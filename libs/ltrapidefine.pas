unit ltrapidefine;
interface
uses SysUtils;

const


LTRD_ADDR_LOCAL   = $7F000001;
LTRD_ADDR_DEFAULT = LTRD_ADDR_LOCAL;
LTRD_PORT_DEFAULT = 11111;


LTR_CRATES_MAX             = 16; {  Максимальное количество крейтов,
                                          которое можно получить с помощью
                                          функции LTR_GetCrates(). Для ltrd
                                          можно получить список большего кол-ва
                                          крейтов с помощью LTR_GetCratesWithInfo() }
LTR_MODULES_PER_CRATE_MAX  = 16; // Максимальное количество модулей в одном крейте


{ Фиктивный серийный номер крейта для управления самим сервером
  (работает и тогда, когда нет ни одного подключенного крейта
  Команды, которые рассчитаны на этот режим, помечены комментарием "SERVER_CONTROL" }
LTR_CSN_SERVER_CONTROL     = '#SERVER_CONTROL';



// типы каналов клиент-сервер
LTR_CC_CHNUM_CONTROL              =  0;      // канал для передачи управляющих запросов крейту или ltrd
LTR_CC_CHNUM_MODULE1              =  1;      // канал для работы c модулем в слоте 1
LTR_CC_CHNUM_MODULE2              =  2;      // канал для работы c модулем в слоте 2
LTR_CC_CHNUM_MODULE3              =  3;      // канал для работы c модулем в слоте 3
LTR_CC_CHNUM_MODULE4              =  4;      // канал для работы c модулем в слоте 4
LTR_CC_CHNUM_MODULE5              =  5;      // канал для работы c модулем в слоте 5
LTR_CC_CHNUM_MODULE6              =  6;      // канал для работы c модулем в слоте 6
LTR_CC_CHNUM_MODULE7              =  7;      // канал для работы c модулем в слоте 7
LTR_CC_CHNUM_MODULE8              =  8;      // канал для работы c модулем в слоте 8
LTR_CC_CHNUM_MODULE9              =  9;      // канал для работы c модулем в слоте 9
LTR_CC_CHNUM_MODULE10             = 10;      // канал для работы c модулем в слоте 10
LTR_CC_CHNUM_MODULE11             = 11;      // канал для работы c модулем в слоте 11
LTR_CC_CHNUM_MODULE12             = 12;      // канал для работы c модулем в слоте 12
LTR_CC_CHNUM_MODULE13             = 13;      // канал для работы c модулем в слоте 13
LTR_CC_CHNUM_MODULE14             = 14;      // канал для работы c модулем в слоте 14
LTR_CC_CHNUM_MODULE15             = 15;      // канал для работы c модулем в слоте 15
LTR_CC_CHNUM_MODULE16             = 16;      // канал для работы c модулем в слоте 16
LTR_CC_CHNUM_USERDATA             = 18;      // канал для работы с псевдомодулем для пользовательских данных

LTR_CC_FLAG_RAW_DATA              = $4000;   { флаг отладки - ltrd передает клиенту
                                               все данные, которые приходят от крейта,
                                               без разбивки по модулям }

LTR_CC_IFACE_USB                  = $0100;  { явное указание, что соединение должно быть
                                              по USB-интерфейсу}
LTR_CC_IFACE_ETH                  = $0200;  { явное указание, что соединение должно быть
                                              по Ethernet (TCP/IP) }


LTR_FLAG_RBUF_OVF                 = (1 shl 0);  // флаг переполнения буфера клиента
LTR_FLAG_RFULL_DATA               = (1 shl 1);  { флаг получения данных в полном формате
                                                 в функции LTR_GetCrateRawData }



// идентификаторы модулей
LTR_MID_EMPTY          =       0    ; // идентификатор соответствующий
LTR_MID_IDENTIFYING    =       $FFFF; // модуль в процессе определения ID
LTR_MID_LTR01          =       $0101; // идентификатор модуля LTR01
LTR_MID_LTR11          =       $0B0B; // идентификатор модуля LTR11
LTR_MID_LTR22          =       $1616; // идентификатор модуля LTR22
LTR_MID_LTR24          =       $1818; // идентификатор модуля LTR24
LTR_MID_LTR25          =       $1919; // идентификатор модуля LTR25
LTR_MID_LTR27          =       $1B1B; // идентификатор модуля LTR27
LTR_MID_LTR34          =       $2222; // идентификатор модуля LTR34
LTR_MID_LTR35          =       $2323; // идентификатор модуля LTR35
LTR_MID_LTR41          =       $2929; // идентификатор модуля LTR41
LTR_MID_LTR42          =       $2A2A; // идентификатор модуля LTR42
LTR_MID_LTR43          =       $2B2B; // идентификатор модуля LTR43
LTR_MID_LTR51          =       $3333; // идентификатор модуля LTR51
LTR_MID_LTR114         =       $7272; // идентификатор модуля LTR114
LTR_MID_LTR210         =       $D2D2; // идентификатор модуля LTR210
LTR_MID_LTR212         =       $D4D4; // идентификатор модуля LTR212


// описание крейта (для TCRATE_INFO)
LTR_CRATE_TYPE_UNKNOWN                      =0;
LTR_CRATE_TYPE_LTR010                       =10;
LTR_CRATE_TYPE_LTR021                       =21;
LTR_CRATE_TYPE_LTR030                       =30;
LTR_CRATE_TYPE_LTR031                       =31;
LTR_CRATE_TYPE_LTR032                       =32;
LTR_CRATE_TYPE_LTR_CU_1                     =40;
LTR_CRATE_TYPE_LTR_CEU_1                    =41;
LTR_CRATE_TYPE_BOOTLOADER                   =99;

// интерфейс крейта (для TCRATE_INFO)
LTR_CRATE_IFACE_UNKNOWN                     =0;
LTR_CRATE_IFACE_USB                         =1;
LTR_CRATE_IFACE_TCPIP                       =2;

// состояние крейта (для TIPCRATE_ENTRY)
LTR_CRATE_IP_STATUS_OFFLINE                 =0;
LTR_CRATE_IP_STATUS_CONNECTING              =1;
LTR_CRATE_IP_STATUS_ONLINE                  =2;
LTR_CRATE_IP_STATUS_ERROR                   =3;

// флаги параметров крейта (для TIPCRATE_ENTRY и команды CONTROL_COMMAND_IP_SET_FLAGS)
LTR_CRATE_IP_FLAG_AUTOCONNECT               =$00000001;
LTR_CRATE_IP_FLAG__VALID_BITS_              =$00000001;



LTR_MODULE_NAME_SIZE                = 16;

LTR_CRATE_DEVNAME_SIZE              = 32;
LTR_CRATE_SERIAL_SIZE               = 16;
LTR_CRATE_SOFTVER_SIZE              = 32;
LTR_CRATE_REVISION_SIZE             = 16;
LTR_CRATE_IMPLEMENTATION_SIZE       = 16;
LTR_CRATE_BOOTVER_SIZE              = 16;
LTR_CRATE_CPUTYPE_SIZE              = 16;
LTR_CRATE_TYPE_NAME                 = 16;
LTR_CRATE_SPECINFO_SIZE             = 48;

LTR_CRATE_FPGA_NAME_SIZE            = 32;
LTR_CRATE_FPGA_VERSION_SIZE         = 32;

LTR_CRATE_THERM_MAX_CNT             = 8; { Максимальное кол-во термометров
                                           в крейте, показания которых отображаются в статистике }

LTR_MODULE_FLAGS_HIGH_BAUD          = $0001;   { признак, что модуль использует высокую скорость }
LTR_MODULE_FLAGS_USE_HARD_SEND_FIFO = $0100;   { признак, что модуль использует статистику
                                                 внутреннего аппаратного FIFO на передачу
                                                 данных }
LTR_MODULE_FLAGS_USE_SYNC_MARK      = $0200;    { признак, что модуль поддерживает
                                                  генерирование синхрометок }







{---------- константы, оставленные только для обратной совместимости  ---------}
{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
CC_CONTROL         =  LTR_CC_CHNUM_CONTROL ;
CC_MODULE1         =  LTR_CC_CHNUM_MODULE1 ;
CC_MODULE2         =  LTR_CC_CHNUM_MODULE2 ;
CC_MODULE3         =  LTR_CC_CHNUM_MODULE3 ;
CC_MODULE4         =  LTR_CC_CHNUM_MODULE4 ;
CC_MODULE5         =  LTR_CC_CHNUM_MODULE5 ;
CC_MODULE6         =  LTR_CC_CHNUM_MODULE6 ;
CC_MODULE7         =  LTR_CC_CHNUM_MODULE7 ;
CC_MODULE8         =  LTR_CC_CHNUM_MODULE8 ;
CC_MODULE9         =  LTR_CC_CHNUM_MODULE9 ;
CC_MODULE10        =  LTR_CC_CHNUM_MODULE10 ;
CC_MODULE11        =  LTR_CC_CHNUM_MODULE11 ;
CC_MODULE12        =  LTR_CC_CHNUM_MODULE12 ;
CC_MODULE13        =  LTR_CC_CHNUM_MODULE13 ;
CC_MODULE14        =  LTR_CC_CHNUM_MODULE14 ;
CC_MODULE15        =  LTR_CC_CHNUM_MODULE15 ;
CC_MODULE16        =  LTR_CC_CHNUM_MODULE16 ;

CC_RAW_DATA_FLAG   =       LTR_CC_FLAG_RAW_DATA;
CRATE_MAX          =       LTR_CRATES_MAX;
MODULE_MAX         =       LTR_MODULES_PER_CRATE_MAX;
FLAG_RBUF_OVF      =       LTR_FLAG_RBUF_OVF;
FLAG_RFULL_DATA    =       LTR_FLAG_RFULL_DATA;

// идентификаторы модулей
MID_EMPTY          =       0     ;       // идентификатор соответствующий
MID_LTR11          =       $0B0B ;       // идентификатор модуля LTR11
MID_LTR22          =       $1616 ;       // идентификатор модуля LTR22
MID_LTR24          =       $1818 ;       // идентификатор модуля LTR24
MID_LTR27          =       $1B1B ;       // идентификатор модуля LTR27
MID_LTR34          =       $2222 ;       // идентификатор модуля LTR34
MID_LTR35          =       $2323 ;       // идентификатор модуля LTR35
MID_LTR41          =       $2929 ;       // идентификатор модуля LTR41
MID_LTR42          =       $2A2A ;       // идентификатор модуля LTR42
MID_LTR43          =       $2B2B ;       // идентификатор модуля LTR43
MID_LTR51          =       $3333 ;       // идентификатор модуля LTR51
MID_LTR114         =       $7272 ;       // идентификатор модуля LTR114
MID_LTR210         =       $D2D2 ;       // идентификатор модуля LTR210
MID_LTR212         =       $D4D4 ;       // идентификатор модуля LTR212


CSN_SERVER_CONTROL   =  LTR_CSN_SERVER_CONTROL;


SERIAL_NUMBER_SIZE   =  LTR_CRATE_SERIAL_SIZE;



SADDR_LOCAL        =       LTRD_ADDR_LOCAL;
SADDR_DEFAULT      =       LTRD_ADDR_DEFAULT;
SPORT_DEFAULT      =       LTRD_PORT_DEFAULT;


CRATE_TYPE_UNKNOWN                      = LTR_CRATE_TYPE_UNKNOWN;
CRATE_TYPE_LTR010                       = LTR_CRATE_TYPE_LTR010;
CRATE_TYPE_LTR021                       = LTR_CRATE_TYPE_LTR021;
CRATE_TYPE_LTR030                       = LTR_CRATE_TYPE_LTR030;
CRATE_TYPE_LTR031                       = LTR_CRATE_TYPE_LTR031;
CRATE_TYPE_LTR032                       = LTR_CRATE_TYPE_LTR032;
CRATE_TYPE_LTR_CU_1                     = LTR_CRATE_TYPE_LTR_CU_1;
CRATE_TYPE_LTR_CEU_1                    = LTR_CRATE_TYPE_LTR_CEU_1;
CRATE_TYPE_BOOTLOADER                   = LTR_CRATE_TYPE_BOOTLOADER;

CRATE_IFACE_UNKNOWN                     = LTR_CRATE_IFACE_UNKNOWN;
CRATE_IFACE_USB                         = LTR_CRATE_IFACE_USB;
CRATE_IFACE_TCPIP                       = LTR_CRATE_IFACE_TCPIP;

CRATE_IP_STATUS_OFFLINE                 = LTR_CRATE_IP_STATUS_OFFLINE;
CRATE_IP_STATUS_CONNECTING              = LTR_CRATE_IP_STATUS_CONNECTING;
CRATE_IP_STATUS_ONLINE                  = LTR_CRATE_IP_STATUS_ONLINE;
CRATE_IP_STATUS_ERROR                   = LTR_CRATE_IP_STATUS_ERROR;

CRATE_IP_FLAG_AUTOCONNECT               = LTR_CRATE_IP_FLAG_AUTOCONNECT;
CRATE_IP_FLAG__VALID_BITS_              = LTR_CRATE_IP_FLAG__VALID_BITS_;

{$ENDIF}

implementation
end.
