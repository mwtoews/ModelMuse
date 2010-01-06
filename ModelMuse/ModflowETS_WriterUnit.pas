unit ModflowETS_WriterUnit;

interface

uses SysUtils, Classes, Contnrs, RbwParser, CustomModflowWriterUnit,
  ScreenObjectUnit, ModflowBoundaryUnit, ModflowPackageSelectionUnit,
  OrderedCollectionUnit, ModflowCellUnit, PhastModelUnit,
  ModflowBoundaryDisplayUnit;

Type
  TModflowETS_Writer = class(TCustomTransientArrayWriter)
  private
    NPETS: integer;
    NETSEG: integer;
    NETSOP: integer;
    FDepthSurface: TList;
    procedure WriteDataSet1;
    procedure WriteDataSets2And3;
    procedure WriteDataSets4To11;
    procedure WriteCells(CellList: TList; const DataSetIdentifier,
      VariableIdentifiers: string);
    procedure WriteEvapotranspirationSurface(CellList: TList);
    procedure WriteExtinctionDepth(CellList: TList);
    procedure WriteDepthFraction(CellList: TList; SegmentIndex: integer);
    procedure WriteRateFraction(CellList: TList; SegmentIndex: integer);
  protected
    function CellType: TValueCellType; override;
    function Prefix: string; override;
    class function Extension: string; override;
    function GetBoundary(ScreenObject: TScreenObject): TModflowBoundary;
      override;
    function Package: TModflowPackageSelection; override;
    function ParameterType: TParameterType; override;
    procedure WriteStressPeriods(const VariableIdentifiers, DataSetIdentifier,
      DS5, D7PNameIname, D7PName: string); override;
    procedure Evaluate; override;
  public
    Constructor Create(Model: TPhastModel); override;
    // @name destroys the current instance of @classname.
    Destructor Destroy; override;
    procedure WriteFile(const AFileName: string);
    // @name is used to update the display of transient data used to color the
    // grid.
    // @param(TimeLists TimeLists is a list of
    //   @link(TModflowBoundaryDisplayTimeList)s that are to be updated.
    //   The order of the @link(TModflowBoundaryDisplayTimeList)s in TimeLists
    //   is important. The position in the list must be same as the index
    //   value used to access @link(TValueCell.RealValue TValueCell.RealValue)
    //   and @link(TValueCell.RealAnnotation TValueCell.RealAnnotation).  The
    //   contents of TimeLists should be in the following order.
    //   @unorderedList(
    //       @item(Evapotranspiration Rate)
    //       @item(Evapotranspiration Surface)
    //       @item(Evapotranspiration Depth)
    //       @item(Depth Fraction 1)
    //       @item(Et Fraction 1)
    //       @item(Depth Fraction 2)
    //       @item(Et Fraction 2)
    //       @item(...)
    //       @item(Depth Fraction N)
    //       @item(Et Fraction N)
    //     )
    //   )
    // @param(ParameterIndicies The values included in ParameterIndicies
    //   indicate which @link(TModflowBoundaryDisplayTimeList)s in TimeLists
    //   are affected by MODFLOW parameters.)
    procedure UpdateDisplay(TimeLists: TModflowBoundListOfTimeLists);
  end;

implementation

uses ModflowUnitNumbers, ModflowTransientListParameterUnit,
  frmErrorsAndWarningsUnit, DataSetUnit, ModflowEtsUnit, GoPhastTypes, 
  frmProgressUnit;

{ TModflowETS_Writer }

const
  ErrorRoot = 'One or more %s parameters have been eliminated '
    + 'because there are no cells associated with them.';

function TModflowETS_Writer.CellType: TValueCellType;
begin
  result := TEtsSurfDepth_Cell;
end;

constructor TModflowETS_Writer.Create(Model: TPhastModel);
begin
  inherited;
  FDepthSurface := TObjectList.Create;
end;

destructor TModflowETS_Writer.Destroy;
begin
  FDepthSurface.Free;
  inherited;
end;

procedure TModflowETS_Writer.Evaluate;
var
  ScreenObjectIndex: Integer;
  ScreenObject: TScreenObject;
  Boundary: TEtsBoundary;
