unit ltr212api;
interface
uses SysUtils, ltrapi, ltrapitypes;
const
    // Коды ошибок. Описание см. ф-ю LRT212_GetErrorString()
    LTR212_NO_ERR=0;
    LTR212_ERR_INVALID_DESCR=               -2001;
    LTR212_ERR_INVALID_CRATE_SN=            -2002;
    LTR212_ERR_INVALID_SLOT_NUM=            -2003;
    LTR212_ERR_CANT_INIT=                   -2004;
    LTR212_ERR_CANT_OPEN_CHANNEL=           -2005;
    LTR212_ERR_CANT_CLOSE=                  -2006;
    LTR212_ERR_CANT_LOAD_BIOS=              -2007;
    LTR212_ERR_CANT_SEND_COMMAND=           -2008;
    LTR212_ERR_CANT_READ_EEPROM=            -2009;
    LTR212_ERR_CANT_WRITE_EEPROM=           -2010;
    LTR212_ERR_CANT_LOAD_IIR=               -2011;
    LTR212_ERR_CANT_LOAD_FIR=               -2012;
    LTR212_ERR_CANT_RESET_CODECS=           -2013;
    LTR212_ERR_CANT_SELECT_CODEC=           -2014;
    LTR212_ERR_CANT_WRITE_REG=              -2015;
    LTR212_ERR_CANT_READ_REG=               -2016;
    LTR212_ERR_WRONG_ADC_SETTINGS=          -2017;
    LTR212_ERR_WRONG_VCH_SETTINGS=          -2018;
    LTR212_ERR_CANT_SET_ADC=                -2019;
    LTR212_ERR_CANT_CALIBRATE=              -2020;
    LTR212_ERR_CANT_START_ADC=              -2021;
    LTR212_ERR_INVALID_ACQ_MODE=            -2022;
    LTR212_ERR_CANT_GET_DATA=               -2023;
    LTR212_ERR_CANT_MANAGE_FILTERS=         -2024;
    LTR212_ERR_CANT_STOP=                   -2025;
    LTR212_ERR_CANT_GET_FRAME=              -2026;
    LTR212_ERR_INV_ADC_DATA=                -2026;
    LTR212_ERR_TEST_NOT_PASSED=             -2027;
    LTR212_ERR_CANT_WRITE_SERIAL_NUM =      -2028;
    LTR212_ERR_CANT_RESET_MODULE =          -2029;
    LTR212_ERR_MODULE_NO_RESPONCE =         -2030;
    LTR212_ERR_WRONG_FLASH_CRC=             -2031;
    LTR212_ERR_CANT_USE_FABRIC_AND_USER_CALIBR_SYM=-2032;
    LTR212_ERR_CANT_START_INTERFACE_TEST=   -2033;
    LTR212_ERR_WRONG_BIOS_FILE=             -2034;
    LTR212_ERR_CANT_USE_CALIBR_MODE=        -2035;
    LTR212_ERR_PARITY_ERROR   =             -2036;
    LTR212_ERR_CANT_LOAD_CLB_COEFFS =       -2037;
    LTR212_ERR_CANT_LOAD_FABRIC_CLB_COEFFS =-2038;
    LTR212_ERR_CANT_GET_VER=                -2039;
    LTR212_ERR_CANT_GET_DATE=               -2040;
    LTR212_ERR_WRONG_SN =                   -2041;
    LTR212_ERR_CANT_EVAL_DAC=               -2042;
    LTR212_ERR_ERROR_OVERFLOW =             -2043;
    LTR212_ERR_SOME_CHENNEL_CANT_CLB      = -2044;
    LTR212_ERR_CANT_GET_MODULE_TYPE                             =-2045;
    LTR212_ERR_ERASE_OR_PROGRAM_FLASH                           =-2046;
    LTR212_ERR_CANT_SET_BRIDGE_CONNECTIONS                      =-2047;
    LTR212_ERR_CANT_SET_BRIDGE_CONNECTIONS_FOR_THIS_MODULE_TYPE =-2048;
    LTR212_ERR_QB_RESISTORS_IN_ALL_CHANNELS_MUST_BE_EQUAL       =-2049;

    LTR212_ERR_INVALID_EEPROM_ADDR                              =-2050;
    LTR212_ERR_INVALID_VCH_CNT                                  =-2051;
    LTR212_ERR_FILTER_FILE_OPEN                                 =-2052;
    LTR212_ERR_FILTER_FILE_READ                                 =-2053;
    LTR212_ERR_FILTER_FILE_FORMAT                               =-2054;
    LTR212_ERR_FILTER_ORDER                                     =-2055;
    LTR212_ERR_UNSUPPORTED_MODULE_TYPE                          =-2056;



    LTR212_LCH_CNT_MAX      = 8;  // Макс. число логических. каналов


    LTR212_FIR_ORDER_MAX    = 255; // Максимальное значение порядка КИХ-фильтра
    LTR212_FIR_ORDER_MIN    = 3;   // Минимальное значение порядка КИХ-фильтра


    // модификации модуля
    LTR212_OLD = 0;   // старый модуль с поддержкой полно- и полу-мостовых подключений
    LTR212_M_1 = 1;   // новый модуль с поддержкой полно-,  полу- и четверть-мостовых подключений
    LTR212_M_2 = 2;   // новый модуль с поддержкой полно- и полу-мостовых подключений

    // типы возможных мостов
    LTR212_FULL_OR_HALF_BRIDGE                          = 0;
    LTR212_QUARTER_BRIDGE_WITH_200_Ohm                  = 1;
    LTR212_QUARTER_BRIDGE_WITH_350_Ohm                  = 2;
    LTR212_QUARTER_BRIDGE_WITH_CUSTOM_Ohm               = 3;
    LTR212_UNBALANCED_QUARTER_BRIDGE_WITH_200_Ohm       = 4;
    LTR212_UNBALANCED_QUARTER_BRIDGE_WITH_350_Ohm       = 5;
    LTR212_UNBALANCED_QUARTER_BRIDGE_WITH_CUSTOM_Ohm    = 6;

    // режимы сбора данных (AcqMode)
    LTR212_ACQ_MODE_MEDIUM_PRECISION    = 0;
    LTR212_ACQ_MODE_HIGH_PRECISION      = 1;
    LTR212_ACQ_MODE_8CH_HIGH_PRECISION  = 2;



    // значения опорного напряжения
    LTR212_REF_2_5V = 0;  //2.5 В
    LTR212_REF_5V   = 1;   //5   В

    // диапазоны каналов
    LTR212_SCALE_B_10 = 0; // диапазон -10мВ/+10мВ
    LTR212_SCALE_B_20 = 1; // диапазон -20мВ/+20мВ
    LTR212_SCALE_B_40 = 2; // диапазон -40мВ/+40мВ
    LTR212_SCALE_B_80 = 3; // диапазон -80мВ/+80мВ
    LTR212_SCALE_U_10 = 4; // диапазон -10мВ/+10мВ
    LTR212_SCALE_U_20 = 5; // диапазон -20мВ/+20мВ
    LTR212_SCALE_U_40 = 6; // диапазон -40мВ/+40мВ
    LTR212_SCALE_U_80 = 7; // диапазон -80мВ/+80мВ

    // режимы калибровки
    LTR212_CALIBR_MODE_INT_ZERO             = 0;
    LTR212_CALIBR_MODE_INT_SCALE            = 1;
    LTR212_CALIBR_MODE_INT_FULL             = 2;
    LTR212_CALIBR_MODE_EXT_ZERO             = 3;
    LTR212_CALIBR_MODE_EXT_SCALE            = 4;
    LTR212_CALIBR_MODE_EXT_ZERO_INT_SCALE   = 5;
    LTR212_CALIBR_MODE_EXT_FULL_2ND_STAGE   = 6; // вторая стадия внешней калибровки
    LTR212_CALIBR_MODE_EXT_ZERO_SAVE_SCALE  = 7; // внешний ноль с сохранением до этого полученных коэф. масштаба



 //******** Определение структуры описания модуля *************/
