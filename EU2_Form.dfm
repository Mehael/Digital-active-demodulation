object MainForm: TMainForm
  Left = 356
  Top = 162
  Caption = #1057#1073#1086#1088' '#1044#1072#1085#1085#1099#1093' EU2'
  ClientHeight = 595
  ClientWidth = 890
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 130
  TextHeight = 18
  object StatusBar1: TStatusBar
    Left = 0
    Top = 576
    Width = 890
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
    ExplicitWidth = 897
  end
  object Panel1: TPanel
    Left = 443
    Top = 0
    Width = 447
    Height = 576
    Align = alRight
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 435
    object Label1: TLabel
      Left = 6
      Top = 72
      Width = 133
      Height = 18
      Caption = #1055#1091#1090#1100' '#1082' '#1093#1088#1072#1085#1080#1083#1080#1097#1091':'
    end
    object Label2: TLabel
      Left = 22
      Top = 108
      Width = 114
      Height = 18
      Caption = #1063#1080#1089#1083#1086' '#1076#1072#1090#1095#1080#1082#1086#1074':'
    end
    object lbWorkTime: TLabel
      Left = 39
      Top = 37
      Width = 103
      Height = 18
      Caption = #1042#1088#1077#1084#1103' '#1088#1072#1073#1086#1090#1099':'
    end
    object Label3: TLabel
      Left = 28
      Top = 145
      Width = 110
      Height = 18
      Caption = #1055#1080#1089#1072#1090#1100' '#1082#1072#1078#1076#1086#1077':'
    end
    object TimerText: TLabel
      Left = 266
      Top = 446
      Width = 12
      Height = 46
      Align = alCustom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -38
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bnStart: TButton
      Left = 248
      Top = 498
      Width = 184
      Height = 62
      Caption = #1057#1090#1072#1088#1090
      TabOrder = 0
      OnClick = bnStartClick
    end
    object Button1: TButton
      Left = 325
      Top = 65
      Width = 104
      Height = 35
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      TabOrder = 1
      OnClick = Button1Click
    end
    object cbTimeMetric: TComboBox
      Left = 227
      Top = 33
      Width = 80
      Height = 26
      Style = csDropDownList
      ItemHeight = 18
      ItemIndex = 0
      TabOrder = 2
      Text = #1084#1080#1085#1091#1090
      Items.Strings = (
        #1084#1080#1085#1091#1090
        #1095#1072#1089#1086#1074
        #1076#1085#1077#1081)
    end
    object Edit1: TEdit
      Left = 150
      Top = 108
      Width = 45
      Height = 26
      Enabled = False
      TabOrder = 3
      Text = '2'
    end
    object txPath: TEdit
      Left = 150
      Top = 71
      Width = 167
      Height = 26
      TabOrder = 4
      Text = 'D:\DataACP'
    end
    object txWorkTime: TEdit
      Left = 151
      Top = 33
      Width = 46
      Height = 26
      TabOrder = 5
      Text = '1'
    end
    object skipVal: TEdit
      Left = 150
      Top = 145
      Width = 45
      Height = 26
      Enabled = False
      TabOrder = 6
      Text = '10'
    end
    object PageControl1: TPageControl
      Left = 16
      Top = 199
      Width = 417
      Height = 218
      ActivePage = TabSheet6
      TabOrder = 7
      object TabSheet6: TTabSheet
        Caption = #1056#1077#1078#1080#1084
        ImageIndex = 5
        object CheckBox1: TCheckBox
          Left = 19
          Top = 19
          Width = 230
          Height = 23
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085#1080#1077' '#1082#1072#1083#1080#1073#1088#1086#1074#1082#1080
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object CheckBox2: TCheckBox
          Left = 19
          Top = 48
          Width = 166
          Height = 23
          Caption = #1041#1077#1089#1082#1086#1085#1077#1095#1085#1072#1103' '#1079#1072#1087#1080#1089#1100
          TabOrder = 1
        end
        object CheckBox3: TCheckBox
          Left = 19
          Top = 77
          Width = 166
          Height = 23
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1089#1080#1075#1085#1072#1083
          TabOrder = 2
        end
      end
      object TabSheet1: TTabSheet
        Caption = #1055#1083#1072#1090#1072
        object lblAdcFreq: TLabel
          Left = 38
          Top = 98
          Width = 125
          Height = 18
          Caption = #1063#1072#1089#1090#1086#1090#1072' '#1040#1062#1055' ('#1043#1094')'
        end
        object lblChAc1: TLabel
          Left = 65
          Top = 50
          Width = 98
          Height = 18
          Caption = #1054#1090#1089#1077#1095#1082#1072' '#1087#1086#1089#1090'.'
        end
        object lblChAc2: TLabel
          Left = 61
          Top = 66
          Width = 102
          Height = 18
          Caption = #1089#1086#1089#1090#1072#1074#1083#1103#1102#1097#1077#1081
        end
        object lblDataFmt: TLabel
          Left = 21
          Top = 138
          Width = 141
          Height = 18
          Caption = #1056#1072#1079#1088#1103#1076#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093
        end
        object lblRange1: TLabel
          Left = 98
          Top = 14
          Width = 65
          Height = 18
          Caption = #1044#1080#1072#1087#1072#1079#1086#1085
        end
        object cbbAC1: TComboBox
          Left = 169
          Top = 57
          Width = 157
          Height = 26
          ItemHeight = 18
          ItemIndex = 0
          TabOrder = 0
          Text = #1042#1099#1082#1083'. (AC+DC)'
          Items.Strings = (
            #1042#1099#1082#1083'. (AC+DC)'
            #1042#1082#1083'. (AC)')
        end
        object cbbAdcFreq: TComboBox
          Left = 169
          Top = 97
          Width = 106
          Height = 26
          ItemHeight = 18
          ItemIndex = 6
          TabOrder = 1
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
          Left = 168
          Top = 137
          Width = 103
          Height = 26
          ItemHeight = 18
          ItemIndex = 0
          TabOrder = 2
          Text = '20 '#1073#1080#1090
          Items.Strings = (
            '20 '#1073#1080#1090
            '24 '#1073#1080#1090#1072)
        end
        object cbbRange1: TComboBox
          Left = 169
          Top = 14
          Width = 77
          Height = 26
          ItemHeight = 18
          ItemIndex = 1
          TabOrder = 3
          Text = '10 '#1042
          Items.Strings = (
            '2 '#1042
            '10 '#1042
            '')
        end
      end
      object TabSheet2: TTabSheet
        Caption = #1054#1087#1090#1080#1084'.'
        ImageIndex = 1
        object Label5: TLabel
          Left = 182
          Top = 23
          Width = 96
          Height = 18
          Caption = '% '#1072#1084#1087#1083#1080#1090#1091#1076#1099
        end
        object Label4: TLabel
          Left = 26
          Top = 23
          Width = 91
          Height = 18
          Caption = #1042#1099#1089#1086#1090#1072' '#1086#1082#1085#1072':'
        end
        object Label6: TLabel
          Left = 22
          Top = 79
          Width = 340
          Height = 18
          Caption = #1045#1089#1083#1080' '#1088#1072#1073#1086#1095#1072#1103' '#1090#1086#1095#1082#1072' '#1089#1076#1074#1080#1085#1091#1083#1072#1089#1100' '#1084#1077#1085#1100#1096#1077', '#1095#1077#1084' '#1085#1072' '
        end
        object Label7: TLabel
          Left = 24
          Top = 103
          Width = 248
          Height = 18
          Caption = #1091#1082#1072#1079#1072#1085#1085#1099#1081' '#1087#1088#1086#1094#1077#1085#1090', '#1080#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100'. '
        end
        object PercentEdit: TSpinEdit
          Left = 128
          Top = 21
          Width = 48
          Height = 28
          MaxValue = 100
          MinValue = 0
          TabOrder = 0
          Value = 1
        end
      end
      object TabSheet3: TTabSheet
        Caption = #1057#1073#1088#1086#1089#1099
        ImageIndex = 2
        object Label8: TLabel
          Left = 17
          Top = 32
          Width = 145
          Height = 18
          Caption = #1057#1073#1088#1086#1089' 1-'#1086#1075#1086' '#1076#1072#1090#1095#1080#1082#1072':'
        end
        object Label9: TLabel
          Left = 17
          Top = 64
          Width = 145
          Height = 18
          Caption = #1057#1073#1088#1086#1089' 2-'#1086#1075#1086' '#1076#1072#1090#1095#1080#1082#1072':'
        end
        object Label10: TLabel
          Left = 233
          Top = 32
          Width = 46
          Height = 18
          Caption = #1042#1086#1083#1100#1090'.'
        end
        object Label11: TLabel
          Left = 233
          Top = 64
          Width = 46
          Height = 18
          Caption = #1042#1086#1083#1100#1090'.'
        end
        object Label12: TLabel
          Left = 17
          Top = 104
          Width = 335
          Height = 18
          Caption = #1045#1089#1083#1080' '#1074#1080#1076#1085#1086' '#1087#1077#1088#1077#1086#1076#1080#1095#1077#1089#1082#1080#1077' '#1074#1077#1088#1090#1080#1082#1072#1083#1100#1085#1099#1077' '#1083#1080#1085#1080#1080','
        end
        object Label13: TLabel
          Left = 17
          Top = 128
          Width = 135
          Height = 18
          Caption = #1090#1086' '#1087#1088#1086#1073#1083#1077#1084#1072' '#1079#1076#1077#1089#1100'.'
        end
        object Edit2: TEdit
          Left = 178
          Top = 32
          Width = 49
          Height = 26
          TabOrder = 0
          Text = '1.8'
        end
        object Edit3: TEdit
          Left = 178
          Top = 64
          Width = 49
          Height = 26
          TabOrder = 1
          Text = '1.86'
        end
      end
      object TabSheet4: TTabSheet
        Caption = #1055#1086#1088#1086#1075
        ImageIndex = 3
        object Label14: TLabel
          Left = 16
          Top = 24
          Width = 379
          Height = 18
          Caption = #1055#1091#1089#1090#1100', '#1088#1072#1073#1086#1095#1072#1103' '#1090#1086#1095#1082#1072' '#1085#1077' '#1084#1086#1078#1077#1090' '#1076#1088#1077#1081#1092#1086#1074#1072#1090#1100' '#1073#1099#1089#1090#1088#1077#1077','
        end
        object Label15: TLabel
          Left = 16
          Top = 56
          Width = 31
          Height = 18
          Caption = #1095#1077#1084' '
        end
        object Label16: TLabel
          Left = 87
          Top = 56
          Width = 243
          Height = 18
          Caption = '% '#1086#1090' '#1088#1072#1073#1086#1095#1077#1081' '#1072#1084#1087#1083#1080#1090#1091#1076#1099' '#1076#1072#1090#1095#1080#1082#1072'.'
        end
        object Label17: TLabel
          Left = 3
          Top = 120
          Width = 393
          Height = 18
          Caption = #1045#1089#1083#1080' '#1089#1080#1083#1100#1085#1099#1081' '#1089#1080#1075#1085#1072#1083' '#1076#1080#1089#1090#1072#1073#1080#1083#1080#1079#1080#1088#1091#1077#1090', '#1085#1091#1078#1085#1086' '#1087#1086#1085#1080#1078#1072#1090#1100
        end
        object Label18: TLabel
          Left = 3
          Top = 144
          Width = 389
          Height = 18
          Caption = #1045#1089#1083#1080' '#1087#1077#1088#1077#1089#1090#1072#1077#1090' '#1092#1080#1083#1100#1090#1088#1086#1074#1072#1090#1100' '#1090#1077#1084#1087#1077#1088#1072#1090#1091#1088#1091' - '#1087#1086#1074#1099#1096#1072#1090#1100'.'
        end
        object Edit4: TEdit
          Left = 53
          Top = 56
          Width = 28
          Height = 26
          TabOrder = 0
          Text = '10'
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 576
    Align = alClient
    AutoSize = True
    TabOrder = 2
    ExplicitWidth = 442
    object chGraph2: TChart
      Left = 1
      Top = 281
      Width = 441
      Height = 280
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
      ExplicitLeft = 2
      ExplicitTop = 37
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
    object chGraph: TChart
      Left = 1
      Top = 1
      Width = 441
      Height = 280
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
      TabOrder = 1
      ExplicitWidth = 440
      object FastLineSeries2: TFastLineSeries
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
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 328
    Top = 368
  end
end
