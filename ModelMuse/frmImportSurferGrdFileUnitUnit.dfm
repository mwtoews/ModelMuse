inherited frmImportSurferGrdFile: TfrmImportSurferGrdFile
  Width = 612
  Height = 406
  HelpKeyword = 'Import_Surfer_Grid_File'
  Caption = 'Import Surfer Grid File'
  ExplicitWidth = 612
  ExplicitHeight = 406
  PixelsPerInch = 120
  TextHeight = 18
  inherited lblDataSet: TLabel
    Top = 124
    ExplicitTop = 124
  end
  inherited lblInterpolator: TLabel
    Top = 192
    ExplicitTop = 192
  end
  object Label1: TLabel [2]
    Left = 8
    Top = 8
    Width = 99
    Height = 18
    Caption = 'Grid file extent'
  end
  inherited comboDataSets: TComboBox
    Top = 148
    Width = 578
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    ExplicitTop = 148
    ExplicitWidth = 578
  end
  inherited comboInterpolators: TComboBox
    Top = 213
    TabOrder = 3
    ExplicitTop = 213
  end
  inherited cbEnclosedCells: TCheckBox
    Left = 496
    Top = 277
    Width = 41
    TabOrder = 6
    Visible = False
    ExplicitLeft = 496
    ExplicitTop = 277
    ExplicitWidth = 41
  end
  inherited cbIntersectedCells: TCheckBox
    Top = 245
    Width = 329
    TabOrder = 4
    ExplicitTop = 245
    ExplicitWidth = 329
  end
  inherited cbInterpolation: TCheckBox
    Left = 8
    Top = 276
    Width = 321
    TabOrder = 5
    ExplicitLeft = 8
    ExplicitTop = 276
    ExplicitWidth = 321
  end
  inherited rgEvaluatedAt: TRadioGroup
    Top = 313
    TabOrder = 7
    ExplicitTop = 313
  end
  inherited btnOK: TBitBtn
    Left = 398
    Top = 324
    TabOrder = 9
    OnClick = btnOKClick
    ExplicitLeft = 398
    ExplicitTop = 324
  end
  inherited btnCancel: TBitBtn
    Left = 495
    Top = 324
    TabOrder = 10
    ExplicitLeft = 495
    ExplicitTop = 324
  end
  inherited btnHelp: TBitBtn
    Left = 301
    Top = 324
    TabOrder = 8
    ExplicitLeft = 301
    ExplicitTop = 324
  end
  object rdgLimits: TRbwDataGrid4 [12]
    Left = 8
    Top = 29
    Width = 578
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    ColCount = 4
    FixedCols = 1
    RowCount = 3
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor]
    TabOrder = 0
    ExtendedAutoDistributeText = False
    AutoMultiEdit = True
    AutoDistributeText = False
    AutoIncreaseColCount = False
    AutoIncreaseRowCount = False
    SelectedRowOrColumnColor = clAqua
    UnselectableColor = clBtnFace
    ColorRangeSelection = False
    Columns = <
      item
        AutoAdjustRowHeights = False
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
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
        CaseSensitivePicklist = False
        CheckStyle = csCheck
        AutoAdjustColWidths = True
      end
      item
        AutoAdjustRowHeights = False
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
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
        CaseSensitivePicklist = False
        CheckStyle = csCheck
        AutoAdjustColWidths = True
      end
      item
        AutoAdjustRowHeights = False
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
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
        CaseSensitivePicklist = False
        CheckStyle = csCheck
        AutoAdjustColWidths = True
      end
      item
        AutoAdjustRowHeights = False
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
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
        CaseSensitivePicklist = False
        CheckStyle = csCheck
        AutoAdjustColWidths = True
      end>
    WordWrapRowCaptions = False
  end
  object rgFilterMethod: TRadioGroup [13]
    Left = 346
    Top = 178
    Width = 240
    Height = 140
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Filter method'
    ItemIndex = 2
    Items.Strings = (
      'Lowest point in cell'
      'Highest point in cell'
      'Average of points in cell'
      'Point closest to cell center'
      'None')
    TabOrder = 2
  end
  inherited OpenDialogFile: TOpenDialog
    Filter = 'Surfer grid file (*.grd, *.dat)|*.grd;*.dat|All files (*.*)|*.*'
    Title = 'Open a Surfer grid file'
    Top = 184
  end
end
