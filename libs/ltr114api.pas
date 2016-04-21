unit ltr114api;
interface
uses SysUtils, ltrapi, ltrapitypes;
const
   LTR114_CLOCK                  = 15000; // тактовая частота модуля в кГц
   LTR114_ADC_DIVIDER            = 1875;    //делитель частоты для АЦП
   LTR114_MAX_CHANNEL            = 16;    // Максимальное число физических каналов
   LTR114_MAX_R_CHANNEL          = 8;     //Максимальное число физических каналов для измерения сопротивлений
   LTR114_MAX_LCHANNEL           = 128;   // Максимальное число логических каналов
   LTR114_MID                    = $7272;   ////id модуля LTR114

   LTR114_ADC_RANGEQNT           = 3;     // количество диапазонов измерения напряжений
   LTR114_R_RANGEQNT             = 3;     // количество диапазонов измерения сопротивлений
   LTR114_SCALE_INTERVALS        = 3;
   LTR114_MAX_SCALE_VALUE        = 8000000; //код шкалы, соответствующий максимальному значению диапазона измерения

   //флаги для функции LTR114_ProcessData
   LTR114_PROCF_NONE             = $00;
   LTR114_PROCF_VALUE            = $01;   //признак необходимисти перевода кода в физические величины
   LTR114_PROCF_AVGR             = $02;   //признак необходимости осреднения двух измерений - +I и -I
   //коды диапазонов напряжений
   LTR114_URANGE_10              = 0;
   LTR114_URANGE_2               = 1;
   LTR114_URANGE_04              = 2;
   //коды диапазонов сопротивлений
   LTR114_RRANGE_400             = 0;
   LTR114_RRANGE_1200            = 1;
   LTR114_RRANGE_4000            = 2;

   //режимы коррекции данных
   LTR114_CORRECTION_MODE_NONE   = 0;
   LTR114_CORRECTION_MODE_INIT   = 1;
   LTR114_CORRECTION_MODE_AUTO   = 2;

   //режимы синхронизации
   LTR114_SYNCMODE_NONE          = 0;
   LTR114_SYNCMODE_INTERNAL      = 1;
   LTR114_SYNCMODE_MASTER        = 2;
   LTR114_SYNCMODE_EXTERNAL      = 4;

   //режимы проверки входов
   LTR114_CHECKMODE_X0Y0         = 1;
   LTR114_CHECKMODE_X5Y0         = 2;
   LTR114_CHECKMODE_X0Y5         = 4;
   LTR114_CHECKMODE_ALL          = 7;

   //коды стандартных режимов измерения
   LTR114_MEASMODE_U             = $00;
   LTR114_MEASMODE_R             = $20;
   LTR114_MEASMODE_NR            = $28;
   //коды специальных режимов коммутации
   LTR114_MEASMODE_NULL          = $10;     //измерение собственного нуля
   LTR114_MEASMODE_DAC12         = $11;     //измерение DAC1 - DAC2
   LTR114_MEASMODE_NDAC12        = $12;
   LTR114_MEASMODE_NDAC12_CBR    = $38;
   LTR114_MEASMODE_DAC12_CBR     = $30;

   LTR114_MEASMODE_DAC12_INTR      = $91;     //измерение DAC1 - DAC2 посередине интервала
   LTR114_MEASMODE_NDAC12_INTR     = $92;
   LTR114_MEASMODE_DAC12_INTR_CBR  = $B8;     //измерение DAC1 - DAC2 посередине интервала
   LTR114_MEASMODE_NDAC12_INTR_CBR = $B0;
   LTR114_MEASMODE_X0Y0            = $40;
   LTR114_MEASMODE_X5Y0            = $50;
   LTR114_MEASMODE_X0Y5            = $70;


   //коды дополнительных возможностей
   LTR114_FEATURES_STOPSW          = 1;   //использовать режим автокалибровки
   LTR114_FEATURES_THERM           = 2;   //термометр
   LTR114_FEATURES_CBR_DIS         = 4;   //запрет начальной калибровки
   LTR114_MANUAL_OSR               = 8;   //ручная установка OSR


   //настройки модуля по-умолчанию
   LTR114_DEF_DIVIDER              = 2;
   LTR114_DEF_INTERVAL             = 0;
   LTR114_DEF_OSR                  = 0;
   LTR114_DEF_SYNC_MODE            =LTR114_SYNCMODE_INTERNAL;

   //коды тестов модуля LTR114
   LTR114_TEST_INTERFACE           = 1;  //проверка интерфейса PC-LTR114
   LTR114_TEST_DAC                 = 2;  //проверка DAC
   LTR114_TEST_DAC1_VALUE          = 3;  //передача тестового значения для DAC1
   LTR114_TEST_DAC2_VALUE          = 4;  //передача тестового значения для DAC2
   LTR114_TEST_SELF_CALIBR         = 5;  //проведение измерения модулем себя для калибровки

   //параметры подтверждения проверки интерфейса PC-LTR114
   LTR114_TEST_INTERFACE_DATA_L    = $55;
   LTR114_TEST_INTERFACE_DATA_H    = $AA;


   // Коды ошибок, возвращаемые функциями библиотеки */
   LTR114_ERR_INVALID_DESCR        = -10000; // указатель на описатель модуля равен NULL
   LTR114_ERR_INVALID_SYNCMODE     = -10001; // недопустимый режим синхронизации модуля АЦП
   LTR114_ERR_INVALID_ADCLCHQNT    = -10002; // недопустимое количество логических каналов
   LTR114_ERR_INVALID_ADCRATE      = -10003; // недопустимое значение частоты дискретизации АЦП модуля
   LTR114_ERR_GETFRAME             = -10004; // ошибка получения кадра данных с АЦП
   LTR114_ERR_GETCFG               = -10005; // ошибка чтения конфигурации
   LTR114_ERR_CFGDATA              = -10006; // ошибка при получении конфигурации модуля
   LTR114_ERR_CFGSIGNATURE         = -10007; // неверное значение первого байта конфигурационной записи модуля
   LTR114_ERR_CFGCRC               = -10008; // неверная контрольная сумма конфигурационной записи
   LTR114_ERR_INVALID_ARRPOINTER   = -10009; // указатель на массив равен NULL
   LTR114_ERR_ADCDATA_CHNUM        = -10010; // неверный номер канала в массиве данных от АЦП
   LTR114_ERR_INVALID_CRATESN      = -10011; // указатель на строку с серийным номером крейта равен NULL
   LTR114_ERR_INVALID_SLOTNUM      = -10012; // недопустимый номер слота в крейте
   LTR114_ERR_NOACK                = -10013; // нет подтверждения от модуля
   LTR114_ERR_MODULEID             = -10014; // попытка открытия модуля, отличного от LTR114
   LTR114_ERR_INVALIDACK           = -10015; // неверное подтверждение от модуля
   LTR114_ERR_ADCDATA_SLOTNUM      = -10016; // неверный номер слота в данных от АЦП
   LTR114_ERR_ADCDATA_CNT          = -10017; // неверный счетчик пакетов в данных от АЦП
   LTR114_ERR_INVALID_LCH          = -10018; // неверный режим лог. канала
   LTR114_ERR_CORRECTION_MODE      = -10019; // неверный режим коррекции данных
   LTR114_ERR_GET_PLD_VER          = -10020; // ошибка при чтении версии ПЛИСа
   LTR114_ERR_ALREADY_RUN          = -10021; // ошибка при попытке запуска сбора данных когда он уже запущен
   LTR114_ERR_MODULE_CLOSED        = -10022; //

