object MainForm: TMainForm
  Left = 224
  Top = 262
  Width = 584
  Height = 744
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cbbModulesList: TComboBox
    Left = 264
    Top = 8
    Width = 273
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object btnRefreshDevList: TButton
    Left = 32
    Top = 8
    Width = 185
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
    TabOrder = 1
    OnClick = btnRefreshDevListClick
  end
  object btnOpen: TButton
    Left = 32
    Top = 65
    Width = 185
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1086
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object btnStart: TButton
    Left = 32
    Top = 96
    Width = 185
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1082' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    TabOrder = 3
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 32
    Top = 128
    Width = 185
    Height = 25
    Caption = #1054#1089#1090#1072#1085#1086#1074' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    Enabled = False
    TabOrder = 4
    OnClick = btnStopClick
  end
  object grpDevInfo: TGroupBox
    Left = 264
    Top = 64
    Width = 273
    Height = 121
    Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1084#1086#1076#1091#1083#1077
    TabOrder = 5
    object lblDevSerial: TLabel
      Left = 16
      Top = 24
      Width = 84
      Height = 13
      Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088
    end
    object lblVerAvrFirm: TLabel
      Left = 16
      Top = 48
      Width = 88
      Height = 13
      Caption = #1042#1077#1088#1089#1080#1103' '#1087#1088#1086#1096#1080#1074#1082#1080
    end
    object lblVerFPGA: TLabel
      Left = 16
      Top = 88
      Width = 66
      Height = 13
      Caption = #1042#1077#1088#1089#1080#1103' '#1055#1051#1048#1057
    end
    object lbl1: TLabel
      Left = 16
      Top = 72
      Width = 79
      Height = 13
      Caption = #1044#1072#1090#1072' '#1087#1088#1086#1096#1080#1074#1082#1080
    end
    object edtDevSerial: TEdit
      Left = 112
      Top = 24
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object edtVerFPGA: TEdit
      Left = 112
      Top = 88
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 1
    end
    object edtVerAvrFirm: TEdit
      Left = 112
      Top = 48
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
    object edtAvrFirmDate: TEdit
      Left = 112
      Top = 68
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 3
    end
  end
  object grpConfig: TGroupBox
    Left = 40
    Top = 192
    Width = 497
    Height = 185
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 6
    object lblSyncLevelL1: TLabel
      Left = 8
      Top = 104
      Width = 71
      Height = 13
      Caption = #1053#1080#1078#1085#1080#1081' '#1087#1086#1088#1086#1075
    end
    object lbl2: TLabel
      Left = 272
      Top = 104
      Width = 74
      Height = 13
      Caption = #1042#1077#1088#1093#1085#1080#1081' '#1087#1086#1088#1086#1075
    end
    object lbl3: TLabel
      Left = 8
      Top = 24
      Width = 228
      Height = 13
      Caption = #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1080#1085#1090#1077#1088#1074#1072#1083' '#1084#1077#1078#1076#1091' '#1092#1088#1086#1085#1090#1072#1084#1080', '#1084#1089
    end
    object lbl4: TLabel
      Left = 8
      Top = 48
      Width = 265
      Height = 13
      Caption = #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077' '#1080#1079#1084#1077#1088#1103#1077#1084#1086#1075#1086' '#1080#1085#1090#1077#1088#1074#1072#1083#1072', '#1084#1089
    end
    object lbl5: TLabel
      Left = 8
      Top = 136
      Width = 165
      Height = 13
      Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1085#1099#1081' '#1076#1080#1072#1087#1072#1079#1086#1085' '#1087#1086#1088#1086#1075#1086#1074
    end
    object lbl6: TLabel
      Left = 8
      Top = 72
      Width = 333
      Height = 13
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1092#1088#1086#1085#1090#1086#1074' '#1084#1077#1078#1076#1091' '#1082#1086#1090#1086#1088#1099#1084#1080' '#1088#1072#1089#1089#1095#1080#1090#1099#1074#1072#1077#1090#1089#1103' '#1080#1085#1090#1077#1088#1074#1072#1083
    end
    object lbl7: TLabel
      Left = 8
      Top = 160
      Width = 197
      Height = 13
      Caption = #1053#1072#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1092#1080#1082#1089#1080#1088#1091#1077#1084#1099#1093' '#1087#1077#1088#1077#1087#1072#1076#1086#1074
    end
    object edtTresholdL: TEdit
      Left = 120
      Top = 104
      Width = 113
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object edtTresholdH: TEdit
      Left = 360
      Top = 104
      Width = 113
      Height = 21
      TabOrder = 1
      Text = '4'
    end
    object edtIntervalMin: TEdit
      Left = 360
      Top = 24
      Width = 113
      Height = 21
      TabOrder = 2
      Text = '2'
    end
    object edtIntervalMax: TEdit
      Left = 360
      Top = 48
      Width = 113
      Height = 21
      TabOrder = 3
      Text = '500000'
    end
    object cbbTreshRange: TComboBox
      Left = 360
      Top = 136
      Width = 113
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = '10 '#1042
      Items.Strings = (
        '10 '#1042
        '1.2 '#1042)
    end
    object cbbEdge: TComboBox
      Left = 360
      Top = 160
      Width = 113
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 5
      Text = #1060#1088#1086#1085#1090
      Items.Strings = (
        #1060#1088#1086#1085#1090
        #1057#1087#1072#1076)
    end
    object edtReqFrontCnt: TEdit
      Left = 360
      Top = 72
      Width = 113
      Height = 21
      TabOrder = 6
      Text = '2'
    end
  end
  object mmoLog: TMemo
    Left = 32
    Top = 384
    Width = 521
    Height = 305
    TabOrder = 7
  end
end
