unit ltr51api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;
const
    // минимальное чесло периодов дискр. в одном периоде измерения
    LTR51_BASE_VAL_MIN        = 70;
    // максимальная частота для дискретизации для модуля
    LTR51_FS_MAX              = 500000;
    // макс. количество каналов в модуле
    LTR51_CHANNEL_CNT         = 16;

    LTR51_THRESHOLD_RANGE_1_2V = 1;
    LTR51_THRESHOLD_RANGE_10V  = 0;

    LTR51_EDGE_MODE_RISE      = 0;
    LTR51_EDGE_MODE_FALL      = 1;

    // Коды ошибок
    LTR51_NO_ERR                            =0;
    LTR51_ERR_WRONG_MODULE_DESCR            =-5001;
    LTR51_ERR_CANT_OPEN                     =-5002;
    LTR51_ERR_CANT_LOAD_ALTERA              =-5003;
    LTR51_ERR_INVALID_CRATE_SN              =-5004;
    LTR51_ERR_INVALID_SLOT_NUM              =-5005;
    LTR51_ERR_CANT_SEND_COMMAND             =-5006;
    LTR51_ERR_CANT_RESET_MODULE             =-5007;
    LTR51_ERR_MODULE_NO_RESPONCE            =-5008;
    LTR51_ERR_CANT_OPEN_MODULE              =-5009;
    LTR51_ERR_PARITY_TO_MODULE              =-5010;
    LTR51_ERR_PARITY_FROM_MODULE            =-5011;
    LTR51_ERR_ALTERA_TEST_FAILED            =-5012;
    LTR51_ERR_CANT_START_DATA_AQC           =-5013;
    LTR51_ERR_CANT_STOP_DATA_AQC            =-5014;
    LTR51_ERR_CANT_SET_FS                   =-5015;
    LTR51_ERR_CANT_SET_BASE                 =-5016;
    LTR51_ERR_CANT_SET_EDGE_MODE            =-5017;
    LTR51_ERR_CANT_SET_THRESHOLD            =-5018;
    LTR51_WRONG_DATA                        =-5019;
    LTR51_ERR_WRONG_HIGH_THRESOLD_SETTINGS  =-5020;
    LTR51_ERR_WRONG_LOW_THRESOLD_SETTINGS   =-5021;
    LTR51_ERR_WRONG_FPGA_FILE               =-5022;
    LTR51_ERR_CANT_READ_ID_REC              =-5023;
    LTR51_ERR_WRONG_ID_REC                  =-5024;
    LTR51_ERR_WRONG_FS_SETTINGS             =-5025;
    LTR51_ERR_WRONG_BASE_SETTINGS           =-5026;
    LTR51_ERR_CANT_WRITE_EEPROM             =-5027;
    LTR51_ERR_CANT_READ_EEPROM              =-5028;
    LTR51_ERR_WRONG_EEPROM_ADDR             =-5029;
    LTR51_ERR_WRONG_THRESHOLD_VALUES        =-5030;
    LTR51_ERR_ERROR_OVERFLOW                =-5031;
    LTR51_ERR_MODULE_WRONG_ACQ_TIME_SETTINGS=-5032;
    LTR51_ERR_NOT_ENOUGH_POINTS             =-5033;
    LTR51_ERR_WRONG_SRC_SIZE                =-5034;