type

{$A4}
    TINFO_LTR212 = record
        Name:       array[0..14] of AnsiChar;
        ModuleType: byte;
        Serial:     array[0..23] of AnsiChar;
        BiosVersion:array[0..7]  of AnsiChar; // Версия БИОСа
        BiosDate:   array[0..15] of AnsiChar;// Дата создания данной версии БИОСа
    end;

    TLTR212_Filter = record
        IIR:integer;         // Флаг использования БИХ-фильтра
        FIR:integer;         // Флаг использования КИХ-фильтра
        Decimation:integer;  // Значение коэффициента децимации для КИХ-фильтра
        TAP:integer;         // Порядок КИХ-фильтра
        IIR_Name:array[0..512] of AnsiChar; // Полный путь к файлу с коэфф-ми программного БИХ-фильтра
        FIR_Name:array[0..512] of AnsiChar; // Полный путь к файлу с коэфф-ми программного КИХ-фильтра
    end;

    TLTR212_Usr_Clb = record
        Offset   :array[0..LTR212_LCH_CNT_MAX-1]of LongWord;
        Scale    :array[0..LTR212_LCH_CNT_MAX-1]of LongWord;
        DAC_Value:array[0..LTR212_LCH_CNT_MAX-1]of byte;
    end;

    TLTR212 = record
        size:integer;
        Channel:TLTR;
        AcqMode:integer;     // Режим сбора данных
        UseClb:integer;      // Флаг использования калибровочных коэфф-тов
        UseFabricClb:integer;// Флаг использования заводских калибровочных коэфф-тов
        LChQnt:integer;      // Кол-во используемых виртуальных каналов
        LChTbl:array[0..LTR212_LCH_CNT_MAX-1]of integer;  //Таблица виртуальных каналов
        REF:integer;         // Флаг высокого опорного напряжения
        AC:integer;          // Флаг знакопеременного опорного напряжения
        Fs:double;           // Частота дискретизации АЦП

        filter:TLTR212_Filter;

        ModuleInfo:TINFO_LTR212;
        CRC_PM:Word; // для служебного пользования
        CRC_Flash_Eval:Word; // для служебного пользования
        CRC_Flash_Read:Word;   // для служебного пользования
    end;

    pTLTR212 = ^TLTR212;

    ltr212filter = record
       fs:double;
       decimation:byte;
       taps:byte;
       koeff:array[0..LTR212_FIR_ORDER_MAX-1]of Smallint;
    end;
{$A+}

