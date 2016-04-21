unit ltr35api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  // Размер строки с именем модуля в структуре #TINFO_LTR35
  LTR35_NAME_SIZE             = 8;
  // Размер строки с серийным номером модуля в структуре #TINFO_LTR35
  LTR35_SERIAL_SIZE           = 16;
  // Количество каналов ЦАП
  LTR35_DAC_CHANNEL_CNT       =  8;
  // Количество выходов для каждого канала ЦАП
  LTR35_DAC_CH_OUTPUTS_CNT    = 2;
  // Максимальное количество цифровых линий
  LTR35_DOUT_LINES_MAX_CNT    = 16;
  // Номер канала, соответствующий выводу на цифровые линии (если считать от 0)
  LTR35_CH_NUM_DIGOUTS        = 8;
  // Максимальное количество отсчетов в странице ЦАП в режиме циклического автогенератора
  LTR35_MAX_POINTS_PER_PAGE   = (4*1024*1024);
  // Количество арифметических синусоидальных генераторов в модуле
  LTR35_ARITH_SRC_CNT         = 4;
  // Максимальное значение частоты преобразования ЦАП, которое можно установить
  LTR35_DAC_FREQ_MAX          = 192000;
  // Минимальное значение частоты преобразования ЦАП, которое можно установить
  LTR35_DAC_FREQ_MIN          = 72000;
  { Штатное значение частота преобразования ЦАП, для которого проверяются
    все метрологические характеристики модуля }
  LTR35_DAC_FREQ_DEFAULT      = 192000;

  // Максимальное значение коэф. затухания
  LTR35_ATTENUATION_MAX       = 119.5;
  // Максимальный код ЦАП
  LTR35_DAC_CODE_MAX          = $7FFFFF;
  // Код ЦАП, соответствующий максимальному значению диапазона в Вольтах
  LTR35_DAC_SCALE_CODE_MAX    = $600000;

  { Устанавливаемое по умолчанию количество прочитанных отсчетов для выдачи
    периодического статуса в потоковом режиме }
  LTR35_STREAM_STATUS_PERIOD_DEFAULT  = 1024;
  { Максимальное значение количества отсчетов для выдачи
    периодического статуса в потоковом режиме }
  LTR35_STREAM_STATUS_PERIOD_MAX      = 1024;
  { Минимальное значение количества отсчетов для выдачи
    периодического статуса в потоковом режиме }
  LTR35_STREAM_STATUS_PERIOD_MIN      = 8;
  { Адрес, с которого начинается пользовательская область flash-памяти }
  LTR35_FLASH_USERDATA_ADDR           = $100000;
  { Размер пользовательской области flash-памяти }
  LTR35_FLASH_USERDATA_SIZE           = $700000;
  { Минимальный размер блока для стирания во flash-памяти модуля }
  LTR35_FLASH_ERASE_BLOCK_SIZE        = 1024;

  { -------------- Коды ошибок, специфичные для LTR35 ------------------------}
  LTR35_ERR_INVALID_SYNT_FREQ             = -10200; // Задана неподдерживаемая частота синтезатора
  LTR35_ERR_PLL_NOT_LOCKED                = -10201; // Ошибка захвата PLL
  LTR35_ERR_INVALID_CH_SOURCE             = -10202; // Задано неверное значение источника данных для канала
  LTR35_ERR_INVALID_CH_RANGE              = -10203; // Задано неверное значение диапазона канала
  LTR35_ERR_INVALID_DATA_FORMAT           = -10204; // Задано неверное значение формата данных
  LTR35_ERR_INVALID_MODE                  = -10205; // Задано неверное значение режима работы
  LTR35_ERR_INVALID_DAC_RATE              = -10206; // Задано неверное значение скорости выдачи на ЦАП
  LTR35_ERR_INVALID_SYNT_CNTRS            = -10207; // Задано недопустимое значение счетчиков синтезатора
  LTR35_ERR_INVALID_ATTENUATION           = -10208; // Задано неверное значение коэффициента затухания канала ЦАП
  LTR35_ERR_UNSUPPORTED_CONFIG            = -10209; // Заданная конфигурация ЦАП не поддерживается
  LTR35_ERR_INVALID_STREAM_STATUS_PERIOD  = -10210; // Задано неверное количество отсчетов для выдачи статуса в потоковом режиме
  LTR35_ERR_DAC_CH_NOT_PRESENT            = -10211; // Выбранный канал ЦАП отсутствует в данном модуле
  LTR35_ERR_DAC_NO_SDRAM_CH_ENABLED       = -10212; // Не разрешен ни один канал ЦАП на вывод из SDRAM
  LTR35_ERR_DAC_DATA_NOT_ALIGNED          = -10213; // Данные ЦАП не выравнены на кол-во разрешенных каналов
  LTR35_ERR_NO_DATA_LOADED                = -10214; // Не было подгружено ни одного отсчета
  LTR35_ERR_LTRD_UNSUP_STREAM_MODE        = -10215; // Данная версия ltrd/LtrServer не поддерживает потоковый режим LTR35
  LTR35_ERR_MODE_UNSUP_FUNC               = -10216; // Данная функция не поддерживается в установленном режиме
  LTR35_ERR_INVALID_ARITH_GEN_NUM         = -10217; // Задано неверное значение номера арифметического генератора

  { --------- Флаги для управления цифровыми выходами ------------ }
  LTR35_DIGOUT_WORD_DIS_H = $00020000; { Запрещение (перевод в третье состояние)
                                         старшей половины цифровых выходов.
                                         Имеет значение только для LTR35-3. }
  LTR35_DIGOUT_WORD_DIS_L = $00010000;  { Запрещение младшей половины цифровых выходов }


  { --------- Флаги для подготовки данных. ----------------------- }
  LTR35_PREP_FLAGS_VOLT   = $00000001; { Флаг указывает, что данные на входе
                                         заданны в вольтах и их нужно перевести в коды }

  { --------- Флаги состояния модуля. ---------------------------- }
  LTR35_STATUS_FLAG_PLL_LOCK      = $0001; { Признак захвата PLL в момент передачи статуса.
                                             Если равен нулю, то модуль неработоспособен. }
  LTR35_STATUS_FLAG_PLL_LOCK_HOLD = $0002; { Признак, что захват PLL не пропадал с момента предыдущей
                                             передачи статуса. Должен быть установлен во всех статусах,
                                             кроме первого }


  { ---------- Формат данных для передачи данных модулю ---------- }
  LTR35_FORMAT_24 = 0; // 24-битный формат. Один отсчет занимает два 32-битных слова LTR
  LTR35_FORMAT_20 = 1; // 20-битный формат. Один отсчет занимает одно 32-битное слово LTR

  { ---------- Режим работы модуля ------------------------------- }
  LTR35_MODE_CYCLE    = 0; { Режим циклического автогенератора. Данные подкачиваются
                             в буфер перед запуском выдачи, после чего выдаются
                             по кругу без подкачки. }
  LTR35_MODE_STREAM   = 1; { Потоковый режим. Данные постоянно подкачиваются
                             в очередь и выдаются при наличии на вывод }

  { ---------- Используемый выход для канала ЦАП ------------------ }
  LTR35_DAC_OUT_FULL_RANGE = 0;  { Выход 1:1 с диапазоном от -10 до +10 для
                                   LTR35-1 и от -2 до +20 для LTR35-2 }
  LTR35_DAC_OUT_DIV_RANGE  = 1;  { Выход 1:5 для LTR35-1 или выход 1:10
                                    для LTR35-2 }

  { ---------- Источники сигнала для каналов ЦАП ------------------ }
  LTR35_CH_SRC_SDRAM = 0; { Сигнал берется из буфера в SDRAM модуля.
                            При этом буфер работает циклически или в виде
                             очереди в зависимости от режима }
  LTR35_CH_SRC_SIN1  = 1; { Синус  от первого арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_COS1  = 2; { Косинус  от первого арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_SIN2  = 3; { Синус  от второго арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_COS2  = 4; { Косинус  от второго арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_SIN3  = 5; { Синус  от третьего арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_COS3  = 6; { Косинус  от третьего арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_SIN4  = 7; { Синус  от четвертого арифметического синусоидального
                             генератора }
  LTR35_CH_SRC_COS4  = 8; {  Косинус  от четвертого арифметического синусоидального
                             генератора }

  { ------------ Скорость выдачи данных. -------------------------- }
  LTR35_DAC_RATE_DOUBLE = 1; // Частота синтезатора, деленная на 384
  LTR35_DAC_RATE_QUAD   = 2; // Частота синтезатора, деленная на 192

  { ------------ Флаги для записи во flash-память модуля ---------- }
  { Признак, что записываемая область памяти уже стерта и не требуется
        дополнительно стирать обновляемые сектора }
   LTR35_FLASH_WRITE_ALREDY_ERASED = $00001;


   { ------------ Модификации модуля LTR35 ------------------------ }
    LTR35_MOD_UNKNOWN = 0; // Неизвестная (не поддерживаемая библиотекой) модификация
    LTR35_MOD_1 = 1;  // LTR35-1
    LTR35_MOD_2 = 2;  // LTR35-2
    LTR35_MOD_3 = 3;  // LTR35-3



  {$A4}
  { Калибровочные коэффициенты }
  type TLTR35_CBR_COEF = record
    Offset : Single; // Код смещения
    Scale  : Single; // Коэффициент шкалы
  end;

  { Описание выхода ЦАП. }
  type TLTR35_DAC_OUT_DESCR = record
    AmpMax : double; // Максимальное пиковое значение амплитуды сигнала для данного выхода
    AmpMin : Double; // Минимальное пиковое значение амплитуды сигнала для данного выхода */
    CodeMax : Integer; //Код ЦАП, соответствующий максимальной амплитуде
    CodeMin : Integer; // Код ЦАП, соответствующий минимальной амплитуде
    Reserved : array [0..2] of LongWord; // Резервные поля
  end;



  { Информация о модуле }
  TINFO_LTR35 = record
    Name : Array [0..LTR35_NAME_SIZE-1] of AnsiChar; // Название модуля (оканчивающаяся нулем ASCII-строка)
    Serial : Array [0..LTR35_SERIAL_SIZE-1] of AnsiChar; //Серийный номер модуля (оканчивающаяся нулем ASCII-строка)
    VerFPGA : Word;  // Версия прошивки ПЛИС модуля (действительна только после ее загрузки)
    VerPLD : Byte; //Версия прошивки PLD
    Modification : Byte; // Модификация модуля. Одно из значений из #e_LTR35_MODIFICATION
    DacChCnt : Byte; // Количество установленных каналов ЦАП
    DoutLineCnt : Byte; // Количество линий цифрового вывода

    { Описание параметров выходов для данной модификации модуля }
    DacOutDescr : array [0..LTR35_DAC_CH_OUTPUTS_CNT-1] of TLTR35_DAC_OUT_DESCR;
    Reserved1 : array [0..25] of LongWord; // Резервные поля 
    { Заводские калибровочные коэффициенты }
    CbrCoef : array [0..LTR35_DAC_CHANNEL_CNT-1] of array [0..LTR35_DAC_CH_OUTPUTS_CNT-1] of TLTR35_CBR_COEF;
    { Дополнительные резервные поля }
    Reserved2 : array [0..64*LTR35_DAC_CHANNEL_CNT*LTR35_DAC_CH_OUTPUTS_CNT-1] of LongWord;
  end;

  { Настройки канала ЦАП }
   TLTR35_CHANNEL_CONFIG = record
    Enabled : Boolean; // Разрешение выдачи сигнала для данного канала
    Output : Byte;  // Используемый выход для данного канала (значение из #e_LTR35_DAC_OUTPUT)
    Source : Byte;  // Источник данных для данного канала (значение из #e_LTR35_CH_SRC)
    ArithAmp : Double; // Амплитуда сигнала в режиме арифметического генератора
    ArithOffs : Double; // Смещение сигнала в режиме арифметического генератора
    Attenuation : Double; // Коэффициент затухания в dB (от 0 до 119.5 с шагом 0.5)
    Reserved : array [0..7] of LongWord; // Резервные поля
  end;


  { Настройки арифметического генератора. }
  TLTR35_ARITH_SRC_CONFIG = record
    Phase : Double; // Начальная фаза сигнала в радианах
    Delta : Double; // Приращение фазы сигнала для каждого значения, выведенного на ЦАП, в радианах
    Reserved : array [0..31] of LongWord; // Резервные поля
  end;

  { Настройки синтезатора. }
  TLTR35_SYNT_CONFIG = record
    b : Word; // Коэффициент b в настройках синтезатора
    r : Word; // Коэффициент r в настройках синтезатора
    a : Byte; // Коэффициент a в настройках синтезатора
  end;

  { Настройки модуля. }
  TLTR35_CONFIG = record
    // Настройки каналов ЦАП.
    Ch : array [0..LTR35_DAC_CHANNEL_CNT-1] of TLTR35_CHANNEL_CONFIG;
    // Настройки арифметических генероторов.
    ArithSrc : array [0..LTR35_ARITH_SRC_CNT-1] of TLTR35_ARITH_SRC_CONFIG;

    Mode : Byte; // Режим работы модуля (значение из #e_LTR35_MODE).
    DataFmt : Byte; // Формат данных (значение из #e_LTR35_DATA_FORMAT).

    DacRate : Byte; { Скорости выдачи (константа из #e_LTR35_RATE).
                       Как правило заполняется с помощью функции LTR35_FillFreq(). }
    Synt : TLTR35_SYNT_CONFIG; { Настройки синтезатора.
                                 Как правило заполняется с помощью функции LTR35_FillFreq().}

    StreamStatusPeriod : Word; { Период передачи статусных слов. В потоковом
                                  режиме ([Mode](@ref TLTR35_CONFIG::Mode)
                                  = #LTR35_MODE_STREAM) статусное слово будет
                                  передаваться после вывода каждых
                                  StreamStatusPeriod слов из буфера.
                                  0 означает выбор значения по-умолчанию. }
    EchoEnable : Byte;        {  Разрешение передачи эхо-данных от одного
                                  выбранного канала. }
    EchoChannel : Byte;       {  При разрешенной передачи эхо-данных определяет
                                  номер канала, которому будут соответствовать
                                  эти данные }

    Reserved: Array [0..62] of LongWord;  // Резервные поля (должны быть установлены в 0) 
  end;


  {  Параметры текущего состояния модуля. }
  TLTR35_STATE = record
    FpgaState : Byte; { Текущее состояние ПЛИС. Одно из значений из e_LTR_FPGA_STATE }
    Run : Byte;       { Признак, запущен ли сейчас вывод на ЦАП (в потоковом режиме
                          или в режиме циклического автогенератора) }
    DacFreq : Double; { Установленная частота ЦАП. Обновляется после
                         вызова LTR35_Configure(). }
    EnabledChCnt : Byte; { Количество разрешенных каналов ЦАП. Обновляется после
                               вызова LTR35_Configure(). }
    SDRAMChCnt : Byte;  { Количество разрешенных каналов ЦАП, отсчеты для
                             которых берутся из буфера модуля. Обновляется после
                             вызова LTR35_Configure(). }
    ArithChCnt : Byte; { Количество разрешенных каналов ЦАП, настроенных
                             на режим арифметического генератора. Обновляется после
                             вызова LTR35_Configure(). }
    Reserved : array [0..32-1] of LongWord; // Резервные поля
  end;

  PTLTR35_INTARNAL = ^TLTR35_INTARNAL;
  TLTR35_INTARNAL = record
  end;

  {  Управляющая структура модуля. }
  TLTR35 = record
    size : integer;      { Размер структуры. Заполняется в LTR35_Init(). }
    Channel : TLTR;      { Структура, содержащая состояние соединения с
                           ltrd или LtrServer.
                           Не используется напрямую пользователем. }
    { Указатель на непрозрачную структуру с внутренними параметрами,
      используемыми исключительно библиотекой и недоступными для пользователя. }
    Internal : PTLTR35_INTARNAL;
    Cfg : TLTR35_CONFIG;   { Настройки модуля. Заполняются пользователем
                                перед вызовом LTR35_Configure() }
    { Состояние модуля и рассчитанные параметры. Поля изменяются функциями
      библиотеки. Пользовательской программой могут использоваться
      только для чтения. }
    State : TLTR35_STATE;
    ModuleInfo : TINFO_LTR35; // Информация о модуле 
  end;

  pTLTR35=^TLTR35;

  {$A+}


  // Инициализация описателя модуля
  Function LTR35_Init(out hnd: TLTR35): Integer;
  // Установить соединение с модулем.
  Function LTR35_Open(var hnd: TLTR35; net_addr : LongWord; net_port : LongWord;
                      csn: string; slot: Word): Integer;
  // Закрытие соединения с модулем
  Function LTR35_Close(var hnd: TLTR35): Integer;
  // Проверка, открыто ли соединение с модулем.
  Function LTR35_IsOpened(var hnd: TLTR35): Integer;

  // Подбор коэффициентов для получения заданной частоты преобразования ЦАП.
  Function LTR35_FillFreq(out cfg: TLTR35_CONFIG; freq : Double; out fnd_freq: double): Integer; overload;
  Function LTR35_FillFreq(out cfg: TLTR35_CONFIG; freq : Double): Integer; overload;

  // Запись настроек в модуль.
  Function LTR35_Configure(var hnd: TLTR35) : Integer;

  // Передача данных ЦАП и цифровых выходов в модуль.
  Function LTR35_Send(var hnd: TLTR35; var data : array of LongWord; size : LongWord; timeout : LongWord) : Integer;

  // Подготовка данных для передачи в модуль.
  Function LTR35_PrepareData(var hnd: TLTR35; var dac_data : array of Double;
                             var dac_size : LongWord;
                             var dout_data : array of LongWord;
                             var dout_size : LongWord;
                             flags : LongWord;
                             out result_data : array of LongWord;
                             var result_size : LongWord) : Integer;

  // Подготовка данных ЦАП для передачи в модуль.
  Function LTR35_PrepareDacData(var hnd: TLTR35; var dac_data : array of Double;
                       size : LongWord; flags : LongWord;
                       var result_data : array of LongWord;
                       out result_size : LongWord) : Integer;

  //  Смена страницы вывода в режиме циклического автогенератора
  Function LTR35_SwitchCyclePage(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer;
  // Запуск выдачи данных в потоковом режиме.
  Function LTR35_StreamStart(var hnd: TLTR35; flags: LongWord): Integer;
  // Останов выдачи данных.
  Function LTR35_Stop(var hnd: TLTR35; flags: LongWord): Integer;
  // Останов выдачи данных с заданным временем ожидания ответа.
  Function LTR35_StopWithTout(var hnd: TLTR35; flags: LongWord; tout: LongWord): Integer;
  // Изменение частоты для арифметического генератора.
  Function LTR35_SetArithSrcDelta(var hnd: TLTR35; gen_num: Byte; delta: double): Integer;
  // Изменение амплитуды и смещения арифметического сигнала.
  Function LTR35_SetArithAmp(var hnd: TLTR35; ch_num: Byte; amp: Double; offset: double): Integer;
  // Прием эхо-данных от модуля.
  Function LTR35_RecvEchoResp(var hnd: TLTR35; out data : array of integer;
                              out tmark : array of Integer;
                              size : LongWord; timeout: LongWord): Integer;

  // Получение сообщения об ошибке.
  Function LTR35_GetErrorString(err: Integer) : string;
  // Проверка, разрешена ли работа ПЛИС модуля.
  Function LTR35_FPGAIsEnabled(var hnd: TLTR35; out enabled: LongBool): Integer;
  // Разрешение работы ПЛИС модуля.
  Function LTR35_FPGAEnable(var hnd: TLTR35; enable: LongBool): Integer;
  // Получение информации о состоянии модуля.
  Function LTR35_GetStatus(var hnd: TLTR35; out status : LongWord): Integer;

  // Чтение данных из flash-памяти модуля
  Function LTR35_FlashRead(var hnd: TLTR35; addr: LongWord; out data : array of byte; size: LongWord): Integer;
  // Запись данных во flash-память модуля
  Function LTR35_FlashWrite(var hnd: TLTR35; addr: LongWord; var data : array of byte; size: LongWord; flags : LongWord): Integer;
  // Стирание области flash-память модуля
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
  // Подготовка данных ЦАП для передачи в модуль.
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

  // Подготовка данных ЦАП для передачи в модуль.
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
