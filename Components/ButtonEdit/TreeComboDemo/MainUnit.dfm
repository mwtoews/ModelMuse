object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Tree Combo Demo'
  ClientHeight = 109
  ClientWidth = 241
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
  object rgSelectionChoice: TRadioGroup
    Left = 8
    Top = 8
    Width = 225
    Height = 65
    Caption = 'Selection Choice'
    ItemIndex = 1
    Items.Strings = (
      'Select any'
      'Only select leaves')
    TabOrder = 0
  end
  object RbwStringTreeCombo1: TRbwStringTreeCombo
    Left = 8
    Top = 79
    Width = 225
    Height = 21
    Tree.Left = 0
    Tree.Top = 0
    Tree.Width = 312
    Tree.Height = 206
    Tree.Align = alClient
    Tree.Header.AutoSizeIndex = 0
    Tree.Header.DefaultHeight = 17
    Tree.Header.Font.Charset = DEFAULT_CHARSET
    Tree.Header.Font.Color = clWindowText
    Tree.Header.Font.Height = -11
    Tree.Header.Font.Name = 'Tahoma'
    Tree.Header.Font.Style = []
    Tree.Header.MainColumn = -1
    Tree.TabOrder = 0
    Tree.OnFocusChanging = RbwStringTreeCombo1TreeFocusChanging
    Tree.OnFreeNode = RbwStringTreeCombo1TreeFreeNode
    Tree.OnGetText = RbwStringTreeCombo1TreeGetText
    Tree.OnGetNodeDataSize = RbwStringTreeCombo1TreeGetNodeDataSize
    Tree.OnInitNode = RbwStringTreeCombo1TreeInitNode
    Tree.ExplicitWidth = 200
    Tree.ExplicitHeight = 100
    Tree.Columns = <>
    Enabled = True
    Glyph.Data = {
      36020000424D3602000000000000360000002800000010000000080000000100
      2000000000000002000000000000000000000000000000000000D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC0000000000D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00C0C0C000D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00000000000000000000000000D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00C0C0C000C0C0C000C0C0C000D8E9EC00D8E9EC00D8E9EC00D8E9EC000000
      000000000000000000000000000000000000D8E9EC00D8E9EC00D8E9EC00C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000D8E9EC00D8E9EC00000000000000
      00000000000000000000000000000000000000000000D8E9EC00C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
      EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00}
    NumGlyphs = 2
    TabOrder = 1
  end
end
