unit RequiredDataSetsUndoUnit;

interface

uses Classes, GoPhastTypes, UndoItems, PhastModelUnit, frmShowHideObjectsUnit,
  ModflowParameterUnit, HufDefinition, ModflowTransientListParameterUnit,
  UndoItemsScreenObjects, ModflowPackageSelectionUnit;

type
  TCustomCreateRequiredDataSetsUndo = class(TCustomUndo)
  private
    FNewSteadyModflowParameterDataSets: TList;
    FNewPackageDataSets: TList;
  // If a @link(TDataArray) whose name is DataSetName does not exist and
  // ArrayNeeded returns @true, then @name will create a new
  // @link(TDataArray). Orientation, DataType, DataSetName, ArrayNeeded,
  // NewFormula, and Classification will be used to assign properties to
  // the new @link(TDataArray).
  //
  // @name is called by @link(UpdatePackageLayers).
    procedure UpdateDataArray(Model: TCustomModel; Index: integer);
    // @name checks if all the data sets for the selected packages
    // exist and creates them if they do not.
    procedure UpdatePackageLayers;
    procedure UpdateOnPostInitialize;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure DoCommand; override;
    procedure Undo; override;
    // causes all the @link(TDataArray)s that are required to be created
    // if they do not already exist.
    procedure UpdatedRequiredDataSets;
  end;

  TCustomUndoChangeParameters = class(TCustomCreateRequiredDataSetsUndo)
  private
    FNewSteadyParameters: TModflowSteadyParameters;
    FOldSteadyParameters: TModflowSteadyParameters;
    FNewTransientParameters: TModflowTransientListParameters;
    FOldTransientParameters: TModflowTransientListParameters;
    FOldHufModflowParameters: THufModflowParameters;
    FNewHufModflowParameters: THufModflowParameters;
    FNewSfrParamInstances: TSfrParamInstances;
    FOldSfrParamInstances: TSfrParamInstances;
    FOldModflowBoundaries: TList;
  protected
    function Description: string; override;
  public
    Constructor Create(var NewSteadyParameters: TModflowSteadyParameters;
      var NewTransientParameters: TModflowTransientListParameters;
      var NewHufModflowParameters: THufModflowParameters;
      var NewSfrParamInstances: TSfrParamInstances);
    Destructor Destroy; override;
    procedure DoCommand; override;
    procedure Undo; override;
  end;

  TUndoModelSelectionChange = class(TCustomCreateRequiredDataSetsUndo)
  private
    FOldModelSelection: TModelSelection;
    FNewModelSelection: TModelSelection;
    FUpwSelected: boolean;
    FLpfSelected: boolean;
    FNwtSelected: boolean;
    FPcgSelected: boolean;
  protected
    function Description: string; override;
  public
    Constructor Create(NewModelSelection: TModelSelection);
    procedure DoCommand; override;
    procedure Undo; override;
  end;

implementation

uses DataSetUnit, RbwParser, frmGoPhastUnit, frmGridColorUnit, 
  frmContourDataUnit, frmGridValueUnit, contnrs, ScreenObjectUnit, 
  ModflowPackagesUnit;

constructor TCustomCreateRequiredDataSetsUndo.Create;
begin
  FNewSteadyModflowParameterDataSets := TList.Create;
  FNewPackageDataSets := TList.Create;
end;

destructor TCustomCreateRequiredDataSetsUndo.Destroy;
begin
  FNewPackageDataSets.Free;
  FNewSteadyModflowParameterDataSets.Free;

  inherited;
end;

procedure TCustomCreateRequiredDataSetsUndo.DoCommand;
begin
  frmGoPhast.PhastModel.ModflowSteadyParameters.NewDataSets := FNewSteadyModflowParameterDataSets;
end;

procedure TCustomCreateRequiredDataSetsUndo.Undo;
begin
  frmGoPhast.PhastModel.ModflowSteadyParameters.NewDataSets := FNewSteadyModflowParameterDataSets;
