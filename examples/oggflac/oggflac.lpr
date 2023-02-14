{
   FLACFLAC example - part of libFLAC_dyn

   Copyright 2023 Ilya Medvedkov

   In this example, pcm audio data is recorded by OpenAL, encoded and saved
   to a file in opus-ogg format in streaming mode.
   Then the saved file is opened, audio data is read and decoded, then played
   by OpenAL with buffering.

   Additionally required the OpenAL_soft library:
      https://github.com/iLya2IK/libOpenALsoft_dyn
}

program oggflac;

uses
  {$ifdef LINUX}
  cthreads,
  {$endif}
  Classes, SysUtils,
  OGLFLACWrapper, OGLOpenALWrapper, OGLOGGWrapper,
  OGLSoundUtils, OGLSoundUtilTypes;

type

  { TOALStreamDataRecorder, TOALStreamDataSource child classes
    to implement FLAC-Ogg data encoding/decoding in streaming mode }

  { TOALFLACDataRecorder }

  TOALFLACDataRecorder = class(TOALStreamDataRecorder)
  private
    FStream : TFLACFile;
  public
    constructor Create(aFormat : TOALFormat; aFreq : Cardinal); override;
    destructor Destroy; override;
    function SaveToFile(const Fn : String) : Boolean; override;
    function SaveToStream({%H-}Str : TStream) : Boolean; override;

    procedure StopRecording; override;

    function WriteSamples(const Buffer : Pointer;
                          Count : Integer) : Integer; override;
  end;

  { TOALFLACDataSource }

  TOALFLACDataSource = class(TOALStreamDataSource)
  private
    FStream : TFLACFile;
  public
    constructor Create; override;
    destructor Destroy; override;

    function LoadFromFile(const Fn : String) : Boolean; override;
    function LoadFromStream({%H-}Str : TStream) : Boolean; override;

    function ReadChunk(const Buffer : Pointer;
                         {%H-}Pos : Int64;
                         Sz  : Integer;
                         {%H-}isloop : Boolean;
                         var fmt : TOALFormat;
                         var freq : Cardinal) : Integer; override;
  end;

constructor TOALFLACDataSource.Create;
begin
  inherited Create;
  FStream := TFLACFile.Create;
end;

destructor TOALFLACDataSource.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TOALFLACDataSource.LoadFromFile(const Fn : String) : Boolean;
begin
  Result := FStream.LoadFromFile(Fn, false);
end;

function TOALFLACDataSource.LoadFromStream(Str : TStream) : Boolean;
begin
  Result := false;
end;

function TOALFLACDataSource.ReadChunk(const Buffer : Pointer; Pos : Int64;
  Sz : Integer; isloop : Boolean; var fmt : TOALFormat; var freq : Cardinal
  ) : Integer;
begin
  fmt := TOpenAL.OALFormat(FStream.Channels, FStream.Bitdepth);
  freq := FStream.Frequency;
  Result := FStream.ReadData(Buffer, FStream.Decoder.FrameFromBytes(Sz),
                                     nil).AsBytes;
end;

constructor TOALFLACDataRecorder.Create(aFormat : TOALFormat; aFreq : Cardinal
  );
begin
  inherited Create(aFormat, aFreq);
  FStream := TFLACFile.Create;
end;

destructor TOALFLACDataRecorder.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TOALFLACDataRecorder.SaveToFile(const Fn : String) : Boolean;
var
  channels : Cardinal;
  ss : TSoundSampleSize;
  comments : ISoundComment;
begin
  case Format of
  oalfMono8 :
    begin
    ss := ss8bit;;
    channels := 1;
    end;
  oalfMono16 :
    begin
    ss := ss16bit;
    channels := 1
    end;
  oalfStereo8 :
    begin
    ss := ss8bit;;
    channels := 2;
    end;
  oalfStereo16 :
    begin
    ss := ss16bit;
    channels := 2
    end;
  end;


  comments := TFLAC.NewEncComment;
  comments.Vendor := 'OALFLACDataRecorder';
  with TOGLSoundComments do
  begin
  comments.AddTag(TagID(COMMENT_ARTIST), 'Your voice');
  comments.AddTag(TagID(COMMENT_TITLE),  'Record');
  end;
  Result := FStream.SaveToFile(Fn,
                       TOGLSound.EncProps([TOGLSound.PROP_CHANNELS,  channels,
                                           TOGLSound.PROP_FREQUENCY, Frequency,
                                           TOGLSound.PROP_SAMPLE_SIZE, ss,
                                           TFLAC.PROP_COMPR_LEVEL, fclLevel5]),
                                           comments);
