unit ltrapidefine;
interface
uses SysUtils;

const


LTRD_ADDR_LOCAL   = $7F000001;
LTRD_ADDR_DEFAULT = LTRD_ADDR_LOCAL;
LTRD_PORT_DEFAULT = 11111;


LTR_CRATES_MAX             = 16; {  ������������ ���������� �������,
                                          ������� ����� �������� � �������
                                          ������� LTR_GetCrates(). ��� ltrd
                                          ����� �������� ������ �������� ���-��
                                          ������� � ������� LTR_GetCratesWithInfo() }
LTR_MODULES_PER_CRATE_MAX  = 16; // ������������ ���������� ������� � ����� ������


{ ��������� �������� ����� ������ ��� ���������� ����� ��������
  (�������� � �����, ����� ��� �� ������ ������������� ������
  �������, ������� ���������� �� ���� �����, �������� ������������ "SERVER_CONTROL" }
LTR_CSN_SERVER_CONTROL     = '#SERVER_CONTROL';



// ���� ������� ������-������
LTR_CC_CHNUM_CONTROL              =  0;      // ����� ��� �������� ����������� �������� ������ ��� ltrd
LTR_CC_CHNUM_MODULE1              =  1;      // ����� ��� ������ c ������� � ����� 1
LTR_CC_CHNUM_MODULE2              =  2;      // ����� ��� ������ c ������� � ����� 2
LTR_CC_CHNUM_MODULE3              =  3;      // ����� ��� ������ c ������� � ����� 3
LTR_CC_CHNUM_MODULE4              =  4;      // ����� ��� ������ c ������� � ����� 4
LTR_CC_CHNUM_MODULE5              =  5;      // ����� ��� ������ c ������� � ����� 5
LTR_CC_CHNUM_MODULE6              =  6;      // ����� ��� ������ c ������� � ����� 6
LTR_CC_CHNUM_MODULE7              =  7;      // ����� ��� ������ c ������� � ����� 7
LTR_CC_CHNUM_MODULE8              =  8;      // ����� ��� ������ c ������� � ����� 8
LTR_CC_CHNUM_MODULE9              =  9;      // ����� ��� ������ c ������� � ����� 9
LTR_CC_CHNUM_MODULE10             = 10;      // ����� ��� ������ c ������� � ����� 10
LTR_CC_CHNUM_MODULE11             = 11;      // ����� ��� ������ c ������� � ����� 11
LTR_CC_CHNUM_MODULE12             = 12;      // ����� ��� ������ c ������� � ����� 12
LTR_CC_CHNUM_MODULE13             = 13;      // ����� ��� ������ c ������� � ����� 13
LTR_CC_CHNUM_MODULE14             = 14;      // ����� ��� ������ c ������� � ����� 14
LTR_CC_CHNUM_MODULE15             = 15;      // ����� ��� ������ c ������� � ����� 15
LTR_CC_CHNUM_MODULE16             = 16;      // ����� ��� ������ c ������� � ����� 16
LTR_CC_CHNUM_USERDATA             = 18;      // ����� ��� ������ � ������������� ��� ���������������� ������

LTR_CC_FLAG_RAW_DATA              = $4000;   { ���� ������� - ltrd �������� �������
                                               ��� ������, ������� �������� �� ������,
                                               ��� �������� �� ������� }

LTR_CC_IFACE_USB                  = $0100;  { ����� ��������, ��� ���������� ������ ����
                                              �� USB-����������}
LTR_CC_IFACE_ETH                  = $0200;  { ����� ��������, ��� ���������� ������ ����
                                              �� Ethernet (TCP/IP) }


LTR_FLAG_RBUF_OVF                 = (1 shl 0);  // ���� ������������ ������ �������
LTR_FLAG_RFULL_DATA               = (1 shl 1);  { ���� ��������� ������ � ������ �������
                                                 � ������� LTR_GetCrateRawData }



// �������������� �������
LTR_MID_EMPTY          =       0    ; // ������������� ���������������
LTR_MID_IDENTIFYING    =       $FFFF; // ������ � �������� ����������� ID
LTR_MID_LTR01          =       $0101; // ������������� ������ LTR01
LTR_MID_LTR11          =       $0B0B; // ������������� ������ LTR11
LTR_MID_LTR22          =       $1616; // ������������� ������ LTR22
LTR_MID_LTR24          =       $1818; // ������������� ������ LTR24
LTR_MID_LTR25          =       $1919; // ������������� ������ LTR25
LTR_MID_LTR27          =       $1B1B; // ������������� ������ LTR27
LTR_MID_LTR34          =       $2222; // ������������� ������ LTR34
LTR_MID_LTR35          =       $2323; // ������������� ������ LTR35
LTR_MID_LTR41          =       $2929; // ������������� ������ LTR41
LTR_MID_LTR42          =       $2A2A; // ������������� ������ LTR42
LTR_MID_LTR43          =       $2B2B; // ������������� ������ LTR43
LTR_MID_LTR51          =       $3333; // ������������� ������ LTR51
LTR_MID_LTR114         =       $7272; // ������������� ������ LTR114
LTR_MID_LTR210         =       $D2D2; // ������������� ������ LTR210
LTR_MID_LTR212         =       $D4D4; // ������������� ������ LTR212


// �������� ������ (��� TCRATE_INFO)
LTR_CRATE_TYPE_UNKNOWN                      =0;
LTR_CRATE_TYPE_LTR010                       =10;
LTR_CRATE_TYPE_LTR021                       =21;
LTR_CRATE_TYPE_LTR030                       =30;
LTR_CRATE_TYPE_LTR031                       =31;
LTR_CRATE_TYPE_LTR032                       =32;
LTR_CRATE_TYPE_LTR_CU_1                     =40;
LTR_CRATE_TYPE_LTR_CEU_1                    =41;
LTR_CRATE_TYPE_BOOTLOADER                   =99;

// ��������� ������ (��� TCRATE_INFO)
LTR_CRATE_IFACE_UNKNOWN                     =0;
LTR_CRATE_IFACE_USB                         =1;
LTR_CRATE_IFACE_TCPIP                       =2;

// ��������� ������ (��� TIPCRATE_ENTRY)
LTR_CRATE_IP_STATUS_OFFLINE                 =0;
LTR_CRATE_IP_STATUS_CONNECTING              =1;
LTR_CRATE_IP_STATUS_ONLINE                  =2;
LTR_CRATE_IP_STATUS_ERROR                   =3;

// ����� ���������� ������ (��� TIPCRATE_ENTRY � ������� CONTROL_COMMAND_IP_SET_FLAGS)
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

LTR_CRATE_THERM_MAX_CNT             = 8; { ������������ ���-�� �����������
                                           � ������, ��������� ������� ������������ � ���������� }

LTR_MODULE_FLAGS_HIGH_BAUD          = $0001;   { �������, ��� ������ ���������� ������� �������� }
LTR_MODULE_FLAGS_USE_HARD_SEND_FIFO = $0100;   { �������, ��� ������ ���������� ����������
                                                 ����������� ����������� FIFO �� ��������
                                                 ������ }
LTR_MODULE_FLAGS_USE_SYNC_MARK      = $0200;    { �������, ��� ������ ������������
                                                  ������������� ����������� }







{---------- ���������, ����������� ������ ��� �������� �������������  ---------}
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

// �������������� �������
MID_EMPTY          =       0     ;       // ������������� ���������������
MID_LTR11          =       $0B0B ;       // ������������� ������ LTR11
MID_LTR22          =       $1616 ;       // ������������� ������ LTR22
MID_LTR24          =       $1818 ;       // ������������� ������ LTR24
MID_LTR27          =       $1B1B ;       // ������������� ������ LTR27
MID_LTR34          =       $2222 ;       // ������������� ������ LTR34
MID_LTR35          =       $2323 ;       // ������������� ������ LTR35
MID_LTR41          =       $2929 ;       // ������������� ������ LTR41
MID_LTR42          =       $2A2A ;       // ������������� ������ LTR42
MID_LTR43          =       $2B2B ;       // ������������� ������ LTR43
MID_LTR51          =       $3333 ;       // ������������� ������ LTR51
MID_LTR114         =       $7272 ;       // ������������� ������ LTR114
MID_LTR210         =       $D2D2 ;       // ������������� ������ LTR210
MID_LTR212         =       $D4D4 ;       // ������������� ������ LTR212


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
