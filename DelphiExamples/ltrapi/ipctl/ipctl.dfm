object Form1: TForm1
  Left = 504
  Top = 162
  Width = 540
  Height = 355
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' IP-'#1072#1076#1088#1077#1089#1072#1084#1080
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
  object btnGetIpList: TButton
    Left = 16
    Top = 280
    Width = 145
    Height = 25
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1072#1076#1088#1077#1089#1072
    TabOrder = 0
    OnClick = btnGetIpListClick
  end
  object lstIpAddr: TListBox
    Left = 16
    Top = 56
    Width = 457
    Height = 217
    ItemHeight = 13
    TabOrder = 1
  end
  object edtNewIpAddr: TEdit
    Left = 192
    Top = 16
    Width = 137
    Height = 25
    TabOrder = 2
  end
  object btnAddIpAddr: TButton
    Left = 16
    Top = 16
    Width = 145
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1099#1081
    TabOrder = 3
    OnClick = btnAddIpAddrClick
  end
  object chkNewIpAuto: TCheckBox
    Left = 336
    Top = 16
    Width = 97
    Height = 17
    Caption = #1040#1074#1090#1086#1082#1086#1085#1085#1077#1082#1090
    TabOrder = 4
  end
  object btnIpRem: TButton
    Left = 176
    Top = 280
    Width = 113
    Height = 25
    Caption = #1059#1076#1072#1083#1077#1085#1080#1077' '#1072#1076#1088#1077#1089#1072
    TabOrder = 5
    OnClick = btnIpRemClick
  end
  object btnIpConnect: TButton
    Left = 296
    Top = 280
    Width = 89
    Height = 25
    Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100
    TabOrder = 6
    OnClick = btnIpConnectClick
  end
  object btnIpDisconnect: TButton
    Left = 392
    Top = 280
    Width = 75
    Height = 25
    Caption = #1054#1090#1082#1083#1102#1095#1080#1090#1100
    TabOrder = 7
    OnClick = btnIpDisconnectClick
  end
end
