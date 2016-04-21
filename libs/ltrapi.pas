unit ltrapi;
interface
uses SysUtils, ltrapitypes, ltrapidefine;

const
    LTR_OK                              =  0;  // Выполнено без ошибок.
    LTR_ERROR_UNKNOWN                   = -1;  // Неизвестная ошибка.
    LTR_ERROR_PARAMETERS                = -2;  // Ошибка входных параметров.
    LTR_ERROR_PARAMETRS                 =  LTR_ERROR_PARAMETERS;
    LTR_ERROR_MEMORY_ALLOC              = -3;  // Ошибка динамического выделения памяти.
    LTR_ERROR_OPEN_CHANNEL              = -4;  // Ошибка открытия канала обмена с сервером.
    LTR_ERROR_OPEN_SOCKET               = -5;  // Ошибка открытия сокета.
    LTR_ERROR_CHANNEL_CLOSED            = -6;  // Ошибка. Канал обмена с сервером не создан.
    LTR_ERROR_SEND                      = -7;  // Ошибка отправления данных.
    LTR_ERROR_RECV                      = -8;  // Ошибка приема данных.
    LTR_ERROR_EXECUTE                   = -9;  // Ошибка обмена с крейт-контроллером.
    LTR_WARNING_MODULE_IN_USE           = -10; // Канал обмена с сервером создан в текущей программе
                                               // и в какой-то еще
    LTR_ERROR_NOT_CTRL_CHANNEL          = -11; // Номер канала для этой операции должен быть CC_CONTROL
    LTR_ERROR_SRV_INVALID_CMD           = -12; // Команда не поддерживается сервером
    LTR_ERROR_SRV_INVALID_CMD_PARAMS    = -13; // Сервер не поддерживает указанные параметры команды
    LTR_ERROR_INVALID_CRATE             = -14; // Указанный крейт не найден
    LTR_ERROR_EMPTY_SLOT                = -15; // В указанном слоте отсутствует модуль
    LTR_ERROR_UNSUP_CMD_FOR_SRV_CTL     = -16; // Команда не поддерживается управляющим каналом сервера
    LTR_ERROR_INVALID_IP_ENTRY          = -17; // Неверная запись сетевого адреса крейта
    LTR_ERROR_NOT_IMPLEMENTED           = -18; // Данная возможность не реализована

    LTR_ERROR_INVALID_MODULE_DESCR      = -40; // Неверный описатель модуля
    LTR_ERROR_INVALID_MODULE_SLOT       = -41; // Указан неверный слот для модуля
    LTR_ERROR_INVALID_MODULE_ID         = -42; // Неверный ID-модуля в ответе на сброс
    LTR_ERROR_NO_RESET_RESPONSE         = -43; // Нет ответа на команду сброс
    LTR_ERROR_SEND_INSUFFICIENT_DATA    = -44; // Передано данных меньше, чем запрашивалось
    LTR_ERROR_RECV_INSUFFICIENT_DATA    = -45;
    LTR_ERROR_NO_CMD_RESPONSE           = -46; // Нет ответа на команду сброс
    LTR_ERROR_INVALID_CMD_RESPONSE      = -47; // Пришел неверный ответ на команду
    LTR_ERROR_INVALID_RESP_PARITY       = -48; // Неверный бит четности в пришедшем ответе
    LTR_ERROR_INVALID_CMD_PARITY        = -49; // Ошибка четности переданной команды
    LTR_ERROR_UNSUP_BY_FIRM_VER         = -50; // Возможность не поддерживается данной версией прошивки
    LTR_ERROR_MODULE_STARTED            = -51; // Модуль уже запущен
    LTR_ERROR_MODULE_STOPPED            = -52; // Модуль остановлен
    LTR_ERROR_RECV_OVERFLOW             = -53; // Произошло переполнение буфера
    LTR_ERROR_FIRM_FILE_OPEN            = -54; // Ошибка открытия файла прошивки
    LTR_ERROR_FIRM_FILE_READ            = -55; // Ошибка чтения файла прошивки
    LTR_ERROR_FIRM_FILE_FORMAT          = -56; // Ошибка формата файла прошивки
    LTR_ERROR_FPGA_LOAD_READY_TOUT      = -57; // Превышен таймаут ожидания готовности ПЛИС к загрузке
    LTR_ERROR_FPGA_LOAD_DONE_TOUT       = -58; // Превышен таймаут ожидания перехода ПЛИС в рабочий режим
    LTR_ERROR_FPGA_IS_NOT_LOADED        = -59; // Прошивка ПЛИС не загружена
    LTR_ERROR_FLASH_INVALID_ADDR        = -60; // Неверный адрес Flash-памяти
    LTR_ERROR_FLASH_WAIT_RDY_TOUT       = -61; // Превышен таймаут ожидания завершения записи/стирания Flash-памяти
    LTR_ERROR_FIRSTFRAME_NOTFOUND       = -62; // First frame in card data stream not found
    LTR_ERROR_CARDSCONFIG_UNSUPPORTED   = -63;
    LTR_ERROR_FLASH_OP_FAILED           = -64; // Ошибка выполненя операции flash-памятью
    LTR_ERROR_FLASH_NOT_PRESENT         = -65; // Flash-память не обнаружена
    LTR_ERROR_FLASH_UNSUPPORTED_ID      = -66; // Обнаружен неподдерживаемый тип flash-памяти
    LTR_ERROR_FLASH_UNALIGNED_ADDR      = -67; // Невыровненный адрес flash-памяти
    LTR_ERROR_FLASH_VERIFY              = -68; // Ошибка при проверки записанных данных во flash-память
    LTR_ERROR_FLASH_UNSUP_PAGE_SIZE     = -69; // Установлен неподдерживаемый размер страницы flash-памяти
    LTR_ERROR_FLASH_INFO_NOT_PRESENT    = -70; // Отсутствует информация о модуле во Flash-памяти
    LTR_ERROR_FLASH_INFO_UNSUP_FORMAT   = -71; // Неподдерживаемый формат информации о модуле во Flash-памяти
    LTR_ERROR_FLASH_SET_PROTECTION      = -72; // Не удалось установить защиту Flash-памяти
    LTR_ERROR_FPGA_NO_POWER             = -73; // Нет питания микросхемы ПЛИС
    LTR_ERROR_FPGA_INVALID_STATE        = -74; // Не действительное состояние загрузки ПЛИС
    LTR_ERROR_FPGA_ENABLE               = -75; // Не удалось перевести ПЛИС в разрешенное состояние
    LTR_ERROR_FPGA_AUTOLOAD_TOUT        = -76; // Истекло время ожидания автоматической загрузки ПЛИС
    LTR_ERROR_PROCDATA_UNALIGNED        = -77; // Обрабатываемые данные не выравнены на границу кадра
    LTR_ERROR_PROCDATA_CNTR             = -78; // Ошибка счетчика в обрабатываемых данных
    LTR_ERROR_PROCDATA_CHNUM            = -79; // Неверный номер канала в обрабатываемых данных
    LTR_ERROR_PROCDATA_WORD_SEQ         = -80; // Неверная последовательность слов в обрабатываемых данных


