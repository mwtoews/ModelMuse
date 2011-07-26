inherited frmGridColor: TfrmGridColor
  Left = 429
  Top = 292
  HelpType = htKeyword
  HelpKeyword = 'Color_Grid_Dialog_Box'
  HorzScrollBar.Range = 557
  VertScrollBar.Range = 225
  Caption = 'Color Grid'
  ExplicitTop = -68
  DesignSize = (
    606
    489)
  PixelsPerInch = 96
  TextHeight = 18
  object lblTime: TLabel [0]
    Left = 487
    Top = 4
    Width = 35
    Height = 18
    Anchors = [akTop, akRight]
    Caption = 'Time'
    ExplicitLeft = 492
  end
  object udTime: TJvUpDown [1]
    Left = 576
    Top = 24
    Width = 17
    Height = 21
    Anchors = [akTop, akRight]
    Associate = btnCancel
    Max = 0
    TabOrder = 3
    OnChangingEx = udTimeChangingEx
  end
  inherited pcChoices: TPageControl
    ActivePage = tabFilters
    TabOrder = 2
    inherited tabSelection: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 29
      ExplicitWidth = 598
      ExplicitHeight = 407
      inherited virttreecomboDataSets1: TRbwStringTreeCombo
        Tree.OnGetNodeDataSize = virttreecomboDataSetsDropDownTreeGetNodeDataSize
        Anchors = [akLeft, akTop, akRight]
      end
    end
    inherited tabFilters: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 29
      ExplicitWidth = 598
      ExplicitHeight = 407
      inherited lblLowerLimit: TLabel
        Anchors = [akLeft, akTop, akBottom]
      end
    end
    inherited tabLegend: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 29
      ExplicitWidth = 598
      ExplicitHeight = 407
      inherited imLegend: TImage
        AlignWithMargins = True
        Left = 221
        Top = 3
        Width = 374
        Height = 401
        ExplicitLeft = 221
        ExplicitTop = 3
        ExplicitWidth = 374
        ExplicitHeight = 329
      end
    end
  end
  inherited Panel1: TPanel
    inherited btnOK: TBitBtn
      OnClick = btnOKClick
    end
  end
  object comboTime3D: TJvComboBox [4]
    Left = 492
    Top = 24
    Width = 85
    Height = 26
    Anchors = [akTop, akRight]
    TabOrder = 0
    Text = '0'
    OnChange = comboTime3DChange
  end
end
