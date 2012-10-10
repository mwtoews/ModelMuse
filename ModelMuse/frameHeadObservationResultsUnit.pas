unit frameHeadObservationResultsUnit;

interface

{ TODO : give the option to plot residuals as a number and to filter out large residuals. }

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, RbwDataGrid4, JvSpin, JvExControls,
  JvColorBox, JvColorButton, frameDisplayLimitUnit, Mask, JvExMask, JvToolEdit,
  ComCtrls, GoPhastTypes, ModflowHeadObsResults, Generics.Collections,
  UndoItems;

type
  TUndoType = (utChange, utImport);
  TObsCol = (ocName, ocResidual, ocObserved, ocSimulated,
    ocX, ocY, ocTime, ocObjectName);

  TObsHeadLink = class(TObject)
  private
    FModel: TBaseModel;
    FOldHeadObsCollection: THeadObsCollection;
    FNewHeadObsCollection: THeadObsCollection;
  public
    constructor Create(AModel: TBaseModel);
    destructor Destroy; override;
  end;

  TObsHeadLinkList = class (TObjectList<TObsHeadLink>)
  public
    function IndexOfModel(AModel: TBaseModel): Integer;
  end;

  TCustomUndoChangeHeadObsResults = class(TCustomUndo)
  private
    FObsLinkList: TObsHeadLinkList;
    procedure ApplyChange(Model: TBaseModel;
      HeadObsCollection: THeadObsCollection);
    procedure UpdateGUI;
  public
    procedure DoCommand; override;
    procedure Undo; override;
  public
    constructor Create(var ObsLinkList: TObsHeadLinkList);
    Destructor Destroy; override;
  end;

  TUndoChangeHeadObsResults = class(TCustomUndoChangeHeadObsResults)
  protected
    function Description: string; override;
  end;

  TUndoImportChangeHeadObsResults = class(TCustomUndoChangeHeadObsResults)
  protected
    function Description: string; override;
  end;

  TframeHeadObservationResults = class(TFrame)
    pgcHeadObs: TPageControl;
    tabControls: TTabSheet;
    lblNegativeColor: TLabel;
    lblColorPositive: TLabel;
    lblMaxSymbolSize: TLabel;
    lblHeadObsResults: TLabel;
    flnmedHeadObsResults: TJvFilenameEdit;
    grpbxFilter: TGroupBox;
    lblMaximumTime: TLabel;
    lblMaxResidual: TLabel;
    lblMinimumTime: TLabel;
    lblMinResidual: TLabel;
    framelmtMaximumTime: TframeDisplayLimit;
    framelmtMaxResidual: TframeDisplayLimit;
    framelmtMinimumTime: TframeDisplayLimit;
    framelmtMinResidual: TframeDisplayLimit;
    clrbtnNegative: TJvColorButton;
    clrbtnPositive: TJvColorButton;
    spinSymbolSize: TJvSpinEdit;
    cbShow: TCheckBox;
    tabValues: TTabSheet;
    rdgHeadObs: TRbwDataGrid4;
    pnlBottom: TPanel;
    comboModels: TComboBox;
    btnHightlightObjects: TButton;
    procedure flnmedHeadObsResultsChange(Sender: TObject);
    procedure comboModelsChange(Sender: TObject);
    procedure btnHightlightObjectsClick(Sender: TObject);
    procedure rdgHeadObsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FUndoType: TUndoType;
    FCurrentModelLink: TObsHeadLink;
    FGettingDate: Boolean;
    FImportResult: Boolean;
    ObsLinkList : TObsHeadLinkList;
    procedure SetCurrentModelLink(Value: TObsHeadLink);
    procedure Initialize(AHeadObsColl: THeadObsCollection);
    procedure DisplayValues(AHeadObsColl: THeadObsCollection);
    procedure GetDataForAModel(AHeadObsColl: THeadObsCollection);
    function ReadFileForAModel(AHeadObsColl: THeadObsCollection;
      const FileName: string; ShowDialog: boolean): Boolean;
    procedure SetDataForAModel(HeadObs: THeadObsCollection);
    property CurrentModelLink: TObsHeadLink read FCurrentModelLink
      write SetCurrentModelLink;
    procedure TestForNewFiles;
    { Private declarations }
  protected
    procedure Loaded; override;
  public
    procedure GetData;
    procedure SetData;
    function ReadFile(const FileName: string): Boolean;
    procedure UpdateChildModels;
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateSelectedModel;
    { Public declarations }
  end;