// Доступные пользователю
Function LTR212_Init(module:pTLTR212):Integer; {$I ltrapi_callconvention};
Function LTR212_IsOpened(module:pTLTR212):Integer;{$I ltrapi_callconvention};
Function LTR212_Open(module:pTLTR212; net_addr:LongWord; net_port:WORD; crate_snCHAR:Pointer; slot_num:integer; biosnameCHAR:Pointer):Integer;{$I ltrapi_callconvention};
Function LTR212_Close(module:pTLTR212):Integer;{$I ltrapi_callconvention};
Function LTR212_CreateLChannel(PhysChannel:integer; Scale:integer):Integer;{$I ltrapi_callconvention};
Function LTR212_CreateLChannel2(PhysChannel:LongWord; Scale:LongWord; BridgeType:LongWord):Integer; {$I ltrapi_callconvention};

Function LTR212_SetADC(module:pTLTR212):Integer;{$I ltrapi_callconvention};
Function LTR212_Start(module:pTLTR212):Integer;{$I ltrapi_callconvention};
Function LTR212_Stop(module:pTLTR212):Integer;{$I ltrapi_callconvention};
Function LTR212_Recv(module:pTLTR212; dataDWORD:Pointer; tmarkDWORD:Pointer; size:LongWord; timeout:LongWord):Integer;{$I ltrapi_callconvention};
Function LTR212_ProcessData(module:pTLTR212; srcDWORD:Pointer;  destDOUBLE:Pointer; sizeDWORD:Pointer; volt:Boolean):Integer;{$I ltrapi_callconvention};
Function LTR212_Calibrate(module:pTLTR212; LChannel_MaskBYTE:pointer; mode:integer; reset:integer):Integer;{$I ltrapi_callconvention};
Function LTR212_CalcFS(module:pTLTR212; fsBaseDOUBLE:pointer; fs:pointer):Integer;{$I ltrapi_callconvention};
Function LTR212_TestEEPROM(module:pTLTR212):Integer;{$I ltrapi_callconvention};
// Вспомогательные функции
Function LTR212_ProcessDataTest(module:pTLTR212; srcDWORD:pointer;  destDOUBLE:Pointer; sizeDWORD:pointer; volt:boolean; bad_numDWORD:pointer):Integer;{$I ltrapi_callconvention};
Function LTR212_ReadFilter(fnameCHAR:Pointer; filter_ltr212filter:Pointer):Integer;{$I ltrapi_callconvention};
Function LTR212_WriteSerialNumber(module:pTLTR212; snCHAR:pointer; Code:WORD):Integer;{$I ltrapi_callconvention};
Function LTR212_TestInterfaceStart(module:pTLTR212; PackDelay:integer):Integer;{$I ltrapi_callconvention};
Function LTR212_CalcTimeOut(module:pTLTR212; n:LongWord):LongWord;{$I ltrapi_callconvention};