// Структура описания модуля
type

    {$A4}
    TINFO_LTR51=record
        Name:           array[0..15] of AnsiChar;
        Serial:         array[0..23] of AnsiChar;
        FirmwareVersion:array[0..7]  of AnsiChar; // Версия прошивки AVR
        FirmwareDate:   array[0..15] of AnsiChar; // Дата создания данной версии прошивки AVR
        FPGA_Version:   array[0..7]  of AnsiChar; // Версия прошивки ПЛИС
    end;

    PTINFO_LTR51=^TINFO_LTR51;

    TLTR51 = record
        size:       integer;              // размер структуры
        Channel:    TLTR;
        ChannelsEna:WORD;          // Маска доступных каналов (показывает, какие субмодули подкл.)
        SetUserPars:LongBool;          // Указывает, задаются ли Fs и Base пользователем
        LChQnt:integer;            // Количество логических каналов
        LChTbl:array[0..15]of LongWord;       // Таблица логических каналов
        Fs:double;                 // Частота выборки сэмплов
        Base:word;                 // Делитель частоты измерения
        F_Base:double;                    // Частота измерений F_Base=Fs/Base
        AcqTime:integer;           // Время сбора в миллисекундах
        TbaseQnt:integer;              // Количество периодов измерений, необходимое для обеспечения указанного интревала измерения
        ModuleInfo:TINFO_LTR51;
    end;
    pTLTR51=^TLTR51;              // Структура описания модуля

    {$A+}

    { Вариант реализации через var/out }
    Function LTR51_Init(out hnd: TLTR51):integer; overload;
    Function LTR51_Open(var hnd: TLTR51; net_addr : LongWord; net_port : Word;
                        csn: string; slot: integer; ttf_name: string): Integer; overload;
    Function LTR51_IsOpened(var hnd: TLTR51):integer; overload;
    Function LTR51_Close(var hnd: TLTR51):integer; overload;
    Function LTR51_CreateLChannel(PhysChannel:integer; var HighThreshold: double;
                                  var LowThreshold: double; ThresholdRange:integer;
                                  EdgeMode:integer):LongWord; overload;
    Function  LTR51_WriteEEPROM(var hnd: TLTR51; Address:integer; val:byte):integer; overload;
    Function  LTR51_ReadEEPROM(var hnd: TLTR51; Address:integer; out val:byte):integer; overload;
    Function  LTR51_Config(var hnd: TLTR51):integer; overload;
    Function  LTR51_Start(var hnd: TLTR51):integer; overload;
    Function  LTR51_Stop(var hnd: TLTR51):integer; overload;
     // Прием данных от модуля
    Function  LTR51_Recv(var hnd: TLTR51; out data : array of LongWord;
                        out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
    // Вариант без синхрометок
    Function  LTR51_Recv(var hnd: TLTR51; out data : array of LongWord; size: LongWord;
                          tout : LongWord): Integer; overload;

    Function  LTR51_ProcessData(var hnd: TLTR51; var src : array of LongWord;
                                out dest : array of LongWord; out Frequencies : array of Double;
                                var size: LongWord): LongInt; overload;
    //выриант без частот - если нужен только массив чисел N и M
    Function  LTR51_ProcessData(var hnd: TLTR51; var src : array of LongWord;
                              out dest : array of LongWord;
                              var size: LongWord): LongInt; overload;
    //вариант без массива N и M - если нужны только частоты
    Function  LTR51_ProcessData(var hnd: TLTR51; var src : array of LongWord;
                              out Frequencies : array of Double;
                              var size: LongWord): LongInt; overload;


    Function  LTR51_GetThresholdVals(var hnd: TLTR51; LChNumber:integer;
                                     out HighThreshold: Double;
                                     out LowThreshold:  Double; ThresholdRange:integer):integer; overload;
    Function  LTR51_CalcTimeOut     (var hnd: TLTR51; n:integer):LongWord; overload;

    Function  LTR51_GetErrorString  (err:integer):string;

{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
    { Старый вариант реализации через Pointer }
    Function  LTR51_Init            (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_Open            (hnd:pTLTR51; net_addrDWORD:LongWord; net_port:WORD; crate_snCHAR:POINTER; slot_num:integer; ttf_nameCHAR:PAnsiChar):integer;{$I ltrapi_callconvention}; overload;
    Function  LTR51_IsOpened        (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_Close           (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_WriteEEPROM     (hnd:pTLTR51; Address:integer; val:byte):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_ReadEEPROM      (hnd:pTLTR51; Address:integer; valBYTE:Pointer):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_CreateLChannel  (PhysChannel:integer; HighThresholdDOUBLE:Pointer; LowThresholdDOUBLE:Pointer; ThresholdRange:integer; EdgeMode:integer):LongWord;{$I ltrapi_callconvention}; overload;
    Function  LTR51_Config          (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_Start           (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_Stop            (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_Recv            (hnd:pTLTR51; dataDWORD:Pointer; tmarkDWORD:Pointer; size:LongWord; timeout:LongWord):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_ProcessData     (hnd:pTLTR51; srcDWORD:Pointer; destDWORD:Pointer; FrequencyDOUBLE:Pointer; sizeDWORD:pointer):integer; {$I ltrapi_callconvention}; overload;
    Function  LTR51_GetThresholdVals(hnd:pTLTR51; LChNumber:integer; HighThresholdDOUBLE:Pointer; LowThresholdDOUBLE:pointer; ThresholdRange:integer):integer;{$I ltrapi_callconvention}; overload;
    Function  LTR51_CalcTimeOut     (hnd:pTLTR51; n:integer):LongWord; {$I ltrapi_callconvention}; overload;
{$ENDIF}

implementation
  Function _init(out hnd: TLTR51):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_Init';
  Function _open(var hnd: TLTR51; net_addr : LongWord; net_port : Word; csn: PAnsiChar; slot: Integer; ttf_name : PAnsiChar) : Integer; {$I ltrapi_callconvention}; external 'ltr51api' name 'LTR51_Open';
  Function _is_opened(var hnd: TLTR51):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_IsOpened';
  Function _close(var hnd: TLTR51):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_Close';
  Function _write_eeprom(var hnd: TLTR51; Address:integer; val:byte):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_WriteEEPROM';
  Function _read_eeprom(var hnd: TLTR51; Address:integer; out val:byte):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_ReadEEPROM';
  Function _create_lchannel(PhysChannel:integer; var HighThreshold: double;
                               var LowThreshold: double; ThresholdRange:integer;
                               EdgeMode:integer):LongWord;{$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_CreateLChannel';
  Function  _config(var hnd: TLTR51):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_Config';
  Function  _start(var hnd: TLTR51):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_Start';
  Function  _stop(var hnd: TLTR51):integer; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_Stop';
  Function _recv(var hnd: TLTR51; out data; out tmark; size: LongWord; tout : LongWord): Integer; {$I ltrapi_callconvention};  external 'ltr51api' name 'LTR51_Recv';
  Function _process_data(var hnd: TLTR51; var src; out dest; out Frequency;
                                var size: LongWord): LongInt; {$I ltrapi_callconvention};  external 'ltr51api' name 'LTR51_ProcessData';
  Function  _get_threshold_vals(var hnd: TLTR51; LChNumber:integer;
                                     out HighThreshold: Double;
                                     out LowThreshold:  Double; ThresholdRange:integer):integer;{$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_GetThresholdVals';
  Function  _calc_timeout(var hnd: TLTR51; n:integer):LongWord; {$I ltrapi_callconvention}; overload; external 'ltr51api' name 'LTR51_CalcTimeOut';
  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr51api' name 'LTR51_GetErrorString';

{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
  Function  LTR51_Init            (hnd:pTLTR51):integer; overload; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_Open            (hnd:pTLTR51; net_addrDWORD:LongWord; net_port:WORD; crate_snCHAR:POINTER; slot_num:integer; ttf_nameCHAR:PAnsiChar):integer; overload; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_IsOpened        (hnd:pTLTR51):integer; overload; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_Close           (hnd:pTLTR51):integer; overload; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_WriteEEPROM     (hnd:pTLTR51; Address:integer; val:byte):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_ReadEEPROM      (hnd:pTLTR51; Address:integer; valBYTE:Pointer):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_CreateLChannel  (PhysChannel:integer; HighThresholdDOUBLE:Pointer; LowThresholdDOUBLE:Pointer; ThresholdRange:integer; EdgeMode:integer):LongWord; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_Config          (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_Start           (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_Stop            (hnd:pTLTR51):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_Recv            (hnd:pTLTR51; dataDWORD:Pointer; tmarkDWORD:Pointer; size:LongWord; timeout:LongWord):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_ProcessData     (hnd:pTLTR51; srcDWORD:Pointer; destDWORD:Pointer; FrequencyDOUBLE:Pointer; sizeDWORD:pointer):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_GetThresholdVals(hnd:pTLTR51; LChNumber:integer; HighThresholdDOUBLE:Pointer; LowThresholdDOUBLE:pointer; ThresholdRange:integer):integer; {$I ltrapi_callconvention}; external 'ltr51api';
  Function  LTR51_CalcTimeOut     (hnd:pTLTR51; n:integer):LongWord; {$I ltrapi_callconvention}; external 'ltr51api';
{$ENDIF}


  Function LTR51_Init(out hnd: TLTR51):integer; overload;
  begin
    LTR51_Init:=_init(hnd);
  end;
  Function LTR51_Open(var hnd: TLTR51; net_addr : LongWord; net_port : Word;
                      csn: string; slot: Integer; ttf_name : string): Integer;  overload;
  begin
      LTR51_Open:=_open(hnd, net_addr, net_port, PAnsiChar(AnsiString(csn)), slot, PAnsiChar(AnsiString(ttf_name)));
  end;

  Function LTR51_IsOpened(var hnd: TLTR51):integer; overload;
  begin
    LTR51_IsOpened := _is_opened(hnd);
  end;
  Function LTR51_Close(var hnd: TLTR51):integer; overload;
  begin
    LTR51_Close:=_close(hnd);
  end;
  Function LTR51_CreateLChannel(PhysChannel:integer; var HighThreshold: double;
                                var LowThreshold: double; ThresholdRange:integer;
                                EdgeMode:integer):LongWord; overload;
  begin
    LTR51_CreateLChannel:=_create_lchannel(PhysChannel, HighThreshold, LowThreshold, ThresholdRange, EdgeMode);
  end;
  Function  LTR51_WriteEEPROM(var hnd: TLTR51; Address:integer; val:byte):integer; overload;
  begin
    LTR51_WriteEEPROM:=_write_eeprom(hnd, address, val);
  end;
  Function  LTR51_ReadEEPROM(var hnd: TLTR51; Address:integer; out val:byte):integer; overload;
  begin
    LTR51_ReadEEPROM:=_read_eeprom(hnd, address, val);
  end;
  Function  LTR51_Config(var hnd: TLTR51):integer; overload;
  begin
    LTR51_Config:=_config(hnd);
  end;
  Function  LTR51_Start(var hnd: TLTR51):integer; overload;
  begin
    LTR51_Start:=_start(hnd);
  end;
  Function  LTR51_Stop(var hnd: TLTR51):integer; overload;
  begin
    LTR51_Stop:=_stop(hnd);
  end;
  Function LTR51_Recv(var hnd: TLTR51; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR51_Recv:=_recv(hnd, data, tmark, size, tout);
  end;

  Function LTR51_Recv(var hnd: TLTR51; out data : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR51_Recv:=_recv(hnd, data, PLongWord(nil)^, size, tout);
  end;

  Function  LTR51_ProcessData(var hnd: TLTR51; var src : array of LongWord;
                              out dest : array of LongWord; out Frequencies : array of Double;
                              var size: LongWord): LongInt;  overload;
  begin
    LTR51_ProcessData:=_process_data(hnd, src, dest, Frequencies, size);
  end;

  Function  LTR51_ProcessData(var hnd: TLTR51; var src : array of LongWord;
                              out dest : array of LongWord;
                              var size: LongWord): LongInt;  overload;
  begin
    LTR51_ProcessData:=_process_data(hnd, src, dest, PDouble(nil)^, size);
  end;

  Function  LTR51_ProcessData(var hnd: TLTR51; var src : array of LongWord;
                              out Frequencies : array of Double;
                              var size: LongWord): LongInt;  overload;
  begin
    LTR51_ProcessData:=_process_data(hnd, src, PLongWord(nil)^, Frequencies, size);
  end;

  Function  LTR51_GetThresholdVals(var hnd: TLTR51; LChNumber:integer;
                                     out HighThreshold: Double;
                                     out LowThreshold:  Double; ThresholdRange:integer):integer; overload;
  begin
    LTR51_GetThresholdVals:=_get_threshold_vals(hnd, LChNumber, HighThreshold, LowThreshold, ThresholdRange);
  end;

  Function  LTR51_CalcTimeOut     (var hnd: TLTR51; n:integer):LongWord; overload;
  begin
    LTR51_CalcTimeOut := _calc_timeout(hnd, n);
  end;

  Function LTR51_GetErrorString(err: Integer) : string;
  begin
     LTR51_GetErrorString:=string(_get_err_str(err));
  end;
end.















