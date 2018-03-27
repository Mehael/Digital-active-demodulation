unit ltr24api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  //  Текущая версия библиотеки.
  LTR24_VERSION_CODE            = $02000000;
  //  Количество каналов.
  LTR24_CHANNEL_NUM             = 4;
  // Количество диапазонов в режиме диф. входа.
  LTR24_RANGE_NUM               = 2;
  // Количество диапазонов в режиме ICP-входа.
  LTR24_ICP_RANGE_NUM           = 2;
  //  Количество частот дискретизации.
  LTR24_FREQ_NUM                = 16;
  //  Количество значений источника тока
  LTR24_I_SRC_VALUE_NUM         = 2;
  //  Размер поля с названием модуля.
  LTR24_NAME_SIZE               = 8;
  //  Размер поля с серийным номером модуля.
  LTR24_SERIAL_SIZE             = 16;




  { -------------- Коды ошибок, специфичные для LTR24 ------------------------}
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




  {------------------ Коды частот дискретизации. -----------------------------}
  LTR24_FREQ_117K     = 0; // 117.1875 кГц
  LTR24_FREQ_78K      = 1; // 78.125 кГц
  LTR24_FREQ_58K      = 2; // 58.59375 кГц
  LTR24_FREQ_39K      = 3; // 39.0625 кГц
  LTR24_FREQ_29K      = 4; // 29.296875 кГц
  LTR24_FREQ_19K      = 5; // 19.53125 кГц
  LTR24_FREQ_14K      = 6; // 14.6484375 кГц
  LTR24_FREQ_9K7      = 7; // 9.765625 кГц
  LTR24_FREQ_7K3      = 8; // 7.32421875 кГц
  LTR24_FREQ_4K8      = 9; // 4.8828125 кГц
  LTR24_FREQ_3K6      = 10; // 3.662109375 кГц
  LTR24_FREQ_2K4      = 11; // 2.44140625 кГц
  LTR24_FREQ_1K8      = 12; // 1.8310546875 кГц
  LTR24_FREQ_1K2      = 13; // 1.220703125 кГц
  LTR24_FREQ_915      = 14; // 915.52734375 Гц
  LTR24_FREQ_610      = 15; // 610.3515625 Гц

  {---------------------- Коды диапазонов в режиме диф. вход. -----------------}
  LTR24_RANGE_2       = 0; // +/-2 В
  LTR24_RANGE_10      = 1; // +/-10 В

  {---------------------- Коды диапазонов в режиме ICP-вход. ------------------}
  LTR24_ICP_RANGE_1   = 0; // ~1 В
  LTR24_ICP_RANGE_5   = 1; // ~5 В

  {---------------------- Значения источника тока. ----------------------------}
  LTR24_I_SRC_VALUE_2_86   = 0; // 2.86 мА
  LTR24_I_SRC_VALUE_10     = 1; // 10 мА

  {------------------------ Коды форматов отсчетов. ---------------------------}
  LTR24_FORMAT_20     = 0; // 20-битный формат
  LTR24_FORMAT_24     = 1; // 24-битный формат


  {------------------- Флаги, управляющие обработкой данных. ------------------}
  //Признак, что нужно применить калибровочные коэффициенты
  LTR24_PROC_FLAG_CALIBR       = $00000001;
  // Признак, что нужно перевести коды АЦП в Вольты
  LTR24_PROC_FLAG_VOLT         = $00000002;
  // Признак, что необходимо выполнить коррекцию АЧХ
  LTR24_PROC_FLAG_AFC_COR      = $00000004;
  // Признак, что идет обработка не непрерывных данных
  LTR24_PROC_FLAG_NONCONT_DATA = $00000100;

 type
  {$A4}

  { Коэффициенты БИХ-фильтра коррекции АЧХ }
  TLTR24_AFC_IIR_COEF = record
    a0 : Double;
    a1 : Double;
    b0 : Double;
  end;

  { Набор коэффициентов для коррекции АЧХ модуля }
  TLTR24_AFC_COEFS = record
    // Частота сигнала, для которой снято отношение амплитуд из FirCoef
    AfcFreq : Double;
    {   Набор отношений измеренной амплитуды синусоидального сигнала
         к реальной амплитуде для макс. частоты дискретизации и частоты сигнала
         из AfcFreq для каждого канала и каждого диапазона }
    FirCoef : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_RANGE_NUM-1] of Double;
    { @brief Коэффициенты БИХ-фильтра для коррекции АЧХ АЦП на частотах
       #LTR24_FREQ_39K и ниже }
    AfcIirCoef : TLTR24_AFC_IIR_COEF;
  end;

  { Заводские калибровочные коэффициенты для одного диапазона }
  TLTR24_CBR_COEF = record
    Offset : Single;  // Смещение
    Scale  : Single;  // Коэффициент масштаба
  end;

  { Информация о модуле.

    Содержит информацию о модуле. Вся информация, кроме значений полей
    SupportICP и VerPLD, берется из ПЗУ моду-ля и действительна только
    после вызова  LTR24_GetConfig(). }
  TINFO_LTR24 = record
    // Название модуля ("LTR24")
    Name    : Array [0..LTR24_NAME_SIZE-1] of AnsiChar;
    // Серийный номер модуля
    Serial  : Array [0..LTR24_SERIAL_SIZE-1] of AnsiChar;
    // Версия прошивки ПЛИС.       
    VerPLD  : Byte;
    //  Признак поддержки измерения с ICP датчиков
    SupportICP : LongBool;
    Reserved : Array [1..8] of LongWord;
    //  Массив заводских калибровочных коэффициентов.
    CalibCoef : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_RANGE_NUM-1] of Array [0..LTR24_FREQ_NUM-1] of TLTR24_CBR_COEF;
    // Коэффициенты для корректировки АЧХ.
    AfcCoef   : TLTR24_AFC_COEFS;
    // Измеренные значения источников токов для каждого канала(только для LTR24-2).
    ISrcVals  : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_I_SRC_VALUE_NUM-1] of Double;
  end;


  TLTR24_CHANNEL_MODE = record
    { Включение канала. }
    Enable   : LongBool;
    { Код диапазона канала.         *
      Устанавливается равным одной из констант
      "LTR24_RANGE_*" или "LTR24_ICP_RANGE_* }
    Range    : Byte;
    { Режим отсечки постоянной составляющей (TRUE -- включен).
      Имеет значение только только в случае, если поле ICPMode равно FALSE. }
    AC       : LongBool;
    { Включение режима измерения ICP-датчиков
      Если FALSE - используется режим "Диф. вход" или "Измерение нуля"
                  (в зависимости от поля TestMode)
      Если TRUE  - режим "ICP" или "ICP тест" }
    ICPMode  : LongBool;
    { Резерв. Поле не должно изменяться пользователем }
    Reserved : Array [1..4] of LongWord;
  end;


  PTLTR24_INTARNAL = ^TLTR24_INTARNAL;
  TLTR24_INTARNAL = record
  end;

  { Управляющая структура модуля.

    Хранит текущие настройки модуля, информацию о
    его состоянии, структуру канала связи. Передается в большинство функций
    библиотеки. Некоторые поля структуры доступны для изменения пользователем
    для настройки параметров модуля. Перед использованием требует инициализации
    с помощью функции LTR24_Init. }
  TLTR24 = record
    {  Размер структуры TLTR24. Заполняется автоматически при вызове функции LTR24_Init. }
    Size        : Integer;
    {  Канал связи с LTR сервером. }
    Channel     : TLTR;
    {  Текущее состояние сбора данных (TRUE -- сбор данных запущен). }
    Run         : LongBool;
    {  Код частоты дискретизации.
       Устанавливается равным одной из констант @ref freqs "LTR24_FREQ_*".
       Устанавливается пользователем. }
    ADCFreqCode : Byte;
    {  Значение частоты дискретизации в Гц.
       Заполняется значением частоты дискретизации, соответствующим коду
       в поле ADCFreqCode, после выполнения функции LTR24_SetADC. }
    ADCFreq     : double;
    {  Код формата данных.
       Устанавливается равным одной из констант @ref formats "LTR24_FORMAT_*".
       Устанавливается пользователем. }
    DataFmt     : Byte;
    { Значение источника тока для всех каналов подключения ICP-датчиков.
      Устанавливается равным одной из констант @ref i_src_vals "LTR24_I_SRC_VALUE_*".
      Устанавливается пользователем. }
    ISrcValue   : Byte;
    {  Включение тестовых режимов.
       Включает тестовые режимы ("Измерение нуля" или "ICP-тест" в зависимости от
       значения значения поля ICPMode для каждого канала)
       для всех каналов (TRUE – включен).
       Устанавливается пользователем. }
    TestMode    : LongBool;
    { Резерв. Поле не должно изменяться пользователем }
    Reserved    : Array [1..16] of LongWord;
    { Настройки каналов. }
    ChannelMode : Array [0..LTR24_CHANNEL_NUM-1] of TLTR24_CHANNEL_MODE;
    { Информация о модуле. }
    ModuleInfo : TINFO_LTR24;
    { Массив используемых калибровочных коэффициентов.
      Применяемые для коррекции данных в функции LTR24_ProcessData()
      калибровочные коэффициенты по каждому каналу, диапазону и частоте.
      При вызове LTR24_GetConfig() в данные поля копируются заводские
      калибровочные коэффициенты (те же, что и в ModuleInfo).
      Но, при необходимости, пользователь может записать в данные поля
      свои коэффициенты. }
    CalibCoef : Array [0..LTR24_CHANNEL_NUM-1] of Array [0..LTR24_RANGE_NUM-1] of Array [0..LTR24_FREQ_NUM-1] of TLTR24_CBR_COEF;
    { Коэффициенты для корректировки АЧХ, применяемые в функции LTR24_ProcessData().
      При вызове LTR24_GetConfig() поля копируются значения из ПЗУ модуля
      (те же, что и в ModuleInfo) }
    AfcCoef   : TLTR24_AFC_COEFS ;
    { Указатель на структуру с параметрами, используемыми только
      библиотекой и недоступными пользователю. }
    Internal  : PTLTR24_INTARNAL;
  end;

  pTLTR24=^TLTR24;

  {$A+}

  // Возвращает текущую версию библиотеки
  Function LTR24_GetVersion : LongWord;
  // Инициализация описателя модуля
  Function LTR24_Init(out hnd: TLTR24) : Integer;
  // Установить соединение с модулем.
  Function LTR24_Open(var hnd: TLTR24; net_addr : LongWord; net_port : Word;
                      csn: string; slot: Word): Integer;
  // Закрытие соединения с модулем
  Function LTR24_Close(var hnd: TLTR24) : Integer;
  // Проверка, открыто ли соединение с модулем.
  Function LTR24_IsOpened(var hnd: TLTR24) : Integer;
  { Считывает информацию из флеш памяти модуля и обновляет поля ModuleInfo в
    управляющей структуре модуля }
  Function LTR24_GetConfig(var hnd: TLTR24) : Integer;
  // Запись настроек в модуль
  Function LTR24_SetADC(var hnd: TLTR24) : Integer;

  // Перевод в режим сбора данных
  Function LTR24_Start(var hnd: TLTR24) : Integer;
  // Останов режима сбора данных
  Function LTR24_Stop(var hnd: TLTR24) : Integer;

  { Используется только при запущенном сборе данных.
    Включает режим измерения собственного нуля. }
  Function LTR24_SetZeroMode(var hnd : TLTR24; enable : LongBool) : Integer;

  { Используется только при запущенном сборе данных.
    Включает режим отсечения постоянной составляющей для каждого канала.
    Возвращает код ошибки. }
  Function LTR24_SetACMode(var hnd : TLTR24;  chan : Byte; ac_mode : LongBool) : Integer;

  // Прием данных от модуля
  Function LTR24_Recv(var hnd: TLTR24; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR24_Recv(var hnd: TLTR24; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR24_RecvEx(var hnd : TLTR24; out data : array of LongWord; out tmark : array of LongWord;
                        size : LongWord; timeout : LongWord; out time_vals: Int64): Integer;
  // Обработка принятых от модуля слов
  Function LTR24_ProcessData(var hnd: TLTR24; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out ovload : array of LongBool): Integer; overload;
  Function LTR24_ProcessData(var hnd: TLTR24; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord): Integer; overload;

  // Получение сообщения об ошибке.
  Function LTR24_GetErrorString(err: Integer) : string;
  
  // Определяет данные в слоте для хранения управляющей структуры как некорректные
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

  
  // Определяет данные в слоте для хранения управляющей структуры как некорректные
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
