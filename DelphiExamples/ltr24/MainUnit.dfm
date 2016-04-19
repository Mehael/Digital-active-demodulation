object MainForm: TMainForm
  Left = 199
  Top = 160
  Width = 786
  Height = 461
  Caption = 'ltr24 example'
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
    Left = 376
    Top = 8
    Width = 273
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object btnRefreshDevList: TButton
    Left = 136
    Top = 8
    Width = 185
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
    TabOrder = 1
    OnClick = btnRefreshDevListClick
  end
  object btnOpen: TButton
    Left = 136
    Top = 65
    Width = 185
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1086
    TabOrder = 2
    OnClick = btnOpenClick
  end
  object btnStart: TButton
    Left = 136
    Top = 96
    Width = 185
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1082' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    TabOrder = 3
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 136
    Top = 128
    Width = 185
    Height = 25
    Caption = #1054#1089#1090#1072#1085#1086#1074' '#1089#1073#1086#1088#1072' '#1076#1072#1085#1085#1099#1093
    Enabled = False
    TabOrder = 4
    OnClick = btnStopClick
  end
  object grpDevInfo: TGroupBox
    Left = 376
    Top = 48
    Width = 273
    Height = 105
    Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1084#1086#1076#1091#1083#1077
    TabOrder = 5
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
      Width = 79
      Height = 13
      Caption = #1055#1086#1076#1076#1077#1088#1078#1082#1072' ICP'
    end
    object edtDevSerial: TEdit
      Left = 112
      Top = 24
      Width = 145
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object edtICPSupport: TEdit
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
    Left = 27
    Top = 168
    Width = 718
    Height = 185
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 6
    object lblRange1: TLabel
      Left = 48
      Top = 48
      Width = 49
      Height = 13
      Caption = #1044#1080#1072#1087#1072#1079#1086#1085
    end
    object lblChAc1: TLabel
      Left = 24
      Top = 72
      Width = 73
      Height = 13
      Caption = #1054#1090#1089#1077#1095#1082#1072' '#1087#1086#1089#1090'.'
    end
    object lblDigBit1: TLabel
      Left = 56
      Top = 112
      Width = 32
      Height = 13
      Caption = #1056#1077#1078#1080#1084
    end
    object lblAdcFreq: TLabel
      Left = 8
      Top = 152
      Width = 90
      Height = 13
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1040#1062#1055' ('#1043#1094')'
    end
    object lblDataFmt: TLabel
      Left = 200
      Top = 152
      Width = 107
      Height = 13
      Caption = #1056#1072#1079#1088#1103#1076#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093
    end
    object lblISrcVal: TLabel
      Left = 400
      Top = 152
      Width = 75
      Height = 13
      Caption = #1048#1089#1090#1086#1095#1085#1080#1082' '#1090#1086#1082#1072
    end
    object lblChAc2: TLabel
      Left = 16
      Top = 88
      Width = 76
      Height = 13
      Caption = #1089#1086#1089#1090#1072#1074#1083#1103#1102#1097#1077#1081
    end
    object grpCfgCh1: TGroupBox
      Left = 104
      Top = 16
      Width = 145
      Height = 121
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
        OnClick = cfgChanged
      end
      object cbbRange1: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 1
        Text = '10 '#1042
        Items.Strings = (
          '2 '#1042
          '10 '#1042
          '')
      end
      object cbbAC1: TComboBox
        Left = 8
        Top = 56
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
      object cbbICPMode1: TComboBox
        Left = 8
        Top = 92
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = #1044#1080#1092'. '#1074#1093#1086#1076
        OnChange = cfgChanged
        Items.Strings = (
          #1044#1080#1092'. '#1074#1093#1086#1076
          'ICP '#1074#1093#1086#1076)
      end
    end
    object cbbAdcFreq: TComboBox
      Left = 101
      Top = 148
      Width = 76
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 1
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
    object chkTestModes: TCheckBox
      Left = 581
      Top = 150
      Width = 129
      Height = 17
      Caption = #1058#1077#1089#1090#1086#1074#1099#1077' '#1088#1077#1078#1080#1084#1099
      TabOrder = 2
      OnClick = cfgChanged
    end
    object cbbDataFmt: TComboBox
      Left = 309
      Top = 148
      Width = 76
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = '20 '#1073#1080#1090
      OnChange = cfgChanged
      Items.Strings = (
        '20 '#1073#1080#1090
        '24 '#1073#1080#1090#1072)
    end
    object cbbISrcValue: TComboBox
      Left = 477
      Top = 148
      Width = 76
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = '2.86 '#1084#1040
      Items.Strings = (
        '2.86 '#1084#1040
        '10 '#1084#1040)
    end
    object grp1: TGroupBox
      Left = 256
      Top = 16
      Width = 145
      Height = 121
      Caption = #1050#1072#1085#1072#1083' 2'
      TabOrder = 5
      object chkChEn2: TCheckBox
        Left = 8
        Top = 16
        Width = 129
        Height = 17
        Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cfgChanged
      end
      object cbbRange2: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 1
        Text = '10 '#1042
        Items.Strings = (
          '2 '#1042
          '10 '#1042
          '')
      end
      object cbbAC2: TComboBox
        Left = 8
        Top = 56
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 2
        Text = #1042#1099#1082#1083'. (AC+DC)'
        Items.Strings = (
          #1042#1099#1082#1083'. (AC+DC)'
          #1042#1082#1083'. (AC)'
          '')
      end
      object cbbICPMode2: TComboBox
        Left = 8
        Top = 92
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = #1044#1080#1092'. '#1074#1093#1086#1076
        OnChange = cfgChanged
        Items.Strings = (
          #1044#1080#1092'. '#1074#1093#1086#1076
          'ICP '#1074#1093#1086#1076)
      end
    end
    object grp2: TGroupBox
      Left = 408
      Top = 16
      Width = 145
      Height = 121
      Caption = #1050#1072#1085#1072#1083' 3'
      TabOrder = 6
      object chkChEn3: TCheckBox
        Left = 8
        Top = 16
        Width = 129
        Height = 17
        Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cfgChanged
      end
      object cbbRange3: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 1
        Text = '10 '#1042
        Items.Strings = (
          '2 '#1042
          '10 '#1042
          '')
      end
      object cbbAC3: TComboBox
        Left = 8
        Top = 56
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
      object cbbICPMode3: TComboBox
        Left = 8
        Top = 92
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = #1044#1080#1092'. '#1074#1093#1086#1076
        OnChange = cfgChanged
        Items.Strings = (
          #1044#1080#1092'. '#1074#1093#1086#1076
          'ICP '#1074#1093#1086#1076)
      end
    end
    object grp3: TGroupBox
      Left = 560
      Top = 16
      Width = 145
      Height = 121
      Caption = #1050#1072#1085#1072#1083' 4'
      TabOrder = 7
      object chkChEn4: TCheckBox
        Left = 8
        Top = 16
        Width = 129
        Height = 17
        Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cfgChanged
      end
      object cbbRange4: TComboBox
        Left = 8
        Top = 32
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 1
        Text = '10 '#1042
        Items.Strings = (
          '2 '#1042
          '10 '#1042
          '')
      end
      object cbbAC4: TComboBox
        Left = 8
        Top = 56
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
      object cbbICPMode4: TComboBox
        Left = 8
        Top = 92
        Width = 113
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = #1044#1080#1092'. '#1074#1093#1086#1076
        OnChange = cfgChanged
        Items.Strings = (
          #1044#1080#1092'. '#1074#1093#1086#1076
          'ICP '#1074#1093#1086#1076)
      end
    end
  end
  object grpResult: TGroupBox
    Left = 24
    Top = 366
    Width = 721
    Height = 49
    Caption = #1048#1079#1084#1077#1088#1077#1085#1085#1099#1077' '#1089#1088#1077#1076#1085#1080#1077' '#1079#1085#1072#1095#1077#1085#1080#1103
    TabOrder = 7
    object edtCh1Avg: TEdit
      Left = 120
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
    object edtCh3Avg: TEdit
      Left = 424
      Top = 20
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
    object edtCh4Avg: TEdit
      Left = 568
      Top = 20
      Width = 105
      Height = 21
      ReadOnly = True
      TabOrder = 3
    end
  end
end