begin
  inherited Evaluate;
  for ScreenObjectIndex := 0 to PhastModel.ScreenObjectCount - 1 do
  begin
    ScreenObject := PhastModel.ScreenObjects[ScreenObjectIndex];
    if ScreenObject.Deleted then
    begin
      Continue;
    end;
    Boundary := ScreenObject.ModflowEtsBoundary;
    if Boundary <> nil then
    begin
//      if PhastModel.ModflowPackages.EtsPackage.TimeVaryingLayers then
      begin
        Boundary.GetEvapotranspirationLayerCells(FLayers);
      end;
      Boundary.GetEvapotranspirationSurfaceDepthCells(FDepthSurface);
    end;
  end;
end;

class function TModflowETS_Writer.Extension: string;
begin
  result := '.ets';
end;

function TModflowETS_Writer.GetBoundary(
  ScreenObject: TScreenObject): TModflowBoundary;
begin
  result := ScreenObject.ModflowEtsBoundary;
end;

function TModflowETS_Writer.Package: TModflowPackageSelection;
begin
  result := PhastModel.ModflowPackages.EtsPackage;
end;

function TModflowETS_Writer.ParameterType: TParameterType;
begin
  result := ptETS;
end;

function TModflowETS_Writer.Prefix: string;
begin
  result := 'ETS'
end;

procedure TModflowETS_Writer.UpdateDisplay(
  TimeLists: TModflowBoundListOfTimeLists);
var
  List: TValueCellList;
  ParameterValues: TList;
  ParametersUsed: TStringList;
  TimeIndex: Integer;
  DepthSurfaceCellList: TValueCellList;
  SegmentIndex: integer;
  NPETS, NETSEG: integer;
  EvapRateTimes: TModflowBoundaryDisplayTimeList;
  EvapRateArray: TModflowBoundaryDisplayDataArray;
  EvapotranspirationSurfaceTimes : TModflowBoundaryDisplayTimeList;
  EvapSurfArray: TModflowBoundaryDisplayDataArray;
  EvapotranspirationDepthTimes : TModflowBoundaryDisplayTimeList;
  EvapDepthArray: TModflowBoundaryDisplayDataArray;
  DepthFractionList: TList;
  EtFractionList: TList;
  ATimeList: TModflowBoundaryDisplayTimeList;
  AnArray: TModflowBoundaryDisplayDataArray;
  Index: integer;
  ParamDefArrays: TList;
  DefArrayList: TList;
  EvapotranspirationLayerTimes : TModflowBoundaryDisplayTimeList;
  EvapLayerArray: TModflowBoundaryDisplayDataArray;
const
  D7PNameIname = '';
  D7PName = '';
