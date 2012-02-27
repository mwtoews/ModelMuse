inherited frameContourData: TframeContourData
  Height = 399
  ExplicitHeight = 399
  inherited pcChoices: TPageControl
    Height = 399
    ActivePage = tabSelection
    ExplicitHeight = 399
    inherited tabSelection: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 562
      ExplicitHeight = 371
      DesignSize = (
        562
        371)
      inherited lblColorScheme: TLabel
        Top = 253
        Anchors = [akLeft, akRight, akBottom]
        ExplicitTop = 253
      end
      inherited lblCycles: TLabel
        Top = 176
        ExplicitLeft = 456
        ExplicitTop = 276
      end
      inherited pbColorScheme: TPaintBox
        Left = 8
        Top = 269
        ExplicitLeft = 8
        ExplicitTop = 269
      end
      inherited lblColorAdjustment: TLabel
        Top = 308
        Anchors = [akLeft, akRight, akBottom]
        ExplicitTop = 308
      end
      inherited reComment: TJvRichEdit
        Width = 551
        Height = 56
        TabOrder = 4
        ExplicitWidth = 551
        ExplicitHeight = 56
      end
      inherited comboColorScheme: TComboBox
        Top = 222
        TabOrder = 8
        ExplicitTop = 222
      end
      inherited seCycles: TJvSpinEdit
        Top = 267
        Anchors = [akLeft, akRight, akBottom]
        TabOrder = 9
        ExplicitTop = 267
      end
      inherited jsColorExponent: TJvxSlider
        Top = 324
        TabOrder = 10
      end
      inherited seColorExponent: TJvSpinEdit
        Top = 335
        TabOrder = 11
        ExplicitTop = 335
      end
      inherited cbLogTransform: TCheckBox
        Top = 339
        TabOrder = 12
        OnClick = cbLogTransformClick
        ExplicitTop = 339
      end
      inherited udDataSets: TJvUpDown
        Left = 319
        Top = 23
        TabOrder = 2
        ExplicitLeft = 319
        ExplicitTop = 23
      end
      inherited rgUpdateLimitChoice: TRadioGroup
        Top = 143
        Anchors = [akLeft, akRight, akBottom]
        TabOrder = 5
        ExplicitTop = 143
      end
      inherited virttreecomboDataSets: TRbwStringTreeCombo
        Top = 20
        Width = 305
        Tree.OnGetNodeDataSize = virttreecomboDataSetsTreeGetNodeDataSize
        TabOrder = 1
        ExplicitTop = 20
        ExplicitWidth = 305
      end
      object btnEditContours: TButton
        Left = 443
        Top = 23
        Width = 119
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Edit contours...'
        Enabled = False
        TabOrder = 3
        OnClick = btnEditContoursClick
      end
      object cbSpecifyContours: TJvCheckBox
        Left = 342
        Top = 13
        Width = 96
        Height = 41
        Anchors = [akTop, akRight]
        Caption = 'Specify contours'
        TabOrder = 0
        WordWrap = True
        OnClick = cbSpecifyContoursClick
        LinkedControls = <>
        AutoSize = False
        HotTrackFont.Charset = DEFAULT_CHARSET
        HotTrackFont.Color = clWindowText
        HotTrackFont.Height = 17
        HotTrackFont.Name = 'Microsoft Sans Serif'
        HotTrackFont.Pitch = fpVariable
        HotTrackFont.Style = []
      end
      object cbLabelContours: TCheckBox
        Left = 319
        Top = 143
        Width = 177
        Height = 17
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Label contours'
        TabOrder = 6
        OnClick = cbLabelContoursClick
      end
      object btnContourFont: TButton
        Left = 319
        Top = 191
        Width = 145
        Height = 25
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Contour label font'
        Enabled = False
        TabOrder = 7
        OnClick = btnContourFontClick
      end
    end
    inherited tabFilters: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 562
      ExplicitHeight = 371
      DesignSize = (
        562
        371)
      inherited lblNumberOfValuesToIgnore: TLabel
        Top = 341
        ExplicitTop = 441
      end
      inherited rdgValuesToIgnore: TRbwDataGrid4
        Height = 220
        ExplicitHeight = 220
      end
      inherited seNumberOfValuesToIgnore: TJvSpinEdit
        Top = 338
        ExplicitTop = 338
      end
    end
    inherited tabLegend: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 562
      ExplicitHeight = 371
      inherited imLegend: TImage
        Height = 371
        ExplicitHeight = 471
      end
      inherited pnlLegend: TPanel
        Height = 371
        ExplicitHeight = 371
        DesignSize = (
          218
          371)
        inherited lblColorLegendRows: TLabel
          Top = 310
          ExplicitTop = 410
        end
        inherited seLegendRows: TJvSpinEdit
          Top = 331
          ExplicitTop = 331
        end
        inherited rdgLegend: TRbwDataGrid4
          Height = 245
          ExplicitHeight = 245
        end
      end
    end
  end
  object fdContourFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 480
    Top = 232
  end
end
