unit ModflowDRN_WriterUnit;

interface

uses SysUtils, Classes, Contnrs, CustomModflowWriterUnit, ModflowDrnUnit,
  PhastModelUnit, ScreenObjectUnit, ModflowBoundaryUnit, ModflowCellUnit,
  ModflowPackageSelectionUnit, OrderedCollectionUnit, FluxObservationUnit,
  GoPhastTypes;

type
  TModflowDRN_Writer = class(TFluxObsWriter)
  private
    NPDRN: integer;
    MXL: integer;
    procedure WriteDataSet1;
    procedure WriteDataSet2;
    procedure WriteDataSets3And4;
    procedure WriteDataSets5To7;
  protected
    function ObservationPackage: TModflowPackageSelection; override;
    function CellType: TValueCellType; override;
    class function Extension: string; override;
    class function ObservationExtension: string; override;
    class function ObservationOutputExtension: string; override;
    function GetBoundary(ScreenObject: TScreenObject): TModflowBoundary;
      override;
    function Package: TModflowPackageSelection; override;
    function ParameterType: TParameterType; override;
    procedure WriteCell(Cell: TValueCell;
      const DataSetIdentifier, VariableIdentifiers: string); override;
    procedure WriteParameterCells(CellList: TValueCellList; NLST: Integer;
      const VariableIdentifiers, DataSetIdentifier: string); override;
  public
    procedure WriteFile(const AFileName: string);
    procedure WriteFluxObservationFile(const AFileName: string;
      Purpose: TObservationPurpose);
  end;

implementation

uses ModflowTimeUnit, frmErrorsAndWarningsUnit,
  ModflowTransientListParameterUnit, ModflowUnitNumbers, frmProgressUnit,
  RbwParser, DataSetUnit;

{ TModflowDRN_Writer }

function TModflowDRN_Writer.CellType: TValueCellType;
begin
  result := TDrn_Cell;
end;

class function TModflowDRN_Writer.Extension: string;
begin
  result := '.drn';
end;

function TModflowDRN_Writer.GetBoundary(
  ScreenObject: TScreenObject): TModflowBoundary;
begin
  result := ScreenObject.ModflowDrnBoundary;
end;

class function TModflowDRN_Writer.ObservationExtension: string;
begin
  result := '.ob_drob';
end;

class function TModflowDRN_Writer.ObservationOutputExtension: string;
begin
  result := '.drob_out';
end;

function TModflowDRN_Writer.ObservationPackage: TModflowPackageSelection;
begin
  result := PhastModel.ModflowPackages.DrobPackage;
end;

function TModflowDRN_Writer.Package: TModflowPackageSelection;
begin
  result := PhastModel.ModflowPackages.DrnPackage;
end;

procedure TModflowDRN_Writer.WriteCell(Cell: TValueCell;
  const DataSetIdentifier, VariableIdentifiers: string);
var
  Drn_Cell: TDrn_Cell;
  LocalLayer: integer;
begin
  Drn_Cell := Cell as TDrn_Cell;
  LocalLayer := PhastModel.LayerStructure.
    DataSetLayerToModflowLayer(Drn_Cell.Layer);
  WriteInteger(LocalLayer);
  WriteInteger(Drn_Cell.Row+1);
  WriteInteger(Drn_Cell.Column+1);
  WriteFloat(Drn_Cell.Elevation);
  WriteFloat(Drn_Cell.Conductance);
  WriteIface(Drn_Cell.IFace);
  WriteString(' # ' + DataSetIdentifier + ' Layer Row Column Elevation '
    + VariableIdentifiers);

  NewLine;
end;

procedure TModflowDRN_Writer.WriteDataSet1;
begin
  CountParametersAndParameterCells(NPDRN, MXL);
  if NPDRN > 0 then
  begin
    WriteString('PARAMETER');
    WriteInteger(NPDRN);
    WriteInteger(MXL);
    WriteString(' # DataSet 1: PARAMETER NPDRN MXL');
    NewLine;
  end;
end;

procedure TModflowDRN_Writer.WriteDataSet2;
var
  MXACTD: integer;
  Option: String;
  IDRNCB: Integer;
begin
  CountCells(MXACTD);
  GetFlowUnitNumber(IDRNCB);
  GetOption(Option);

  WriteInteger(MXACTD);
  WriteInteger(IDRNCB);
  WriteString(Option);
  WriteString(' # DataSet 2: MXACTD IDRNCB');
  if Option <> '' then
  begin
    WriteString(' Option');
  end;
  NewLine
end;

function TModflowDRN_Writer.ParameterType: TParameterType;
begin
  result := ptDRN;
