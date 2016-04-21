unit ltr25api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  // Количество каналов АЦП в одном модуле LTR25
  LTR25_CHANNEL_CNT        = 8;
  // Количество частот дискретизации.
  LTR25_FREQ_CNT           = 8;
  // Количество частот, для которых сохраняются калибровочные коэффициенты
  LTR25_CBR_FREQ_CNT       = 2;
  // Количество значений источника тока
  LTR25_I_SRC_VALUE_CNT    = 2;
  // Размер поля с названием модуля.
  LTR25_NAME_SIZE          = 8;
  // Размер поля с серийным номером модуля.
  LTR25_SERIAL_SIZE        = 16;
  // Максимальное пиковое значение в Вольтах для диапазона измерения модуля
  LTR25_ADC_RANGE_PEAK     = 10;
  // Код АЦП, соответствующее максимальному пиковому значению
  LTR25_ADC_SCALE_CODE_MAX = 2000000000;

  // Адрес, с которого начинается пользовательская область flash-памяти
  LTR25_FLASH_USERDATA_ADDR  = $0;
  // Размер пользовательской области flash-памяти
  LTR25_FLASH_USERDATA_SIZE  = $100000;
  // Минимальный размер блока для стирания flash-памяти. Все операции стирания
  //  должны быть кратны данному размеру
  LTR25_FLASH_ERASE_BLOCK_SIZE = 4096;


  { -------------- Коды ошибок, специфичные для LTR25 ------------------------}
  LTR25_ERR_FPGA_FIRM_TEMP_RANGE      = -10600; // Загружена прошивка ПЛИС для неверного температурного диапазона
  LTR25_ERR_I2C_ACK_STATUS            = -10601; // Ошибка обмена при обращении к регистрам АЦП по интерфейсу I2C
  LTR25_ERR_I2C_INVALID_RESP          = -10602; // Неверный ответ на команду при обращении к регистрам АЦП по интерфейсу I2C
  LTR25_ERR_INVALID_FREQ_CODE         = -10603; // Неверно задан код частоты АЦП
  LTR25_ERR_INVALID_DATA_FORMAT       = -10604; // Неверно задан формат данных АЦП
  LTR25_ERR_INVALID_I_SRC_VALUE       = -10605; // Неверно задано значение источника тока
  LTR25_ERR_CFG_UNSUP_CH_CNT          = -10606; // Для заданной частоты и формата не поддерживается заданное количество каналов АЦП
  LTR25_ERR_NO_ENABLED_CH             = -10607; // Не был разрешен ни один канал АЦП
  LTR25_ERR_ADC_PLL_NOT_LOCKED        = -10608; // Ошибка захвата PLL АЦП
  LTR25_ERR_ADC_REG_CHECK             = -10609; // Ошибка проверки значения записанных регистров АЦП
  LTR25_ERR_LOW_POW_MODE_NOT_CHANGED  = -10610; // Не удалось перевести АЦП из/в низкопотребляющее состояние
  LTR25_ERR_LOW_POW_MODE              = -10611; // Модуль находится в низкопотребляющем режиме

  {------------------ Коды частот дискретизации. -----------------------------}
  LTR25_FREQ_78K     = 0;     // 78.125 кГц
  LTR25_FREQ_39K     = 1;     // 39.0625 кГц
  LTR25_FREQ_19K     = 2;     // 19.53125 кГц
  LTR25_FREQ_9K7     = 3;     // 9.765625 кГц
  LTR25_FREQ_4K8     = 4;     // 4.8828125 кГц
  LTR25_FREQ_2K4     = 5;     // 2.44140625 кГц
  LTR25_FREQ_1K2     = 6;     // 1.220703125 кГц
  LTR25_FREQ_610     = 7;     // 610.3515625 Гц

  {------------------ Форматы данных от модуля --------------------------------}
  LTR25_FORMAT_20   = 0; // 20-битный целочисленный (1 слово на отсчет)
  LTR25_FORMAT_32   = 1; // 32-битный целочисленный (2 слова на отсчет)

  {---------------------- Значения источника тока. ----------------------------}
  LTR25_I_SRC_VALUE_2_86   = 0; // 2.86 мА
  LTR25_I_SRC_VALUE_10     = 1; // 10 мА



  {------------------- Флаги, управляющие обработкой данных. ------------------}
  // Признак, что нужно перевести коды АЦП в Вольты
  LTR25_PROC_FLAG_VOLT         = $00000001;
  // Признак, что идет обработка не непрерывных данных
  LTR25_PROC_FLAG_NONCONT_DATA = $00000100;


  {------------------- Состояние входного канала. -----------------------------}
  LTR25_CH_STATUS_OK          = 0; // Канал в рабочем состоянии
  LTR25_CH_STATUS_SHORT       = 1; // Было обнаружено короткое замыкание
  LTR25_CH_STATUS_OPEN        = 2; // Был обнаружен разрыв цепи


 type
  {$A4}
  { Заводские калибровочные коэффициенты для одного диапазона }
  TLTR25_CBR_COEF = record
    Offset : Single;  // Код смещения
    Scale  : Single;  // Коэффициент масштаба
  end;

  { Набор коэффициентов для коррекции АЧХ модуля }
  TLTR25_AFC_COEFS = record
    // Частота сигнала, для которой снято отношение амплитуд из FirCoef
    AfcFreq : Double;
    {   Набор отношений измеренной амплитуды синусоидального сигнала
         к реальной амплитуде для макс. частоты дискретизации и частоты сигнала
         из AfcFreq для каждого канала и каждого диапазона }
    FirCoef : Array [0..LTR25_CHANNEL_CNT-1] of Double;
  end;

  { Информация о модуле }
  TINFO_LTR25 = record
    // Название модуля ("LTR25")
    Name    : Array [0..LTR25_NAME_SIZE-1] of AnsiChar;
    // Серийный номер модуля
    Serial  : Array [0..LTR25_SERIAL_SIZE-1] of AnsiChar;
    // Версия прошивки ПЛИС
    VerFPGA : Word;
    // Версия прошивки PLD
    VerPLD  : Byte;
    // Ревизия платы
    BoardRev : Byte;
    // Признак, это индустриальный вариант модуля или нет
    Industrial : LongBool;
    // Зарезервированные поля. Всегда равны 0
    Reserved : Array [1..8] of LongWord;
    { Калибровочные коэффициенты модуля. Считываются из Flash-памяти
        модуля при вызове LTR25_Open() или LTR25_GetConfig() и загружаются
        в ПЛИС для применения во время вызова LTR25_SetADC() }
    CbrCoef : Array [0..LTR25_CHANNEL_CNT-1] of Array [0..LTR25_CBR_FREQ_CNT-1] of TLTR25_CBR_COEF;
    // Коэффициенты для коррекции АЧХ модуля
    AfcCoef : TLTR25_AFC_COEFS;
    // Резервные поля
    Reserved2 : array [0 .. (32*LTR25_CHANNEL_CNT - (LTR25_CHANNEL_CNT + 1) - 1)] of Double;
  end;

  // Настройки канала АЦП.
  TLTR25_CHANNEL_CONFIG = record
    Enabled : LongBool; // Признак, разрешен ли сбор по данному каналу
    Reserved : array [1..11] of LongWord;  // Резервные поля (не должны изменяться пользователем)
  end;

  // Настройки модуля.
  TLTR25_CONFIG = record
    Ch : array [0..LTR25_CHANNEL_CNT-1] of TLTR25_CHANNEL_CONFIG; // Настройки каналов АЦП
    FreqCode : byte; // Код, задающий требуемую частоту сбора АЦП. Одно из значений #e_LTR25_FREQS
    DataFmt : byte;  //< Формат, в котором будут передаваться отсчеты АЦП от модуля. Одно из значений #e_LTR25_FORMATS.
    ISrcValue : byte; // Используемое значение источника тока. Одно из значений #e_LTR25_I_SOURCES
    Reserved : array [1..50] of LongWord; // Резервные поля (не должны изменяться пользователем)
  end;

  // Параметры текущего состояния модуля.
  TLTR25_STATE = record
    FpgaState : byte;  //Tекущее состояние ПЛИС. Одно из значений из e_LTR_FPGA_STATE
    EnabledChCnt : byte;  //Количество разрешенных каналов. Устанавливается после вызова LTR25_SetADC()
    Run : LongBool;   // Признак, запущен ли сбор данных
    AdcFreq : double; // Установленная частота АЦП. Обновляется после вызова LTR25_SetADC()
    LowPowMode : LongBool; //< Признак, находится ли модуль в состоянии низкого потребления. */
    Reserved : array [1..31] of LongWord; // Резервные поля
  end;

  PTLTR25_INTARNAL = ^TLTR25_INTARNAL;
  TLTR25_INTARNAL = record
  end;

  // Управляющая структура модуля.
  TLTR25 = record
    Size : Integer; // Размер структуры. Заполняется в LTR25_Init().
    { Структура, содержащая состояние соединения с программой ltrd или LtrServer.
       Не используется напрямую пользователем. }
    Channel : TLTR;
    { Указатель на непрозрачную структуру с внутренними параметрами,
      используемыми исключительно библиотекой и недоступными для пользователя. }
    Internal : PTLTR25_INTARNAL;
    // Настройки модуля. Заполняются пользователем перед вызовом LTR25_SetADC().
    Cfg : TLTR25_CONFIG;
    { Состояние модуля и рассчитанные параметры. Поля изменяются функциями
        библиотеки. Пользовательской программой могут использоваться
        только для чтения. }
    State : TLTR25_STATE;
    { Информация о модуле }
    ModuleInfo : TINFO_LTR25;
  end;

  pTLTR25=^TLTR25;

  {$A+}

  // Инициализация описателя модуля
  Function LTR25_Init(out hnd: TLTR25) : Integer;
  // Установить соединение с модулем.
  Function LTR25_Open(var hnd: TLTR25; net_addr : LongWord; net_port : Word;
                      csn: string; slot: Integer): Integer;
  // Закрытие соединения с модулем
  Function LTR25_Close(var hnd: TLTR25) : Integer;
  // Проверка, открыто ли соединение с модулем.
  Function LTR25_IsOpened(var hnd: TLTR25) : Integer;
  // Запись настроек в модуль
  Function LTR25_SetADC(var hnd: TLTR25) : Integer;

  // Перевод в режим сбора данных
  Function LTR25_Start(var hnd: TLTR25) : Integer;
  // Останов режима сбора данных
  Function LTR25_Stop(var hnd: TLTR25) : Integer;

  // Прием данных от модуля
  Function LTR25_Recv(var hnd: TLTR25; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR25_Recv(var hnd: TLTR25; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;

  // Обработка принятых от модуля слов
  Function LTR25_ProcessData(var hnd: TLTR25; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out ch_status : array of LongWord): Integer; overload;
  Function LTR25_ProcessData(var hnd: TLTR25; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord): Integer; overload;

    // Поиск начала первого кадра.
  Function LTR25_SearchFirstFrame(var hnd : TLTR25; var data : array of LongWord;
                                size : LongWord; out index : LongWord) : Integer;

  // Получение сообщения об ошибке.
  Function LTR25_GetErrorString(err: Integer) : string;
  Function LTR25_GetConfig(var hnd : TLTR25) : Integer;

  // Перевод модуля в режим низкого потребления.
  Function LTR25_SetLowPowMode(var hnd: TLTR25; lowPowMode : LongBool) : Integer;
  // Проверка, разрешена ли работа ПЛИС модуля.
  Function LTR25_FPGAIsEnabled(var hnd: TLTR25; out enabled : LongBool) : Integer;
  // Разрешение работы ПЛИС модуля.
  Function LTR25_FPGAEnable(var hnd: TLTR25; enable : LongBool) : Integer;

  // Чтение данных из flash-памяти модуля
  Function LTR25_FlashRead(var hnd: TLTR25; addr : LongWord; out data : array of byte; size : LongWord) : Integer;
  // Запись данных во flash-память модуля
  Function LTR25_FlashWrite(var hnd: TLTR25; addr : LongWord; var data : array of Byte; size : LongWord) : Integer;
  // Стирание области flash-память модуля
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

  // Определяет данные в слоте для хранения управляющей структуры как некорректные
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
