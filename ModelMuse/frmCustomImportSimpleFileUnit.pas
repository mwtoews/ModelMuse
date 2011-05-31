{@abstract(The main purpose of @name is to define
  @link(TfrmCustomImportSimpleFile)
  which is used as a base class for importing
  DXF and Surfer grid files into ModelMuse. )}
unit frmCustomImportSimpleFileUnit;


interface

uses
  SysUtils, Types, Classes, Variants, Graphics, Controls, Forms,
  Dialogs, StdCtrls, frmCustomGoPhastUnit, Buttons, ExtCtrls,
  Grids, IntListUnit, ScreenObjectUnit, DXF_Structs, DXF_read, DXF_Utils,
  frmImportShapefileUnit, FastGEO, AbstractGridUnit, GoPhastTypes,
  ValueArrayStorageUnit;

type
  TImportMethod = (imLowest, imHighest, imAverage, imClosest);
  TImportProgress = procedure (Sender: TObject; FractionDone: double) of object;

  {@abstract(@name is a base class used to import DXF and Surfer
    grid files into ModelMuse.)
    See @link(TfrmGoPhast.miImportDXFFileClick).}
  TfrmCustomImportSimpleFile = class(TfrmCustomGoPhast)
    // Clicking @name closes @classname without doing anything.
    btnCancel: TBitBtn;
    // Clicking @name displays help about @classname.
    btnHelp: TBitBtn;
    btnOK: TBitBtn;
    // @name indicates that the value of the imported @link(TScreenObject)s
    // should set the value of enclosed cells or elements in the related
    // @link(TDataArray).
    cbEnclosedCells: TCheckBox;
    // @name indicates that the value of the imported @link(TScreenObject)s
    // should set the value of cells or elements in the related
    // @link(TDataArray) by interpolation.
    cbInterpolation: TCheckBox;
    // @name indicates that the value of the imported @link(TScreenObject)s
    // should set the value of intersected cells or elements in the related
    // @link(TDataArray).
    cbIntersectedCells: TCheckBox;
    // @name is used to select the name of the @link(TDataArray) to be
    // affected by the imported @link(TScreenObject)s.
    comboDataSets: TComboBox;
    // @name is the name of the @link(TCustom2DInterpolater) that will
    // be used with a new @link(TDataArray).
    comboInterpolators: TComboBox;
    // @name displays "Data Set".
    lblDataSet: TLabel;
    // @name displays "Interpolator".
    lblInterpolator: TLabel;
    // @name is used to select the DXF file.
    OpenDialogFile: TOpenDialog;
    // @name indicates whether a new data set will be evaluated at
    // elements or cells.
    rgEvaluatedAt: TRadioGroup;
    // @name makes sure that at least one of the following checkboxes is
    // checked: @link(cbEnclosedCells), @link(cbIntersectedCells), and
    // @link(cbInterpolation).  If not, their fonts are changed to emphasize
    // them and @link(btnOK) is disabled.
    procedure cbEnclosedCellsClick(Sender: TObject);
    // @name enables or disables @link(comboInterpolators) depending
    // on whether a new @link(TDataArray) is to be created.
    // @link(comboInterpolators) will be enabled if
    // a new @link(TDataArray) is to be created.
    procedure comboDataSetsChange(Sender: TObject);
    // @name enables @link(cbInterpolation) if an interpolator
    // is specified.
    procedure comboInterpolatorsChange(Sender: TObject);
    // @name calls @link(GetInterpolators).
    procedure FormCreate(Sender: TObject); override;
    // @name changes the captions of @link(cbEnclosedCells),
    // @link(cbIntersectedCells), and @link(cbInterpolation).
    procedure rgEvaluatedAtClick(Sender: TObject);
  protected
    Values: array of array of double;
    Counts: array of array of integer;
    CenterPoints: array of array of TPoint2D;
    Distances: array of array of double;
    MinX: Real;
    MaxX: Real;
    MinY: Real;
    MaxY: Real;
    procedure GetGridMinMax;
    procedure HandleAPoint(APoint3D: TPoint3D; ImportMethod: TImportMethod; EvalAt: TEvaluatedAt; Grid: TCustomGrid);
    // @name updates the contents of rgEvaluatedAt to the appropriate
    // values depending on what model (PHAST or MODFLOW) is selected.
    procedure UpdateEvalAt;
    // @name fills @link(comboDataSets) with the names of
    // @link(TDataArray)s that can be used by the imported
    // @link(TScreenObject)s.
    procedure GetDataSets;
    // @name fills @link(comboInterpolators) with a list of
    // @link(TCustom2DInterpolater)s.
    procedure GetInterpolators;
    // If @link(comboDataSets).ItemIndex = 0,
    // @name creates a new @link(TDataArray) with
    // an @link(TDataArray.Orientation) of dsoTop
    // and adds it to NewDataSets.
    // Suffix is a string that will be added to the end of the file name
    // when generating the data set name.
    // Classification is the @link(TDataArray.Classification)
    // of the @link(TDataArray).
    // If @name does create a new @link(TDataArray), @link(comboDataSets).Text
    // is set to the name of the @link(TDataArray).
    procedure MakeNewDataSet(NewDataSets: TList; Suffix, Classification: string);
    { Set the captions of @link(cbEnclosedCells), @link(cbIntersectedCells),
      and @link(cbInterpolation) based on @link(rgEvaluatedAt).ItemIndex
      depending on what model (PHAST or MODFLOW) is selected.}
    procedure SetCheckBoxCaptions; virtual;
    procedure InitializeArrays(ImportMethod: TImportMethod);
    procedure AssignPointsAndValues(Grid: TCustomGrid;
      AScreenObject: TScreenObject; Item: TValueArrayItem);
    procedure ComputeAverage(ImportMethod: TImportMethod;
      ImportProgress: TImportProgress = nil);
    { Protected declarations }
  public
    { Public declarations }
  end;