type
// Значения для управления ножками процессора, доступными для пользовательского программирования
en_LTR_UserIoCfg=(LTR_USERIO_DIGIN1    =1,// ножка является входом и подключена к DIGIN1
                  LTR_USERIO_DIGIN2   = 2,    // ножка является входом и подключена к DIGIN2
                  LTR_USERIO_DIGOUT   = 0,    // ножка является выходом (подключение см. en_LTR_DigOutCfg)
                  LTR_USERIO_DEFAULT  = LTR_USERIO_DIGOUT);
// Значения для управления выходами DIGOUTx
en_LTR_DigOutCfg=(
    LTR_DIGOUT_CONST0   = $00, // постоянный уровень логического "0"
    LTR_DIGOUT_CONST1   = $01, // постоянный уровень логической "1"
    LTR_DIGOUT_USERIO0  = $02, // выход подключен к ножке userio0 (PF1 в рев. 0, PF1 в рев. 1)
    LTR_DIGOUT_USERIO1  = $03, // выход подключен к ножке userio1 (PG13)
    LTR_DIGOUT_DIGIN1   = $04, // выход подключен ко входу DIGIN1
    LTR_DIGOUT_DIGIN2   = $05, // выход подключен ко входу DIGIN2
    LTR_DIGOUT_START    = $06, // на выход подаются метки "СТАРТ"
    LTR_DIGOUT_SECOND   = $07, // на выход подаются метки "СЕКУНДА"
    LTR_DIGOUT_IRIG     = $08, // контроль сигналов точного времени IRIG (digout1: готовность, digout2: секунда)
    LTR_DIGOUT_DEFAULT  = LTR_DIGOUT_CONST0
    );
