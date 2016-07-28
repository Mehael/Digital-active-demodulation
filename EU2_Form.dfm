object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = #1057#1073#1086#1088' '#1044#1072#1085#1085#1099#1093' EU2'
  ClientHeight = 431
  ClientWidth = 648
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 412
    Width = 648
    Height = 19
    Panels = <
      item
        Text = #1057#1090#1072#1090#1091#1089': '#1054#1050
        Width = 70
      end
      item
        Text = #1042#1089#1077' '#1089#1080#1089#1090#1077#1084#1099' '#1088#1072#1073#1086#1090#1072#1102#1090' '#1085#1086#1088#1084#1072#1083#1100#1085#1086
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 319
    Top = 0
    Width = 329
    Height = 412
    Align = alRight
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 4
      Top = 52
      Width = 98
      Height = 13
      Caption = #1055#1091#1090#1100' '#1082' '#1093#1088#1072#1085#1080#1083#1080#1097#1091':'
    end
    object Label2: TLabel
      Left = 16
      Top = 78
      Width = 86
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1076#1072#1090#1095#1080#1082#1086#1074':'
    end
    object lbWorkTime: TLabel
      Left = 28
      Top = 27
      Width = 75
      Height = 13
      Caption = #1042#1088#1077#1084#1103' '#1088#1072#1073#1086#1090#1099':'
    end
    object Label3: TLabel
      Left = 16
      Top = 105
      Width = 82
      Height = 13
      Caption = #1055#1080#1089#1072#1090#1100' '#1082#1072#1078#1076#1086#1077':'
    end
    object bnStart: TButton
      Left = 185
      Top = 361
      Width = 133
      Height = 45
      Caption = #1057#1090#1072#1088#1090
      TabOrder = 0
      OnClick = bnStartClick
    end
    object Button1: TButton
      Left = 235
      Top = 47
      Width = 75
      Height = 25
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      TabOrder = 1
      OnClick = Button1Click
    end
    object cbTimeMetric: TComboBox
      Left = 164
      Top = 24
      Width = 58
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = #1084#1080#1085#1091#1090
      Items.Strings = (
        #1084#1080#1085#1091#1090
        #1095#1072#1089#1086#1074
        #1076#1085#1077#1081)
    end
    object CheckBox1: TCheckBox
      Left = 213
      Top = 82
      Width = 97
      Height = 17
      Caption = #1050#1072#1083#1080#1073#1088#1086#1074#1082#1072
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object Edit1: TEdit
      Left = 108
      Top = 78
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 4
      Text = '1'
    end
    object grpConfig: TGroupBox
      Left = 9
      Top = 125
      Width = 309
      Height = 138
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      TabOrder = 5
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
        ItemIndex = 6
        TabOrder = 0
        Text = '14648'
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
    object txPath: TEdit
      Left = 108
      Top = 51
      Width = 121
      Height = 21
      TabOrder = 6
      Text = 'D:\DataACP'
    end
    object txWorkTime: TEdit
      Left = 109
      Top = 24
      Width = 33
      Height = 21
      TabOrder = 7
      Text = '5'
    end
    object skipVal: TEdit
      Left = 108
      Top = 105
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 8
      Text = '10'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 319
    Height = 412
    Align = alClient
    AutoSize = True
    TabOrder = 2
    object chGraph: TChart
      Left = 1
      Top = 1
      Width = 317
      Height = 202
      AllowPanning = pmNone
      Legend.Visible = False
      MarginLeft = 0
      MarginRight = 10
      Title.Font.Color = clLime
      Title.Text.Strings = (
        #1050#1072#1085#1072#1083)
      ClipPoints = False
      LeftAxis.Title.Visible = False
      RightAxis.Labels = False
      RightAxis.Title.Visible = False
      View3D = False
      View3DWalls = False
      Zoom.Allow = False
      Zoom.Animated = True
      Align = alTop
      Color = clBlack
      TabOrder = 0
      object Series1: TFastLineSeries
        Marks.Callout.Brush.Color = clBlack
        Marks.Visible = False
        SeriesColor = clLime
        DrawAllPoints = False
        LinePen.Color = clLime
        LinePen.EndStyle = esFlat
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
        Data = {0000000000}
      end
    end
    object chGraph2: TChart
      Left = 1
      Top = 204
      Width = 317
      Height = 207
      AllowPanning = pmNone
      Legend.Visible = False
      MarginLeft = 0
      MarginRight = 10
      Title.Font.Color = clLime
      Title.Text.Strings = (
        #1050#1072#1085#1072#1083)
      ClipPoints = False
      LeftAxis.Title.Visible = False
      RightAxis.Labels = False
      RightAxis.Title.Visible = False
      View3D = False
      View3DWalls = False
      Zoom.Allow = False
      Zoom.Animated = True
      Align = alBottom
      Color = clBlack
      TabOrder = 1
      PrintMargins = (
        15
        24
        15
        24)
      object FastLineSeries1: TFastLineSeries
        Marks.Callout.Brush.Color = clBlack
        Marks.Visible = False
        SeriesColor = clLime
        DrawAllPoints = False
        LinePen.Color = clLime
        LinePen.EndStyle = esFlat
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
        Data = {0000000000}
      end
    end
  end
end
