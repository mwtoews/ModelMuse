inherited frmPrintFrequency: TfrmPrintFrequency
  Left = 499
  Top = 181
  Width = 626
  Height = 560
  HelpType = htKeyword
  HelpKeyword = 'Print_Frequency_Dialog_Box'
  VertScrollBar.Range = 73
  Caption = 'PHAST Print Frequency'
  ExplicitWidth = 626
  ExplicitHeight = 560
  PixelsPerInch = 96
  TextHeight = 17
  object pnlBottom: TPanel
    Left = 0
    Top = 453
    Width = 618
    Height = 73
    Align = alBottom
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      618
      73)
    object btnInsert: TButton
      Left = 103
      Top = 6
      Width = 89
      Height = 33
      Caption = 'Insert'
      TabOrder = 1
      OnClick = btnInsertClick
    end
    object btnAdd: TButton
      Left = 8
      Top = 6
      Width = 89
      Height = 33
      Caption = 'Add'
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 198
      Top = 6
      Width = 89
      Height = 33
      Caption = 'Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnOK: TBitBtn
      Left = 424
      Top = 36
      Width = 91
      Height = 33
      Anchors = [akTop, akRight]
      TabOrder = 5
      OnClick = btnOKClick
      Kind = bkOK
    end
    object btnCancel: TBitBtn
      Left = 521
      Top = 36
      Width = 91
      Height = 33
      Anchors = [akTop, akRight]
      TabOrder = 6
      Kind = bkCancel
    end
    object cbSaveFinalHeads: TCheckBox
      Left = 8
      Top = 40
      Width = 273
      Height = 30
      Caption = 'Save final heads in *.head.dat'
      TabOrder = 3
    end
    object btnHelp: TBitBtn
      Left = 329
      Top = 36
      Width = 91
      Height = 33
      Anchors = [akTop, akRight]
      TabOrder = 4
      OnClick = btnHelpClick
      Kind = bkHelp
    end
  end
  object rdgPrintFrequency: TRbwDataGrid4
    Left = 0
    Top = 41
    Width = 618
    Height = 412
    Align = alClient
    ColCount = 4
    FixedCols = 2
    RowCount = 22
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs, goAlwaysShowEditor]
    TabOrder = 1
    OnMouseDown = rdgPrintFrequencyMouseDown
    OnMouseUp = rdgPrintFrequencyMouseUp
    OnSelectCell = rdgPrintFrequencySelectCell
    OnSetEditText = rdgPrintFrequencySetEditText
    AutoDistributeText = True
    AutoIncreaseColCount = True
    AutoIncreaseRowCount = False
    SelectedRowOrColumnColor = clAqua
    UnselectableColor = clBtnFace
    OnBeforeDrawCell = rdgPrintFrequencyBeforeDrawCell
    OnColSize = rdgPrintFrequencyColSize
    ColorRangeSelection = False
    OnHorizontalScroll = rdgPrintFrequencyHorizontalScroll
    OnDistributeTextProgress = rdgPrintFrequencyDistributeTextProgress
    ColorSelectedRow = False
    Columns = <
      item
        AutoAdjustRowHeights = False
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
        ButtonFont.Pitch = fpVariable
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
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
        ButtonFont.Pitch = fpVariable
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
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
        ButtonFont.Pitch = fpVariable
        ButtonFont.Style = []
        ButtonUsed = False
        ButtonWidth = 20
        CheckMax = False
        CheckMin = True
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
        ButtonCaption = '...'
        ButtonFont.Charset = DEFAULT_CHARSET
        ButtonFont.Color = clWindowText
        ButtonFont.Height = -11
        ButtonFont.Name = 'Tahoma'
        ButtonFont.Pitch = fpVariable
        ButtonFont.Style = []
        ButtonUsed = False
        ButtonWidth = 20
        CheckMax = False
        CheckMin = False
        ComboUsed = True
        Format = rcf4String
        LimitToList = True
        MaxLength = 0
        ParentButtonFont = False
        PickList.Strings = (
          'default'
          'seconds'
          'minutes'
          'hours'
          'days'
          'years'
          'step'
          'end')
        WordWrapCaptions = False
        WordWrapCells = False
        AutoAdjustColWidths = True
      end>
    ColWidths = (
      64
      64
      64
      75)
    RowHeights = (
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24)
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 618
    Height = 41
    Align = alTop
    TabOrder = 2
    object rdeTime: TRbwDataEntry
      Left = 136
      Top = 10
      Width = 56
      Height = 22
      Color = clBtnFace
      Enabled = False
      ItemHeight = 17
      TabOrder = 0
      Text = '0'
      OnChange = rdeTimeChange
      DataType = dtReal
      Max = 1.000000000000000000
      CheckMin = True
      ChangeDisabledColor = True
    end
    object comboUnits: TJvImageComboBox
      Left = 198
      Top = 8
      Width = 73
      Height = 27
      Style = csOwnerDrawVariable
      ButtonStyle = fsLighter
      Color = clBtnFace
      DroppedWidth = 145
      Enabled = False
      ImageHeight = 0
      ImageWidth = 0
      ItemHeight = 21
      ItemIndex = 0
      TabOrder = 1
      OnChange = comboUnitsChange
      Items = <
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'default'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'seconds'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'minutes'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'hours'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'days'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'years'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'step'
        end
        item
          Brush.Style = bsClear
          Indent = 0
          Text = 'end'
        end>
    end
  end
end
