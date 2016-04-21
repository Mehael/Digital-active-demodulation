object MainForm: TMainForm
  Left = 199
  Top = 160
  Caption = 'ltr24 example'
  ClientHeight = 422
  ClientWidth = 770
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
  object btnStart: TButton
    Left = 24
    Top = 16
    Width = 185
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1082' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 24
    Top = 48
    Width = 185
    Height = 25
    Caption = #1054#1089#1090#1072#1085#1086#1074' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    Enabled = False
    TabOrder = 1
    OnClick = btnStopClick
  end
  object grpConfig: TGroupBox
    Left = 24
    Top = 87
    Width = 249
    Height = 138
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 2
    object lblRange1: TLabel
      Left = 71
      Top = 22
      Width = 49
      Height = 13
      Caption = #1044#1080#1072#1087#1072#1079#1086#1085
    end
    object lblChAc1: TLabel
      Left = 47
      Top = 48
      Width = 73
      Height = 13
      Caption = #1054#1090#1089#1077#1095#1082#1072' '#1087#1086#1089#1090'.'
    end
    object lblAdcFreq: TLabel
      Left = 30
      Top = 78
      Width = 90
      Height = 13
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1040#1062#1055' ('#1043#1094')'
    end
    object lblDataFmt: TLabel
      Left = 13
      Top = 103
      Width = 107
      Height = 13
      Caption = #1056#1072#1079#1088#1103#1076#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093
    end
    object lblChAc2: TLabel
      Left = 44
      Top = 59
      Width = 76
      Height = 13
      Caption = #1089#1086#1089#1090#1072#1074#1083#1103#1102#1097#1077#1081
    end
    object cbbAdcFreq: TComboBox
      Left = 126
      Top = 76
      Width = 76
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = '117188'
      OnChange = cfgChanged
      Items.Strings = (
        '117188'
        '78125'
        '58594'
        '39063'
        '29297'
        '19531'
        '14648'
        '9766'
        '7324'
        '4883'
        '3662'
        '2441'
        '1831'
        '1221'
        '916'
        '610')
    end
    object cbbDataFmt: TComboBox
      Left = 126
      Top = 103
      Width = 76
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
      Text = '20 '#1073#1080#1090
      OnChange = cfgChanged
      Items.Strings = (
        '20 '#1073#1080#1090
        '24 '#1073#1080#1090#1072)
    end
    object cbbAC1: TComboBox
      Left = 126
      Top = 49
      Width = 113
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = #1042#1099#1082#1083'. (AC+DC)'
      Items.Strings = (
        #1042#1099#1082#1083'. (AC+DC)'
        #1042#1082#1083'. (AC)')
    end
    object cbbRange1: TComboBox
      Left = 126
      Top = 22
      Width = 113
      Height = 21
      ItemHeight = 13
      ItemIndex = 1
      TabOrder = 3
      Text = '10 '#1042
      Items.Strings = (
        '2 '#1042
        '10 '#1042
        '')
    end
  end
  object grpResult: TGroupBox
    Left = 24
    Top = 231
    Width = 249
    Height = 82
    Caption = #1048#1079#1084#1077#1088#1077#1085#1085#1099#1077' '#1089#1088#1077#1076#1085#1080#1077' '#1079#1085#1072#1095#1077#1085#1080#1103
    TabOrder = 3
    object edtCh1Avg: TEdit
      Left = 15
      Top = 20
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object edtCh2Avg: TEdit
      Left = 134
      Top = 20
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 1
    end
    object edtCh3Avg: TEdit
      Left = 15
      Top = 47
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
    object edtCh4Avg: TEdit
      Left = 134
      Top = 47
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 3
    end
  end
end
