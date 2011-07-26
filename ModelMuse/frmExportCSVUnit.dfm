inherited frmExportCSV: TfrmExportCSV
  HelpType = htKeyword
  HelpKeyword = 'Export_Data_as_CSV_Dialog_Box'
  Caption = 'Export Data as CSV'
  ClientHeight = 407
  ExplicitWidth = 440
  ExplicitHeight = 441
  PixelsPerInch = 96
  TextHeight = 18
  object Panel1: TPanel
    Left = 0
    Top = 64
    Width = 432
    Height = 343
    Align = alClient
    TabOrder = 0
    DesignSize = (
      432
      343)
    object vstDataSets: TVirtualStringTree
      Left = 8
      Top = 8
      Width = 416
      Height = 256
      Anchors = [akLeft, akTop, akRight, akBottom]
      Header.AutoSizeIndex = 0
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.MainColumn = -1
      TabOrder = 0
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      OnChecked = vstDataSetsChecked
      OnGetText = vstDataSetsGetText
      OnGetNodeDataSize = vstDataSetsGetNodeDataSize
      Columns = <>
    end
    object rgOrientation: TRadioGroup
      Left = 8
      Top = 270
      Width = 113
      Height = 65
      Anchors = [akLeft, akBottom]
      Caption = 'Orientation'
      ItemIndex = 1
      Items.Strings = (
        '2D Top'
        '3D')
      TabOrder = 1
      OnClick = rgOrientationClick
    end
    object rgEvaluatedAt: TRadioGroup
      Left = 127
      Top = 270
      Width = 122
      Height = 65
      Anchors = [akLeft, akBottom]
      Caption = 'Evaluated at'
      ItemIndex = 0
      Items.Strings = (
        'Elements'
        'Nodes')
      TabOrder = 2
      OnClick = rgEvaluatedAtClick
    end
    object btnHelp: TBitBtn
      Left = 320
      Top = 270
      Width = 104
      Height = 27
      Anchors = [akRight, akBottom]
      DoubleBuffered = True
      Kind = bkHelp
      NumGlyphs = 2
      ParentDoubleBuffered = False
      TabOrder = 3
      OnClick = btnHelpClick
    end
    object btnSave: TBitBtn
      Left = 320
      Top = 308
      Width = 104
      Height = 27
      Anchors = [akRight, akBottom]
      Caption = 'Save Data'
      DoubleBuffered = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
        7700333333337777777733333333008088003333333377F73377333333330088
        88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
        000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
        FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
        99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
        99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
        99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
        93337FFFF7737777733300000033333333337777773333333333}
      NumGlyphs = 2
      ParentDoubleBuffered = False
      TabOrder = 4
      OnClick = btnSaveClick
    end
  end
  object pnlModel: TPanel
    Left = 0
    Top = 0
    Width = 432
    Height = 64
    Align = alTop
    TabOrder = 1
    DesignSize = (
      432
      64)
    object lblModel: TLabel
      Left = 8
      Top = 11
      Width = 43
      Height = 18
      Caption = 'Model'
    end
    object comboModel: TComboBox
      Left = 8
      Top = 32
      Width = 423
      Height = 26
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
  end
  object sdSaveCSV: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Comma Separated Value files (*.csv)|*.csv|All Files|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    OnTypeChange = sdSaveCSVTypeChange
    Left = 264
    Top = 288
  end
end