end;

procedure TCustomCreateRequiredDataSetsUndo.UpdateDataArray(Model: TCustomModel; Index: integer);
var
  DataArray: TDataArray;
//  DataArrayIndex: Integer;
  DataSetName: string;
  Orientation: TDataSetOrientation;
  DataType: TRbwDataType;
  ArrayNeeded, CreateDataSet: TObjectUsedEvent;
  NewFormula, Classification: string;
  Lock: TDataLock;
  DataArrayManager: TDataArrayManager;
  PhastModel: TPhastModel;
  ChildIndex: Integer;
  ChildModel: TChildModel;
begin
  { TODO : Find a way to extract common code from
TPhastModel.CreateModflowDataSets and
TCustomCreateRequiredDataSetsUndo.UpdateDataArray}
  DataArrayManager := Model.DataArrayManager;

  DataSetName := DataArrayManager.FDataArrayCreationRecords[Index].Name;
  Orientation := DataArrayManager.FDataArrayCreationRecords[Index].Orientation;
  DataType := DataArrayManager.FDataArrayCreationRecords[Index].DataType;
  ArrayNeeded := DataArrayManager.FDataArrayCreationRecords[Index].DataSetNeeded;
  CreateDataSet := DataArrayManager.FDataArrayCreationRecords[Index].DataSetShouldBeCreated;
  NewFormula := DataArrayManager.FDataArrayCreationRecords[Index].Formula;
  Classification := DataArrayManager.FDataArrayCreationRecords[Index].Classification;
  Lock := DataArrayManager.FDataArrayCreationRecords[Index].Lock;

  DataArray := DataArrayManager.GetDataSetByName(DataSetName);
//  DataArray := nil;
  Assert(Assigned(ArrayNeeded));
  if DataArray <> nil then
  begin
//    DataArray := Model.DataSets[DataArrayIndex];
    DataArray.Name := DataSetName;
    DataArray.Lock := Lock;
  end
  else if ArrayNeeded(self)
    or (Assigned(CreateDataSet) and CreateDataSet(self)) then
  begin
    DataArray := DataArrayManager.CreateNewDataArray(TDataArray, DataSetName, NewFormula,
      Lock, DataType, DataArrayManager.FDataArrayCreationRecords[Index].EvaluatedAt,
      Orientation, Classification);
    DataArray.OnDataSetUsed := ArrayNeeded;
    DataArray.Lock := Lock;
    DataArray.CheckMax := DataArrayManager.FDataArrayCreationRecords[Index].CheckMax;
    DataArray.CheckMin := DataArrayManager.FDataArrayCreationRecords[Index].CheckMin;
    DataArray.Max := DataArrayManager.FDataArrayCreationRecords[Index].Max;
    DataArray.Min := DataArrayManager.FDataArrayCreationRecords[Index].Min;

    FNewPackageDataSets.Add(DataArray);
  end;
  if DataArray <> nil then
  begin
    DataArray.AssociatedDataSets :=
      DataArrayManager.FDataArrayCreationRecords[Index].AssociatedDataSets;
  end;
  if (DataArray <> nil) and (Model.Grid <> nil) then
  begin
    DataArray.UpdateDimensions(Model.Grid.LayerCount, Model.Grid.RowCount,
      Model.Grid.ColumnCount);
  end;
  Model.UpdateDataArrayParameterUsed;
  if Model is TPhastModel then
  begin
    PhastModel := TPhastModel(Model);
    for ChildIndex := 0 to PhastModel.ChildModels.Count - 1 do
    begin
      ChildModel := PhastModel.ChildModels[ChildIndex].ChildModel;
      UpdateDataArray(ChildModel, Index);
    end;
  end;
end;

procedure TCustomCreateRequiredDataSetsUndo.UpdatePackageLayers;
var
  Model: TPhastModel;
  Index: Integer;