implementation

uses frmGoPhastUnit, DataSetUnit, 
  RbwParser, UndoItems, frmProgressUnit, frmDataSetsUnits, ModelMuseUtilities, 
  PhastModelUnit;

{$R *.dfm}

procedure TfrmCustomImportSimpleFile.FormCreate(Sender: TObject);
begin
  inherited;
  cbEnclosedCellsClick(nil);
  SetCheckBoxCaptions;
  GetInterpolators;
end;

procedure TfrmCustomImportSimpleFile.MakeNewDataSet(NewDataSets: TList;
  Suffix, Classification: string);
var
  NewDataSetName: string;
  DataSet: TDataArray;
  AType: TInterpolatorType;
  Interpolator: TCustom2DInterpolater;

begin
  Assert(SizeOf(TObject) = SizeOf(TInterpolatorType));
  if comboDataSets.ItemIndex = 0 then
  begin
    NewDataSetName := ExtractFileName(OpenDialogFile.FileName);
    NewDataSetName := ChangeFileExt(NewDataSetName, '');
    NewDataSetName := GenerateNewName(NewDataSetName + Suffix);

    DataSet := frmGoPhast.PhastModel.DataArrayManager.CreateNewDataArray(TDataArray,
      NewDataSetName, '0.', [], rdtDouble,
      TEvaluatedAt(rgEvaluatedAt.ItemIndex), dsoTop, Classification);

    DataSet.OnDataSetUsed := frmGoPhast.PhastModel.ModelResultsRequired;
    DataSet.Units := '';

    if comboInterpolators.ItemIndex > 0 then
    begin
      AType := TInterpolatorType(comboInterpolators.Items.
        Objects[comboInterpolators.ItemIndex]);
      Interpolator := AType.Create(nil);
      try
        DataSet.TwoDInterpolator := Interpolator
      finally
        Interpolator.Free;
      end;
    end;

    DataSet.UpdateDimensions(frmGoPhast.Grid.LayerCount,
      frmGoPhast.Grid.RowCount, frmGoPhast.Grid.ColumnCount);
    NewDataSets.add(DataSet);

    comboDataSets.Items[0] := NewDataSetName;
    comboDataSets.Text := NewDataSetName;
    comboDataSets.ItemIndex := 0;
  end;
