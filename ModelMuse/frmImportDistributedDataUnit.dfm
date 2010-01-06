inherited frmImportDistributedData: TfrmImportDistributedData
  Left = 392
  Top = 183
  Width = 471
  Height = 462
  HelpType = htKeyword
  HelpKeyword = 'Import_Distributed_Data_by_Zone'
  VertScrollBar.Range = 210
  Caption = 'Import Distributed Data by Zone'
  OnResize = FormResize
  ExplicitWidth = 471
  ExplicitHeight = 462
  PixelsPerInch = 96
  TextHeight = 17
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 463
    Height = 169
    Align = alTop
    ParentColor = True
    TabOrder = 0
    object lblLowerX: TLabel
      Left = 8
      Top = 12
      Width = 54
      Height = 17
      Caption = 'Lower X'#39
    end
    object lblHigherX: TLabel
      Left = 256
      Top = 12
      Width = 58
      Height = 17
      Caption = 'Higher X'#39
    end
    object lblLowerY: TLabel
      Left = 8
      Top = 52
      Width = 54
      Height = 17
      Caption = 'Lower Y'#39
    end
    object lblHigherY: TLabel
      Left = 256
      Top = 52
      Width = 58
      Height = 17
      Caption = 'Higher Y'#39
    end
    object lblLowerZ: TLabel
      Left = 8
      Top = 92
      Width = 51
      Height = 17
      Caption = 'Lower Z'
    end
    object lblHigherZ: TLabel
      Left = 256
      Top = 92
      Width = 55
      Height = 17
      Caption = 'Higher Z'
    end
    object lblImportTo: TLabel
      Left = 8
      Top = 132
      Width = 59
      Height = 17
      Caption = 'Import to '
    end
    object rdeLowerX: TRbwDataEntry
      Left = 104
      Top = 8
      Width = 101
      Height = 28
      Cursor = crIBeam
      ItemHeight = 17
      TabOrder = 1
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeHigherX: TRbwDataEntry
      Left = 352
      Top = 8
      Width = 101
      Height = 28
      Cursor = crIBeam
      ItemHeight = 17
      TabOrder = 0
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeLowerY: TRbwDataEntry
      Left = 104
      Top = 48
      Width = 101
      Height = 28
      Cursor = crIBeam
      ItemHeight = 17
      TabOrder = 3
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeHigherY: TRbwDataEntry
      Left = 352
      Top = 48
      Width = 101
      Height = 28
      Cursor = crIBeam
      ItemHeight = 17
      TabOrder = 2
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeLowerZ: TRbwDataEntry
      Left = 104
      Top = 88
      Width = 101
      Height = 28
      Cursor = crIBeam
      ItemHeight = 17
      TabOrder = 4
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeHigherZ: TRbwDataEntry
      Left = 352
      Top = 88
      Width = 101
      Height = 28
      Cursor = crIBeam
      ItemHeight = 17
      TabOrder = 5
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object comboViewDirection: TComboBox
      Left = 104
      Top = 128
      Width = 101
      Height = 25
      Style = csDropDownList
      ItemHeight = 17
      ItemIndex = 0
      TabOrder = 6
      Text = 'Top'
      OnChange = comboViewDirectionChange
      Items.Strings = (
        'Top'
        'Front'
        'Side')
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 387
    Width = 463
    Height = 41
    Align = alBottom
    ParentColor = True
    TabOrder = 2
    DesignSize = (
      463
      41)
    object btnOK: TBitBtn
      Left = 275
      Top = 4
      Width = 89
      Height = 33
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      Enabled = False
      ModalResult = 1
      TabOrder = 1
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
      Left = 371
      Top = 4
      Width = 91
      Height = 33
      Anchors = [akTop, akRight]
      TabOrder = 2
      Kind = bkCancel
    end
    object btnHelp: TBitBtn
      Left = 179
      Top = 4
      Width = 89
      Height = 33
      Anchors = [akTop, akRight]
      TabOrder = 0
      OnClick = btnHelpClick
      Kind = bkHelp
    end
  end
  object dgDataSets: TRbwDataGrid4
    Left = 0
    Top = 169
    Width = 463
    Height = 218
    Align = alClient
    ColCount = 2
    DefaultColWidth = 100
    FixedCols = 1
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs, goAlwaysShowEditor]
    TabOrder = 1
    AutoDistributeText = False
    AutoIncreaseColCount = False
    AutoIncreaseRowCount = False
    SelectedRowOrColumnColor = clAqua
    UnselectableColor = clBtnFace
    OnButtonClick = dgDataSetsButtonClicked
    ColorRangeSelection = False
    ColorSelectedRow = True
    Columns = <
      item
        AutoAdjustRowHeights = False
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'MS Sans Serif'
        ButtonFont.Style = []
        ButtonUsed = False
        ButtonWidth = 20
        CheckMax = False
        CheckMin = False
        ComboUsed = False
        Format = rcf4String
        LimitToList = False
        MaxLength = 0
        ParentButtonFont = False
        WordWrapCaptions = False
        WordWrapCells = False
        AutoAdjustColWidths = True
      end
      item
        AutoAdjustRowHeights = False
        ButtonCaption = 'Browse'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clBlack
        ButtonFont.Height = 17
        ButtonFont.Name = 'Microsoft Sans Serif'
        ButtonFont.Pitch = fpVariable
        ButtonFont.Style = []
        ButtonUsed = True
        ButtonWidth = 60
        CheckMax = False
        CheckMin = False
        ComboUsed = False
        Format = rcf4String
        LimitToList = False
        MaxLength = 0
        ParentButtonFont = False
        WordWrapCaptions = False
        WordWrapCells = False
        AutoAdjustColWidths = True
      end>
  end
  object OpenDialogFile: TOpenDialog
    Filter = 'Dat files (*.dat)|*.dat|All fIles (*.*)|*.*'
    FilterIndex = 0
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Select a file containing zone values'
    Left = 232
    Top = 40
  end
end
