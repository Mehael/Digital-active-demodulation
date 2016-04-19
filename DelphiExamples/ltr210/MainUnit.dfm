object MainForm: TMainForm
  Left = -812
  Top = 766
  Width = 639
  Height = 686
  Caption = 'ltr210 example'
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
  object lblFpgaLoadProgr: TLabel
    Left = 32
    Top = 40
    Width = 130
    Height = 13
    Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1087#1088#1086#1096#1080#1074#1082#1080' '#1055#1051#1048#1057
  end
  object btnRefreshDevList: TButton
    Left = 32
    Top = 8
    Width = 185
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
    TabOrder = 0
    OnClick = btnRefreshDevListClick
  end
  object cbbModulesList: TComboBox
    Left = 232
    Top = 8
    Width = 273
    Height = 21
    ItemHeight = 13
    TabOrder = 1
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
  object pbFpgaLoad: TProgressBar
    Left = 176
    Top = 40
    Width = 329
    Height = 17
    TabOrder = 3
  end
  object grpDevInfo: TGroupBox
    Left = 336
    Top = 80
    Width = 273
    Height = 105
    Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1084#1086#1076#1091#1083#1077
    TabOrder = 4
    object lblDevSerial: TLabel
      Left = 16
      Top = 24
      Width = 84
      Height = 13
      Caption = #1057#1077#1088#1080#1081#1085#1099#1081' '#1085#1086#1084#1077#1088
    end
    object lblVerPld: TLabel
      Left = 16
      Top = 48
      Width = 56
      Height = 13
      Caption = #1042#1077#1088#1089#1080#1103' PLD'
    end
    object lblVerFPGA: TLabel
      Left = 16
      Top = 72
      Width = 66
      Height = 13
      Caption = #1042#1077#1088#1089#1080#1103' '#1055#1051#1048#1057
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
      Top = 72
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 1
    end
    object edtVerPld: TEdit
      Left = 112
      Top = 48
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
  end
  object grpConfig: TGroupBox
    Left = 24
    Top = 208
    Width = 585
    Height = 289
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 5
    object lblRange1: TLabel
      Left = 96
      Top = 48
      Width = 49
      Height = 13
      Caption = #1044#1080#1072#1087#1072#1079#1086#1085
    end
    object lblChMode1: TLabel
      Left = 104
      Top = 72
      Width = 32
      Height = 13
      Caption = #1056#1077#1078#1080#1084
    end
    object lblSyncLevelL1: TLabel
      Left = 48
      Top = 96
      Width = 94
      Height = 13
      Caption = #1053#1080#1078#1085#1080#1081' '#1091#1088'. '#1089#1080#1085#1093#1088'.'
    end
    object lblSyncLevelH1: TLabel
      Left = 48
      Top = 120
      Width = 97
      Height = 13
      Caption = #1042#1077#1088#1093#1085#1080#1081' '#1091#1088'. '#1089#1080#1085#1093#1088'.'
    end
    object lblDigBit1: TLabel
      Left = 56
      Top = 144
      Width = 89
      Height = 13
      Caption = #1056#1077#1078#1080#1084' '#1089#1087#1077#1094'. '#1073#1080#1090#1072
    end
    object lblSyncMode: TLabel
      Left = 312
      Top = 192
      Width = 111
      Height = 13
      Caption = #1056#1077#1078#1080#1084' '#1089#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1080
    end
    object lblGroupMode: TLabel
      Left = 344
      Top = 216
      Width = 83
      Height = 13
      Caption = #1056#1072#1073#1086#1090#1072' '#1074' '#1075#1088#1091#1087#1087#1077
    end
    object lblFrameSize: TLabel
      Left = 96
      Top = 184
      Width = 69
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1082#1072#1076#1088#1072
    end
    object lblHistSize: TLabel
      Left = 56
      Top = 208
      Width = 106
      Height = 13
      Caption = #1056#1072#1079#1084#1077#1088' '#1087#1088#1077#1076#1099#1089#1090#1086#1088#1080#1080
    end
    object lblAdcFreqDiv: TLabel
      Left = 48
      Top = 232
      Width = 122
      Height = 13
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1073#1086#1088#1072' '#1040#1062#1055' ('#1043#1094')'
    end
    object lblAdcDcm: TLabel
      Left = 8
      Top = 256
      Width = 168
      Height = 13
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1083#1077#1076#1086#1074#1072#1085#1080#1103' '#1082#1072#1076#1088#1086#1074' ('#1043#1094')'
    end
    object grpCfgCh1: TGroupBox
      Left = 152
      Top = 16
      Width = 145
      Height = 161
      Caption = #1050#1072#1085#1072#1083' 1'
      TabOrder = 0
      object chkChEn1: TCheckBox
        Left = 8
        Top = 16
        Width = 129
        Height = 17
        Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object cbbRange1: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 1
        Text = '10 '#1042
        Items.Strings = (
          '10 '#1042
          '5 '#1042
          '2 '#1042
          '1 '#1042
          '0.5 '#1042
          '0.2 '#1042)
      end
      object cbbMode1: TComboBox
        Left = 8
        Top = 56
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 2
        Text = #1054#1090#1082#1088#1099#1090#1099#1081' '#1074#1093#1086#1076
        Items.Strings = (
          #1054#1090#1082#1088#1099#1090#1099#1081' '#1074#1093#1086#1076
          #1047#1072#1082#1088#1099#1090#1099#1081' '#1074#1093#1086#1076
          #1057#1086#1073#1089#1090#1074#1077#1085#1085#1099#1081' '#1085#1086#1083#1100)
      end
      object edtSyncLevelL1: TEdit
        Left = 8
        Top = 80
        Width = 113
        Height = 21
        TabOrder = 3
        Text = '0'
      end
      object edtSyncLevelH1: TEdit
        Left = 8
        Top = 104
        Width = 113
        Height = 21
        TabOrder = 4
        Text = '0'
      end
      object cbbDigBit1: TComboBox
        Left = 8
        Top = 124
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 5
        Text = #1042#1093#1086#1076' SYNC'
        Items.Strings = (
          #1053#1091#1083#1100
          #1042#1093#1086#1076' SYNC'
          #1050#1072#1085#1072#1083' '#1040#1062#1055'1'
          #1050#1072#1085#1072#1083' '#1040#1062#1055'2'
          #1042#1085#1091#1090#1088'. '#1089#1086#1073#1099#1090#1080#1077)
      end
    end
    object grp1: TGroupBox
      Left = 304
      Top = 16
      Width = 153
      Height = 161
      Caption = #1050#1072#1085#1072#1083' 2'
      TabOrder = 1
      object chkChEn2: TCheckBox
        Left = 8
        Top = 16
        Width = 129
        Height = 17
        Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object cbbRange2: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 1
        Text = '10 '#1042
        Items.Strings = (
          '10 '#1042
          '5 '#1042
          '2 '#1042
          '1 '#1042
          '0.5 '#1042
          '0.2 '#1042)
      end
      object cbbMode2: TComboBox
        Left = 8
        Top = 56
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 2
        Text = #1054#1090#1082#1088#1099#1090#1099#1081' '#1074#1093#1086#1076
        Items.Strings = (
          #1054#1090#1082#1088#1099#1090#1099#1081' '#1074#1093#1086#1076
          #1047#1072#1082#1088#1099#1090#1099#1081' '#1074#1093#1086#1076
          #1057#1086#1073#1089#1090#1074#1077#1085#1085#1099#1081' '#1085#1086#1083#1100)
      end
      object edtSyncLevelL2: TEdit
        Left = 8
        Top = 80
        Width = 113
        Height = 21
        TabOrder = 3
        Text = '0'
      end
      object edtSyncLevelH2: TEdit
        Left = 8
        Top = 104
        Width = 113
        Height = 21
        TabOrder = 4
        Text = '0'
      end
      object cbbDigBit2: TComboBox
        Left = 8
        Top = 124
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 5
        Text = #1042#1093#1086#1076' SYNC'
        Items.Strings = (
          #1053#1091#1083#1100
          #1042#1093#1086#1076' SYNC'
          #1050#1072#1085#1072#1083' '#1040#1062#1055'1'
          #1050#1072#1085#1072#1083' '#1040#1062#1055'2'
          #1042#1085#1091#1090#1088'. '#1089#1086#1073#1099#1090#1080#1077)
      end
    end
    object cbbSyncMode: TComboBox
      Left = 432
      Top = 188
      Width = 137
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = #1042#1085#1091#1090#1088#1077#1085#1085#1103#1103' ('#1087#1088#1086#1075#1088#1072#1084#1084#1085#1072#1103')'
      Items.Strings = (
        #1042#1085#1091#1090#1088#1077#1085#1085#1103#1103' ('#1087#1088#1086#1075#1088#1072#1084#1084#1085#1072#1103')'
        #1050#1072#1085#1072#1083' 1 ('#1092#1088#1086#1085#1090')'
        #1050#1072#1085#1072#1083' 1 ('#1089#1087#1072#1076')'
        #1050#1072#1085#1072#1083' 2 ('#1092#1088#1086#1085#1090')'
        #1050#1072#1085#1072#1083' 2 ('#1089#1087#1072#1076')'
        'SYNC ('#1092#1088#1086#1085#1090')'
        'SYNC ('#1089#1087#1072#1076')'
        #1055#1077#1088#1080#1086#1076#1080#1095#1077#1089#1082#1080#1081)
    end
    object cbbGroupMode: TComboBox
      Left = 432
      Top = 212
      Width = 137
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = #1054#1090#1082#1083'. '
      Items.Strings = (
        #1054#1090#1082#1083'. '
        #1052#1072#1089#1090#1077#1088
        #1055#1086#1076#1095#1080#1085#1077#1085#1085#1099#1081' (slave)')
    end
    object seFrameSize: TSpinEdit
      Left = 184
      Top = 184
      Width = 121
      Height = 22
      MaxValue = 16776704
      MinValue = 1
      TabOrder = 4
      Value = 4000
    end
    object seHistSize: TSpinEdit
      Left = 184
      Top = 208
      Width = 121
      Height = 22
      MaxValue = 16776704
      MinValue = 0
      TabOrder = 5
      Value = 0
    end
    object chkKeepaliveEn: TCheckBox
      Left = 320
      Top = 240
      Width = 257
      Height = 17
      Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1087#1077#1088#1080#1086#1076#1080#1095#1077#1089#1082#1086#1081' '#1087#1086#1089#1099#1083#1082#1080' '#1089#1090#1072#1090#1091#1089#1072
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object chkWriteAutoSusp: TCheckBox
      Left = 320
      Top = 256
      Width = 249
      Height = 17
      Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1072#1103' '#1087#1088#1080#1086#1089#1090#1072#1085#1086#1074#1082#1072' '#1079#1072#1087#1080#1089#1080
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object edtAdcFreq: TEdit
      Left = 184
      Top = 232
      Width = 121
      Height = 21
      TabOrder = 8
      Text = '10000000'
    end
    object edtFrameFreq: TEdit
      Left = 184
      Top = 256
      Width = 121
      Height = 21
      TabOrder = 9
      Text = '1'
    end
  end
  object btnStart: TButton
    Left = 32
    Top = 96
    Width = 185
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1082' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    TabOrder = 6
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 32
    Top = 128
    Width = 185
    Height = 25
    Caption = #1054#1089#1090#1072#1085#1086#1074' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    Enabled = False
    TabOrder = 7
    OnClick = btnStopClick
  end
  object grpResult: TGroupBox
    Left = 24
    Top = 504
    Width = 433
    Height = 49
    Caption = #1048#1079#1084#1077#1088#1077#1085#1085#1099#1077' '#1089#1088#1077#1076#1085#1080#1077' '#1079#1085#1072#1095#1077#1085#1080#1103
    TabOrder = 8
    object lblCh1Avg: TLabel
      Left = 32
      Top = 24
      Width = 40
      Height = 13
      Caption = #1050#1072#1085#1072#1083' 1'
    end
    object lblCh2Avg: TLabel
      Left = 216
      Top = 24
      Width = 40
      Height = 13
      Caption = #1050#1072#1085#1072#1083' 2'
    end
    object edtCh1Avg: TEdit
      Left = 88
      Top = 20
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object edtCh2Avg: TEdit
      Left = 272
      Top = 20
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 1
    end
  end
  object grpFrameCntrs: TGroupBox
    Left = 24
    Top = 552
    Width = 585
    Height = 89
    Caption = #1057#1095#1077#1090#1095#1080#1082#1080' '#1087#1088#1080#1085#1103#1090#1099#1093' '#1082#1072#1076#1088#1086#1074
    TabOrder = 9
    object lblValidFrameCntr: TLabel
      Left = 32
      Top = 32
      Width = 78
      Height = 13
      Caption = #1042#1077#1088#1085#1099#1093' '#1082#1072#1076#1088#1086#1074
    end
    object lblInvalidFrameCntr: TLabel
      Left = 128
      Top = 32
      Width = 99
      Height = 13
      Caption = #1050#1072#1076#1088#1086#1074' '#1089' '#1086#1096#1080#1073#1082#1072#1084#1080
    end
    object lblSyncSkip: TLabel
      Left = 248
      Top = 16
      Width = 97
      Height = 26
      Caption = #1055#1088#1086#1087#1091#1097#1077#1085#1086' '#1089#1086#1073#1099'-'#13#10#1090#1080#1081' '#1089#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1080
    end
    object lblOverlapCntr: TLabel
      Left = 360
      Top = 32
      Width = 86
      Height = 13
      Caption = #1057#1086#1073#1099#1090#1080#1081' Overlap'
    end
    object lblInvalidHistCntr: TLabel
      Left = 461
      Top = 16
      Width = 100
      Height = 26
      Caption = #1050#1072#1076#1088#1086#1074' '#1089' '#1085#1077#1074#1077#1088#1085#1086#1081' '#13#10#1087#1088#1077#1076#1080#1089#1090#1088#1080#1077#1081
    end
    object edtValidFrameCntr: TEdit
      Left = 32
      Top = 52
      Width = 89
      Height = 21
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object edtInvalidFrameCntr: TEdit
      Left = 136
      Top = 52
      Width = 89
      Height = 21
      ReadOnly = True
      TabOrder = 1
      Text = '0'
    end
    object edtSyncSkipCntr: TEdit
      Left = 248
      Top = 52
      Width = 89
      Height = 21
      ReadOnly = True
      TabOrder = 2
      Text = '0'
    end
    object edtOverlapCntr: TEdit
      Left = 360
      Top = 52
      Width = 89
      Height = 21
      ReadOnly = True
      TabOrder = 3
      Text = '0'
    end
    object edtInvalidHistCntr: TEdit
      Left = 472
      Top = 52
      Width = 89
      Height = 21
      ReadOnly = True
      TabOrder = 4
      Text = '0'
    end
  end
  object btnFrameStart: TButton
    Left = 32
    Top = 160
    Width = 185
    Height = 25
    Caption = #1055#1088#1086#1075#1088#1072#1084#1084#1085#1099#1081' '#1079#1072#1087#1091#1089#1082' '#1082#1072#1076#1088#1072
    Enabled = False
    TabOrder = 10
    OnClick = btnFrameStartClick
  end
end
