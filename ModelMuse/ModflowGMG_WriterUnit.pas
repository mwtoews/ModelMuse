unit ModflowGMG_WriterUnit;

interface

uses SysUtils, CustomModflowWriterUnit, ModflowPackageSelectionUnit;

Type
  TGmgWriter = class(TCustomSolverWriter)
  private
    NameOfFile: string;
    procedure WriteDataSet1;
    procedure WriteDataSet2;
    procedure WriteDataSet3;
    procedure WriteDataSet4;
  protected
    function Package: TModflowPackageSelection; override;
    class function Extension: string; override;
  public
    procedure WriteFile(const AFileName: string);
  end;

implementation

uses ModflowUnitNumbers, PhastModelUnit, frmProgressUnit;

{ TGmgWriter }

class function TGmgWriter.Extension: string;
begin
  result := '.gmg';
end;

function TGmgWriter.Package: TModflowPackageSelection;
begin
  result := PhastModel.ModflowPackages.GmgPackage;
end;

procedure TGmgWriter.WriteDataSet1;
var
  GMG : TGmgPackageSelection;
begin
  GMG := PhastModel.ModflowPackages.GmgPackage;
  WriteFloat(GMG.RCLOSE.Value);
  WriteInteger(GMG.IITER);
  WriteFloat(GMG.HCLOSE.Value);
  WriteInteger(GMG.MXITER);
  WriteString(' # RCLOSE IITER HCLOSE MXITER');
  NewLine;
end;

procedure TGmgWriter.WriteDataSet2;
var
  GMG : TGmgPackageSelection;
  IUNITMHC: integer;
  OutputFile: string;
begin
  GMG := PhastModel.ModflowPackages.GmgPackage;
  WriteFloat(GMG.DAMP.Value);
  WriteInteger(GMG.IADAMP);
  WriteInteger(GMG.IOUTGMG);
  if GMG.IUNITMHC then
  begin
    IUNITMHC := PhastModel.UnitNumbers.UnitNumber(StrIUNITMHC);
    OutputFile := ChangeFileExt(NameOfFile, '.gmgout');
    WriteToNameFile(StrDATA, IUNITMHC, OutputFile, foOutput);
  end
  else
  begin
    IUNITMHC := 0;
  end;
  WriteInteger(IUNITMHC);
  WriteString(' # DAMP IADAMP IOUTGMG IUNITMHC');
  NewLine;
end;

procedure TGmgWriter.WriteDataSet3;
var
  GMG : TGmgPackageSelection;
begin
  GMG := PhastModel.ModflowPackages.GmgPackage;
  WriteInteger(GMG.ISM);
  WriteInteger(GMG.ISM);
  if True then
  begin
    WriteFloat(GMG.DUP.Value);
    WriteFloat(GMG.DLOW.Value);
    WriteFloat(GMG.CHGLIMIT.Value);
  end;
  NewLine;
end;

procedure TGmgWriter.WriteDataSet4;
var
  GMG : TGmgPackageSelection;
begin
  GMG := PhastModel.ModflowPackages.GmgPackage;
  if GMG.ISC = 4 then
  begin
    WriteFloat(GMG.RELAX.Value);
  end;
end;

procedure TGmgWriter.WriteFile(const AFileName: string);
begin
  if not Package.IsSelected then
  begin
    Exit
  end;
  if SolverFileGeneratedExternally then
  begin
    Exit;
  end;
  NameOfFile := FileName(AFileName);
  WriteToNameFile('GMG', PhastModel.UnitNumbers.UnitNumber(StrGMG), NameOfFile, foInput);
  OpenFile(NameOfFile);
  try
    frmProgress.AddMessage('Writing GMG Package input.');
    WriteDataSet0;
    WriteDataSet1;
    WriteDataSet2;
    WriteDataSet3;
    WriteDataSet4;
  finally
    CloseFile;
  end;
end;

end.