end;

procedure TModflowDRN_Writer.WriteDataSets3And4;
const
  ErrorRoot = 'One or more %s parameters have been eliminated '
    + 'because there are no cells associated with them.';
  DS3 = ' # Data Set 3: PARNAM PARTYP Parval NLST';
  DS3Instances = ' INSTANCES NUMINST';
  DS4A = ' # Data Set 4a: INSTNAM';
  DataSetIdentifier = 'Data Set 4b:';
  VariableIdentifiers = 'Condfact IFACE';
begin
  WriteParameterDefinitions(DS3, DS3Instances, DS4A, DataSetIdentifier,
    VariableIdentifiers, ErrorRoot);
end;

procedure TModflowDRN_Writer.WriteDataSets5To7;
const
  D7PName =      ' # Data Set 7: PARNAM';
  D7PNameIname = ' # Data Set 7: PARNAM Iname';
  DS5 = ' # Data Set 5: ITMP NP';
  DataSetIdentifier = 'Data Set 6:';
  VariableIdentifiers = 'Cond IFACE';
begin
  WriteStressPeriods(VariableIdentifiers, DataSetIdentifier, DS5,
    D7PNameIname, D7PName);
end;

procedure TModflowDRN_Writer.WriteFile(const AFileName: string);
var
  NameOfFile: string;
  ShouldWriteFile: Boolean;
  ShouldWriteObservationFile: Boolean;
begin
  if not Package.IsSelected then
  begin
    Exit
  end;
  ShouldWriteFile := not PhastModel.PackageGeneratedExternally(StrDRN);
  ShouldWriteObservationFile := ObservationPackage.IsSelected
    and not PhastModel.PackageGeneratedExternally(StrDROB);

  if not ShouldWriteFile and not ShouldWriteObservationFile then
  begin
    Exit;
  end;

  NameOfFile := FileName(AFileName);
  if ShouldWriteFile then
  begin
    WriteToNameFile('DRN', PhastModel.UnitNumbers.UnitNumber(StrDRN),
      NameOfFile, foInput);
  end;
  if ShouldWriteFile or ShouldWriteObservationFile then
  begin
    Evaluate;
  end;
  if not ShouldWriteFile then
  begin
    Exit;
  end;
  OpenFile(FileName(AFileName));
  try
    frmProgress.AddMessage('Writing DRN Package input.');
    frmProgress.AddMessage('  Writing Data Set 0.');
    WriteDataSet0;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 1.');
    WriteDataSet1;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 2.');
    WriteDataSet2;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Sets 3 and 4.');
    WriteDataSets3And4;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Sets 5 to 7.');
    WriteDataSets5To7;
  finally
    CloseFile;
  end;
end;

procedure TModflowDRN_Writer.WriteFluxObservationFile(const AFileName: string;
  Purpose: TObservationPurpose);
const
  DataSet1Comment = ' # Data Set 1: NQDR NQCDR NQTDR IUDROBSV';
  DataSet2Comment = ' # Data Set 2: TOMULTDR';
  DataSet3Comment = ' # Data Set 3: NQOBDR NQCLDR';
  PackageAbbreviation = StrDROB;
begin
  WriteFluxObsFile(AFileName, StrIUDROBSV, PackageAbbreviation,
    DataSet1Comment, DataSet2Comment, DataSet3Comment,
    PhastModel.DrainObservations, Purpose);
end;

procedure TModflowDRN_Writer.WriteParameterCells(CellList: TValueCellList;
  NLST: Integer; const VariableIdentifiers, DataSetIdentifier: string);
var
  Cell: TDrn_Cell;
  CellIndex: Integer;
begin
  // Data set 4b
  for CellIndex := 0 to CellList.Count - 1 do
  begin
    Cell := CellList[CellIndex] as TDrn_Cell;
    WriteCell(Cell, DataSetIdentifier, VariableIdentifiers);
  end;
  // Dummy inactive cells to fill out data set 4b.
  // Each instance of a parameter is required to have the same
  // number of cells.  This introduces dummy boundaries to fill
  // out the list.  because Condfact is set equal to zero, the
  // dummy boundaries have no effect.
  for CellIndex := CellList.Count to NLST - 1 do
  begin
    WriteInteger(1);
    WriteInteger(1);
    WriteInteger(1);
    WriteFloat(0);
    WriteFloat(0);
    WriteInteger(0);
    WriteString(
      ' # Data Set 4b: Layer Row Column Stage Condfact IFACE (Dummy boundary)');
    NewLine;
  end;
end;

end.