// Значения для управления метками "СТАРТ" и "СЕКУНДА"
en_LTR_MarkMode=(
    LTR_MARK_OFF                = $00, // метка отключена
    LTR_MARK_EXT_DIGIN1_RISE    = $01, // метка по фронту DIGIN1
    LTR_MARK_EXT_DIGIN1_FALL    = $02, // метка по спаду DIGIN1
    LTR_MARK_EXT_DIGIN2_RISE    = $03, // метка по фронту DIGIN2
    LTR_MARK_EXT_DIGIN2_FALL    = $04, // метка по спаду DIGIN2
    LTR_MARK_INTERNAL           = $05, // внутренняя генерация метки

    LTR_MARK_NAMUR1_LO2HI       = 8,   // по сигналу NAMUR1 (START_IN), возрастание тока
    LTR_MARK_NAMUR1_HI2LO       = 9,   // по сигналу NAMUR1 (START_IN), спад тока
    LTR_MARK_NAMUR2_LO2HI       = 10,  // по сигналу NAMUR2 (M1S_IN), возрастание тока
    LTR_MARK_NAMUR2_HI2LO       = 11,  // по сигналу NAMUR2 (M1S_IN), спад тока

    { Источник метки - декодер сигналов точного времени IRIG-B006
       IRIG может использоваться только для меток "СЕКУНДА", для "СТАРТ" игнорируется }
    LTR_MARK_SEC_IRIGB_DIGIN1   = 16,   // со входа DIGIN1, прямой сигнал
    LTR_MARK_SEC_IRIGB_nDIGIN1  = 17,   // со входа DIGIN1, инвертированный сигнал
    LTR_MARK_SEC_IRIGB_DIGIN2   = 18,   // со входа DIGIN2, прямой сигнал
    LTR_MARK_SEC_IRIGB_nDIGIN2  = 19    // со входа DIGIN2, инвертированный сигнал
    );

{$A4}
TLTR=record
    saddr:LongWord;                     // сетевой адрес сервера
    sport:word;                         // сетевой порт сервера
    csn:SERNUMtext;                     // серийный номер крейта
    cc:WORD;                            // номер канала крейта
    flags:LongWord;                     // флаги состояния канала
    tmark:LongWord;                     // последняя принятая метка времени
    internal:Pointer;                   // указатель на канал
end;
pTLTR = ^TLTR;
TLTR_CONFIG=record
     userio:array[0..3]of WORD;
     digout:array[0..1]of WORD;
     digout_en:WORD;
end;

Type t_crate_ipentry_array = array[0..0] of TIPCRATE_ENTRY;
Type p_crate_ipentry_array = ^t_crate_ipentry_array;

{$A+}



Function LTR_Init(out ltr: TLTR):integer; overload;
Function LTR_Open(var ltr: TLTR):integer; overload;
Function LTR_Close(var ltr: TLTR):integer; overload;
Function LTR_IsOpened(var ltr: TLTR):integer; overload;
//заполнения поля с серийным номером в структуре TLTR (используется перед открытием)
Procedure LTR_FillSerial(var ltr: TLTR; csn : string);

Function LTR_GetCrates(var ltr: TLTR; var csn: array of string; out crates_cnt: Integer):integer;  overload;

Function LTR_GetCrateModules(var ltr: TLTR; var mids: array of Word):integer; overload;

Function LTR_GetCrateInfo(var ltr:TLTR; out CrateInfo:TCRATE_INFO):integer; overload;
Function LTR_Config(var ltr:TLTR; var conf : TLTR_CONFIG):integer; overload;
Function LTR_StartSecondMark(var ltr:TLTR; mode:en_LTR_MarkMode):integer; overload;
Function LTR_StopSecondMark(var ltr:TLTR):integer; overload;
Function LTR_MakeStartMark(var ltr:TLTR; mode:en_LTR_MarkMode):integer; overload;

Function LTR_AddIPCrate(var ltr: TLTR; ip_addr: LongWord; flags: LongWord; permanent:LongBool):integer; overload;
Function LTR_DeleteIPCrate(var ltr: TLTR; ip_addr: LongWord; permanent:LongBool):integer; overload;
Function LTR_ConnectIPCrate(var ltr: TLTR; ip_addr:LongWord):integer; overload;
Function LTR_DisconnectIPCrate(var ltr: TLTR; ip_addr:LongWord):integer; overload;
Function LTR_ConnectAllAutoIPCrates(var ltr: TLTR):integer; overload;
Function LTR_DisconnectAllIPCrates(var ltr: TLTR):integer; overload;
Function LTR_SetIPCrateFlags(var ltr: TLTR; ip_addr:LongWord; new_flags:LongWord; permanent:LongBool):integer; overload;

