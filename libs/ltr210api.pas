unit ltr210api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
  // ������ ������ � ������ ������ � ��������� TINFO_LTR210
  LTR210_NAME_SIZE                 = 8;
  // ������ ������ � �������� ������� ������ � ��������� TINFO_LTR210
  LTR210_SERIAL_SIZE               = 16;
  // ���������� ������� ��� � ����� ������
  LTR210_CHANNEL_CNT               = 2;
  // ���������� ���������� ��������� ���
  LTR210_RANGE_CNT                 = 5;

  // ��� ��������� ������� ���, ��������������� ������������� ���������� ��������� ���������
  LTR210_ADC_SCALE_CODE_MAX        = 13000;
  // ������������ �������� �������� ������� ���
  LTR210_ADC_FREQ_DIV_MAX          = 9;
  // ������������ �������� ������������ ������������ ������ �� ���
  LTR210_ADC_DCM_CNT_MAX           = 256;

  // ������� � ������, ������������ ������� �������� ������� �������� ���
  LTR210_ADC_FREQ_HZ               = 10000000;
  // ������� � ������, ������������ ������� �������� ������� ���������� ������ � ������ LTR210_SYNC_MODE_PERIODIC
  LTR210_FRAME_FREQ_HZ             = 1000000;
  // ������ ����������� ������������ ������ ������ � �������� ���
  LTR210_INTERNAL_BUFFER_SIZE      = 16777216;
  // ������������ ������ �����, ������� ����� ���������� � ������������� ������
  LTR210_FRAME_SIZE_MAX            = (16777216 - 512);


  { -------------- ���� ������, ����������� ��� LTR210 ------------------------}
  LTR210_ERR_INVALID_SYNC_MODE          = -10500; // ����� �������� ��� ������� ����� �����
  LTR210_ERR_INVALID_GROUP_MODE         = -10501; // ����� �������� ��� ������ ������ ������ � ������� ������
  LTR210_ERR_INVALID_ADC_FREQ_DIV       = -10502; // ������ �������� �������� �������� ������� ���
  LTR210_ERR_INVALID_CH_RANGE           = -10503; // ����� �������� ��� ��������� ������ ���
  LTR210_ERR_INVALID_CH_MODE            = -10504; // ����� �������� ����� ��������� ������
  LTR210_ERR_SYNC_LEVEL_EXCEED_RANGE    = -10505; // ������������� ������� ���������� ������������� ������� �� ������� �������������� ���������
  LTR210_ERR_NO_ENABLED_CHANNEL         = -10506; // �� ���� ����� ��� �� ��� ��������
  LTR210_ERR_PLL_NOT_LOCKED             = -10507; // ������ ������� PLL
  LTR210_ERR_INVALID_RECV_DATA_CNTR     = -10508; // �������� �������� �������� � �������� ������
  LTR210_ERR_RECV_UNEXPECTED_CMD        = -10509; // ����� ���������������� ������� � ������ ������
  LTR210_ERR_FLASH_INFO_SIGN            = -10510; // �������� ������� ���������� � ������ �� Flash-������
  LTR210_ERR_FLASH_INFO_SIZE            = -10511; // �������� ������ ����������� �� Flash-������ ���������� � ������
  LTR210_ERR_FLASH_INFO_UNSUP_FORMAT    = -10512; // ���������������� ������ ���������� � ������ �� Flash-������
  LTR210_ERR_FLASH_INFO_CRC             = -10513; // ������ �������� CRC ���������� � ������ �� Flash-������
  LTR210_ERR_FLASH_INFO_VERIFY          = -10514; // ������ �������� ������ ���������� � ������ �� Flash-������
  LTR210_ERR_CHANGE_PAR_ON_THE_FLY      = -10515; // ����� ����������� ���������� ������ �������� �� ����
  LTR210_ERR_INVALID_ADC_DCM_CNT        = -10516; // ����� �������� ����������� ������������ ������ ���
  LTR210_ERR_MODE_UNSUP_ADC_FREQ        = -10517; // ������������� ����� �� ������������ �������� ������� ���
  LTR210_ERR_INVALID_FRAME_SIZE         = -10518; // ������� ����� ������ �����
  LTR210_ERR_INVALID_HIST_SIZE          = -10519; // ������� ����� ������ �����������
  LTR210_ERR_INVALID_INTF_TRANSF_RATE   = -10520; // ������� ������ �������� �������� ������ ������ � ���������
  LTR210_ERR_INVALID_DIG_BIT_MODE       = -10321;  // ������� ����� ����� ������ ��������������� ����
  LTR210_ERR_SYNC_LEVEL_LOW_EXCEED_HIGH = -10522; // ������ ����� ���������� ������������� ��������� �������
  LTR210_ERR_KEEPALIVE_TOUT_EXCEEDED    = -10523; // �� ������ �� ������ ������� �� ������ �� �������� ��������
  LTR210_ERR_WAIT_FRAME_TIMEOUT         = -10524; // �� ������� ��������� ������� ����� �� �������� ����� */
  LTR210_ERR_FRAME_STATUS               = -10525; // ����� ������� � �������� ����� ��������� �� ������ ������ */


  { --------------- �������� ������ ��� ---------------------}
  LTR210_ADC_RANGE_10     = 0; // �������� +/- 10 �
  LTR210_ADC_RANGE_5      = 1; // �������� +/- 5 �
  LTR210_ADC_RANGE_2      = 2; // �������� +/- 2 �
  LTR210_ADC_RANGE_1      = 3; // �������� +/- 1 �
  LTR210_ADC_RANGE_0_5    = 4;  // �������� +/- 0.5 �

  { --------------- ����� ��������� ������ ��� -------------}
  LTR210_CH_MODE_ACDC    = 0; // ��������� ���������� � ���������� ������������ (�������� ����)
  LTR210_CH_MODE_AC      = 1; // ������� ���������� ������������ (�������� ����)
  LTR210_CH_MODE_ZERO    = 2;  // ����� ��������� ������������ ����



  { --------------- ����� ������� ����� ������ -------------------}
  LTR210_SYNC_MODE_INTERNAL     = 0; // ����� ����� ����� �� ����������� �������, ������������ ������� LTR210_FrameStart()
  LTR210_SYNC_MODE_CH1_RISE     = 1; // ����� ����� ����� �� ������ ������� ������������ ������ ������������� �� ������ ���������� ������
  LTR210_SYNC_MODE_CH1_FALL     = 2; // ����� ����� ����� �� ����� ������� ������������ ������ ������������� �� ������ ���������� ������
  LTR210_SYNC_MODE_CH2_RISE     = 3; // ����� ����� ����� �� ������ ������� ������������ ������ ������������� �� ������ ���������� ������
  LTR210_SYNC_MODE_CH2_FALL     = 4; // ����� ����� ����� �� ����� ������� ������������ ������ ������������� �� ������ ���������� ������
  LTR210_SYNC_MODE_SYNC_IN_RISE = 5; // ����� ����� ����� �� ������ ��������� ������� �� ����� SYNC (�� �� ������� ������!)
  LTR210_SYNC_MODE_SYNC_IN_FALL = 6; // ����� ����� ����� �� ����� ��������� ������� �� ����� SYNC (�� �� ������� ������!)
  LTR210_SYNC_MODE_PERIODIC     = 7; // ����� �������������� ����� ������ � ������������� �������� ���������� ������
  LTR210_SYNC_MODE_CONTINUOUS   = 8; // ����� ������������ ����� ������


  { ---------------- ����� ������ ������ � ������ ------------------}
  LTR210_GROUP_MODE_SINGLE      = 0; // �������� ������ ���� ����������� ������
  LTR210_GROUP_MODE_MASTER      = 1; // ����� �������
  LTR210_GROUP_MODE_SLAVE       = 2; // ����� ������������ ������


  {----------------- ���� ����������� ������� ---------------------}
  LTR210_RECV_EVENT_TIMEOUT   = 0;  // �� ������ �������� ������� �� ������ �� ��������� �����
  LTR210_RECV_EVENT_KEEPALIVE = 1;  // ������ ���������� ������ ����� �� ������
  LTR210_RECV_EVENT_SOF       = 2;   // ������ ������ ���������� �����


  { ---------------- ����, ������������ ������������ ��������� ����� -------}
  LTR210_FRAME_RESULT_OK       = 0; // ���� ������ ��� ������. ������ ����� �������������
  LTR210_FRAME_RESULT_PENDING  = 1; // � �������������� ������ �� ���� �������� ����� �����.
  LTR210_FRAME_RESULT_ERROR    = 2;  // ���� ������ � �������. ������ ����� �� �������������.

  {----------------- ����� ������� ----------------------------------}
  LTR210_STATUS_FLAG_PLL_LOCK      = $0001; // ������� ������� PLL � ������ �������� �������
  LTR210_STATUS_FLAG_PLL_LOCK_HOLD = $0002; // �������, ��� ������ PLL ��  �������� � ������� ���������� ������� �������.
  LTR210_STATUS_FLAG_OVERLAP       = $0004; // �������, ��� ������� ������ ������� ������� ������
  LTR210_STATUS_FLAG_SYNC_SKIP     = $0008; // �������, ��� �� ����� ������ ����� �������� ���� �� ���� �������������, ������� ���� ���������.
  LTR210_STATUS_FLAG_INVALID_HIST  = $0010; // ������� ����, ��� ����������� ��������� ����� �� �������������
  LTR210_STATUS_FLAG_CH1_EN        = $0040; // �������, ��� ��������� ������ �� ������� ������
  LTR210_STATUS_FLAG_CH2_EN        = $0080;  // �������, ��� ��������� ������ �� ������� ������



  {---------------- �������������� ����� �������� -------------------}
  // ���������� ������������� �������� ������� ������ ��� ���������� �����
  LTR210_CFG_FLAGS_KEEPALIVE_EN    = $001;
  { ���������� ������ �������������� ������������ ������ �� �����, ����
      ���� �������� �� ���������� � �����. ������ ����� ��������� ����������
      ������������ ������ ����� ���������� �� ������� �������� ��� }
  LTR210_CFG_FLAGS_WRITE_AUTO_SUSP = $002;
  // ��������� ������� ������, � ������� ������ ������ ���������� �������
  LTR210_CFG_FLAGS_TEST_CNTR_MODE  = $100;


  { ----------------- ����� ��������� ������ ------------------------}
  { �������, ��� ����� ��������� ���� ��� � ������. ���� ������ ���� �� ������,
      �� ����� ���������� ���� ���. ��� ���� ��� #LTR210_ADC_SCALE_CODE_MAX
      ������������� ������������ ���������� ��� �������������� ��������. }
  LTR210_PROC_FLAG_VOLT          = $0001;
  { �������, ��� ���������� ��������� ��������� ��� �� ��������� ����������
      � ������ ������������� ������� ��� }
  LTR210_PROC_FLAG_AFC_COR       = $0002;
  { �������, ��� ���������� ��������� �������������� ��������� ���� � �������
      �������� �� State.AdcZeroOffset, ������� ����� ���� �������� � �������
      ������� LTR210_MeasAdcZeroOffset() }
  LTR210_PROC_FLAG_ZERO_OFFS_COR = $0004;
    { �� ��������� LTR210_ProcessData() ������������, ��� �� �� ���������
        ���������� ��� �������� ������, � ��������� ������������� �������� �� ������
        ������ ����������� ����� ������, �� � ����� ��������.
        ���� �������������� �� ��� ������ ��� ���� � ���� ������ �������������
        ��������, �� ����� ������� ������ ����, ����� ������� ���������� ������
        ������ ����� }
  LTR210_PROC_FLAG_NONCONT_DATA  = $0100;



  { --------------- �������� ������ ������ � ��������� ----------------}
  LTR210_INTF_TRANSF_RATE_500K  = 0; // 500 �����/c
  LTR210_INTF_TRANSF_RATE_200K  = 1; // 200 �����/c
  LTR210_INTF_TRANSF_RATE_100K  = 2; // 100 �����/c
  LTR210_INTF_TRANSF_RATE_50K   = 3; // 50  �����/c
  LTR210_INTF_TRANSF_RATE_25K   = 4; // 25  �����/c
  LTR210_INTF_TRANSF_RATE_10K   = 5; // 10  �����/c




  { ---------- ����� ������ ��������������� ���� �� ������� ������ ----------}
  LTR210_DIG_BIT_MODE_ZERO             = 0; // ������ ������� �������� ����
  LTR210_DIG_BIT_MODE_SYNC_IN          = 1; // ��� �������� ��������� ��������� ����� SYNC ������
  LTR210_DIG_BIT_MODE_CH1_LVL          = 2; // ��� ����� "1", ���� ������� ������� ��� 1-�� ������ ��� ���� ������ �������������
  LTR210_DIG_BIT_MODE_CH2_LVL          = 3; // ��� ����� "1", ���� ������� ������� ��� 2-�� ������ ��� ���� ������ �������������
  LTR210_DIG_BIT_MODE_INTERNAL_SYNC    = 4; // ��� ����� "1" ��� ������ ������� � ������ ������������ ����������� ��� ������������� �������������


  {$A4}
  { ������������� ������������ }
  type TLTR210_CBR_COEF = record
    Offset : Single; // ��� ��������
    Scale  : Single; // ����������� �����
  end;

  { ��������� ���-������� }
  type TLTR210_AFC_IIR_COEF = record
    R : Double; // ������������� ������������� ���� �������
    C  : Double; // ������� ������������� ���� �������
  end;

  { ���������� � ������ }
  TINFO_LTR210 = record
    Name : Array [0..LTR210_NAME_SIZE-1] of AnsiChar; // �������� ������ (�������������� ����� ASCII-������)
    Serial : Array [0..LTR210_SERIAL_SIZE-1] of AnsiChar; //�������� ����� ������ (�������������� ����� ASCII-������)
    VerFPGA : Word;  // ������ �������� ���� ������ (������������� ������ ����� �� ��������)
    VerPLD : Byte; //������ �������� PLD
    { ��������� ������������� ������������ (�� ����� ������������� ������
        #LTR210_RANGE_CNT, ��������� - ������) }
    CbrCoef : Array[0..LTR210_CHANNEL_CNT-1] of Array [0..7] of TLTR210_CBR_COEF;
    { ������� � ��, ������� ������������� ���������������� ������������ ��� }
    AfcCoefFreq : Double;
    {   ������������, �������� ���� ��� ������ �� ������� AfcCoefFreq. ������������
        ����� ��������� ��������� ����������� ��������������� ������� �� ���������
        ������� � ��������� ������� ������������� �������. ������������ �����������
        �� Flash-������ ������ ��� �������� ����� � ���. ����� ���� ������������
        ��� ������������� ��� ��� �������������. �� ����� ������������� ������
        LTR210_RANGE_CNT �������������, ��������� - ������. }
    AfcCoef : Array[0..LTR210_CHANNEL_CNT-1] of Array [0..7] of Double;
    AfcIirParam : Array[0..LTR210_CHANNEL_CNT-1] of Array [0..7] of TLTR210_AFC_IIR_COEF;
    Reserved : Array[1..32] of LongWord; // ��������� ���� (�� ������ ���������� �������������)
  end;

  { ��������� ������ ��� }
  TLTR210_CHANNEL_CONFIG = record
    Enabled : Boolean; // �������, �������� �� ���� �� ������� ������
    Range   : Byte;    // ������������� �������� --- ��������� �� #e_LTR210_ADC_RANGE
    Mode    : Byte;    // ����� ��������� --- ��������� �� #e_LTR210_CH_MODE
    DigBitMode : Byte;  // ����� ������ ��������������� ���� �� ������� ������ ������ ������� ������. ��������� �� #e_LTR210_DIG_BIT_MODE
    Reserved: Array [1..4] of Byte;  //��������� ���� (�� ������ ���������� �������������)
    SyncLevelL : Double; //������ ����� ����������� ��� ������� ���������� ������������� � �������
    SyncLevelH : Double; //������� ����� ����������� ��� ������� ���������� ������������� � �������
    Reserved2: array [1..10] of LongWord; // ��������� ���� (�� ������ ���������� �������������) 
  end;

  PTLTR210_CHANNEL_CONFIG = ^TLTR210_CHANNEL_CONFIG;

  { ��������� ������ }
  TLTR210_CONFIG = record
    Ch        : array [0..LTR210_CHANNEL_CNT-1] of TLTR210_CHANNEL_CONFIG; // ��������� ������� ���
    FrameSize : LongWord;  // ������ ����� �� ����� � ����� ��� ���������� �����
    { ������ ��������� ����������� (���������� ����� � ����� �� �����,
        ���������� �� ������������� ������� �������������) }
    HistSize  : LongWord;
    // ������� ����� ����� (������� �������������). ���� �� �������� #e_LTR210_SYNC_MODE
    SyncMode  : Byte;
    // ����� ������ � ������� ������ �������. ���� �� �������� #e_LTR210_GROUP_MODE
    GroupMode : Byte;
    { �������� �������� ������� ���  - 1. ����� ���� � ��������� �� 0
        �� #LTR210_ADC_FREQ_DIV_MAX-1 }
    AdcFreqDiv : Word;
    { �������� ���������� ������������ ������ ��� - 1. ����� ���� � ���������
        �� 0 �� #LTR210_ADC_DCM_CNT_MAX-1.}
    AdcDcmCnt  : LongWord;
    {   �������� ������� ������� ����� ������ ��� SyncMode = #LTR210_SYNC_MODE_PERIODIC.
        ������� ������ ����� 10^6/(FrameFreqDiv + 1) �� }
    FrameFreqDiv : LongWord;
    Flags    : LongWord; // ����� (���������� �� #e_LTR210_CFG_FLAGS)
    { �������� ������ ������ � ��������� (���� �� �������� �� #e_LTR210_INTF_TRANSF_RATE).
        ��-��������� ��������������� ������������ �������� (500 �����/�).
        ���� ������������� �������� ��������� ������������ �������� ���������� ��� ������,
        � ������� ���������� ������, �� ����� ����������� ������������ ��������,
        �������������� ������ ������� }
    IntfTransfRate : Byte;
    Reserved : array [1..39] of LongWord; // ��������� ���� (�� ������ ���������� �������������)
  end;

  PTLTR210_CONFIG = ^TLTR210_CONFIG;

  { ��������� ��������� ������. }
  TLTR210_STATE = record
    Run           : Boolean;  // �������, ������� �� ���� ������
    { ���������� ���� � ����������� �����, ������� ������.
        (��������������� ����� ������ LTR210_SetADC()) }
    RecvFrameSize : LongWord;
    { ������������ ������� �������� ��� � �� (��������������� ����� ������
        LTR210_SetADC()) }
    AdcFreq       : Double;
    {   ������������ ������� ���������� ������ ��� ������ �������������
        #LTR210_SYNC_MODE_PERIODIC (��������������� ����� ������
        LTR210_SetADC()) }
    FrameFreq     : Double;
    { ���������� �������� �������� ���� ��� � ����� }
    AdcZeroOffset : Array [0..LTR210_CHANNEL_CNT-1] of Double;
    Reserved      : Array [1..4] of LongWord; // ��������� ����
  end;


  PTLTR210_INTARNAL = ^TLTR210_INTARNAL;
  TLTR210_INTARNAL = record
  end;

  { ��������� ������ }
  TLTR210 = record
    Size          : Integer; // ������ ���������. ����������� � LTR210_Init().
    { ���������, ���������� ��������� ���������� � ��������.
       �� ������������ �������� �������������. }
    Channel       : TLTR;
    {  ��������� �� ������������ ��������� � ����������� �����������,
       ������������� ������������� ����������� � ������������ ��� ������������. }
    Internal      : PTLTR210_INTARNAL;
    { ��������� ������. ����������� ������������� ����� ������� LTR210_SetADC(). }
    Cfg           : TLTR210_CONFIG;
    { ��������� ������ � ������������ ���������. ���� ���������� ���������
        ����������. ���������������� ���������� ����� ��������������
        ������ ��� ������. }
    State         : TLTR210_STATE;
    ModuleInfo    : TINFO_LTR210; // ���������� � ������
  end;

  pTLTR210=^TLTR210;


  { �������������� ���������� � �������� ������� }
  TLTR210_DATA_INFO = record
    {  ������� ��� ������������� �������� ��������������� ����, �������������
        ������ � ������� ������. ��� �������� ������ ��� �������� �����
        �� �������� �� #e_LTR210_DIG_BIT_MODE � ���� DigBitMode �� ����� ������������.
        ��������� ���� ����� ���� ������������ � �������, ������� ��� �������
        ����� ��������� �������� DigBitState and 1 }
    DigBitState : Byte;
    { ����� ������, �������� ������������� �������� ����� (0-������, 1 - ������) }
    Ch          : Byte;
    Range       : Byte;     // �������� ������, ������������� �� ����� ��������������
    Reserved    : Byte;  // ��������� ���� (�� ������ ���������� �������������)
  end;

  PTLTR210_DATA_INFO = ^TLTR210_DATA_INFO;

  { ���������� � ������� ������������� ����� }
  TLTR210_FRAME_STATUS = record
    { ��� ���������� ��������� ����� (���� �� �������� #e_LTR210_FRAME_RESULT).
        ��������� ����������, ������ �� ��� ����� ����� � �������������
        �� ������ � ����� }
    Result   : Byte;
    { ��������� ���� (������ ����� 0) }
    Reserved : Byte;
    {   �������������� ����� �� #e_LTR210_STATUS_FLAGS,
        �������������� ����� ���������� � ������� ������
        ������ � ��������� �����. ����� ���� ��������� ������,
        ������������ ����� ���������� ��� }
    Flags    : Word;
  end;

  PTLTR210_FRAME_STATUS = ^TLTR210_FRAME_STATUS;

  { ��� ������� ��� ��������� �������� �������� ���� }
  type TLTR210_LOAD_PROGR_CB = procedure(cb_data : Pointer; var hnd: TLTR210; done_size: LongWord; full_size : LongWord); {$I ltrapi_callconvention};
  type PTLTR210_LOAD_PROGR_CB = ^TLTR210_LOAD_PROGR_CB;

  {$A+}


  // ������������� ��������� ������
  Function LTR210_Init(out hnd: TLTR210) : Integer;
  // ���������� ���������� � �������.
  Function LTR210_Open(var hnd: TLTR210; net_addr : LongWord; net_port : LongWord;
                      csn: string; slot: Word): Integer;
  // �������� ���������� � �������
  Function LTR210_Close(var hnd: TLTR210) : Integer;
  // ��������, ������� �� ���������� � �������.
  Function LTR210_IsOpened(var hnd: TLTR210) : Integer;
  // ��������, ��������� �� �������� ���� ������.
  Function LTR210_FPGAIsLoaded(var hnd: TLTR210) : Integer;
  // �������� �������� ���� ������.
  Function LTR210_LoadFPGA(var hnd: TLTR210; filename : string;  progr_cb : TLTR210_LOAD_PROGR_CB; cb_data: Pointer) : Integer;
  Function LTR210_LoadFPGA(var hnd: TLTR210; filename : string) : Integer; overload;
  // ������ �������� � ������
  Function LTR210_SetADC(var hnd: TLTR210) : Integer;

  Function LTR210_FillAdcFreq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord; out set_freq : double) : Integer; overload;
  Function LTR210_FillAdcFreq(var cfg: TLTR210_CONFIG; freq : double; flags : LongWord) : Integer; overload;

  Function LTR210_FillFrameFreq(var cfg: TLTR210_CONFIG; freq : double; out set_freq : double) : Integer; overload;
  Function LTR210_FillFrameFreq(var cfg: TLTR210_CONFIG; freq : double) : Integer; overload;
  // ������� � ����� ����� ������
  Function LTR210_Start(var hnd: TLTR210) : Integer;
  // ������� ������ ����� ������
  Function LTR210_Stop(var hnd: TLTR210) : Integer;
  // ���������� ������ ����� �����
  Function LTR210_FrameStart(var hnd: TLTR210) : Integer;
  // �������� ������������ ������� �� ������
  Function LTR210_WaitEvent(var hnd: TLTR210; out evt: LongWord; out status: LongWord; tout: LongWord) : Integer; overload;
  Function LTR210_WaitEvent(var hnd: TLTR210; out evt: LongWord; tout: LongWord) : Integer; overload;

  // ����� ������ �� ������
  Function LTR210_Recv(var hnd: TLTR210; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  Function LTR210_Recv(var hnd: TLTR210; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
  // ��������� �������� �� ������ ����
  Function LTR210_ProcessData(var hnd: TLTR210; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS; out data_info: array of TLTR210_DATA_INFO): LongInt;  overload;
  Function LTR210_ProcessData(var hnd: TLTR210; var src : array of LongWord; out dest : array of Double; var size: Integer; flags : LongWord; out frame_status: TLTR210_FRAME_STATUS): LongInt; overload;

  // ��������� �������� ����
  Function LTR210_MeasAdcZeroOffset(var hnd: TLTR210; flags : LongWord) : Integer;

  // ��������� ���������� ��������� � ������� ������ ���������� �����
  Function LTR210_GetLastWordInterval(var hnd: TLTR210; out interval: LongWord) : Integer;
  // ��������� ��������� �� ������.
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