end;

procedure TfrmCustomImportSimpleFile.GetInterpolators;
var
  List: TList;
  Index: integer;
  AType: TInterpolatorType;
begin
  Assert(SizeOf(TObject) = SizeOf(TInterpolatorType));
  List := TList.Create;
  try
    AddInterpolatorsToList(List);
    comboInterpolators.Items.Add('none');
    for Index := 0 to List.Count - 1 do
    begin
      AType := List[Index];
      comboInterpolators.Items.AddObject(AType.InterpolatorName,
        TObject(AType));
    end;
  finally
    List.Free;
  end;
end;

procedure TfrmCustomImportSimpleFile.HandleAPoint(APoint3D: TPoint3D;
  ImportMethod: TImportMethod; EvalAt: TEvaluatedAt; Grid: TCustomGrid);
var
  ADistance: TFloat;
  ARow: Integer;
  ACol: Integer;
  APoint2D: TPoint2D;
begin
  if (APoint3D.x >= MinX)
    and (APoint3D.x <= MaxX)
    and (APoint3D.y >= MinY)
    and (APoint3D.y <= MaxY) then
  begin
    ACol := -1;
    ARow := -1;
    case EvalAt of
      eaBlocks:
        begin
          ACol := Grid.GetContainingColumn(APoint3D.x);
          ARow := Grid.GetContainingRow(APoint3D.y);
        end;
      eaNodes:
        begin
          ACol := Grid.NearestColumnPosition(APoint3D.x);
          ARow := Grid.NearestRowPosition(APoint3D.y);
        end;
    else
      Assert(False);
    end;
    if Counts[ARow, ACol] = 0 then
    begin
      Counts[ARow, ACol] := 1;
      Values[ARow, ACol] := APoint3D.z;
      if ImportMethod = imClosest then
      begin
        APoint2D.x := APoint3D.x;
        APoint2D.y := APoint3D.y;
        Distances[ARow, ACol] := Distance(APoint2D, CenterPoints[ARow, ACol]);
      end;
    end;
    case ImportMethod of
      imLowest:
        begin
          if Values[ARow, ACol] > APoint3D.z then
          begin
            Values[ARow, ACol] := APoint3D.z;
          end;
        end;
      imHighest:
        begin
          if Values[ARow, ACol] < APoint3D.z then
          begin
            Values[ARow, ACol] := APoint3D.z;
          end;
        end;
      imAverage:
        begin
          Values[ARow, ACol] := Values[ARow, ACol] + APoint3D.z;
          Counts[ARow, ACol] := Counts[ARow, ACol] + 1;
        end;
      imClosest:
        begin
          APoint2D.x := APoint3D.x;
          APoint2D.y := APoint3D.y;
          ADistance := Distance(APoint2D, CenterPoints[ARow, ACol]);
          if Distances[ARow, ACol] > ADistance then
          begin
            Values[ARow, ACol] := APoint3D.z;
            Distances[ARow, ACol] := ADistance;
          end;
        end;
    end;
  end;
end;

procedure TfrmCustomImportSimpleFile.InitializeArrays(
  ImportMethod: TImportMethod);
var
  RowIndex: Integer;
  ColIndex: Integer;
  Grid: TCustomGrid;
  EvalAt: TEvaluatedAt;