//================================================================================================*/
type
    {$A4}
    LTR114_GainSet = record
        Offset:double;                      // смещение нуля */
        Gain  :double;                      // масштабный коэффициент */
    end;

    LTR114_CbrCoef = record
        U: array[0..LTR114_ADC_RANGEQNT-1] of single;       //значения ИОН для диапазонов измерения напряжений
        I: array[0..LTR114_R_RANGEQNT-1]   of single;       //значения токов для диапазонов измерения сопротивлений
        UIntr: array[0..LTR114_ADC_RANGEQNT-1] of single;   //значение промежуточных напряжений
    end;


    TINFO_LTR114 = record
      Name   : array [0..7]  of AnsiChar;   // название модуля (строка)
      Serial : array [0..15] of AnsiChar;  // серийный номер модуля (строка)
      VerMCU : word;                  // версия ПО модуля (младший байт - минорная, старший - мажорная
      Date : array [0..13] of AnsiChar; // дата создания ПО (строка)                                       */
      VerPLD : byte;                            //версия прошивки ПЛИС
      CbrCoef : LTR114_CbrCoef;                 // заводские калибровочные коэффициенты */
    end;

    //
    TSCALE_LTR114 = record
        Null    : integer;        //значение нуля
        Ref     : integer;         //значение +шкала
        NRef    : integer;       //значение -шкала
        Interm  : integer;
        NInterm : integer;
    end;


     //информация о модуле
    TCBRINFO = record
        Coef : array [0..LTR114_SCALE_INTERVALS-1] of LTR114_GainSet;        //вычисленные на этапе автокалибровки значения Gain и Offset
        TempScale : ^TSCALE_LTR114;            //массив временных измерений шкалы/нуля
        Index : TSCALE_LTR114;          //количество измерений в TempScale
        LastVals : TSCALE_LTR114;       //последнее измерение

        HVal : integer;
        LVal : integer;
    end;


    //описатель логического канала
    LTR114_LCHANNEL = record
       MeasMode : byte;       //режим измерения
       Channel  : byte;       //физический канал
       Range    : byte;       //диапазон измерения*/
    end;

   //опистаель модуля LTR114
   TLTR114= record                     // информация о модуле LTR114
       size:integer;                           // размер структуры в байтах
       Channel:TLTR;                           // описатель канала связи с модулем
       AutoCalibrInfo: array[0..LTR114_ADC_RANGEQNT-1] of TCBRINFO; // данные для вычисления калибровочных коэф. для каждого диапазона
       LChQnt : integer;                              // количество активных логических каналов
       LChTbl : array[0..LTR114_MAX_LCHANNEL-1] of LTR114_LCHANNEL;        // управляющая таблица с настройками логических каналов

       Interval : word;                          //длина межкадрового интервала

       SpecialFeatures : byte;                   //дополнительные возможности модуля (подключение термометра, блокировка коммутации)
       AdcOsr : byte;                             //значение передискр. АЦП - вычисляется в соответствии с частотой дискретизации
       SyncMode : byte;                           //режим синхронизации

       FreqDivider : integer;                       // делитель частоты АЦП (2..8000)
                                           // частота дискретизации равна F = LTR114_CLOCK/(LTR114_ADC_DIVIDER*FreqDivider)

       FrameLength : integer;                       //размер данных, передаваемых модулем за один кадр
                                           //устанавливается после вызова LTR114_SetADC
       Active : boolean;                           //находится ли модуль в режиме сбора данных
       Reserve : integer;
       ModuleInfo : TINFO_LTR114;                 // информация о модуле LTR114
    end;