begin
  if not Package.IsSelected then
  begin
    UpdateNotUsedDisplay(TimeLists);
    Exit;
  end;
  ParameterValues := TList.Create;
  try
    Evaluate;
    ParamDefArrays := TObjectList.Create;
    DepthFractionList := TList.Create;
    EtFractionList := TList.Create;
    try
      EvaluateParameterDefinitions(ParamDefArrays, ErrorRoot);
      NPETS := ParameterCount;
      NETSOP := Ord(PhastModel.ModflowPackages.EtsPackage.LayerOption) + 1;
      NETSEG := PhastModel.ModflowPackages.EtsPackage.SegmentCount;
      EvapRateTimes := TimeLists[0];
      EvapotranspirationSurfaceTimes := TimeLists[1];
      EvapotranspirationDepthTimes := TimeLists[2];
      EvapotranspirationLayerTimes := TimeLists[3];
      for TimeIndex := 4 to TimeLists.Count - 1 do
      begin
        if Odd(TimeIndex) then
        begin
          EtFractionList.Add(TimeLists[TimeIndex]);
        end
        else
        begin
          DepthFractionList.Add(TimeLists[TimeIndex]);
        end;
      end;

      if Values.Count = 0 then
      begin
        SetTimeListsUpToDate(TimeLists);
        Exit;
      end;
      for TimeIndex := 0 to Values.Count - 1 do
      begin
        EvapRateArray := EvapRateTimes[TimeIndex]
          as TModflowBoundaryDisplayDataArray;
        EvapSurfArray := EvapotranspirationSurfaceTimes[TimeIndex]
          as TModflowBoundaryDisplayDataArray;
        EvapDepthArray := EvapotranspirationDepthTimes[TimeIndex]
          as TModflowBoundaryDisplayDataArray;
        if EvapotranspirationLayerTimes = nil then
        begin
          EvapLayerArray := nil;
        end
        else
        begin
          EvapLayerArray := EvapotranspirationLayerTimes[TimeIndex]
            as TModflowBoundaryDisplayDataArray;
        end;

        ParametersUsed := TStringList.Create;
        try
          RetrieveParametersForStressPeriod(D7PNameIname, D7PName, TimeIndex,
            ParametersUsed, ParameterValues);
          List := Values[TimeIndex];
          List.CheckRestore;

          // data set 5
          DepthSurfaceCellList := FDepthSurface[TimeIndex];
          DepthSurfaceCellList.CheckRestore;
          AssignTransient2DArray(EvapSurfArray, 0, DepthSurfaceCellList, 0,
            rdtDouble, umAssign);

          if NPETS = 0 then
          begin
            // data set 6
            AssignTransient2DArray(EvapRateArray, 0, List, 0, rdtDouble,
              umAssign);
          end
          else
          begin
            DefArrayList := ParamDefArrays[TimeIndex];
            UpdateTransient2DArray(EvapRateArray, DefArrayList);
          end;

          // data set 8

          AssignTransient2DArray(EvapDepthArray, 1, DepthSurfaceCellList, 0,
            rdtDouble, umAssign);

          if EvapLayerArray <> nil then
          begin
            if (PhastModel.ModflowPackages.EtsPackage.
              LayerOption = loSpecified)
              and not PhastModel.ModflowPackages.EtsPackage.
              TimeVaryingLayers then
            begin
              RetrieveParametersForStressPeriod(D7PNameIname, D7PName, 0,
                ParametersUsed, ParameterValues);
              List := Values[0];
            end;
            // data set 9
            UpdateLayerDisplay(List, ParameterValues, TimeIndex,
              EvapLayerArray);
          end;

          for SegmentIndex := 1 to NETSEG - 1 do
          begin
            // data set 10
            ATimeList := DepthFractionList[SegmentIndex-1];
            AnArray := ATimeList[TimeIndex] as TModflowBoundaryDisplayDataArray;
            AssignTransient2DArray(AnArray, SegmentIndex*2,
              DepthSurfaceCellList, 0, rdtDouble, umAssign);

            // data set 11
            ATimeList := EtFractionList[SegmentIndex-1];
            AnArray := ATimeList[TimeIndex] as TModflowBoundaryDisplayDataArray;
            AssignTransient2DArray(AnArray, SegmentIndex*2+1,
              DepthSurfaceCellList, 0, rdtDouble, umAssign);
          end;
          List.Cache;
        finally
          ParametersUsed.Free;
        end;
      end;
      for Index := 0 to TimeLists.Count - 1 do
      begin
        ATimeList := TimeLists[Index];
        if ATimeList <> nil then
        begin
          ATimeList.SetUpToDate(True);
        end;
      end;
    finally
      DepthFractionList.Free;
      EtFractionList.Free;
      ParamDefArrays.Free;
    end;
  finally
    ParameterValues.Free;
  end;
end;

procedure TModflowETS_Writer.WriteDataSets2And3;
const
  DS3 = ' # Data Set 2: PARNAM PARTYP Parval NCLU';
  DS3Instances = ' INSTANCES NUMINST';
  DS4A = ' # Data Set 3a: INSTNAM';
  DataSetIdentifier = 'Data Set 3b:';
  VariableIdentifiers = 'Condfact';
begin
  WriteParameterDefinitions(DS3, DS3Instances, DS4A, DataSetIdentifier,
    VariableIdentifiers, ErrorRoot);
end;

procedure TModflowETS_Writer.WriteDataSet1;
var
  IEVTCB: integer;