end;

function TOALFLACDataRecorder.SaveToStream(Str : TStream) : Boolean;
begin
  //do nothing
  Result := false;
end;

procedure TOALFLACDataRecorder.StopRecording;
begin
  FStream.StopStreaming;
end;

function TOALFLACDataRecorder.WriteSamples(const Buffer : Pointer; Count : Integer
  ) : Integer;
begin
  Result := FStream.WriteData(Buffer, FStream.Encoder.FrameFromSamples(Count),
                                      nil).AsSamples;
end;

const // name of file to capture data
      cCaptureFile = 'capture.flac';
      {$ifdef Windows}
      cOALDLL = '..\libs\soft_oal.dll';
      cFLACDLL = '..\libs\flac.dll';
      {$endif}
      {$ifdef DEBUG}
      cHeapTrace = 'heaptrace.trc';
      {$endif}

var
  OALCapture : TOALCapture; // OpenAL audio recoder
  OALPlayer  : TOALPlayer;  // OpenAL audio player
  dt: Integer;
begin
  {$ifdef DEBUG}
  if FileExists(cHeapTrace) then
     DeleteFile(cHeapTrace);
  SetHeapTraceOutput(cHeapTrace);
  {$endif}

  // Open FLAC, Ogg, OpenAL libraries and initialize interfaces
  {$ifdef Windows}
  if TOpenAL.OALLibsLoad([cOALDLL]) and TFLAC.FLACLibsLoad([cFLACDLL]) then
  {$else}
  if TOpenAL.OALLibsLoadDefault and TFLAC.FLACLibsLoadDefault then
  {$endif}
  begin
    // create OpenAL audio recoder
    OALCapture := TOALCapture.Create;
    try
      try
        // config OpenAL audio recoder
        OALCapture.DataRecClass := TOALFLACDataRecorder;
        // initialize OpenAL audio recoder
        OALCapture.Init;
        // configure buffering for the audio recorder to save data to a file
        if OALCapture.SaveToFile(cCaptureFile) then
        begin
          // start to record data with OpanAL
          OALCapture.Start;

          // run recording loop
          dt := 0;
          while dt < 1000 do begin
            // capture new data chunk and encode/write with opusenc to
            // cCaptureFile in opus-ogg format
            OALCapture.Proceed;
            TThread.Sleep(10);
            inc(dt);
          end;

          //stop recording. close opus-ogg file cCaptureFile
          OALCapture.Stop;

          WriteLn('Capturing completed successfully!');

        end else
          WriteLn('Cant save to ogg-opus file');

      except
        on e : Exception do WriteLn(e.ToString);
      end;
    finally
      OALCapture.Free;
    end;

    // create OpenAL audio player
    OALPlayer := TOALPlayer.Create;
    try
      try
        // config OpenAL audio player
        OALPlayer.DataSourceClass := TOALFLACDataSource;
        // initialize OpenAL audio player
        OALPlayer.Init;
        // configure buffering for the audio player to read data from file
        if OALPlayer.LoadFromFile(cCaptureFile) then
        begin
          // start to play audio data with OpanAL
          OALPlayer.Play;

          // run playing loop. do while the data is available
          while OALPlayer.Status = oalsPlaying do begin
            // if there are empty buffers available - read/decode new data chunk
            // from cCaptureFile with opusfile and put them in the queue
            OALPlayer.Stream.Proceed;
            TThread.Sleep(10);
          end;

          WriteLn('Playing completed successfully!');

        end else
          WriteLn('Cant load ogg-FLAC file');

      except
        on e : Exception do WriteLn(e.ToString);
      end;
    finally
      OALPlayer.Free;
    end;

    // close interfaces
    TOpenAL.OALLibsUnLoad;
    TFLAC.FLACLibsUnLoad;
  end else
    WriteLn('Cant load libraries');
end.

