inherited frameScreenObjectLAK: TframeScreenObjectLAK
  Width = 463
  Height = 417
  ExplicitWidth = 463
  ExplicitHeight = 417
  inherited pnlBottom: TPanel
    Top = 160
    Width = 463
    Height = 257
    ExplicitTop = 160
    ExplicitWidth = 463
    ExplicitHeight = 257
    DesignSize = (
      463
      257)
    object lblInitialStage: TLabel [1]
      Left = 79
      Top = 80
      Width = 56
      Height = 13
      Caption = 'Initial stage'
    end
    object lblCenterLake: TLabel [2]
      Left = 362
      Top = 48
      Width = 55
      Height = 13
      Caption = 'Center lake'
    end
    object lblSill: TLabel [3]
      Left = 362
      Top = 80
      Width = 12
      Height = 13
      Caption = 'Sill'
    end
    object lblLakeID: TLabel [4]
      Left = 79
      Top = 48
      Width = 36
      Height = 13
      Caption = 'Lake ID'
    end
    inherited btnDelete: TBitBtn
      Left = 375
      ExplicitLeft = 375
    end
    inherited btnInsert: TBitBtn
      Left = 291
      ExplicitLeft = 291
    end
    object rdeInitialStage: TRbwDataEntry
      Left = 8
      Top = 77
      Width = 65
      Height = 22
      ItemHeight = 13
      TabOrder = 3
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeCenterLake: TRbwDataEntry
      Left = 291
      Top = 45
      Width = 65
      Height = 22
      ItemHeight = 13
      TabOrder = 4
      Text = '0'
      OnChange = rdeCenterLakeChange
      DataType = dtInteger
      Max = 1.000000000000000000
      CheckMin = True
      ChangeDisabledColor = True
    end
    object rdeSill: TRbwDataEntry
      Left = 291
      Top = 73
      Width = 65
      Height = 22
      Color = clBtnFace
      Enabled = False
      ItemHeight = 13
      TabOrder = 5
      Text = '0'
      DataType = dtReal
      Max = 1.000000000000000000
      ChangeDisabledColor = True
    end
    object rdeLakeID: TRbwDataEntry
      Left = 8
      Top = 45
      Width = 65
      Height = 22
      ItemHeight = 13
      TabOrder = 6
      Text = '1'
      DataType = dtInteger
      Max = 1.000000000000000000
      Min = 1.000000000000000000
      CheckMin = True
      ChangeDisabledColor = True
    end
    object gbGage: TGroupBox
      Left = 8
      Top = 105
      Width = 449
      Height = 144
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Gage output'
      TabOrder = 7
      DesignSize = (
        449
        144)
      object cbGagStandard: TCheckBox
        Left = 3
        Top = 16
        Width = 430
        Height = 17
        AllowGrayed = True
        Caption = 'Time, stage, volume, and concentration'
        TabOrder = 0
        OnClick = cbGagStandardClick
      end
      object cbGagFluxAndCond: TCheckBox
        Left = 3
        Top = 39
        Width = 443
        Height = 17
        AllowGrayed = True
        Caption = 'Time-step fluxes for lake and total lake conductance'
        Enabled = False
        TabOrder = 1
        OnClick = cbGagFluxAndCondClick
      end
      object cbGagDelta: TCheckBox
        Left = 3
        Top = 62
        Width = 443
        Height = 17
        AllowGrayed = True
        Caption = 'Changes in stage, volume, and concentration for lake'
        Enabled = False
        TabOrder = 2
        OnClick = cbGagDeltaClick
      end
      object cbGage4: TCheckBox
        Left = 3
        Top = 85
        Width = 443
        Height = 56
        AllowGrayed = True
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Time, lake stage, lake volume, solute concentration, rate of cha' +
          'nge of lake volume, volumetric rates for all inflows to and outf' +
          'lows from lakes, total lake conductance, and time-step budget er' +
          'ror. '
        TabOrder = 3
        WordWrap = True
        OnClick = cbGage4Click
      end
    end
  end
  inherited pnlTop: TPanel
    Width = 463
    ExplicitWidth = 463
    inherited pnlCaption: TPanel
      Width = 461
      ExplicitWidth = 461
    end
  end
  inherited pnlGrid: TPanel
    Width = 463
    Height = 135
    ExplicitWidth = 463
    ExplicitHeight = 135
    inherited pnlEditGrid: TPanel
      Width = 461
      ExplicitWidth = 461
    end
    inherited dgModflowBoundary: TRbwDataGrid4
      Width = 461
      Height = 83
      ColCount = 8
      Columns = <
        item
          AutoAdjustRowHeights = False
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = True
          WordWrapCells = False
          AutoAdjustColWidths = True
        end
        item
          AutoAdjustRowHeights = True
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4Real
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = True
          WordWrapCells = False
          AutoAdjustColWidths = True
        end
        item
          AutoAdjustRowHeights = True
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = True
          WordWrapCells = False
          AutoAdjustColWidths = True
        end
        item
          AutoAdjustRowHeights = False
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = False
          WordWrapCells = False
          AutoAdjustColWidths = False
        end
        item
          AutoAdjustRowHeights = False
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = False
          WordWrapCells = False
          AutoAdjustColWidths = False
        end
        item
          AutoAdjustRowHeights = False
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = False
          WordWrapCells = False
          AutoAdjustColWidths = False
        end
        item
          AutoAdjustRowHeights = False
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = False
          WordWrapCells = False
          AutoAdjustColWidths = False
        end
        item
          AutoAdjustRowHeights = False
          ButtonCaption = 'F()'
          ButtonFont.Charset = DEFAULT_CHARSET
          ButtonFont.Color = clWindowText
          ButtonFont.Height = -11
          ButtonFont.Name = 'Tahoma'
          ButtonFont.Style = []
          ButtonUsed = False
          ButtonWidth = 35
          CheckMax = False
          CheckMin = False
          ComboUsed = False
          Format = rcf4String
          LimitToList = False
          MaxLength = 0
          ParentButtonFont = False
          WordWrapCaptions = False
          WordWrapCells = False
          AutoAdjustColWidths = False
        end>
      ExplicitWidth = 461
      ExplicitHeight = 83
    end
  end
end
