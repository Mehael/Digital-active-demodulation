unit ltr27api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;
const
    LTR27_ERROR_SEND_DATA           =-3000;
    LTR27_ERROR_RECV_DATA           =-3001;
    LTR27_ERROR_RESET_MODULE        =-3002;
    LTR27_ERROR_NOT_LTR27           =-3003;
    LTR27_ERROR_PARITY              =-3004;
    LTR27_ERROR_OVERFLOW            =-3005;
    LTR27_ERROR_INDEX               =-3006;
    LTR27_ERROR                     =-3007;
    LTR27_ERROR_EXCHANGE            =-3008;
    LTR27_ERROR_FORMAT              =-3008;
    LTR27_ERROR_CRC                 =-3010;
    LTR27_ERROR_EXCHANGE_RECIEVE    =-3011;
    LTR27_ERROR_EXCHANGE_SEND       =-3012;
    LTR27_ERROR_EXCHANGE_SIZE       =-3013;
    LTR27_ERROR_EXCHANGE_PARAM      =-3014;
    LTR27_ERROR_EXCHANGE_TIME       =-3015;
    LTR27_ERROR_EXCHANGE_ECHO       =-3016;


    LTR27_MEZZANINE_NUMBER          =8;

    LTR27_DATA_CORRECTION           =1 shl 0;
    LTR27_DATA_VALUE                =1 shl 1;
    // макросы для функций
    LTR27_MODULE_DESCRIPTION        =1 shl 0;
    LTR27_MEZZANINE1_DESCRIPTION    =1 shl 1;
    LTR27_MEZZANINE2_DESCRIPTION    =1 shl 2;
    LTR27_MEZZANINE3_DESCRIPTION    =1 shl 3;
    LTR27_MEZZANINE4_DESCRIPTION    =1 shl 4;
    LTR27_MEZZANINE5_DESCRIPTION    =1 shl 5;
    LTR27_MEZZANINE6_DESCRIPTION    =1 shl 6;
    LTR27_MEZZANINE7_DESCRIPTION    =1 shl 7;
    LTR27_MEZZANINE8_DESCRIPTION    =1 shl 8;

    LTR27_ALL_MEZZANINE_DESCRIPTION =510; //(все биты кроме LTR27_MODULE_DESCRIPTION)
    LTR27_ALL_DESCRIPTION           =511;//все биты


type
{$A4}
// Структура описания модуля
TINFO_LTR27=record
    Module:TDESCRIPTION_MODULE;
    Cpu:TDESCRIPTION_CPU;
    Mezzanine:array[0..LTR27_MEZZANINE_NUMBER-1]of TDESCRIPTION_MEZZANINE;
end;

TLTR27_Mezzanine=record
    Name :array[0..15]of AnsiChar;              // название субмодуля
    MUnit:array[0..15]of AnsiChar;              // измеряемая субмодулем физ.величина   в С это UNIT но в PASCAL это зарезервировано
    ConvCoeff:array[0..1]of double;          // масштаб и смещение для пересчета кода в физ.величину
    CalibrCoeff:array[0..3]of double;        // калибровочные коэффициенты
end;

TLTR27=record
  //**** служебная информация       //
  size:integer;
  Channel:TLTR;                     //
  subchannel:BYTE ;                 //
  //**** настройки модуля           //
  FrequencyDivisor:byte;            // делитель частоты дискретизации 0..255 (1000..4 Гц)
  Mezzanine:array[0..LTR27_MEZZANINE_NUMBER-1]of TLTR27_Mezzanine;// установленные мезонины
  ModuleInfo:TINFO_LTR27;
end;                           //
pTLTR27=^TLTR27;// Структура описания модуля

{$A+}


  // основные функции
  Function  LTR27_Init                (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_Open                (module:pTLTR27; saddrDWORD:LongWord; sport:WORD; csnCHAR:Pointer; cc:WORD):Integer; {$I ltrapi_callconvention};
  Function  LTR27_Close               (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_IsOpened            (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_Echo                (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_GetConfig           (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_SetConfig           (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_ADCStart            (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_ADCStop             (module:pTLTR27):Integer; {$I ltrapi_callconvention};
  Function  LTR27_Recv                (module:pTLTR27; dataDWORD:Pointer; tstampDWORD:Pointer; sizeDWORD:LongWord; timeoutDWORD:LongWord):Integer; {$I ltrapi_callconvention};
  Function  LTR27_ProcessData         (module:pTLTR27; src_dataDWORD:Pointer; dst_dataDouble:Pointer; sizeDWORD:Pointer; calibr:BOOLEAN; value:BOOLEAN):Integer; {$I ltrapi_callconvention};
  Function  LTR27_GetDescription      (module:pTLTR27; flags:WORD):Integer; {$I ltrapi_callconvention};
  Function  LTR27_WriteMezzanineDescr (module:pTLTR27; mn:BYTE):Integer; {$I ltrapi_callconvention};
  // функции вспомагательного характера
  Function  LTR27_GetErrorString(err:integer):string; {$I ltrapi_callconvention};
implementation
  // основные функции
  Function  LTR27_Init                (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_Open                (module:pTLTR27; saddrDWORD:LongWord; sport:WORD; csnCHAR:Pointer; cc:WORD):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_Close               (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_IsOpened            (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_Echo                (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_GetConfig           (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_SetConfig           (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_ADCStart            (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_ADCStop             (module:pTLTR27):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_Recv                (module:pTLTR27; dataDWORD:Pointer; tstampDWORD:Pointer; sizeDWORD:LongWord; timeoutDWORD:LongWord):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_ProcessData         (module:pTLTR27; src_dataDWORD:Pointer; dst_dataDouble:Pointer; sizeDWORD:Pointer; calibr:BOOLEAN; value:BOOLEAN):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_GetDescription      (module:pTLTR27; flags:WORD):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  Function  LTR27_WriteMezzanineDescr (module:pTLTR27; mn:BYTE):Integer; {$I ltrapi_callconvention}; external 'ltr27api';
  // функции вспомагательного характера

  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr27api' name 'LTR27_GetErrorString';

  Function LTR27_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
  begin
     LTR27_GetErrorString:=string(_get_err_str(err));
  end;
end.


