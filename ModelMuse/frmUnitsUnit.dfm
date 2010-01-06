inherited frmUnits: TfrmUnits
  Left = 399
  Top = 49
  Width = 734
  Height = 666
  HelpType = htKeyword
  HelpKeyword = 'Title_and_Units_Dialog_Box'
  HorzScrollBar.Range = 723
  VertScrollBar.Range = 28
  ActiveControl = memoTitle
  Caption = 'PHAST Title and Units'
  ExplicitTop = -32
  ExplicitWidth = 734
  ExplicitHeight = 666
  PixelsPerInch = 96
  TextHeight = 17
  object lblTitle: TLabel
    Left = 8
    Top = 8
    Width = 352
    Height = 17
    Caption = 'Title (Only the first two lines will be printed in the output)'
  end
  object lblTimeUnits: TLabel
    Left = 8
    Top = 153
    Width = 65
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Time units'
  end
  object lblHorizGridUnits: TLabel
    Left = 8
    Top = 184
    Width = 126
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Horizontal grid units'
  end
  object lblVertGridUnits: TLabel
    Left = 8
    Top = 215
    Width = 109
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Vertical grid units'
  end
  object lblHeadUnits: TLabel
    Left = 8
    Top = 246
    Width = 68
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Head units'
  end
  object lblHydraulicCondLengthUnits: TLabel
    Left = 8
    Top = 277
    Width = 171
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Hydraulic conductivity units'
  end
  object lblHydraulicCondTimeUnits: TLabel
    Left = 512
    Top = 277
    Width = 21
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'per'
  end
  object lblSpecificStorageUnits: TLabel
    Left = 8
    Top = 308
    Width = 135
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Specific storage units'
  end
  object lblDispersivityUnits: TLabel
    Left = 8
    Top = 339
    Width = 106
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Dispersivity units'
  end
  object lblFluxLengthUnits: TLabel
    Left = 8
    Top = 370
    Width = 59
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Flux units'
  end
  object lblFluxTimeUnits: TLabel
    Left = 511
    Top = 370
    Width = 21
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'per'
  end
  object lblLeakyHydCondLengthUnits: TLabel
    Left = 8
    Top = 401
    Width = 211
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Leaky hydraulic conductivity units'
  end
  object lblLeakyHydCondTimeUnits: TLabel
    Left = 512
    Top = 401
    Width = 21
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'per'
  end
  object lblLeakyThicknessUnits: TLabel
    Left = 8
    Top = 432
    Width = 135
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Leaky thickness units'
  end
  object lblWellDiameterUnits: TLabel
    Left = 8
    Top = 463
    Width = 120
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Well diameter units'
  end
  object lblWellFlowVolumeUnits: TLabel
    Left = 8
    Top = 494
    Width = 118
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Well flow rate units'
  end
  object lblWellFlowTimeUnits: TLabel
    Left = 511
    Top = 494
    Width = 21
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'per'
  end
  object lblRiverHydCondLengthUnits: TLabel
    Left = 8
    Top = 525
    Width = 234
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'River bed hydraulic conductivity units'
  end
  object lblRiverHydCondTimeUnits: TLabel
    Left = 511
    Top = 525
    Width = 21
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'per'
  end
  object lblRiverThicknessUnits: TLabel
    Left = 8
    Top = 556
    Width = 158
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'River bed thickness units'
  end
  object memoTitle: TMemo
    Left = 8
    Top = 40
    Width = 715
    Height = 104
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object btnOK: TBitBtn
    Left = 528
    Top = 590
    Width = 89
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      04000000000068010000120B0000120B00001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object btnCancel: TBitBtn
    Left = 624
    Top = 590
    Width = 91
    Height = 33
    Anchors = [akLeft, akBottom]
    TabOrder = 21
    Kind = bkCancel
  end
  object comboTimeUnits: TComboBox
    Left = 328
    Top = 150
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 2
    Items.Strings = (
      'seconds'
      'minutes'
      'hours'
      'days'
      'years')
  end
  object comboHorizGridUnits: TComboBox
    Left = 328
    Top = 181
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 3
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboVertGridUnits: TComboBox
    Left = 328
    Top = 212
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 4
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboHeadUnits: TComboBox
    Left = 328
    Top = 243
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 5
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboHydraulicCondLengthUnits: TComboBox
    Left = 328
    Top = 274
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 6
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboHydraulicCondTimeUnits: TComboBox
    Left = 541
    Top = 274
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 7
    Items.Strings = (
      'second'
      'minute'
      'hour'
      'day'
      'year')
  end
  object comboSpecificStorageUnits: TComboBox
    Left = 328
    Top = 305
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 8
    Items.Strings = (
      '1/inches'
      '1/feet'
      '1/miles'
      '1/millimeters'
      '1/centimeters'
      '1/meters'
      '1/kilometers')
  end
  object comboDispersivityUnits: TComboBox
    Left = 328
    Top = 336
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 9
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboFluxLengthUnits: TComboBox
    Left = 328
    Top = 367
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 10
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboFluxTimeUnits: TComboBox
    Left = 541
    Top = 367
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 11
    Items.Strings = (
      'second'
      'minute'
      'hour'
      'day'
      'year')
  end
  object comboLeakyHydCondLengthUnits: TComboBox
    Left = 328
    Top = 398
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 12
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboLeakyHydCondTimeUnits: TComboBox
    Left = 541
    Top = 398
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 13
    Items.Strings = (
      'second'
      'minute'
      'hour'
      'day'
      'year')
  end
  object comboLeakyThicknessUnits: TComboBox
    Left = 328
    Top = 429
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 14
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboWellDiameterUnits: TComboBox
    Left = 328
    Top = 460
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 15
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboWellFlowVolumeUnits: TComboBox
    Left = 328
    Top = 491
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 16
    Items.Strings = (
      'gallons'
      'inches^3'
      'feet^3'
      'miles^3'
      'liters'
      'millimeters^3'
      'centimeters^3'
      'meters^3'
      'kilometers^3')
  end
  object comboWellFlowTimeUnits: TComboBox
    Left = 541
    Top = 491
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 17
    Items.Strings = (
      'second'
      'minute'
      'hour'
      'day'
      'year')
  end
  object comboRiverHydCondLengthUnits: TComboBox
    Left = 328
    Top = 522
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 18
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object comboRiverHydCondTimeUnits: TComboBox
    Left = 541
    Top = 522
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 19
    Items.Strings = (
      'second'
      'minute'
      'hour'
      'day'
      'year')
  end
  object comboRiverThicknessUnits: TComboBox
    Left = 328
    Top = 553
    Width = 177
    Height = 25
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    ItemHeight = 17
    TabOrder = 20
    Items.Strings = (
      'inches'
      'feet'
      'miles'
      'millimeters'
      'centimeters'
      'meters'
      'kilometers')
  end
  object btnHelp: TBitBtn
    Left = 433
    Top = 590
    Width = 89
    Height = 33
    HelpType = htKeyword
    Anchors = [akLeft, akBottom]
    TabOrder = 22
    OnClick = btnHelpClick
    Kind = bkHelp
  end
end
