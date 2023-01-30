(******************************************************************************)
(*                             libFLAC_dynlite                                *)
(*                   free pascal wrapper around FLAC library                  *)
(*                          https://xiph.org/flac/                            *)
(*                                                                            *)
(* Copyright (c) 2023 Ilya Medvedkov                                          *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the  GNU Lesser General Public License  as published by *)
(* the Free Software Foundation; either version 3 of the License (LGPL v3).   *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.                                          *)
(* See the GNU Lesser General Public License for more details.                *)
(*                                                                            *)
(* A copy of the GNU Lesser General Public License is available on the World  *)
(* Wide Web at <https://www.gnu.org/licenses/lgpl-3.0.html>.                  *)
(*                                                                            *)
(******************************************************************************)

unit libFLAC_dynlite;


{$mode objfpc}{$H+}

{$packrecords c}

interface

uses dynlibs, SysUtils, libOGG_dynlite, ctypes;

const
{$if defined(UNIX) and not defined(darwin)}
  FLACDLL: Array [0..0] of string = ('libFLAC.so');
{$ELSE}
{$ifdef WINDOWS}
  FLACDLL: Array [0..0] of string = ('flac.dll');
{$endif}
{$endif}

type
  pFLAC__StreamDecoder = pointer;
  pFLAC__StreamEncoder = pointer;

  FLAC__bool = cint;
  FLAC__MetadataType = cint;

  FLAC__ChannelAssignment = cint;
  FLAC__FrameNumberType = cint;
  FLAC__EntropyCodingMethodType = cint;
  FLAC__VerbatimSubframeDataType = cint;
  FLAC__SubframeType = cint;
  
  FLAC__StreamDecoderReadStatus = cint;
  FLAC__StreamDecoderSeekStatus = cint;
  FLAC__StreamDecoderTellStatus = cint;
  FLAC__StreamDecoderLengthStatus = cint;
  FLAC__StreamDecoderWriteStatus = cint;
  FLAC__StreamDecoderErrorStatus = cint;
  FLAC__StreamDecoderInitStatus = cint;
  FLAC__StreamDecoderState = cint;

  FLAC__StreamEncoderState = cint;
  FLAC__StreamEncoderInitStatus = cint;
  FLAC__StreamEncoderReadStatus = cint;
  FLAC__StreamEncoderWriteStatus = cint;
  FLAC__StreamEncoderSeekStatus = cint;
  FLAC__StreamEncoderTellStatus = cint;

  FLAC__int8 = cint8;
  FLAC__uint8 = cuint8;
  FLAC__byte = FLAC__uint8;
  FLAC__int16 = cint16;
  FLAC__uint16 = cuint16;
  FLAC__int32 = cint32;
  FLAC__uint32 = cuint32;
  FLAC__int64 = cint64;
  FLAC__uint64 = cuint64;
    
  pFLAC__int32 = ^FLAC__int32;
  pFLAC__uint32 = ^FLAC__uint32;
  pFLAC__int64 = ^FLAC__int64;
  pFLAC__uint64 = ^FLAC__uint64;
  pFLAC__byte = ^FLAC__byte;

const
  FLAC__MAX_CHANNELS = 8;
  FLAC__MIN_BITS_PER_SAMPLE = 4;
  FLAC__MAX_BITS_PER_SAMPLE = 32;
  FLAC__REFERENCE_CODEC_MAX_BITS_PER_SAMPLE = 32;
  FLAC__MAX_METADATA_TYPE_CODE = 126;
  FLAC__MIN_BLOCK_SIZE = 16;
  FLAC__MAX_BLOCK_SIZE = 65535;
  FLAC__SUBSET_MAX_BLOCK_SIZE_48000HZ = 4608;
  FLAC__MAX_SAMPLE_RATE = 1048575;
  FLAC__MAX_LPC_ORDER = 32;
  FLAC__SUBSET_MAX_LPC_ORDER_48000HZ = 12;
  FLAC__MIN_QLP_COEFF_PRECISION = 5;
  FLAC__MAX_QLP_COEFF_PRECISION = 15;
  FLAC__MAX_FIXED_ORDER = 4;
  FLAC__MAX_RICE_PARTITION_ORDER = 15;
  FLAC__SUBSET_MAX_RICE_PARTITION_ORDER = 8;

type

  TFLAC__Number__ = record
    Case FLAC__uint32 of
     0 : (frame_number : FLAC__uint32);
     1 : (sample_number : FLAC__uint64);
  end;

  FLAC__FrameHeader = record
    blocksize,
    sample_rate,
    channels : cuint32;
    channel_assignment : FLAC__ChannelAssignment;
    bits_per_sample : cuint32;

    number_type : FLAC__FrameNumberType;

    number : TFLAC__Number__;

    crc : FLAC__uint8;
  end;

  FLAC__Subframe_Constant = record
    value : FLAC__int64;
  end;

  pFLAC__EntropyCodingMethod_PartitionedRiceContents = ^FLAC__EntropyCodingMethod_PartitionedRiceContents;
  FLAC__EntropyCodingMethod_PartitionedRiceContents = record
     parameters,
     raw_bits : pcuint32;
     capacity_by_order : cuint32;
  end;

  FLAC__EntropyCodingMethod_PartitionedRice = record
    order : cuint32;
    contents : pFLAC__EntropyCodingMethod_PartitionedRiceContents;
  end;

  TFLAC__EntropyCodingMethod__ = record
     partitioned_rice : FLAC__EntropyCodingMethod_PartitionedRice;
  end;

  FLAC__EntropyCodingMethod = record
    atype : FLAC__EntropyCodingMethodType;
    data  : TFLAC__EntropyCodingMethod__;
  end;

  FLAC__Subframe_Fixed = record
    entropy_coding_method : FLAC__EntropyCodingMethod;
    order : cuint32;
    warmup : Array [0..FLAC__MAX_FIXED_ORDER-1] of FLAC__int64;
    residual : pFLAC__int32;
  end;

  FLAC__Subframe_LPC = record
    entropy_coding_method : FLAC__EntropyCodingMethod;
    order,
    qlp_coeff_precision : cuint32;
    quantization_level : cint;
    qlp_coeff : Array [0..FLAC__MAX_LPC_ORDER-1] of FLAC__int32;
    warmup : Array [0..FLAC__MAX_LPC_ORDER-1] of FLAC__int64;
    residual : pFLAC__int32;
  end;

  TFLAC_SubframeVerbatimData__ = record
    case csize_t of
      0 : (_int32 : pFLAC__int32);
      1 : (_int64 : pFLAC__int64);
  end;

  FLAC__Subframe_Verbatim = record
    data : TFLAC_SubframeVerbatimData__;
    data_type : FLAC__VerbatimSubframeDataType;
  end;

  TFLAC__SubFrameData__ = record
    case FLAC__uint32 of
      0 : (constant : FLAC__Subframe_Constant);
      1 : (fixed : FLAC__Subframe_Fixed);
      2 : (lpc : FLAC__Subframe_LPC);
      3 : (verbatim : FLAC__Subframe_Verbatim);
  end;

  FLAC__Subframe = record
    atype : FLAC__SubframeType;
    data  : TFLAC__SubFrameData__;
    wasted_bits : cuint32;
  end;

  FLAC__FrameFooter = record
    cc : FLAC__uint16;
  end;

  pFLAC__Frame = ^FLAC__Frame;
  FLAC__Frame = record
    header : FLAC__FrameHeader;
    subframes : Array [0..FLAC__MAX_CHANNELS] of FLAC__Subframe;
    footer : FLAC__FrameFooter;
  end;

  TFLAC__byteArray4 = Array [0..3] of FLAC__byte;

  FLAC__StreamMetadata_StreamInfo = record
    min_blocksize, max_blocksize : cuint32;
    min_framesize, max_framesize : cuint32;
    sample_rate : cuint32;
    channels : cuint32;
    bits_per_sample : cuint32;
    total_samples : FLAC__uint64;
    md5sum : Array [0..15] of FLAC__byte;
  end;

  FLAC__StreamMetadata_Padding = record
    dummy : cint;                               
  end;

  FLAC__StreamMetadata_Application = record
    id : TFLAC__byteArray4;
    data : pFLAC__byte;
  end;

  pFLAC__StreamMetadata_SeekPoint = ^FLAC__StreamMetadata_SeekPoint;
  FLAC__StreamMetadata_SeekPoint = record
    sample_number : FLAC__uint64;
    stream_offset : FLAC__uint64;
    frame_samples : cuint32;
  end;
  
  FLAC__StreamMetadata_SeekTable = record
    num_points : cuint32;
    points : pFLAC__StreamMetadata_SeekPoint;    
  end;  

  pFLAC__StreamMetadata_VorbisComment_Entry = ^FLAC__StreamMetadata_VorbisComment_Entry;
  FLAC__StreamMetadata_VorbisComment_Entry = record
    length : FLAC__uint32;
    entry  : pFLAC__byte;
  end;    

  pFLAC__StreamMetadata_VorbisComment = ^FLAC__StreamMetadata_VorbisComment;
  FLAC__StreamMetadata_VorbisComment = record
    vendor_string : FLAC__StreamMetadata_VorbisComment_Entry;
    num_comments : FLAC__uint32;  
    comments : pFLAC__StreamMetadata_VorbisComment_Entry;
  end;      

  pFLAC__StreamMetadata_CueSheet_Index = ^FLAC__StreamMetadata_CueSheet_Index;
  FLAC__StreamMetadata_CueSheet_Index = record    
    offset : FLAC__uint64;  
    number : FLAC__byte;
  end;        

  FLAC__StreamMetadata_CueSheet_Track = bitpacked record
    offset : FLAC__uint64;
    number : FLAC__byte;
    isrc : Array [0..12] of cchar;
    atype : 0..1; //bitpacked
    pre_emphasis : 0..1; //bitpacked
    num_indices : FLAC__byte;
    indices : pFLAC__StreamMetadata_CueSheet_Index;
  end;

  TFLAC__MetaData__ = record
    Case FLAC__uint32 of
     0:	(stream_info : FLAC__StreamMetadata_StreamInfo);
     1:	(application : FLAC__StreamMetadata_Application);
     2:	(seek_table : FLAC__StreamMetadata_SeekTable);
     3:	(vorbis_comment : FLAC__StreamMetadata_VorbisComment);
 {    4:	(cue_sheet : FLAC__StreamMetadata_CueSheet);
 	FLAC__StreamMetadata_Padding padding;
 	FLAC__StreamMetadata_Application application;
 	FLAC__StreamMetadata_SeekTable seek_table;
 	FLAC__StreamMetadata_VorbisComment vorbis_comment;
 	FLAC__StreamMetadata_CueSheet cue_sheet;
 	FLAC__StreamMetadata_Picture picture;
 	FLAC__StreamMetadata_Unknown unknown;}
  end;

  ppFLAC__StreamMetadata = ^pFLAC__StreamMetadata;
  pFLAC__StreamMetadata = ^FLAC__StreamMetadata;
  FLAC__StreamMetadata = record
     atype : FLAC__MetadataType;
     is_last : FLAC__bool;

     length : cuint32;

     data : TFLAC__MetaData__;
  end;
  
  FLAC__StreamDecoderReadCallback =  function (
    const decoder : pFLAC__StreamDecoder;
    buffer : pFLAC__byte; bytes : pcsize_t;
    client_data : pointer) : FLAC__StreamDecoderReadStatus; cdecl;

  FLAC__StreamDecoderSeekCallback = function (
    const decoder : pFLAC__StreamDecoder;
    absolute_byte_offset : FLAC__uint64;
    client_data : pointer) : FLAC__StreamDecoderSeekStatus; cdecl;

  FLAC__StreamDecoderTellCallback = function (
    const decoder : pFLAC__StreamDecoder;
    absolute_byte_offset : pFLAC__uint64;
    client_data : pointer) : FLAC__StreamDecoderTellStatus; cdecl;

  FLAC__StreamDecoderLengthCallback = function (
    const decoder : pFLAC__StreamDecoder;
    stream_length : pFLAC__uint64;
    client_data : pointer) : FLAC__StreamDecoderLengthStatus; cdecl;

  FLAC__StreamDecoderEofCallback = function (
    const decoder : pFLAC__StreamDecoder;
    client_data : pointer) : FLAC__bool; cdecl;

  FLAC__StreamDecoderWriteCallback = function (
    const decoder : pFLAC__StreamDecoder;
    const frame : pFLAC__Frame; const buffer : Pointer;
    client_data : pointer) : FLAC__StreamDecoderWriteStatus; cdecl;

  FLAC__StreamDecoderMetadataCallback = procedure (
    const decoder : pFLAC__StreamDecoder;
    const metadata : pFLAC__StreamMetadata;
    client_data : pointer); cdecl;

  FLAC__StreamDecoderErrorCallback = procedure (
    const decoder : pFLAC__StreamDecoder;
    status : FLAC__StreamDecoderErrorStatus; client_data : pointer); cdecl;

  FLAC__StreamEncoderReadCallback = function (
    const encoder : pFLAC__StreamEncoder;
    buffer : pFLAC__byte;
    bytes : pcsize_t;
    client_data : Pointer) : FLAC__StreamEncoderReadStatus; cdecl;

  FLAC__StreamEncoderWriteCallback = function (
    const encoder : pFLAC__StreamEncoder;
    buffer : pFLAC__byte; bytes : csize_t;
    samples, current_frame : cuint32;
    client_data : Pointer) : FLAC__StreamEncoderWriteStatus; cdecl;

  FLAC__StreamEncoderSeekCallback = function (
    const encoder : pFLAC__StreamEncoder;
    absolute_byte_offset : FLAC__uint64;
    client_data : Pointer) : FLAC__StreamEncoderSeekStatus; cdecl;

  FLAC__StreamEncoderTellCallback = function (
    const encoder : pFLAC__StreamEncoder;
    absolute_byte_offset : pFLAC__uint64;
    client_data : Pointer) : FLAC__StreamEncoderTellStatus; cdecl;

  FLAC__StreamEncoderMetadataCallback = procedure (
    const encoder : pFLAC__StreamEncoder;
    const metadata : pFLAC__StreamMetadata; client_data : Pointer); cdecl;

  FLAC__StreamEncoderProgressCallback = procedure (
    const encoder : pFLAC__StreamEncoder;
    bytes_written, samples_written : FLAC__uint64;
    frames_written, total_frames_estimate : cuint32;
    client_data : Pointer); cdecl;
  
  
const 
  FLAC__true = 1;
  FLAC__false = 0;

  // FLAC__ChannelAssignment
  FLAC__CHANNEL_ASSIGNMENT_INDEPENDENT = 0;
  FLAC__CHANNEL_ASSIGNMENT_LEFT_SIDE = 1;
  FLAC__CHANNEL_ASSIGNMENT_RIGHT_SIDE = 2;
  FLAC__CHANNEL_ASSIGNMENT_MID_SIDE = 3;

  // FLAC__FrameNumberType
  FLAC__FRAME_NUMBER_TYPE_FRAME_NUMBER = 0;
  FLAC__FRAME_NUMBER_TYPE_SAMPLE_NUMBER = 1;

  // FLAC__EntropyCodingMethodType
  FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE = 0;
  FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE2 = 1;

  // FLAC__VerbatimSubframeDataType
  FLAC__VERBATIM_SUBFRAME_DATA_TYPE_INT32 = 0;
  FLAC__VERBATIM_SUBFRAME_DATA_TYPE_INT64 = 1;

  // FLAC__SubframeType
  FLAC__SUBFRAME_TYPE_CONSTANT = 0;
  FLAC__SUBFRAME_TYPE_VERBATIM = 1;
  FLAC__SUBFRAME_TYPE_FIXED = 2;
  FLAC__SUBFRAME_TYPE_LPC = 3;

  // FLAC__MetadataType
  FLAC__METADATA_TYPE_STREAMINFO = 0;
  FLAC__METADATA_TYPE_PADDING = 1;	
  FLAC__METADATA_TYPE_APPLICATION = 2;	
  FLAC__METADATA_TYPE_SEEKTABLE = 3;	
  FLAC__METADATA_TYPE_VORBIS_COMMENT = 4;
  FLAC__METADATA_TYPE_CUESHEET = 5;	
  FLAC__METADATA_TYPE_PICTURE = 6;
  FLAC__METADATA_TYPE_UNDEFINED = 7;
  FLAC__MAX_METADATA_TYPE = FLAC__MAX_METADATA_TYPE_CODE;

  //FLAC__StreamDecoderState
  FLAC__STREAM_DECODER_SEARCH_FOR_METADATA = 0;
  FLAC__STREAM_DECODER_READ_METADATA = 1;
  FLAC__STREAM_DECODER_SEARCH_FOR_FRAME_SYNC = 3;
  FLAC__STREAM_DECODER_READ_FRAME = 4;
  FLAC__STREAM_DECODER_END_OF_STREAM = 5;
  FLAC__STREAM_DECODER_OGG_ERROR = 6;
  FLAC__STREAM_DECODER_SEEK_ERROR = 7;
  FLAC__STREAM_DECODER_ABORTED = 8;
  FLAC__STREAM_DECODER_MEMORY_ALLOCATION_ERROR = 9;
  FLAC__STREAM_DECODER_UNINITIALIZED = 10;

  //FLAC__StreamDecoderInitStatus
  FLAC__STREAM_DECODER_INIT_STATUS_OK = 0;
  FLAC__STREAM_DECODER_INIT_STATUS_UNSUPPORTED_CONTAINER = 1;
  FLAC__STREAM_DECODER_INIT_STATUS_INVALID_CALLBACKS = 2;
  FLAC__STREAM_DECODER_INIT_STATUS_MEMORY_ALLOCATION_ERROR = 3;
  FLAC__STREAM_DECODER_INIT_STATUS_ERROR_OPENING_FILE = 4;
  FLAC__STREAM_DECODER_INIT_STATUS_ALREADY_INITIALIZED = 5;

  //FLAC__StreamDecoderReadStatus
  FLAC__STREAM_DECODER_READ_STATUS_CONTINUE = 0;
  FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM = 1;
  FLAC__STREAM_DECODER_READ_STATUS_ABORT = 2;

  //FLAC__StreamDecoderSeekStatus
  FLAC__STREAM_DECODER_SEEK_STATUS_OK = 0;
  FLAC__STREAM_DECODER_SEEK_STATUS_ERROR = 1;
  FLAC__STREAM_DECODER_SEEK_STATUS_UNSUPPORTED = 2;

  //FLAC__StreamDecoderTellStatus
  FLAC__STREAM_DECODER_TELL_STATUS_OK = 0;
  FLAC__STREAM_DECODER_TELL_STATUS_ERROR = 1;
  FLAC__STREAM_DECODER_TELL_STATUS_UNSUPPORTED = 2;

  //FLAC__StreamDecoderLengthStatus
  FLAC__STREAM_DECODER_LENGTH_STATUS_OK = 0;
  FLAC__STREAM_DECODER_LENGTH_STATUS_ERROR = 1;
  FLAC__STREAM_DECODER_LENGTH_STATUS_UNSUPPORTED = 2;

  //FLAC__StreamDecoderWriteStatus
  FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE = 0;
  FLAC__STREAM_DECODER_WRITE_STATUS_ABORT = 1;

  //FLAC__StreamDecoderErrorStatus
  FLAC__STREAM_DECODER_ERROR_STATUS_LOST_SYNC = 0;
  FLAC__STREAM_DECODER_ERROR_STATUS_BAD_HEADER = 1;
  FLAC__STREAM_DECODER_ERROR_STATUS_FRAME_CRC_MISMATCH = 2;
  FLAC__STREAM_DECODER_ERROR_STATUS_UNPARSEABLE_STREAM = 3;
  FLAC__STREAM_DECODER_ERROR_STATUS_BAD_METADATA = 4;

  //FLAC__StreamEncoderState
  FLAC__STREAM_ENCODER_OK = 0;
  FLAC__STREAM_ENCODER_UNINITIALIZED = 1;
  FLAC__STREAM_ENCODER_OGG_ERROR = 2;
  FLAC__STREAM_ENCODER_VERIFY_DECODER_ERROR = 3;
  FLAC__STREAM_ENCODER_VERIFY_MISMATCH_IN_AUDIO_DATA = 4;
  FLAC__STREAM_ENCODER_CLIENT_ERROR = 5;
  FLAC__STREAM_ENCODER_IO_ERROR = 6;
  FLAC__STREAM_ENCODER_FRAMING_ERROR = 7;
  FLAC__STREAM_ENCODER_MEMORY_ALLOCATION_ERROR = 8;

  //FLAC__StreamEncoderInitStatus
  FLAC__STREAM_ENCODER_INIT_STATUS_OK = 0;
  FLAC__STREAM_ENCODER_INIT_STATUS_ENCODER_ERROR = 1;
  FLAC__STREAM_ENCODER_INIT_STATUS_UNSUPPORTED_CONTAINER = 2;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_CALLBACKS = 3;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_NUMBER_OF_CHANNELS = 4;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_BITS_PER_SAMPLE = 5;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_SAMPLE_RATE = 6;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_BLOCK_SIZE = 7;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_MAX_LPC_ORDER = 8;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_QLP_COEFF_PRECISION = 9;
  FLAC__STREAM_ENCODER_INIT_STATUS_BLOCK_SIZE_TOO_SMALL_FOR_LPC_ORDER = 10;
  FLAC__STREAM_ENCODER_INIT_STATUS_NOT_STREAMABLE = 11;
  FLAC__STREAM_ENCODER_INIT_STATUS_INVALID_METADATA = 12;
  FLAC__STREAM_ENCODER_INIT_STATUS_ALREADY_INITIALIZED = 13;

  //FLAC__StreamEncoderReadStatus
  FLAC__STREAM_ENCODER_READ_STATUS_CONTINUE = 0;
  FLAC__STREAM_ENCODER_READ_STATUS_END_OF_STREAM = 1;
  FLAC__STREAM_ENCODER_READ_STATUS_ABORT = 2;
  FLAC__STREAM_ENCODER_READ_STATUS_UNSUPPORTED = 3;

  //FLAC__StreamEncoderWriteStatus
  FLAC__STREAM_ENCODER_WRITE_STATUS_OK = 0;
  FLAC__STREAM_ENCODER_WRITE_STATUS_FATAL_ERROR = 1;

  //FLAC__StreamEncoderSeekStatus
  FLAC__STREAM_ENCODER_SEEK_STATUS_OK = 0;
  FLAC__STREAM_ENCODER_SEEK_STATUS_ERROR = 1;
  FLAC__STREAM_ENCODER_SEEK_STATUS_UNSUPPORTED = 2;

  //FLAC__StreamEncoderTellStatus
  FLAC__STREAM_ENCODER_TELL_STATUS_OK = 0;
  FLAC__STREAM_ENCODER_TELL_STATUS_ERROR = 1;
  FLAC__STREAM_ENCODER_TELL_STATUS_UNSUPPORTED = 2;

{ metadata.h }

function FLAC__metadata_object_new(atype : FLAC__MetadataType) : pFLAC__StreamMetadata;
function FLAC__metadata_object_clone(const aobject : pFLAC__StreamMetadata) : pFLAC__StreamMetadata;
procedure FLAC__metadata_object_delete(aobject : pFLAC__StreamMetadata);

function FLAC__metadata_object_vorbiscomment_set_vendor_string(aobject : pFLAC__StreamMetadata; entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool) : FLAC__bool;
function FLAC__metadata_object_vorbiscomment_resize_comments(aobject : pFLAC__StreamMetadata; new_num_comments : cuint32) : FLAC__bool;
function FLAC__metadata_object_vorbiscomment_set_comment(aobject : pFLAC__StreamMetadata; comment_num : cuint32; entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool) : FLAC__bool;
function FLAC__metadata_object_vorbiscomment_append_comment(aobject : pFLAC__StreamMetadata; entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool) : FLAC__bool;

{ stream_encoder.h }  

function FLAC__stream_decoder_new(): pFLAC__StreamDecoder;
procedure FLAC__stream_decoder_delete(decoder: pFLAC__StreamDecoder);
function FLAC__stream_decoder_set_ogg_serial_number(decoder: pFLAC__StreamDecoder; serial_number: clong): FLAC__bool;
function FLAC__stream_decoder_set_md5_checking(decoder: pFLAC__StreamDecoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_decoder_set_metadata_respond(decoder: pFLAC__StreamDecoder; atype: FLAC__MetadataType): FLAC__bool;
function FLAC__stream_decoder_set_metadata_respond_application(decoder: pFLAC__StreamDecoder; const id: TFLAC__byteArray4): FLAC__bool;
function FLAC__stream_decoder_set_metadata_respond_all(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_set_metadata_ignore(decoder: pFLAC__StreamDecoder; atype: FLAC__MetadataType): FLAC__bool;
function FLAC__stream_decoder_set_metadata_ignore_application(decoder: pFLAC__StreamDecoder; const id: TFLAC__byteArray4): FLAC__bool;
function FLAC__stream_decoder_set_metadata_ignore_all(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_get_state(const decoder: pFLAC__StreamDecoder): FLAC__StreamDecoderState;
function FLAC__stream_decoder_get_resolved_state_string(const decoder: pFLAC__StreamDecoder): pcchar;
function FLAC__stream_decoder_get_md5_checking(const decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_get_total_samples(const decoder: pFLAC__StreamDecoder): FLAC__uint64;
function FLAC__stream_decoder_get_channels(const decoder: pFLAC__StreamDecoder): cuint32;
function FLAC__stream_decoder_get_channel_assignment(const decoder: pFLAC__StreamDecoder): FLAC__ChannelAssignment;
function FLAC__stream_decoder_get_bits_per_sample(const decoder: pFLAC__StreamDecoder): cuint32;
function FLAC__stream_decoder_get_sample_rate(const decoder: pFLAC__StreamDecoder): cuint32;
function FLAC__stream_decoder_get_blocksize(const decoder: pFLAC__StreamDecoder): cuint32;
function FLAC__stream_decoder_get_decode_position(const decoder: pFLAC__StreamDecoder; position: pFLAC__uint64): FLAC__bool;
function FLAC__stream_decoder_get_client_data(decoder: pFLAC__StreamDecoder): pointer;
function FLAC__stream_decoder_init_stream(decoder: pFLAC__StreamDecoder; read_callback: FLAC__StreamDecoderReadCallback; seek_callback: FLAC__StreamDecoderSeekCallback; tell_callback: FLAC__StreamDecoderTellCallback; length_callback: FLAC__StreamDecoderLengthCallback; eof_callback: FLAC__StreamDecoderEofCallback; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus;
function FLAC__stream_decoder_init_ogg_stream(decoder: pFLAC__StreamDecoder;
  read_callback: FLAC__StreamDecoderReadCallback;
  seek_callback: FLAC__StreamDecoderSeekCallback;
  tell_callback: FLAC__StreamDecoderTellCallback;
  length_callback: FLAC__StreamDecoderLengthCallback;
  eof_callback: FLAC__StreamDecoderEofCallback;
  write_callback: FLAC__StreamDecoderWriteCallback;
  metadata_callback: FLAC__StreamDecoderMetadataCallback;
  error_callback: FLAC__StreamDecoderErrorCallback;
  client_data: pointer): FLAC__StreamDecoderInitStatus;
function FLAC__stream_decoder_init_file(decoder: pFLAC__StreamDecoder;
  const filename: pcchar; write_callback:
  FLAC__StreamDecoderWriteCallback;
  metadata_callback: FLAC__StreamDecoderMetadataCallback;
  error_callback: FLAC__StreamDecoderErrorCallback;
  client_data: pointer): FLAC__StreamDecoderInitStatus;
function FLAC__stream_decoder_init_ogg_file(decoder: pFLAC__StreamDecoder;
  const filename: pcchar;
  write_callback: FLAC__StreamDecoderWriteCallback;
  metadata_callback: FLAC__StreamDecoderMetadataCallback;
  error_callback: FLAC__StreamDecoderErrorCallback;
  client_data: pointer): FLAC__StreamDecoderInitStatus;
function FLAC__stream_decoder_finish(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_flush(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_reset(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_process_single(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_process_until_end_of_metadata(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_process_until_end_of_stream(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_skip_single_frame(decoder: pFLAC__StreamDecoder): FLAC__bool;
function FLAC__stream_decoder_seek_absolute(decoder: pFLAC__StreamDecoder; sample: FLAC__uint64): FLAC__bool;

{ stream_encoder.h }
function FLAC__stream_encoder_new(): pFLAC__StreamEncoder;
procedure FLAC__stream_encoder_delete(encoder: pFLAC__StreamEncoder);
function FLAC__stream_encoder_set_ogg_serial_number(encoder: pFLAC__StreamEncoder; serial_number: clong): FLAC__bool;
function FLAC__stream_encoder_set_verify(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_streamable_subset(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_channels(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_bits_per_sample(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_sample_rate(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_compression_level(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_blocksize(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_do_mid_side_stereo(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_loose_mid_side_stereo(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_apodization(encoder: pFLAC__StreamEncoder; const specification: pcchar): FLAC__bool;
function FLAC__stream_encoder_set_max_lpc_order(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_qlp_coeff_precision(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_do_qlp_coeff_prec_search(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_do_escape_coding(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_do_exhaustive_model_search(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_set_min_residual_partition_order(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_max_residual_partition_order(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_rice_parameter_search_dist(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_total_samples_estimate(encoder: pFLAC__StreamEncoder; value: FLAC__uint64): FLAC__bool;
function FLAC__stream_encoder_set_metadata(encoder: pFLAC__StreamEncoder; metadata: ppFLAC__StreamMetadata; num_blocks: cuint32): FLAC__bool;
function FLAC__stream_encoder_set_limit_min_bitrate(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
function FLAC__stream_encoder_get_state(const encoder: pFLAC__StreamEncoder): FLAC__StreamEncoderState;
function FLAC__stream_encoder_get_verify_decoder_state(const encoder: pFLAC__StreamEncoder): FLAC__StreamDecoderState;
function FLAC__stream_encoder_get_resolved_state_string(const encoder: pFLAC__StreamEncoder): pcchar;
procedure FLAC__stream_encoder_get_verify_decoder_error_stats(const encoder: pFLAC__StreamEncoder; absolute_sample: pFLAC__uint64; frame_number: pcuint32; channel: pcuint32; sample: pcuint32; expected: pFLAC__int32; got: pFLAC__int32);
function FLAC__stream_encoder_get_verify(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_streamable_subset(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_channels(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_bits_per_sample(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_sample_rate(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_blocksize(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_do_mid_side_stereo(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_loose_mid_side_stereo(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_max_lpc_order(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_qlp_coeff_precision(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_do_qlp_coeff_prec_search(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_do_escape_coding(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_do_exhaustive_model_search(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_get_min_residual_partition_order(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_max_residual_partition_order(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_rice_parameter_search_dist(const encoder: pFLAC__StreamEncoder): cuint32;
function FLAC__stream_encoder_get_total_samples_estimate(const encoder: pFLAC__StreamEncoder): FLAC__uint64;
function FLAC__stream_encoder_get_limit_min_bitrate(const encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_init_stream(
  encoder: pFLAC__StreamEncoder;
  write_callback: FLAC__StreamEncoderWriteCallback;
  seek_callback: FLAC__StreamEncoderSeekCallback;
  tell_callback: FLAC__StreamEncoderTellCallback;
  metadata_callback: FLAC__StreamEncoderMetadataCallback;
  client_data: pointer): FLAC__StreamEncoderInitStatus;
function FLAC__stream_encoder_init_ogg_stream(
  encoder: pFLAC__StreamEncoder;
  read_callback: FLAC__StreamEncoderReadCallback;
  write_callback: FLAC__StreamEncoderWriteCallback;
  seek_callback: FLAC__StreamEncoderSeekCallback;
  tell_callback: FLAC__StreamEncoderTellCallback;
  metadata_callback: FLAC__StreamEncoderMetadataCallback;
  client_data: pointer): FLAC__StreamEncoderInitStatus;
function FLAC__stream_encoder_init_file(
  encoder: pFLAC__StreamEncoder;
  const filename: pcchar;
  progress_callback: FLAC__StreamEncoderProgressCallback;
  client_data: pointer): FLAC__StreamEncoderInitStatus;
function FLAC__stream_encoder_init_ogg_file(
  encoder: pFLAC__StreamEncoder;
  const filename: pcchar;
  progress_callback: FLAC__StreamEncoderProgressCallback;
  client_data: pointer): FLAC__StreamEncoderInitStatus;
function FLAC__stream_encoder_finish(encoder: pFLAC__StreamEncoder): FLAC__bool;
function FLAC__stream_encoder_process(encoder: pFLAC__StreamEncoder; const buffer: pFLAC__int32; samples: cuint32): FLAC__bool;
function FLAC__stream_encoder_process_interleaved(encoder: pFLAC__StreamEncoder; const buffer: pFLAC__int32; samples: cuint32): FLAC__bool;

function IsFLACloaded: boolean; 
function InitFLACInterface(const aLibs : Array of String): boolean; overload; 
function DestroyFLACInterface: boolean; 

implementation

var
  FLACloaded: boolean = False;
  FLACLib: Array of HModule;
resourcestring
  SFailedToLoadFLAC = 'Failed to load FLAC library';

type
  p_FLAC__metadata_object_new = function (atype : FLAC__MetadataType) : pFLAC__StreamMetadata; cdecl;
  p_FLAC__metadata_object_clone = function (const aobject : pFLAC__StreamMetadata) : pFLAC__StreamMetadata; cdecl;
  p_FLAC__metadata_object_delete = procedure (aobject : pFLAC__StreamMetadata); cdecl;

  p_FLAC__metadata_object_vorbiscomment_set_vendor_string = function (aobject : pFLAC__StreamMetadata; entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool) : FLAC__bool; cdecl;
  p_FLAC__metadata_object_vorbiscomment_resize_comments = function (aobject : pFLAC__StreamMetadata; new_num_comments : cuint32) : FLAC__bool; cdecl;
  p_FLAC__metadata_object_vorbiscomment_set_comment = function (aobject : pFLAC__StreamMetadata; comment_num : cuint32; entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool) : FLAC__bool; cdecl;
  p_FLAC__metadata_object_vorbiscomment_append_comment = function (aobject : pFLAC__StreamMetadata; entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool) : FLAC__bool; cdecl;

  p_FLAC__stream_decoder_new = function(): pFLAC__StreamDecoder; cdecl;
  p_FLAC__stream_decoder_delete = procedure(decoder: pFLAC__StreamDecoder); cdecl;
  p_FLAC__stream_decoder_set_ogg_serial_number = function(decoder: pFLAC__StreamDecoder; serial_number: clong): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_md5_checking = function(decoder: pFLAC__StreamDecoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_metadata_respond = function(decoder: pFLAC__StreamDecoder; atype: FLAC__MetadataType): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_metadata_respond_application = function(decoder: pFLAC__StreamDecoder; const id: TFLAC__byteArray4): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_metadata_respond_all = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_metadata_ignore = function(decoder: pFLAC__StreamDecoder; atype: FLAC__MetadataType): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_metadata_ignore_application = function(decoder: pFLAC__StreamDecoder; const id: TFLAC__byteArray4): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_set_metadata_ignore_all = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_get_state = function(const decoder: pFLAC__StreamDecoder): FLAC__StreamDecoderState; cdecl;
  p_FLAC__stream_decoder_get_resolved_state_string = function(const decoder: pFLAC__StreamDecoder): pcchar; cdecl;
  p_FLAC__stream_decoder_get_md5_checking = function(const decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_get_total_samples = function(const decoder: pFLAC__StreamDecoder): FLAC__uint64; cdecl;
  p_FLAC__stream_decoder_get_channels = function(const decoder: pFLAC__StreamDecoder): cuint32; cdecl;
  p_FLAC__stream_decoder_get_channel_assignment = function(const decoder: pFLAC__StreamDecoder): FLAC__ChannelAssignment; cdecl;
  p_FLAC__stream_decoder_get_bits_per_sample = function(const decoder: pFLAC__StreamDecoder): cuint32; cdecl;
  p_FLAC__stream_decoder_get_sample_rate = function(const decoder: pFLAC__StreamDecoder): cuint32; cdecl;
  p_FLAC__stream_decoder_get_blocksize = function(const decoder: pFLAC__StreamDecoder): cuint32; cdecl;
  p_FLAC__stream_decoder_get_decode_position = function(const decoder: pFLAC__StreamDecoder; position: pFLAC__uint64): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_get_client_data = function(decoder: pFLAC__StreamDecoder): pointer; cdecl;
  p_FLAC__stream_decoder_init_stream = function(decoder: pFLAC__StreamDecoder; read_callback: FLAC__StreamDecoderReadCallback; seek_callback: FLAC__StreamDecoderSeekCallback; tell_callback: FLAC__StreamDecoderTellCallback; length_callback: FLAC__StreamDecoderLengthCallback; eof_callback: FLAC__StreamDecoderEofCallback; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus; cdecl;
  p_FLAC__stream_decoder_init_ogg_stream = function(decoder: pFLAC__StreamDecoder; read_callback: FLAC__StreamDecoderReadCallback; seek_callback: FLAC__StreamDecoderSeekCallback; tell_callback: FLAC__StreamDecoderTellCallback; length_callback: FLAC__StreamDecoderLengthCallback; eof_callback: FLAC__StreamDecoderEofCallback; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus; cdecl;
  p_FLAC__stream_decoder_init_file = function(decoder: pFLAC__StreamDecoder; const filename: pcchar; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus; cdecl;
  p_FLAC__stream_decoder_init_ogg_file = function(decoder: pFLAC__StreamDecoder; const filename: pcchar; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus; cdecl;
  p_FLAC__stream_decoder_finish = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_flush = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_reset = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_process_single = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_process_until_end_of_metadata = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_process_until_end_of_stream = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_skip_single_frame = function(decoder: pFLAC__StreamDecoder): FLAC__bool; cdecl;
  p_FLAC__stream_decoder_seek_absolute = function(decoder: pFLAC__StreamDecoder; sample: FLAC__uint64): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_new = function(): pFLAC__StreamEncoder; cdecl;
  p_FLAC__stream_encoder_delete = procedure(encoder: pFLAC__StreamEncoder); cdecl;
  p_FLAC__stream_encoder_set_ogg_serial_number = function(encoder: pFLAC__StreamEncoder; serial_number: clong): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_verify = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_streamable_subset = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_channels = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_bits_per_sample = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_sample_rate = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_compression_level = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_blocksize = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_do_mid_side_stereo = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_loose_mid_side_stereo = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_apodization = function(encoder: pFLAC__StreamEncoder; const specification: pcchar): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_max_lpc_order = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_qlp_coeff_precision = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_do_qlp_coeff_prec_search = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_do_escape_coding = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_do_exhaustive_model_search = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_min_residual_partition_order = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_max_residual_partition_order = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_rice_parameter_search_dist = function(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_total_samples_estimate = function(encoder: pFLAC__StreamEncoder; value: FLAC__uint64): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_metadata = function(encoder: pFLAC__StreamEncoder; metadata: ppFLAC__StreamMetadata; num_blocks: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_set_limit_min_bitrate = function(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_state = function(const encoder: pFLAC__StreamEncoder): FLAC__StreamEncoderState; cdecl;
  p_FLAC__stream_encoder_get_verify_decoder_state = function(const encoder: pFLAC__StreamEncoder): FLAC__StreamDecoderState; cdecl;
  p_FLAC__stream_encoder_get_resolved_state_string = function(const encoder: pFLAC__StreamEncoder): pcchar; cdecl;
  p_FLAC__stream_encoder_get_verify_decoder_error_stats = procedure(const encoder: pFLAC__StreamEncoder; absolute_sample: pFLAC__uint64; frame_number: pcuint32; channel: pcuint32; sample: pcuint32; expected: pFLAC__int32; got: pFLAC__int32); cdecl;
  p_FLAC__stream_encoder_get_verify = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_streamable_subset = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_channels = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_bits_per_sample = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_sample_rate = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_blocksize = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_do_mid_side_stereo = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_loose_mid_side_stereo = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_max_lpc_order = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_qlp_coeff_precision = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_do_qlp_coeff_prec_search = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_do_escape_coding = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_do_exhaustive_model_search = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_get_min_residual_partition_order = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_max_residual_partition_order = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_rice_parameter_search_dist = function(const encoder: pFLAC__StreamEncoder): cuint32; cdecl;
  p_FLAC__stream_encoder_get_total_samples_estimate = function(const encoder: pFLAC__StreamEncoder): FLAC__uint64; cdecl;
  p_FLAC__stream_encoder_get_limit_min_bitrate = function(const encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_init_stream = function(encoder: pFLAC__StreamEncoder; write_callback: FLAC__StreamEncoderWriteCallback; seek_callback: FLAC__StreamEncoderSeekCallback; tell_callback: FLAC__StreamEncoderTellCallback; metadata_callback: FLAC__StreamEncoderMetadataCallback; client_data: pointer): FLAC__StreamEncoderInitStatus; cdecl;
  p_FLAC__stream_encoder_init_ogg_stream = function(encoder: pFLAC__StreamEncoder; read_callback: FLAC__StreamEncoderReadCallback; write_callback: FLAC__StreamEncoderWriteCallback; seek_callback: FLAC__StreamEncoderSeekCallback; tell_callback: FLAC__StreamEncoderTellCallback; metadata_callback: FLAC__StreamEncoderMetadataCallback; client_data: pointer): FLAC__StreamEncoderInitStatus; cdecl;
  p_FLAC__stream_encoder_init_file = function(encoder: pFLAC__StreamEncoder; const filename: pcchar; progress_callback: FLAC__StreamEncoderProgressCallback; client_data: pointer): FLAC__StreamEncoderInitStatus; cdecl;
  p_FLAC__stream_encoder_init_ogg_file = function(encoder: pFLAC__StreamEncoder; const filename: pcchar; progress_callback: FLAC__StreamEncoderProgressCallback; client_data: pointer): FLAC__StreamEncoderInitStatus; cdecl;
  p_FLAC__stream_encoder_finish = function(encoder: pFLAC__StreamEncoder): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_process = function(encoder: pFLAC__StreamEncoder; const buffer: pFLAC__int32; samples: cuint32): FLAC__bool; cdecl;
  p_FLAC__stream_encoder_process_interleaved = function(encoder: pFLAC__StreamEncoder; const buffer: pFLAC__int32; samples: cuint32): FLAC__bool; cdecl;

var
  _FLAC__metadata_object_new   :p_FLAC__metadata_object_new   =nil;
  _FLAC__metadata_object_clone :p_FLAC__metadata_object_clone =nil;
  _FLAC__metadata_object_delete:p_FLAC__metadata_object_delete=nil;

  _FLAC__metadata_object_vorbiscomment_set_vendor_string : p_FLAC__metadata_object_vorbiscomment_set_vendor_string = nil;
  _FLAC__metadata_object_vorbiscomment_resize_comments  : p_FLAC__metadata_object_vorbiscomment_resize_comments = nil;
  _FLAC__metadata_object_vorbiscomment_set_comment      : p_FLAC__metadata_object_vorbiscomment_set_comment = nil;
  _FLAC__metadata_object_vorbiscomment_append_comment   : p_FLAC__metadata_object_vorbiscomment_append_comment = nil;

  _FLAC__stream_decoder_new: p_FLAC__stream_decoder_new = nil;
  _FLAC__stream_decoder_delete: p_FLAC__stream_decoder_delete = nil;
  _FLAC__stream_decoder_set_ogg_serial_number: p_FLAC__stream_decoder_set_ogg_serial_number = nil;
  _FLAC__stream_decoder_set_md5_checking: p_FLAC__stream_decoder_set_md5_checking = nil;
  _FLAC__stream_decoder_set_metadata_respond: p_FLAC__stream_decoder_set_metadata_respond = nil;
  _FLAC__stream_decoder_set_metadata_respond_application: p_FLAC__stream_decoder_set_metadata_respond_application = nil;
  _FLAC__stream_decoder_set_metadata_respond_all: p_FLAC__stream_decoder_set_metadata_respond_all = nil;
  _FLAC__stream_decoder_set_metadata_ignore: p_FLAC__stream_decoder_set_metadata_ignore = nil;
  _FLAC__stream_decoder_set_metadata_ignore_application: p_FLAC__stream_decoder_set_metadata_ignore_application = nil;
  _FLAC__stream_decoder_set_metadata_ignore_all: p_FLAC__stream_decoder_set_metadata_ignore_all = nil;
  _FLAC__stream_decoder_get_state: p_FLAC__stream_decoder_get_state = nil;
  _FLAC__stream_decoder_get_resolved_state_string: p_FLAC__stream_decoder_get_resolved_state_string = nil;
  _FLAC__stream_decoder_get_md5_checking: p_FLAC__stream_decoder_get_md5_checking = nil;
  _FLAC__stream_decoder_get_total_samples: p_FLAC__stream_decoder_get_total_samples = nil;
  _FLAC__stream_decoder_get_channels: p_FLAC__stream_decoder_get_channels = nil;
  _FLAC__stream_decoder_get_channel_assignment: p_FLAC__stream_decoder_get_channel_assignment = nil;
  _FLAC__stream_decoder_get_bits_per_sample: p_FLAC__stream_decoder_get_bits_per_sample = nil;
  _FLAC__stream_decoder_get_sample_rate: p_FLAC__stream_decoder_get_sample_rate = nil;
  _FLAC__stream_decoder_get_blocksize: p_FLAC__stream_decoder_get_blocksize = nil;
  _FLAC__stream_decoder_get_decode_position: p_FLAC__stream_decoder_get_decode_position = nil;
  _FLAC__stream_decoder_get_client_data: p_FLAC__stream_decoder_get_client_data = nil;
  _FLAC__stream_decoder_init_stream: p_FLAC__stream_decoder_init_stream = nil;
  _FLAC__stream_decoder_init_ogg_stream: p_FLAC__stream_decoder_init_ogg_stream = nil;
  _FLAC__stream_decoder_init_file: p_FLAC__stream_decoder_init_file = nil;
  _FLAC__stream_decoder_init_ogg_file: p_FLAC__stream_decoder_init_ogg_file = nil;
  _FLAC__stream_decoder_finish: p_FLAC__stream_decoder_finish = nil;
  _FLAC__stream_decoder_flush: p_FLAC__stream_decoder_flush = nil;
  _FLAC__stream_decoder_reset: p_FLAC__stream_decoder_reset = nil;
  _FLAC__stream_decoder_process_single: p_FLAC__stream_decoder_process_single = nil;
  _FLAC__stream_decoder_process_until_end_of_metadata: p_FLAC__stream_decoder_process_until_end_of_metadata = nil;
  _FLAC__stream_decoder_process_until_end_of_stream: p_FLAC__stream_decoder_process_until_end_of_stream = nil;
  _FLAC__stream_decoder_skip_single_frame: p_FLAC__stream_decoder_skip_single_frame = nil;
  _FLAC__stream_decoder_seek_absolute: p_FLAC__stream_decoder_seek_absolute = nil;
  _FLAC__stream_encoder_new: p_FLAC__stream_encoder_new = nil;
  _FLAC__stream_encoder_delete: p_FLAC__stream_encoder_delete = nil;
  _FLAC__stream_encoder_set_ogg_serial_number: p_FLAC__stream_encoder_set_ogg_serial_number = nil;
  _FLAC__stream_encoder_set_verify: p_FLAC__stream_encoder_set_verify = nil;
  _FLAC__stream_encoder_set_streamable_subset: p_FLAC__stream_encoder_set_streamable_subset = nil;
  _FLAC__stream_encoder_set_channels: p_FLAC__stream_encoder_set_channels = nil;
  _FLAC__stream_encoder_set_bits_per_sample: p_FLAC__stream_encoder_set_bits_per_sample = nil;
  _FLAC__stream_encoder_set_sample_rate: p_FLAC__stream_encoder_set_sample_rate = nil;
  _FLAC__stream_encoder_set_compression_level: p_FLAC__stream_encoder_set_compression_level = nil;
  _FLAC__stream_encoder_set_blocksize: p_FLAC__stream_encoder_set_blocksize = nil;
  _FLAC__stream_encoder_set_do_mid_side_stereo: p_FLAC__stream_encoder_set_do_mid_side_stereo = nil;
  _FLAC__stream_encoder_set_loose_mid_side_stereo: p_FLAC__stream_encoder_set_loose_mid_side_stereo = nil;
  _FLAC__stream_encoder_set_apodization: p_FLAC__stream_encoder_set_apodization = nil;
  _FLAC__stream_encoder_set_max_lpc_order: p_FLAC__stream_encoder_set_max_lpc_order = nil;
  _FLAC__stream_encoder_set_qlp_coeff_precision: p_FLAC__stream_encoder_set_qlp_coeff_precision = nil;
  _FLAC__stream_encoder_set_do_qlp_coeff_prec_search: p_FLAC__stream_encoder_set_do_qlp_coeff_prec_search = nil;
  _FLAC__stream_encoder_set_do_escape_coding: p_FLAC__stream_encoder_set_do_escape_coding = nil;
  _FLAC__stream_encoder_set_do_exhaustive_model_search: p_FLAC__stream_encoder_set_do_exhaustive_model_search = nil;
  _FLAC__stream_encoder_set_min_residual_partition_order: p_FLAC__stream_encoder_set_min_residual_partition_order = nil;
  _FLAC__stream_encoder_set_max_residual_partition_order: p_FLAC__stream_encoder_set_max_residual_partition_order = nil;
  _FLAC__stream_encoder_set_rice_parameter_search_dist: p_FLAC__stream_encoder_set_rice_parameter_search_dist = nil;
  _FLAC__stream_encoder_set_total_samples_estimate: p_FLAC__stream_encoder_set_total_samples_estimate = nil;
  _FLAC__stream_encoder_set_metadata: p_FLAC__stream_encoder_set_metadata = nil;
  _FLAC__stream_encoder_set_limit_min_bitrate: p_FLAC__stream_encoder_set_limit_min_bitrate = nil;
  _FLAC__stream_encoder_get_state: p_FLAC__stream_encoder_get_state = nil;
  _FLAC__stream_encoder_get_verify_decoder_state: p_FLAC__stream_encoder_get_verify_decoder_state = nil;
  _FLAC__stream_encoder_get_resolved_state_string: p_FLAC__stream_encoder_get_resolved_state_string = nil;
  _FLAC__stream_encoder_get_verify_decoder_error_stats: p_FLAC__stream_encoder_get_verify_decoder_error_stats = nil;
  _FLAC__stream_encoder_get_verify: p_FLAC__stream_encoder_get_verify = nil;
  _FLAC__stream_encoder_get_streamable_subset: p_FLAC__stream_encoder_get_streamable_subset = nil;
  _FLAC__stream_encoder_get_channels: p_FLAC__stream_encoder_get_channels = nil;
  _FLAC__stream_encoder_get_bits_per_sample: p_FLAC__stream_encoder_get_bits_per_sample = nil;
  _FLAC__stream_encoder_get_sample_rate: p_FLAC__stream_encoder_get_sample_rate = nil;
  _FLAC__stream_encoder_get_blocksize: p_FLAC__stream_encoder_get_blocksize = nil;
  _FLAC__stream_encoder_get_do_mid_side_stereo: p_FLAC__stream_encoder_get_do_mid_side_stereo = nil;
  _FLAC__stream_encoder_get_loose_mid_side_stereo: p_FLAC__stream_encoder_get_loose_mid_side_stereo = nil;
  _FLAC__stream_encoder_get_max_lpc_order: p_FLAC__stream_encoder_get_max_lpc_order = nil;
  _FLAC__stream_encoder_get_qlp_coeff_precision: p_FLAC__stream_encoder_get_qlp_coeff_precision = nil;
  _FLAC__stream_encoder_get_do_qlp_coeff_prec_search: p_FLAC__stream_encoder_get_do_qlp_coeff_prec_search = nil;
  _FLAC__stream_encoder_get_do_escape_coding: p_FLAC__stream_encoder_get_do_escape_coding = nil;
  _FLAC__stream_encoder_get_do_exhaustive_model_search: p_FLAC__stream_encoder_get_do_exhaustive_model_search = nil;
  _FLAC__stream_encoder_get_min_residual_partition_order: p_FLAC__stream_encoder_get_min_residual_partition_order = nil;
  _FLAC__stream_encoder_get_max_residual_partition_order: p_FLAC__stream_encoder_get_max_residual_partition_order = nil;
  _FLAC__stream_encoder_get_rice_parameter_search_dist: p_FLAC__stream_encoder_get_rice_parameter_search_dist = nil;
  _FLAC__stream_encoder_get_total_samples_estimate: p_FLAC__stream_encoder_get_total_samples_estimate = nil;
  _FLAC__stream_encoder_get_limit_min_bitrate: p_FLAC__stream_encoder_get_limit_min_bitrate = nil;
  _FLAC__stream_encoder_init_stream: p_FLAC__stream_encoder_init_stream = nil;
  _FLAC__stream_encoder_init_ogg_stream: p_FLAC__stream_encoder_init_ogg_stream = nil;
  _FLAC__stream_encoder_init_file: p_FLAC__stream_encoder_init_file = nil;
  _FLAC__stream_encoder_init_ogg_file: p_FLAC__stream_encoder_init_ogg_file = nil;
  _FLAC__stream_encoder_finish: p_FLAC__stream_encoder_finish = nil;
  _FLAC__stream_encoder_process: p_FLAC__stream_encoder_process = nil;
  _FLAC__stream_encoder_process_interleaved: p_FLAC__stream_encoder_process_interleaved = nil;

{$IFNDEF WINDOWS}
{ Try to load all library versions until you find or run out }
procedure LoadLibUnix(const aLibs : Array of String);
var i : integer;
begin
  for i := 0 to High(aLibs) do
  begin
    FLACLib[i] := LoadLibrary(aLibs[i]);
  end;
end;

{$ELSE WINDOWS}
procedure LoadLibsWin(const aLibs : Array of String);
var i : integer;
begin
  for i := 0 to High(aLibs) do
  begin
    FLACLib[i] := LoadLibrary(aLibs[i]);
  end;
end;

{$ENDIF WINDOWS}

function IsFLACloaded: boolean;
begin
  Result := FLACloaded;
end;

procedure UnloadLibraries;
var i : integer;
begin
  FLACloaded := False;
  for i := 0 to High(FLACLib) do
  if FLACLib[i] <> NilHandle then
  begin
    FreeLibrary(FLACLib[i]);
    FLACLib[i] := NilHandle;
  end;
end;

function LoadLibraries(const aLibs : Array of String): boolean;
var i : integer;
begin
  SetLength(FLACLib, Length(aLibs));
  Result := False;
  {$IFDEF WINDOWS}
  LoadLibsWin(aLibs);
  {$ELSE}
  LoadLibUnix(aLibs);
  {$ENDIF}
  for i := 0 to High(aLibs) do
  if FLACLib[i] <> NilHandle then
     Result := true;
end;

function GetProcAddr(const module: Array of HModule; const ProcName: string): Pointer;
var i : integer;
begin
  for i := Low(module) to High(module) do 
  if module[i] <> NilHandle then 
  begin
    Result := GetProcAddress(module[i], PChar(ProcName));
    if Assigned(Result) then Exit;
  end;
  Result := nil;
end;

procedure LoadFLACEntryPoints;
begin
  _FLAC__metadata_object_new    := p_FLAC__metadata_object_new(GetProcAddr(FLACLib, 'FLAC__metadata_object_new'));
  _FLAC__metadata_object_clone  := p_FLAC__metadata_object_clone(GetProcAddr(FLACLib, 'FLAC__metadata_object_clone'));
  _FLAC__metadata_object_delete := p_FLAC__metadata_object_delete(GetProcAddr(FLACLib, 'FLAC__metadata_object_delete'));

  _FLAC__metadata_object_vorbiscomment_set_vendor_string := p_FLAC__metadata_object_vorbiscomment_set_vendor_string(GetProcAddr(FLACLib, 'FLAC__metadata_object_vorbiscomment_set_vendor_string'));
  _FLAC__metadata_object_vorbiscomment_resize_comments   := p_FLAC__metadata_object_vorbiscomment_resize_comments(GetProcAddr(FLACLib, 'FLAC__metadata_object_vorbiscomment_resize_comments'));
  _FLAC__metadata_object_vorbiscomment_set_comment       := p_FLAC__metadata_object_vorbiscomment_set_comment(GetProcAddr(FLACLib, 'FLAC__metadata_object_vorbiscomment_set_comment'));
  _FLAC__metadata_object_vorbiscomment_append_comment    := p_FLAC__metadata_object_vorbiscomment_append_comment(GetProcAddr(FLACLib, 'FLAC__metadata_object_vorbiscomment_append_comment'));

  _FLAC__stream_decoder_new := p_FLAC__stream_decoder_new(GetProcAddr(FLACLib, 'FLAC__stream_decoder_new'));
  _FLAC__stream_decoder_delete := p_FLAC__stream_decoder_delete(GetProcAddr(FLACLib, 'FLAC__stream_decoder_delete'));
  _FLAC__stream_decoder_set_ogg_serial_number := p_FLAC__stream_decoder_set_ogg_serial_number(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_ogg_serial_number'));
  _FLAC__stream_decoder_set_md5_checking := p_FLAC__stream_decoder_set_md5_checking(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_md5_checking'));
  _FLAC__stream_decoder_set_metadata_respond := p_FLAC__stream_decoder_set_metadata_respond(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_metadata_respond'));
  _FLAC__stream_decoder_set_metadata_respond_application := p_FLAC__stream_decoder_set_metadata_respond_application(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_metadata_respond_application'));
  _FLAC__stream_decoder_set_metadata_respond_all := p_FLAC__stream_decoder_set_metadata_respond_all(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_metadata_respond_all'));
  _FLAC__stream_decoder_set_metadata_ignore := p_FLAC__stream_decoder_set_metadata_ignore(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_metadata_ignore'));
  _FLAC__stream_decoder_set_metadata_ignore_application := p_FLAC__stream_decoder_set_metadata_ignore_application(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_metadata_ignore_application'));
  _FLAC__stream_decoder_set_metadata_ignore_all := p_FLAC__stream_decoder_set_metadata_ignore_all(GetProcAddr(FLACLib, 'FLAC__stream_decoder_set_metadata_ignore_all'));
  _FLAC__stream_decoder_get_state := p_FLAC__stream_decoder_get_state(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_state'));
  _FLAC__stream_decoder_get_resolved_state_string := p_FLAC__stream_decoder_get_resolved_state_string(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_resolved_state_string'));
  _FLAC__stream_decoder_get_md5_checking := p_FLAC__stream_decoder_get_md5_checking(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_md5_checking'));
  _FLAC__stream_decoder_get_total_samples := p_FLAC__stream_decoder_get_total_samples(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_total_samples'));
  _FLAC__stream_decoder_get_channels := p_FLAC__stream_decoder_get_channels(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_channels'));
  _FLAC__stream_decoder_get_channel_assignment := p_FLAC__stream_decoder_get_channel_assignment(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_channel_assignment'));
  _FLAC__stream_decoder_get_bits_per_sample := p_FLAC__stream_decoder_get_bits_per_sample(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_bits_per_sample'));
  _FLAC__stream_decoder_get_sample_rate := p_FLAC__stream_decoder_get_sample_rate(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_sample_rate'));
  _FLAC__stream_decoder_get_blocksize := p_FLAC__stream_decoder_get_blocksize(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_blocksize'));
  _FLAC__stream_decoder_get_decode_position := p_FLAC__stream_decoder_get_decode_position(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_decode_position'));
  _FLAC__stream_decoder_get_client_data := p_FLAC__stream_decoder_get_client_data(GetProcAddr(FLACLib, 'FLAC__stream_decoder_get_client_data'));
  _FLAC__stream_decoder_init_stream := p_FLAC__stream_decoder_init_stream(GetProcAddr(FLACLib, 'FLAC__stream_decoder_init_stream'));
  _FLAC__stream_decoder_init_ogg_stream := p_FLAC__stream_decoder_init_ogg_stream(GetProcAddr(FLACLib, 'FLAC__stream_decoder_init_ogg_stream'));
  _FLAC__stream_decoder_init_file := p_FLAC__stream_decoder_init_file(GetProcAddr(FLACLib, 'FLAC__stream_decoder_init_file'));
  _FLAC__stream_decoder_init_ogg_file := p_FLAC__stream_decoder_init_ogg_file(GetProcAddr(FLACLib, 'FLAC__stream_decoder_init_ogg_file'));
  _FLAC__stream_decoder_finish := p_FLAC__stream_decoder_finish(GetProcAddr(FLACLib, 'FLAC__stream_decoder_finish'));
  _FLAC__stream_decoder_flush := p_FLAC__stream_decoder_flush(GetProcAddr(FLACLib, 'FLAC__stream_decoder_flush'));
  _FLAC__stream_decoder_reset := p_FLAC__stream_decoder_reset(GetProcAddr(FLACLib, 'FLAC__stream_decoder_reset'));
  _FLAC__stream_decoder_process_single := p_FLAC__stream_decoder_process_single(GetProcAddr(FLACLib, 'FLAC__stream_decoder_process_single'));
  _FLAC__stream_decoder_process_until_end_of_metadata := p_FLAC__stream_decoder_process_until_end_of_metadata(GetProcAddr(FLACLib, 'FLAC__stream_decoder_process_until_end_of_metadata'));
  _FLAC__stream_decoder_process_until_end_of_stream := p_FLAC__stream_decoder_process_until_end_of_stream(GetProcAddr(FLACLib, 'FLAC__stream_decoder_process_until_end_of_stream'));
  _FLAC__stream_decoder_skip_single_frame := p_FLAC__stream_decoder_skip_single_frame(GetProcAddr(FLACLib, 'FLAC__stream_decoder_skip_single_frame'));
  _FLAC__stream_decoder_seek_absolute := p_FLAC__stream_decoder_seek_absolute(GetProcAddr(FLACLib, 'FLAC__stream_decoder_seek_absolute'));
  _FLAC__stream_encoder_new := p_FLAC__stream_encoder_new(GetProcAddr(FLACLib, 'FLAC__stream_encoder_new'));
  _FLAC__stream_encoder_delete := p_FLAC__stream_encoder_delete(GetProcAddr(FLACLib, 'FLAC__stream_encoder_delete'));
  _FLAC__stream_encoder_set_ogg_serial_number := p_FLAC__stream_encoder_set_ogg_serial_number(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_ogg_serial_number'));
  _FLAC__stream_encoder_set_verify := p_FLAC__stream_encoder_set_verify(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_verify'));
  _FLAC__stream_encoder_set_streamable_subset := p_FLAC__stream_encoder_set_streamable_subset(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_streamable_subset'));
  _FLAC__stream_encoder_set_channels := p_FLAC__stream_encoder_set_channels(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_channels'));
  _FLAC__stream_encoder_set_bits_per_sample := p_FLAC__stream_encoder_set_bits_per_sample(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_bits_per_sample'));
  _FLAC__stream_encoder_set_sample_rate := p_FLAC__stream_encoder_set_sample_rate(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_sample_rate'));
  _FLAC__stream_encoder_set_compression_level := p_FLAC__stream_encoder_set_compression_level(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_compression_level'));
  _FLAC__stream_encoder_set_blocksize := p_FLAC__stream_encoder_set_blocksize(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_blocksize'));
  _FLAC__stream_encoder_set_do_mid_side_stereo := p_FLAC__stream_encoder_set_do_mid_side_stereo(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_do_mid_side_stereo'));
  _FLAC__stream_encoder_set_loose_mid_side_stereo := p_FLAC__stream_encoder_set_loose_mid_side_stereo(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_loose_mid_side_stereo'));
  _FLAC__stream_encoder_set_apodization := p_FLAC__stream_encoder_set_apodization(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_apodization'));
  _FLAC__stream_encoder_set_max_lpc_order := p_FLAC__stream_encoder_set_max_lpc_order(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_max_lpc_order'));
  _FLAC__stream_encoder_set_qlp_coeff_precision := p_FLAC__stream_encoder_set_qlp_coeff_precision(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_qlp_coeff_precision'));
  _FLAC__stream_encoder_set_do_qlp_coeff_prec_search := p_FLAC__stream_encoder_set_do_qlp_coeff_prec_search(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_do_qlp_coeff_prec_search'));
  _FLAC__stream_encoder_set_do_escape_coding := p_FLAC__stream_encoder_set_do_escape_coding(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_do_escape_coding'));
  _FLAC__stream_encoder_set_do_exhaustive_model_search := p_FLAC__stream_encoder_set_do_exhaustive_model_search(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_do_exhaustive_model_search'));
  _FLAC__stream_encoder_set_min_residual_partition_order := p_FLAC__stream_encoder_set_min_residual_partition_order(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_min_residual_partition_order'));
  _FLAC__stream_encoder_set_max_residual_partition_order := p_FLAC__stream_encoder_set_max_residual_partition_order(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_max_residual_partition_order'));
  _FLAC__stream_encoder_set_rice_parameter_search_dist := p_FLAC__stream_encoder_set_rice_parameter_search_dist(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_rice_parameter_search_dist'));
  _FLAC__stream_encoder_set_total_samples_estimate := p_FLAC__stream_encoder_set_total_samples_estimate(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_total_samples_estimate'));
  _FLAC__stream_encoder_set_metadata := p_FLAC__stream_encoder_set_metadata(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_metadata'));
  _FLAC__stream_encoder_set_limit_min_bitrate := p_FLAC__stream_encoder_set_limit_min_bitrate(GetProcAddr(FLACLib, 'FLAC__stream_encoder_set_limit_min_bitrate'));
  _FLAC__stream_encoder_get_state := p_FLAC__stream_encoder_get_state(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_state'));
  _FLAC__stream_encoder_get_verify_decoder_state := p_FLAC__stream_encoder_get_verify_decoder_state(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_verify_decoder_state'));
  _FLAC__stream_encoder_get_resolved_state_string := p_FLAC__stream_encoder_get_resolved_state_string(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_resolved_state_string'));
  _FLAC__stream_encoder_get_verify_decoder_error_stats := p_FLAC__stream_encoder_get_verify_decoder_error_stats(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_verify_decoder_error_stats'));
  _FLAC__stream_encoder_get_verify := p_FLAC__stream_encoder_get_verify(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_verify'));
  _FLAC__stream_encoder_get_streamable_subset := p_FLAC__stream_encoder_get_streamable_subset(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_streamable_subset'));
  _FLAC__stream_encoder_get_channels := p_FLAC__stream_encoder_get_channels(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_channels'));
  _FLAC__stream_encoder_get_bits_per_sample := p_FLAC__stream_encoder_get_bits_per_sample(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_bits_per_sample'));
  _FLAC__stream_encoder_get_sample_rate := p_FLAC__stream_encoder_get_sample_rate(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_sample_rate'));
  _FLAC__stream_encoder_get_blocksize := p_FLAC__stream_encoder_get_blocksize(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_blocksize'));
  _FLAC__stream_encoder_get_do_mid_side_stereo := p_FLAC__stream_encoder_get_do_mid_side_stereo(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_do_mid_side_stereo'));
  _FLAC__stream_encoder_get_loose_mid_side_stereo := p_FLAC__stream_encoder_get_loose_mid_side_stereo(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_loose_mid_side_stereo'));
  _FLAC__stream_encoder_get_max_lpc_order := p_FLAC__stream_encoder_get_max_lpc_order(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_max_lpc_order'));
  _FLAC__stream_encoder_get_qlp_coeff_precision := p_FLAC__stream_encoder_get_qlp_coeff_precision(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_qlp_coeff_precision'));
  _FLAC__stream_encoder_get_do_qlp_coeff_prec_search := p_FLAC__stream_encoder_get_do_qlp_coeff_prec_search(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_do_qlp_coeff_prec_search'));
  _FLAC__stream_encoder_get_do_escape_coding := p_FLAC__stream_encoder_get_do_escape_coding(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_do_escape_coding'));
  _FLAC__stream_encoder_get_do_exhaustive_model_search := p_FLAC__stream_encoder_get_do_exhaustive_model_search(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_do_exhaustive_model_search'));
  _FLAC__stream_encoder_get_min_residual_partition_order := p_FLAC__stream_encoder_get_min_residual_partition_order(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_min_residual_partition_order'));
  _FLAC__stream_encoder_get_max_residual_partition_order := p_FLAC__stream_encoder_get_max_residual_partition_order(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_max_residual_partition_order'));
  _FLAC__stream_encoder_get_rice_parameter_search_dist := p_FLAC__stream_encoder_get_rice_parameter_search_dist(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_rice_parameter_search_dist'));
  _FLAC__stream_encoder_get_total_samples_estimate := p_FLAC__stream_encoder_get_total_samples_estimate(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_total_samples_estimate'));
  _FLAC__stream_encoder_get_limit_min_bitrate := p_FLAC__stream_encoder_get_limit_min_bitrate(GetProcAddr(FLACLib, 'FLAC__stream_encoder_get_limit_min_bitrate'));
  _FLAC__stream_encoder_init_stream := p_FLAC__stream_encoder_init_stream(GetProcAddr(FLACLib, 'FLAC__stream_encoder_init_stream'));
  _FLAC__stream_encoder_init_ogg_stream := p_FLAC__stream_encoder_init_ogg_stream(GetProcAddr(FLACLib, 'FLAC__stream_encoder_init_ogg_stream'));
  _FLAC__stream_encoder_init_file := p_FLAC__stream_encoder_init_file(GetProcAddr(FLACLib, 'FLAC__stream_encoder_init_file'));
  _FLAC__stream_encoder_init_ogg_file := p_FLAC__stream_encoder_init_ogg_file(GetProcAddr(FLACLib, 'FLAC__stream_encoder_init_ogg_file'));
  _FLAC__stream_encoder_finish := p_FLAC__stream_encoder_finish(GetProcAddr(FLACLib, 'FLAC__stream_encoder_finish'));
  _FLAC__stream_encoder_process := p_FLAC__stream_encoder_process(GetProcAddr(FLACLib, 'FLAC__stream_encoder_process'));
  _FLAC__stream_encoder_process_interleaved := p_FLAC__stream_encoder_process_interleaved(GetProcAddr(FLACLib, 'FLAC__stream_encoder_process_interleaved'));
end;

procedure ClearFLACEntryPoints;
begin
  _FLAC__metadata_object_new    := nil;
  _FLAC__metadata_object_clone  := nil;
  _FLAC__metadata_object_delete := nil;

  _FLAC__metadata_object_vorbiscomment_set_vendor_string := nil;
  _FLAC__metadata_object_vorbiscomment_resize_comments   := nil;
  _FLAC__metadata_object_vorbiscomment_set_comment       := nil;
  _FLAC__metadata_object_vorbiscomment_append_comment    := nil;

  _FLAC__stream_decoder_new := nil;
  _FLAC__stream_decoder_delete := nil;
  _FLAC__stream_decoder_set_ogg_serial_number := nil;
  _FLAC__stream_decoder_set_md5_checking := nil;
  _FLAC__stream_decoder_set_metadata_respond := nil;
  _FLAC__stream_decoder_set_metadata_respond_application := nil;
  _FLAC__stream_decoder_set_metadata_respond_all := nil;
  _FLAC__stream_decoder_set_metadata_ignore := nil;
  _FLAC__stream_decoder_set_metadata_ignore_application := nil;
  _FLAC__stream_decoder_set_metadata_ignore_all := nil;
  _FLAC__stream_decoder_get_state := nil;
  _FLAC__stream_decoder_get_resolved_state_string := nil;
  _FLAC__stream_decoder_get_md5_checking := nil;
  _FLAC__stream_decoder_get_total_samples := nil;
  _FLAC__stream_decoder_get_channels := nil;
  _FLAC__stream_decoder_get_channel_assignment := nil;
  _FLAC__stream_decoder_get_bits_per_sample := nil;
  _FLAC__stream_decoder_get_sample_rate := nil;
  _FLAC__stream_decoder_get_blocksize := nil;
  _FLAC__stream_decoder_get_decode_position := nil;
  _FLAC__stream_decoder_get_client_data := nil;
  _FLAC__stream_decoder_init_stream := nil;
  _FLAC__stream_decoder_init_ogg_stream := nil;
  _FLAC__stream_decoder_init_file := nil;
  _FLAC__stream_decoder_init_ogg_file := nil;
  _FLAC__stream_decoder_finish := nil;
  _FLAC__stream_decoder_flush := nil;
  _FLAC__stream_decoder_reset := nil;
  _FLAC__stream_decoder_process_single := nil;
  _FLAC__stream_decoder_process_until_end_of_metadata := nil;
  _FLAC__stream_decoder_process_until_end_of_stream := nil;
  _FLAC__stream_decoder_skip_single_frame := nil;
  _FLAC__stream_decoder_seek_absolute := nil;
  _FLAC__stream_encoder_new := nil;
  _FLAC__stream_encoder_delete := nil;
  _FLAC__stream_encoder_set_ogg_serial_number := nil;
  _FLAC__stream_encoder_set_verify := nil;
  _FLAC__stream_encoder_set_streamable_subset := nil;
  _FLAC__stream_encoder_set_channels := nil;
  _FLAC__stream_encoder_set_bits_per_sample := nil;
  _FLAC__stream_encoder_set_sample_rate := nil;
  _FLAC__stream_encoder_set_compression_level := nil;
  _FLAC__stream_encoder_set_blocksize := nil;
  _FLAC__stream_encoder_set_do_mid_side_stereo := nil;
  _FLAC__stream_encoder_set_loose_mid_side_stereo := nil;
  _FLAC__stream_encoder_set_apodization := nil;
  _FLAC__stream_encoder_set_max_lpc_order := nil;
  _FLAC__stream_encoder_set_qlp_coeff_precision := nil;
  _FLAC__stream_encoder_set_do_qlp_coeff_prec_search := nil;
  _FLAC__stream_encoder_set_do_escape_coding := nil;
  _FLAC__stream_encoder_set_do_exhaustive_model_search := nil;
  _FLAC__stream_encoder_set_min_residual_partition_order := nil;
  _FLAC__stream_encoder_set_max_residual_partition_order := nil;
  _FLAC__stream_encoder_set_rice_parameter_search_dist := nil;
  _FLAC__stream_encoder_set_total_samples_estimate := nil;
  _FLAC__stream_encoder_set_metadata := nil;
  _FLAC__stream_encoder_set_limit_min_bitrate := nil;
  _FLAC__stream_encoder_get_state := nil;
  _FLAC__stream_encoder_get_verify_decoder_state := nil;
  _FLAC__stream_encoder_get_resolved_state_string := nil;
  _FLAC__stream_encoder_get_verify_decoder_error_stats := nil;
  _FLAC__stream_encoder_get_verify := nil;
  _FLAC__stream_encoder_get_streamable_subset := nil;
  _FLAC__stream_encoder_get_channels := nil;
  _FLAC__stream_encoder_get_bits_per_sample := nil;
  _FLAC__stream_encoder_get_sample_rate := nil;
  _FLAC__stream_encoder_get_blocksize := nil;
  _FLAC__stream_encoder_get_do_mid_side_stereo := nil;
  _FLAC__stream_encoder_get_loose_mid_side_stereo := nil;
  _FLAC__stream_encoder_get_max_lpc_order := nil;
  _FLAC__stream_encoder_get_qlp_coeff_precision := nil;
  _FLAC__stream_encoder_get_do_qlp_coeff_prec_search := nil;
  _FLAC__stream_encoder_get_do_escape_coding := nil;
  _FLAC__stream_encoder_get_do_exhaustive_model_search := nil;
  _FLAC__stream_encoder_get_min_residual_partition_order := nil;
  _FLAC__stream_encoder_get_max_residual_partition_order := nil;
  _FLAC__stream_encoder_get_rice_parameter_search_dist := nil;
  _FLAC__stream_encoder_get_total_samples_estimate := nil;
  _FLAC__stream_encoder_get_limit_min_bitrate := nil;
  _FLAC__stream_encoder_init_stream := nil;
  _FLAC__stream_encoder_init_ogg_stream := nil;
  _FLAC__stream_encoder_init_file := nil;
  _FLAC__stream_encoder_init_ogg_file := nil;
  _FLAC__stream_encoder_finish := nil;
  _FLAC__stream_encoder_process := nil;
  _FLAC__stream_encoder_process_interleaved := nil;
end;

function InitFLACInterface(const aLibs : array of String): boolean;
begin
  Result := IsFLACloaded;
  if Result then
    exit;
  Result := LoadLibraries(aLibs);
  if not Result then
  begin
    UnloadLibraries;
    Exit;
  end;
  LoadFLACEntryPoints;
  FLACloaded := True;
  Result := True;
end;

function DestroyFLACInterface: boolean;
begin
  Result := not IsFLACloaded;
  if Result then
    exit;
  ClearFLACEntryPoints;
  UnloadLibraries;
  Result := True;
end;

function FLAC__metadata_object_new(atype : FLAC__MetadataType
  ) : pFLAC__StreamMetadata;
begin
  if Assigned(_FLAC__metadata_object_new) then
    Result := _FLAC__metadata_object_new(atype)
  else
    Result := nil;
end;

function FLAC__metadata_object_clone(const aobject : pFLAC__StreamMetadata
  ) : pFLAC__StreamMetadata;
begin
  if Assigned(_FLAC__metadata_object_clone) then
    Result := _FLAC__metadata_object_clone(aobject)
  else
    Result := nil;
end;

procedure FLAC__metadata_object_delete(aobject : pFLAC__StreamMetadata);
begin
  if Assigned(_FLAC__metadata_object_delete) then
     _FLAC__metadata_object_delete(aobject);
end;

function FLAC__metadata_object_vorbiscomment_set_vendor_string(
  aobject : pFLAC__StreamMetadata;
  entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool
  ) : FLAC__bool;
begin
  if Assigned(_FLAC__metadata_object_vorbiscomment_set_vendor_string) then
    Result := _FLAC__metadata_object_vorbiscomment_set_vendor_string(aobject, entry, copy)
  else
    Result := FLAC__false;
end;

function FLAC__metadata_object_vorbiscomment_resize_comments(
  aobject : pFLAC__StreamMetadata; new_num_comments : cuint32) : FLAC__bool;
begin
  if Assigned(_FLAC__metadata_object_vorbiscomment_resize_comments) then
    Result := _FLAC__metadata_object_vorbiscomment_resize_comments(aobject, new_num_comments)
  else
    Result := FLAC__false;
end;

function FLAC__metadata_object_vorbiscomment_set_comment(
  aobject : pFLAC__StreamMetadata; comment_num : cuint32;
  entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool
  ) : FLAC__bool;
begin
  if Assigned(_FLAC__metadata_object_vorbiscomment_set_comment) then
    Result := _FLAC__metadata_object_vorbiscomment_set_comment(aobject, comment_num, entry, copy)
  else
    Result := FLAC__false;
end;

function FLAC__metadata_object_vorbiscomment_append_comment(
  aobject : pFLAC__StreamMetadata;
  entry : FLAC__StreamMetadata_VorbisComment_Entry; copy : FLAC__bool
  ) : FLAC__bool;
begin
  if Assigned(_FLAC__metadata_object_vorbiscomment_append_comment) then
    Result := _FLAC__metadata_object_vorbiscomment_append_comment(aobject, entry, copy)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_new(): pFLAC__StreamDecoder;
begin
  if Assigned(_FLAC__stream_decoder_new) then
    Result := _FLAC__stream_decoder_new()
  else
    Result := nil;
end;

procedure FLAC__stream_decoder_delete(decoder: pFLAC__StreamDecoder);
begin
  if Assigned(_FLAC__stream_decoder_delete) then
    _FLAC__stream_decoder_delete(decoder);
end;

function FLAC__stream_decoder_set_ogg_serial_number(decoder: pFLAC__StreamDecoder; serial_number: clong): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_ogg_serial_number) then
    Result := _FLAC__stream_decoder_set_ogg_serial_number(decoder, serial_number)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_md5_checking(decoder: pFLAC__StreamDecoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_md5_checking) then
    Result := _FLAC__stream_decoder_set_md5_checking(decoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_metadata_respond(decoder: pFLAC__StreamDecoder; atype: FLAC__MetadataType): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_metadata_respond) then
    Result := _FLAC__stream_decoder_set_metadata_respond(decoder, atype)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_metadata_respond_application(decoder: pFLAC__StreamDecoder; const id: TFLAC__byteArray4): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_metadata_respond_application) then
    Result := _FLAC__stream_decoder_set_metadata_respond_application(decoder, id)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_metadata_respond_all(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_metadata_respond_all) then
    Result := _FLAC__stream_decoder_set_metadata_respond_all(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_metadata_ignore(decoder: pFLAC__StreamDecoder; atype: FLAC__MetadataType): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_metadata_ignore) then
    Result := _FLAC__stream_decoder_set_metadata_ignore(decoder, atype)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_metadata_ignore_application(decoder: pFLAC__StreamDecoder; const id: TFLAC__byteArray4): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_metadata_ignore_application) then
    Result := _FLAC__stream_decoder_set_metadata_ignore_application(decoder, id)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_set_metadata_ignore_all(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_set_metadata_ignore_all) then
    Result := _FLAC__stream_decoder_set_metadata_ignore_all(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_get_state(const decoder: pFLAC__StreamDecoder): FLAC__StreamDecoderState;
begin
  if Assigned(_FLAC__stream_decoder_get_state) then
    Result := _FLAC__stream_decoder_get_state(decoder)
  else
    Result := -1;
end;

function FLAC__stream_decoder_get_resolved_state_string(const decoder: pFLAC__StreamDecoder): pcchar;
begin
  if Assigned(_FLAC__stream_decoder_get_resolved_state_string) then
    Result := _FLAC__stream_decoder_get_resolved_state_string(decoder)
  else
    Result := nil;
end;

function FLAC__stream_decoder_get_md5_checking(const decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_get_md5_checking) then
    Result := _FLAC__stream_decoder_get_md5_checking(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_get_total_samples(const decoder: pFLAC__StreamDecoder): FLAC__uint64;
begin
  if Assigned(_FLAC__stream_decoder_get_total_samples) then
    Result := _FLAC__stream_decoder_get_total_samples(decoder)
  else
    Result := 0;
end;

function FLAC__stream_decoder_get_channels(const decoder: pFLAC__StreamDecoder): cuint32;
begin
  if Assigned(_FLAC__stream_decoder_get_channels) then
    Result := _FLAC__stream_decoder_get_channels(decoder)
  else
    Result := 0;
end;

function FLAC__stream_decoder_get_channel_assignment(const decoder: pFLAC__StreamDecoder): FLAC__ChannelAssignment;
begin
  if Assigned(_FLAC__stream_decoder_get_channel_assignment) then
    Result := _FLAC__stream_decoder_get_channel_assignment(decoder)
  else
    Result := -1;
end;

function FLAC__stream_decoder_get_bits_per_sample(const decoder: pFLAC__StreamDecoder): cuint32;
begin
  if Assigned(_FLAC__stream_decoder_get_bits_per_sample) then
    Result := _FLAC__stream_decoder_get_bits_per_sample(decoder)
  else
    Result := 0;
end;

function FLAC__stream_decoder_get_sample_rate(const decoder: pFLAC__StreamDecoder): cuint32;
begin
  if Assigned(_FLAC__stream_decoder_get_sample_rate) then
    Result := _FLAC__stream_decoder_get_sample_rate(decoder)
  else
    Result := 0;
end;

function FLAC__stream_decoder_get_blocksize(const decoder: pFLAC__StreamDecoder): cuint32;
begin
  if Assigned(_FLAC__stream_decoder_get_blocksize) then
    Result := _FLAC__stream_decoder_get_blocksize(decoder)
  else
    Result := 0;
end;

function FLAC__stream_decoder_get_decode_position(const decoder: pFLAC__StreamDecoder; position: pFLAC__uint64): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_get_decode_position) then
    Result := _FLAC__stream_decoder_get_decode_position(decoder, position)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_get_client_data(decoder: pFLAC__StreamDecoder): pointer;
begin
  if Assigned(_FLAC__stream_decoder_get_client_data) then
    Result := _FLAC__stream_decoder_get_client_data(decoder)
  else
    Result := nil;
end;

function FLAC__stream_decoder_init_stream(decoder: pFLAC__StreamDecoder; read_callback: FLAC__StreamDecoderReadCallback; seek_callback: FLAC__StreamDecoderSeekCallback; tell_callback: FLAC__StreamDecoderTellCallback; length_callback: FLAC__StreamDecoderLengthCallback; eof_callback: FLAC__StreamDecoderEofCallback; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus;
begin
  if Assigned(_FLAC__stream_decoder_init_stream) then
    Result := _FLAC__stream_decoder_init_stream(decoder, read_callback, seek_callback, tell_callback, length_callback, eof_callback, write_callback, metadata_callback, error_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_decoder_init_ogg_stream(decoder: pFLAC__StreamDecoder; read_callback: FLAC__StreamDecoderReadCallback; seek_callback: FLAC__StreamDecoderSeekCallback; tell_callback: FLAC__StreamDecoderTellCallback; length_callback: FLAC__StreamDecoderLengthCallback; eof_callback: FLAC__StreamDecoderEofCallback; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus;
begin
  if Assigned(_FLAC__stream_decoder_init_ogg_stream) then
    Result := _FLAC__stream_decoder_init_ogg_stream(decoder, read_callback, seek_callback, tell_callback, length_callback, eof_callback, write_callback, metadata_callback, error_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_decoder_init_file(decoder: pFLAC__StreamDecoder; const filename: pcchar; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus;
begin
  if Assigned(_FLAC__stream_decoder_init_file) then
    Result := _FLAC__stream_decoder_init_file(decoder, filename, write_callback, metadata_callback, error_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_decoder_init_ogg_file(decoder: pFLAC__StreamDecoder; const filename: pcchar; write_callback: FLAC__StreamDecoderWriteCallback; metadata_callback: FLAC__StreamDecoderMetadataCallback; error_callback: FLAC__StreamDecoderErrorCallback; client_data: pointer): FLAC__StreamDecoderInitStatus;
begin
  if Assigned(_FLAC__stream_decoder_init_ogg_file) then
    Result := _FLAC__stream_decoder_init_ogg_file(decoder, filename, write_callback, metadata_callback, error_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_decoder_finish(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_finish) then
    Result := _FLAC__stream_decoder_finish(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_flush(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_flush) then
    Result := _FLAC__stream_decoder_flush(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_reset(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_reset) then
    Result := _FLAC__stream_decoder_reset(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_process_single(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_process_single) then
    Result := _FLAC__stream_decoder_process_single(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_process_until_end_of_metadata(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_process_until_end_of_metadata) then
    Result := _FLAC__stream_decoder_process_until_end_of_metadata(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_process_until_end_of_stream(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_process_until_end_of_stream) then
    Result := _FLAC__stream_decoder_process_until_end_of_stream(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_skip_single_frame(decoder: pFLAC__StreamDecoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_skip_single_frame) then
    Result := _FLAC__stream_decoder_skip_single_frame(decoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_decoder_seek_absolute(decoder: pFLAC__StreamDecoder; sample: FLAC__uint64): FLAC__bool;
begin
  if Assigned(_FLAC__stream_decoder_seek_absolute) then
    Result := _FLAC__stream_decoder_seek_absolute(decoder, sample)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_new(): pFLAC__StreamEncoder;
begin
  if Assigned(_FLAC__stream_encoder_new) then
    Result := _FLAC__stream_encoder_new()
  else
    Result := nil;
end;

procedure FLAC__stream_encoder_delete(encoder: pFLAC__StreamEncoder);
begin
  if Assigned(_FLAC__stream_encoder_delete) then
    _FLAC__stream_encoder_delete(encoder);
end;

function FLAC__stream_encoder_set_ogg_serial_number(encoder: pFLAC__StreamEncoder; serial_number: clong): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_ogg_serial_number) then
    Result := _FLAC__stream_encoder_set_ogg_serial_number(encoder, serial_number)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_verify(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_verify) then
    Result := _FLAC__stream_encoder_set_verify(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_streamable_subset(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_streamable_subset) then
    Result := _FLAC__stream_encoder_set_streamable_subset(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_channels(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_channels) then
    Result := _FLAC__stream_encoder_set_channels(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_bits_per_sample(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_bits_per_sample) then
    Result := _FLAC__stream_encoder_set_bits_per_sample(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_sample_rate(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_sample_rate) then
    Result := _FLAC__stream_encoder_set_sample_rate(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_compression_level(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_compression_level) then
    Result := _FLAC__stream_encoder_set_compression_level(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_blocksize(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_blocksize) then
    Result := _FLAC__stream_encoder_set_blocksize(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_do_mid_side_stereo(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_do_mid_side_stereo) then
    Result := _FLAC__stream_encoder_set_do_mid_side_stereo(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_loose_mid_side_stereo(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_loose_mid_side_stereo) then
    Result := _FLAC__stream_encoder_set_loose_mid_side_stereo(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_apodization(encoder: pFLAC__StreamEncoder; const specification: pcchar): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_apodization) then
    Result := _FLAC__stream_encoder_set_apodization(encoder, specification)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_max_lpc_order(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_max_lpc_order) then
    Result := _FLAC__stream_encoder_set_max_lpc_order(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_qlp_coeff_precision(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_qlp_coeff_precision) then
    Result := _FLAC__stream_encoder_set_qlp_coeff_precision(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_do_qlp_coeff_prec_search(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_do_qlp_coeff_prec_search) then
    Result := _FLAC__stream_encoder_set_do_qlp_coeff_prec_search(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_do_escape_coding(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_do_escape_coding) then
    Result := _FLAC__stream_encoder_set_do_escape_coding(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_do_exhaustive_model_search(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_do_exhaustive_model_search) then
    Result := _FLAC__stream_encoder_set_do_exhaustive_model_search(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_min_residual_partition_order(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_min_residual_partition_order) then
    Result := _FLAC__stream_encoder_set_min_residual_partition_order(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_max_residual_partition_order(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_max_residual_partition_order) then
    Result := _FLAC__stream_encoder_set_max_residual_partition_order(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_rice_parameter_search_dist(encoder: pFLAC__StreamEncoder; value: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_rice_parameter_search_dist) then
    Result := _FLAC__stream_encoder_set_rice_parameter_search_dist(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_total_samples_estimate(encoder: pFLAC__StreamEncoder; value: FLAC__uint64): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_total_samples_estimate) then
    Result := _FLAC__stream_encoder_set_total_samples_estimate(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_metadata(encoder : pFLAC__StreamEncoder;
  metadata : ppFLAC__StreamMetadata; num_blocks : cuint32) : FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_metadata) then
    Result := _FLAC__stream_encoder_set_metadata(encoder, metadata, num_blocks)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_set_limit_min_bitrate(encoder: pFLAC__StreamEncoder; value: FLAC__bool): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_set_limit_min_bitrate) then
    Result := _FLAC__stream_encoder_set_limit_min_bitrate(encoder, value)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_state(const encoder: pFLAC__StreamEncoder): FLAC__StreamEncoderState;
begin
  if Assigned(_FLAC__stream_encoder_get_state) then
    Result := _FLAC__stream_encoder_get_state(encoder)
  else
    Result := -1;
end;

function FLAC__stream_encoder_get_verify_decoder_state(const encoder: pFLAC__StreamEncoder): FLAC__StreamDecoderState;
begin
  if Assigned(_FLAC__stream_encoder_get_verify_decoder_state) then
    Result := _FLAC__stream_encoder_get_verify_decoder_state(encoder)
  else
    Result := -1;
end;

function FLAC__stream_encoder_get_resolved_state_string(const encoder: pFLAC__StreamEncoder): pcchar;
begin
  if Assigned(_FLAC__stream_encoder_get_resolved_state_string) then
    Result := _FLAC__stream_encoder_get_resolved_state_string(encoder)
  else
    Result := nil;
end;

procedure FLAC__stream_encoder_get_verify_decoder_error_stats(const encoder: pFLAC__StreamEncoder; absolute_sample: pFLAC__uint64; frame_number: pcuint32; channel: pcuint32; sample: pcuint32; expected: pFLAC__int32; got: pFLAC__int32);
begin
  if Assigned(_FLAC__stream_encoder_get_verify_decoder_error_stats) then
    _FLAC__stream_encoder_get_verify_decoder_error_stats(encoder, absolute_sample, frame_number, channel, sample, expected, got);
end;

function FLAC__stream_encoder_get_verify(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_verify) then
    Result := _FLAC__stream_encoder_get_verify(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_streamable_subset(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_streamable_subset) then
    Result := _FLAC__stream_encoder_get_streamable_subset(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_channels(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_channels) then
    Result := _FLAC__stream_encoder_get_channels(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_bits_per_sample(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_bits_per_sample) then
    Result := _FLAC__stream_encoder_get_bits_per_sample(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_sample_rate(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_sample_rate) then
    Result := _FLAC__stream_encoder_get_sample_rate(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_blocksize(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_blocksize) then
    Result := _FLAC__stream_encoder_get_blocksize(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_do_mid_side_stereo(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_do_mid_side_stereo) then
    Result := _FLAC__stream_encoder_get_do_mid_side_stereo(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_loose_mid_side_stereo(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_loose_mid_side_stereo) then
    Result := _FLAC__stream_encoder_get_loose_mid_side_stereo(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_max_lpc_order(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_max_lpc_order) then
    Result := _FLAC__stream_encoder_get_max_lpc_order(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_qlp_coeff_precision(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_qlp_coeff_precision) then
    Result := _FLAC__stream_encoder_get_qlp_coeff_precision(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_do_qlp_coeff_prec_search(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_do_qlp_coeff_prec_search) then
    Result := _FLAC__stream_encoder_get_do_qlp_coeff_prec_search(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_do_escape_coding(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_do_escape_coding) then
    Result := _FLAC__stream_encoder_get_do_escape_coding(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_do_exhaustive_model_search(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_do_exhaustive_model_search) then
    Result := _FLAC__stream_encoder_get_do_exhaustive_model_search(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_get_min_residual_partition_order(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_min_residual_partition_order) then
    Result := _FLAC__stream_encoder_get_min_residual_partition_order(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_max_residual_partition_order(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_max_residual_partition_order) then
    Result := _FLAC__stream_encoder_get_max_residual_partition_order(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_rice_parameter_search_dist(const encoder: pFLAC__StreamEncoder): cuint32;
begin
  if Assigned(_FLAC__stream_encoder_get_rice_parameter_search_dist) then
    Result := _FLAC__stream_encoder_get_rice_parameter_search_dist(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_total_samples_estimate(const encoder: pFLAC__StreamEncoder): FLAC__uint64;
begin
  if Assigned(_FLAC__stream_encoder_get_total_samples_estimate) then
    Result := _FLAC__stream_encoder_get_total_samples_estimate(encoder)
  else
    Result := 0;
end;

function FLAC__stream_encoder_get_limit_min_bitrate(const encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_get_limit_min_bitrate) then
    Result := _FLAC__stream_encoder_get_limit_min_bitrate(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_init_stream(encoder: pFLAC__StreamEncoder; write_callback: FLAC__StreamEncoderWriteCallback; seek_callback: FLAC__StreamEncoderSeekCallback; tell_callback: FLAC__StreamEncoderTellCallback; metadata_callback: FLAC__StreamEncoderMetadataCallback; client_data: pointer): FLAC__StreamEncoderInitStatus;
begin
  if Assigned(_FLAC__stream_encoder_init_stream) then
    Result := _FLAC__stream_encoder_init_stream(encoder, write_callback, seek_callback, tell_callback, metadata_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_encoder_init_ogg_stream(encoder: pFLAC__StreamEncoder; read_callback: FLAC__StreamEncoderReadCallback; write_callback: FLAC__StreamEncoderWriteCallback; seek_callback: FLAC__StreamEncoderSeekCallback; tell_callback: FLAC__StreamEncoderTellCallback; metadata_callback: FLAC__StreamEncoderMetadataCallback; client_data: pointer): FLAC__StreamEncoderInitStatus;
begin
  if Assigned(_FLAC__stream_encoder_init_ogg_stream) then
    Result := _FLAC__stream_encoder_init_ogg_stream(encoder, read_callback, write_callback, seek_callback, tell_callback, metadata_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_encoder_init_file(encoder: pFLAC__StreamEncoder; const filename: pcchar; progress_callback: FLAC__StreamEncoderProgressCallback; client_data: pointer): FLAC__StreamEncoderInitStatus;
begin
  if Assigned(_FLAC__stream_encoder_init_file) then
    Result := _FLAC__stream_encoder_init_file(encoder, filename, progress_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_encoder_init_ogg_file(encoder: pFLAC__StreamEncoder; const filename: pcchar; progress_callback: FLAC__StreamEncoderProgressCallback; client_data: pointer): FLAC__StreamEncoderInitStatus;
begin
  if Assigned(_FLAC__stream_encoder_init_ogg_file) then
    Result := _FLAC__stream_encoder_init_ogg_file(encoder, filename, progress_callback, client_data)
  else
    Result := -1;
end;

function FLAC__stream_encoder_finish(encoder: pFLAC__StreamEncoder): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_finish) then
    Result := _FLAC__stream_encoder_finish(encoder)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_process(encoder: pFLAC__StreamEncoder; const buffer: pFLAC__int32; samples: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_process) then
    Result := _FLAC__stream_encoder_process(encoder, buffer, samples)
  else
    Result := FLAC__false;
end;

function FLAC__stream_encoder_process_interleaved(encoder: pFLAC__StreamEncoder; const buffer: pFLAC__int32; samples: cuint32): FLAC__bool;
begin
  if Assigned(_FLAC__stream_encoder_process_interleaved) then
    Result := _FLAC__stream_encoder_process_interleaved(encoder, buffer, samples)
  else
    Result := FLAC__false;
end;

end.