implementation

uses
  PhastModelUnit, frmGoPhastUnit, ModflowHobUnit, frmDisplayDataUnit, Math,
  UndoItemsScreenObjects, ScreenObjectUnit, frmGoToUnit, Contnrs;

{$R *.dfm}

resourcestring
  StrTheFileSHasADi = 'The file %s has a different date than the imported re' +
  'sults. Do you want to import it?';
  StrTheFileSHasADiMultiple = 'The following files %s have a different date '
  + 'than the imported results. Do you want to import them?';
  StrChangeHeadResultP = 'change head result parameters';
  StrImportHeadResults = 'import head results';
  StrObservationName = 'Observation Name';
  StrX = 'X';
  StrY = 'Y';
  StrTime = 'Time';
  StrObservedValue = 'Observed Value';
  StrSimulatedValue = 'Simulated Value';
  StrResidual = 'Residual';
  StrObjectName = 'Object Name';


type
  TGridCrack = class(TRbwDataGrid4);
  TCompareMethod = class(TObject)
    Method: TObsCol;
  end;

var
  SortOrder: TList = nil;


function CompareScreenObjectName(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := AnsiCompareText(P1.ScreenObjectName, P2.ScreenObjectName);
end;

function CompareName(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := AnsiCompareText(P1.Name, P2.Name);
end;

function CompareObservedValue(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(P1.ObservedValue - P2.ObservedValue);
end;

function CompareSimulatedValue(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(P1.SimulatedValue - P2.SimulatedValue);
end;

function CompareResidual(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(P1.Residual - P2.Residual);
end;

function CompareTime(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(P1.Time - P2.Time);
end;

function CompareX(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(P1.X - P2.X);
end;

function CompareY(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(P1.Y - P2.Y);
end;

function CompareVisible(Item1, Item2: Pointer): Integer;
var
  P1, P2: THeadObsItem;
begin
  P1 := Item1;
  P2 := Item2;
  result := Sign(Ord(P1.Visible) - Ord(P2.Visible));
end;

function CompareObservations(Item1, Item2: Pointer): Integer;
var
  Index: Integer;
  CM: TCompareMethod;
begin
  result := 0;
  for Index := 0 to SortOrder.Count - 1 do
  begin
    CM := SortOrder[Index];
    case CM.Method of
      ocName: result := CompareName(Item1, Item2);
      ocResidual: result := CompareResidual(Item1, Item2);
      ocObserved: result := CompareObservedValue(Item1, Item2);
      ocSimulated: result := CompareSimulatedValue(Item1, Item2);
      ocX: result := CompareX(Item1, Item2);
      ocY: result := CompareY(Item1, Item2);
      ocTime: result := CompareTime(Item1, Item2);
      ocObjectName: result := CompareScreenObjectName(Item1, Item2);
    end;
    if result <> 0 then
    begin
      Exit;
    end;
  end;
end;


{ TObsHeadLink }

constructor TObsHeadLink.Create(AModel: TBaseModel);
var
  LocalModel: TCustomModel;
begin
  FModel := AModel;
  FOldHeadObsCollection := THeadObsCollection.Create(nil);
  FNewHeadObsCollection := THeadObsCollection.Create(nil);

  LocalModel := FModel as TCustomModel;
  FOldHeadObsCollection.Assign(LocalModel.HeadObsResults);
  FNewHeadObsCollection.Assign(LocalModel.HeadObsResults);
end;

destructor TObsHeadLink.Destroy;
begin
  FOldHeadObsCollection.Free;
  FNewHeadObsCollection.Free;
  inherited;
end;

{ TObsHeadLinkList }

function TObsHeadLinkList.IndexOfModel(AModel: TBaseModel): Integer;
var
  Index: Integer;
  AnItem: TObsHeadLink;
begin
  for Index := 0 to Count - 1 do
  begin
    AnItem := Items[Index];
    if AnItem.FModel = AModel then
    begin
      Result := Index;
      Exit;
    end;
  end;
  result := -1;
end;

{ TCustomUndoChangeHeadObsResults }

procedure TCustomUndoChangeHeadObsResults.ApplyChange(Model: TBaseModel;
  HeadObsCollection: THeadObsCollection);
begin
  (Model as TCustomModel).HeadObsResults.Assign(HeadObsCollection);
end;

constructor TCustomUndoChangeHeadObsResults.Create(var ObsLinkList: TObsHeadLinkList);
begin
  FObsLinkList := ObsLinkList;
  ObsLinkList := nil;
end;

destructor TCustomUndoChangeHeadObsResults.Destroy;
begin
  FObsLinkList.Free;
  inherited;
end;

procedure TCustomUndoChangeHeadObsResults.UpdateGUI;
begin
  frmGoPhast.TopDiscretizationChanged := True;
  frmGoPhast.frameTopView.ZoomBox.InvalidateImage32;

  if frmDisplayData <> nil then
  begin
    frmDisplayData.frameHeadObservationResults.UpdateSelectedModel;
  end;
end;

procedure TCustomUndoChangeHeadObsResults.DoCommand;
var
  Index: Integer;
  ObsItem: TObsHeadLink;
begin
  inherited;
  for Index := 0 to FObsLinkList.Count - 1 do
  begin
    ObsItem := FObsLinkList[Index];
    ApplyChange(ObsItem.FModel, ObsItem.FNewHeadObsCollection);
  end;
  UpdateGUI;
end;

procedure TCustomUndoChangeHeadObsResults.Undo;
var
  Index: Integer;
  ObsItem: TObsHeadLink;
begin
  inherited;
  for Index := 0 to FObsLinkList.Count - 1 do
  begin
    ObsItem := FObsLinkList[Index];
    ApplyChange(ObsItem.FModel, ObsItem.FOldHeadObsCollection);
  end;
  UpdateGUI;
end;

{ TUndoChangeHeadObsResults }

function TUndoChangeHeadObsResults.Description: string;
begin
  result := StrChangeHeadResultP;
end;

{ TUndoImportChangeHeadObsResults }

function TUndoImportChangeHeadObsResults.Description: string;
begin
  result := StrImportHeadResults;
end;


{ TframeHeadObservationResults }

procedure TframeHeadObservationResults.btnHightlightObjectsClick(
  Sender: TObject);
var
  Undo: TUndoChangeSelection;
  RowIndex: Integer;
  ColIndex: Integer;
  ScreenObjects: TStringList;
  ScreenObjectIndex: Integer;
  AScreenObject: TScreenObject;
  ScreenObjectName: string;
  NameIndex: Integer;
  XCoordinate: real;
  YCoordinate: real;
begin
  ScreenObjects := TStringList.Create;
  try
    for ScreenObjectIndex := 0 to frmGoPhast.PhastModel.ScreenObjectCount - 1 do
    begin
      AScreenObject := frmGoPhast.PhastModel.ScreenObjects[ScreenObjectIndex];
      if not AScreenObject.Deleted
        and (AScreenObject.ModflowBoundaries.ModflowHeadObservations <> nil)
        and AScreenObject.ModflowBoundaries.ModflowHeadObservations.Used then
      begin
        ScreenObjects.AddObject(AScreenObject.Name, AScreenObject)
      end;
    end;
    ScreenObjects.Sorted := True;

    Undo := TUndoChangeSelection.Create;
    frmGoPhast.ResetSelectedScreenObjects;

    for RowIndex := 1 to rdgHeadObs.RowCount - 1 do
    begin
      for ColIndex := 0 to rdgHeadObs.ColCount - 1 do
      begin
        if rdgHeadObs.IsSelectedCell(ColIndex, RowIndex) then
        begin
          ScreenObjectName := rdgHeadObs.Cells[Ord(ocObjectName), RowIndex];
          NameIndex := ScreenObjects.IndexOf(ScreenObjectName);
          if NameIndex >= 0 then
          begin
            AScreenObject := ScreenObjects.Objects[NameIndex] as TScreenObject;
            AScreenObject.Selected := True;
          end;
          break;
        end;
      end;
    end;
    ScreenObjectName := rdgHeadObs.Cells[
      Ord(ocObjectName),rdgHeadObs.SelectedRow];

    Undo.SetPostSelection;

    if Undo.SelectionChanged then
    begin
      frmGoPhast.UndoStack.Submit(Undo);
    end
    else
    begin
      Undo.Free;
    end;

    NameIndex := ScreenObjects.IndexOf(ScreenObjectName);
    if NameIndex >= 0 then
    begin
      AScreenObject := ScreenObjects.Objects[NameIndex] as TScreenObject;
      AScreenObject.Selected := True;
      XCoordinate := AScreenObject.Points[0].X;
      YCoordinate := AScreenObject.Points[0].Y;
      case AScreenObject.ViewDirection of
        vdTop:
          begin
            SetTopPosition(XCoordinate, YCoordinate);
          end;
        vdFront:
          begin
            SetFrontPosition(XCoordinate, YCoordinate);
          end;
        vdSide:
          begin
            SetSidePosition(YCoordinate, XCoordinate);
          end;
      else
        Assert(False);
      end;
    end;

  finally
    ScreenObjects.Free;
  end;
end;

procedure TframeHeadObservationResults.comboModelsChange(Sender: TObject);
var
  AModel: TBaseModel;
  ModelIndex: Integer;
begin
  inherited;
  if comboModels.ItemIndex >= 0 then
  begin
    AModel := comboModels.Items.Objects[comboModels.ItemIndex] as TBaseModel;
    ModelIndex := ObsLinkList.IndexOfModel(AModel);
    if ModelIndex < 0 then
    begin
      CurrentModelLink := TObsHeadLink.Create(AModel);
      ObsLinkList.Add(FCurrentModelLink);
    end
    else
    begin
      CurrentModelLink := ObsLinkList[ModelIndex];
    end;
  end
  else
  begin
    CurrentModelLink := nil;
  end;
end;

constructor TframeHeadObservationResults.Create(Owner: TComponent);
begin
  inherited;
  ObsLinkList := TObsHeadLinkList.Create;
end;

destructor TframeHeadObservationResults.Destroy;
begin
  ObsLinkList.Free;
  inherited;
end;

procedure TframeHeadObservationResults.DisplayValues(
  AHeadObsColl: THeadObsCollection);
var
  Item: THeadObsItem;
  Index: Integer;
  AList: TList;
begin
  rdgHeadObs.BeginUpdate;
  try
    rdgHeadObs.RowCount := Max(AHeadObsColl.Count + 1,2);
    AList := TList.Create;
    try
      AList.Capacity := AHeadObsColl.Count;
      for Index := 0 to AHeadObsColl.Count - 1 do
      begin
        AList.Add(AHeadObsColl[Index]);
      end;
      AList.Sort(CompareObservations);
      for Index := 0 to AList.Count - 1 do
      begin
        Item := AList[Index];
        rdgHeadObs.Cells[Ord(ocName), Index + 1] := Item.Name;
        rdgHeadObs.Cells[Ord(ocX), Index + 1] := FloatToStr(Item.X);
        rdgHeadObs.Cells[Ord(ocY), Index + 1] := FloatToStr(Item.Y);
        rdgHeadObs.Cells[Ord(ocTime), Index + 1] := FloatToStr(Item.Time);
        rdgHeadObs.Cells[Ord(ocObserved), Index + 1] := FloatToStr(Item.ObservedValue);
        rdgHeadObs.Cells[Ord(ocSimulated), Index + 1] := FloatToStr(Item.SimulatedValue);
        rdgHeadObs.Cells[Ord(ocResidual), Index + 1] := FloatToStr(Item.Residual);
        rdgHeadObs.Cells[Ord(ocObjectName), Index + 1] := Item.ScreenObjectName;
      end;
    finally
      AList.Free;
    end;
  finally
    rdgHeadObs.EndUpdate;
  end;
end;

procedure TframeHeadObservationResults.flnmedHeadObsResultsChange(
  Sender: TObject);
begin
  if FGettingDate then
  begin
    Exit;
  end;
  if FileExists(flnmedHeadObsResults.FileName) then
  begin
    CurrentModelLink.FNewHeadObsCollection.FileName := flnmedHeadObsResults.FileName;
    FImportResult := CurrentModelLink.FNewHeadObsCollection.ReadFromFile;
    FUndoType := utImport
  end
  else
  begin
    CurrentModelLink.FNewHeadObsCollection.FileName := '';
    CurrentModelLink.FNewHeadObsCollection.FileDate := 0;
    CurrentModelLink.FNewHeadObsCollection.Clear;
  end;
end;

procedure TframeHeadObservationResults.GetData;
begin
  Handle;
  FCurrentModelLink := nil;
  UpdateChildModels;
  CurrentModelLink := ObsLinkList[0];
end;

procedure TframeHeadObservationResults.GetDataForAModel(
  AHeadObsColl: THeadObsCollection);
begin
  FGettingDate := True;
  try
    Initialize(AHeadObsColl);
    flnmedHeadObsResults.FileName := AHeadObsColl.FileName;
    DisplayValues(AHeadObsColl);
  finally
    FGettingDate := False;
  end;
end;

procedure TframeHeadObservationResults.Initialize(
  AHeadObsColl: THeadObsCollection);
begin
//  FHeadObsCollection.Assign(AHeadObsColl);
  framelmtMinResidual.Limit := AHeadObsColl.MinResidualLimit;
  framelmtMaxResidual.Limit := AHeadObsColl.MaxResidualLimit;
  framelmtMinimumTime.Limit := AHeadObsColl.MinTimeLimit;
  framelmtMaximumTime.Limit := AHeadObsColl.MaxTimeLimit;
  clrbtnNegative.Color := AHeadObsColl.NegativeColor;
  clrbtnPositive.Color := AHeadObsColl.PositiveColor;
  spinSymbolSize.AsInteger := AHeadObsColl.MaxSymbolSize;
  cbShow.Checked := AHeadObsColl.Visible;
end;

procedure TframeHeadObservationResults.Loaded;
begin
  inherited;
  pgcHeadObs.ActivePageIndex := 0;
  framelmtMinResidual.Enabled := True;
  framelmtMaxResidual.Enabled := True;
  framelmtMinimumTime.Enabled := True;
  framelmtMaximumTime.Enabled := True;

  rdgHeadObs.BeginUpdate;
  try
    rdgHeadObs.Cells[Ord(ocName),0] := StrObservationName;
    rdgHeadObs.Cells[Ord(ocX),0] := StrX;
    rdgHeadObs.Cells[Ord(ocY),0] := StrY;
    rdgHeadObs.Cells[Ord(ocTime),0] := StrTime;
    rdgHeadObs.Cells[Ord(ocObserved),0] := StrObservedValue;
    rdgHeadObs.Cells[Ord(ocSimulated),0] := StrSimulatedValue;
    rdgHeadObs.Cells[Ord(ocResidual),0] := StrResidual;
    rdgHeadObs.Cells[Ord(ocObjectName),0] := StrObjectName;
  finally
    rdgHeadObs.EndUpdate;
  end;

  UpdateChildModels;
end;

procedure TframeHeadObservationResults.rdgHeadObsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol: Integer;
  ARow: Integer;
  ObsCol: TObsCol;
  Index: integer;
  CM: TCompareMethod;
begin
  if FCurrentModelLink <> nil then
  begin
    rdgHeadObs.MouseToCell(X, Y, ACol, ARow);
    if (ARow = 0) and (ACol >= 0) and (ACol < rdgHeadObs.ColCount) then
    begin
      TGridCrack(rdgHeadObs).HideEditor;
      ObsCol := TObsCol(ACol);
      for Index := 0 to SortOrder.Count-1 do
      begin
        CM := SortOrder[Index];
        if CM.Method = ObsCol then
        begin
          SortOrder.Extract(CM);
          SortOrder.Insert(0, CM);
          GetDataForAModel(FCurrentModelLink.FNewHeadObsCollection);
          break;
        end;
      end;
    end;
  end;
end;

function TframeHeadObservationResults.ReadFile(const FileName: string): Boolean;
var
  Index: Integer;
  ObsItem: TObsHeadLink;
  AFileName: string;
begin
  UpdateChildModels;

  result := True;
  for Index := 0 to ObsLinkList.Count - 1 do
  begin
    ObsItem := ObsLinkList[Index];
    if ObsItem.FModel is TChildModel then
    begin
      AFileName := TChildModel(ObsItem.FModel).Child_NameFile_Name(FileName);
      AFileName := ChangeFileExt(AFileName, StrHobout);
    end
    else
    begin
      AFileName := FileName;
    end;
    FCurrentModelLink := ObsItem;
    Result := ReadFileForAModel(ObsItem.FNewHeadObsCollection, AFileName, Index=0);
    if not result then
    begin
      Exit;
    end;
  end;
  FCurrentModelLink := nil;
  CurrentModelLink := ObsLinkList[0];
end;

function TframeHeadObservationResults.ReadFileForAModel(
  AHeadObsColl: THeadObsCollection; const FileName: string;
  ShowDialog: boolean): Boolean;
begin
  Initialize(AHeadObsColl);
  flnmedHeadObsResults.Dialog.FileName := FileName;
  if ShowDialog then
  begin
    result := flnmedHeadObsResults.Dialog.Execute;
  end
  else
  begin
    result := True;
  end;
  if result then
  begin
    FImportResult := False;
    flnmedHeadObsResults.FileName := flnmedHeadObsResults.Dialog.FileName;
    result := FImportResult;
  end;
  DisplayValues(AHeadObsColl);
end;

procedure TframeHeadObservationResults.SetCurrentModelLink(Value: TObsHeadLink);
var
  HeadObs: THeadObsCollection;
  FOldModelLink: TObsHeadLink;
begin
  if FCurrentModelLink <> nil then
  begin
    HeadObs := FCurrentModelLink.FNewHeadObsCollection;
    SetDataForAModel(HeadObs);
  end;
  FOldModelLink := FCurrentModelLink;
  FCurrentModelLink := Value;
  if FCurrentModelLink <> nil then
  begin
    if (FOldModelLink <> FCurrentModelLink) and (FOldModelLink <> nil) then
    begin
      FCurrentModelLink.FNewHeadObsCollection.MaxSymbolSize :=
        FOldModelLink.FNewHeadObsCollection.MaxSymbolSize
    end;
    GetDataForAModel(FCurrentModelLink.FNewHeadObsCollection)
  end;
end;

procedure TframeHeadObservationResults.SetData;
var
  Undo: TCustomUndoChangeHeadObsResults;
begin
  CurrentModelLink := nil;
  TestForNewFiles;
  Undo := nil;
  case FUndoType of
    utChange:
      begin
        Undo := TUndoChangeHeadObsResults.Create(ObsLinkList);
      end;
    utImport:
      begin
        Undo := TUndoImportChangeHeadObsResults.Create(ObsLinkList);
      end;
    else Assert(False);
  end;
  frmGoPhast.UndoStack.Submit(Undo);
  FUndoType := utChange;
end;

procedure TframeHeadObservationResults.SetDataForAModel(
  HeadObs: THeadObsCollection);
begin
  HeadObs.MinResidualLimit := framelmtMinResidual.Limit;
  HeadObs.MaxResidualLimit := framelmtMaxResidual.Limit;
  HeadObs.MinTimeLimit := framelmtMinimumTime.Limit;
  HeadObs.MaxTimeLimit := framelmtMaximumTime.Limit;
  HeadObs.NegativeColor := clrbtnNegative.Color;
  HeadObs.PositiveColor := clrbtnPositive.Color;
  HeadObs.MaxSymbolSize := spinSymbolSize.AsInteger;
  HeadObs.Visible := cbShow.Checked;
end;

procedure TframeHeadObservationResults.TestForNewFiles;
var
  ObsItem: TObsHeadLink;
  ReadFiles: Boolean;
  Index: Integer;
  FileDate: TDateTime;
  NewerFiles: TStringList;
begin
  NewerFiles := TStringList.Create;
  try
    for Index := 0 to ObsLinkList.Count - 1 do
    begin
      ObsItem := ObsLinkList[Index];
      if FileExists(ObsItem.FNewHeadObsCollection.FileName) then
      begin
        FileAge(ObsItem.FNewHeadObsCollection.FileName, FileDate);
        if FileDate <> ObsItem.FNewHeadObsCollection.FileDate then
        begin
          NewerFiles.Add(ObsItem.FNewHeadObsCollection.FileName);
        end;
      end;
    end;
    ReadFiles := False;
    if NewerFiles.Count > 0 then
    begin
      Beep;
      if NewerFiles.Count = 1 then
      begin
        ReadFiles := MessageDlg(Format(StrTheFileSHasADi, [NewerFiles[0]]),
          mtWarning, [mbYes, mbNo], 0) = mrYes;
      end
      else
      begin
        NewerFiles.LineBreak := ', ';
        ReadFiles := MessageDlg(Format(StrTheFileSHasADiMultiple, [NewerFiles.Text]),
          mtWarning, [mbYes, mbNo], 0) = mrYes;
      end;
    end;
    for Index := 0 to ObsLinkList.Count - 1 do
    begin
      ObsItem := ObsLinkList[Index];
      if ReadFiles and FileExists(ObsItem.FNewHeadObsCollection.FileName) then
      begin
        FileAge(ObsItem.FNewHeadObsCollection.FileName, FileDate);
        if FileDate <> ObsItem.FNewHeadObsCollection.FileDate then
        begin
          ObsItem.FNewHeadObsCollection.ReadFromFile;
        end;
      end;
      if ObsItem.FNewHeadObsCollection.FileName = '' then
      begin
        ObsItem.FNewHeadObsCollection.Clear;
      end;
    end;
  finally
    NewerFiles.Free;
  end;
end;

procedure TframeHeadObservationResults.UpdateChildModels;
var
  ChildIndex: Integer;
  ChildModel: TChildModel;
  LocalModel: TPhastModel;
  Index: Integer;
  AModel: TBaseModel;
begin
  if ObsLinkList = nil then
  begin
    ObsLinkList := TObsHeadLinkList.Create;
  end;
  ObsLinkList.Clear;

  LocalModel := frmGoPhast.PhastModel;
  ObsLinkList.Add(TObsHeadLink.Create(LocalModel));
  if LocalModel.LgrUsed then
  begin
    for ChildIndex := 0 to LocalModel.ChildModels.Count - 1 do
    begin
      ChildModel := LocalModel.ChildModels[ChildIndex].ChildModel;
      ObsLinkList.Add(TObsHeadLink.Create(ChildModel));
    end;
  end;

  for Index := comboModels.Items.Count - 1 downto 0 do
  begin
    AModel := comboModels.Items.Objects[Index] as TBaseModel;
    if ObsLinkList.IndexOfModel(AModel) < 0 then
    begin
      comboModels.Items.Delete(Index);
    end;
  end;

//  comboModels.Clear;
  if comboModels.Items.IndexOfObject(LocalModel) < 0 then
  begin
    comboModels.Items.InsertObject(0, LocalModel.DisplayName, LocalModel);
  end;
  if LocalModel.LgrUsed then
  begin
    comboModels.Visible := True;
    for ChildIndex := 0 to LocalModel.ChildModels.Count - 1 do
    begin
      ChildModel := LocalModel.ChildModels[ChildIndex].ChildModel;
      if comboModels.Items.IndexOfObject(ChildModel) < 0 then
      begin
        comboModels.Items.InsertObject(ChildIndex+1, ChildModel.DisplayName, ChildModel);
      end;
    end;
  end
  else
  begin
    comboModels.Visible := False;
  end;
  comboModels.ItemIndex := 0;
end;

procedure TframeHeadObservationResults.UpdateSelectedModel;
var
  ModelIndex: Integer;
begin
  ModelIndex := comboModels.ItemIndex;
  GetData;
  if ModelIndex < comboModels.Items.Count then
  begin
    comboModels.ItemIndex := ModelIndex;
    comboModelsChange(nil);
  end;
end;

procedure InitializeSortOrder;
var
  Index: TObsCol;
  CM: TCompareMethod;
begin
  SortOrder.Free;
  SortOrder := TObjectList.Create;
  for Index := Low(TObsCol) to High(TObsCol) do
  begin
    CM := TCompareMethod.Create;
    CM.Method := Index;
    SortOrder.Add(CM)
  end;
end;

initialization
  InitializeSortOrder;

finalization
  SortOrder.Free;

end.
