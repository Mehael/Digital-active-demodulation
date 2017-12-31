unit ltr210api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  // Размер строки с именем модуля в структуре TINFO_LTR210
  LTR210_NAME_SIZE                 = 8;
  // Размер строки с серийным номером модуля в структуре TINFO_LTR210
  LTR210_SERIAL_SIZE               = 16;
  // Количество каналов АЦП в одном модуле
  LTR210_CHANNEL_CNT               = 2;
  // Количество диапазонов измерения АЦП
  LTR210_RANGE_CNT                 = 5;

  // Код принятого отсчета АЦП, соответствующий максимальному напряжению заданного диапазона
  LTR210_ADC_SCALE_CODE_MAX        = 13000;
  // Максимальное значение делителя частоты АЦП
  LTR210_ADC_FREQ_DIV_MAX          = 9;
  // Максимальное значение коэффициента прореживания данных от АЦП
  LTR210_ADC_DCM_CNT_MAX           = 256;

  // Частота в Герцах, относительно которой задается частота отсчетов АЦП
  LTR210_ADC_FREQ_HZ               = 10000000;
  // Частота в Герцах, относительно которой задается частота следования кадров в режиме LTR210_SYNC_MODE_PERIODIC
  LTR210_FRAME_FREQ_HZ             = 1000000;
  // Размер внутреннего циклического буфера модуля в отсчетах АЦП
  LTR210_INTERNAL_BUFFER_SIZE      = 16777216;
  // Максимальный размер кадра, который можно установить в одноканальном режиме
  LTR210_FRAME_SIZE_MAX            = (16777216 - 512);


  { -------------- Коды ошибок, специфичные для LTR210 ------------------------}
  LTR210_ERR_INVALID_SYNC_MODE          = -10500; // Задан неверный код условия сбора кадра
  LTR210_ERR_INVALID_GROUP_MODE         = -10501; // Задан неверный код режима работы модуля в составе группы
  LTR210_ERR_INVALID_ADC_FREQ_DIV       = -10502; // Задано неверное значение делителя частоты АЦП
  LTR210_ERR_INVALID_CH_RANGE           = -10503; // Задан неверный код диапазона канала АЦП
  LTR210_ERR_INVALID_CH_MODE            = -10504; // Задан неверный режим измерения канала
  LTR210_ERR_SYNC_LEVEL_EXCEED_RANGE    = -10505; // Установленный уровень аналоговой синхронизации выходит за границы установленного диапазона
  LTR210_ERR_NO_ENABLED_CHANNEL         = -10506; // Ни один канал АЦП не был разрешен
  LTR210_ERR_PLL_NOT_LOCKED             = -10507; // Ошибка захвата PLL
  LTR210_ERR_INVALID_RECV_DATA_CNTR     = -10508; // Неверное значение счетчика в принятых данных
  LTR210_ERR_RECV_UNEXPECTED_CMD        = -10509; // Прием неподдерживаемой команды в потоке данных
  LTR210_ERR_FLASH_INFO_SIGN            = -10510; // Неверный признак информации о модуле во Flash-памяти
  LTR210_ERR_FLASH_INFO_SIZE            = -10511; // Неверный размер прочитанной из Flash-памяти информации о модуле
  LTR210_ERR_FLASH_INFO_UNSUP_FORMAT    = -10512; // Неподдерживаемый формат информации о модуле из Flash-памяти
  LTR210_ERR_FLASH_INFO_CRC             = -10513; // Ошибка проверки CRC информации о модуле из Flash-памяти
  LTR210_ERR_FLASH_INFO_VERIFY          = -10514; // Ошибка проверки записи информации о модуле во Flash-память
  LTR210_ERR_CHANGE_PAR_ON_THE_FLY      = -10515; // Часть измененнных параметров нельзя изменять на лету
  LTR210_ERR_INVALID_ADC_DCM_CNT        = -10516; // Задан неверный коэффициент прореживания данных АЦП
  LTR210_ERR_MODE_UNSUP_ADC_FREQ        = -10517; // Установленный режим не поддерживает заданную частоту АЦП
  LTR210_ERR_INVALID_FRAME_SIZE         = -10518; // Неверно задан размер кадра
  LTR210_ERR_INVALID_HIST_SIZE          = -10519; // Неверно задан размер предыстории
  LTR210_ERR_INVALID_INTF_TRANSF_RATE   = -10520; // Неверно задано значение скорости выдачи данных в интерфейс
  LTR210_ERR_INVALID_DIG_BIT_MODE       = -10321;  // Неверно задан режим работы дополнительного бита
  LTR210_ERR_SYNC_LEVEL_LOW_EXCEED_HIGH = -10522; // Нижний порог аналоговой синхронизации превышает верхний
  LTR210_ERR_KEEPALIVE_TOUT_EXCEEDED    = -10523; // Не пришло ни одного статуса от модуля за заданный интервал
  LTR210_ERR_WAIT_FRAME_TIMEOUT         = -10524; // Не удалось дождаться прихода кадра за заданное время */
  LTR210_ERR_FRAME_STATUS               = -10525; // Слово статуса в принятом кадре указывает на ошибку данных */


  { --------------- Диапаоны канала АЦП ---------------------}
  LTR210_ADC_RANGE_10     = 0; // Диапазон +/- 10 В
  LTR210_ADC_RANGE_5      = 1; // Диапазон +/- 5 В
  LTR210_ADC_RANGE_2      = 2; // Диапазон +/- 2 В
  LTR210_ADC_RANGE_1      = 3; // Диапазон +/- 1 В
  LTR210_ADC_RANGE_0_5    = 4;  // Диапазон +/- 0.5 В

  { --------------- Режим измерения канала АЦП -------------}
  LTR210_CH_MODE_ACDC    = 0; // Измерение переменной и постоянной состовляющей (открытый вход)
  LTR210_CH_MODE_AC      = 1; // Отсечка постоянной состовляющей (закрытый вход)
  LTR210_CH_MODE_ZERO    = 2;  // Режим измерения собственного нуля



  { --------------- Режим запуска сбора данных -------------------}
  LTR210_SYNC_MODE_INTERNAL     = 0; // Режим сбора кадра по программной команде, передаваемой вызовом LTR210_FrameStart()
  LTR210_SYNC_MODE_CH1_RISE     = 1; // Режим сбора кадра по фронту сигнала относительно уровня синхронизации на первом аналоговом канале
  LTR210_SYNC_MODE_CH1_FALL     = 2; // Режим сбора кадра по спаду сигнала относительно уровня синхронизации на первом аналоговом канале
  LTR210_SYNC_MODE_CH2_RISE     = 3; // Режим сбора кадра по фронту сигнала относительно уровня синхронизации на втором аналоговом канале
  LTR210_SYNC_MODE_CH2_FALL     = 4; // Режим сбора кадра по спаду сигнала относительно уровня синхронизации на втором аналоговом канале
  LTR210_SYNC_MODE_SYNC_IN_RISE = 5; // Режим сбора кадра по фронту цифрового сигнала на входе SYNC (не от другого модуля!)
  LTR210_SYNC_MODE_SYNC_IN_FALL = 6; // Режим сбора кадра по спаду цифрового сигнала на входе SYNC (не от другого модуля!)
  LTR210_SYNC_MODE_PERIODIC     = 7; // Режим периодического сбора кадров с установленной частотой следования кадров
  LTR210_SYNC_MODE_CONTINUOUS   = 8; // Режим непрерывного сбора данных


  { ---------------- Режим работы модуля в группе ------------------}
  LTR210_GROUP_MODE_SINGLE      = 0; // Работает только один независимый модуль
  LTR210_GROUP_MODE_MASTER      = 1; // Режим мастера
  LTR210_GROUP_MODE_SLAVE       = 2; // Режим подчиненного модуля


  {----------------- Коды асинхронных событий ---------------------}
  LTR210_RECV_EVENT_TIMEOUT   = 0;  // Не пришло никакого события от модуля за указанное время
  LTR210_RECV_EVENT_KEEPALIVE = 1;  // Пришел корректный сигнал жизни от модуля
  LTR210_RECV_EVENT_SOF       = 2;   // Пришло начало собранного кадра


  { ---------------- Коды, определяющие правильность принятого кадра -------}
  LTR210_FRAME_RESULT_OK       = 0; // Кадр принят без ошибок. Данные кадра действительны
  LTR210_FRAME_RESULT_PENDING  = 1; // В обрабатываемых данных не было признака конца кадра.
  LTR210_FRAME_RESULT_ERROR    = 2;  // Кадр принят с ошибкой. Данные кадра не действительны.

  {----------------- Флаги статуса ----------------------------------}
  LTR210_STATUS_FLAG_PLL_LOCK      = $0001; // Признак захвата PLL в момент передачи статуса
  LTR210_STATUS_FLAG_PLL_LOCK_HOLD = $0002; // Признак, что захват PLL не  пропадал с момента предыдущей предачи статуса.
  LTR210_STATUS_FLAG_OVERLAP       = $0004; // Признак, что процесс записи обогнал процесс чтения
  LTR210_STATUS_FLAG_SYNC_SKIP     = $0008; // Признак, что во время записи кадра возникло хотя бы одно синхрособытие, которое было пропущено.
  LTR210_STATUS_FLAG_INVALID_HIST  = $0010; // Признак того, что предистория принятого кадра не действительна
  LTR210_STATUS_FLAG_CH1_EN        = $0040; // Признак, что разрешена запись по первому каналу
  LTR210_STATUS_FLAG_CH2_EN        = $0080;  // Признак, что разрешена запись по второму каналу



  {---------------- Дополнительные флаги настроек -------------------}
  // Разрешение периодической передачи статуса модуля при запущенном сборе
  LTR210_CFG_FLAGS_KEEPALIVE_EN    = $001;
  { Разрешение режима автоматической приостановки записи на время, пока
      кадр выдается по интерфейсу в крейт. Данный режим позволяет установить
      максимальный размер кадра независимо от частоты отсчетов АЦП }
  LTR210_CFG_FLAGS_WRITE_AUTO_SUSP = $002;
  // Включение тестого режима, в котором вместо данных передается счетчик
  LTR210_CFG_FLAGS_TEST_CNTR_MODE  = $100;


  { ----------------- Флаги обработки данных ------------------------}
  { Признак, что нужно перевести коды АЦП в Вольты. Если данный флаг не указан,
      то будут возвращены коды АЦП. При этом код #LTR210_ADC_SCALE_CODE_MAX
      соответствует максиальному напряжению для установленного диапзона. }
  LTR210_PROC_FLAG_VOLT          = $0001;
  { Признак, что необходимо выполнить коррекцию АЧХ на основании записанных
      в модуль коэффициентов падения АЧХ }
  LTR210_PROC_FLAG_AFC_COR       = $0002;
  { Признак, что необходимо выполнить дополнительную коррекцию нуля с помощью
      значений из State.AdcZeroOffset, которые могут быть измерены с помощью
      функции LTR210_MeasAdcZeroOffset() }
  LTR210_PROC_FLAG_ZERO_OFFS_COR = $0004;
    { По умолчанию LTR210_ProcessData() предпологает, что ей на обработку
        передаются все принятые данные, и проверяет непрерывность счетчика не только
        внутри переданного блока данных, но и между вызовами.
        Если обрабатываются не все данные или одни и теже данные обрабатыаются
        повторно, то нужно указать данный флаг, чтобы счетчик проверялся только
        внутри блока }
  LTR210_PROC_FLAG_NONCONT_DATA  = $0100;



  { --------------- Скорость выдачи данных в интерфейс ----------------}
  LTR210_INTF_TRANSF_RATE_500K  = 0; // 500 КСлов/c
  LTR210_INTF_TRANSF_RATE_200K  = 1; // 200 КСлов/c
  LTR210_INTF_TRANSF_RATE_100K  = 2; // 100 КСлов/c
  LTR210_INTF_TRANSF_RATE_50K   = 3; // 50  КСлов/c
  LTR210_INTF_TRANSF_RATE_25K   = 4; // 25  КСлов/c
  LTR210_INTF_TRANSF_RATE_10K   = 5; // 10  КСлов/c




  { ---------- Режим работы дополнительного бита во входном потоке ----------}
  LTR210_DIG_BIT_MODE_ZERO             = 0; // Всегда нулевое значение бита
  LTR210_DIG_BIT_MODE_SYNC_IN          = 1; // Бит отражает состояние цифрового входа SYNC модуля
  LTR210_DIG_BIT_MODE_CH1_LVL          = 2; // Бит равен "1", если уровень сигнала для 1-го канала АЦП выше уровня синхронизации
  LTR210_DIG_BIT_MODE_CH2_LVL          = 3; // Бит равен "1", если уровень сигнала для 2-го канала АЦП выше уровня синхронизации
  LTR210_DIG_BIT_MODE_INTERNAL_SYNC    = 4; // Бит равен "1" для одного отсчета в момент срабатывания программной или периодической синхронизации


  {$A4}
  { Калибровочные коэффициенты }
  type TLTR210_CBR_COEF = record
    Offset : Single; // Код смещения
    Scale  : Single; // Коэффициент шкалы
  end;

  { Параметры БИХ-фильтра }
  type TLTR210_AFC_IIR_COEF = record
    R : Double; // Сопротивление эквивалентной цепи фильтра
    C  : Double; // Емкость эквивалентной цепи фильтра
  end;

  { Информация о модуле }
  TINFO_LTR210 = record
    Name : Array [0..LTR210_NAME_SIZE-1] of AnsiChar; // Название модуля (оканчивающаяся нулем ASCII-строка)
    Serial : Array [0..LTR210_SERIAL_SIZE-1] of AnsiChar; //Серийный номер модуля (оканчивающаяся нулем ASCII-строка)
    VerFPGA : Word;  // Версия прошивки ПЛИС модуля (действительна только после ее загрузки)
    VerPLD : Byte; //Версия прошивки PLD
    { Заводские калибровочные коэффициенты (на канал действительны первые
        #LTR210_RANGE_CNT, остальные - резерв) }
    CbrCoef : Array[0..LTR210_CHANNEL_CNT-1] of Array [0..7] of TLTR210_CBR_COEF;
    { Частота в Гц, которой соответствуют корректировочные коэффициенты АЧХ }
    AfcCoefFreq : Double;
    {   Коэффициенты, задающие спад АЧХ модуля на частоте AfcCoefFreq. Представляют
        собой отношение амплитуды измеренного синусоидального сигнала на указанной
        частоте к амплитуде реально выставленного сигнала. Коэффициенты загружаются
        из Flash-памяти модуля при открытии связи с ним. Могут быть использованы
        для корректировки АЧХ при необходимости. На канал действительны первые
        LTR210_RANGE_CNT коэффициентов, остальные - резерв. }
    AfcCoef : Array[0..LTR210_CHANNEL_CNT-1] of Array [0..7] of Double;
    AfcIirParam : Array[0..LTR210_CHANNEL_CNT-1] of Array [0..7] of TLTR210_AFC_IIR_COEF;
    Reserved : Array[1..32] of LongWord; // Резервные поля (не должны изменяться пользователем)
  end;

  { Настройки канала АЦП }
  TLTR210_CHANNEL_CONFIG = record
    Enabled : Boolean; // Признак, разрешен ли сбор по данному каналу
    Range   : Byte;    // Установленный диапазон --- константа из #e_LTR210_ADC_RANGE
    Mode    : Byte;    // Режим измерения --- константа из #e_LTR210_CH_MODE
    DigBitMode : Byte;  // Режим работы дополнительного бита во входном потоке данных данного канала. Константа из #e_LTR210_DIG_BIT_MODE
    Reserved: Array [1..4] of Byte;  //Резервные поля (не должны изменяться пользователем)
    SyncLevelL : Double; //Нижний порог гистерезиса для события аналоговой синхронизации в Вольтах
    SyncLevelH : Double; //Верхний порог гистерезиса для события аналоговой синхронизации в Вольтах
    Reserved2: array [1..10] of LongWord; // Резервные поля (не должны изменяться пользователем) 
  end;

  PTLTR210_CHANNEL_CONFIG = ^TLTR210_CHANNEL_CONFIG;

  { Настройки модуля }
  TLTR210_CONFIG = record
    Ch        : array [0..LTR210_CHANNEL_CNT-1] of TLTR210_CHANNEL_CONFIG; // Настройки каналов АЦП
    FrameSize : LongWord;  // Размер точек на канал в кадре при покадровом сборе
    { Размер сохранной предыстории (количество точек в кадре на канал,
        измеренных до возникновения события синхронизации) }
    HistSize  : LongWord;
    // Условие сбора кадра (событие синхронизации). Одно из значений #e_LTR210_SYNC_MODE
    SyncMode  : Byte;
    // Режим работы в составе группы модулей. Одно из значений #e_LTR210_GROUP_MODE
    GroupMode : Byte;
    { Значение делителя частоты АЦП  - 1. Может быть в диапазоне от 0
        до #LTR210_ADC_FREQ_DIV_MAX-1 }
    AdcFreqDiv : Word;
    { Значение коэфициент прореживания данных АЦП - 1. Может быть в диапазоне
        от 0 до #LTR210_ADC_DCM_CNT_MAX-1.}
    AdcDcmCnt  : LongWord;
    {   Делитель частоты запуска сбора кадров для SyncMode = #LTR210_SYNC_MODE_PERIODIC.
        Частота кадров равна 10^6/(FrameFreqDiv + 1) Гц }
    FrameFreqDiv : LongWord;
    Flags    : LongWord; // Флаги (комбинация из #e_LTR210_CFG_FLAGS)
    { Скорость выдачи данных в интерфейс (одно из значений из #e_LTR210_INTF_TRANSF_RATE).
        По-умолчанию устанавливается максимальная скорость (500 КСлов/с).
        Если установленная скорость превышает максимальную скорость интерфейса для крейта,
        в который установлен модуль, то будет установлена максимальная скорость,
        поддерживаемая данным крейтом }
    IntfTransfRate : Byte;
    Reserved : array [1..39] of LongWord; // Резервные поля (не должны изменяться пользователем)
  end;

  PTLTR210_CONFIG = ^TLTR210_CONFIG;

  { Параметры состояния модуля. }
  TLTR210_STATE = record
    Run           : Boolean;  // Признак, запущен ли сбор данных
    { Количество слов в принимаемом кадре, включая статус.
        (устанавливается после вызова LTR210_SetADC()) }
    RecvFrameSize : LongWord;
    { Рассчитанная частота отсчетов АЦП в Гц (устанавливается после вызова
        LTR210_SetADC()) }
    AdcFreq       : Double;
    {   Рассчитанная частота следования кадров для режима синхронизации
        #LTR210_SYNC_MODE_PERIODIC (устанавливается после вызова
        LTR210_SetADC()) }
    FrameFreq     : Double;
    { Измеренные значения смещения нуля АЦП в кодах }
    AdcZeroOffset : Array [0..LTR210_CHANNEL_CNT-1] of Double;
    Reserved      : Array [1..4] of LongWord; // Резервные поля
  end;


  PTLTR210_INTARNAL = ^TLTR210_INTARNAL;
  TLTR210_INTARNAL = record
  end;

  { Описатель модуля }
  TLTR210 = record
    Size          : Integer; // Размер структуры. Заполняется в LTR210_Init().
    { Структура, содержащая состояние соединения с сервером.
       Не используется напрямую пользователем. }
    Channel       : TLTR;
    {  Указатель на непрозрачную структуру с внутренними параметрами,
       используемыми исключительно библиотекой и недоступными для пользователя. }
    Internal      : PTLTR210_INTARNAL;
    { Настройки модуля. Заполняются пользователем перед вызовом LTR210_SetADC(). }
    Cfg           : TLTR210_CONFIG;
    { Состояние модуля и рассчитанные параметры. Поля изменяются функциями
        библиотеки. Пользовательской программой могут использоваться
        только для чтения. }
    State         : TLTR210_STATE;
    ModuleInfo    : TINFO_LTR210; // Информация о модуле
  end;

  pTLTR210=^TLTR210;


  { Дополнительная информация о принятом отсчете }
  TLTR210_DATA_INFO = record
    {  Младший бит соответствует значению дополнительного бита, передаваемого
        вместе с потоком данных. Что означает данный бит задается одной
        из констант из #e_LTR210_DIG_BIT_MODE в поле DigBitMode на этапе конфигурации.
        Остальные биты могут быть использованы в будущем, поэтому при аналезе
        нужно проверять значение DigBitState and 1 }
    DigBitState : Byte;
    { Номер канала, которому соответствует принятое слово (0-первый, 1 - второй) }
    Ch          : Byte;
    Range       : Byte;     // Диапазон канала, установленный во время преобразования
    Reserved    : Byte;  // Резервные поля (не должны изменяться пользователем)
  end;

  PTLTR210_DATA_INFO = ^TLTR210_DATA_INFO;

  { Информация о статусе обработанного кадра }
  TLTR210_FRAME_STATUS = record
    { Код результата обработки кадра (одно из значений #e_LTR210_FRAME_RESULT).
        Позволяет определить, найден ли был конец кадра и действительны
        ли данные в кадре }
    Result   : Byte;
    { Резервное поле (всегда равно 0) }
    Reserved : Byte;
    {   Дополнительные флаги из #e_LTR210_STATUS_FLAGS,
        представляющие собой информацию о статусе самого
        модуля и принятого кадра. Может быть несколько флагов,
        объединенных через логическое ИЛИ }
    Flags    : Word;
  end;

  PTLTR210_FRAME_STATUS = ^TLTR210_FRAME_STATUS;

  { Тип функции для индикации процесса загрузки ПЛИС }
  type TLTR210_LOAD_PROGR_CB = procedure(cb_data : Pointer; var hnd: TLTR210; done_size: LongWord; full_size : LongWord); {$I ltrapi_callconvention};
  type PTLTR210_LOAD_PROGR_CB = ^TLTR210_LOAD_PROGR_CB;

  {$A+}


  // Инициализация описателя модуля
  Function LTR210_Init(out hnd: TLTR210) : Integer;
  // Установить соединение с модулем.
  Function LTR210_Open(var hnd: TLTR210; net_addr : LongWord; net_port : LongWord;
                      csn: string; slot: Word): Integer;
  // Закрытие соединения с модулем
  Function LTR210_Close(var hnd: TLTR210) : Integer;
  // Проверка, открыто ли соединение с модулем.
  Function LTR210_IsOpened(var hnd: TLTR210) : Integer;
  // Проверка, загружена ли прошивка ПЛИС модуля.
  Function LTR210_FPGAIsLoaded(var hnd: TLTR210) : Integer;
  // Загрузка прошивки ПЛИС модуля.
  Function LTR210_LoadFPGA(var hnd: TLTR210; filename : string;  progr_cb : TLTR210_LOAD_PROGR_CB; cb_data: Pointer) : Integer;
  Function LTR210_LoadFPGA(var hnd: TLTR210; filename : string) : Integer; overload;
  // Запись настроек в модуль
  Function LTR210_SetADC(var hnd: TLTR210) : Integer;

  Function LTR210_FillAdcFreq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord; out set_freq : double) : Integer; overload;
  Function LTR210_FillAdcFreq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord) : Integer; overload;

  Function LTR210_FillFrameFreq(var cfg: TLTR210_CONFIG; freq : double; out set_freq : double) : Integer; overload;
  Function LTR210_FillFrameFreq(var cfg: TLTR210_CONFIG; freq : double) : Integer; overload;
  // Перевод в режим сбора данных
  Function LTR210_Start(var hnd: TLTR210) : Integer;
  // Останов режима сбора данных
  Function LTR210_Stop(var hnd: TLTR210) : Integer;
  // Програмный запуск сбора кадра
  Function LTR210_FrameStart(var hnd: TLTR210) : Integer;
  // Ожидание асинхронного события от модуля
  Function LTR210_WaitEvent(var hnd: TLTR210; out evt: LongWord; out status: LongWord; tout: LongWord) : Integer; overload;
  Function LTR210_WaitEvent(var hnd: TLTR210; out evt: LongWord; tout: LongWord) : Integer; overload;

  // Прием данных от модуля
  Function LTR210_Recv(var hnd: TLTR210; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR210_Recv(var hnd: TLTR210; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  // Обработка принятых от модуля слов
  Function LTR210_ProcessData(var hnd: TLTR210; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS; out data_info: array of TLTR210_DATA_INFO): LongInt;  overload;
  Function LTR210_ProcessData(var hnd: TLTR210; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS): LongInt; overload;

  // Измерение смещения нуля
  Function LTR210_MeasAdcZeroOffset(var hnd: TLTR210; flags : LongWord) : Integer;

  // Получение прошедшего интервала с момента приема последнего слова
  Function LTR210_GetLastWordInterval(var hnd: TLTR210; out interval: LongWord) : Integer;
  // Получение сообщения об ошибке.
  Function LTR210_GetErrorString(err: Integer) : string;



  implementation

  Function _init(out hnd: TLTR210) : Integer;  {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_Init';
  Function _open(var hnd: TLTR210; net_addr : LongWord; net_port : LongWord; csn: PAnsiChar; slot: Word) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_Open';
  Function _close(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_Close';
  Function _is_opened(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_IsOpened';
  Function _fpga_is_loaded(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_FPGAIsLoaded';
  Function _load_fpga(var hnd: TLTR210;  filename : PAnsiChar;  progr_cb : TLTR210_LOAD_PROGR_CB; cb_data: Pointer) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_LoadFPGA';
  Function _set_adc(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_SetADC';
  Function _fill_adc_freq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord; out set_freq : double) : Integer; {$I ltrapi_callconvention};external 'ltr210api' name 'LTR210_FillAdcFreq';
  Function _fill_frame_freq(var cfg: TLTR210_CONFIG; freq : double; out set_freq : double) : Integer; {$I ltrapi_callconvention};external 'ltr210api' name 'LTR210_FillFrameFreq';
  Function _start(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_Start';
  Function _stop(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_Stop';
  Function _frame_start(var hnd: TLTR210) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_FrameStart';
  Function _wait_event(var hnd: TLTR210; out evt: LongWord; out status: LongWord; tout: LongWord) : Integer; {$I ltrapi_callconvention}; overload; external 'ltr210api' name 'LTR210_WaitEvent';
  Function _recv(var hnd: TLTR210; out data; out tmark; size: LongWord; tout : LongWord): Integer; {$I ltrapi_callconvention};  external 'ltr210api' name 'LTR210_Recv';
  Function _process_data(var hnd: TLTR210; var src; out dest; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS; out data_info): LongInt;  {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_ProcessData'; overload;
  //Function _process_data(var hnd: TLTR210; var src; out dest; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS; data_info : Pointer): LongInt; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_ProcessData'; overload;


  Function _meas_adc_zero_offset(var hnd: TLTR210; flags : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_MeasAdcZeroOffset';
  Function _get_last_word_interval(var hnd: TLTR210; out interval: LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_GetLastWordInterval';
  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr210api' name 'LTR210_GetErrorString';

  Function LTR210_Init(out hnd: TLTR210) : Integer;
  begin
    LTR210_Init:=_init(hnd);
  end;
  Function LTR210_Open(var hnd: TLTR210; net_addr : LongWord; net_port : LongWord; csn: string; slot: Word): Integer;
  begin
      LTR210_Open:=_open(hnd, net_addr, net_port, PAnsiChar(AnsiString(csn)), slot);
  end;
  Function LTR210_Close(var hnd: TLTR210) : Integer;
  begin
    LTR210_Close:=_close(hnd);
  end;
  Function LTR210_IsOpened(var hnd: TLTR210) : Integer;
  begin
    LTR210_IsOpened:=_is_opened(hnd);
  end;
  Function LTR210_FPGAIsLoaded(var hnd: TLTR210) : Integer;
  begin
    LTR210_FPGAIsLoaded:=_fpga_is_loaded(hnd);
  end;

  Function LTR210_LoadFPGA(var hnd: TLTR210;  filename : string;  progr_cb : TLTR210_LOAD_PROGR_CB; cb_data: Pointer) : Integer;
  begin
     LTR210_LoadFPGA:=_load_fpga(hnd, PAnsiChar(AnsiString(filename)), progr_cb, cb_data);
  end;

  Function LTR210_LoadFPGA(var hnd: TLTR210; filename : string) : Integer;
  begin
     LTR210_LoadFPGA:=LTR210_LoadFPGA(hnd, PAnsiChar(AnsiString(filename)), nil, nil);
  end;

  Function LTR210_SetADC(var hnd: TLTR210) : Integer;
  begin
    LTR210_SetADC:=_set_adc(hnd);
  end;

  Function LTR210_FillAdcFreq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord; out set_freq : double) : Integer; overload;
  begin
    LTR210_FillAdcFreq:=_fill_adc_freq(cfg, freq, flags, set_freq);
  end;

  Function LTR210_FillAdcFreq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord) : Integer;
  begin
    LTR210_FillAdcFreq:=LTR210_FillAdcFreq(cfg, freq, flags, PDouble(nil)^);
  end;

  Function LTR210_FillFrameFreq(var cfg: TLTR210_CONFIG; freq : double; out set_freq : double) : Integer; overload;
  begin
    LTR210_FillFrameFreq:=_fill_frame_freq(cfg, freq, set_freq);
  end;
  Function LTR210_FillFrameFreq(var cfg: TLTR210_CONFIG; freq : double) : Integer;
  begin
    LTR210_FillFrameFreq:=LTR210_FillFrameFreq(cfg, freq, PDouble(nil)^);
  end;

  Function LTR210_Start(var hnd: TLTR210) : Integer;
  begin
    LTR210_Start:=_start(hnd);
  end;
  Function LTR210_Stop(var hnd: TLTR210) : Integer;
  begin
    LTR210_Stop:=_stop(hnd);
  end;

  Function LTR210_FrameStart(var hnd: TLTR210) : Integer;
  begin
    LTR210_FrameStart:=_frame_start(hnd);
  end;

  Function LTR210_WaitEvent(var hnd: TLTR210; out evt: LongWord; out status: LongWord; tout: LongWord) : Integer; overload;
  begin
    LTR210_WaitEvent:=_wait_event(hnd, evt, status, tout);
  end;
  Function LTR210_WaitEvent(var hnd: TLTR210; out evt: LongWord; tout: LongWord) : Integer;  overload;
  begin
     LTR210_WaitEvent:=LTR210_WaitEvent(hnd, evt, PLongWord(nil)^, tout);
  end;

  Function LTR210_Recv(var hnd: TLTR210; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR210_Recv:=_recv(hnd, data, tmark, size, tout);
  end;

  Function LTR210_Recv(var hnd: TLTR210; out data : array of LongWord; size: LongWord; tout : LongWord): Integer;
  begin
    LTR210_Recv:=_recv(hnd, data, PLongWord(nil)^, size, tout);
  end;

  Function LTR210_ProcessData(var hnd: TLTR210; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS; out data_info: array of
  TLTR210_DATA_INFO): LongInt;
  begin
     LTR210_ProcessData:=_process_data(hnd, src, dest, size, flags, frame_status, data_info);
  end;

  Function LTR210_ProcessData(var hnd: TLTR210; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS): LongInt;
  begin
    LTR210_ProcessData:=_process_data(hnd, src, dest, size, flags, frame_status, PTLTR210_DATA_INFO(nil)^);
  end;

  Function LTR210_MeasAdcZeroOffset(var hnd: TLTR210; flags : LongWord) : Integer;
  begin
    LTR210_MeasAdcZeroOffset:=_meas_adc_zero_offset(hnd, flags);
  end;

  Function LTR210_GetLastWordInterval(var hnd: TLTR210; out interval: LongWord) : Integer;
  begin
    LTR210_GetLastWordInterval:=_get_last_word_interval(hnd, interval);
  end;

  function LTR210_GetErrorString(err: Integer) : string;
  begin
     LTR210_GetErrorString:=string(_get_err_str(err));
  end;













end.