begin
  NETSOP := Ord(PhastModel.ModflowPackages.EtsPackage.LayerOption) + 1;
  GetFlowUnitNumber(IEVTCB);
  NPETS := ParameterCount;
  NETSEG := PhastModel.ModflowPackages.EtsPackage.SegmentCount;

  WriteInteger(NETSOP);
  WriteInteger(IEVTCB);
  WriteInteger(NPETS);
  WriteInteger(NETSEG);
  WriteString(' # DataSet 1: NETSOP IEVTCB, NPETS, NETSEG');
  NewLine
end;

procedure TModflowETS_Writer.WriteDataSets4To11;
const
  D7PName =      ' # Data Set 7: PARNAM';
  D7PNameIname = ' # Data Set 7: PARNAM Iname';
  DS5 = ' # Data Set 4: INETSS INETSR INETSX [INIETS [INSGDF]]';
  DataSetIdentifier = 'Data Set 6:';
  VariableIdentifiers = 'ETSR';
begin
  WriteStressPeriods(VariableIdentifiers, DataSetIdentifier, DS5,
    D7PNameIname, D7PName);
end;

procedure TModflowETS_Writer.WriteFile(const AFileName: string);
var
  NameOfFile: string;
begin
  if not Package.IsSelected then
  begin
    Exit
  end;
  if PhastModel.PackageGeneratedExternally(StrETS) then
  begin
    Exit;
  end;
//  frmProgress.AddMessage('Evaluating ETS Package data.');
  NameOfFile := FileName(AFileName);
  WriteToNameFile(StrETS, PhastModel.UnitNumbers.UnitNumber(StrETS), NameOfFile, foInput);
  Evaluate;
  OpenFile(FileName(AFileName));
  try
    frmProgress.AddMessage('Writing ETS Package input.');
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

    frmProgress.AddMessage('  Writing Data Sets 2 and 3.');
    WriteDataSets2And3;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Sets 4 to 11.');
    WriteDataSets4To11;
  finally
    CloseFile;
  end;
end;

procedure TModflowETS_Writer.WriteCells(CellList: TList;
  const DataSetIdentifier, VariableIdentifiers: string);
var
  DefaultValue: double;
  DataType: TRbwDataType;
  DataTypeIndex: integer;
  Comment: string;
begin
  DefaultValue := 0;
  DataType := rdtDouble;
  DataTypeIndex := 0;
  Comment := DataSetIdentifier + ' ' + VariableIdentifiers;
  WriteTransient2DArray(Comment, DataTypeIndex, DataType, DefaultValue, CellList);
end;

procedure TModflowETS_Writer.WriteEvapotranspirationSurface(CellList: TList);
var
  DefaultValue: double;
  DataType: TRbwDataType;
  DataTypeIndex: integer;
  Comment: string;
begin
  DefaultValue := 0;
  DataType := rdtDouble;
  DataTypeIndex := 0;
  Comment := 'Data Set 5: ETSS';
  WriteTransient2DArray(Comment, DataTypeIndex, DataType, DefaultValue, CellList);
end;

procedure TModflowETS_Writer.WriteExtinctionDepth(CellList: TList);
var
  DefaultValue: double;
  DataType: TRbwDataType;
  DataTypeIndex: integer;
  Comment: string;
begin
  DefaultValue := 0;
  DataType := rdtDouble;
  DataTypeIndex := 1;
  Comment := 'Data Set 8: ETSX';
  WriteTransient2DArray(Comment, DataTypeIndex, DataType, DefaultValue, CellList);
end;

procedure TModflowETS_Writer.WriteDepthFraction(CellList: TList; SegmentIndex: integer);
var
  DefaultValue: double;
  DataType: TRbwDataType;
  DataTypeIndex: integer;
  Comment: string;
begin
  DefaultValue := 0;
  DataType := rdtDouble;
  DataTypeIndex := SegmentIndex*2;
  Comment := 'Data Set 10: PXDP';
  WriteTransient2DArray(Comment, DataTypeIndex, DataType, DefaultValue, CellList);
end;

procedure TModflowETS_Writer.WriteRateFraction(CellList: TList; SegmentIndex: integer);
var
  DefaultValue: double;
  DataType: TRbwDataType;
  DataTypeIndex: integer;
  Comment: string;