begin
  Grid := frmGoPhast.PhastModel.Grid;
  EvalAt := TEvaluatedAt(rgEvaluatedAt.ItemIndex);
  case EvalAt of
    eaBlocks:
      begin
        SetLength(Values, Grid.RowCount, Grid.ColumnCount);
        SetLength(Counts, Grid.RowCount, Grid.ColumnCount);
        for RowIndex := 0 to Grid.RowCount - 1 do
        begin
          for ColIndex := 0 to Grid.ColumnCount - 1 do
          begin
            Counts[RowIndex, ColIndex] := 0;
          end;
        end;
        SetLength(CenterPoints, Grid.RowCount, Grid.ColumnCount);
        for RowIndex := 0 to Grid.RowCount - 1 do
        begin
          for ColIndex := 0 to Grid.ColumnCount - 1 do
          begin
            CenterPoints[RowIndex, ColIndex] := Grid.UnrotatedTwoDElementCenter(ColIndex, RowIndex);
          end;
        end;
        if ImportMethod = imClosest then
        begin
          SetLength(Distances, Grid.RowCount, Grid.ColumnCount);
        end;
      end;
    eaNodes:
      begin
        SetLength(Values, Grid.RowCount + 1, Grid.ColumnCount + 1);
        SetLength(Counts, Grid.RowCount + 1, Grid.ColumnCount + 1);
        for RowIndex := 0 to Grid.RowCount do
        begin
          for ColIndex := 0 to Grid.ColumnCount do
          begin
            Counts[RowIndex, ColIndex] := 0;
          end;
        end;
        SetLength(CenterPoints, Grid.RowCount + 1, Grid.ColumnCount + 1);
        for RowIndex := 0 to Grid.RowCount do
        begin
          for ColIndex := 0 to Grid.ColumnCount do
          begin
            CenterPoints[RowIndex, ColIndex] := Grid.UnrotatedTwoDElementCorner(ColIndex, RowIndex);
          end;
        end;
        if ImportMethod = imClosest then
        begin
          SetLength(Distances, Grid.RowCount + 1, Grid.ColumnCount + 1);
        end;
      end;
  else
    Assert(False);
  end;
end;

procedure TfrmCustomImportSimpleFile.GetDataSets;
var
  EvalAt: TEvaluatedAt;
  DataSet: TDataArray;
  Index: integer;
  DataArrayManager: TDataArrayManager;
begin
  EvalAt := TEvaluatedAt(rgEvaluatedAt.ItemIndex);
  with comboDataSets.Items do
  begin
    Clear;
    AddObject(rsNewDataSet, nil);
    DataArrayManager := frmGoPhast.PhastModel.DataArrayManager;
    for Index := 0 to DataArrayManager.DataSetCount - 1 do
    begin
      DataSet := DataArrayManager.DataSets[Index];
      if (DataSet.EvaluatedAt = EvalAt)
        and (DataSet.Orientation = dsoTop)
        and (DataSet.DataType = rdtDouble) then
      begin
        AddObject(DataSet.Name, DataSet);
      end;
    end;
  end;
  comboDataSets.ItemIndex := 0;
  comboDataSetsChange(nil);
end;

procedure TfrmCustomImportSimpleFile.SetCheckBoxCaptions;
var
  NodeElemString: string;
begin
  NodeElemString := EvalAtToString(TEvaluatedAt(rgEvaluatedAt.ItemIndex),
    frmGoPhast.ModelSelection, True, False);
  cbEnclosedCells.Caption := rsSetValueOfEnclosed + NodeElemString;
  cbIntersectedCells.Caption := rsSetValueOfIntersected + NodeElemString;
  cbInterpolation.Caption := rsSetValueOf + NodeElemString + rsByInterpolation;
end;

procedure TfrmCustomImportSimpleFile.UpdateEvalAt;
begin
  rgEvaluatedAt.Items[Ord(eaBlocks)] :=
    EvalAtToString(eaBlocks, frmGoPhast.PhastModel.ModelSelection, True, True);
  rgEvaluatedAt.Items[Ord(eaNodes)] :=
    EvalAtToString(eaNodes, frmGoPhast.PhastModel.ModelSelection, True, True);
  rgEvaluatedAt.Enabled :=
    frmGoPhast.PhastModel.ModelSelection = msPhast;
