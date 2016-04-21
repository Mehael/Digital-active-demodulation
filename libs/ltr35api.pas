unit ltr35api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  // ������ ������ � ������ ������ � ��������� #TINFO_LTR35
  LTR35_NAME_SIZE             = 8;
  // ������ ������ � �������� ������� ������ � ��������� #TINFO_LTR35
  LTR35_SERIAL_SIZE           = 16;
  // ���������� ������� ���
  LTR35_DAC_CHANNEL_CNT       =  8;
  // ���������� ������� ��� ������� ������ ���
  LTR35_DAC_CH_OUTPUTS_CNT    = 2;
  // ������������ ���������� �������� �����
  LTR35_DOUT_LINES_MAX_CNT    = 16;
  // ����� ������, ��������������� ������ �� �������� ����� (���� ������� �� 0)
  LTR35_CH_NUM_DIGOUTS        = 8;
  // ������������ ���������� �������� � �������� ��� � ������ ������������ ��������������
  LTR35_MAX_POINTS_PER_PAGE   = (4*1024*1024);
  // ���������� �������������� �������������� ����������� � ������
  LTR35_ARITH_SRC_CNT         = 4;
  // ������������ �������� ������� �������������� ���, ������� ����� ����������
  LTR35_DAC_FREQ_MAX          = 192000;
  // ����������� �������� ������� �������������� ���, ������� ����� ����������
  LTR35_DAC_FREQ_MIN          = 72000;
  { ������� �������� ������� �������������� ���, ��� �������� �����������
    ��� ��������������� �������������� ������ }
  LTR35_DAC_FREQ_DEFAULT      = 192000;

  // ������������ �������� ����. ���������
  LTR35_ATTENUATION_MAX       = 119.5;
  // ������������ ��� ���
  LTR35_DAC_CODE_MAX          = $7FFFFF;
  // ��� ���, ��������������� ������������� �������� ��������� � �������
  LTR35_DAC_SCALE_CODE_MAX    = $600000;

  { ��������������� �� ��������� ���������� ����������� �������� ��� ������
    �������������� ������� � ��������� ������ }
  LTR35_STREAM_STATUS_PERIOD_DEFAULT  = 1024;
  { ������������ �������� ���������� �������� ��� ������
    �������������� ������� � ��������� ������ }
  LTR35_STREAM_STATUS_PERIOD_MAX      = 1024;
  { ����������� �������� ���������� �������� ��� ������
    �������������� ������� � ��������� ������ }
  LTR35_STREAM_STATUS_PERIOD_MIN      = 8;
  { �����, � �������� ���������� ���������������� ������� flash-������ }
  LTR35_FLASH_USERDATA_ADDR           = $100000;
  { ������ ���������������� ������� flash-������ }
  LTR35_FLASH_USERDATA_SIZE           = $700000;
  { ����������� ������ ����� ��� �������� �� flash-������ ������ }
  LTR35_FLASH_ERASE_BLOCK_SIZE        = 1024;

  { -------------- ���� ������, ����������� ��� LTR35 ------------------------}
  LTR35_ERR_INVALID_SYNT_FREQ             = -10200; // ������ ���������������� ������� �����������
  LTR35_ERR_PLL_NOT_LOCKED                = -10201; // ������ ������� PLL
  LTR35_ERR_INVALID_CH_SOURCE             = -10202; // ������ �������� �������� ��������� ������ ��� ������
  LTR35_ERR_INVALID_CH_RANGE              = -10203; // ������ �������� �������� ��������� ������
  LTR35_ERR_INVALID_DATA_FORMAT           = -10204; // ������ �������� �������� ������� ������
  LTR35_ERR_INVALID_MODE                  = -10205; // ������ �������� �������� ������ ������
  LTR35_ERR_INVALID_DAC_RATE              = -10206; // ������ �������� �������� �������� ������ �� ���
  LTR35_ERR_INVALID_SYNT_CNTRS            = -10207; // ������ ������������ �������� ��������� �����������
  LTR35_ERR_INVALID_ATTENUATION           = -10208; // ������ �������� �������� ������������ ��������� ������ ���
  LTR35_ERR_UNSUPPORTED_CONFIG            = -10209; // �������� ������������ ��� �� ��������������
  LTR35_ERR_INVALID_STREAM_STATUS_PERIOD  = -10210; // ������ �������� ���������� �������� ��� ������ ������� � ��������� ������
  LTR35_ERR_DAC_CH_NOT_PRESENT            = -10211; // ��������� ����� ��� ����������� � ������ ������
  LTR35_ERR_DAC_NO_SDRAM_CH_ENABLED       = -10212; // �� �������� �� ���� ����� ��� �� ����� �� SDRAM
  LTR35_ERR_DAC_DATA_NOT_ALIGNED          = -10213; // ������ ��� �� ��������� �� ���-�� ����������� �������
  LTR35_ERR_NO_DATA_LOADED                = -10214; // �� ���� ���������� �� ������ �������
  LTR35_ERR_LTRD_UNSUP_STREAM_MODE        = -10215; // ������ ������ ltrd/LtrServer �� ������������ ��������� ����� LTR35
  LTR35_ERR_MODE_UNSUP_FUNC               = -10216; // ������ ������� �� �������������� � ������������� ������
  LTR35_ERR_INVALID_ARITH_GEN_NUM         = -10217; // ������ �������� �������� ������ ��������������� ����������

  { --------- ����� ��� ���������� ��������� �������� ------------ }
  LTR35_DIGOUT_WORD_DIS_H = $00020000; { ���������� (������� � ������ ���������)
                                         ������� �������� �������� �������.
                                         ����� �������� ������ ��� LTR35-3. }
  LTR35_DIGOUT_WORD_DIS_L = $00010000;  { ���������� ������� �������� �������� ������� }


  { --------- ����� ��� ���������� ������. ----------------------- }
  LTR35_PREP_FLAGS_VOLT   = $00000001; { ���� ���������, ��� ������ �� �����
                                         ������� � ������� � �� ����� ��������� � ���� }

  { --------- ����� ��������� ������. ---------------------------- }
  LTR35_STATUS_FLAG_PLL_LOCK      = $0001; { ������� ������� PLL � ������ �������� �������.
                                             ���� ����� ����, �� ������ ����������������. }
  LTR35_STATUS_FLAG_PLL_LOCK_HOLD = $0002; { �������, ��� ������ PLL �� �������� � ������� ����������
                                             �������� �������. ������ ���� ���������� �� ���� ��������,
                                             ����� ������� }


  { ---------- ������ ������ ��� �������� ������ ������ ---------- }
  LTR35_FORMAT_24 = 0; // 24-������ ������. ���� ������ �������� ��� 32-������ ����� LTR
  LTR35_FORMAT_20 = 1; // 20-������ ������. ���� ������ �������� ���� 32-������ ����� LTR

  { ---------- ����� ������ ������ ------------------------------- }
  LTR35_MODE_CYCLE    = 0; { ����� ������������ ��������������. ������ �������������
                             � ����� ����� �������� ������, ����� ���� ��������
                             �� ����� ��� ��������. }
  LTR35_MODE_STREAM   = 1; { ��������� �����. ������ ��������� �������������
                             � ������� � �������� ��� ������� �� ����� }

  { ---------- ������������ ����� ��� ������ ��� ------------------ }
  LTR35_DAC_OUT_FULL_RANGE = 0;  { ����� 1:1 � ���������� �� -10 �� +10 ���
                                   LTR35-1 � �� -2 �� +20 ��� LTR35-2 }
  LTR35_DAC_OUT_DIV_RANGE  = 1;  { ����� 1:5 ��� LTR35-1 ��� ����� 1:10
                                    ��� LTR35-2 }

  { ---------- ��������� ������� ��� ������� ��� ------------------ }
  LTR35_CH_SRC_SDRAM = 0; { ������ ������� �� ������ � SDRAM ������.
                            ��� ���� ����� �������� ���������� ��� � ����
                             ������� � ����������� �� ������ }
  LTR35_CH_SRC_SIN1  = 1; { �����  �� ������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_COS1  = 2; { �������  �� ������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_SIN2  = 3; { �����  �� ������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_COS2  = 4; { �������  �� ������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_SIN3  = 5; { �����  �� �������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_COS3  = 6; { �������  �� �������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_SIN4  = 7; { �����  �� ���������� ��������������� ���������������
                             ���������� }
  LTR35_CH_SRC_COS4  = 8; {  �������  �� ���������� ��������������� ���������������
                             ���������� }

  { ------------ �������� ������ ������. -------------------------- }
  LTR35_DAC_RATE_DOUBLE = 1; // ������� �����������, �������� �� 384
  LTR35_DAC_RATE_QUAD   = 2; // ������� �����������, �������� �� 192

  { ------------ ����� ��� ������ �� flash-������ ������ ---------- }
  { �������, ��� ������������ ������� ������ ��� ������ � �� ���������
        ������������� ������� ����������� ������� }
   LTR35_FLASH_WRITE_ALREDY_ERASED = $00001;


   { ------------ ����������� ������ LTR35 ------------------------ }
    LTR35_MOD_UNKNOWN = 0; // ����������� (�� �������������� �����������) �����������
    LTR35_MOD_1 = 1;  // LTR35-1
    LTR35_MOD_2 = 2;  // LTR35-2
    LTR35_MOD_3 = 3;  // LTR35-3



  {$A4}
  { ������������� ������������ }
  type TLTR35_CBR_COEF = record
    Offset : Single; // ��� ��������
    Scale  : Single; // ����������� �����
  end;

  { �������� ������ ���. }
  type TLTR35_DAC_OUT_DESCR = record
    AmpMax : double; // ������������ ������� �������� ��������� ������� ��� ������� ������
    AmpMin : Double; // ����������� ������� �������� ��������� ������� ��� ������� ������ */
    CodeMax : Integer; //��� ���, ��������������� ������������ ���������
    CodeMin : Integer; // ��� ���, ��������������� ����������� ���������
    Reserved : array [0..2] of LongWord; // ��������� ����
  end;



  { ���������� � ������ }
  TINFO_LTR35 = record
    Name : Array [0..LTR35_NAME_SIZE-1] of AnsiChar; // �������� ������ (�������������� ����� ASCII-������)
    Serial : Array [0..LTR35_SERIAL_SIZE-1] of AnsiChar; //�������� ����� ������ (�������������� ����� ASCII-������)
    VerFPGA : Word;  // ������ �������� ���� ������ (������������� ������ ����� �� ��������)
    VerPLD : Byte; //������ �������� PLD
    Modification : Byte; // ����������� ������. ���� �� �������� �� #e_LTR35_MODIFICATION
    DacChCnt : Byte; // ���������� ������������� ������� ���
    DoutLineCnt : Byte; // ���������� ����� ��������� ������

    { �������� ���������� ������� ��� ������ ����������� ������ }
    DacOutDescr : array [0..LTR35_DAC_CH_OUTPUTS_CNT-1] of TLTR35_DAC_OUT_DESCR;
    Reserved1 : array [0..25] of LongWord; // ��������� ���� 
    { ��������� ������������� ������������ }
    CbrCoef : array [0..LTR35_DAC_CHANNEL_CNT-1] of array [0..LTR35_DAC_CH_OUTPUTS_CNT-1] of TLTR35_CBR_COEF;
    { �������������� ��������� ���� }
    Reserved2 : array [0..64*LTR35_DAC_CHANNEL_CNT*LTR35_DAC_CH_OUTPUTS_CNT-1] of LongWord;
  end;

  { ��������� ������ ��� }
   TLTR35_CHANNEL_CONFIG = record
    Enabled : Boolean; // ���������� ������ ������� ��� ������� ������
    Output : Byte;  // ������������ ����� ��� ������� ������ (�������� �� #e_LTR35_DAC_OUTPUT)
    Source : Byte;  // �������� ������ ��� ������� ������ (�������� �� #e_LTR35_CH_SRC)
    ArithAmp : Double; // ��������� ������� � ������ ��������������� ����������
    ArithOffs : Double; // �������� ������� � ������ ��������������� ����������
    Attenuation : Double; // ����������� ��������� � dB (�� 0 �� 119.5 � ����� 0.5)
    Reserved : array [0..7] of LongWord; // ��������� ����
  end;


  { ��������� ��������������� ����������. }
  TLTR35_ARITH_SRC_CONFIG = record
    Phase : Double; // ��������� ���� ������� � ��������
    Delta : Double; // ���������� ���� ������� ��� ������� ��������, ����������� �� ���, � ��������
    Reserved : array [0..31] of LongWord; // ��������� ����
  end;

  { ��������� �����������. }
  TLTR35_SYNT_CONFIG = record
    b : Word; // ����������� b � ���������� �����������
    r : Word; // ����������� r � ���������� �����������
    a : Byte; // ����������� a � ���������� �����������
  end;

  { ��������� ������. }
  TLTR35_CONFIG = record
    // ��������� ������� ���.
    Ch : array [0..LTR35_DAC_CHANNEL_CNT-1] of TLTR35_CHANNEL_CONFIG;
    // ��������� �������������� �����������.
    ArithSrc : array [0..LTR35_ARITH_SRC_CNT-1] of TLTR35_ARITH_SRC_CONFIG;

    Mode : Byte; // ����� ������ ������ (�������� �� #e_LTR35_MODE).
    DataFmt : Byte; // ������ ������ (�������� �� #e_LTR35_DATA_FORMAT).

    DacRate : Byte; { �������� ������ (��������� �� #e_LTR35_RATE).
                       ��� ������� ����������� � ������� ������� LTR35_FillFreq(). }
    Synt : TLTR35_SYNT_CONFIG; { ��������� �����������.
                                 ��� ������� ����������� � ������� ������� LTR35_FillFreq().}

    StreamStatusPeriod : Word; { ������ �������� ��������� ����. � ���������
                                  ������ ([Mode](@ref TLTR35_CONFIG::Mode)
                                  = #LTR35_MODE_STREAM) ��������� ����� �����
                                  ������������ ����� ������ ������
                                  StreamStatusPeriod ���� �� ������.
                                  0 �������� ����� �������� ��-���������. }
    EchoEnable : Byte;        {  ���������� �������� ���-������ �� ������
                                  ���������� ������. }
    EchoChannel : Byte;       {  ��� ����������� �������� ���-������ ����������
                                  ����� ������, �������� ����� ���������������
                                  ��� ������ }

    Reserved: Array [0..62] of LongWord;  // ��������� ���� (������ ���� ����������� � 0) 
  end;


  {  ��������� �������� ��������� ������. }
  TLTR35_STATE = record
    FpgaState : Byte; { ������� ��������� ����. ���� �� �������� �� e_LTR_FPGA_STATE }
    Run : Byte;       { �������, ������� �� ������ ����� �� ��� (� ��������� ������
                          ��� � ������ ������������ ��������������) }
    DacFreq : Double; { ������������� ������� ���. ����������� �����
                         ������ LTR35_Configure(). }
    EnabledChCnt : Byte; { ���������� ����������� ������� ���. ����������� �����
                               ������ LTR35_Configure(). }
    SDRAMChCnt : Byte;  { ���������� ����������� ������� ���, ������� ���
                             ������� ������� �� ������ ������. ����������� �����
                             ������ LTR35_Configure(). }
    ArithChCnt : Byte; { ���������� ����������� ������� ���, �����������
                             �� ����� ��������������� ����������. ����������� �����
                             ������ LTR35_Configure(). }
    Reserved : array [0..32-1] of LongWord; // ��������� ����
  end;

  PTLTR35_INTARNAL = ^TLTR35_INTARNAL;
  TLTR35_INTARNAL = record
  end;

  {  ����������� ��������� ������. }
  TLTR35 = record
    size : integer;      { ������ ���������. ����������� � LTR35_Init(). }
    Channel : TLTR;      { ���������, ���������� ��������� ���������� �
                           ltrd ��� LtrServer.
                           �� ������������ �������� �������������. }
    { ��������� �� ������������ ��������� � ����������� �����������,
      ������������� ������������� ����������� � ������������ ��� ������������. }
    Internal : PTLTR35_INTARNAL;
    Cfg : TLTR35_CONFIG;   { ��������� ������. ����������� �������������
                                ����� ������� LTR35_Configure() }
    { ��������� ������ � ������������ ���������. ���� ���������� ���������
      ����������. ���������������� ���������� ����� ��������������
      ������ ��� ������. }
    State : TLTR35_STATE;
    ModuleInfo : TINFO_LTR35; // ���������� � ������ 
  end;

  pTLTR35=^TLTR35;

  {$A+}


  // ������������� ��������� ������
  Function LTR35_Init(out hnd: TLTR35): Integer;
  // ���������� ���������� � �������.
  Function LTR35_Open(var hnd: TLTR35; net_addr : LongWord; net_port : LongWord;
                      csn: string; slot: Word): Integer;
  // �������� ���������� � �������
  Function LTR35_Close(var hnd: TLTR35): Integer;
  // ��������, ������� �� ���������� � �������.
  Function LTR35_IsOpened(var hnd: TLTR35): Integer;

  // ������ ������������� ��� ��������� �������� ������� �������������� ���.
  Function LTR35_FillFreq(out cfg: TLTR35_CONFIG; freq : Double; out fnd_freq: double): Integer; overload;
  Function LTR35_FillFreq(out cfg: TLTR35_CONFIG; freq : Double): Integer; overload;

  // ������ �������� � ������.
  Function LTR35_Configure(var hnd: TLTR35) : Integer;

  // �������� ������ ��� � �������� ������� � ������.
  Function LTR35_Send(var hnd: TLTR35; var data : array of LongWord; size : LongWord; timeout : LongWord) : Integer;

  // ���������� ������ ��� �������� � ������.
  Function LTR35_PrepareData(var hnd: TLTR35; var dac_data : array of Double;
                             var dac_size : LongWord;
                             var dout_data : array of LongWord;
                             var dout_size : LongWord;
                             flags : LongWord;
                             out result_data : array of LongWord;
                             var result_size : LongWord) : Integer;

  // ���������� ������ ��� ��� �������� � ������.
  Function LTR35_PrepareDacData(var hnd: TLTR35; var dac_data : array of Double;
                       size : LongWord; flags : LongWord;
                       var result_data : array of LongWord;
                       out result_size : LongWord) : Integer;

  //  ����� �������� ������ � ������ ������������ ��������������
  Function LTR35_SwitchCyclePage(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer;
  // ������ ������ ������ � ��������� ������.
  Function LTR35_StreamStart(var hnd: TLTR35; flags: LongWord): Integer;
  // ������� ������ ������.
  Function LTR35_Stop(var hnd: TLTR35; flags: LongWord): Integer;
  // ������� ������ ������ � �������� �������� �������� ������.
  Function LTR35_StopWithTout(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer;
  // ��������� ������� ��� ��������������� ����������.
  Function LTR35_SetArithSrcDelta(var hnd: TLTR35; gen_num: Byte; delta: double): Integer;
  // ��������� ��������� � �������� ��������������� �������.
  Function LTR35_SetArithAmp(var hnd: TLTR35; ch_num: Byte; amp: Double; offset: double): Integer;
  // ����� ���-������ �� ������.
  Function LTR35_RecvEchoResp(var hnd: TLTR35; out data : array of integer;
                              out tmark : array of Integer;
                              size : LongWord; timeout: LongWord): Integer;

  // ��������� ��������� �� ������.
  Function LTR35_GetErrorString(err: Integer) : string;
  // ��������, ��������� �� ������ ���� ������.
  Function LTR35_FPGAIsEnabled(var hnd: TLTR35; out enabled: LongBool): Integer;
  // ���������� ������ ���� ������.
  Function LTR35_FPGAEnable(var hnd: TLTR35; enable: LongBool): Integer;
  // ��������� ���������� � ��������� ������.
  Function LTR35_GetStatus(var hnd: TLTR35; out status : LongWord): Integer;

  // ������ ������ �� flash-������ ������
  Function LTR35_FlashRead(var hnd: TLTR35; addr: LongWord; out data : array of byte; size: LongWord): Integer;
  // ������ ������ �� flash-������ ������
  Function LTR35_FlashWrite(var hnd: TLTR35; addr: LongWord; var data : array of byte; size: LongWord; flags : LongWord): Integer;
  // �������� ������� flash-������ ������
  Function LTR35_FlashErase(var hnd: TLTR35; addr: LongWord; size: LongWord): Integer;



  implementation

  Function _init(out hnd: TLTR35): Integer;  {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_Init';
  Function _open(var hnd: TLTR35; net_addr : LongWord; net_port : LongWord; csn: PAnsiChar; slot: Word): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_Open';
  Function _close(var hnd: TLTR35): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_Close';
  Function _is_opened(var hnd: TLTR35): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_IsOpened';
  Function _fill_freq(out cfg: TLTR35_CONFIG; freq : Double; out fnd_freq: double): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_FillFreq';
  Function _configure(var hnd: TLTR35): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_Configure';
  Function _send(var hnd: TLTR35; var data; size: LongWord; timeout : LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_Send';
  Function _prepare_data(var hnd: TLTR35; var dac_data; var dac_size : LongWord;
                             var dout_data; var dout_size : LongWord; flags : LongWord;
                             out result; var snd_size : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_PrepareData';
  // ���������� ������ ��� ��� �������� � ������.
  Function _prepare_dac_data(var hnd: TLTR35; var dac_data; size : LongWord;
                        flags : LongWord; var result; out snd_size : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_PrepareDacData';

  Function _switch_cycle_page(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_SwitchCyclePage';
  Function _stream_start(var hnd: TLTR35; flags: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_StreamStart';
  Function _stop(var hnd: TLTR35; flags: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_Stop';
  Function _stop_with_tout(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_StopWithTout';
  Function _set_arith_src_delta(var hnd: TLTR35; gen_num: Byte; delta: double): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_SetArithSrcDelta';
  Function _set_arith_amp(var hnd: TLTR35; ch_num: Byte; amp: Double; offset: double): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_SetArithAmp';

  Function _recv_echo_resp(var hnd: TLTR35; out data; out tmark; size : LongWord;
                           timeout: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_RecvEchoResp';

  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_GetErrorString';

  Function _fpga_is_enabled(var hnd: TLTR35; out enabled: LongBool): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_FPGAIsEnabled';
  Function _fpga_enable(var hnd: TLTR35; enable: LongBool): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_FPGAEnable';
  Function _get_status(var hnd: TLTR35; out status : LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_GetStatus';


  Function _flash_read(var hnd: TLTR35; addr: LongWord; out data; size: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_FlashRead';
  Function _flash_write(var hnd: TLTR35; addr: LongWord; var data : array of byte; size: LongWord; flags : LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_FlashWrite';
  Function _flash_erase(var hnd: TLTR35; addr: LongWord; size: LongWord): Integer; {$I ltrapi_callconvention}; external 'ltr35api' name 'LTR35_FlashErase';




  Function LTR35_Init(out hnd: TLTR35): Integer;
  begin
    LTR35_Init:=_init(hnd);
  end;

  Function LTR35_Open(var hnd: TLTR35; net_addr : LongWord; net_port : LongWord; csn: string; slot: Word): Integer;
  begin
    LTR35_Open:=_open(hnd, net_addr, net_port, PAnsiChar(AnsiString(csn)), slot);
  end;

  Function LTR35_Close(var hnd: TLTR35): Integer;
  begin
    LTR35_Close:=_close(hnd);
  end;
  Function LTR35_IsOpened(var hnd: TLTR35): Integer;
  begin
    LTR35_IsOpened:=_is_opened(hnd);
  end;
  Function LTR35_FillFreq(out cfg: TLTR35_CONFIG; freq : Double; out fnd_freq: double): Integer; overload;
  begin
    LTR35_FillFreq:=_fill_freq(cfg, freq, fnd_freq);
  end;
  Function LTR35_FillFreq(out cfg: TLTR35_CONFIG; freq : Double): Integer; overload;
  begin
    LTR35_FillFreq:=LTR35_FillFreq(cfg, freq, PDouble(nil)^);
  end;

  Function LTR35_Configure(var hnd: TLTR35) : Integer;
  begin
    LTR35_Configure:=_configure(hnd);
  end;

  Function LTR35_Send(var hnd: TLTR35; var data : array of LongWord; size : LongWord; timeout : LongWord) : Integer;
  begin
    LTR35_Send:=_send(hnd, data, size, timeout);
  end;

  Function LTR35_PrepareData(var hnd: TLTR35; var dac_data : array of Double;
                             var dac_size : LongWord;
                             var dout_data : array of LongWord;
                             var dout_size : LongWord;
                             flags : LongWord;
                             out result_data : array of LongWord;
                             var result_size : LongWord) : Integer;
  begin
    LTR35_PrepareData:=_prepare_data(hnd, dac_data, dac_size, dout_data, dout_size, flags, result_data, result_size);
  end;

  // ���������� ������ ��� ��� �������� � ������.
  Function LTR35_PrepareDacData(var hnd: TLTR35; var dac_data : array of Double;
                       size : LongWord; flags : LongWord;
                       var result_data : array of LongWord;
                       out result_size : LongWord) : Integer;
  begin
    LTR35_PrepareDacData:=_prepare_dac_data(hnd, dac_data, size, flags, result_data, result_size);
  end;

  Function LTR35_SwitchCyclePage(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer;
  begin
    LTR35_SwitchCyclePage:=_switch_cycle_page(hnd, flags, tout);
  end;
  Function LTR35_StreamStart(var hnd: TLTR35; flags: LongWord): Integer;
  begin
    LTR35_StreamStart:=_stream_start(hnd, flags);
  end;
  Function LTR35_Stop(var hnd: TLTR35; flags: LongWord): Integer;
  begin
    LTR35_Stop:=_stop(hnd, flags);
  end;
  Function LTR35_StopWithTout(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer;
  begin
    LTR35_StopWithTout:=_stop_with_tout(hnd, flags, tout);
  end;
  Function LTR35_SetArithSrcDelta(var hnd: TLTR35; gen_num: Byte; delta: double): Integer;
  begin
    LTR35_SetArithSrcDelta:=_set_arith_src_delta(hnd, gen_num, delta);
  end;
  Function LTR35_SetArithAmp(var hnd: TLTR35; ch_num: Byte; amp: Double; offset: double): Integer;
  begin
    LTR35_SetArithAmp:=_set_arith_amp(hnd, ch_num, amp, offset);
  end;

  Function LTR35_RecvEchoResp(var hnd: TLTR35; out data : array of integer;
                              out tmark : array of Integer;
                              size : LongWord; timeout: LongWord): Integer;
  begin
    LTR35_RecvEchoResp:=_recv_echo_resp(hnd, data, tmark, size, timeout);
  end;

  function LTR35_GetErrorString(err: Integer) : string;
  begin
     LTR35_GetErrorString:=string(_get_err_str(err));
  end;

  Function LTR35_FPGAIsEnabled(var hnd: TLTR35; out enabled: LongBool): Integer;
  begin
    LTR35_FPGAIsEnabled:=_fpga_is_enabled(hnd, enabled);
  end;
  Function LTR35_FPGAEnable(var hnd: TLTR35; enable: LongBool): Integer;
  begin
    LTR35_FPGAEnable:=_fpga_enable(hnd, enable);
  end;
  Function LTR35_GetStatus(var hnd: TLTR35; out status : LongWord): Integer;
  begin
    LTR35_GetStatus:=_get_status(hnd, status);
  end;
  Function LTR35_FlashRead(var hnd: TLTR35; addr: LongWord; out data : array of byte; size: LongWord): Integer;
  begin
    LTR35_FlashRead:=_flash_read(hnd, addr, data, size);
  end;
  Function LTR35_FlashWrite(var hnd: TLTR35; addr: LongWord; var data : array of byte; size: LongWord; flags : LongWord): Integer;
  begin
    LTR35_FlashWrite:=_flash_write(hnd, addr, data, size, flags);
  end;
  Function LTR35_FlashErase(var hnd: TLTR35; addr: LongWord; size: LongWord): Integer;
  begin
    LTR35_FlashErase:=_flash_erase(hnd, addr, size);
  end;
end.