Function LTR_GetListOfIPCrates(var ltr: TLTR; ip_net : LongWord; ip_mask:LongWord;
                               out entries_found: LongWord;
                               out entries_returned: LongWord;
                               out info_array: array of TIPCRATE_ENTRY):integer;

Function LTR_GetLogLevel(var ltr: TLTR; out level:integer):integer; overload;
Function LTR_SetLogLevel(var ltr: TLTR; level:integer;  permanent: LongBool):integer; overload;
Function LTR_ServerRestart(var ltr: TLTR):integer; overload;
Function LTR_ServerShutdown(var ltr: TLTR):integer; overload;
Function LTR_SetTimeout(var ltr: TLTR; ms:LongWord):integer; overload;
Function LTR_SetServerProcessPriority(var ltr: TLTR; Priority:LongWord):integer; overload;
Function LTR_GetServerProcessPriority(var ltr: TLTR; out Priority:LongWord):integer; overload;
Function LTR_GetServerVersion(var ltr: TLTR; out version:LongWord):integer; overload;
Function LTR_GetLastUnixTimeMark(var ltr: TLTR; out unixtime:UInt64):integer; overload;


Function LTR_CrateGetArray(var ltr: TLTR; address : LongWord; out buf: array of Byte; size : LongWord): Integer;
Function LTR_CratePutArray(var ltr: TLTR; address : LongWord; const buf: array of Byte; size : LongWord): Integer;








