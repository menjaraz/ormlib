object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'ORM Test Application'
  ClientHeight = 422
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 350
    Top = 63
    Width = 200
    Height = 13
    Caption = #1053#1072#1078#1084#1080#1090#1077'"Connect" '#1076#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103'...'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 589
    Height = 51
    Align = alTop
    TabOrder = 0
    object Panel2: TPanel
      Left = 332
      Top = 1
      Width = 256
      Height = 49
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitHeight = 47
      object ComboBox1: TComboBox
        AlignWithMargins = True
        Left = 25
        Top = 13
        Width = 145
        Height = 21
        Margins.Top = 13
        Align = alRight
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'MS Access'
        Items.Strings = (
          'MS Access'
          'MS SQL Server 2005'
          'PostgreSQL')
        ExplicitLeft = 15
        ExplicitTop = 14
      end
      object Button2: TButton
        AlignWithMargins = True
        Left = 176
        Top = 10
        Width = 75
        Height = 28
        Margins.Top = 10
        Margins.Right = 5
        Margins.Bottom = 11
        Align = alRight
        Caption = 'Connect'
        TabOrder = 1
        OnClick = Button2Click
        ExplicitLeft = 166
        ExplicitTop = 12
        ExplicitHeight = 25
      end
    end
  end
  object TaskPanel: TPanel
    Left = 0
    Top = 51
    Width = 589
    Height = 51
    Align = alTop
    TabOrder = 1
    Visible = False
    ExplicitTop = 49
    object Label5: TLabel
      AlignWithMargins = True
      Left = 9
      Top = 16
      Width = 54
      Height = 31
      Margins.Left = 8
      Margins.Top = 15
      Align = alLeft
      Caption = #1054#1087#1077#1088#1072#1094#1080#1103':'
      ExplicitHeight = 13
    end
    object cbTask: TComboBox
      AlignWithMargins = True
      Left = 69
      Top = 14
      Width = 433
      Height = 21
      Margins.Top = 13
      Align = alClient
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbTaskChange
      Items.Strings = (
        #1057#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1089#1093#1077#1084#1091' '#1076#1072#1085#1085#1099#1093
        #1042#1099#1073#1086#1088#1082#1072' '#1074#1089#1077#1093' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
        #1042#1099#1073#1086#1088#1082#1072' '#1089' '#1091#1089#1083#1086#1074#1080#1077#1084
        #1042#1099#1073#1086#1088#1082#1072' '#1089' '#1089#1086#1088#1090#1080#1088#1086#1074#1082#1086#1081
        #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1079#1072#1087#1080#1089#1077#1081' '#1074' '#1090#1072#1073#1083#1080#1094#1077
        #1042#1099#1073#1086#1088#1082#1072' '#1076#1072#1085#1085#1099#1093' '#1080#1079' '#1079#1072#1076#1072#1085#1085#1099#1093' '#1087#1086#1083#1077#1081
        #1042#1099#1073#1086#1088#1082#1072' '#1076#1072#1085#1085#1099#1093' '#1080#1079' '#1089#1074#1103#1079#1072#1085#1085#1099#1093' '#1090#1072#1073#1083#1080#1094
        #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
        #1054#1073#1085#1086#1074#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
        #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
        #1044#1086#1073#1072#1074#1080#1090#1100' 10 '#1085#1086#1074#1099#1093' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081)
    end
    object Button12: TButton
      AlignWithMargins = True
      Left = 508
      Top = 11
      Width = 75
      Height = 28
      Margins.Top = 10
      Margins.Right = 5
      Margins.Bottom = 11
      Align = alRight
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
      TabOrder = 1
      OnClick = Button12Click
    end
  end
  object LogPanel: TPanel
    Left = 0
    Top = 320
    Width = 589
    Height = 102
    Align = alBottom
    TabOrder = 2
    Visible = False
    object Label6: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 28
      Height = 94
      Align = alLeft
      Caption = #1051#1086#1075#1080':'
      ExplicitHeight = 13
    end
    object mLog: TMemo
      AlignWithMargins = True
      Left = 38
      Top = 4
      Width = 547
      Height = 94
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object CodePanel: TPanel
    Left = 0
    Top = 102
    Width = 589
    Height = 66
    Align = alTop
    Caption = 'CodePanel'
    TabOrder = 3
    Visible = False
    ExplicitTop = 100
    object Label7: TLabel
      AlignWithMargins = True
      Left = 9
      Top = 4
      Width = 24
      Height = 58
      Margins.Left = 8
      Align = alLeft
      Caption = #1050#1086#1076':'
      Visible = False
      ExplicitHeight = 13
    end
    object mCode: TMemo
      AlignWithMargins = True
      Left = 39
      Top = 4
      Width = 546
      Height = 58
      Align = alClient
      TabOrder = 0
    end
  end
  object BodyPanel: TPanel
    Left = 0
    Top = 168
    Width = 589
    Height = 152
    Align = alClient
    TabOrder = 4
    Visible = False
    ExplicitTop = 166
    ExplicitHeight = 154
    object Panel4: TPanel
      Left = 408
      Top = 1
      Width = 180
      Height = 150
      Align = alRight
      TabOrder = 0
      ExplicitHeight = 152
      object Id: TLabel
        Left = 17
        Top = 21
        Width = 10
        Height = 13
        Caption = 'Id'
      end
      object Label3: TLabel
        Left = 17
        Top = 58
        Width = 27
        Height = 13
        Caption = 'Name'
      end
      object Label2: TLabel
        Left = 15
        Top = 93
        Width = 19
        Height = 13
        Caption = 'Age'
      end
      object Edit2: TEdit
        Left = 58
        Top = 18
        Width = 97
        Height = 21
        Enabled = False
        TabOrder = 0
        Text = '6'
      end
      object Edit3: TEdit
        Left = 58
        Top = 55
        Width = 97
        Height = 21
        TabOrder = 1
        Text = 'New_User'
      end
      object Edit4: TEdit
        Left = 58
        Top = 90
        Width = 97
        Height = 21
        TabOrder = 2
        Text = '123.4'
      end
    end
    object StringGrid1: TStringGrid
      Left = 1
      Top = 1
      Width = 407
      Height = 150
      Align = alClient
      ColCount = 3
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 1
      OnSelectCell = StringGrid1SelectCell
      ExplicitHeight = 152
      ColWidths = (
        64
        131
        64)
    end
  end
end
