{
   FLACStreaming example - part of libFLAC_dyn

   Copyright 2023 Ilya Medvedkov

   In this example, an FLAC-ogg file (named cInputFile) is opened and decoded
   into a data stream. The resulting stream is then re-encoded into a set of
   FLAC packages. A set of packages is saved to a file on disk (cStreamFile) in
   the user's format. A file with a set of packages is opened, decoded into a
   data stream and saved in a new file in FLAC-ogg format (cOutputFile).

   step 1.
   cInputFile->FLACOggDecoder->[pcm]->FLACEncoder->[FLAC packets]->cStreamFile[N]
   step 2.
   cStreamFile[N]->FLACAltDecoder->[pcm]->FLACOggEncoder->[ogg container]->cOutputFile
}

program FLACstreaming;
uses
  {$ifdef LINUX}
  cthreads,
  {$endif}
  Classes, SysUtils,
  OGLFLACWrapper, OGLOGGWrapper, OGLSoundUtils, OGLSoundUtilTypes;

const // the name of source FLAC-ogg file
      cInputFile  = '..' + PathDelim + 'media' + PathDelim + 'testing.ogg';
      // the name of the intermediate file with encoded packets in user`s format
      cStreamFile = '..' + PathDelim + 'media' + PathDelim + 'flacpacket';
      cOGGs = '.oggs';
      // the name of dest reencoded FLAC-ogg file
      cOutputFile = '..' + PathDelim + 'media' + PathDelim + 'output.ogg';
      {$ifdef Windows}
      cFLACDLL : String  '..\libs\flac.dll';
      {$endif}
      // duration of data chunk to encode
      cChunckDuration : Integer = 500; // 0.5 second
      cChunckSize     : Integer = 4096;

var
  oggf : TFLACOggFile; // interface to encode/decode FLAC-Ogg data
  pack_enc : TFLACStreamEncoder;  // FLAC custom streaming encoder
  pack_dec : TFLACStreamDecoder;  // FLAC custom streaming decoder
  aFileStream : TFileStream;      // TFileStream linked to cStreamFile
  Buffer : Pointer;               // intermediate buffer
  len : ISoundFrameSize;          // length of data
  MaxLength,
  ChunkLength,
  frame_len : ISoundFrameSize;    // total length of frame
  i : Integer;
  fEOF  : Boolean;
  Files : TStringList;
  aFile : String;

  aEncProps : ISoundEncoderProps; // encoder properties
begin
  // Initialize FLAC, FLACenc, FLACfile interfaces - load libraries
  {$ifdef Windows}
  if TFLAC.FLACLibsLoad([cFLACDLL]) then
  {$else}
  if TFLAC.FLACLibsLoadDefault then
  {$endif}
  begin
    Files := TStringList.Create;
    // Create FLAC-Ogg encoder/decoder interface
    oggf := TFLACOggFile.Create;
    try
      // Config TFLACFile to decoder state (FLACfile mode)
      if oggf.LoadFromFile(cInputFile, false) then
      begin
        // cInputFile opended and headers/coments are loaded
        MaxLength := oggf.Decoder.FrameFromDuration(cChunckDuration);
        ChunkLength := oggf.Decoder.FrameFromBytes(cChunckSize);

        // gen encoder properties
        // Compression level = 5
        aEncProps := TOGLSound.EncProps([TOGLSound.PROP_CHANNELS, oggf.Channels,
                                         TOGLSound.PROP_FREQUENCY, oggf.Frequency,
                                         TOGLSound.PROP_SAMPLE_SIZE, ss16bit,
                                         TFLAC.PROP_COMPR_LEVEL, fclLevel5,
                                         // FLAC specifies a subset of itself as
                                         // the Subset format
                                         TFLAC.PROP_SUBSET, True]);

        // initialize intermediate buffer to store decoded data chunk
        Buffer := GetMem(cChunckSize);
        try
          pack_enc := nil;
          fEOF := false;
          while not fEOF do
          begin
            aFile := cStreamFile + Format('%.4d', [Files.Count + 1]) + cOGGs;
            Files.Add(aFile);

            aFileStream := TFileStream.Create(aFile, fmOpenWrite or fmCreate);
            try
              // initialize custom streaming encoder
              if not Assigned(pack_enc) then
                pack_enc := TFLAC.FLACStreamEncoder(aFileStream, aEncProps, nil)
              else
                pack_enc.SetStream(aFileStream);
              frame_len := TOGLSound.NewEmptyFrame(MaxLength);
              repeat
                // read decoded pcm data from FLAC-ogg file
                // len - length of decoded data in bytes
                len := oggf.ReadData(Buffer, ChunkLength, nil);

                if len.IsValid then
                begin
                  frame_len.Inc(len);
                  // this is where pcm data is encoded into the FLAC packets.
                  pack_enc.WriteData(Buffer, len, nil);
                end else
                  fEOF := true;
              until len.Less(ChunkLength) or
                    frame_len.GreaterOrEqual(MaxLength) or fEOF;
              if fEOF then
                pack_enc.Close(nil);
            finally
              aFileStream.Free;
            end;
          end;
          // complete the stream formation process.
          // write the packets that are in the cache.
          if Assigned(pack_enc) then
          begin
            pack_enc.Free;
          end;
        finally
          FreeMemAndNil(Buffer);
        end;

        // remove streaming prop
        aEncProps.Exclude(TFLAC.PROP_SUBSET);
        // Config TFLACOggFile to encode state (FLACenc mode)
        // and create/open to write cOutputFile
        // Compression level = 5
        if oggf.SaveToFile(cOutputFile, aEncProps, nil) then
        begin
          // cOutputFile has been created/opened and headers/comments have
          // been
          // initialize intermediate buffer to store decoded data chunk
          Buffer := GetMem(cChunckSize);
          try
            pack_dec := nil;
            // initialize custom streaming decoder
            For i := 0 to Files.Count-1 do
            begin
              // open file stream to read from cStreamFile
              aFileStream := TFileStream.Create(Files[i], fmOpenRead);
              try
                pack_dec := TFLAC.FLACStreamDecoder(aFileStream);
                try
                  repeat
                    // read decoded pcm data from FLAC streaming file
                    len := pack_dec.ReadData(Buffer, ChunkLength, nil);

                    if len.IsValid then begin
                      // this is where pcm data samples are encoded into the
                      // FLAC-ogg format and then written to the FLAC-ogg file.
                      oggf.WriteData(Buffer, len, nil);
                    end;
                  until len.Less(ChunkLength);
                finally
                  pack_dec.Free;
                end;
              finally
                aFileStream.Free;
              end;
            end;
          finally
            FreeMemAndNil(Buffer);
          end;
          // complete the ogg stream formation process.
          // write the ogg data that is in the cache.
          oggf.StopStreaming;
        end;
      end;
    finally
      oggf.Free;
      Files.Free;
    end;
    // close FLAC interfaces
    TFLAC.FLACLibsUnLoad;
  end else
    WriteLn('Cant load libraries');
end.

