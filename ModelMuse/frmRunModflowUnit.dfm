object frmRunModflow: TfrmRunModflow
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'frmRunModflow'
  ClientHeight = 31
  ClientWidth = 364
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cbRun: TCheckBox
    Left = 8
    Top = 8
    Width = 102
    Height = 17
    Caption = 'Execute model'
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object comboModelSelection: TComboBox
    Left = 104
    Top = 6
    Width = 241
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
end