{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
// Функции для внутреннего применения
Function LTR__GenericCtlFunc(
        TLTR:Pointer;                       // дескриптор LTR
        request_buf:Pointer;                // буфер с запросом
        request_size:LongWord;              // длина запроса (в байтах)
        reply_buf:Pointer;                  // буфер для ответа (или NULL)
        reply_size:LongWord;                // длина ответа (в байтах)
        ack_error_code:integer;             // какая ошибка, если ack не GOOD (0 = не использовать ack)
        timeout:LongWord                   // таймаут, мс
    ):integer; {$I ltrapi_callconvention};

// Функции общего назначения



Function LTR_Init(ltr:pTLTR):integer;  {$I ltrapi_callconvention}; overload;
Function LTR_Open(ltr:pTLTR):integer;  {$I ltrapi_callconvention}; overload;
Function LTR_Close(ltr:pTLTR):integer;  {$I ltrapi_callconvention}; overload;
Function LTR_IsOpened(ltr:pTLTR):integer;  {$I ltrapi_callconvention}; overload;
Function LTR_Recv(ltr:pTLTR; dataDWORD:Pointer; tmarkDWORD:POINTER; size:LongWord; timeout:LongWord):integer;  {$I ltrapi_callconvention};
Function LTR_Send(ltr:pTLTR; dataDWORD:Pointer; size:LongWord; timeout:LongWord):integer;  {$I ltrapi_callconvention};
Function LTR_GetCrates(ltr:pTLTR; csnBYTE:Pointer):integer;  {$I ltrapi_callconvention}; overload;
Function LTR_GetCrateModules(ltr:pTLTR; midWORD:Pointer):integer;  {$I ltrapi_callconvention}; overload;

Function LTR_GetCrateRawData(ltr:pTLTR; dataDWORD:Pointer; tmarkDWORD:Pointer; size:LongWord; timeout:LongWord):integer;  {$I ltrapi_callconvention};
Function LTR_GetErrorString(error:integer):string;
Function    LTR_GetCrateInfo(ltr:pTLTR; CrateInfoTCRATE_INFO:Pointer):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_Config(ltr:pTLTR; confTLTR_CONFIG:Pointer):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_StartSecondMark(ltr:pTLTR; mode:en_LTR_MarkMode):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_StopSecondMark(ltr:pTLTR):integer; {$I ltrapi_callconvention};  overload;
Function    LTR_MakeStartMark(ltr:pTLTR; mode:en_LTR_MarkMode):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_AddIPCrate(ltr:pTLTR; ip_addr:LongWord; flags:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_DeleteIPCrate(ltr:pTLTR; ip_addr:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_ConnectIPCrate(ltr:pTLTR; ip_addr:LongWord):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_DisconnectIPCrate(ltr:pTLTR; ip_addr:LongWord):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_ConnectAllAutoIPCrates(ltr:pTLTR):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_DisconnectAllIPCrates(ltr:pTLTR):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_SetIPCrateFlags(ltr:pTLTR; ip_addr:LongWord; new_flags:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_GetLogLevel(ltr:pTLTR; levelINT:Pointer):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_SetLogLevel(ltr:pTLTR; level:integer;  permanent:LongBool):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_ServerRestart(ltr:pTLTR):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_ServerShutdown(ltr:pTLTR):integer; {$I ltrapi_callconvention}; overload;
Function    LTR_SetTimeout(ltr:pTLTR; ms:LongWord):integer; {$I ltrapi_callconvention};  overload;
Function    LTR_SetServerProcessPriority(ltr:pTLTR; Priority:LongWord):integer;  {$I ltrapi_callconvention}; overload;
Function    LTR_GetServerProcessPriority(ltr:pTLTR; Priority:Pointer):integer; {$I ltrapi_callconvention};  overload;
Function    LTR_GetServerVersion(ltr:pTLTR; version:Pointer):integer; {$I ltrapi_callconvention};  overload;
Function    LTR_GetLastUnixTimeMark(ltr:pTLTR; unixtime:Pointer):integer;{$I ltrapi_callconvention};  overload;

Function    LTR_GetIPCrateDiscoveryMode(ltr:pTLTR; enabledBOOL:Pointer; autoconnectBOOL:Pointer):integer; {$I ltrapi_callconvention};
Function    LTR_SetIPCrateDiscoveryMode(ltr:pTLTR; enabled:LongBool; autoconnect:LongBool; permanent:LongBool):integer; {$I ltrapi_callconvention};
{$ENDIF}



Implementation
  Type t_crate_mids_array = array[0..MODULE_MAX-1] of Word;
  Type p_crate_mids_array = ^t_crate_mids_array;


{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
  Function LTR__GenericCtlFunc(TLTR:Pointer;request_buf:Pointer;request_size:LongWord;reply_buf:Pointer;reply_size:LongWord;ack_error_code:integer;timeout:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_Init(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_Open(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_Close(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_IsOpened(ltr:pTLTR):integer; {$I ltrapi_callconvention};  external 'ltrapi';
  Function LTR_Recv(ltr:pTLTR; dataDWORD:Pointer; tmarkDWORD:POINTER; size:LongWord; timeout:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_Send(ltr:pTLTR; dataDWORD:Pointer; size:LongWord; timeout:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetCrates(ltr:pTLTR; csnBYTE:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetCrateModules(ltr:pTLTR; midWORD:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_SetServerProcessPriority(ltr:pTLTR; Priority:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetCrateRawData(ltr:pTLTR; dataDWORD:Pointer; tmarkDWORD:Pointer; size:LongWord; timeout:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  //Function LTR_GetErrorString(error:integer):string; external 'ltrapi';
  Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_GetErrorString';

  Function LTR_GetCrateInfo(ltr:pTLTR; CrateInfoTCRATE_INFO:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_Config(ltr:pTLTR; confTLTR_CONFIG:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_StartSecondMark(ltr:pTLTR; mode:en_LTR_MarkMode):integer; {$I ltrapi_callconvention};  external 'ltrapi';
  Function LTR_StopSecondMark(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_MakeStartMark(ltr:pTLTR; mode:en_LTR_MarkMode):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  //Function LTR_GetListOfIPCrates(ltr:pTLTR; max_entries:DWORD; ip_net:DWORD; ip_mask:DWORD; entries_foundDWORD:Pointer; entries_returnedDWORD:Pointer; var info_array:TIPCRATE_ENTRY):integer; external 'ltrapi';



  Function LTR_AddIPCrate(ltr:pTLTR; ip_addr:LongWord; flags:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_DeleteIPCrate(ltr:pTLTR; ip_addr:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_ConnectIPCrate(ltr:pTLTR; ip_addr:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_DisconnectIPCrate(ltr:pTLTR; ip_addr:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_ConnectAllAutoIPCrates(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_DisconnectAllIPCrates(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_SetIPCrateFlags(ltr:pTLTR; ip_addr:LongWord; new_flags:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetIPCrateDiscoveryMode(ltr:pTLTR; enabledBOOL:Pointer; autoconnectBOOL:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_SetIPCrateDiscoveryMode(ltr:pTLTR; enabled:LongBool; autoconnect:LongBool; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetLogLevel(ltr:pTLTR; levelINT:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_SetLogLevel(ltr:pTLTR; level:integer;  permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_ServerRestart(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_ServerShutdown(ltr:pTLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_SetTimeout(ltr:pTLTR; ms:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetServerProcessPriority(ltr:pTLTR; Priority:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetServerVersion(ltr:pTLTR; version:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
  Function LTR_GetLastUnixTimeMark(ltr:pTLTR; unixtime:Pointer):integer; {$I ltrapi_callconvention}; external 'ltrapi';
{$ENDIF}





  Function priv_Init(out ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_Init';
  Function priv_Open(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_Open';
  Function priv_Close(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_Close';
  Function priv_IsOpened(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_IsOpened';
  Function priv_GetCrates(var ltr: TLTR; csn: PAnsiChar): Integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_GetCrates';
  Function priv_GetCrateModules(var ltr: TLTR; mids: p_crate_mids_array):integer;  {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_GetCrateModules';

  Function priv_GetCrateInfo(var ltr:TLTR; out CrateInfo:TCRATE_INFO):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_GetCrateInfo';
  Function priv_Config(var ltr:TLTR; var conf : TLTR_CONFIG):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_Config';
  Function priv_StartSecondMark(var ltr:TLTR; mode:en_LTR_MarkMode):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_StartSecondMark';
  Function priv_StopSecondMark(var ltr:TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_StopSecondMark';
  Function priv_MakeStartMark(var ltr:TLTR; mode:en_LTR_MarkMode):integer; {$I ltrapi_callconvention};  external 'ltrapi' name 'LTR_StopSecondMark';

  Function priv_GetListOfIPCrates(var ltr: TLTR; max_entries:LongWord; ip_net:LongWord; ip_mask:LongWord; out entries_found:LongWord; out entries_returned:LongWord; info_array:p_crate_ipentry_array):integer;{$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_GetListOfIPCrates';
  Function priv_AddIPCrate(var ltr: TLTR; ip_addr: LongWord; flags: LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_AddIPCrate';
  Function priv_DeleteIPCrate(var ltr: TLTR; ip_addr: LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_DeleteIPCrate';
  Function priv_ConnectIPCrate(var ltr: TLTR; ip_addr:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_ConnectIPCrate';
  Function priv_DisconnectIPCrate(var ltr: TLTR; ip_addr:LongWord):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_DisconnectIPCrate';
  Function priv_ConnectAllAutoIPCrates(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_ConnectAllAutoIPCrates';
  Function priv_DisconnectAllIPCrates(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_DisconnectAllIPCrates';
  Function priv_SetIPCrateFlags(var ltr: TLTR; ip_addr:LongWord; new_flags:LongWord; permanent:LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_SetIPCrateFlags';

  Function priv_GetLogLevel(var ltr: TLTR; out level:integer):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_GetLogLevel';
  Function priv_SetLogLevel(var ltr: TLTR; level:integer;  permanent: LongBool):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_SetLogLevel';
  Function priv_ServerRestart(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_ServerRestart';
  Function priv_ServerShutdown(var ltr: TLTR):integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_ServerShutdown';
  Function priv_SetTimeout(var ltr: TLTR; ms:LongWord):integer; {$I ltrapi_callconvention};  external 'ltrapi' name 'LTR_SetTimeout';
  Function priv_SetServerProcessPriority(var ltr: TLTR; Priority:LongWord):integer;  {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_SetServerProcessPriority';
  Function priv_GetServerProcessPriority(var ltr: TLTR; out Priority:LongWord):integer; {$I ltrapi_callconvention};  external 'ltrapi' name 'LTR_GetServerProcessPriority';
  Function priv_GetServerVersion(var ltr: TLTR; out version:LongWord):integer; {$I ltrapi_callconvention};  external 'ltrapi' name 'LTR_GetServerVersion';
  Function priv_GetLastUnixTimeMark(var ltr: TLTR; out unixtime:UInt64):integer;{$I ltrapi_callconvention};  external 'ltrapi' name 'LTR_GetLastUnixTimeMark';

  Function priv_CrateGetArray(var ltr: TLTR; address : LongWord; out buf; size : LongWord): Integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_CrateGetArray';
  Function priv_CratePutArray(var ltr: TLTR; address : LongWord; const buf; size : LongWord): Integer; {$I ltrapi_callconvention}; external 'ltrapi' name 'LTR_CratePutArray';


  Procedure LTR_FillSerial(var ltr: TLTR; csn : string);
  var
    i: Integer;
  begin
     for i:=0 to SERIAL_NUMBER_SIZE-1 do     //устанавливаем серийный номер крейта
     begin
       if i < Length(csn) then
       begin
          ltr.csn[i] := AnsiChar(csn[i+1]);
       end
       else
       begin
          ltr.csn[i] := AnsiChar(0);
       end;
     end;
  end;



  Function LTR_Init(out ltr: TLTR):integer; overload;
  begin
    LTR_Init := priv_Init(ltr);
  end;

  Function LTR_Open(var ltr: TLTR):integer; overload;
  begin
    LTR_Open := priv_Open(ltr);
  end;

  Function LTR_Close(var ltr: TLTR):integer; overload;
  begin
    LTR_Close := priv_Close(ltr);
  end;

  Function LTR_IsOpened(var ltr: TLTR):integer; overload;
  begin
    LTR_IsOpened := priv_IsOpened(ltr);
  end;

  Function LTR_GetCrates(var ltr: TLTR; var csn: array of string; out crates_cnt: Integer):integer;
  var
    serial_array: PAnsiChar;
    res,i: Integer;
  begin
    crates_cnt:=0;
    serial_array:=GetMemory(CRATE_MAX*SERIAL_NUMBER_SIZE);
    res:= priv_GetCrates(ltr, serial_array);
    if res = LTR_OK then
    begin
        for i:=0 to CRATE_MAX-1 do
        begin
            if (serial_array[SERIAL_NUMBER_SIZE*i]<> AnsiChar(0)) then   //добавляем в список все непустые серийники
            begin
                if Length(csn) > crates_cnt then
                begin
                  csn[crates_cnt] := string(StrPas(PAnsiChar(@serial_array[SERIAL_NUMBER_SIZE*i])));
                end;
                crates_cnt:=crates_cnt+1;
            end;
        end;
    end;
    FreeMemory(serial_array);
    LTR_GetCrates := res;
  end;

  Function LTR_GetCrateModules(var ltr: TLTR; var mids: array of Word):integer; overload;
  var
    mid_array: p_crate_mids_array;
    res,i: Integer;
  begin
    mid_array:=GetMemory(MODULE_MAX*2);
    res:= priv_GetCrateModules(ltr, mid_array);
    if res = LTR_OK then
    begin
        for i:=0 to Length(mids)-1 do
        begin
            if (i < MODULE_MAX) then   //добавляем в список все непустые серийники
            begin
                mids[i]:=mid_array^[i];
            end
            else
            begin
                mids[i]:=MID_EMPTY;
            end;
        end;
    end;
    FreeMemory(mid_array);
    LTR_GetCrateModules := res;
  end;

  Function LTR_GetCrateInfo(var ltr:TLTR; out CrateInfo:TCRATE_INFO):integer; overload;
  begin
    LTR_GetCrateInfo := priv_GetCrateInfo(ltr, Crateinfo);
  end;

  Function LTR_Config(var ltr:TLTR; var conf : TLTR_CONFIG):integer; overload;
  begin
    LTR_Config := priv_Config(ltr, conf);
  end;

  Function LTR_StartSecondMark(var ltr:TLTR; mode:en_LTR_MarkMode):integer; overload;
  begin
    LTR_StartSecondMark := priv_StartSecondMark(ltr, mode);
  end;

  Function LTR_StopSecondMark(var ltr:TLTR):integer; overload;
  begin
    LTR_StopSecondMark := priv_StopSecondMark(ltr);
  end;

  Function LTR_MakeStartMark(var ltr:TLTR; mode:en_LTR_MarkMode):integer; overload;
  begin
    LTR_MakeStartMark := priv_MakeStartMark(ltr, mode);
  end;



  Function LTR_GetListOfIPCrates(var ltr: TLTR; ip_net : LongWord; ip_mask:LongWord;
                                 out entries_found: LongWord;
                                 out entries_returned: LongWord;
                                 out info_array: array of TIPCRATE_ENTRY):integer;
  var
    ip_arr: p_crate_ipentry_array;
    res, i: Integer;
  begin
    if Length(info_array) > 0 then
    begin
      ip_arr:=GetMemory(Length(info_array)*SizeOf(TIPCRATE_ENTRY));
      res:= priv_GetListOfIPCrates(ltr, Length(info_array),  ip_net, ip_mask,
                                  entries_found, entries_returned, ip_arr);
      if res = LTR_OK then
      begin
        for i:=0 to entries_returned-1 do
          info_array[i] := ip_arr^[i];
      end;
      FreeMemory(ip_arr);
    end
    else
    begin
      res:=priv_GetListOfIPCrates(ltr, 0,  ip_net, ip_mask, entries_found,
                                  entries_returned, nil);
    end;

    LTR_GetListOfIPCrates:=res;
  end;


  Function LTR_AddIPCrate(var ltr: TLTR; ip_addr: LongWord; flags: LongWord; permanent:LongBool):integer; overload;
  begin
    LTR_AddIPCrate:=priv_AddIPCrate(ltr, ip_addr, flags, permanent);
  end;
  Function LTR_DeleteIPCrate(var ltr: TLTR; ip_addr: LongWord; permanent:LongBool):integer; overload;
  begin
    LTR_DeleteIPCrate:=priv_DeleteIPCrate(ltr, ip_addr, permanent);
  end;
  Function LTR_ConnectIPCrate(var ltr: TLTR; ip_addr:LongWord):integer; overload;
  begin
    LTR_ConnectIPCrate:=priv_ConnectIPCrate(ltr, ip_addr);
  end;
  Function LTR_DisconnectIPCrate(var ltr: TLTR; ip_addr:LongWord):integer; overload;
  begin
    LTR_DisconnectIPCrate:=priv_DisconnectIPCrate(ltr, ip_addr);
  end;
  Function LTR_ConnectAllAutoIPCrates(var ltr: TLTR):integer; overload;
  begin
    LTR_ConnectAllAutoIPCrates:=priv_ConnectAllAutoIPCrates(ltr);
  end;
  Function LTR_DisconnectAllIPCrates(var ltr: TLTR):integer; overload;
  begin
    LTR_DisconnectAllIPCrates:=priv_DisconnectAllIPCrates(ltr);
  end;
  Function LTR_SetIPCrateFlags(var ltr: TLTR; ip_addr:LongWord; new_flags:LongWord; permanent:LongBool):integer; overload;
  begin
    LTR_SetIPCrateFlags:=priv_SetIPCrateFlags(ltr, ip_addr, new_flags, permanent);
  end;

  Function LTR_GetLogLevel(var ltr: TLTR; out level:integer):integer; overload;
  begin
    LTR_GetLogLevel:=priv_GetLogLevel(ltr, level);
  end;
  Function LTR_SetLogLevel(var ltr: TLTR; level:integer;  permanent: LongBool):integer; overload;
  begin
    LTR_SetLogLevel:=priv_SetLogLevel(ltr, level, permanent);
  end;
  Function LTR_ServerRestart(var ltr: TLTR):integer; overload;
  begin
    LTR_ServerRestart:=priv_ServerRestart(ltr);
  end;
  Function LTR_ServerShutdown(var ltr: TLTR):integer; overload;
  begin
    LTR_ServerShutdown:=priv_ServerShutdown(ltr);
  end;
  Function LTR_SetTimeout(var ltr: TLTR; ms:LongWord):integer; overload;
  begin
    LTR_SetTimeout:=priv_SetTimeout(ltr, ms);
  end;
  Function LTR_SetServerProcessPriority(var ltr: TLTR; Priority:LongWord):integer; overload;
  begin
    LTR_SetServerProcessPriority:=priv_SetServerProcessPriority(ltr, priority);
  end;
  Function LTR_GetServerProcessPriority(var ltr: TLTR; out Priority:LongWord):integer; overload;
  begin
    LTR_GetServerProcessPriority:=priv_GetServerProcessPriority(ltr, priority);
  end;
  Function LTR_GetServerVersion(var ltr: TLTR; out version:LongWord):integer; overload;
  begin
    LTR_GetServerVersion:=priv_GetServerVersion(ltr, version);
  end;
  Function LTR_GetLastUnixTimeMark(var ltr: TLTR; out unixtime:UInt64):integer; overload;
  begin
    LTR_GetLastUnixTimeMark:=priv_GetLastUnixTimeMark(ltr, unixtime);
  end;

  Function LTR_GetErrorString(error:integer):string;
  begin
    LTR_GetErrorString:= string(_get_err_str(error));
  end;

  Function LTR_CrateGetArray(var ltr: TLTR; address : LongWord; out buf: array of Byte; size : LongWord): Integer;
  begin
     LTR_CrateGetArray := priv_CrateGetArray(ltr, address, buf, size);
  end;

  Function LTR_CratePutArray(var ltr: TLTR; address : LongWord; const buf: array of Byte; size : LongWord): Integer;
  begin
    LTR_CratePutArray := priv_CratePutArray(ltr, address, buf, size);
  end;

end.


