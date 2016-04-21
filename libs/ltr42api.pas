unit ltr42api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;
const
// Коды ошибок
    LTR42_NO_ERR                          =0;
    LTR42_ERR_WRONG_MODULE_DESCR          =-8001;
    LTR42_ERR_CANT_OPEN                   =-8002;
    LTR42_ERR_INVALID_CRATE_SN            =-8003;
    LTR42_ERR_INVALID_SLOT_NUM            =-8004;
    LTR42_ERR_CANT_SEND_COMMAND           =-8005;
    LTR42_ERR_CANT_RESET_MODULE           =-8006;
    LTR42_ERR_MODULE_NO_RESPONCE          =-8007;
    LTR42_ERR_CANT_SEND_DATA              =-8008;
    LTR42_ERR_CANT_CONFIG                 =-8009;
    LTR42_ERR_CANT_LAUNCH_SEC_MARK        =-8010;
    LTR42_ERR_CANT_STOP_SEC_MARK          =-8011;
    LTR42_ERR_CANT_LAUNCH_START_MARK      =-8012;
    LTR42_ERR_DATA_TRANSMISSON_ERROR      =-8013;
    LTR42_ERR_LESS_WORDS_RECEIVED         =-8014;
    LTR42_ERR_PARITY_TO_MODULE            =-8015;
    LTR42_ERR_PARITY_FROM_MODULE          =-8016;
    LTR42_ERR_WRONG_SECOND_MARK_CONF      =-8017;
    LTR42_ERR_WRONG_START_MARK_CONF       =-8018;
    LTR42_ERR_CANT_READ_DATA              =-8019;
    LTR42_ERR_CANT_WRITE_EEPROM           =-8020;
    LTR42_ERR_CANT_READ_EEPROM            =-8021;
    LTR42_ERR_WRONG_EEPROM_ADDR           =-8022;
    LTR42_ERR_CANT_READ_CONF_REC          =-8023;
    LTR42_ERR_WRONG_CONF_REC              =-8024;



    LTR42_MARK_MODE_INTERNAL         = 0;
    LTR42_MARK_MODE_MASTER           = 1;
    LTR42_MARK_MODE_EXTERNAL         = 2;

    LTR42_EEPROM_SIZE                = 512;


type
{$A4}
// Структура описания модуля
TINFO_LTR42 = record
    Name  :array[0..15]of AnsiChar;
    Serial:array[0..23]of AnsiChar;
    FirmwareVersion:array[0..7]of AnsiChar;// Версия БИОСа
    FirmwareDate   :array[0..15]of AnsiChar;  // Дата создания данной версии БИОСа
end;
pTINFO_LTR42 = ^TINFO_LTR42;

TLTR42_Marks = record
    SecondMark_Mode:integer; // Режим меток. 0 - внутр., 1-внутр.+выход, 2-внешн
    StartMark_Mode:integer; //
end;

TLTR42 = record
    Channel:TLTR;
    size:integer;   // размер структуры
    AckEna:boolean;
    Marks:TLTR42_Marks;  // Структура для работы с временными метками
    ModuleInfo:TINFO_LTR42;
end;
pTLTR42=^TLTR42;// Структура описания модуля

{$A+}

    Function  LTR42_Init            (module:pTLTR42):Integer; {$I ltrapi_callconvention};
    Function  LTR42_Open            (module:pTLTR42; net_addr:LongWord;net_port:WORD; crate_snCHAR:Pointer; slot_num:integer):Integer; {$I ltrapi_callconvention};
    Function  LTR42_Close           (module:pTLTR42):Integer; {$I ltrapi_callconvention};
    Function  LTR42_WritePort       (module:pTLTR42;OutputData:LongWord):Integer; {$I ltrapi_callconvention};
    Function  LTR42_WriteArray      (module:pTLTR42; OutputArrayDWORD:Pointer; ArraySize:byte):Integer; {$I ltrapi_callconvention};
    Function  LTR42_Config          (module:pTLTR42):Integer; {$I ltrapi_callconvention};
    Function  LTR42_StartSecondMark (module:pTLTR42):Integer; {$I ltrapi_callconvention};
    Function  LTR42_StopSecondMark  (module:pTLTR42):Integer; {$I ltrapi_callconvention};
    Function  LTR42_GetErrorString  (err:integer):string; {$I ltrapi_callconvention};
    Function  LTR42_MakeStartMark   (module:pTLTR42):Integer; {$I ltrapi_callconvention};
    Function  LTR42_WriteEEPROM     (module:pTLTR42; Address:integer;val:byte):Integer; {$I ltrapi_callconvention};
    Function  LTR42_ReadEEPROM      (module:pTLTR42;Address:integer;valBYTE:Pointer):Integer; {$I ltrapi_callconvention};
    Function  LTR42_IsOpened        (module:pTLTR42):Integer; {$I ltrapi_callconvention};

implementation
    Function  LTR42_Init            (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_Open            (module:pTLTR42; net_addr:LongWord;net_port:WORD; crate_snCHAR:Pointer; slot_num:integer):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_Close           (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_WritePort       (module:pTLTR42;OutputData:LongWord):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_WriteArray      (module:pTLTR42; OutputArrayDWORD:Pointer; ArraySize:byte):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_Config          (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_StartSecondMark (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_StopSecondMark  (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_MakeStartMark   (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_WriteEEPROM     (module:pTLTR42; Address:integer;val:byte):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_ReadEEPROM      (module:pTLTR42;Address:integer;valBYTE:Pointer):Integer; {$I ltrapi_callconvention}; external 'ltr42api';
    Function  LTR42_IsOpened        (module:pTLTR42):Integer; {$I ltrapi_callconvention}; external 'ltr42api';

    Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr42api' name 'LTR42_GetErrorString';

    Function LTR42_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
    begin
        LTR42_GetErrorString:=string(_get_err_str(err));
    end;



end.
