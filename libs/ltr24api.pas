unit ltr24api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  //  ������� ������ ����������.
  LTR24_VERSION_CODE            = $02000000;
  //  ���������� �������.
  LTR24_CHANNEL_NUM             = 4;
  // ���������� ���������� � ������ ���. �����.
  LTR24_RANGE_NUM               = 2;
  // ���������� ���������� � ������ ICP-�����.
  LTR24_ICP_RANGE_NUM           = 2;
  //  ���������� ������ �������������.
  LTR24_FREQ_NUM                = 16;
  //  ���������� �������� ��������� ����
  LTR24_I_SRC_VALUE_NUM         = 2;
  //  ������ ���� � ��������� ������.
  LTR24_NAME_SIZE               = 8;
  //  ������ ���� � �������� ������� ������.
  LTR24_SERIAL_SIZE             = 16;




  { -------------- ���� ������, ����������� ��� LTR24 ------------------------}
  LTR24_ERR_INVAL_FREQ        = -10100;
  LTR24_ERR_INVAL_FORMAT      = -10101;
  LTR24_ERR_CFG_UNSUP_CH_CNT  = -10102;
  LTR24_ERR_INVAL_RANGE       = -10103;
  LTR24_ERR_WRONG_CRC         = -10104;
  LTR24_ERR_VERIFY_FAILED     = -10105;
  LTR24_ERR_DATA_FORMAT       = -10106;
  LTR24_ERR_UNALIGNED_DATA    = -10107;
  LTR24_ERR_DISCONT_DATA      = -10108;
  LTR24_ERR_CHANNELS_DISBL    = -10109;
  LTR24_ERR_UNSUP_VERS        = -10110;
  LTR24_ERR_FRAME_NOT_FOUND   = -10111;  
  LTR24_ERR_UNSUP_FLASH_FMT   = -10116;
  LTR24_ERR_INVAL_I_SRC_VALUE = -10117;
  LTR24_ERR_UNSUP_ICP_MODE    = -10118;




  {------------------ ���� ������ �������������. -----------------------------}
  LTR24_FREQ_117K     = 0; // 117.1875 ���
  LTR24_FREQ_78K      = 1; // 78.125 ���
  LTR24_FREQ_58K      = 2; // 58.59375 ���
  LTR24_FREQ_39K      = 3; // 39.0625 ���
  LTR24_FREQ_29K      = 4; // 29.296875 ���
  LTR24_FREQ_19K      = 5; // 19.53125 ���
  LTR24_FREQ_14K      = 6; // 14.6484375 ���
  LTR24_FREQ_9K7      = 7; // 9.765625 ���
  LTR24_FREQ_7K3      = 8; // 7.32421875 ���
  LTR24_FREQ_4K8      = 9; // 4.8828125 ���
  LTR24_FREQ_3K6      = 10; // 3.662109375 ���
  LTR24_FREQ_2K4      = 11; // 2.44140625 ���
  LTR24_FREQ_1K8      = 12; // 1.8310546875 ���
  LTR24_FREQ_1K2      = 13; // 1.220703125 ���
  LTR24_FREQ_915      = 14; // 915.52734375 ��
  LTR24_FREQ_610      = 15; // 610.3515625 ��

  {---------------------- ���� ���������� � ������ ���. ����. -----------------}
  LTR24_RANGE_2       = 0; // +/-2 �
  LTR24_RANGE_10      = 1; // +/-10 �

  {---------------------- ���� ���������� � ������ ICP-����. ------------------}
  LTR24_ICP_RANGE_1   = 0; // ~1 �
  LTR24_ICP_RANGE_5   = 1; // ~5 �

  {---------------------- �������� ��������� ����. ----------------------------}
  LTR24_I_SRC_VALUE_2_86   = 0; // 2.86 ��
  LTR24_I_SRC_VALUE_10     = 1; // 10 ��

  {------------------------ ���� �������� ��������. ---------------------------}
  LTR24_FORMAT_20     = 0; // 20-������ ������
  LTR24_FORMAT_24     = 1; // 24-������ ������


  {------------------- �����, ����������� ���������� ������. ------------------}
  //�������, ��� ����� ��������� ������������� ������������
  LTR24_PROC_FLAG_CALIBR       = $00000001;
  // �������, ��� ����� ��������� ���� ��� � ������
  LTR24_PROC_FLAG_VOLT         = $00000002;
  // �������, ��� ���������� ��������� ��������� ���
  LTR24_PROC_FLAG_AFC_COR      = $00000004;
  // �������, ��� ���� ��������� �� ����������� ������
  LTR24_PROC_FLAG_NONCONT_DATA = $00000100;

 type
  {$A4}

  { ������������ ���-������� ��������� ��� }
  TLTR24_AFC_IIR_COEF = record
    a0 : Double;
    a1 : Double;
    b0 : Double;
  end;

  { ����� ������������� ��� ��������� ��� ������ }
  TLTR24_AFC_COEFS = record
    // ������� �������, ��� ������� ����� ��������� �������� �� FirCoef
    AfcFreq : Double;
    {   ����� ��������� ���������� ��������� ��������������� �������
         � �������� ��������� ��� ����. ������� ������������� � ������� �������
         �� AfcFreq ��� ������� ������ � ������� ��������� }
    FirCoef : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_RANGE_NUM-1] of Double;
    { @brief ������������ ���-������� ��� ��������� ��� ��� �� ��������
       #LTR24_FREQ_39K � ���� }
    AfcIirCoef : TLTR24_AFC_IIR_COEF;
  end;

  { ��������� ������������� ������������ ��� ������ ��������� }
  TLTR24_CBR_COEF = record
    Offset : Single;  // ��������
    Scale  : Single;  // ����������� ��������
  end;

  { ���������� � ������.

    �������� ���������� � ������. ��� ����������, ����� �������� �����
    SupportICP � VerPLD, ������� �� ��� ����-�� � ������������� ������
    ����� ������  LTR24_GetConfig(). }
  TINFO_LTR24 = record
    // �������� ������ ("LTR24")
    Name    : Array [0..LTR24_NAME_SIZE-1] of AnsiChar;
    // �������� ����� ������
    Serial  : Array [0..LTR24_SERIAL_SIZE-1] of AnsiChar;
    // ������ �������� ����.       
    VerPLD  : Byte;
    //  ������� ��������� ��������� � ICP ��������
    SupportICP : LongBool;
    Reserved : Array [1..8] of LongWord;
    //  ������ ��������� ������������� �������������.
    CalibCoef : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_RANGE_NUM-1] of Array [0..LTR24_FREQ_NUM-1] of TLTR24_CBR_COEF;
    // ������������ ��� ������������� ���.
    AfcCoef   : TLTR24_AFC_COEFS;
    // ���������� �������� ���������� ����� ��� ������� ������(������ ��� LTR24-2).
    ISrcVals  : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_I_SRC_VALUE_NUM-1] of Double;
  end;


  TLTR24_CHANNEL_MODE = record
    { ��������� ������. }
    Enable   : LongBool;
    { ��� ��������� ������.         *
      ��������������� ������ ����� �� ��������
      "LTR24_RANGE_*" ��� "LTR24_ICP_RANGE_* }
    Range    : Byte;
    { ����� ������� ���������� ������������ (TRUE -- �������).
      ����� �������� ������ ������ � ������, ���� ���� ICPMode ����� FALSE. }
    AC       : LongBool;
    { ��������� ������ ��������� ICP-��������
      ���� FALSE - ������������ ����� "���. ����" ��� "��������� ����"
                  (� ����������� �� ���� TestMode)
      ���� TRUE  - ����� "ICP" ��� "ICP ����" }
    ICPMode  : LongBool;
    { ������. ���� �� ������ ���������� ������������� }
    Reserved : Array [1..4] of LongWord;
  end;


  PTLTR24_INTARNAL = ^TLTR24_INTARNAL;
  TLTR24_INTARNAL = record
  end;

  { ����������� ��������� ������.

    ������ ������� ��������� ������, ���������� �
    ��� ���������, ��������� ������ �����. ���������� � ����������� �������
    ����������. ��������� ���� ��������� �������� ��� ��������� �������������
    ��� ��������� ���������� ������. ����� �������������� ������� �������������
    � ������� ������� LTR24_Init. }
  TLTR24 = record
    {  ������ ��������� TLTR24. ����������� ������������� ��� ������ ������� LTR24_Init. }
    Size        : Integer;
    {  ����� ����� � LTR ��������. }
    Channel     : TLTR;
    {  ������� ��������� ����� ������ (TRUE -- ���� ������ �������). }
    Run         : LongBool;
    {  ��� ������� �������������.
       ��������������� ������ ����� �� �������� @ref freqs "LTR24_FREQ_*".
       ��������������� �������������. }
    ADCFreqCode : Byte;
    {  �������� ������� ������������� � ��.
       ����������� ��������� ������� �������������, ��������������� ����
       � ���� ADCFreqCode, ����� ���������� ������� LTR24_SetADC. }
    ADCFreq     : double;
    {  ��� ������� ������.
       ��������������� ������ ����� �� �������� @ref formats "LTR24_FORMAT_*".
       ��������������� �������������. }
    DataFmt     : Byte;
    { �������� ��������� ���� ��� ���� ������� ����������� ICP-��������.
      ��������������� ������ ����� �� �������� @ref i_src_vals "LTR24_I_SRC_VALUE_*".
      ��������������� �������������. }
    ISrcValue   : Byte;
    {  ��������� �������� �������.
       �������� �������� ������ ("��������� ����" ��� "ICP-����" � ����������� ��
       �������� �������� ���� ICPMode ��� ������� ������)
       ��� ���� ������� (TRUE � �������).
       ��������������� �������������. }
    TestMode    : LongBool;
    { ������. ���� �� ������ ���������� ������������� }
    Reserved    : Array [1..16] of LongWord;
    { ��������� �������. }
    ChannelMode : Array [0..LTR24_CHANNEL_NUM-1] of TLTR24_CHANNEL_MODE;
    { ���������� � ������. }
    ModuleInfo : TINFO_LTR24;
    { ������ ������������ ������������� �������������.
      ����������� ��� ��������� ������ � ������� LTR24_ProcessData()
      ������������� ������������ �� ������� ������, ��������� � �������.
      ��� ������ LTR24_GetConfig() � ������ ���� ���������� ���������
      ������������� ������������ (�� ��, ��� � � ModuleInfo).
      ��, ��� �������������, ������������ ����� �������� � ������ ����
      ���� ������������. }
    CalibCoef : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_RANGE_NUM-1] of Array [0..LTR24_FREQ_NUM-1] of TLTR24_CBR_COEF;
    { ������������ ��� ������������� ���, ����������� � ������� LTR24_ProcessData().
      ��� ������ LTR24_GetConfig() ���� ���������� �������� �� ��� ������
      (�� ��, ��� � � ModuleInfo) }
    AfcCoef   : TLTR24_AFC_COEFS ;
    { ��������� �� ��������� � �����������, ������������� ������
      ����������� � ������������ ������������. }
    Internal  : PTLTR24_INTARNAL;
  end;

  pTLTR24=^TLTR24;

  {$A+}

  // ���������� ������� ������ ����������
  Function LTR24_GetVersion : LongWord;
  // ������������� ��������� ������
  Function LTR24_Init(out hnd: TLTR24) : Integer;
  // ���������� ���������� � �������.
  Function LTR24_Open(var hnd: TLTR24; net_addr : LongWord; net_port : Word;
                      csn: string; slot: Word): Integer;
  // �������� ���������� � �������
  Function LTR24_Close(var hnd: TLTR24) : Integer;
  // ��������, ������� �� ���������� � �������.
  Function LTR24_IsOpened(var hnd: TLTR24) : Integer;
  { ��������� ���������� �� ���� ������ ������ � ��������� ���� ModuleInfo �
    ����������� ��������� ������ }
  Function LTR24_GetConfig(var hnd: TLTR24) : Integer;
  // ������ �������� � ������
  Function LTR24_SetADC(var hnd: TLTR24) : Integer;

  // ������� � ����� ����� ������
  Function LTR24_Start(var hnd: TLTR24) : Integer;
  // ������� ������ ����� ������
  Function LTR24_Stop(var hnd: TLTR24) : Integer;

  { ������������ ������ ��� ���������� ����� ������.
    �������� ����� ��������� ������������ ����. }
  Function LTR24_SetZeroMode(var hnd : TLTR24; enable : LongBool) : Integer;

  { ������������ ������ ��� ���������� ����� ������.
    �������� ����� ��������� ���������� ������������ ��� ������� ������.
    ���������� ��� ������. }
  Function LTR24_SetACMode(var hnd : TLTR24;  chan : Byte; ac_mode : LongBool) : Integer;

  // ����� ������ �� ������
  Function LTR24_Recv(var hnd: TLTR24; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR24_Recv(var hnd: TLTR24; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR24_RecvEx(var hnd : TLTR24; out data : array of LongWord; out tmark : array of LongWord;
                        size : LongWord; timeout : LongWord; out time_vals: Int64): Integer;
  // ��������� �������� �� ������ ����
  Function LTR24_ProcessData(var hnd: TLTR24; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out ovload : array of LongBool): Integer; overload;
  Function LTR24_ProcessData(var hnd: TLTR24; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord): Integer; overload;

  // ��������� ��������� �� ������.
  Function LTR24_GetErrorString(err: Integer) : string;
  
  // ���������� ������ � ����� ��� �������� ����������� ��������� ��� ������������
  Function LTR24_FindFrameStart(var hnd : TLTR24; var data : array of LongWord;
                                size : Integer; out index : Integer) : Integer;


  implementation

  Function _get_version : LongWord; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_GetVersion';
  Function _init(out hnd: TLTR24) : Integer;  {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_Init';
  Function _open(var hnd: TLTR24; net_addr : LongWord; net_port : Word; csn: PAnsiChar; slot: Word) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_Open';
  Function _close(var hnd: TLTR24) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_Close';
  Function _is_opened(var hnd: TLTR24) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_IsOpened';
  Function _get_config(var hnd: TLTR24) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_GetConfig';
  Function _set_adc(var hnd: TLTR24) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_SetADC';
  Function _start(var hnd: TLTR24) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_Start';
  Function _stop(var hnd: TLTR24) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_Stop';
  Function _set_zero_mode(var hnd : TLTR24; enable : LongBool) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_SetZeroMode';
  Function _set_ac_mode(var hnd : TLTR24;  chan : Byte; ac_mode : LongBool) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_SetACMode';

  Function _recv(var hnd: TLTR24; out data; out tmark; size: LongWord; tout : LongWord): Integer; {$I ltrapi_callconvention};  external 'ltr24api' name 'LTR24_Recv';
  function _recv_ex(var hnd : TLTR24; out data; out tmark; size : LongWord; timeout : LongWord; out time_vals: Int64): Integer; {$I ltrapi_callconvention};  external 'ltr24api' name 'LTR24_RecvEx';
  Function _process_data(var hnd: TLTR24; var src; out dest; var size: Integer; flags : LongWord; out ovload): Integer;  {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_ProcessData';
  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_GetErrorString';

  
  // ���������� ������ � ����� ��� �������� ����������� ��������� ��� ������������
  Function priv_FindFrameStart(var hnd : TLTR24; var data; size : Integer; out index : Integer) : Integer; {$I ltrapi_callconvention}; external 'ltr24api' name 'LTR24_FindFrameStart';


  Function LTR24_GetVersion : LongWord;
  begin
    LTR24_GetVersion := _get_version;
  end;

  Function LTR24_Init(out hnd: TLTR24) : Integer;
  begin
    LTR24_Init := _init(hnd);
  end;

  Function LTR24_Open(var hnd: TLTR24; net_addr : LongWord; net_port : Word; csn: string; slot: Word): Integer;
  begin
      LTR24_Open:=_open(hnd, net_addr, net_port, PAnsiChar(AnsiString(csn)), slot);
  end;

  Function LTR24_Close(var hnd: TLTR24) : Integer;
  begin
    LTR24_Close := _close(hnd);
  end;
  Function LTR24_IsOpened(var hnd: TLTR24) : Integer;
  begin
    LTR24_IsOpened := _is_opened(hnd);
  end;
  Function LTR24_GetConfig(var hnd: TLTR24) : Integer;
  begin
    LTR24_GetConfig := _get_config(hnd);
  end;
  Function LTR24_SetADC(var hnd: TLTR24) : Integer;
  begin
    LTR24_SetADC := _set_adc(hnd);
  end;
  Function LTR24_Start(var hnd: TLTR24) : Integer;
  begin
    LTR24_Start := _start(hnd);
  end;
  Function LTR24_Stop(var hnd: TLTR24) : Integer;
  begin
    LTR24_Stop := _stop(hnd);
  end;
  Function LTR24_SetZeroMode(var hnd : TLTR24; enable : LongBool) : Integer;
  begin
    LTR24_SetZeroMode := _set_zero_mode(hnd, enable);
  end;
  Function LTR24_SetACMode(var hnd : TLTR24;  chan : Byte; ac_mode : LongBool) : Integer;
  begin
    LTR24_SetACMode := _set_ac_mode(hnd, chan, ac_mode);
  end;

  Function LTR24_GetErrorString(err: Integer) : string;
  begin
     LTR24_GetErrorString:=string(_get_err_str(err));
  end;

  Function LTR24_Recv(var hnd: TLTR24; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR24_Recv:=_recv(hnd, data, tmark, size, tout);
  end;

  Function LTR24_Recv(var hnd: TLTR24; out data : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR24_Recv:=_recv(hnd, data, PLongWord(nil)^, size, tout);
  end;

  Function LTR24_RecvEx(var hnd : TLTR24; out data : array of LongWord; out tmark : array of LongWord;
                        size : LongWord; timeout : LongWord; out time_vals: Int64) : Integer;
  begin
    LTR24_RecvEx:=_recv_ex(hnd, data, tmark, size, timeout, time_vals);
  end;

  Function LTR24_ProcessData(var hnd: TLTR24; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord;
                            out ovload : array of LongBool): Integer;
  begin
     LTR24_ProcessData:=_process_data(hnd, src, dest, size, flags, ovload);
  end;

  Function LTR24_ProcessData(var hnd: TLTR24; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord): Integer;
  begin
     LTR24_ProcessData:=_process_data(hnd, src, dest, size, flags, PLongWord(nil)^);
  end;

  Function LTR24_FindFrameStart(var hnd : TLTR24; var data : array of LongWord;
                                size : Integer; out index : Integer) : Integer;
  begin
      LTR24_FindFrameStart:= priv_FindFrameStart(hnd, data, size, index);
  end;
end.
