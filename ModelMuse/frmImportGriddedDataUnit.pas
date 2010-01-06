unit frmImportGriddedDataUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frmCustomGoPhastUnit, Grids, RbwDataGrid4, JvPageList,  ExtCtrls,
  JvExControls, ComCtrls, StdCtrls, Buttons, Mask, FastGEO, JvExMask, JvSpin,
  DataSetUnit, ScreenObjectUnit, ValueArrayStorageUnit, GoPhastTypes,
  UndoItemsScreenObjects, JvLabel, TntStdCtrls, TntExDropDownEdit,
  TntExDropDownVirtualStringTree, VirtualTrees;

type
  TfrmImportGriddedData = class(TfrmCustomGoPhast)
    jvplCellGrid: TJvPageList;
    pnlMethodControls: TPanel;
    Panel2: TPanel;
    jvspCellList: TJvStandardPage;
    jvspGrid: TJvStandardPage;
    rdgList: TRbwDataGrid4;
    pcGriddedData: TPageControl;
    pnlListControls: TPanel;
    GridPanel1: TGridPanel;
    sbAddRow: TSpeedButton;
    sbInsertRow: TSpeedButton;
    sbDeleteRow: TSpeedButton;
    btnHelp: TBitBtn;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    comboMethod: TComboBox;
    lblMethod: TLabel;
    lblDataSet: TLabel;
    seNumberOfRows: TJvSpinEdit;
    lblNumberOfRows: TLabel;
    rdgIgnoreValues: TRbwDataGrid4;
    seIgnoreValueCount: TJvSpinEdit;
    lblIgnoreValueCount: TLabel;
    lblColumns: TLabel;
    lblRows: TJvLabel;
    combotreeDataSets: TTntExDropDownVirtualStringTree;
    procedure comboMethodChange(Sender: TObject);
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject);
    procedure rdgListEndUpdate(Sender: TObject);
    procedure seNumberOfRowsChange(Sender: TObject);
    procedure sbAddRowClick(Sender: TObject);
    procedure sbInsertRowClick(Sender: TObject);
    procedure sbDeleteRowClick(Sender: TObject);
    procedure rdgIgnoreValuesEndUpdate(Sender: TObject);
    procedure seIgnoreValueCountChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure combotreeDataSetsDropDownTreeGetNodeDataSize(
      Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure combotreeDataSetsDropDownTreeChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure combotreeDataSetsDropDownTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
  private
    FGrids: TList;
    FRealIgnoreValues: array of double;
    FIntegerIgnoreValues: array of integer;
    FBooleanIgnoreValues: array of boolean;
    FStringIgnoreValues: array of string;
    FStoredClassifications: TList;
    FSelectedVirtNode: PVirtualNode;
    procedure InitializeGridForCellList(DataSet: TDataArray);
    procedure InitializeGridForGriddedData(Grid: TRbwDataGrid4;
      ColumnFormat: TRbwColumnFormat4; ColumnsForward, RowsForward: Boolean);
    procedure InitializeTabSheetFor2DGriddedData(DataSet: TDataArray);
    procedure InitializeGridsForGriddedData(DataSet: TDataArray);
    procedure GetData;
    procedure SetData;
    procedure AssignDataSetValue;
    procedure StoreIgnoredValues(DataSet: TDataArray);
    function IsIgnoredRealValue(AValue: double): boolean;
    function IsIgnoredIntegerValue(AValue: integer): boolean;
    function IsIgnoredBooleanValue(AValue: boolean): boolean;
    function IsIgnoredStringValue(AValue: string): boolean;
    function ReadARowOfListData(DataSet: TDataArray; RowIndex: Integer;
      out FirstIndex, SecondIndex: Integer; out RealData: Double;
      out IntegerData: Integer; out BooleanData: Boolean;
      out StringData: string): boolean;
    function ReadDataCell(DataSet: TDataArray; RowIndex, DataColumn: Integer;
      var RealData: Double; var IntegerData: Integer; var BooleanData: Boolean;
      var StringData: string): Boolean;
    function ReadAnIndex(var AnIndex: Integer;
      RowIndex, DataColumn: Integer): boolean;
    function ReadOneRow(DataSet: TDataArray; RowIndex: Integer;
      var Layer, Row, Column: Integer; var RealData: Double;
      var IntegerData: Integer; var BooleanData: Boolean;
      var StringData: string): Boolean;
    procedure CreateAScreenObject(DataSet: TDataArray;
      ScreenObjectList: TList; var ScreenObject: TScreenObject;
      ObjectIndex: Integer);
    procedure GetValues(var Values: TValueArrayStorage; DataSet: TDataArray;
      ScreenObject: TScreenObject);
    procedure GetElevations(var Elevations: TValueArrayStorage;
      DataSet: TDataArray; ScreenObject: TScreenObject);
    procedure GetLocation(var Point2D: TPoint2D; var APoint: T3DRealPoint;
      Column: Integer; Row: Integer; Layer: Integer; DataSet: TDataArray);
    procedure AssignValueToScreenObject(ScreenObject: TScreenObject;
      StringData: string; BooleanData: Boolean; IntegerData: Integer;
      RealData: Double; Column: Integer; Row: Integer; Layer: Integer;
      DataSet: TDataArray);
    procedure GetColRowLayerFromGrid(Grid: TRbwDataGrid4;
      ColIndex, RowIndex, GridIndex: Integer; out Column, Row, Layer: Integer;
      DataSet: TDataArray);
    function ReadDataFromGrid(Grid: TRbwDataGrid4; DataSet: TDataArray;
      ColIndex, RowIndex: Integer; var RealData: Double;
      var IntegerData: Integer; var BooleanData: Boolean;
      var StringData: string): Boolean;
    procedure InitializeScreenObject(var ScreenObject: TScreenObject;
      Layer: Integer; ScreenObjectList: TList; DataSet: TDataArray);
    procedure FinalizeScreenObjects(ScreenObjectList: TList;
      DataSet: TDataArray);
    procedure GetGridCount(DataSet: TDataArray; var Limit: Integer);
    procedure RetrieveSelectedObject(var AnObject: TObject);
    property SelectedVirtNode: PVirtualNode read FSelectedVirtNode;
    procedure SetSelectedNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure GetNodeCaption(Node: PVirtualNode; var CellText: WideString; Sender: TBaseVirtualTree);
    { Private declarations }
  public
    { Public declarations }
  end;

  TUndoImportGriddedData = class(TCustomImportMultipleScreenObjects)
  protected
    function Description: string; override;
  public
    procedure DoCommand; override;
    procedure Redo; override;
    procedure Undo; override;
  end;

var
  frmImportGriddedData: TfrmImportGriddedData;

implementation

uses
  Contnrs, RbwParser, frmGoPhastUnit, ClassificationUnit,PhastModelUnit,
  UndoItems, GIS_Functions, frmShowHideObjectsUnit;

{$R *.dfm}

function ConvertDataFormat(DataType: TRbwDataType): TRbwColumnFormat4;
begin
  result := rcf4Real;
  case DataType of
    rdtDouble: result := rcf4Real;
    rdtInteger: result := rcf4Integer;
    rdtBoolean: result := rcf4Boolean;
    rdtString: result := rcf4String;
    else Assert(False);
  end;
end;

Function OrientationToViewDirection(Value: TDataSetOrientation): TViewDirection;
begin
  result := vdTop;
  case Value of
    dsoTop: result := vdTop;
    dsoFront: result := vdFront;
    dsoSide: result := vdSide;
    dso3D: result := vdTop;
    else Assert(False);
  end;
end;

procedure TfrmImportGriddedData.AssignDataSetValue;
var
  DataArray: TDataArray;
  RowIndex: Integer;
  AnObject: TObject;
begin
  jvplCellGrid.ActivePageIndex := comboMethod.ItemIndex;
  RetrieveSelectedObject(AnObject);
  DataArray := AnObject as TDataArray;
  if DataArray <> nil then
  begin
    case jvplCellGrid.ActivePageIndex of
      0:
        begin
          InitializeGridForCellList(DataArray);
        end;
      1:
        begin
          InitializeGridsForGriddedData(DataArray);
        end;
      else Assert(False);
    end;
    if rdgIgnoreValues.Columns[0].Format <>
      ConvertDataFormat(DataArray.DataType) then
    begin
      rdgIgnoreValues.Columns[0].Format :=
        ConvertDataFormat(DataArray.DataType);
      for RowIndex := 1 to rdgIgnoreValues.RowCount - 1 do
      begin
        rdgIgnoreValues.Cells[0,RowIndex] := '';
      end;
    end;
  end;
end;

procedure TfrmImportGriddedData.StoreIgnoredValues(DataSet: TDataArray);
var
  RowIndex: Integer;
  Position: Integer;
  IntegerData: Integer;
  RealData: Double; 
begin
  case DataSet.DataType of
    rdtDouble:
      begin
        SetLength(FRealIgnoreValues, seIgnoreValueCount.AsInteger);
        Position := 0;
        for RowIndex := 1 to seIgnoreValueCount.AsInteger do
        begin
          if TryStrToFloat(rdgIgnoreValues.Cells[0, RowIndex], RealData) then
          begin
            FRealIgnoreValues[Position] := RealData;
            Inc(Position);
          end;
        end;
        SetLength(FRealIgnoreValues, Position);
      end;
    rdtInteger:
      begin
        SetLength(FIntegerIgnoreValues, seIgnoreValueCount.AsInteger);
        Position := 0;
        for RowIndex := 1 to seIgnoreValueCount.AsInteger do
        begin
          if TryStrToInt(rdgIgnoreValues.Cells[0, RowIndex], IntegerData) then
          begin
            FIntegerIgnoreValues[Position] := IntegerData;
            Inc(Position);
          end;
        end;
        SetLength(FIntegerIgnoreValues, Position);
      end;
    rdtBoolean:
      begin
        SetLength(FBooleanIgnoreValues, seIgnoreValueCount.AsInteger);
        for RowIndex := 1 to seIgnoreValueCount.AsInteger do
        begin
          FBooleanIgnoreValues[RowIndex - 1] :=
            rdgIgnoreValues.Checked[0, RowIndex];
        end;
      end;
    rdtString:
      begin
        SetLength(FStringIgnoreValues, seIgnoreValueCount.AsInteger);
        Position := 0;
        for RowIndex := 1 to seIgnoreValueCount.AsInteger do
        begin
          if (rdgIgnoreValues.Cells[0, RowIndex] <> '') then
          begin
            FStringIgnoreValues[Position] := rdgIgnoreValues.Cells[0, RowIndex];
            Inc(Position);
          end;
        end;
        SetLength(FStringIgnoreValues, Position);
      end;
  else
    begin
      Assert(False);
    end;
  end;
end;

procedure TfrmImportGriddedData.GetData;
var
  Index: Integer;
  SelectedDataArray: TDataArray;
  ClassificationList: TStringList;
  LayerGroupsDataSets: TList;
  DataSetList: TClassificationList;
  LayerGroupList: TClassificationList;
  DataSet: TDataArray;
  ClassificationObject: TDataSetClassification;
  SelectedName: string;
  Position: integer;
  HydrogeologicUnitNames: TStringList;
  HufDataArrays: TClassificationList;
begin
  jvplCellGrid.ActivePageIndex := comboMethod.ItemIndex;

  FStoredClassifications.Clear;
  combotreeDataSets.Tree.Clear;

  { TODO : Nearly the same code is use in TfrmFormulaUnit, TFrmGridColor,
  TfrmScreenObjectProperties, and TfrmDataSets. Find a way to combine them. }
  SelectedDataArray := frmGoPhast.Grid.ThreeDDataSet;
  if SelectedDataArray = nil then
  begin
    SelectedName := '';
  end
  else
  begin
    SelectedName := SelectedDataArray.Name;
  end;
  ClassificationList := TStringList.Create;
  try

    HydrogeologicUnitNames := TStringList.Create;
    HufDataArrays := TClassificationList.Create;
    LayerGroupsDataSets := TList.Create;
    DataSetList:= TClassificationList.Create;
    LayerGroupList := TClassificationList.Create;
    try
      frmGoPhast.PhastModel.HydrogeologicUnits.FillDataArrayNames(
        HydrogeologicUnitNames);
      HydrogeologicUnitNames.CaseSensitive := False;
      for Index := 0 to HydrogeologicUnitNames.Count - 1 do
      begin
        HufDataArrays.Add(nil);
      end;

      frmGoPhast.PhastModel.GetLayerGroupDataSets(LayerGroupsDataSets);
      for Index := 0 to LayerGroupsDataSets.Count - 1 do
      begin
        LayerGroupList.Add(nil);
      end;

      for Index := 0 to frmGoPhast.PhastModel.DataSetCount - 1 do
      begin
        DataSet := frmGoPhast.PhastModel.DataSets[Index];
        ClassificationObject := TDataSetClassification.Create(DataSet);
        DataSetList.Add(ClassificationObject);
        FStoredClassifications.Add(ClassificationObject);
        Position := LayerGroupsDataSets.IndexOf(DataSet);
        if Position >= 0 then
        begin
          LayerGroupList[Position] := ClassificationObject;
        end;
        Position := HydrogeologicUnitNames.IndexOf(DataSet.Name);
        if Position >= 0 then
        begin
          HufDataArrays[Position] := ClassificationObject;
        end;
      end;

      ClassifyListedObjects(ClassificationList, DataSetList,
        [LayerGroupList, HufDataArrays]);

      CreateClassifiedVirtualNodes(ClassificationList, 0,
        combotreeDataSets.Tree, SelectedName, FStoredClassifications);
    finally
      LayerGroupList.Free;
      DataSetList.Free;
      LayerGroupsDataSets.Free;
      HufDataArrays.Free;
      HydrogeologicUnitNames.Free;
    end;
  finally
    ClassificationList.Free;
  end;
end;

procedure TfrmImportGriddedData.InitializeGridsForGriddedData(
  DataSet: TDataArray);
var
  ColumnFormat: TRbwColumnFormat4;
  Grid: TRbwDataGrid4;
  ColumnsForward: Boolean;
  RowsForward: Boolean;
  TabSheet: TTabSheet;
  Index: Integer;
  LayerLimit: Integer;
begin
  ColumnFormat := ConvertDataFormat(DataSet.DataType);
  case DataSet.Orientation of
    dsoTop:
      begin
        lblColumns.Caption := 'Columns';
        lblRows.Caption := 'Rows';
        InitializeTabSheetFor2DGriddedData(DataSet);
        Grid := FGrids[0];
        case DataSet.EvaluatedAt of
          eaBlocks:
            begin
              Grid.ColCount := DataSet.ColumnCount + 1;
              Grid.RowCount := DataSet.RowCount + 1;
            end;
          eaNodes:
            begin
              Grid.ColCount := DataSet.ColumnCount + 2;
              Grid.RowCount := DataSet.RowCount + 2;
            end;
          else
            begin
              Assert(False);
            end;
        end;
        ColumnsForward := True;
        RowsForward := True;
        case frmGoPhast.ModelSelection of
          msUndefined:
            begin
              Assert(False);
            end;
          msPhast:
            begin
              ColumnsForward := True;
              RowsForward := False;
            end;
          msModflow:
            begin
              ColumnsForward := True;
              RowsForward := True;
            end;
        else
          begin
            Assert(False);
          end;
        end;
        InitializeGridForGriddedData(Grid, ColumnFormat,
          ColumnsForward, RowsForward);
      end;
    dsoFront:
      begin
        lblColumns.Caption := 'Columns';
        lblRows.Caption := 'Layers';
        InitializeTabSheetFor2DGriddedData(DataSet);
        Grid := FGrids[0];
        case DataSet.EvaluatedAt of
          eaBlocks:
            begin
              Grid.ColCount := DataSet.ColumnCount + 1;
              Grid.RowCount := DataSet.LayerCount + 1;
            end;
          eaNodes:
            begin
              Grid.ColCount := DataSet.ColumnCount + 2;
              Grid.RowCount := DataSet.LayerCount + 2;
            end;
          else
            begin
              Assert(False);
            end;
        end;
        ColumnsForward := True;
        RowsForward := True;
        case frmGoPhast.ModelSelection of
          msUndefined:
            begin
              Assert(False);
            end;
          msPhast:
            begin
              ColumnsForward := True;
              RowsForward := False;
            end;
          msModflow:
            begin
              ColumnsForward := True;
              RowsForward := True;
            end;
        else
          begin
            Assert(False);
          end;
        end;
        InitializeGridForGriddedData(Grid, ColumnFormat,
          ColumnsForward, RowsForward);
      end;
    dsoSide:
      begin
        lblColumns.Caption := 'Rows';
        lblRows.Caption := 'Layers';
        InitializeTabSheetFor2DGriddedData(DataSet);
        Grid := FGrids[0];
        case DataSet.EvaluatedAt of
          eaBlocks:
            begin
              Grid.ColCount := DataSet.RowCount + 1;
              Grid.RowCount := DataSet.LayerCount + 1;
            end;
          eaNodes:
            begin
              Grid.ColCount := DataSet.RowCount + 2;
              Grid.RowCount := DataSet.LayerCount + 2;
            end;
          else
            begin
              Assert(False);
            end;
        end;
        ColumnsForward := True;
        RowsForward := True;
        case frmGoPhast.ModelSelection of
          msUndefined:
            begin
              Assert(False);
            end;
          msPhast:
            begin
              ColumnsForward := True;
              RowsForward := False;
            end;
          msModflow:
            begin
              ColumnsForward := False;
              RowsForward := True;
            end;
        else
          begin
            Assert(False);
          end;
        end;
        InitializeGridForGriddedData(Grid, ColumnFormat,
          ColumnsForward, RowsForward);
      end;
    dso3D:
      begin
        lblColumns.Caption := 'Columns';
        lblRows.Caption := 'Rows';
        LayerLimit := 0;
        case DataSet.EvaluatedAt of
          eaBlocks:
            begin
              LayerLimit := DataSet.LayerCount;
            end;
          eaNodes:
            begin
              LayerLimit := DataSet.LayerCount + 1;
            end;
          else
            begin
              Assert(False);
            end;
        end;
        while pcGriddedData.PageCount > LayerLimit do
        begin
          pcGriddedData.Pages[pcGriddedData.PageCount - 1].Free;
        end;
        while pcGriddedData.PageCount < LayerLimit do
        begin
          TabSheet := TTabSheet.Create(self);
          TabSheet.PageControl := pcGriddedData;
        end;
        for Index := 0 to pcGriddedData.PageCount - 1 do
        begin
          pcGriddedData.Pages[Index].Caption := 'Layer ' + IntToStr(Index + 1);
          if Index < FGrids.Count then
          begin
            Grid := FGrids[Index];
          end
          else
          begin
            Grid := TRbwDataGrid4.Create(nil);
            FGrids.Add(Grid);
            Grid.AutoDistributeText := True;
          end;
          Grid.Parent := pcGriddedData.Pages[Index];
          case DataSet.EvaluatedAt of
            eaBlocks:
              begin
                Grid.ColCount := DataSet.ColumnCount + 1;
                Grid.RowCount := DataSet.RowCount + 1;
              end;
            eaNodes:
              begin
                Grid.ColCount := DataSet.ColumnCount + 2;
                Grid.RowCount := DataSet.RowCount + 2;
              end;
            else
              begin
                Assert(False);
              end;
          end;
          ColumnsForward := True;
          RowsForward := True;
          case frmGoPhast.ModelSelection of
            msUndefined:
              begin
                Assert(False);
              end;
            msPhast:
              begin
                ColumnsForward := True;
                RowsForward := False;
              end;
            msModflow:
              begin
                ColumnsForward := True;
                RowsForward := True;
              end;
          else
            begin
              Assert(False);
            end;
          end;
          InitializeGridForGriddedData(Grid, ColumnFormat,
            ColumnsForward, RowsForward);
        end;
      end;
  else
    begin
      Assert(False);
    end;
  end;
end;

procedure TfrmImportGriddedData.InitializeTabSheetFor2DGriddedData(
  DataSet: TDataArray);
var
  TabSheet: TTabSheet;
  Grid: TRbwDataGrid4;
begin
  if FGrids.Count > 1 then
  begin
    FGrids.Count := 1;
  end;
  while pcGriddedData.PageCount > 1 do
  begin
    pcGriddedData.Pages[pcGriddedData.PageCount - 1].Free;
  end;
  while pcGriddedData.PageCount < 1 do
  begin
    TabSheet := TTabSheet.Create(self);
    TabSheet.PageControl := pcGriddedData;
  end;
  pcGriddedData.Pages[0].Caption := DataSet.Name;
  if FGrids.Count <> 0 then
  begin
    Grid := FGrids[0];
  end
  else
  begin
    Grid := TRbwDataGrid4.Create(nil);
    FGrids.Add(Grid);
    Grid.AutoDistributeText := True;
  end;
  Grid.Parent := pcGriddedData.Pages[0];
end;

procedure TfrmImportGriddedData.rdgIgnoreValuesEndUpdate(Sender: TObject);
begin
  inherited;
  seIgnoreValueCount.AsInteger := rdgIgnoreValues.RowCount -1;
end;

procedure TfrmImportGriddedData.rdgListEndUpdate(Sender: TObject);
begin
  inherited;
  seNumberOfRows.AsInteger := rdgList.RowCount -1;
end;

procedure TfrmImportGriddedData.sbAddRowClick(Sender: TObject);
begin
  inherited;
  seNumberOfRows.AsInteger := seNumberOfRows.AsInteger + 1;
end;

procedure TfrmImportGriddedData.sbDeleteRowClick(Sender: TObject);
begin
  inherited;
  rdgList.DeleteRow(rdgList.Row);
  rdgListEndUpdate(nil);
end;

procedure TfrmImportGriddedData.sbInsertRowClick(Sender: TObject);
begin
  inherited;
  rdgList.InsertRow(rdgList.Row);
  rdgListEndUpdate(nil);
end;

procedure TfrmImportGriddedData.seNumberOfRowsChange(Sender: TObject);
var
  Index: Integer;
begin
  inherited;
  rdgList.BeginUpdate;
  try
    rdgList.RowCount := seNumberOfRows.AsInteger + 1;
    sbDeleteRow.Enabled := seNumberOfRows.AsInteger > 1;
    for Index := 1 to rdgList.RowCount - 1 do
    begin
      rdgList.Cells[0,Index] := IntToStr(Index);
    end;
  finally
    rdgList.EndUpdate;
  end;
end;

function TfrmImportGriddedData.IsIgnoredRealValue(AValue: double): boolean;
var
  Index: Integer;
begin
  result := False;
  for Index := 0 to Length(FRealIgnoreValues) - 1 do
  begin
    result := FRealIgnoreValues[Index] = AValue;
    if result then
    begin
      Exit;
    end;
  end;
end;

function TfrmImportGriddedData.IsIgnoredIntegerValue(AValue: integer): boolean;
var
  Index: Integer;
begin
  result := False;
  for Index := 0 to Length(FIntegerIgnoreValues) - 1 do
  begin
    result := FIntegerIgnoreValues[Index] = AValue;
    if result then
    begin
      Exit;
    end;
  end;
end;

function TfrmImportGriddedData.IsIgnoredBooleanValue(AValue: boolean): boolean;
var
  Index: Integer;
begin
  result := False;
  for Index := 0 to Length(FBooleanIgnoreValues) - 1 do
  begin
    result := FBooleanIgnoreValues[Index] = AValue;
    if result then
    begin
      Exit;
    end;
  end;
end;

function TfrmImportGriddedData.IsIgnoredStringValue(AValue: string): boolean;
var
  Index: Integer;
begin
  result := False;
  for Index := 0 to Length(FStringIgnoreValues) - 1 do
  begin
    result := FStringIgnoreValues[Index] = AValue;
    if result then
    begin
      Exit;
    end;
  end;
end;

function TfrmImportGriddedData.ReadARowOfListData(DataSet: TDataArray;
  RowIndex: Integer; out FirstIndex, SecondIndex: Integer; out RealData: Double;
  out IntegerData: Integer; out BooleanData: Boolean;
  out StringData: string): Boolean;
var
  DataColumn: Integer;
begin
  Result := ReadAnIndex(FirstIndex, RowIndex, 1);
  if not Result then
  begin
    Exit;
  end;
  Result := ReadAnIndex(SecondIndex, RowIndex, 2);
  if not Result then
  begin
    Exit;
  end;
  DataColumn := 3;
  result := ReadDataCell(DataSet, RowIndex, DataColumn, RealData, IntegerData,
    BooleanData, StringData);
end;

function TfrmImportGriddedData.ReadDataCell(DataSet: TDataArray;
  RowIndex, DataColumn: Integer; var RealData: Double;
  var IntegerData: Integer; var BooleanData: Boolean;
  var StringData: string): Boolean;
begin
  result := True;
  case DataSet.DataType of
    rdtDouble:
      begin
        if not TryStrToFloat(rdgList.Cells[DataColumn, RowIndex],
          RealData) then
        begin
          result := False;
          Exit;
        end;
        if IsIgnoredRealValue(RealData) then
        begin
          result := False;
          Exit;
        end;
      end;
    rdtInteger:
      begin
        if not TryStrToInt(rdgList.Cells[DataColumn, RowIndex],
          IntegerData) then
        begin
          result := False;
          Exit;
        end;
        if IsIgnoredIntegerValue(IntegerData) then
        begin
          result := False;
          Exit;
        end;
      end;
    rdtBoolean:
      begin
        BooleanData := rdgList.Checked[DataColumn, RowIndex];
        if IsIgnoredBooleanValue(BooleanData) then
        begin
          result := False;
          Exit;
        end;
      end;
    rdtString:
      begin
        StringData := rdgList.Cells[DataColumn, RowIndex];
        if IsIgnoredStringValue(StringData) then
        begin
          result := False;
          Exit;
        end;
      end;
  else
    begin
      Assert(False);
    end;
  end;
end;

function TfrmImportGriddedData.ReadAnIndex(var AnIndex: Integer;
  RowIndex, DataColumn: Integer): Boolean;
begin
  result := True;
  if not TryStrToInt(rdgList.Cells[DataColumn, RowIndex], AnIndex) then
  begin
    result := False;
  end;
end;

function TfrmImportGriddedData.ReadOneRow(DataSet: TDataArray;
  RowIndex: Integer; var Layer, Row, Column: Integer; var RealData: Double;
  var IntegerData: Integer; var BooleanData: Boolean;
  var StringData: string): Boolean;
begin
  result := True;
  try
  case DataSet.Orientation of
    dsoTop:
      begin
        Layer := 1;
        result := ReadARowOfListData(DataSet, RowIndex, Row, Column,
          RealData, IntegerData, BooleanData, StringData);
      end;
    dsoFront:
      begin
        Row := 1;
        result := ReadARowOfListData(DataSet, RowIndex, Layer, Column,
          RealData, IntegerData, BooleanData, StringData);
      end;
    dsoSide:
      begin
        Column := 1;
        result := ReadARowOfListData(DataSet, RowIndex, Layer, Row,
          RealData, IntegerData, BooleanData, StringData);
      end;
    dso3D:
      begin
        result := ReadAnIndex(Layer, RowIndex, 1);
        if result then
        begin
          result := ReadAnIndex(Row, RowIndex, 2);
        end;
        if result then
        begin
          result := ReadAnIndex(Column, RowIndex, 3);
        end;
        if result then
        begin
          result := ReadDataCell(DataSet, RowIndex, 4,
            RealData, IntegerData, BooleanData, StringData);
        end;
      end;
  else
    begin
      Assert(False);
    end;
  end;
  finally
    Dec(Layer);
    Dec(Row);
    Dec(Column);
  end;
end;

procedure TfrmImportGriddedData.RetrieveSelectedObject(var AnObject: TObject);
var
  NodeData: PClassificationNodeData;
begin
  if SelectedVirtNode = nil then
  begin
    AnObject := nil;
  end
  else
  begin
    NodeData := combotreeDataSets.Tree.GetNodeData(SelectedVirtNode);
    if Assigned(NodeData) and Assigned(NodeData.ClassificationObject) then
    begin
      if NodeData.ClassificationObject is TDataSetClassification then
      begin
        AnObject := TDataSetClassification(NodeData.ClassificationObject).DataArray;
      end;
    end
    else
    begin
      AnObject := nil;
    end;
  end;
end;

procedure TfrmImportGriddedData.CreateAScreenObject(DataSet: TDataArray;
  ScreenObjectList: TList; var ScreenObject: TScreenObject;
  ObjectIndex: Integer);
var
  DummyUndo: TCustomUndo;
  ViewDirection: TViewDirection;
  DSIndex: Integer;
  AGrid: TRbwDataGrid4; 
begin
  DummyUndo := nil;
  ViewDirection := OrientationToViewDirection(DataSet.Orientation);
  ScreenObject := TScreenObject.CreateWithViewDirection(frmGoPhast.PhastModel,
    ViewDirection, DummyUndo, False);
  ScreenObjectList[ObjectIndex] := ScreenObject;
  ScreenObject.EvaluatedAt := DataSet.EvaluatedAt;
  if DataSet.Orientation = dso3D then
  begin
    ScreenObject.ElevationCount := ecOne;
    ScreenObject.ElevationFormula :=
      rsObjectImportedValuesR
      + '("' + StrImportedElevations + '")';
  end
  else
  begin
    ScreenObject.ElevationCount := ecZero;
  end;
  if jvplCellGrid.ActivePage = jvspCellList then
  begin
    ScreenObject.Capacity := rdgList.RowCount - 1;
  end
  else
  begin
    AGrid := FGrids[0];
    ScreenObject.Capacity := pcGriddedData.PageCount
      * (AGrid.RowCount -1) * (AGrid.ColCount -1);
  end;
  ScreenObject.SetValuesOfIntersectedCells := True;
  DSIndex := ScreenObject.AddDataSet(DataSet);
  case DataSet.DataType of
    rdtDouble: ScreenObject.DataSetFormulas[DSIndex]
      := rsObjectImportedValuesR + '("' + DataSet.Name + '")';
    rdtInteger: ScreenObject.DataSetFormulas[DSIndex]
      := rsObjectImportedValuesI + '("' + DataSet.Name + '")';
    rdtBoolean: ScreenObject.DataSetFormulas[DSIndex]
      := rsObjectImportedValuesB + '("' + DataSet.Name + '")';
    rdtString: ScreenObject.DataSetFormulas[DSIndex]
      := rsObjectImportedValuesT + '("' + DataSet.Name + '")';
    else Assert(False);
  end;
end;

procedure TfrmImportGriddedData.GetValues(var Values: TValueArrayStorage;
  DataSet: TDataArray;
  ScreenObject: TScreenObject);
var
  Item: TValueArrayItem;
begin
  Values := ScreenObject.ImportedValues.ValuesByName(DataSet.Name);
//  Values := DataList[ObjectIndex];
  if Values = nil then
  begin
    Item := ScreenObject.ImportedValues.Add as TValueArrayItem;
    Item.Name := DataSet.Name;
    Values := Item.Values;
    Values.DataType := DataSet.DataType;
    Values.Count := ScreenObject.Capacity;
  end;
end;

procedure TfrmImportGriddedData.GetElevations(
  var Elevations: TValueArrayStorage; DataSet: TDataArray;
  ScreenObject: TScreenObject);
begin
  if DataSet.Orientation = dso3D then
  begin
    Elevations := ScreenObject.ImportedSectionElevations;
    Elevations.Count := ScreenObject.Capacity;
  end
  else
  begin
    Elevations := nil;
  end;
end;

procedure TfrmImportGriddedData.GetLocation(var Point2D: TPoint2D; var APoint: T3DRealPoint; Column: Integer; Row: Integer; Layer: Integer; DataSet: TDataArray);
var
  ViewDirection: TViewDirection;
begin
  case DataSet.EvaluatedAt of
    eaBlocks:
      begin
        APoint := frmGoPhast.Grid.ThreeDElementCenter(Column, Row, Layer);
      end;
    eaNodes:
      begin
        APoint := frmGoPhast.Grid.ThreeDElementCorner(Column, Row, Layer);
      end;
  else
    begin
      Assert(False);
    end;
  end;
  ViewDirection := OrientationToViewDirection(DataSet.Orientation);
  case ViewDirection of
    vdTop:
      begin
        Point2D.x := APoint.X;
        Point2D.y := APoint.y;
        Point2D := frmGoPhast.Grid.
          RotateFromGridCoordinatesToRealWorldCoordinates(Point2D)
      end;
    vdFront:
      begin
        Point2D.x := APoint.X;
        Point2D.y := APoint.Z;
      end;
    vdSide:
      begin
        Point2D.x := APoint.z;
        Point2D.y := APoint.Y;
      end;
  else
    Assert(False);
  end;
end;

procedure TfrmImportGriddedData.GetNodeCaption(Node: PVirtualNode;
  var CellText: WideString; Sender: TBaseVirtualTree);
var
  ClassificationNodeData: PClassificationNodeData;
begin
  ClassificationNodeData := Sender.GetNodeData(Node);
  if not Assigned(ClassificationNodeData)
    or not Assigned(ClassificationNodeData.ClassificationObject) then
  begin
    CellText := 'none';
  end
  else
  begin
    CellText := ClassificationNodeData.ClassificationObject.ClassificationName;
  end;
end;

procedure TfrmImportGriddedData.AssignValueToScreenObject(
  ScreenObject: TScreenObject; StringData: string; BooleanData: Boolean;
  IntegerData: Integer; RealData: Double;
  Column: Integer; Row: Integer; Layer: Integer; DataSet: TDataArray);
var
  APoint: T3DRealPoint;
  Point2D: TPoint2D;
  Elevations: TValueArrayStorage;
  Values: TValueArrayStorage;
begin
  GetValues(Values, DataSet, ScreenObject);
  GetElevations(Elevations, DataSet, ScreenObject);
  GetLocation(Point2D, APoint, Column, Row, Layer, DataSet);
  ScreenObject.AddPoint(Point2D, True);
  case DataSet.DataType of
    rdtDouble:
      Values.RealValues[ScreenObject.Count - 1] := RealData;
    rdtInteger:
      Values.IntValues[ScreenObject.Count - 1] := IntegerData;
    rdtBoolean:
      Values.BooleanValues[ScreenObject.Count - 1] := BooleanData;
    rdtString:
      Values.StringValues[ScreenObject.Count - 1] := StringData;
  else
    Assert(False);
  end;
  if Elevations <> nil then
  begin
    Elevations.RealValues[ScreenObject.Count - 1] := APoint.Z;
  end;
end;

procedure TfrmImportGriddedData.GetColRowLayerFromGrid(Grid: TRbwDataGrid4;
  ColIndex, RowIndex, GridIndex: Integer; out Column, Row, Layer: Integer;
  DataSet: TDataArray);
begin
  try
    case DataSet.Orientation of
      dsoTop:
        begin
          case frmGoPhast.ModelSelection of
            msUndefined:
              begin
                Assert(False);
              end;
            msPhast:
              begin
                Column := ColIndex;
                Row := Grid.ColCount - RowIndex;
                Layer := 1;
              end;
            msModflow:
              begin
                Column := ColIndex;
                Row := RowIndex;
                Layer := 1;
              end;
          else
            Assert(False);
          end;
        end;
      dsoFront:
        begin
          case frmGoPhast.ModelSelection of
            msUndefined:
              begin
                Assert(False);
              end;
            msPhast:
              begin
                Column := ColIndex;
                Row := 1;
                Layer := Grid.RowCount - RowIndex;
              end;
            msModflow:
              begin
                Column := ColIndex;
                Row := 1;
                Layer := RowIndex;
              end;
          else
            Assert(False);
          end;
        end;
      dsoSide:
        begin
          case frmGoPhast.ModelSelection of
            msUndefined:
              begin
                Assert(False);
              end;
            msPhast:
              begin
                Column := 1;
                Row := ColIndex;
                Layer := Grid.RowCount - RowIndex;
              end;
            msModflow:
              begin
                Column := 1;
                Row := Grid.ColCount - ColIndex;
                Layer := RowIndex;
              end;
          else
            Assert(False);
          end;
        end;
      dso3D:
        begin
          case frmGoPhast.ModelSelection of
            msUndefined:
              begin
                Assert(False);
              end;
            msPhast:
              begin
                Column := ColIndex;
                Row := Grid.ColCount - RowIndex;
                Layer := GridIndex + 1;
              end;
            msModflow:
              begin
                Column := ColIndex;
                Row := RowIndex;
                Layer := GridIndex + 1;
              end;
          else
            Assert(False);
          end;
        end;
    else
      Assert(False);
    end;
  finally
    Dec(Layer);
    Dec(Row);
    Dec(Column);
  end;
end;

function TfrmImportGriddedData.ReadDataFromGrid(Grid: TRbwDataGrid4;
  DataSet: TDataArray; ColIndex, RowIndex: Integer; var RealData: Double;
  var IntegerData: Integer; var BooleanData: Boolean;
  var StringData: string): Boolean;
begin
  result := True;
  case DataSet.DataType of
    rdtDouble:
      begin
        if not TryStrToFloat(Grid.Cells[ColIndex, RowIndex], RealData) then
        begin
          result := False;
        end;
        if IsIgnoredRealValue(RealData) then
        begin
          result := False;
        end;
      end;
    rdtInteger:
      begin
        if not TryStrToInt(Grid.Cells[ColIndex, RowIndex], IntegerData) then
        begin
          result := False;
        end;
        if IsIgnoredIntegerValue(IntegerData) then
        begin
          result := False;
        end;
      end;
    rdtBoolean:
      begin
        BooleanData := Grid.Checked[ColIndex, RowIndex];
        if IsIgnoredBooleanValue(BooleanData) then
        begin
          result := False;
        end;
      end;
    rdtString:
      begin
        StringData := Grid.Cells[ColIndex, RowIndex];
        if (StringData = '') or IsIgnoredStringValue(StringData) then
        begin
          result := False;
        end;
      end;
  else
    Assert(False);
  end;
end;

procedure TfrmImportGriddedData.InitializeScreenObject(
  var ScreenObject: TScreenObject; Layer: Integer; ScreenObjectList: TList;
  DataSet: TDataArray);
var
  ObjectIndex: Integer;
begin
  if DataSet.Orientation = dso3D then
  begin
    ObjectIndex := Layer;
  end
  else
  begin
    ObjectIndex := 0;
  end;
  while ObjectIndex >= ScreenObjectList.Count do
  begin
    ScreenObjectList.Add(nil);
  end;
  ScreenObject := ScreenObjectList[ObjectIndex];
  if ScreenObject = nil then
  begin
    CreateAScreenObject(DataSet, ScreenObjectList, ScreenObject, ObjectIndex);
  end;
end;

procedure TfrmImportGriddedData.FinalizeScreenObjects(ScreenObjectList: TList;
  DataSet: TDataArray);
var
  Values: TValueArrayStorage;
  ScreenObjectIndex: Integer;
  ScreenObject: TScreenObject;
begin
  ScreenObjectList.Pack;
  for ScreenObjectIndex := 0 to ScreenObjectList.Count - 1 do
  begin
    ScreenObject := ScreenObjectList[ScreenObjectIndex];
    ScreenObject.Capacity := ScreenObject.Count;
    Values := ScreenObject.ImportedValues.ValuesByName(DataSet.Name);
    Values.Count := ScreenObject.Count;
    if DataSet.Orientation = dso3D then
    begin
      ScreenObject.ImportedSectionElevations.Count := ScreenObject.Count;
    end;
  end;
end;

procedure TfrmImportGriddedData.GetGridCount(DataSet: TDataArray; var Limit: Integer);
begin
  // Gridded data
  Limit := 0;
  case DataSet.Orientation of
    dsoTop, dsoFront, dsoSide:
      begin
        Limit := 1;
      end;
    dso3D:
      begin
        case DataSet.EvaluatedAt of
          eaBlocks:
            begin
              Limit := DataSet.LayerCount;
            end;
          eaNodes:
            begin
              Limit := DataSet.LayerCount + 1;
            end;
        else
          Assert(False);
        end;
      end;
  else
    Assert(False);
  end;
end;

procedure TfrmImportGriddedData.SetData;
var
  DataArray: TDataArray;
  ScreenObjectList: TList;
  RowIndex: Integer;
  Layer, Row, Column: integer;
  RealData: double;
  StringData: string;
  BooleanData: boolean;
  IntegerData: integer;
  ScreenObject: TScreenObject;
  Undo: TUndoImportGriddedData;
  Limit: Integer;
  GridIndex: Integer;
  Grid: TRbwDataGrid4;
  ColIndex: Integer;
  AnObject: TObject;
begin
  RetrieveSelectedObject(AnObject);
  DataArray := AnObject as TDataArray;
  if DataArray = nil then
  begin
    Exit;
  end;
  StoreIgnoredValues(DataArray);

  ScreenObjectList := TList.Create;
  try
    case jvplCellGrid.ActivePageIndex of
      0:
        begin
          // List
          for RowIndex := 1 to rdgList.RowCount - 1 do
          begin
            if not ReadOneRow(DataArray, RowIndex, Layer, Row, Column,
              RealData, IntegerData, BooleanData, StringData) then
            begin
              Continue;
            end;
            InitializeScreenObject(ScreenObject, Layer, ScreenObjectList, DataArray);
            AssignValueToScreenObject(ScreenObject, StringData, BooleanData,
              IntegerData, RealData, Column, Row, Layer, DataArray);
          end;
        end;
      1:
        begin
          GetGridCount(DataArray, Limit);
          for GridIndex := 0 to Limit - 1 do
          begin
            Grid := FGrids[GridIndex];
            for RowIndex := 1 to Grid.RowCount - 1 do
            begin
              for ColIndex := 1 to Grid.ColCount - 1 do
              begin
                if not ReadDataFromGrid(Grid, DataArray, ColIndex, RowIndex,
                  RealData, IntegerData, BooleanData, StringData) then
                begin
                  Continue;
                end;
                GetColRowLayerFromGrid(Grid, ColIndex, RowIndex, GridIndex,
                  Column, Row, Layer, DataArray);
                InitializeScreenObject(ScreenObject, Layer,
                  ScreenObjectList, DataArray);
                AssignValueToScreenObject(ScreenObject, StringData,
                  BooleanData, IntegerData, RealData,
                  Column, Row, Layer, DataArray);
              end;
            end;
          end;
        end;
      else Assert(False);
    end;
    FinalizeScreenObjects(ScreenObjectList, DataArray);
    if ScreenObjectList.Count > 0 then
    begin
      Undo := TUndoImportGriddedData.Create;
      Undo.StoreNewScreenObjects(ScreenObjectList);
      frmGoPhast.UndoStack.Submit(Undo);
    end;
  finally
    ScreenObjectList.Free;
  end;
end;

procedure TfrmImportGriddedData.SetSelectedNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  CellText: WideString;
begin
  if Sender.Selected[Node] and Sender.HasChildren[Node] then
  begin
    Sender.Selected[Node] := False;
    Sender.FocusedNode := nil;
    combotreeDataSets.Text := '';
  end;
  if Sender.Selected[Node] then
  begin
    FSelectedVirtNode := Node;
    GetNodeCaption(Node, CellText, Sender);
    combotreeDataSets.Text := CellText;
  end
  else
  begin
    FSelectedVirtNode := nil;
  end;
  btnOk.Enabled := SelectedVirtNode <> nil;
end;

procedure TfrmImportGriddedData.seIgnoreValueCountChange(Sender: TObject);
begin
  inherited;
  if seIgnoreValueCount.AsInteger = 0 then
  begin
    rdgIgnoreValues.RowCount := 2;
  end
  else
  begin
    rdgIgnoreValues.RowCount := seIgnoreValueCount.AsInteger + 1;
  end;
end;

procedure TfrmImportGriddedData.InitializeGridForGriddedData(
  Grid: TRbwDataGrid4; ColumnFormat: TRbwColumnFormat4;
  ColumnsForward, RowsForward: Boolean);
var
  ColIndex: Integer;
  RowIndex: Integer;
  ClearColumn: Boolean;
begin
  Grid.Align := alClient;
  for ColIndex := 1 to Grid.ColCount - 1 do
  begin
    ClearColumn := Grid.Columns[ColIndex].Format <> ColumnFormat;
    Grid.Columns[ColIndex].Format := ColumnFormat;
    if ColumnsForward then
    begin
      Grid.Cells[ColIndex, 0] := IntToStr(ColIndex);
    end
    else
    begin
      Grid.Cells[ColIndex, 0] := IntToStr(Grid.ColCount - ColIndex);
    end;
    if ClearColumn then
    begin
      for RowIndex := 1 to Grid.RowCount - 1 do
      begin
        Grid.Cells[ColIndex, RowIndex] := '';
      end;
    end;
  end;
  for RowIndex := 1 to Grid.RowCount - 1 do
  begin
    if RowsForward then
    begin
      Grid.Cells[0, RowIndex] := IntToStr(RowIndex);
    end
    else
    begin
      Grid.Cells[0, RowIndex] := IntToStr(Grid.RowCount - RowIndex);
    end;
  end;
end;

procedure TfrmImportGriddedData.InitializeGridForCellList(DataSet: TDataArray);
var
  ClearColumn: Boolean;
  RowIndex: Integer;
  Index: Integer;
  MaxCol, MaxRow, MaxLayer: integer;
begin
  MaxCol := -1;
  MaxRow := -1;
  MaxLayer := -1;
  case DataSet.EvaluatedAt of
    eaBlocks:
      begin
        MaxCol := DataSet.ColumnCount;
        MaxRow := DataSet.RowCount;
        MaxLayer := DataSet.LayerCount;
      end;
    eaNodes:
      begin
        MaxCol := DataSet.ColumnCount+1;
        MaxRow := DataSet.RowCount+1;
        MaxLayer := DataSet.LayerCount+1;
      end;
    else Assert(False);
  end;
  case DataSet.Orientation of
    dsoTop:
      begin
        rdgList.ColCount := 4;
        rdgList.Cells[0, 0] := 'N';
        rdgList.Cells[1, 0] := 'Row';
        rdgList.Cells[2, 0] := 'Column';
        rdgList.Cells[3, 0] := DataSet.Name;

        rdgList.Columns[1].Format := rcf4Integer;
        rdgList.Columns[1].CheckMin := True;
        rdgList.Columns[1].CheckMax := True;
        rdgList.Columns[1].Min := 1;
        rdgList.Columns[1].Max := MaxRow;

        rdgList.Columns[2].Format := rcf4Integer;
        rdgList.Columns[2].CheckMin := True;
        rdgList.Columns[2].CheckMax := True;
        rdgList.Columns[2].Min := 1;
        rdgList.Columns[2].Max := MaxCol;

        rdgList.Columns[3].Format := ConvertDataFormat(DataSet.DataType);
      end;
    dsoFront:
      begin
        rdgList.ColCount := 4;
        rdgList.Cells[0, 0] := 'N';
        rdgList.Cells[1, 0] := 'Layer';
        rdgList.Cells[2, 0] := 'Column';
        rdgList.Cells[3, 0] := DataSet.Name;

        rdgList.Columns[1].Format := rcf4Integer;
        rdgList.Columns[1].CheckMin := True;
        rdgList.Columns[1].CheckMax := True;
        rdgList.Columns[1].Min := 1;
        rdgList.Columns[1].Max := MaxLayer;

        rdgList.Columns[2].Format := rcf4Integer;
        rdgList.Columns[2].CheckMin := True;
        rdgList.Columns[2].CheckMax := True;
        rdgList.Columns[2].Min := 1;
        rdgList.Columns[2].Max := MaxCol;

        rdgList.Columns[3].Format := ConvertDataFormat(DataSet.DataType);
      end;
    dsoSide:
      begin
        rdgList.ColCount := 4;
        rdgList.Cells[0, 0] := 'N';
        rdgList.Cells[1, 0] := 'Layer';
        rdgList.Cells[2, 0] := 'Row';
        rdgList.Cells[3, 0] := DataSet.Name;

        rdgList.Columns[1].Format := rcf4Integer;
        rdgList.Columns[1].CheckMin := True;
        rdgList.Columns[1].CheckMax := True;
        rdgList.Columns[1].Min := 1;
        rdgList.Columns[1].Max := MaxLayer;

        rdgList.Columns[2].Format := rcf4Integer;
        rdgList.Columns[2].CheckMin := True;
        rdgList.Columns[2].CheckMax := True;
        rdgList.Columns[2].Min := 1;
        rdgList.Columns[2].Max := MaxRow;

        rdgList.Columns[3].Format := ConvertDataFormat(DataSet.DataType);
      end;
    dso3D:
      begin
        rdgList.ColCount := 5;
        rdgList.Cells[0, 0] := 'N';
        rdgList.Cells[1, 0] := 'Layer';
        rdgList.Cells[2, 0] := 'Row';
        rdgList.Cells[3, 0] := 'Column';
        rdgList.Cells[4, 0] := DataSet.Name;

        rdgList.Columns[1].Format := rcf4Integer;
        rdgList.Columns[1].CheckMin := True;
        rdgList.Columns[1].CheckMax := True;
        rdgList.Columns[1].Min := 1;
        rdgList.Columns[1].Max := MaxLayer;

        rdgList.Columns[2].Format := rcf4Integer;
        rdgList.Columns[2].CheckMin := True;
        rdgList.Columns[2].CheckMax := True;
        rdgList.Columns[2].Min := 1;
        rdgList.Columns[2].Max := MaxRow;

        ClearColumn := rdgList.Columns[3].Format <> rcf4Integer;
        rdgList.Columns[3].Format := rcf4Integer;
        if ClearColumn then
        begin
          for RowIndex := 1 to rdgList.RowCount - 1 do
          begin
            rdgList.Cells[3, RowIndex] := '';
          end;
        end;
        rdgList.Columns[3].CheckMin := True;
        rdgList.Columns[3].CheckMax := True;
        rdgList.Columns[3].Min := 1;
        rdgList.Columns[3].Max := MaxCol;

        ClearColumn := rdgList.Columns[4].Format <>
          ConvertDataFormat(DataSet.DataType);
        rdgList.Columns[4].Format := ConvertDataFormat(DataSet.DataType);
        if ClearColumn then
        begin
          for RowIndex := 1 to rdgList.RowCount - 1 do
          begin
            rdgList.Cells[4, RowIndex] := '';
          end;
        end;
      end;
  else
    begin
      Assert(False);
    end;
  end;
  rdgList.Cells[0, 1] := '1';
  for Index := 0 to rdgList.ColCount - 1 do
  begin
    rdgList.Columns[Index].AutoAdjustColWidths := True;
  end;
end;

procedure TfrmImportGriddedData.comboMethodChange(Sender: TObject);
begin
  inherited;
  AssignDataSetValue;
end;

procedure TfrmImportGriddedData.combotreeDataSetsDropDownTreeChange(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  inherited;
  SetSelectedNode(Sender, Node);
  AssignDataSetValue;
end;

procedure TfrmImportGriddedData.combotreeDataSetsDropDownTreeGetNodeDataSize(
  Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  inherited;
  NodeDataSize := SizeOf(TClassificationNodeData); 
end;

procedure TfrmImportGriddedData.combotreeDataSetsDropDownTreeGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
begin
  inherited;
  GetNodeCaption(Node, CellText, Sender);
end;

procedure TfrmImportGriddedData.FormCreate(Sender: TObject);
begin
  inherited;
  FGrids := TObjectList.Create;
  FStoredClassifications := TObjectList.Create;

  rdgIgnoreValues.Cells[0,0] := 'Values to ignore';
  GetData;
end;

procedure TfrmImportGriddedData.FormDestroy(Sender: TObject);
begin
  inherited;
  FStoredClassifications.Free;
  FGrids.Free;
end;

procedure TfrmImportGriddedData.FormResize(Sender: TObject);
begin
  inherited;
  lblColumns.Left := (jvspGrid.Width - lblColumns.Width) div 2;
  lblRows.Top := (jvspGrid.Height - lblRows.Height) div 2;
end;

procedure TfrmImportGriddedData.btnOKClick(Sender: TObject);
begin
  inherited;
  SetData;
end;


{ TUndoImportGriddedData }

function TUndoImportGriddedData.Description: string;
begin
  result := 'import gridded data';
end;

procedure TUndoImportGriddedData.DoCommand;
begin
  frmGoPhast.CanDraw := False;
  try
    UnDeleteNewScreenObjects;
  finally
    frmGoPhast.CanDraw := True;
  end;
  FShouldUpdateShowHideObjects := True;
  frmGoPhast.PhastModel.FormulaManager.Pack;
  inherited;
end;

procedure TUndoImportGriddedData.Redo;
begin
  DoCommand;
  FShouldUpdateShowHideObjects := True;
  inherited;
end;

procedure TUndoImportGriddedData.Undo;
begin
  frmGoPhast.CanDraw := False;
  try
    DeleteNewScreenObjects;
  finally
    frmGoPhast.CanDraw := True;
  end;
  FShouldUpdateShowHideObjects := True;
  frmGoPhast.PhastModel.FormulaManager.Pack;
  inherited;
end;

end.