end;

procedure TfrmCustomImportSimpleFile.rgEvaluatedAtClick(Sender: TObject);
begin
  inherited;
  SetCheckBoxCaptions;
  GetDataSets;
end;

procedure TfrmCustomImportSimpleFile.comboDataSetsChange(Sender: TObject);
begin
  inherited;
  comboInterpolators.Enabled := comboDataSets.Text = rsNewDataSet;
end;

procedure TfrmCustomImportSimpleFile.comboInterpolatorsChange(Sender: TObject);
begin
  inherited;
  cbInterpolation.Enabled := comboInterpolators.ItemIndex <> 0;
  if not cbInterpolation.Enabled then
  begin
    cbInterpolation.Checked := False;
  end;
end;

procedure TfrmCustomImportSimpleFile.ComputeAverage(
  ImportMethod: TImportMethod; ImportProgress: TImportProgress = nil);
var
  ColIndex: Integer;
  RowIndex: Integer;
begin
  if ImportMethod = imAverage then
  begin
    for RowIndex := 0 to Length(Values) - 1 do
    begin
      if Assigned(ImportProgress) then
      begin
        ImportProgress(self, RowIndex / Length(Values));
      end;
      for ColIndex := 0 to Length(Values[0]) - 1 do
      begin
        if Counts[RowIndex, ColIndex] > 1 then
        begin
          Values[RowIndex, ColIndex] := Values[RowIndex, ColIndex]
            / Counts[RowIndex, ColIndex];
        end;
      end;
    end;
  end;
end;

procedure TfrmCustomImportSimpleFile.GetGridMinMax;
var
  Grid: TCustomGrid;
  procedure EnsureMinMax(var MinValue, MaxValue: Real);
  var
    Temp: Real;
  begin
    if MinValue > MaxValue then
    begin
      Temp := MinValue;
      MinValue := MaxValue;
      MaxValue := Temp;
    end;
  end;
begin
  Grid := frmGoPhast.PhastModel.Grid;
  MinX := Grid.ColumnPosition[0];
  MaxX := Grid.ColumnPosition[Grid.ColumnCount];
  EnsureMinMax(MinX, MaxX);
  MinY := Grid.RowPosition[0];
  MaxY := Grid.RowPosition[Grid.RowCount];
  EnsureMinMax(MinY, MaxY);

end;

procedure TfrmCustomImportSimpleFile.AssignPointsAndValues(Grid: TCustomGrid;
  AScreenObject: TScreenObject; Item: TValueArrayItem);
var
  ValueIndex: Integer;
  RowIndex: Integer;
  ColIndex: Integer;
  GridPoint2D: TPoint2D;
begin
  ValueIndex := 0;
  for RowIndex := 0 to Length(Values) - 1 do
  begin
    for ColIndex := 0 to Length(Values[0]) - 1 do
    begin
      if Counts[RowIndex, ColIndex] > 0 then
      begin
        GridPoint2D := CenterPoints[RowIndex, ColIndex];
        GridPoint2D :=
          Grid.RotateFromGridCoordinatesToRealWorldCoordinates(GridPoint2D);
        AScreenObject.AddPoint(GridPoint2D, True);
        Item.Values.RealValues[ValueIndex] := Values[RowIndex, ColIndex];
        Inc(ValueIndex);
      end;
    end;
  end;
  Item.Values.Count := ValueIndex;
end;

procedure TfrmCustomImportSimpleFile.cbEnclosedCellsClick(Sender: TObject);
begin
  inherited;
  EmphasizeCheckBoxes([cbEnclosedCells, cbIntersectedCells, cbInterpolation]);
  btnOK.Enabled := cbEnclosedCells.Checked or
    cbIntersectedCells.Checked or
    cbInterpolation.Checked;
end;

end.