begin
  Model:= frmGoPhast.PhastModel;

  for Index := 0 to Length(Model.DataArrayManager.FDataArrayCreationRecords) - 1 do
  begin
    UpdateDataArray(Model, Index);
  end;

  UpdateFrmGridColor;
  UpdateFrmContourData;
  UpdateFrmGridValue;
end;

procedure TCustomCreateRequiredDataSetsUndo.UpdateOnPostInitialize;
begin
  frmGoPhast.PhastModel.UpdateOnPostInitialize;
end;

procedure TCustomCreateRequiredDataSetsUndo.UpdatedRequiredDataSets;
begin
  UpdatePackageLayers;
  UpdateOnPostInitialize;
  if frmShowHideObjects <> nil then
  begin
    frmShowHideObjects.UpdateScreenObjects;
  end;
  UpdateFrmGridValue;
end;

{ TUndoModelSelectionChange }

constructor TUndoModelSelectionChange.Create(NewModelSelection: TModelSelection);
var
  Packages: TModflowPackages;
begin
  inherited Create;
  FOldModelSelection := frmGoPhast.ModelSelection;
  FNewModelSelection := NewModelSelection;
  Packages := frmGoPhast.PhastModel.ModflowPackages;
  FUpwSelected := Packages.UpwPackage.IsSelected;
  FLpfSelected := Packages.LpfPackage.IsSelected;
  FNwtSelected := Packages.NwtPackage.IsSelected;
  FPcgSelected := Packages.PcgPackage.IsSelected;
end;

function TUndoModelSelectionChange.Description: string;
begin
  result := 'change model selection';
end;

procedure TUndoModelSelectionChange.DoCommand;
begin
  inherited;
  frmGoPhast.ModelSelection := FNewModelSelection;
  UpdatedRequiredDataSets;
end;

procedure TUndoModelSelectionChange.Undo;
var
  Packages: TModflowPackages;
begin
  inherited;
  frmGoPhast.ModelSelection := FOldModelSelection;
  Packages := frmGoPhast.PhastModel.ModflowPackages;
  Packages.UpwPackage.IsSelected := FUpwSelected;
  Packages.LpfPackage.IsSelected := FLpfSelected;
  Packages.NwtPackage.IsSelected := FNwtSelected;
  Packages.PcgPackage.IsSelected := FPcgSelected;
  UpdatedRequiredDataSets;
end;

{ TUndoChangeParameters }

constructor TCustomUndoChangeParameters.Create(
  var NewSteadyParameters: TModflowSteadyParameters;
  var NewTransientParameters: TModflowTransientListParameters;
  var NewHufModflowParameters: THufModflowParameters;
  var NewSfrParamInstances: TSfrParamInstances);
var
  ScreenObjectIndex: Integer;
  ScreenObject: TScreenObject;
  OldBoundary: TModflowBoundaries;
begin
  inherited Create;
  FOldModflowBoundaries := TObjectList.Create;
  for ScreenObjectIndex := 0 to frmGoPhast.PhastModel.ScreenObjectCount - 1 do
  begin
    ScreenObject := frmGoPhast.PhastModel.ScreenObjects[ScreenObjectIndex];
    OldBoundary := TModflowBoundaries.Create;
    OldBoundary.Assign(ScreenObject.ModflowBoundaries);
    FOldModflowBoundaries.Add(OldBoundary);
  end;

  FNewSteadyParameters:= NewSteadyParameters;
  // TUndoDefineLayers takes ownership of NewSteadyParameters.
  NewSteadyParameters := nil;

  FNewTransientParameters := NewTransientParameters;
  // TUndoDefineLayers takes ownership of NewTransientParameters.
  NewTransientParameters := nil;

  // TUndoDefineLayers takes ownership of NewHufModflowParameters.
  FNewHufModflowParameters := NewHufModflowParameters;
  NewHufModflowParameters := nil;

  FNewSfrParamInstances := NewSfrParamInstances;
  NewSfrParamInstances := nil;

  FOldSteadyParameters:= TModflowSteadyParameters.Create(nil);
  FOldSteadyParameters.Assign(frmGoPhast.PhastModel.ModflowSteadyParameters);
  FOldTransientParameters:= TModflowTransientListParameters.Create(nil);
  FOldTransientParameters.Assign(frmGoPhast.PhastModel.ModflowTransientParameters);
  FOldHufModflowParameters := THufModflowParameters.Create(nil);
  FOldHufModflowParameters.Assign(frmGoPhast.PhastModel.HufParameters);
  FOldSfrParamInstances := TSfrParamInstances.Create(nil);
  FOldSfrParamInstances.Assign(frmGoPhast.PhastModel.ModflowPackages.
    SfrPackage.ParameterInstances);