//================================================================================================*/
    pTLTR114=^TLTR114;
//================================================================================================*/
     {$A+}

Function LTR114_Init(hnd : pTLTR114) : integer; {$I ltrapi_callconvention};
Function LTR114_Open(hnd: pTLTR114; net_addr : LongWord; net_port: word; crate_snChar : Pointer; slot_num : integer) : integer; {$I ltrapi_callconvention};
Function LTR114_Close(hnd: pTLTR114) : integer; {$I ltrapi_callconvention};
Function LTR114_GetConfig(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_Calibrate(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_SetADC(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_Start(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_Stop(hnd: pTLTR114): integer; {$I ltrapi_callconvention};

Function LTR114_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};

Function LTR114_GetFrame(hnd: pTLTR114; bufDWORD : Pointer):integer; {$I ltrapi_callconvention};

Function LTR114_Recv(hnd: pTLTR114; dataDWORD : Pointer; tmarkDWORD : Pointer; size : LongWord; timeout : LongWord):integer; {$I ltrapi_callconvention};
Function LTR114_ProcessData(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; sizeINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention};
Function LTR114_ProcessDataTherm(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; thermDOUBLE : Pointer; sizeINT : Pointer; tcntINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention};

Function LTR114_CheckInputs(hnd: pTLTR114; ChannelsMask : integer; CheckMode : integer; res_dataDOUBLE : Pointer; sizeINT : Pointer):integer; {$I ltrapi_callconvention};

Function LTR114_SetRef(hnd: pTLTR114; range : integer; middle:boolean) :integer; {$I ltrapi_callconvention};
Function LTR114_GetDllVer() : word; {$I ltrapi_callconvention};

Function LTR114_CreateLChannel(MeasMode : integer; Channel : integer; Range: integer) : LTR114_LCHANNEL; {$I ltrapi_callconvention};


//================================================================================================*/
implementation
      Function LTR114_Init(hnd : pTLTR114) : integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Open(hnd: pTLTR114; net_addr : LongWord; net_port: word; crate_snChar : Pointer; slot_num : integer) : integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Close(hnd: pTLTR114) : integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_GetConfig(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Calibrate(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_SetADC(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Start(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Stop(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr114api' name 'LTR114_GetErrorString';

      Function LTR114_GetFrame(hnd: pTLTR114; bufDWORD : Pointer):integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_Recv(hnd: pTLTR114; dataDWORD : Pointer; tmarkDWORD : Pointer; size : LongWord; timeout : LongWord):integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_ProcessData(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; sizeINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_ProcessDataTherm(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; thermDOUBLE : Pointer; sizeINT : Pointer; tcntINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_CheckInputs(hnd: pTLTR114; ChannelsMask : integer; CheckMode : integer; res_dataDOUBLE : Pointer; sizeINT : Pointer):integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_SetRef(hnd: pTLTR114; range : integer; middle:boolean) :integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_GetDllVer() : word; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_CreateLChannel(MeasMode : integer; Channel : integer; Range: integer) : LTR114_LCHANNEL; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
      begin
        LTR114_GetErrorString:=string(_get_err_str(err));
      end;
end.