Function LTR212_ReadUSR_Clb (module:pTLTR212; CALLIBR:pointer):Integer;{$I ltrapi_callconvention};
Function LTR212_WriteUSR_Clb(module:pTLTR212; CALLIBR:pointer):Integer;{$I ltrapi_callconvention};

Function LTR212_GetErrorString(err:integer):string;{$I ltrapi_callconvention};


implementation
  Function LTR212_Init(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_IsOpened(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_Open(module:pTLTR212; net_addr:LongWord; net_port:WORD; crate_snCHAR:Pointer; slot_num:integer; biosnameCHAR:Pointer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_Close(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_CreateLChannel(PhysChannel:integer; Scale:integer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_CreateLChannel2(PhysChannel:LongWord; Scale:LongWord; BridgeType:LongWord):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_SetADC(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_Start(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_Stop(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_Recv(module:pTLTR212; dataDWORD:Pointer; tmarkDWORD:Pointer; size:LongWord; timeout:LongWord):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_ProcessData(module:pTLTR212; srcDWORD:Pointer;  destDOUBLE:Pointer; sizeDWORD:Pointer; volt:Boolean):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_Calibrate(module:pTLTR212; LChannel_MaskBYTE:pointer; mode:integer; reset:integer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_CalcFS(module:pTLTR212; fsBaseDOUBLE:pointer; fs:pointer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_TestEEPROM(module:pTLTR212):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  // Вспомогательные функции
  Function LTR212_ProcessDataTest(module:pTLTR212; srcDWORD:pointer;  destDOUBLE:Pointer; sizeDWORD:pointer; volt:boolean; bad_numDWORD:pointer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_ReadFilter(fnameCHAR:Pointer; filter_ltr212filter:Pointer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_WriteSerialNumber(module:pTLTR212; snCHAR:pointer; Code:WORD):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_TestInterfaceStart(module:pTLTR212; PackDelay:integer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_CalcTimeOut(module:pTLTR212; n:LongWord):LongWord; {$I ltrapi_callconvention}; external 'ltr212api';

  Function LTR212_ReadUSR_Clb (module:pTLTR212; CALLIBR:pointer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';
  Function LTR212_WriteUSR_Clb(module:pTLTR212; CALLIBR:pointer):Integer; {$I ltrapi_callconvention}; external 'ltr212api';

  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr212api' name 'LTR212_GetErrorString';

  Function LTR212_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
  begin
     LTR212_GetErrorString:=string(_get_err_str(err));
  end;
end.