//  FExistingScreenObjects := TScreenObjectEditCollection.Create;
//  FExistingScreenObjects.OwnScreenObject := False;


end;

function TCustomUndoChangeParameters.Description: string;
begin
  result := 'Change parameters';
end;

destructor TCustomUndoChangeParameters.Destroy;
begin
  FOldHufModflowParameters.Free;
  FNewHufModflowParameters.Free;
  FNewSteadyParameters.Free;
  FOldSteadyParameters.Free;
  FNewTransientParameters.Free;
  FOldTransientParameters.Free;
  FNewSfrParamInstances.Free;
  FOldSfrParamInstances.Free;
  FOldModflowBoundaries.Free;
//  FExistingScreenObjects.Free;
  inherited;
end;

procedure TCustomUndoChangeParameters.DoCommand;
begin
  inherited;
  frmGoPhast.PhastModel.ModflowSteadyParameters.ClearNewDataSets;
  frmGoPhast.PhastModel.ModflowSteadyParameters := FNewSteadyParameters;
  frmGoPhast.PhastModel.ModflowSteadyParameters.RemoveOldDataSetVariables;
  frmGoPhast.PhastModel.ModflowTransientParameters := FNewTransientParameters;
  frmGoPhast.PhastModel.ModflowSteadyParameters.NewDataSets := nil;
  frmGoPhast.PhastModel.HufParameters := FNewHufModflowParameters;
  frmGoPhast.PhastModel.ModflowPackages.SfrPackage.ParameterInstances :=
    FNewSfrParamInstances;
  UpdatedRequiredDataSets;
end;

procedure TCustomUndoChangeParameters.Undo;
var
  ScreenObjectIndex: Integer;
  ScreenObject: TScreenObject;
  OldBoundary: TModflowBoundaries;
begin
  inherited;
  frmGoPhast.PhastModel.ModflowSteadyParameters  := FOldSteadyParameters;
  frmGoPhast.PhastModel.ModflowSteadyParameters.RemoveNewDataSets;
  frmGoPhast.PhastModel.ModflowSteadyParameters.RemoveOldDataSetVariables;
  frmGoPhast.PhastModel.ModflowTransientParameters := FOldTransientParameters;
  frmGoPhast.PhastModel.ModflowSteadyParameters.NewDataSets := nil;
  frmGoPhast.PhastModel.HufParameters := FOldHufModflowParameters;
  frmGoPhast.PhastModel.ModflowPackages.SfrPackage.ParameterInstances :=
    FOldSfrParamInstances;
  UpdatedRequiredDataSets;
  for ScreenObjectIndex := 0 to frmGoPhast.PhastModel.ScreenObjectCount - 1 do
  begin
    ScreenObject := frmGoPhast.PhastModel.ScreenObjects[ScreenObjectIndex];
    OldBoundary := FOldModflowBoundaries[ScreenObjectIndex];
    ScreenObject.ModflowBoundaries.Assign(OldBoundary);
  end;
end;

end.
