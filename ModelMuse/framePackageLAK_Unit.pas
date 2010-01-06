unit framePackageLAK_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, framePackageUnit, StdCtrls, ArgusDataEntry, JvExStdCtrls, JvCheckBox,
  ModflowPackageSelectionUnit, RbwController;

type
  TframePackageLAK = class(TframePackage)
    rdeTheta: TRbwDataEntry;
    lblTheta: TLabel;
    rdeIterations: TRbwDataEntry;
    lblIterations: TLabel;
    rdeConvergenceCriterion: TRbwDataEntry;
    lblConvergenceCriterion: TLabel;
    cbPrintLake: TCheckBox;
    rdeSurfDepth: TRbwDataEntry;
    lblSurfDepth: TLabel;
  private
    { Private declarations }
  public
    procedure GetData(Package: TModflowPackageSelection); override;
    procedure SetData(Package: TModflowPackageSelection); override;
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TframePackageLAK }

procedure TframePackageLAK.GetData(Package: TModflowPackageSelection);
var
  Lake: TLakePackageSelection;
begin
  inherited;
  Lake := Package as TLakePackageSelection;
  rdeTheta.Text := FloatToStr(Lake.Theta);
  rdeIterations.Text := IntToStr(Lake.NumberOfIterations);
  rdeConvergenceCriterion.Text := FloatToStr(Lake.ConvergenceCriterion);
  rdeSurfDepth.Text := FloatToStr(Lake.SurfDepth.Value);
  cbPrintLake.Checked := Lake.PrintLakes;
end;

procedure TframePackageLAK.SetData(Package: TModflowPackageSelection);
var
  Lake: TLakePackageSelection;
begin
  inherited;
  Lake := Package as TLakePackageSelection;
  Lake.Theta := StrToFloat(rdeTheta.Text);
  Lake.NumberOfIterations := StrToInt(rdeIterations.Text);
  Lake.ConvergenceCriterion := StrToFloat(rdeConvergenceCriterion.Text);
  Lake.SurfDepth.Value := StrToFloat(rdeSurfDepth.Text);
  Lake.PrintLakes := cbPrintLake.Checked;
end;

end.