begin
  DefaultValue := 0;
  DataType := rdtDouble;
  DataTypeIndex := SegmentIndex*2+1;
  Comment := 'Data Set 11: PETM';
  WriteTransient2DArray(Comment, DataTypeIndex, DataType, DefaultValue, CellList);
end;

procedure TModflowETS_Writer.WriteStressPeriods(const VariableIdentifiers,
  DataSetIdentifier, DS5, D7PNameIname, D7PName: string);
var
  NP: Integer;
  List: TValueCellList;
  ParameterValues: TList;
  ParamIndex: Integer;
  ParametersUsed: TStringList;
  TimeIndex: Integer;
  INETSR, INIETS, INSGDF: Integer;
  INETSS: Integer;
  INETSX: Integer;
  DepthSurfaceCellList: TList;
  Comment: string;
  SegmentIndex: integer;
begin
  ParameterValues := TList.Create;
  try
    Comment := 'Data Set 9: IETS';
    if Values.Count = 0 then
    begin
      frmErrorsAndWarnings.AddError('No evapotranspiration segments defined',
        'The Evapotranspiration Segments package is active but '
        + 'no evapotranspiration segments have been defined for any stress period.');
    end;
    for TimeIndex := 0 to Values.Count - 1 do
    begin
      if not frmProgress.ShouldContinue then
      begin
        Exit;
      end;
      frmProgress.AddMessage('    Writing Stress Period ' + IntToStr(TimeIndex+1));
      ParametersUsed := TStringList.Create;
      try
        RetrieveParametersForStressPeriod(D7PNameIname, D7PName, TimeIndex,
          ParametersUsed, ParameterValues);
        NP := ParametersUsed.Count;
        List := Values[TimeIndex];

        // data set 4;
        INETSS := 1;
        if NPETS > 0 then
        begin
          INETSR := NP;
        end
        else
        begin
          INETSR := 1;
        end;
        INETSX := 1;
        if NETSOP = 2 then
        begin
          INIETS  := 1;
        end
        else
        begin
          INIETS  := -1;
        end;
        INSGDF := 1;

        WriteInteger(INETSS);
        WriteInteger(INETSR);
        WriteInteger(INETSX);
        WriteInteger(INIETS);
        WriteInteger(INSGDF);
        WriteString(DS5 + ' Stress period ' + IntToStr(TimeIndex+1));
        NewLine;

        // data set 5
        DepthSurfaceCellList := FDepthSurface[TimeIndex];
        WriteEvapotranspirationSurface(DepthSurfaceCellList);
        if not frmProgress.ShouldContinue then
        begin
          List.Cache;
          Exit;
        end;

        if NPETS = 0 then
        begin
          // data set 6
          WriteCells(List, DataSetIdentifier, VariableIdentifiers);
        end
        else
        begin
          // data set 7
          for ParamIndex := 0 to ParametersUsed.Count - 1 do
          begin
            WriteString(ParametersUsed[ParamIndex]);
            NewLine;
          end;
        end;
        if not frmProgress.ShouldContinue then
        begin
          List.Cache;
          Exit;
        end;

        // data set 8
        WriteExtinctionDepth(DepthSurfaceCellList);
        if not frmProgress.ShouldContinue then
        begin
          List.Cache;
          Exit;
        end;

        // data set 9
        WriteLayerSelection(List, ParameterValues, TimeIndex, Comment);
        if not frmProgress.ShouldContinue then
        begin
          List.Cache;
          Exit;
        end;

        for SegmentIndex := 1 to NETSEG - 1 do
        begin
          // data set 10
          WriteDepthFraction(DepthSurfaceCellList, SegmentIndex);
          if not frmProgress.ShouldContinue then
          begin
            List.Cache;
            Exit;
          end;

          // data set 11
          WriteRateFraction(DepthSurfaceCellList, SegmentIndex);
          if not frmProgress.ShouldContinue then
          begin
            List.Cache;
            Exit;
          end;
        end;
        List.Cache;
      finally
        ParametersUsed.Free;
      end;
    end;
  finally
    ParameterValues.Free;
  end;
end;

end.
