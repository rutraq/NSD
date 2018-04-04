object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 193
    Height = 284
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 434
    Top = 8
    Width = 193
    Height = 284
    Lines.Strings = (
      'Memo2')
    TabOrder = 1
  end
  object Button1: TButton
    Left = 272
    Top = 112
    Width = 99
    Height = 25
    Caption = #1047#1072#1096#1080#1092#1088#1086#1074#1072#1090#1100
    TabOrder = 2
    OnClick = Button1Click
  end
end
