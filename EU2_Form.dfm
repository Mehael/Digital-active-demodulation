object MainForm: TMainForm
  Left = 356
  Top = 162
  Caption = #1057#1073#1086#1088' '#1044#1072#1085#1085#1099#1093' EU2'
  ClientHeight = 430
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 411
    Width = 643
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
    Left = 320
    Top = 0
    Width = 323
    Height = 411
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
      Left = 20
      Top = 105
      Width = 82
      Height = 13
      Caption = #1055#1080#1089#1072#1090#1100' '#1082#1072#1078#1076#1086#1077':'
    end
    object TimerText: TLabel
      Left = 192
      Top = 322
      Width = 9
      Height = 34
      Align = alCustom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -28
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object bnStart: TButton
      Left = 179
      Top = 360
      Width = 133
      Height = 44
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
    object Edit1: TEdit
      Left = 108
      Top = 78
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 3
      Text = '2'
    end
    object txPath: TEdit
      Left = 108
      Top = 51
      Width = 121
      Height = 21
      TabOrder = 4
      Text = 'D:\DataACP'
    end
    object txWorkTime: TEdit
      Left = 109
      Top = 24
      Width = 33
      Height = 21
      TabOrder = 5
      Text = '1'
    end
    object skipVal: TEdit
      Left = 108
      Top = 105
      Width = 33
      Height = 21
      Enabled = False
      TabOrder = 6
      Text = '10'
    end
    object PageControl1: TPageControl
      Left = 12
      Top = 144
      Width = 301
      Height = 174
      ActivePage = TabSheet6
      MultiLine = True
      TabOrder = 7
      object TabSheet6: TTabSheet
        Caption = #1056#1077#1078#1080#1084
        ImageIndex = 5
        object CheckBox1: TCheckBox
          Left = 14
          Top = 14
          Width = 166
          Height = 16
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085#1080#1077' '#1082#1072#1083#1080#1073#1088#1086#1074#1082#1080
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object CheckBox2: TCheckBox
          Left = 14
          Top = 35
          Width = 120
          Height = 16
          Caption = #1041#1077#1089#1082#1086#1085#1077#1095#1085#1072#1103' '#1079#1072#1087#1080#1089#1100
          TabOrder = 1
        end
        object CheckBox3: TCheckBox
          Left = 14
          Top = 56
          Width = 120
          Height = 16
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1089#1080#1075#1085#1072#1083
          TabOrder = 2
        end
      end
      object TabSheet1: TTabSheet
        Caption = #1055#1083#1072#1090#1072
        object lblAdcFreq: TLabel
          Left = 27
          Top = 71
          Width = 90
          Height = 13
          Caption = #1063#1072#1089#1090#1086#1090#1072' '#1040#1062#1055' ('#1043#1094')'
        end
        object lblChAc1: TLabel
          Left = 47
          Top = 36
          Width = 73
          Height = 13
          Caption = #1054#1090#1089#1077#1095#1082#1072' '#1087#1086#1089#1090'.'
        end
        object lblChAc2: TLabel
          Left = 44
          Top = 48
          Width = 76
          Height = 13
          Caption = #1089#1086#1089#1090#1072#1074#1083#1103#1102#1097#1077#1081
        end
        object lblDataFmt: TLabel
          Left = 15
          Top = 100
          Width = 107
          Height = 13
          Caption = #1056#1072#1079#1088#1103#1076#1085#1086#1089#1090#1100' '#1076#1072#1085#1085#1099#1093
        end
        object lblRange1: TLabel
          Left = 71
          Top = 10
          Width = 49
          Height = 13
          Caption = #1044#1080#1072#1087#1072#1079#1086#1085
        end
        object cbbAC1: TComboBox
          Left = 122
          Top = 41
          Width = 113
          Height = 21
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = #1042#1099#1082#1083'. (AC+DC)'
          Items.Strings = (
            #1042#1099#1082#1083'. (AC+DC)'
            #1042#1082#1083'. (AC)')
        end
        object cbbAdcFreq: TComboBox
          Left = 122
          Top = 70
          Width = 77
          Height = 21
          ItemHeight = 13
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
          Left = 121
          Top = 99
          Width = 75
          Height = 21
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 2
          Text = '20 '#1073#1080#1090
          Items.Strings = (
            '20 '#1073#1080#1090
            '24 '#1073#1080#1090#1072)
        end
        object cbbRange1: TComboBox
          Left = 122
          Top = 10
          Width = 56
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
      object TabSheet2: TTabSheet
        Caption = #1054#1087#1090#1080#1084'.'
        ImageIndex = 1
        object Label5: TLabel
          Left = 131
          Top = 17
          Width = 71
          Height = 13
          Caption = '% '#1072#1084#1087#1083#1080#1090#1091#1076#1099
        end
        object Label4: TLabel
          Left = 19
          Top = 17
          Width = 68
          Height = 13
          Caption = #1042#1099#1089#1086#1090#1072' '#1086#1082#1085#1072':'
        end
        object Label6: TLabel
          Left = 16
          Top = 57
          Width = 247
          Height = 13
          Caption = #1045#1089#1083#1080' '#1088#1072#1073#1086#1095#1072#1103' '#1090#1086#1095#1082#1072' '#1089#1076#1074#1080#1085#1091#1083#1072#1089#1100' '#1084#1077#1085#1100#1096#1077', '#1095#1077#1084' '#1085#1072' '
        end
        object Label7: TLabel
          Left = 17
          Top = 74
          Width = 185
          Height = 13
          Caption = #1091#1082#1072#1079#1072#1085#1085#1099#1081' '#1087#1088#1086#1094#1077#1085#1090', '#1080#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100'. '
        end
        object PercentEdit: TSpinEdit
          Left = 92
          Top = 15
          Width = 35
          Height = 22
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
          Left = 12
          Top = 23
          Width = 110
          Height = 13
          Caption = #1057#1073#1088#1086#1089' 1-'#1086#1075#1086' '#1076#1072#1090#1095#1080#1082#1072':'
        end
        object Label9: TLabel
          Left = 12
          Top = 46
          Width = 110
          Height = 13
          Caption = #1057#1073#1088#1086#1089' 2-'#1086#1075#1086' '#1076#1072#1090#1095#1080#1082#1072':'
        end
        object Label10: TLabel
          Left = 168
          Top = 23
          Width = 34
          Height = 13
          Caption = #1042#1086#1083#1100#1090'.'
        end
        object Label11: TLabel
          Left = 168
          Top = 46
          Width = 34
          Height = 13
          Caption = #1042#1086#1083#1100#1090'.'
        end
        object Label12: TLabel
          Left = 12
          Top = 75
          Width = 252
          Height = 13
          Caption = #1045#1089#1083#1080' '#1074#1080#1076#1085#1086' '#1087#1077#1088#1077#1086#1076#1080#1095#1077#1089#1082#1080#1077' '#1074#1077#1088#1090#1080#1082#1072#1083#1100#1085#1099#1077' '#1083#1080#1085#1080#1080','
        end
        object Label13: TLabel
          Left = 12
          Top = 92
          Width = 99
          Height = 13
          Caption = #1090#1086' '#1087#1088#1086#1073#1083#1077#1084#1072' '#1079#1076#1077#1089#1100'.'
        end
        object Edit2: TEdit
          Left = 129
          Top = 23
          Width = 35
          Height = 21
          TabOrder = 0
          Text = '1.8'
        end
        object Edit3: TEdit
          Left = 129
          Top = 46
          Width = 35
          Height = 21
          TabOrder = 1
          Text = '1.86'
        end
      end
      object TabSheet4: TTabSheet
        Caption = #1055#1086#1088#1086#1075
        ImageIndex = 3
        object Label14: TLabel
          Left = 12
          Top = 17
          Width = 278
          Height = 13
          Caption = #1055#1091#1089#1090#1100', '#1088#1072#1073#1086#1095#1072#1103' '#1090#1086#1095#1082#1072' '#1085#1077' '#1084#1086#1078#1077#1090' '#1076#1088#1077#1081#1092#1086#1074#1072#1090#1100' '#1073#1099#1089#1090#1088#1077#1077','
        end
        object Label15: TLabel
          Left = 12
          Top = 40
          Width = 21
          Height = 13
          Caption = #1095#1077#1084' '
        end
        object Label16: TLabel
          Left = 63
          Top = 40
          Width = 181
          Height = 13
          Caption = '% '#1086#1090' '#1088#1072#1073#1086#1095#1077#1081' '#1072#1084#1087#1083#1080#1090#1091#1076#1099' '#1076#1072#1090#1095#1080#1082#1072'.'
        end
        object Label17: TLabel
          Left = 2
          Top = 87
          Width = 290
          Height = 13
          Caption = #1045#1089#1083#1080' '#1089#1080#1083#1100#1085#1099#1081' '#1089#1080#1075#1085#1072#1083' '#1076#1080#1089#1090#1072#1073#1080#1083#1080#1079#1080#1088#1091#1077#1090', '#1085#1091#1078#1085#1086' '#1087#1086#1085#1080#1078#1072#1090#1100
        end
        object Label18: TLabel
          Left = 2
          Top = 104
          Width = 285
          Height = 13
          Caption = #1045#1089#1083#1080' '#1087#1077#1088#1077#1089#1090#1072#1077#1090' '#1092#1080#1083#1100#1090#1088#1086#1074#1072#1090#1100' '#1090#1077#1084#1087#1077#1088#1072#1090#1091#1088#1091' - '#1087#1086#1074#1099#1096#1072#1090#1100'.'
        end
        object Edit4: TEdit
          Left = 38
          Top = 40
          Width = 21
          Height = 21
          TabOrder = 0
          Text = '10'
        end
      end
      object TabSheet5: TTabSheet
        Caption = #1052#1085#1086#1078#1080#1090'.'
        ImageIndex = 5
        object Label19: TLabel
          Left = 12
          Top = 12
          Width = 259
          Height = 13
          Caption = 'Spectro '#1085#1077' '#1087#1086#1085#1080#1084#1072#1077#1090' '#1095#1080#1089#1083#1072' < 1, '#1087#1086#1101#1090#1086#1084#1091' '#1091#1084#1085#1086#1078#1072#1077#1084' '
        end
        object Label20: TLabel
          Left = 12
          Top = 29
          Width = 103
          Height = 13
          Caption = #1087#1086#1083#1091#1095#1072#1077#1084#1099#1081' '#1089#1080#1075#1085#1072#1083'.'
        end
        object Label21: TLabel
          Left = 41
          Top = 64
          Width = 54
          Height = 13
          Caption = '1'#1081' '#1082#1072#1085#1072#1083' *'
        end
        object Label22: TLabel
          Left = 41
          Top = 87
          Width = 54
          Height = 13
          Caption = '2'#1081' '#1082#1072#1085#1072#1083' *'
        end
        object Edit5: TEdit
          Left = 98
          Top = 64
          Width = 88
          Height = 21
          TabOrder = 0
          Text = '1'
        end
        object Edit6: TEdit
          Left = 98
          Top = 87
          Width = 87
          Height = 21
          TabOrder = 1
          Text = '100000'
        end
      end
      object TabSheet7: TTabSheet
        Caption = #1053#1080#1079#1082#1086#1095'.'
        ImageIndex = 6
        object Label23: TLabel
          Left = 2
          Top = 17
          Width = 286
          Height = 13
          Caption = #1053#1080#1079#1082#1086#1095#1072#1089#1090#1086#1090#1085#1099#1081' '#1089#1080#1075#1085#1072#1083' '#1089#1095#1080#1090#1072#1077#1090#1089#1103' '#1089#1082#1086#1083#1100#1079#1103#1097#1080#1084' '#1089#1088#1077#1076#1085#1080#1084
        end
        object Label24: TLabel
          Left = 2
          Top = 40
          Width = 89
          Height = 13
          Caption = #1041#1077#1088#1077#1090#1089#1103' '#1089#1088#1077#1076#1085#1077#1077' '
        end
        object Label25: TLabel
          Left = 135
          Top = 40
          Width = 82
          Height = 13
          Caption = #1073#1083#1086#1082#1086#1074' '#1076#1072#1085#1085#1099#1093'.'
        end
        object Label26: TLabel
          Left = 2
          Top = 81
          Width = 118
          Height = 13
          Caption = #1050#1072#1078#1076#1099#1081' '#1073#1083#1086#1082' '#1087#1080#1096#1077#1090#1089#1103' '
        end
        object Label27: TLabel
          Left = 157
          Top = 81
          Width = 64
          Height = 13
          Caption = #1084#1080#1083#1080#1089#1077#1082#1091#1085#1076'.'
        end
        object Edit7: TEdit
          Left = 98
          Top = 40
          Width = 33
          Height = 21
          TabOrder = 0
          Text = '40'
        end
        object Edit8: TEdit
          Left = 122
          Top = 81
          Width = 31
          Height = 21
          TabOrder = 1
          Text = '10'
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 411
    Align = alClient
    AutoSize = True
    TabOrder = 2
    object chGraph2: TChart
      Left = 1
      Top = 203
      Width = 318
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
    object chGraph: TChart
      Left = 1
      Top = 1
      Width = 318
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
      TabOrder = 1
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
