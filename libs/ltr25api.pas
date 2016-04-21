unit ltr25api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  // ���������� ������� ��� � ����� ������ LTR25
  LTR25_CHANNEL_CNT        = 8;
  // ���������� ������ �������������.
  LTR25_FREQ_CNT           = 8;
  // ���������� ������, ��� ������� ����������� ������������� ������������
  LTR25_CBR_FREQ_CNT       = 2;
  // ���������� �������� ��������� ����
  LTR25_I_SRC_VALUE_CNT    = 2;
  // ������ ���� � ��������� ������.
  LTR25_NAME_SIZE          = 8;
  // ������ ���� � �������� ������� ������.
  LTR25_SERIAL_SIZE        = 16;
  // ������������ ������� �������� � ������� ��� ��������� ��������� ������
  LTR25_ADC_RANGE_PEAK     = 10;
  // ��� ���, ��������������� ������������� �������� ��������
  LTR25_ADC_SCALE_CODE_MAX = 2000000000;

  // �����, � �������� ���������� ���������������� ������� flash-������
  LTR25_FLASH_USERDATA_ADDR  = $0;
  // ������ ���������������� ������� flash-������
  LTR25_FLASH_USERDATA_SIZE  = $100000;
  // ����������� ������ ����� ��� �������� flash-������. ��� �������� ��������
  //  ������ ���� ������ ������� �������
  LTR25_FLASH_ERASE_BLOCK_SIZE = 4096;


  { -------------- ���� ������, ����������� ��� LTR25 ------------------------}
  LTR25_ERR_FPGA_FIRM_TEMP_RANGE      = -10600; // ��������� �������� ���� ��� ��������� �������������� ���������
  LTR25_ERR_I2C_ACK_STATUS            = -10601; // ������ ������ ��� ��������� � ��������� ��� �� ���������� I2C
  LTR25_ERR_I2C_INVALID_RESP          = -10602; // �������� ����� �� ������� ��� ��������� � ��������� ��� �� ���������� I2C
  LTR25_ERR_INVALID_FREQ_CODE         = -10603; // ������� ����� ��� ������� ���
  LTR25_ERR_INVALID_DATA_FORMAT       = -10604; // ������� ����� ������ ������ ���
  LTR25_ERR_INVALID_I_SRC_VALUE       = -10605; // ������� ������ �������� ��������� ����
  LTR25_ERR_CFG_UNSUP_CH_CNT          = -10606; // ��� �������� ������� � ������� �� �������������� �������� ���������� ������� ���
  LTR25_ERR_NO_ENABLED_CH             = -10607; // �� ��� �������� �� ���� ����� ���
  LTR25_ERR_ADC_PLL_NOT_LOCKED        = -10608; // ������ ������� PLL ���
  LTR25_ERR_ADC_REG_CHECK             = -10609; // ������ �������� �������� ���������� ��������� ���
  LTR25_ERR_LOW_POW_MODE_NOT_CHANGED  = -10610; // �� ������� ��������� ��� ��/� ����������������� ���������
  LTR25_ERR_LOW_POW_MODE              = -10611; // ������ ��������� � ����������������� ������

  {------------------ ���� ������ �������������. -----------------------------}
  LTR25_FREQ_78K     = 0;     // 78.125 ���
  LTR25_FREQ_39K     = 1;     // 39.0625 ���
  LTR25_FREQ_19K     = 2;     // 19.53125 ���
  LTR25_FREQ_9K7     = 3;     // 9.765625 ���
  LTR25_FREQ_4K8     = 4;     // 4.8828125 ���
  LTR25_FREQ_2K4     = 5;     // 2.44140625 ���
  LTR25_FREQ_1K2     = 6;     // 1.220703125 ���
  LTR25_FREQ_610     = 7;     // 610.3515625 ��

  {------------------ ������� ������ �� ������ --------------------------------}
  LTR25_FORMAT_20   = 0; // 20-������ ������������� (1 ����� �� ������)
  LTR25_FORMAT_32   = 1; // 32-������ ������������� (2 ����� �� ������)

  {---------------------- �������� ��������� ����. ----------------------------}
  LTR25_I_SRC_VALUE_2_86   = 0; // 2.86 ��
  LTR25_I_SRC_VALUE_10     = 1; // 10 ��



  {------------------- �����, ����������� ���������� ������. ------------------}
  // �������, ��� ����� ��������� ���� ��� � ������
  LTR25_PROC_FLAG_VOLT         = $00000001;
  // �������, ��� ���� ��������� �� ����������� ������
  LTR25_PROC_FLAG_NONCONT_DATA = $00000100;


  {------------------- ��������� �������� ������. -----------------------------}
  LTR25_CH_STATUS_OK          = 0; // ����� � ������� ���������
  LTR25_CH_STATUS_SHORT       = 1; // ���� ���������� �������� ���������
  LTR25_CH_STATUS_OPEN        = 2; // ��� ��������� ������ ����


 type
  {$A4}
  { ��������� ������������� ������������ ��� ������ ��������� }
  TLTR25_CBR_COEF = record
    Offset : Single;  // ��� ��������
    Scale  : Single;  // ����������� ��������
  end;

  { ����� ������������� ��� ��������� ��� ������ }
  TLTR25_AFC_COEFS = record
    // ������� �������, ��� ������� ����� ��������� �������� �� FirCoef
    AfcFreq : Double;
    {   ����� ��������� ���������� ��������� ��������������� �������
         � �������� ��������� ��� ����. ������� ������������� � ������� �������
         �� AfcFreq ��� ������� ������ � ������� ��������� }
    FirCoef : Array [0..LTR25_CHANNEL_CNT-1] of Double;
  end;

  { ���������� � ������ }
  TINFO_LTR25 = record
    // �������� ������ ("LTR25")
    Name    : Array [0..LTR25_NAME_SIZE-1] of AnsiChar;
    // �������� ����� ������
    Serial  : Array [0..LTR25_SERIAL_SIZE-1] of AnsiChar;
    // ������ �������� ����
    VerFPGA : Word;
    // ������ �������� PLD
    VerPLD  : Byte;
    // ������� �����
    BoardRev : Byte;
    // �������, ��� �������������� ������� ������ ��� ���
    Industrial : LongBool;
    // ����������������� ����. ������ ����� 0
    Reserved : Array [1..8] of LongWord;
    { ������������� ������������ ������. ����������� �� Flash-������
        ������ ��� ������ LTR25_Open() ��� LTR25_GetConfig() � �����������
        � ���� ��� ���������� �� ����� ������ LTR25_SetADC() }
    CbrCoef : Array [0..LTR25_CHANNEL_CNT-1] of Array [0..LTR25_CBR_FREQ_CNT-1] of TLTR25_CBR_COEF;
    // ������������ ��� ��������� ��� ������
    AfcCoef : TLTR25_AFC_COEFS;
    // ��������� ����
    Reserved2 : array [0 .. (32*LTR25_CHANNEL_CNT - (LTR25_CHANNEL_CNT + 1) - 1)] of Double;
  end;

  // ��������� ������ ���.
  TLTR25_CHANNEL_CONFIG = record
    Enabled : LongBool; // �������, �������� �� ���� �� ������� ������
    Reserved : array [1..11] of LongWord;  // ��������� ���� (�� ������ ���������� �������������)
  end;

  // ��������� ������.
  TLTR25_CONFIG = record
    Ch : array [0..LTR25_CHANNEL_CNT-1] of TLTR25_CHANNEL_CONFIG; // ��������� ������� ���
    FreqCode : byte; // ���, �������� ��������� ������� ����� ���. ���� �� �������� #e_LTR25_FREQS
    DataFmt : byte;  //< ������, � ������� ����� ������������ ������� ��� �� ������. ���� �� �������� #e_LTR25_FORMATS.
    ISrcValue : byte; // ������������ �������� ��������� ����. ���� �� �������� #e_LTR25_I_SOURCES
    Reserved : array [1..50] of LongWord; // ��������� ���� (�� ������ ���������� �������������)
  end;

  // ��������� �������� ��������� ������.
  TLTR25_STATE = record
    FpgaState : byte;  //T������ ��������� ����. ���� �� �������� �� e_LTR_FPGA_STATE
    EnabledChCnt : byte;  //���������� ����������� �������. ��������������� ����� ������ LTR25_SetADC()
    Run : LongBool;   // �������, ������� �� ���� ������
    AdcFreq : double; // ������������� ������� ���. ����������� ����� ������ LTR25_SetADC()
    LowPowMode : LongBool; //< �������, ��������� �� ������ � ��������� ������� �����������. */
    Reserved : array [1..31] of LongWord; // ��������� ����
  end;

  PTLTR25_INTARNAL = ^TLTR25_INTARNAL;
  TLTR25_INTARNAL = record
  end;

  // ����������� ��������� ������.
  TLTR25 = record
    Size : Integer; // ������ ���������. ����������� � LTR25_Init().
    { ���������, ���������� ��������� ���������� � ���������� ltrd ��� LtrServer.
       �� ������������ �������� �������������. }
    Channel : TLTR;
    { ��������� �� ������������ ��������� � ����������� �����������,
      ������������� ������������� ����������� � ������������ ��� ������������. }
    Internal : PTLTR25_INTARNAL;
    // ��������� ������. ����������� ������������� ����� ������� LTR25_SetADC().
    Cfg : TLTR25_CONFIG;
    { ��������� ������ � ������������ ���������. ���� ���������� ���������
        ����������. ���������������� ���������� ����� ��������������
        ������ ��� ������. }
    State : TLTR25_STATE;
    { ���������� � ������ }
    ModuleInfo : TINFO_LTR25;
  end;

  pTLTR25=^TLTR25;

  {$A+}

  // ������������� ��������� ������
  Function LTR25_Init(out hnd: TLTR25) : Integer;
  // ���������� ���������� � �������.
  Function LTR25_Open(var hnd: TLTR25; net_addr : LongWord; net_port : Word;
                      csn: string; slot: Integer): Integer;
  // �������� ���������� � �������
  Function LTR25_Close(var hnd: TLTR25) : Integer;
  // ��������, ������� �� ���������� � �������.
  Function LTR25_IsOpened(var hnd: TLTR25) : Integer;
  // ������ �������� � ������
  Function LTR25_SetADC(var hnd: TLTR25) : Integer;

  // ������� � ����� ����� ������
  Function LTR25_Start(var hnd: TLTR25) : Integer;
  // ������� ������ ����� ������
  Function LTR25_Stop(var hnd: TLTR25) : Integer;

  // ����� ������ �� ������
  Function LTR25_Recv(var hnd: TLTR25; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR25_Recv(var hnd: TLTR25; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;

  // ��������� �������� �� ������ ����
  Function LTR25_ProcessData(var hnd: TLTR25; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out ch_status : array of LongWord): Integer; overload;
  Function LTR25_ProcessData(var hnd: TLTR25; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord): Integer; overload;

    // ����� ������ ������� �����.
  Function LTR25_SearchFirstFrame(var hnd : TLTR25; var data : array of LongWord;
                                size : LongWord; out index : LongWord) : Integer;

  // ��������� ��������� �� ������.
  Function LTR25_GetErrorString(err: Integer) : string;
  Function LTR25_GetConfig(var hnd : TLTR25) : Integer;

  // ������� ������ � ����� ������� �����������.
  Function LTR25_SetLowPowMode(var hnd: TLTR25; lowPowMode : LongBool) : Integer;
  // ��������, ��������� �� ������ ���� ������.
  Function LTR25_FPGAIsEnabled(var hnd: TLTR25; out enabled : LongBool) : Integer;
  // ���������� ������ ���� ������.
  Function LTR25_FPGAEnable(var hnd: TLTR25; enable : LongBool) : Integer;

  // ������ ������ �� flash-������ ������
  Function LTR25_FlashRead(var hnd: TLTR25; addr : LongWord; out data : array of byte; size : LongWord) : Integer;
  // ������ ������ �� flash-������ ������
  Function LTR25_FlashWrite(var hnd: TLTR25; addr : LongWord; var data : array of Byte; size : LongWord) : Integer;
  // �������� ������� flash-������ ������
  Function LTR25_FlashErase(var hnd: TLTR25; addr : LongWord; size : LongWord) : Integer;



  implementation

  Function _init(out hnd: TLTR25) : Integer;  {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_Init';
  Function _open(var hnd: TLTR25; net_addr : LongWord; net_port : Word; csn: PAnsiChar; slot: Integer) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_Open';
  Function _close(var hnd: TLTR25) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_Close';
  Function _is_opened(var hnd: TLTR25) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_IsOpened';
  Function _set_adc(var hnd: TLTR25) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_SetADC';
  Function _start(var hnd: TLTR25) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_Start';
  Function _stop(var hnd: TLTR25) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_Stop';

  Function _recv(var hnd: TLTR25; out data; out tmark; size: LongWord; tout : LongWord): Integer; {$I ltrapi_callconvention};  external 'ltr25api' name 'LTR25_Recv';
  Function _process_data(var hnd: TLTR25; var src; out dest; var size: Integer; flags : LongWord; out ch_status): Integer;  {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_ProcessData';

  // ���������� ������ � ����� ��� �������� ����������� ��������� ��� ������������
  Function _search_first_frame(var hnd : TLTR25; var data; size : LongWord; out index : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_SearchFirstFrame';

  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_GetErrorString';
  Function _get_config(var hnd : TLTR25) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_GetConfig';
  Function _set_low_pow_mode(var hnd: TLTR25; lowPowMode : LongBool) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_SetLowPowMode';
  Function _fpga_is_enabled(var hnd: TLTR25; out enabled : LongBool) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_FPGAIsEnabled';
  Function _fpga_enable(var hnd: TLTR25; enable : LongBool) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_FPGAEnable';
  Function _flash_read(var hnd: TLTR25; addr : LongWord; out data; size : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_FlashRead';
  Function _flash_write(var hnd: TLTR25; addr : LongWord; var data : array of Byte; size : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_FlashWrite';
  Function _flash_erase(var hnd: TLTR25; addr : LongWord; size : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr25api' name 'LTR25_FlashErase';


  Function LTR25_Init(out hnd: TLTR25) : Integer;
  begin
    LTR25_Init:=_init(hnd);
  end;

  Function LTR25_Close(var hnd: TLTR25) : Integer;
  begin
    LTR25_Close:=_close(hnd);
  end;

  Function LTR25_Open(var hnd: TLTR25; net_addr : LongWord; net_port : Word; csn: string; slot: Integer): Integer;
  begin
      LTR25_Open:=_open(hnd, net_addr, net_port, PAnsiChar(AnsiString(csn)), slot);
  end;

  Function LTR25_IsOpened(var hnd: TLTR25) : Integer;
  begin
    LTR25_IsOpened:=_is_opened(hnd);
  end;

  Function LTR25_SetADC(var hnd: TLTR25) : Integer;
  begin
    LTR25_SetADC:=_set_adc(hnd);
  end;

  Function LTR25_Start(var hnd: TLTR25) : Integer;
  begin
    LTR25_Start := _start(hnd);
  end;

  Function LTR25_Stop(var hnd: TLTR25) : Integer;
  begin
    LTR25_Stop:=_stop(hnd);
  end;

  Function LTR25_GetErrorString(err: Integer) : string;
  begin
     LTR25_GetErrorString:=string(_get_err_str(err));
  end;

  Function LTR25_Recv(var hnd: TLTR25; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR25_Recv:=_recv(hnd, data, tmark, size, tout);
  end;

  Function LTR25_Recv(var hnd: TLTR25; out data : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR25_Recv:=_recv(hnd, data, PLongWord(nil)^, size, tout);
  end;

  Function LTR25_ProcessData(var hnd: TLTR25; var src : array of LongWord; out dest : array of Double; var size: Integer;
                             flags : LongWord; out ch_status : array of LongWord): Integer;
  begin
     LTR25_ProcessData:=_process_data(hnd, src, dest, size, flags, ch_status);
  end;

  Function LTR25_ProcessData(var hnd: TLTR25; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord): Integer;
  begin
     LTR25_ProcessData:=_process_data(hnd, src, dest, size, flags, PLongWord(nil)^);
  end;

  Function LTR25_SearchFirstFrame(var hnd : TLTR25; var data : array of LongWord;
                                size : LongWord; out index : LongWord) : Integer;
  begin
      LTR25_SearchFirstFrame:=_search_first_frame(hnd, data, size, index);
  end;

  Function LTR25_GetConfig(var hnd : TLTR25) : Integer;
  begin
    LTR25_GetConfig:=_get_config(hnd);
  end;

  Function LTR25_SetLowPowMode(var hnd: TLTR25; lowPowMode : LongBool) : Integer;
  begin
    LTR25_SetLowPowMode:=_set_low_pow_mode(hnd, lowPowMode);
  end;

  Function LTR25_FPGAIsEnabled(var hnd: TLTR25; out enabled : LongBool) : Integer;
  begin
    LTR25_FPGAIsEnabled:=_fpga_is_enabled(hnd, enabled);
  end;

  Function LTR25_FPGAEnable(var hnd: TLTR25; enable : LongBool) : Integer;
  begin
    LTR25_FPGAEnable:=_fpga_enable(hnd, enable);
  end;

  Function LTR25_FlashRead(var hnd: TLTR25; addr : LongWord; out data : array of byte; size : LongWord) : Integer;
  begin
      LTR25_FlashRead:=_flash_read(hnd, addr, data, size);
  end;
  Function LTR25_FlashWrite(var hnd: TLTR25; addr : LongWord; var data : array of Byte; size : LongWord) : Integer;
  begin
      LTR25_FlashWrite:=_flash_write(hnd, addr, data, size);
  end;

  Function LTR25_FlashErase(var hnd: TLTR25; addr : LongWord; size : LongWord) : Integer;
  begin
    LTR25_FlashErase:=_flash_erase(hnd, addr, size);
  end;

end.
