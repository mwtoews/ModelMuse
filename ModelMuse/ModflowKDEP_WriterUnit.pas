unit ModflowKDEP_WriterUnit;

interface

uses SysUtils, Classes, CustomModflowWriterUnit, ModflowPackageSelectionUnit;

type
  TModflowKDEP_Writer = class(TCustomPackageWriter)
  private
    FNameOfFile: string;
    IFKDEP: Integer;
    // @name writes a comment identifying KDEP package.
    procedure WriteDataSet0;
    procedure WriteDataSet1;
    procedure WriteDataSet2;
    procedure WriteDataSets3and4;
    function PackageID_Comment: string;
  protected
    function Package: TModflowPackageSelection; override;
    class function Extension: string; override;
  public
    procedure WriteFile(const AFileName: string);
  end;


implementation

uses PhastModelUnit, OrderedCollectionUnit, ModflowUnitNumbers,
  frmProgressUnit, DataSetUnit, HufDefinition, frmErrorsAndWarningsUnit,
  ModflowParameterUnit;

{ TModflowKDEP_Writer }

class function TModflowKDEP_Writer.Extension: string;
begin
  result := '.kdep';
end;

function TModflowKDEP_Writer.Package: TModflowPackageSelection;
begin
  result := PhastModel.ModflowPackages.HufPackage;
end;

function TModflowKDEP_Writer.PackageID_Comment: string;
begin
  result := 'KDEP file created on '
    + DateToStr(Now) + ' by ' + PhastModel.ProgramName + ' version '
    + ModelVersion + '.';
end;

procedure TModflowKDEP_Writer.WriteDataSet0;
begin
  WriteCommentLine(PackageID_Comment);
end;

procedure TModflowKDEP_Writer.WriteDataSet1;
var
  NPKDEP: Integer;
begin
  NPKDEP := PhastModel.HufParameters.CountParameters([ptHUF_KDEP]);
  IFKDEP := Ord(THufPackageSelection(Package).ReferenceChoice);
  WriteInteger(NPKDEP);
  WriteInteger(IFKDEP);
  WriteString(' # Data Set 1: NPKDEP, IFKDEP');
  NewLine;
end;

procedure TModflowKDEP_Writer.WriteDataSet2;
var
  RSArray: TDataArray;
begin
  if IFKDEP > 0 then
  begin
    RSArray := PhastModel.GetDataSetByName(StrHufReferenceSurface);
    WriteArray(RSArray, 0, ' # Data Set 2: RS');
    PhastModel.CacheDataArrays;
  end;
end;

procedure TModflowKDEP_Writer.WriteDataSets3and4;
const
  NoClusters = 'The following parameters in the HUF2 package are not used with '
    + 'any hydrogeologic units.';
var
  UsedParameters: TList;
  UsedHufUnits: TList;
  ParamIndex: Integer;
  Parameter: THufParameter;
  HufUnitIndex: Integer;
  HGU: THydrogeologicUnit;
  UsedParam: THufUsedParameter;
  PARNAM: string;
  PARTYP: string;
  PARVAL: Double;
  NCLU: Integer;
  ClusterIndex: Integer;
  HGUNAM: string;
  Mltarr: string;
  Zonarr: string;
  IZ: string;
begin
  UsedParameters := TList.Create;
  UsedHufUnits := TList.Create;
  try
    for ParamIndex := 0 to PhastModel.HufParameters.Count - 1 do
    begin
      Parameter := PhastModel.HufParameters[ParamIndex];
      if (Parameter.ParameterType <> ptHUF_KDEP) then
      begin
        Continue;
      end;
      UsedParameters.Clear;
      UsedHufUnits.Clear;
      for HufUnitIndex := 0 to PhastModel.HydrogeologicUnits.Count - 1 do
      begin
        HGU := PhastModel.HydrogeologicUnits[HufUnitIndex];
        UsedParam := HGU.UsesParameter(Parameter);
        if UsedParam <> nil then
        begin
          UsedParameters.Add(UsedParam);
          UsedHufUnits.Add(HGU);
        end;
      end;

      if UsedParameters.Count = 0 then
      begin
        frmErrorsAndWarnings.AddWarning(NoClusters, Parameter.ParameterName);
      end;

      PARNAM := ExpandString(Parameter.ParameterName, 10);
      case Parameter.ParameterType of
        ptHUF_KDEP: PARTYP := 'KDEP';
        else Assert(False);
      end;
      PARTYP := ExpandString(' ' + PARTYP, 10);
      PARVAL := Parameter.Value;
      NCLU := UsedParameters.Count;
      
      WriteString(PARNAM);
      WriteString(PARTYP);
      WriteFloat(PARVAL);
      WriteInteger(NCLU);
      WriteString(' # Data set 3: PARNAM PARTYP Parval NCLU');
      NewLine;
      PhastModel.WritePValAndTemplate(PARNAM,PARVAL);

      for ClusterIndex := 0 to UsedParameters.Count - 1 do
      begin
        UsedParam := UsedParameters[ClusterIndex];
        HGU := UsedHufUnits[ClusterIndex];
        HGUNAM := ExpandString(HGU.HufName, 10);

        if UsedParam.UseMultiplier then
        begin
          UsedParam.GenerateMultiplierArrayName;
          Mltarr := UsedParam.MultiplierArrayName;
          UsedMultiplierArrayNames.Add(Mltarr);
        end
        else
        begin
          Mltarr := ' NONE      ';
        end;
        Mltarr := ExpandString(Mltarr, 10);

        if UsedParam.UseZone then
        begin
          UsedParam.GenerateZoneArrayName;
          Zonarr := UsedParam.ZoneArrayName;
          UsedZoneArrayNames.Add(Zonarr);
          IZ := ' 1';
        end
        else
        begin
          Zonarr := ' ALL       ';
          IZ := '';
        end;
        Zonarr := ExpandString(Zonarr, 10);

        WriteString(HGUNAM + ' ');
        WriteString(Mltarr + ' ');
        WriteString(Zonarr + ' ');
        WriteString(IZ);
        WriteString(' # Data Set 4: HGUNAM Mltarr Zonarr IZ');
        NewLine;
      end;
    end;
  finally
    UsedParameters.Free;
    UsedHufUnits.Free;
  end;

end;

procedure TModflowKDEP_Writer.WriteFile(const AFileName: string);
begin
  if not Package.IsSelected then
  begin
    Exit
  end;
  if PhastModel.PackageGeneratedExternally(StrKDEP) then
  begin
    Exit;
  end;
  if PhastModel.HufParameters.CountParameters([ptHUF_KDEP]) = 0 then
  begin
    Exit;
  end;

  FNameOfFile := FileName(AFileName);
  WriteToNameFile(StrKDEP, PhastModel.UnitNumbers.UnitNumber(StrKDEP),
    FNameOfFile, foInput);
  OpenFile(FNameOfFile);
  try
    frmProgress.AddMessage('Writing KDEP Package input.');
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
    WriteDataSets3and4;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

  finally
    CloseFile;
  end;

end;

end.
