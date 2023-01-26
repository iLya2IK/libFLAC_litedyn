{
 OGLFLACWrapper:
   Wrapper for FLAC library

   Copyright (c) 2023 by Ilya Medvedkov

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit OGLFLACWrapper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, libFLAC_dynlite,
  OGLOGGWrapper, OGLSoundUtils, OGLSoundUtilTypes, OGLSoundDataConverting;

type

  TFLACCompressionLevel = (fclLevel0, fclLevel1, fclLevel2, fclLevel3,
                           fclLevel4, fclLevel5, fclLevel6, fclLevel7,
                           fclLevel8);

  TFLACEncoderInitStatus = (  fseisOK,
                                    fseisEncoderError,
                                    fseisUnsupportedContainer,
                                    fseisInvalidCallbacks,
                                    fseisInvalidNumberOfChannels,
                                    fseisInvalidBitsPerSample,
                                    fseisInvalidSampleRate,
                                    fseisInvalidBlockSize,
                                    fseisInvalidMaxLPCOrder,
                                    fseisInvalidQLPCoeffPrecision,
                                    fseisBlockSizeTooSmallForLPCOrder,
                                    fseisNotStreamable,
                                    fseisInvalidMetadata,
                                    fseisAlreadyInitialized);

  TFLACEncoderState = ( fsesOK, fsesUnInitialized, fsesOggError,
                              fsesVerifyDecoderError,
                              fsesVerifyMismatchInAudioData,
                              fsesClientError, fsesIOError, fsesFramingError,
                              fsesMemoryAllocError);

  TFLACStreamDecoderInitStatus = (  fsdisOK,
                                    fsdisEncoderError,
                                    fsdisUnsupportedContainer,
                                    fsdisInvalidCallbacks,
                                    fsdisInvalidNumberOfChannels,
                                    fsdisInvalidBitsPerSample,
                                    fsdisInvalidSampleRate,
                                    fsdisInvalidBlockSize,
                                    fsdisInvalidMaxLPCOrder,
                                    fsdisInvalidQLPCoeffPrecision,
                                    fsdisBlockSizeTooSmallForLPCOrder,
                                    fsdisNotStreamable,
                                    fsdisInvalidMetadata,
                                    fsdisAlreadyInitialized);

  TFLACStreamDecoderState = ( fsdsSearchMetadata,
                              fsdsReadMetadata,
                              fsdsSearchFrameSync,
                              fsdsReadFrame,
                              fsdsEOS,
                              fsdsOGGError,
                              fsdsSeekError,
                              fsdsAborted,
                              fsdsMemoryAllocError,
                              fsdsUnInitialized );

  TFLACChannelAssignment = ( fcaIndependent,
                             fcaLeftSide,
                             fcaRightSide,
                             fcaMidSide );

  IFLACComment = interface(IOGGComment)
  ['{8C90A978-8544-4AE8-8164-ED856ED256B7}']
  end;

  { IFLACEncoder }

  IFLACEncoder = interface
  ['{D837FBA4-A1A8-408D-9E63-FAA2DE724141}']
  function Ref : pFLAC__StreamEncoder;

  procedure Init;
  function InitStream(
    write_callback: FLAC__StreamEncoderWriteCallback;
    seek_callback: FLAC__StreamEncoderSeekCallback;
    tell_callback: FLAC__StreamEncoderTellCallback;
    metadata_callback: FLAC__StreamEncoderMetadataCallback;
    client_data: pointer): TFLACEncoderInitStatus;
  function InitOGGStream(
    read_callback: FLAC__StreamEncoderReadCallback;
    write_callback: FLAC__StreamEncoderWriteCallback;
    seek_callback: FLAC__StreamEncoderSeekCallback;
    tell_callback: FLAC__StreamEncoderTellCallback;
    metadata_callback: FLAC__StreamEncoderMetadataCallback;
    client_data: pointer): TFLACEncoderInitStatus;
  function Finish: Boolean;
  procedure Done;

  procedure SetOggSerialNumber(serial_number: Longint);
  procedure SetVerify(aValue: Boolean);
  procedure SetStreamableSubset(aValue: Boolean);
  procedure SetChannels(aValue: Cardinal);
  procedure SetBitsPerSample(aValue: Cardinal);
  procedure SetSampleRate(aValue: Cardinal);
  procedure SetCompressionLevel(aValue: TFLACCompressionLevel);
  procedure SetBlocksize(aValue: Cardinal);
  procedure SetDoMidSideStereo(aValue: Boolean);
  procedure SetLooseMidSideStereo(aValue: Boolean);
  procedure SetApodization(const specification: String);
  procedure SetMaxLPCOrder(aValue: Cardinal);
  procedure SetQLPCoeffPrecision(aValue: Cardinal);
  procedure SetDoQLPCoeffPrecSearch(aValue: Boolean);
  procedure SetDoEscapeCoding(aValue: Boolean);
  procedure SetDoExhaustiveModelSearch(aValue: Boolean);
  procedure SetMinResidualPartitionOrder(aValue: Cardinal);
  procedure SetMaxResidualPartitionOrder(aValue: Cardinal);
  procedure SetRiceParameterSearchDist(aValue: Cardinal);
  procedure SetTotalSamplesEstimate(aValue: QWord);
  //procedure SetMetadata(metadata: IFLACStreamMetadata; num_blocks: Cardinal);
  procedure SetLimitMinBitrate(aValue: Boolean);

  function GetState: TFLACEncoderState;
  function GetVerifyDecoderState: TFLACStreamDecoderState;
  function GetResolvedStateString: String;
  procedure GetVerifyDecoderErrorStats(absolute_sample: PQWord;
                                       frame_number: PCardinal;
                                       channel: PCardinal;
                                       sample: PCardinal;
                                       expected: PInteger;
                                       got: PInteger);
  function GetVerify: Boolean;
  function GetStreamableSubset: Boolean;
  function GetChannels : Cardinal;
  function GetBitsPerSample: Cardinal;
  function GetSampleRate: Cardinal;
  function GetBlocksize: Cardinal;
  function GetDoMidSideStereo: Boolean;
  function GetLooseMidSideStereo: Boolean;
  function GetMaxLPCOrder: Cardinal;
  function GetQLPCoeffPrecision: Cardinal;
  function GetDoQLPCoeffPrecSearch: Boolean;
  function GetDoEscapeCoding: Boolean;
  function GetDoExhaustiveModelSearch: Boolean;
  function GetMinResidualPartitionOrder: Cardinal;
  function GetMaxResidualPartitionOrder: Cardinal;
  function GetRiceParameterSearchDist: Cardinal;
  function GetTotalSamplesEstimate: QWord;
  function GetLimitMinBitrate: Boolean;

  function Process(const buffer: pointer; samples: Cardinal): Boolean;
  function ProcessInterleaved(const buffer: pointer; samples: Cardinal): Boolean;

  property Channels : Cardinal read GetChannels write SetChannels;
  property Verify : Boolean read GetVerify write SetVerify;
  property StreamableSubset : Boolean read GetStreamableSubset write SetStreamableSubset;
  property BitsPerSample : Cardinal read GetBitsPerSample write SetBitsPerSample;
  property SampleRate : Cardinal read GetSampleRate write SetSampleRate;
  property Blocksize : Cardinal read GetBlocksize write SetBlocksize;
  property DoMidSideStereo : Boolean read GetDoMidSideStereo write SetDoMidSideStereo;
  property LooseMidSideStereo : Boolean read GetLooseMidSideStereo write SetLooseMidSideStereo;
  property MaxLPCOrder : Cardinal read GetMaxLPCOrder write SetMaxLPCOrder;
  property QLPCoeffPrecision : Cardinal read GetQLPCoeffPrecision write SetQLPCoeffPrecision;
  property DoQLPCoeffPrecSearch : Boolean read GetDoQLPCoeffPrecSearch write SetDoQLPCoeffPrecSearch;
  property DoEscapeCoding : Boolean read GetDoEscapeCoding write SetDoEscapeCoding;
  property DoExhaustiveModelSearch : Boolean read GetDoExhaustiveModelSearch write SetDoExhaustiveModelSearch;
  property MinResidualPartitionOrder : Cardinal read GetMinResidualPartitionOrder write SetMinResidualPartitionOrder;
  property MaxResidualPartitionOrder : Cardinal read GetMaxResidualPartitionOrder write SetMaxResidualPartitionOrder;
  property RiceParameterSearchDist : Cardinal read GetRiceParameterSearchDist write SetRiceParameterSearchDist;
  property TotalSamplesEstimate : QWord read GetTotalSamplesEstimate write SetTotalSamplesEstimate;
  property LimitMinBitrate : Boolean read GetLimitMinBitrate write SetLimitMinBitrate;
  end;

  IFLACDecoder = interface
  ['{3E63CAC8-7324-4AF6-B509-4ADDA6F9B54F}']
  function Ref : pFLAC__StreamDecoder;

  procedure Init;
  function InitStream(
    read_callback: FLAC__StreamDecoderReadCallback;
    seek_callback: FLAC__StreamDecoderSeekCallback;
    tell_callback: FLAC__StreamDecoderTellCallback;
    length_callback: FLAC__StreamDecoderLengthCallback;
    eof_callback: FLAC__StreamDecoderEofCallback;
    write_callback: FLAC__StreamDecoderWriteCallback;
    metadata_callback: FLAC__StreamDecoderMetadataCallback;
    error_callback: FLAC__StreamDecoderErrorCallback;
    client_data: pointer): TFLACStreamDecoderInitStatus;
  function InitOGGStream(
    read_callback: FLAC__StreamDecoderReadCallback;
    seek_callback: FLAC__StreamDecoderSeekCallback;
    tell_callback: FLAC__StreamDecoderTellCallback;
    length_callback: FLAC__StreamDecoderLengthCallback;
    eof_callback: FLAC__StreamDecoderEofCallback;
    write_callback: FLAC__StreamDecoderWriteCallback;
    metadata_callback: FLAC__StreamDecoderMetadataCallback;
    error_callback: FLAC__StreamDecoderErrorCallback;
    client_data: pointer): TFLACStreamDecoderInitStatus;
  function Finish: Boolean;
  procedure Done;

  function SetOggSerialNumber(serial_number: Longint): Boolean;
  procedure SetMD5Checking(aValue: Boolean);
  procedure SetMetaSampleRate(aValue : Cardinal);
  procedure SetMetaChannels(aValue : Cardinal);
  procedure SetMetaBitsPerSample(aValue : Cardinal);
  function SetMetadataRespond(atype: FLAC__MetadataType): Boolean;
  function SetMetadataRespondApplication(const id: TFLAC__byteArray4): Boolean;
  function SetMetadataRespondAll: Boolean;
  function SetMetadataIgnore(atype: FLAC__MetadataType): Boolean;
  function SetMetadataIgnoreApplication(const id: TFLAC__byteArray4): Boolean;
  function SetMetadataIgnoreAll: Boolean;

  function GetState: TFLACStreamDecoderState;
  function GetResolvedStateString: String;
  function GetMD5Checking: Boolean;
  function GetTotalSamples: QWord;
  function GetChannels: Cardinal;
  function GetChannelAssignment: TFLACChannelAssignment;
  function GetBitsPerSample: Cardinal;
  function GetSampleRate: Cardinal;
  function GetBlocksize: Cardinal;
  function GetDecodePosition: QWord;
  function GetClientData: pointer;

  function Flush: Boolean;
  function Reset: Boolean;

  function ProcessSingle: Boolean;
  function ProcessUntilEndOfMetadata: Boolean;
  function ProcessUntilEndOfStream: Boolean;
  function SkipSingleFrame: Boolean;
  function SeekAbsolute(sample: QWord): Boolean;

  property Channels : Cardinal read GetChannels;
  property BitsPerSample : Cardinal read GetBitsPerSample;
  property SampleRate : Cardinal read GetSampleRate;
  property Blocksize : Cardinal read GetBlocksize;
  property MD5Checking : Boolean read GetMD5Checking write SetMD5Checking;
  end;

  { TFLACComment }

  TFLACComment = class(TInterfacedObject, IFLACComment)
  private
    fRef : pFLAC__StreamMetadata;
  public
    function Ref : Pointer;

    procedure Init;
    procedure Done;

    procedure Add(const comment: String);
    procedure AddTag(const tag, value: String);
    function Query(const tag: String; index: integer): String;
    function QueryCount(const tag: String): integer;
  end;

  { TFLACEncoder }

  TFLACEncoder = class(TInterfacedObject, IFLACEncoder)
  private
    fRef : pFLAC__StreamEncoder;
  protected
    function GetVerify: Boolean;
    function GetStreamableSubset: Boolean;
    function GetChannels : Cardinal;
    function GetBitsPerSample: Cardinal;
    function GetSampleRate: Cardinal;
    function GetBlocksize: Cardinal;
    function GetDoMidSideStereo: Boolean;
    function GetLooseMidSideStereo: Boolean;
    function GetMaxLPCOrder: Cardinal;
    function GetQLPCoeffPrecision: Cardinal;
    function GetDoQLPCoeffPrecSearch: Boolean;
    function GetDoEscapeCoding: Boolean;
    function GetDoExhaustiveModelSearch: Boolean;
    function GetMinResidualPartitionOrder: Cardinal;
    function GetMaxResidualPartitionOrder: Cardinal;
    function GetRiceParameterSearchDist: Cardinal;
    function GetTotalSamplesEstimate: QWord;
    function GetLimitMinBitrate: Boolean;

    procedure SetVerify(aValue: Boolean);
    procedure SetStreamableSubset(aValue: Boolean);
    procedure SetChannels(aValue: Cardinal);
    procedure SetBitsPerSample(aValue: Cardinal);
    procedure SetSampleRate(aValue: Cardinal);
    procedure SetBlocksize(aValue: Cardinal);
    procedure SetDoMidSideStereo(aValue: Boolean);
    procedure SetLooseMidSideStereo(aValue: Boolean);
    procedure SetApodization(const specification: String);
    procedure SetMaxLPCOrder(aValue: Cardinal);
    procedure SetQLPCoeffPrecision(aValue: Cardinal);
    procedure SetDoQLPCoeffPrecSearch(aValue: Boolean);
    procedure SetDoEscapeCoding(aValue: Boolean);
    procedure SetDoExhaustiveModelSearch(aValue: Boolean);
    procedure SetMinResidualPartitionOrder(aValue: Cardinal);
    procedure SetMaxResidualPartitionOrder(aValue: Cardinal);
    procedure SetRiceParameterSearchDist(aValue: Cardinal);
    procedure SetTotalSamplesEstimate(aValue: QWord);
    procedure SetLimitMinBitrate(aValue: Boolean);

    procedure Init;
    function InitStream(
      write_callback: FLAC__StreamEncoderWriteCallback;
      seek_callback: FLAC__StreamEncoderSeekCallback;
      tell_callback: FLAC__StreamEncoderTellCallback;
      metadata_callback: FLAC__StreamEncoderMetadataCallback;
      client_data: pointer): TFLACEncoderInitStatus;
    function InitOGGStream(
      read_callback: FLAC__StreamEncoderReadCallback;
      write_callback: FLAC__StreamEncoderWriteCallback;
      seek_callback: FLAC__StreamEncoderSeekCallback;
      tell_callback: FLAC__StreamEncoderTellCallback;
      metadata_callback: FLAC__StreamEncoderMetadataCallback;
      client_data: pointer): TFLACEncoderInitStatus;
    function Finish: Boolean;
    procedure Done;
  public
    function Ref : pFLAC__StreamEncoder; inline;

    constructor Create(aChannels : Cardinal;
                       aFreq : Cardinal;
                       aSampleSize : TSoundSampleSize;
                       aComprLevel : TFLACCompressionLevel);
    destructor Destroy; override;

    procedure SetOggSerialNumber(serial_number: Longint);
    procedure SetCompressionLevel(aValue: TFLACCompressionLevel);
    //procedure SetMetadata(metadata: IFLACStreamMetadata; num_blocks: Cardinal);

    function GetState: TFLACEncoderState;
    function GetVerifyDecoderState: TFLACStreamDecoderState;
    function GetResolvedStateString: String;
    procedure GetVerifyDecoderErrorStats(absolute_sample: PQWord;
                                         frame_number: PCardinal;
                                         channel: PCardinal;
                                         sample: PCardinal;
                                         expected: PInteger;
                                         got: PInteger);

    function Process(const buffer: pointer; samples: Cardinal): Boolean;
    function ProcessInterleaved(const buffer: pointer; samples: Cardinal): Boolean;
  end;

  { TFLACDecoder }

  TFLACDecoder = class(TInterfacedObject, IFLACDecoder)
  private
    fRef : pFLAC__StreamDecoder;
    fMetaSampleRate : Cardinal;
    fMetaChannels   : Cardinal;
    fMetaBPS  : Cardinal;
  protected
    function SetOggSerialNumber(serial_number: Longint): Boolean;
    procedure SetMD5Checking(aValue: Boolean);
    procedure SetMetaSampleRate(aValue : Cardinal);
    procedure SetMetaChannels(aValue : Cardinal);
    procedure SetMetaBitsPerSample(aValue : Cardinal);
    function SetMetadataRespond(atype: FLAC__MetadataType): Boolean;
    function SetMetadataRespondApplication(const id: TFLAC__byteArray4): Boolean;
    function SetMetadataRespondAll: Boolean;
    function SetMetadataIgnore(atype: FLAC__MetadataType): Boolean;
    function SetMetadataIgnoreApplication(const id: TFLAC__byteArray4): Boolean;
    function SetMetadataIgnoreAll: Boolean;

    function GetState: TFLACStreamDecoderState;
    function GetResolvedStateString: String;
    function GetMD5Checking: Boolean;
    function GetTotalSamples: QWord;
    function GetChannels: Cardinal;
    function GetChannelAssignment: TFLACChannelAssignment;
    function GetBitsPerSample: Cardinal;
    function GetSampleRate: Cardinal;
    function GetBlocksize: Cardinal;
    function GetDecodePosition: QWord;
    function GetClientData: pointer;

    procedure Init;
    function InitStream(
      read_callback: FLAC__StreamDecoderReadCallback;
      seek_callback: FLAC__StreamDecoderSeekCallback;
      tell_callback: FLAC__StreamDecoderTellCallback;
      length_callback: FLAC__StreamDecoderLengthCallback;
      eof_callback: FLAC__StreamDecoderEofCallback;
      write_callback: FLAC__StreamDecoderWriteCallback;
      metadata_callback: FLAC__StreamDecoderMetadataCallback;
      error_callback: FLAC__StreamDecoderErrorCallback;
      client_data: pointer): TFLACStreamDecoderInitStatus;
    function InitOGGStream(
      read_callback: FLAC__StreamDecoderReadCallback;
      seek_callback: FLAC__StreamDecoderSeekCallback;
      tell_callback: FLAC__StreamDecoderTellCallback;
      length_callback: FLAC__StreamDecoderLengthCallback;
      eof_callback: FLAC__StreamDecoderEofCallback;
      write_callback: FLAC__StreamDecoderWriteCallback;
      metadata_callback: FLAC__StreamDecoderMetadataCallback;
      error_callback: FLAC__StreamDecoderErrorCallback;
      client_data: pointer): TFLACStreamDecoderInitStatus;
    function Finish: Boolean;
    procedure Done;
  public
    function Ref : pFLAC__StreamDecoder; inline;

    constructor Create;
    destructor Destroy; override;

    function Flush: Boolean;
    function Reset: Boolean;

    function ProcessSingle: Boolean;
    function ProcessUntilEndOfMetadata: Boolean;
    function ProcessUntilEndOfStream: Boolean;
    function SkipSingleFrame: Boolean;
    function SeekAbsolute(sample: QWord): Boolean;
  end;

  { TFLACAbstractEncoder }

  TFLACAbstractEncoder = class(TSoundAbstractEncoder)
  private
    fRef : IFLACEncoder;
    fComm : IOGGComment;
    fImBuf : Pointer;
  protected
    procedure InitFLACEncoder; virtual;
    procedure Init(aProps : ISoundEncoderProps;
                   aComments : ISoundComment); override;
    procedure Done; override;

    function GetBitdepth : Cardinal; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetMode : TSoundEncoderMode; override;
    function GetQuality : Single; override;
    function GetVersion : Integer; override;

    class function DefaultIntermediateBufferSamplesSize : Integer;
  public
    function Ref : IFLACEncoder; inline;

    constructor Create(aProps : ISoundEncoderProps;
                       aComments : IOGGComment);
    destructor Destroy; override;

    function  Comments : IOGGComment; override;

    function  WriteData(Buffer : Pointer; Count : ISoundFrameSize;
                       {%H-}Par : Pointer) : ISoundFrameSize; override;
    procedure Close({%H-}Par : Pointer); override;

    function Ready : Boolean; override;
  end;

  { TFLACOggEncoder }

  TFLACOggEncoder = class(TFLACAbstractEncoder)
  protected
    procedure InitFLACEncoder; override;
  end;

  { TFLACStreamEncoder }

  TFLACStreamEncoder = class(TFLACAbstractEncoder)
  public
    constructor Create(aStream : TStream;
                       aProps : ISoundEncoderProps;
                       aComments : IOGGComment);
    procedure SetStream(aStream : TStream);
  end;

  { TFLACOggStreamEncoder }

  TFLACOggStreamEncoder = class(TFLACOggEncoder)
  public
    constructor Create(aStream : TStream;
                       aProps : ISoundEncoderProps;
                       aComments : IOGGComment);
    procedure SetStream(aStream : TStream);
  end;

  { TFLACAbstractDecoder }

  TFLACAbstractDecoder = class(TSoundAbstractDecoder)
  private
    fRef  : IFLACDecoder;
    fComm : IOGGComment;

    FActiveBuffer : Pointer;
    fABSize, fABPos : Integer;

    fOverBuffer : Pointer;
    fOBSize, fOBPos : Integer;

    procedure ReadMetadata;
  protected
    procedure WriteFLAC(const frame : pFLAC__Frame; data : PPointer);
    procedure InitFLACDecoder; virtual;
    procedure Init; override;
    procedure Done; override;

    function GetBitdepth : Cardinal; override;
    function GetBitrate : Cardinal; override;
    function GetChannels : Cardinal; override;
    function GetFrequency : Cardinal; override;
    function GetVersion : Integer; override;

    class function DefaultOverflowBufferSize : Integer;
  public
    function Ref : IFLACDecoder; inline;

    constructor Create;
    destructor Destroy; override;

    function  Comments : IOGGComment; override;

    function ReadData(Buffer : Pointer; Count : ISoundFrameSize;
                       {%H-}Par : Pointer) : ISoundFrameSize; override;
    procedure ResetToStart; override;

    function Ready : Boolean; override;
  end;

  { TFLACOggDecoder }

  TFLACOggDecoder = class(TFLACAbstractDecoder)
  protected
    procedure InitFLACDecoder; override;
  end;

  { TFLACStreamDecoder }

  TFLACStreamDecoder = class(TFLACAbstractDecoder)
  public
    constructor Create(aStream : TStream);
    procedure SetStream(aStream : TStream);
  end;

  { TFLACOggStreamDecoder }

  TFLACOggStreamDecoder = class(TFLACOggDecoder)
  public
    constructor Create(aStream : TStream);
  end;

  { TFLACFile }

  TFLACFile = class(TSoundFile)
  protected
    function InitEncoder(aProps : ISoundEncoderProps;
                   aComments : ISoundComment) : ISoundEncoder; override;
    function InitDecoder : ISoundDecoder; override;
  end;

  { TFLACOggFile }

  TFLACOggFile = class(TSoundFile)
  protected
    function InitEncoder(aProps : ISoundEncoderProps;
                   aComments : ISoundComment) : ISoundEncoder; override;
    function InitDecoder : ISoundDecoder; override;
  end;

  TFLAC = class
  public
    class function NewComment : IFLACComment;
     class function FLACOggStreamEncoder(aStream : TStream;
                       aProps : ISoundEncoderProps;
                       aComments : IOGGComment) : TFLACOggStreamEncoder;
     class function FLACOggStreamDecoder(aStream : TStream) :
                                                         TFLACOggStreamDecoder;
     class function FLACStreamEncoder(aStream : TStream;
                       aProps : ISoundEncoderProps;
                       aComments: IOGGComment) : TFLACStreamEncoder;
     class function FLACStreamDecoder(aStream : TStream) :
                                                         TFLACStreamDecoder;

    class function PROP_COMPR_LEVEL : Cardinal;
    class function PROP_SUBSET : Cardinal;

    class function FLACLibsLoad(const aFLACLibs : array of String) : Boolean;
    class function FLACLibsLoadDefault : Boolean;
    class function IsFLACLibsLoaded : Boolean;
    class function FLACLibsUnLoad : Boolean;
  end;

  { EFLAC }

  EFLAC = class(Exception)
  public
    constructor Create(aError : Integer); overload;
  end;

implementation

uses ctypes;

const cFLACError = 'FLAC error %d';
      cFLACWrongBufferSize = 'Wrong buffer size. Must be a multiple of the sample size';
      cFLACWrongMetadata = 'Wrong metadata';
      cFLACBufferOverflow = 'Internal buffer overflow';
      cFLACWrongSampleSizeDec = 'Sample size is not supported by decoder';
      cFLACWrongSampleSizeEnc = 'Sample size is not supported by encoder';
      cFLACFullError = 'FLAC error (%d) : %s';

function flac_enc_read (
  const {%H-}encoder : pFLAC__StreamEncoder;
  {%H-}buffer : pFLAC__byte;
  {%H-}bytes : pcsize_t;
  {%H-}client_data : Pointer) : FLAC__StreamEncoderReadStatus; cdecl;
begin
  Result := FLAC__STREAM_ENCODER_READ_STATUS_UNSUPPORTED;
end;

function flac_enc_write (
  const {%H-}encoder : pFLAC__StreamEncoder;
  buffer : pFLAC__byte; bytes : csize_t;
  {%H-}samples, {%H-}current_frame : cuint32;
  client_data : Pointer) : FLAC__StreamEncoderWriteStatus; cdecl;
begin
  TFLACAbstractEncoder(client_data).Writer.DoWrite(Pointer(buffer), bytes);
  Result := FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
end;

function flac_enc_seek (
  const {%H-}encoder : pFLAC__StreamEncoder;
  {%H-}absolute_byte_offset : FLAC__uint64;
  {%H-}client_data : Pointer) : FLAC__StreamEncoderSeekStatus; cdecl;
begin
  Result := FLAC__STREAM_ENCODER_SEEK_STATUS_UNSUPPORTED;
end;

function flac_enc_tell (
  const {%H-}encoder : pFLAC__StreamEncoder;
  {%H-}absolute_byte_offset : pFLAC__uint64;
  {%H-}client_data : Pointer) : FLAC__StreamEncoderTellStatus; cdecl;
begin
  Result := FLAC__STREAM_ENCODER_TELL_STATUS_UNSUPPORTED;
end;

procedure flac_enc_meta (
  const {%H-}encoder : pFLAC__StreamEncoder;
  const {%H-}metadata : pFLAC__StreamMetadata;
  {%H-}client_data : Pointer); cdecl;
begin
  // do nothing
  // seek to the beginning and write actual metadata
end;

function flac_dec_read (
  const {%H-}decoder : pFLAC__StreamDecoder;
  buffer : pFLAC__byte; bytes : pcsize_t;
  client_data : pointer) : FLAC__StreamDecoderReadStatus; cdecl;
var rsz : integer;
begin
  rsz := TFLACAbstractDecoder(client_data).Reader.DoRead(buffer, bytes^);
  if rsz > 0 then
  begin
    bytes^ := rsz;
    Result := FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
  end else
  if rsz = 0 then
  begin
    bytes^ := 0;
    Result := FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM;
  end else
    Result := FLAC__STREAM_DECODER_READ_STATUS_ABORT;
end;

function flac_dec_seek (
  const {%H-}decoder : pFLAC__StreamDecoder;
  {%H-}absolute_byte_offset : FLAC__uint64;
  {%H-}client_data : pointer) : FLAC__StreamDecoderSeekStatus; cdecl;
begin
  Result := FLAC__STREAM_DECODER_SEEK_STATUS_UNSUPPORTED;
end;

function flac_dec_tell (
  const {%H-}decoder : pFLAC__StreamDecoder;
  {%H-}absolute_byte_offset : pFLAC__uint64;
  {%H-}client_data : pointer) : FLAC__StreamDecoderTellStatus; cdecl;
begin
  Result := FLAC__STREAM_DECODER_TELL_STATUS_UNSUPPORTED;
end;

function flac_dec_length (
  const {%H-}decoder : pFLAC__StreamDecoder;
  {%H-}stream_length : pFLAC__uint64;
  {%H-}client_data : pointer) : FLAC__StreamDecoderLengthStatus; cdecl;
begin
  Result := FLAC__STREAM_DECODER_LENGTH_STATUS_UNSUPPORTED;
end;

function flac_dec_eof (
  const {%H-}decoder : pFLAC__StreamDecoder;
  {%H-}client_data : pointer) : FLAC__bool; cdecl;
begin
  Result := FLAC__false;
end;

function flac_dec_write (
  const {%H-}decoder : pFLAC__StreamDecoder;
  const frame : pFLAC__Frame; const buffer : Pointer;
  client_data : pointer) : FLAC__StreamDecoderWriteStatus; cdecl;
begin
  try
    TFLACAbstractDecoder(client_data).WriteFLAC(frame, buffer);
    Result := FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
  except
    on e : exception do Result := FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
  end;
end;

procedure flac_dec_meta (
  const {%H-}decoder : pFLAC__StreamDecoder;
  const {%H-}metadata : pFLAC__StreamMetadata;
  {%H-}client_data : pointer); cdecl;
begin
  case (metadata^.atype) of
    FLAC__METADATA_TYPE_STREAMINFO:
    begin
      TFLACAbstractDecoder(client_data).Ref.SetMetaSampleRate(metadata^.data.stream_info.sample_rate);
      TFLACAbstractDecoder(client_data).Ref.SetMetaChannels(metadata^.data.stream_info.channels);
      TFLACAbstractDecoder(client_data).Ref.SetMetaBitsPerSample(metadata^.data.stream_info.bits_per_sample);
    end;
    FLAC__METADATA_TYPE_VORBIS_COMMENT:
    begin
      //todo: write metadata to comments here
    end;
  end;
end;

procedure flac_dec_error (
  const {%H-}decoder : pFLAC__StreamDecoder;
  {%H-}status : FLAC__StreamDecoderErrorStatus;
  {%H-}client_data : pointer); cdecl;
begin
  //todo: proceed the error here (raise exception)
end;

{ TFLACStreamDecoder }

constructor TFLACStreamDecoder.Create(aStream : TStream);
begin
  InitReader(TOGLSound.NewStreamReader(aStream));
  inherited Create;
end;

procedure TFLACStreamDecoder.SetStream(aStream : TStream);
begin
  (Reader as TSoundStreamDataReader).Stream := aStream;
end;

{ TFLACOggStreamDecoder }

constructor TFLACOggStreamDecoder.Create(aStream : TStream);
begin
  InitReader(TOGLSound.NewStreamReader(aStream));
  inherited Create;
end;

{ TFLACOggDecoder }

procedure TFLACOggDecoder.InitFLACDecoder;
begin
  fRef.InitOGGStream(@flac_dec_read, nil, nil, nil, nil,
                  @flac_dec_write, @flac_dec_meta, @flac_dec_error, Self);
end;

{ TFLACAbstractDecoder }

procedure TFLACAbstractDecoder.ReadMetadata;
begin
  if not fRef.ProcessUntilEndOfMetadata then
    raise EFLAC.Create(cFLACWrongMetadata);
end;

procedure TFLACAbstractDecoder.WriteFLAC(const frame : pFLAC__Frame;
  data : PPointer);
var
  i, samples, scnt, bcnt, ssize : integer;
  ss : TSoundSampleSize;
  imed : PPointer;
begin
  if frame^.header.blocksize > 0 then
  begin
    ss := GetSampleSize;
    samples := frame^.header.blocksize;
    ssize := TOGLSound.SampleSizeToBytedepth(ss) * frame^.header.channels;
    if ssize = 0 then Exit;

    // interleave samples
    bcnt := (fABSize - fABPos);
    scnt := bcnt div ssize;
    if scnt > 0 then
    begin
      if scnt > samples then begin
        scnt := samples;
        bcnt := samples * ssize;
      end;
      InterleaveSamples(data, @(PByte(FActiveBuffer)[fABPos]), ss32bit, ss, false, frame^.header.channels, scnt);
      Inc(fABPos, bcnt);
    end;
    if scnt < samples then
    begin
      Dec(samples, scnt);
      imed := GetMem(Sizeof(Pointer) * frame^.header.channels);
      try
        for i := 0 to frame^.header.channels-1 do
          imed[i] := @(pcint32(data[i])[scnt]);

        bcnt := (DefaultOverflowBufferSize - fOBSize);
        scnt := bcnt div ssize;
        if scnt >= samples then
        begin
          scnt := samples;
          bcnt := samples * ssize;
          InterleaveSamples(imed, @(PByte(fOverBuffer)[fOBSize]), ss32bit, ss, false, frame^.header.channels, scnt);
          Inc(fOBSize, bcnt);
        end else
          raise EFLAC.Create(cFLACBufferOverflow);
      finally
        FreeMem(imed);
      end;
    end;
  end;
end;

procedure TFLACAbstractDecoder.InitFLACDecoder;
begin
  fRef.InitStream(@flac_dec_read, nil, nil, nil, nil,
                  @flac_dec_write, @flac_dec_meta, @flac_dec_error, Self);
end;

procedure TFLACAbstractDecoder.Init;
begin
  fComm := TFLAC.NewComment;
  FActiveBuffer := nil;
  fABSize := 0;
  fOverBuffer := GetMem(DefaultOverflowBufferSize);
  fOBSize := 0;
  fOBPos := 0;

  FRef := TFLACDecoder.Create as IFLACDecoder;
  InitFLACDecoder;
  ReadMetadata;
end;

procedure TFLACAbstractDecoder.Done;
begin
  fComm := nil;
  fRef := nil;
  if assigned(fOverBuffer) then
    FreeMemAndNil(fOverBuffer);
end;

function TFLACAbstractDecoder.GetBitdepth : Cardinal;
begin
  Result := fRef.BitsPerSample;
end;

function TFLACAbstractDecoder.GetBitrate : Cardinal;
begin
  Result := 0;
end;

function TFLACAbstractDecoder.GetChannels : Cardinal;
begin
  Result := fRef.Channels;
end;

function TFLACAbstractDecoder.GetFrequency : Cardinal;
begin
  Result := fRef.SampleRate;
end;

function TFLACAbstractDecoder.GetVersion : Integer;
begin
  Result := 0;
end;

class function TFLACAbstractDecoder.DefaultOverflowBufferSize : Integer;
begin
  Result := 81920;
end;

function TFLACAbstractDecoder.Ref : IFLACDecoder;
begin
  Result := fRef;
end;

constructor TFLACAbstractDecoder.Create;
begin
  Init;
end;

destructor TFLACAbstractDecoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TFLACAbstractDecoder.Comments : IOGGComment;
begin
  Result := fComm;
end;

function TFLACAbstractDecoder.ReadData(Buffer : Pointer;
  Count : ISoundFrameSize; Par : Pointer) : ISoundFrameSize;
var
  Res : Boolean;
begin
  FActiveBuffer := Buffer;
  fABSize := Count.AsBytes;
  fABPos := 0;
  if fOBSize > 0 then
  begin
    if fOBPos < fOBSize then
    begin
      fABPos := fOBSize - fOBPos;
      if fABPos > fABSize then fABPos := fABSize;
      Move(PByte(fOverBuffer)[fOBPos], Buffer^, fABPos);
      Inc(fOBPos, fABPos);
      if fOBPos = fOBSize then
      begin
        fOBSize := 0;
        fOBPos := 0;
      end;
    end else
    begin
      fOBSize := 0;
      fOBPos := 0;
    end;
  end;

  Res := True;
  While fABSize > fABPos do
  begin
    if fRef.ProcessSingle then
    begin
      if fRef.GetState >= fsdsEOS then
      begin
        if fRef.GetState > fsdsEOS then
          Res := false;
        Break;
      end;
    end else
    begin
      Res := false;
      Break;
    end;
  end;
  //
  Result := Count.EmptyDuplicate;
  if Res then
    Result.IncBytes(fABPos);
end;

procedure TFLACAbstractDecoder.ResetToStart;
begin
  fRef.Reset;
end;

function TFLACAbstractDecoder.Ready : Boolean;
begin
  Result := Assigned(fRef);
end;

{ TFLACDecoder }

function TFLACDecoder.SetOggSerialNumber(serial_number : Longint) : Boolean;
begin
  Result := FLAC__stream_decoder_set_ogg_serial_number(fref, serial_number) > 0;
end;

procedure TFLACDecoder.SetMD5Checking(aValue : Boolean);
begin
  FLAC__stream_decoder_set_md5_checking(fref, Integer(aValue));
end;

procedure TFLACDecoder.SetMetaSampleRate(aValue : Cardinal);
begin
  fMetaSampleRate := aValue;
end;

procedure TFLACDecoder.SetMetaChannels(aValue : Cardinal);
begin
  fMetaChannels := aValue;
end;

procedure TFLACDecoder.SetMetaBitsPerSample(aValue : Cardinal);
begin
  fMetaBPS := aValue;
end;

function TFLACDecoder.SetMetadataRespond(atype : FLAC__MetadataType) : Boolean;
begin
  Result := FLAC__stream_decoder_set_metadata_respond(fref, atype) > 0;
end;

function TFLACDecoder.SetMetadataRespondApplication(const id : TFLAC__byteArray4
  ) : Boolean;
begin
  Result := FLAC__stream_decoder_set_metadata_respond_application(fref, id) > 0;
end;

function TFLACDecoder.SetMetadataRespondAll : Boolean;
begin
  Result := FLAC__stream_decoder_set_metadata_respond_all(fref) > 0;
end;

function TFLACDecoder.SetMetadataIgnore(atype : FLAC__MetadataType) : Boolean;
begin
  Result := FLAC__stream_decoder_set_metadata_ignore(fref, atype) > 0;
end;

function TFLACDecoder.SetMetadataIgnoreApplication(const id : TFLAC__byteArray4
  ) : Boolean;
begin
  Result := FLAC__stream_decoder_set_metadata_ignore_application(fref, id) > 0;
end;

function TFLACDecoder.SetMetadataIgnoreAll : Boolean;
begin
  Result := FLAC__stream_decoder_set_metadata_ignore_all(fref) > 0;
end;

function TFLACDecoder.GetState : TFLACStreamDecoderState;
begin
  Result := TFLACStreamDecoderState(FLAC__stream_decoder_get_state(fRef));
end;

function TFLACDecoder.GetResolvedStateString : String;
begin
  Result := StrPas(PChar(FLAC__stream_decoder_get_resolved_state_string(fRef)));
end;

function TFLACDecoder.GetMD5Checking : Boolean;
begin
  Result := FLAC__stream_decoder_get_md5_checking(fRef) > 0;
end;

function TFLACDecoder.GetTotalSamples : QWord;
begin
  Result := FLAC__stream_decoder_get_total_samples(fRef);
end;

function TFLACDecoder.GetChannels : Cardinal;
begin
  Result := FLAC__stream_decoder_get_channels(fRef);
  if Result = 0 then Result := fMetaChannels;
end;

function TFLACDecoder.GetChannelAssignment : TFLACChannelAssignment;
begin
  Result := TFLACChannelAssignment(FLAC__stream_decoder_get_channel_assignment(fRef));
end;

function TFLACDecoder.GetBitsPerSample : Cardinal;
begin
  Result := FLAC__stream_decoder_get_bits_per_sample(fRef);
  if Result = 0 then Result := fMetaBPS;
end;

function TFLACDecoder.GetSampleRate : Cardinal;
begin
  Result := FLAC__stream_decoder_get_sample_rate(fRef);
  if Result = 0 then Result := fMetaSampleRate;
end;

function TFLACDecoder.GetBlocksize : Cardinal;
begin
  Result := FLAC__stream_decoder_get_blocksize(fRef);
end;

function TFLACDecoder.GetDecodePosition : QWord;
begin
  Result := FLAC__stream_decoder_get_decode_position(fRef, @Result);
end;

function TFLACDecoder.GetClientData : pointer;
begin
  Result := FLAC__stream_decoder_get_client_data(fRef);
end;

procedure TFLACDecoder.Init;
begin
  fRef := FLAC__stream_decoder_new();
end;

function TFLACDecoder.InitStream(
  read_callback : FLAC__StreamDecoderReadCallback;
  seek_callback : FLAC__StreamDecoderSeekCallback;
  tell_callback : FLAC__StreamDecoderTellCallback;
  length_callback : FLAC__StreamDecoderLengthCallback;
  eof_callback : FLAC__StreamDecoderEofCallback;
  write_callback : FLAC__StreamDecoderWriteCallback;
  metadata_callback : FLAC__StreamDecoderMetadataCallback;
  error_callback : FLAC__StreamDecoderErrorCallback; client_data : pointer
  ) : TFLACStreamDecoderInitStatus;
begin
  Result := TFLACStreamDecoderInitStatus(
    FLAC__stream_decoder_init_stream(fRef, read_callback, seek_callback,
                                           tell_callback, length_callback,
                                           eof_callback, write_callback,
                                           metadata_callback, error_callback,
                                           client_data));
end;

function TFLACDecoder.InitOGGStream(
  read_callback : FLAC__StreamDecoderReadCallback;
  seek_callback : FLAC__StreamDecoderSeekCallback;
  tell_callback : FLAC__StreamDecoderTellCallback;
  length_callback : FLAC__StreamDecoderLengthCallback;
  eof_callback : FLAC__StreamDecoderEofCallback;
  write_callback : FLAC__StreamDecoderWriteCallback;
  metadata_callback : FLAC__StreamDecoderMetadataCallback;
  error_callback : FLAC__StreamDecoderErrorCallback; client_data : pointer
  ) : TFLACStreamDecoderInitStatus;
begin
  Result := TFLACStreamDecoderInitStatus(
    FLAC__stream_decoder_init_ogg_stream(fRef, read_callback, seek_callback,
                                           tell_callback, length_callback,
                                           eof_callback, write_callback,
                                           metadata_callback, error_callback,
                                           client_data));
end;

function TFLACDecoder.Finish : Boolean;
begin
  Result := FLAC__stream_decoder_finish(fRef) > 0;
end;

procedure TFLACDecoder.Done;
begin
  FLAC__stream_decoder_delete(fRef);
  fRef := nil;
end;

function TFLACDecoder.Ref : pFLAC__StreamDecoder;
begin
  Result := fRef;
end;

constructor TFLACDecoder.Create;
begin
  Init;
end;

destructor TFLACDecoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TFLACDecoder.Flush : Boolean;
begin
  Result := FLAC__stream_decoder_flush(fRef) > 0;
end;

function TFLACDecoder.Reset : Boolean;
begin
  Result := FLAC__stream_decoder_reset(fRef) > 0;
end;

function TFLACDecoder.ProcessSingle : Boolean;
begin
  Result := FLAC__stream_decoder_process_single(fRef) > 0;
end;

function TFLACDecoder.ProcessUntilEndOfMetadata : Boolean;
begin
  Result := FLAC__stream_decoder_process_until_end_of_metadata(fRef) > 0;
end;

function TFLACDecoder.ProcessUntilEndOfStream : Boolean;
begin
  Result := FLAC__stream_decoder_process_until_end_of_stream(fRef) > 0;
end;

function TFLACDecoder.SkipSingleFrame : Boolean;
begin
  Result := FLAC__stream_decoder_skip_single_frame(fRef) > 0;
end;

function TFLACDecoder.SeekAbsolute(sample : QWord) : Boolean;
begin
  Result := FLAC__stream_decoder_seek_absolute(fRef, sample) > 0;
end;

{ TFLACComment }

function TFLACComment.Ref : Pointer;
begin
  Result := fRef;
end;

procedure TFLACComment.Init;
begin
  //
end;

procedure TFLACComment.Done;
begin
  //
end;

procedure TFLACComment.Add(const comment : String);
begin
  //
end;

procedure TFLACComment.AddTag(const tag, value : String);
begin
  //
end;

function TFLACComment.Query(const tag : String; index : integer) : String;
begin
  Result := '';
end;

function TFLACComment.QueryCount(const tag : String) : integer;
begin
  Result := 0;
end;

{ TFLACOggStreamEncoder }

constructor TFLACOggStreamEncoder.Create(aStream : TStream;
  aProps : ISoundEncoderProps; aComments : IOGGComment);
begin
  InitWriter(TOGLSound.NewStreamWriter(aStream));
  inherited Create(aProps, aComments);
end;

procedure TFLACOggStreamEncoder.SetStream(aStream : TStream);
begin
  (Writer as TSoundStreamDataWriter).Stream := aStream;
end;

{ TFLACStreamEncoder }

constructor TFLACStreamEncoder.Create(aStream : TStream;
  aProps : ISoundEncoderProps; aComments : IOGGComment);
begin
  InitWriter(TOGLSound.NewStreamWriter(aStream));
  inherited Create(aProps, aComments);
end;

procedure TFLACStreamEncoder.SetStream(aStream : TStream);
begin
  (Writer as TSoundStreamDataWriter).Stream := aStream;
end;

{ TFLACOggEncoder }

procedure TFLACOggEncoder.InitFLACEncoder;
begin
  fRef.SetOggSerialNumber(Random(Int64(Now)));
  //fRef.InitOGGStream(@flac_enc_read, @flac_enc_write, @flac_enc_seek, @flac_enc_tell, @flac_enc_meta, Self);
  fRef.InitOGGStream(nil, @flac_enc_write, nil, nil, @flac_enc_meta, Self);
end;

{ TFLACAbstractEncoder }

procedure TFLACAbstractEncoder.InitFLACEncoder;
begin
  //fRef.InitStream(@flac_enc_write, @flac_enc_seek, @flac_enc_tell, @flac_enc_meta, Self);
  fRef.InitStream(@flac_enc_write, nil, nil, @flac_enc_meta, Self);
end;

procedure TFLACAbstractEncoder.Init(aProps : ISoundEncoderProps;
  aComments : ISoundComment);
begin
  fRef := TFLACEncoder.Create(aProps.Channels, aProps.Frequency,
                              aProps.SampleSize,
                              aProps.GetDefault(TFLAC.PROP_COMPR_LEVEL, fclLevel5));

  fRef.SetStreamableSubset(aProps.GetDefault(TFLAC.PROP_SUBSET, false));

  if aProps.SampleSize <> ss32bit then
  begin
    fImBuf := GetMem(aProps.Channels *
                     DefaultIntermediateBufferSamplesSize * sizeof(cint32));
  end else
    fImBuf := nil;

  if Assigned(aComments) then
    fComm := aComments as IOGGComment else
    fComm := TFLAC.NewComment;
  InitFLACEncoder;
end;

procedure TFLACAbstractEncoder.Done;
begin
  fRef := nil;
  fComm := nil;
  if assigned(fImBuf) then
    FreeMemAndNil(fImBuf);
end;

function TFLACAbstractEncoder.GetBitdepth : Cardinal;
begin
  Result := fRef.BitsPerSample;
end;

function TFLACAbstractEncoder.GetBitrate : Cardinal;
begin
  Result := 0;
end;

function TFLACAbstractEncoder.GetChannels : Cardinal;
begin
  Result := fRef.Channels;
end;

function TFLACAbstractEncoder.GetFrequency : Cardinal;
begin
  Result := fRef.SampleRate;
end;

function TFLACAbstractEncoder.GetMode : TSoundEncoderMode;
begin
  Result := oemCBR;
end;

function TFLACAbstractEncoder.GetQuality : Single;
begin
  Result := 0
end;

function TFLACAbstractEncoder.GetVersion : Integer;
begin
  Result := 0
end;

class function TFLACAbstractEncoder.DefaultIntermediateBufferSamplesSize : Integer;
begin
  Result := 4096;
end;

function TFLACAbstractEncoder.Ref : IFLACEncoder;
begin
  Result := fRef;
end;

constructor TFLACAbstractEncoder.Create(aProps : ISoundEncoderProps;
  aComments : IOGGComment);
begin
  Init(aProps, aComments);
end;

destructor TFLACAbstractEncoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

function TFLACAbstractEncoder.Comments : IOGGComment;
begin
  Result := fComm;
end;

function TFLACAbstractEncoder.WriteData(Buffer : Pointer;
  Count : ISoundFrameSize; Par : Pointer) : ISoundFrameSize;
var loc : pcint32;
    samples, ch, i, j, sz, bsz : Integer;
    Res : Boolean;
begin
  case GetSampleSize of
    ss8bit, ss16bit : begin
      samples := Count.AsSamples;
      ch := Count.Channels;
      sz := 0;
      while sz < samples do
      begin
        bsz := samples - sz;
        if bsz > DefaultIntermediateBufferSamplesSize then
          bsz := DefaultIntermediateBufferSamplesSize;

        loc := fImBuf;

        case GetSampleSize of
          ss8bit :
              for i := 0 to bsz-1 do
                for j := 0 to ch-1 do
                begin
                  loc^ := pcint8(Buffer)^;
                  Inc(PByte(Buffer));
                  Inc(loc);
                end;
          ss16bit :
              for i := 0 to bsz-1 do
                for j := 0 to ch-1 do
                begin
                  loc^ := pcint16(Buffer)^;
                  Inc(PWord(Buffer));
                  Inc(loc);
                end;
        end;
        if fRef.ProcessInterleaved(fImBuf, bsz) then
        begin
          Res := True;
          Inc(sz, bsz);
        end else
        begin
          Res := False;
          Break;
        end;
      end;
    end;
    ss32bit :
      Res := fRef.ProcessInterleaved(Buffer, samples);
  else
    Res := false;
  end;
  if Res then
    Result := Count.Duplicate else
  begin
    Result := Count.EmptyDuplicate;
    //raise EFLAC.Create(Integer(fRef.GetState));
  end;
end;

procedure TFLACAbstractEncoder.Close(Par : Pointer);
begin
  fRef.Finish;
end;

function TFLACAbstractEncoder.Ready : Boolean;
begin
  Result := Assigned(fRef);
end;

{ TFLACEncoder }

function TFLACEncoder.GetVerify : Boolean;
begin
  Result := FLAC__stream_encoder_get_verify(fRef) > 0;
end;

function TFLACEncoder.GetStreamableSubset : Boolean;
begin
  Result := FLAC__stream_encoder_get_streamable_subset(fRef) > 0;
end;

function TFLACEncoder.GetChannels : Cardinal;
begin
  Result := FLAC__stream_encoder_get_channels(fRef);
end;

function TFLACEncoder.GetBitsPerSample : Cardinal;
begin
  Result := FLAC__stream_encoder_get_bits_per_sample(fRef);
end;

function TFLACEncoder.GetSampleRate : Cardinal;
begin
  Result := FLAC__stream_encoder_get_sample_rate(fRef);
end;

function TFLACEncoder.GetBlocksize : Cardinal;
begin
  Result := FLAC__stream_encoder_get_blocksize(fRef);
end;

function TFLACEncoder.GetDoMidSideStereo : Boolean;
begin
  Result := FLAC__stream_encoder_get_do_mid_side_stereo(fRef) > 0;
end;

function TFLACEncoder.GetLooseMidSideStereo : Boolean;
begin
  Result := FLAC__stream_encoder_get_loose_mid_side_stereo(fRef) > 0;
end;

function TFLACEncoder.GetMaxLPCOrder : Cardinal;
begin
  Result := FLAC__stream_encoder_get_max_lpc_order(fRef);
end;

function TFLACEncoder.GetQLPCoeffPrecision : Cardinal;
begin
  Result := FLAC__stream_encoder_get_qlp_coeff_precision(fRef);
end;

function TFLACEncoder.GetDoQLPCoeffPrecSearch : Boolean;
begin
  Result := FLAC__stream_encoder_get_do_qlp_coeff_prec_search(fRef) > 0;
end;

function TFLACEncoder.GetDoEscapeCoding : Boolean;
begin
  Result := FLAC__stream_encoder_get_do_escape_coding(fRef) > 0;
end;

function TFLACEncoder.GetDoExhaustiveModelSearch : Boolean;
begin
  Result := FLAC__stream_encoder_get_do_exhaustive_model_search(fRef) > 0;
end;

function TFLACEncoder.GetMinResidualPartitionOrder : Cardinal;
begin
  Result := FLAC__stream_encoder_get_min_residual_partition_order(fRef);
end;

function TFLACEncoder.GetMaxResidualPartitionOrder : Cardinal;
begin
  Result := FLAC__stream_encoder_get_max_residual_partition_order(fRef);
end;

function TFLACEncoder.GetRiceParameterSearchDist : Cardinal;
begin
  Result := FLAC__stream_encoder_get_rice_parameter_search_dist(fRef);
end;

function TFLACEncoder.GetTotalSamplesEstimate : QWord;
begin
  Result := FLAC__stream_encoder_get_total_samples_estimate(fRef);
end;

function TFLACEncoder.GetLimitMinBitrate : Boolean;
begin
  Result := FLAC__stream_encoder_get_limit_min_bitrate(fRef) > 0;
end;

procedure TFLACEncoder.SetVerify(aValue : Boolean);
begin
  FLAC__stream_encoder_set_verify(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetStreamableSubset(aValue : Boolean);
begin
  FLAC__stream_encoder_set_streamable_subset(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetChannels(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_channels(fRef, aValue);
end;

procedure TFLACEncoder.SetBitsPerSample(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_bits_per_sample(fRef, aValue);
end;

procedure TFLACEncoder.SetSampleRate(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_sample_rate(fRef, aValue);
end;

procedure TFLACEncoder.SetBlocksize(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_blocksize(fRef, aValue);
end;

procedure TFLACEncoder.SetDoMidSideStereo(aValue : Boolean);
begin
  FLAC__stream_encoder_set_do_mid_side_stereo(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetLooseMidSideStereo(aValue : Boolean);
begin
  FLAC__stream_encoder_set_loose_mid_side_stereo(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetApodization(const specification : String);
begin
  FLAC__stream_encoder_set_apodization(fRef, pcchar(PChar(specification)));
end;

procedure TFLACEncoder.SetMaxLPCOrder(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_max_lpc_order(fRef, aValue);
end;

procedure TFLACEncoder.SetQLPCoeffPrecision(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_qlp_coeff_precision(fRef, aValue);
end;

procedure TFLACEncoder.SetDoQLPCoeffPrecSearch(aValue : Boolean);
begin
  FLAC__stream_encoder_set_do_qlp_coeff_prec_search(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetDoEscapeCoding(aValue : Boolean);
begin
  FLAC__stream_encoder_set_do_escape_coding(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetDoExhaustiveModelSearch(aValue : Boolean);
begin
  FLAC__stream_encoder_set_do_exhaustive_model_search(fRef, Integer(aValue));
end;

procedure TFLACEncoder.SetMinResidualPartitionOrder(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_min_residual_partition_order(fRef, aValue);
end;

procedure TFLACEncoder.SetMaxResidualPartitionOrder(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_max_residual_partition_order(fRef, aValue);
end;

procedure TFLACEncoder.SetRiceParameterSearchDist(aValue : Cardinal);
begin
  FLAC__stream_encoder_set_rice_parameter_search_dist(fRef, aValue);
end;

procedure TFLACEncoder.SetTotalSamplesEstimate(aValue : QWord);
begin
  FLAC__stream_encoder_set_total_samples_estimate(fRef, aValue);
end;

procedure TFLACEncoder.SetLimitMinBitrate(aValue : Boolean);
begin
  FLAC__stream_encoder_set_limit_min_bitrate(fRef, Integer(aValue));
end;

procedure TFLACEncoder.Init;
begin
  fRef := FLAC__stream_encoder_new();
  if GetState <> fsesUnInitialized then
     raise Exception.Create('error');
end;

function TFLACEncoder.InitStream(
  write_callback : FLAC__StreamEncoderWriteCallback;
  seek_callback : FLAC__StreamEncoderSeekCallback;
  tell_callback : FLAC__StreamEncoderTellCallback;
  metadata_callback : FLAC__StreamEncoderMetadataCallback; client_data : pointer
  ) : TFLACEncoderInitStatus;
begin
  Result := TFLACEncoderInitStatus(FLAC__stream_encoder_init_stream(fRef,
                                         write_callback,
                                         seek_callback, tell_callback,
                                         metadata_callback, client_data));
end;

function TFLACEncoder.InitOGGStream(
  read_callback : FLAC__StreamEncoderReadCallback;
  write_callback : FLAC__StreamEncoderWriteCallback;
  seek_callback : FLAC__StreamEncoderSeekCallback;
  tell_callback : FLAC__StreamEncoderTellCallback;
  metadata_callback : FLAC__StreamEncoderMetadataCallback; client_data : pointer
  ) : TFLACEncoderInitStatus;
begin
  Result := TFLACEncoderInitStatus(FLAC__stream_encoder_init_ogg_stream(fRef,
                                         read_callback, write_callback,
                                         seek_callback, tell_callback,
                                         metadata_callback, client_data));
end;

function TFLACEncoder.Finish : Boolean;
begin
  Result := FLAC__stream_encoder_finish(fRef) > 0;
end;

procedure TFLACEncoder.Done;
begin
  if Assigned(fRef) then
    FLAC__stream_encoder_delete(fRef);
end;

function TFLACEncoder.Ref : pFLAC__StreamEncoder;
begin
  Result := fRef;
end;

constructor TFLACEncoder.Create(aChannels : Cardinal; aFreq : Cardinal;
  aSampleSize : TSoundSampleSize; aComprLevel : TFLACCompressionLevel);
begin
  Init;
  SetChannels(aChannels);
  SetSampleRate(aFreq);
  SetBitsPerSample(TOGLSound.SampleSizeToBitdepth(aSampleSize));
  SetCompressionLevel(aComprLevel);
end;

destructor TFLACEncoder.Destroy;
begin
  Done;
  inherited Destroy;
end;

procedure TFLACEncoder.SetOggSerialNumber(serial_number : Longint);
begin
  FLAC__stream_encoder_set_ogg_serial_number(fRef, serial_number);
end;

procedure TFLACEncoder.SetCompressionLevel(aValue : TFLACCompressionLevel);
begin
  FLAC__stream_encoder_set_compression_level(fRef, Integer(aValue));
end;

function TFLACEncoder.GetState : TFLACEncoderState;
begin
  Result := TFLACEncoderState(FLAC__stream_encoder_get_state(fRef));
end;

function TFLACEncoder.GetVerifyDecoderState : TFLACStreamDecoderState;
begin
  Result := TFLACStreamDecoderState(FLAC__stream_encoder_get_verify_decoder_state(fRef));
end;

function TFLACEncoder.GetResolvedStateString : String;
begin
  Result := StrPas(PChar(FLAC__stream_encoder_get_resolved_state_string(fRef)));
end;

procedure TFLACEncoder.GetVerifyDecoderErrorStats(absolute_sample : PQWord;
  frame_number : PCardinal; channel : PCardinal; sample : PCardinal;
  expected : PInteger; got : PInteger);
begin
  FLAC__stream_encoder_get_verify_decoder_error_stats(fRef, absolute_sample,
                                                      frame_number, channel,
                                                      sample, expected, got);
end;

function TFLACEncoder.Process(const buffer : pointer; samples : Cardinal
  ) : Boolean;
begin
  Result := FLAC__stream_encoder_process(fRef, buffer, samples) > 0;
end;

function TFLACEncoder.ProcessInterleaved(const buffer : pointer;
  samples : Cardinal) : Boolean;
begin
  Result := FLAC__stream_encoder_process_interleaved(fRef, buffer, samples) > 0;
end;

{ EFLAC }

constructor EFLAC.Create(aError : Integer);
begin
  inherited CreateFmt(cFLACError, [aError]);
end;

{ TFLACFile }

function TFLACFile.InitEncoder(aProps : ISoundEncoderProps;
                               aComments : ISoundComment) : ISoundEncoder;
begin
  Result := TFLACStreamEncoder.Create(Stream, aProps,
                                         aComments as IOGGComment) as ISoundEncoder;
end;

function TFLACFile.InitDecoder : ISoundDecoder;
begin
  Result := TFLACStreamDecoder.Create(Stream) as ISoundDecoder;
end;

{ TFLACOggFile }

function TFLACOggFile.InitEncoder(aProps : ISoundEncoderProps;
  aComments : ISoundComment) : ISoundEncoder;
begin
  Result := TFLACOggStreamEncoder.Create(Stream, aProps,
                                         aComments as IOGGComment) as ISoundEncoder;
end;

function TFLACOggFile.InitDecoder : ISoundDecoder;
begin
  Result := TFLACOggStreamDecoder.Create(Stream) as ISoundDecoder;
end;

{ TFLAC }

class function TFLAC.NewComment : IFLACComment;
begin
  Result := TFLACComment.Create as IFLACComment;
end;

class function TFLAC.FLACOggStreamEncoder(aStream : TStream;
  aProps : ISoundEncoderProps; aComments : IOGGComment) : TFLACOggStreamEncoder;
begin
  Result := TFLACOggStreamEncoder.Create(aStream, aProps, aComments);
end;

class function TFLAC.FLACOggStreamDecoder(aStream : TStream) : TFLACOggStreamDecoder;
begin
  Result := TFLACOggStreamDecoder.Create(aStream);
end;

class function TFLAC.FLACStreamEncoder(aStream : TStream;
  aProps : ISoundEncoderProps; aComments: IOGGComment) : TFLACStreamEncoder;
begin
  Result := TFLACStreamEncoder.Create(aStream, aProps, aComments);
end;

class function TFLAC.FLACStreamDecoder(aStream : TStream
  ) : TFLACStreamDecoder;
begin
  Result := TFLACStreamDecoder.Create(aStream);
end;

class function TFLAC.PROP_COMPR_LEVEL : Cardinal;
begin
  Result := $031;
end;

class function TFLAC.PROP_SUBSET : Cardinal;
begin
  Result := $032;
end;

class function TFLAC.FLACLibsLoad(const aFLACLibs : array of String
  ) : Boolean;
begin
  Result := InitFLACInterface(aFLACLibs);
end;

class function TFLAC.FLACLibsLoadDefault : Boolean;
begin
  Result := InitFLACInterface(FLACDLL);
end;

class function TFLAC.IsFLACLibsLoaded : Boolean;
begin
  Result := IsFLACloaded;
end;

class function TFLAC.FLACLibsUnLoad : Boolean;
begin
  Result := DestroyFLACInterface;
end;

end.
