unit ltr41api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;
const
// Коды ошибок
    LTR41_NO_ERR                                =0;
    LTR41_ERR_WRONG_MODULE_DESCR                =-7001;
    LTR41_ERR_CANT_OPEN                         =-7002;
    LTR41_ERR_INVALID_CRATE_SN                  =-7003;
    LTR41_ERR_INVALID_SLOT_NUM                  =-7004;
    LTR41_ERR_CANT_SEND_COMMAND                 =-7005;
    LTR41_ERR_CANT_RESET_MODULE                 =-7006;
    LTR41_ERR_MODULE_NO_RESPONCE                =-7007;
    LTR41_ERR_CANT_CONFIG                       =-7008;
    LTR41_ERR_CANT_LAUNCH_SEC_MARK              =-7009;
    LTR41_ERR_CANT_STOP_SEC_MARK                =-7010;
    LTR41_ERR_CANT_LAUNCH_START_MARK            =-7011;
    LTR41_ERR_LESS_WORDS_RECEIVED               =-7012;
    LTR41_ERR_PARITY_TO_MODULE                  =-7013;
    LTR41_ERR_PARITY_FROM_MODULE                =-7014;
    LTR41_ERR_WRONG_SECOND_MARK_CONF            =-7015;
    LTR41_ERR_WRONG_START_MARK_CONF             =-7016;
    LTR41_ERR_CANT_READ_DATA                    =-7017;
    LTR41_ERR_CANT_WRITE_EEPROM                 =-7018;
    LTR41_ERR_CANT_READ_EEPROM                  =-7019;
    LTR41_ERR_WRONG_EEPROM_ADDR                 =-7020;
    LTR41_ERR_CANT_READ_CONF_REC                =-7021;
    LTR41_ERR_WRONG_CONF_REC                    =-7022;
    LTR41_ERR_CANT_START_STREAM_READ            =-7023;
    LTR41_ERR_CANT_STOP_STREAM_READ             =-7024;
    LTR41_ERR_WRONG_IO_DATA                     =-7025;
    LTR41_ERR_WRONG_STREAM_READ_FREQ_SETTINGS   =-7026;
    LTR41_ERR_ERROR_OVERFLOW                    =-7027;

    LTR41_MARK_MODE_INTERNAL         = 0;
    LTR41_MARK_MODE_MASTER           = 1;
    LTR41_MARK_MODE_EXTERNAL         = 2;

    LTR41_EEPROM_SIZE                = 512;

type
{$A4}
// Структура описания модуля
TINFO_LTR41 = record
    Name  :array[0..15]of AnsiChar;
    Serial:array[0..23]of AnsiChar;
    FirmwareVersion:array[0..7]of AnsiChar;// Версия БИОСа
    FirmwareDate   :array[0..15]of AnsiChar;  // Дата создания данной версии БИОСа
end;

pTINFO_LTR41 = ^TINFO_LTR41;

TLTR41_Marks = record
    SecondMark_Mode:integer; // Режим меток. 0 - внутр., 1-внутр.+выход, 2-внешн
    StartMark_Mode:integer; //
end;

TLTR41 = record
    size:integer;   // размер структуры
    Channel:TLTR;
    StreamReadRate:double;
    Marks:TLTR41_Marks;  // Структура для работы с временными метками
    ModuleInfo:TINFO_LTR41;
end;

pTLTR41=^TLTR41;// Структура описания модуля

{$A+}

  Function  LTR41_Init            (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_Open            (module:pTLTR41; net_addr:LongWord;net_port:WORD; crate_snCHAR:Pointer; slot_num:integer):Integer; {$I ltrapi_callconvention};
  Function  LTR41_IsOpened        (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_Close           (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_ReadPort        (module:pTLTR41; InputDataDWORD:Pointer):Integer; {$I ltrapi_callconvention};
  Function  LTR41_StartStreamRead (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_StopStreamRead  (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_Recv            (module:pTLTR41; dataDWORD:Pointer;tmarkDWORD:Pointer;size:LongWord;timeout:LongWord):Integer; {$I ltrapi_callconvention};
  Function  LTR41_ProcessData     (module:pTLTR41; srcDWORD:Pointer;destDWORD:Pointer; sizeDWORD:Pointer):Integer; {$I ltrapi_callconvention};
  Function  LTR41_Config          (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_StartSecondMark (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_StopSecondMark  (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_GetErrorString  (err:integer):string; {$I ltrapi_callconvention};
  Function  LTR41_MakeStartMark   (module:pTLTR41):Integer; {$I ltrapi_callconvention};
  Function  LTR41_WriteEEPROM     (module:pTLTR41; Address:integer;val:byte):Integer; {$I ltrapi_callconvention};
  Function  LTR41_ReadEEPROM      (module:pTLTR41; Address:integer;valBYTE:Pointer):Integer; {$I ltrapi_callconvention};

implementation
  Function  LTR41_Init            (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_Open            (module:pTLTR41; net_addr:LongWord;net_port:WORD; crate_snCHAR:Pointer; slot_num:integer):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_IsOpened        (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_Close           (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_ReadPort        (module:pTLTR41; InputDataDWORD:Pointer):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_StartStreamRead (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_StopStreamRead  (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_Recv            (module:pTLTR41; dataDWORD:Pointer;tmarkDWORD:Pointer;size:LongWord;timeout:LongWord):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_ProcessData     (module:pTLTR41; srcDWORD:Pointer;destDWORD:Pointer; sizeDWORD:Pointer):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_Config          (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_StartSecondMark (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_StopSecondMark  (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_MakeStartMark   (module:pTLTR41):Integer; {$I ltrapi_callconvention}; external 'ltr41api';
  Function  LTR41_WriteEEPROM     (module:pTLTR41; Address:integer;val:byte):Integer; {$I ltrapi_callconvention};  external 'ltr41api';
  Function  LTR41_ReadEEPROM      (module:pTLTR41; Address:integer;valBYTE:Pointer):Integer; {$I ltrapi_callconvention}; external 'ltr41api';

  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr41api' name 'LTR41_GetErrorString';

  Function LTR41_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
  begin
     LTR41_GetErrorString:=string(_get_err_str(err));
  end;

end.