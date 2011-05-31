{@abstract(@name is used define @link(TCustomLayerRowColumnSelector)
  which is an abstract base class whose descendants handle
  changes of the selected column, row, or layer.)}
unit ColRowLayerChangeUnit;

interface

{ TODO : 
Make a UML sequence diagram illustrating the process of changing a 
column, row, or layer and how that causes the grid to be redrawn on the 
2D and 3D views. }

uses SysUtils, Classes, Controls, ExtCtrls, RbwModelCube, GoPhastTypes,
  DataSetUnit;

type
  // when clicking on TframeView.@link(TframeView.ModelCube),
  // @name is used to indicate how much to change the selected
  // layer, row, or column.
  // @Value(jtSmall = change by 1.)
  // @Value(jtBig = change by 10.)
  // @Value(jtToMouse = change to the mouse position.)
  TJumpType = (jtSmall, jtBig, jtToMouse);

  {@abstract(@name is an abstract base class whose descendants handle
    changes of the selected column, row, or layer.)}
  TCustomLayerRowColumnSelector = class(TComponent)
  private
    // @name records X-coordinate of the mouse over @link(FModelCube)
    // as set in @link(MouseDown), @link(MouseMove) or @link(MouseUp).
    FCubeX: integer;
    // @name records Y-coordinate of the mouse over @link(FModelCube)
    // as set in @link(MouseDown), @link(MouseMove) or @link(MouseUp).
    FCubeY: integer;
    // @name records how the selected layer, row, or column is supposed
    // to change.
    // @seealso(TJumpType).
    FJumpType: TJumpType;
    // @name is the TRbwModelCube on the @link(TframeView) to which this
    // @classname applies.
    FModelCube: TRbwModelCube;
    // @name is the event-handler for @link(Timer).OnTimer.
    // It calls @link(ChangeSelectedItem) and sets the interval to 100 ms.
    procedure ChangeColRowLayer(Sender: TObject);
    // @name sets @link(FJumpType), @link(FCubeX), and @link(FCubeY).
    // Then it sets frmGoPhast.@link(Timer).OnTimer
    // to @link(ChangeColRowLayer)
    // and starts the timer with an initial interval of 1000 ms.
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    // @name displays the selected layer, row, or column
    // and updates @link(FCubeX) and @link(FCubeY).
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    // @name sets @link(FJumpType), @link(FCubeX), and @link(FCubeY).
    // It may also call @link(ChangeSelectedItem) if Timer.OnTimer
    // has never been called.
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    // See @link(Timer).
    function GetTimer: TTimer;
  protected
    // @name changes the column, row, or layer.
    procedure ChangeSelectedItem; virtual; abstract;
    // @name get the data set that is being displayed on the
    // top, front, or side view of the model.
    function GetViewDataSet: TDataArray; virtual; abstract;
    // @name acts as a class variable. It accesses a variable defined in
    // the implementation section outside of any class.
    property Timer: TTimer read GetTimer;
  public
    // @name creates an instance of @classname.
    // AOwner must be a TframeView.
    // @name sets @link(FModelCube) and sets FModelCube's event-handlers
    // for OnMouseDown, OnMouseMove, and OnMouseUp events to
    // @link(MouseDown), @link(MouseMove), and @link(MouseUp).
    constructor Create(AOwner: TComponent); override;
    // @name displays which column, row, or layer is selected on the
    // status bar of @link(frmGoPhast).
    procedure DisplayItem; virtual; abstract;
    // @name determines whether the grid is to be evaluated at block centers
    // or nodes.  This is important because it affects how high the
    // selected column, row, or layer can be.
    function EvaluatedAt: TEvaluatedAt;
    // @name is used as an event handler for
    // TCustomGrid.@link(TCustomGrid.OnSelectedColumnChange),
    // TCustomGrid.@link(TCustomGrid.OnSelectedLayerChange),
    // and TCustomGrid.@link(TCustomGrid.OnSelectedRowChange).
    procedure ItemChange(Sender: TObject); virtual; abstract;
    // @name is a factory method that
    // creates a descendant of @classname depending on ViewDirection.
    class function New(const Owner: TComponent;
      const ViewDirection: TViewDirection): TCustomLayerRowColumnSelector;
  end;

  {@abstract(@name handles changes in the selected row.)}
  TRowSelector = class(TCustomLayerRowColumnSelector)
  private
    // @name changes the selected row.
    procedure ChangeRow;
    // @name displays the selected row on the status bar.
    procedure DisplayRow;
    // @name is used to change how the row is displayed in
    // TCustomLayerRowColumnSelector.@link(
    // TCustomLayerRowColumnSelector.FModelCube).
    procedure RowHasChanged;
  protected
    // @name changes the selected row by calling @link(ChangeRow).
    procedure ChangeSelectedItem; override;
    // @name gets the @link(TDataArray)
    // used to color the front view of the grid.
    function GetViewDataSet: TDataArray; override;
  public
    // @name calls @link(DisplayRow).
    procedure DisplayItem; override;
    // @name is used as an event handler for
    // TCustomGrid.@link(TCustomGrid.OnSelectedRowChange).
    procedure ItemChange(Sender: TObject); override;
  end;

  {@abstract(@name handles changes in the selected layer.)}
  TLayerSelector = class(TCustomLayerRowColumnSelector)
  private
    // @name changes the selected layer.
    procedure ChangeLayer;
    // @name displays the selected layer on the status bar.
    procedure DisplayLayer;
    // @name is used to change how the layer is displayed in
    // TCustomLayerRowColumnSelector.@link(
    // TCustomLayerRowColumnSelector.FModelCube).
    procedure LayerHasChanged;
  protected
    // @name changes the selected layer by calling @link(ChangeLayer).
    procedure ChangeSelectedItem; override;
    // @name gets the @link(TDataArray) used to color the top view of the grid.
    function GetViewDataSet: TDataArray; override;
  public
    // @name calls @link(DisplayLayer).
    procedure DisplayItem; override;
    // @name is used as an event handler for
    // TCustomGrid.@link(TCustomGrid.OnSelectedLayerChange).
    procedure ItemChange(Sender: TObject); override;
  end;

implementation

uses frmGoPhastUnit, frameViewUnit, ScreenObjectUnit, PhastModelUnit;

type
  {@abstract(@name handles changes in the selected column.)}
  TColumnSelector = class(TCustomLayerRowColumnSelector)
  private
    // @name changes the selected column.
    procedure ChangeColumn;
    // @name is used to change how the column is displayed in
    // TCustomLayerRowColumnSelector.@link(
    // TCustomLayerRowColumnSelector.FModelCube).
    procedure ColumnHasChanged;
    // @name displays the selected column on the status bar.
    procedure DisplayColumn;
  protected
    // @name changes the selected column by calling @link(ChangeColumn).
    procedure ChangeSelectedItem; override;
    // @name gets the @link(TDataArray)
    // used to color the side view of the grid.
    function GetViewDataSet: TDataArray; override;
  public
    // @name calls @link(DisplayColumn).
    procedure DisplayItem; override;
    // @name is used as an event handler for
    // TCustomGrid.@link(TCustomGrid.OnSelectedColumnChange).
    procedure ItemChange(Sender: TObject); override;
  end;


var
  // SelectionTimer acts like a class variable for all instances of
  // TCustomLayerRowColumnSelector or its descendants.
  // See TCustomLayerRowColumnSelector.Timer.
  SelectionTimer: TTimer;

{ TCustomLayerRowColumnSelector }

procedure TCustomLayerRowColumnSelector.ChangeColRowLayer(Sender: TObject);
begin
  // See MouseDown
  ChangeSelectedItem;
  Timer.Interval := 100;
end;

constructor TCustomLayerRowColumnSelector.Create(AOwner: TComponent);
begin
  inherited;
  FModelCube := (AOwner as TframeView).ModelCube;
  FModelCube.OnMouseDown := MouseDown;
  FModelCube.OnMouseMove := MouseMove;
  FModelCube.OnMouseUp := MouseUp;
end;

function TCustomLayerRowColumnSelector.EvaluatedAt: TEvaluatedAt;
var
  ViewDataSet: TDataArray;
begin
  ViewDataSet := GetViewDataSet;

  if ViewDataSet = nil then
  begin
    result := eaBlocks;
  end
  else
  begin
    result := ViewDataSet.EvaluatedAt;
  end;
end;

function TCustomLayerRowColumnSelector.GetTimer: TTimer;
begin
  result := SelectionTimer;
end;

procedure TCustomLayerRowColumnSelector.MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // This procedure sets FJumpType, FCubeX, and FCubeY.
  // Then it sets frmGoPhast.Timer.OnTimer to ChangeColRowLayer
  // and starts the timer.
  FJumpType := jtSmall;
  if ssShift in Shift then
  begin
    FJumpType := jtBig;
  end;
  FCubeX := X;
  FCubeY := Y;
  Timer.Interval := 1000;
  Timer.OnTimer := ChangeColRowLayer;
  Timer.Enabled := True;
end;

procedure TCustomLayerRowColumnSelector.MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  //This procedure displays the selected layer, row, or column
  // and updates FCubeX and FCubeY.
  DisplayItem;
  FCubeX := X;
  FCubeY := Y;
end;

procedure TCustomLayerRowColumnSelector.MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FJumpType := jtSmall;
  if ssCtrl in Shift then
  begin
    FJumpType := jtToMouse;
  end
  else if ssShift in Shift then
  begin
    FJumpType := jtBig;
  end;
  FCubeX := X;
  FCubeY := Y;

  Timer.Enabled := False;
  // If Timer.Interval is still 1000,
  // the Timer.OnTimer event has never occurred because
  // it sets the Timer.Interval to 100.
  if Timer.Interval = 1000 then
  begin
    // Change the column, row, or layer.
    ChangeSelectedItem;
  end;
  FJumpType := jtSmall;
end;

class function TCustomLayerRowColumnSelector.New(const Owner: TComponent;
  const ViewDirection: TViewDirection): TCustomLayerRowColumnSelector;
begin
  result := nil;
  case ViewDirection of
    vdTop:
      begin
        result := TLayerSelector.Create(Owner);
      end;
    vdFront:
      begin
        result := TRowSelector.Create(Owner);
      end;
    vdSide:
      begin
        result := TColumnSelector.Create(Owner);
      end;
  else Assert(False);
  end;
end;

{ TColumnSelector }

procedure TColumnSelector.ColumnHasChanged;
var
  LocalModel: TPhastModel;
  ColumnCount: Integer;
begin
    // @name is used to change how the column is displayed in
    // TCustomLayerRowColumnSelector.@link(
    // TCustomLayerRowColumnSelector.FModelCube).
  if frmGoPhast.Grid <> nil then
  begin
    LocalModel := frmGoPhast.PhastModel;
    ColumnCount := LocalModel.CombinedColumnCount;
    if LocalModel.CombinedColumnCount <= 0 then
    begin
      FModelCube.Selection2 := 0;
      FModelCube.Selection1 := 0;
    end
    else
    begin
      case EvaluatedAt of
        eaBlocks:
          begin
            FModelCube.Selection2 := (LocalModel.CombinedDisplayColumn + 1) / (ColumnCount);
            FModelCube.Selection1 := (LocalModel.CombinedDisplayColumn) / (ColumnCount);
          end;
        eaNodes:
          begin
            FModelCube.Selection2 := (LocalModel.CombinedDisplayColumn) / (ColumnCount);
            FModelCube.Selection1 := FModelCube.Selection2;
          end;
      else
        Assert(False);
      end;
    end;
  end;
  frmGoPhast.TopGridChanged := True;
  frmGoPhast.FrontGridChanged := True;
  frmGoPhast.SideGridChanged := True;
  frmGoPhast.frame3DView.glWidModelView.Invalidate;
  (Owner as TframeView).NeedToRecalculateCellColors := True;
end;


procedure TColumnSelector.ChangeSelectedItem;
begin
  ChangeColumn;
end;

procedure TColumnSelector.DisplayItem;
begin
  DisplayColumn;
end;

procedure TColumnSelector.ChangeColumn;
var
  ClickDirection: TRbwClickDirection;
  Increment: integer;
  Done: boolean;
  PriorColumn: integer;
begin
  // Change the selected column.
  if FJumpType = jtBig then
  begin
    Increment := 10;
  end
  else
  begin
    Increment := 1;
  end;
  ClickDirection := FModelCube.ClickDirection(FCubeX, FCubeY);
  Done := False;
  while not Done do
  begin
    PriorColumn := frmGoPhast.PhastModel.CombinedDisplayColumn;
    if FModelCube.XOrigin = xoWest then
    begin
      if ClickDirection = cdWest then
      begin
        frmGoPhast.PhastModel.CombinedDisplayColumn :=
          frmGoPhast.PhastModel.CombinedDisplayColumn - Increment;
      end
      else if ClickDirection = cdEast then
      begin
        frmGoPhast.PhastModel.CombinedDisplayColumn :=
          frmGoPhast.PhastModel.CombinedDisplayColumn
          + Increment;
      end;
    end
    else
    begin
      if ClickDirection = cdWest then
      begin
        frmGoPhast.PhastModel.CombinedDisplayColumn :=
          frmGoPhast.PhastModel.CombinedDisplayColumn
          + Increment;
      end
      else if ClickDirection = cdEast then
      begin
        frmGoPhast.PhastModel.CombinedDisplayColumn :=
          frmGoPhast.PhastModel.CombinedDisplayColumn
          - Increment;
      end;
    end;
    if FJumpType = jtToMouse then
    begin
      Done := (PriorColumn = frmGoPhast.PhastModel.CombinedDisplayColumn) or
        (ClickDirection <> FModelCube.ClickDirection(FCubeX, FCubeY));
    end
    else
    begin
      Done := True;
    end;
  end;

  DisplayItem;
end;

procedure TColumnSelector.DisplayColumn;
begin
  // Display the column that is selected.
  frmGoPhast.sbMain.Panels[1].Text := 'Selected Col: '
    + IntToStr(frmGoPhast.Grid.SelectedColumn + 1);
end;

procedure TColumnSelector.ItemChange(Sender: TObject);
begin
  ColumnHasChanged;
end;

function TColumnSelector.GetViewDataSet: TDataArray;
begin
  if frmGoPhast.Grid = nil then
  begin
    result := nil;
  end
  else
  begin
    result := frmGoPhast.Grid.SideDataSet;
  end;
end;

{ TRowSelector }

procedure TRowSelector.RowHasChanged;
var
  RowCount: Integer;
  LocalModel: TPhastModel;
begin
  if frmGoPhast.Grid <> nil then
  begin
    LocalModel := frmGoPhast.PhastModel;
    RowCount := LocalModel.CombinedRowCount;
    if RowCount <= 0 then
    begin
      FModelCube.Selection2 := 0;
      FModelCube.Selection1 := 0;
    end
    else
    begin
      case EvaluatedAt of
        eaBlocks:
          begin
            FModelCube.Selection2 := (LocalModel.CombinedDisplayRow + 1) / (RowCount);
            FModelCube.Selection1 := (LocalModel.CombinedDisplayRow) / (RowCount);
          end;
        eaNodes:
          begin
            FModelCube.Selection2 := (LocalModel.CombinedDisplayRow) / (RowCount);
            FModelCube.Selection1 := FModelCube.Selection2;
          end;
      else
        Assert(False);
      end;
    end;
  end;

  frmGoPhast.TopGridChanged := True;
  frmGoPhast.FrontGridChanged := True;
  frmGoPhast.SideGridChanged := True;
  frmGoPhast.frame3DView.glWidModelView.Invalidate;
  (Owner as TframeView).NeedToRecalculateCellColors := True;
end;

procedure TRowSelector.ChangeSelectedItem;
begin
  ChangeRow;
end;

procedure TRowSelector.DisplayItem;
begin
  DisplayRow;
end;

procedure TRowSelector.ChangeRow;
var
  ClickDirection: TRbwClickDirection;
  Increment: integer;
  Done: boolean;
  PriorRow: integer;
begin
  if FJumpType = jtBig then
  begin
    Increment := 10;
  end
  else
  begin
    Increment := 1;
  end;
  ClickDirection := FModelCube.ClickDirection(FCubeX, FCubeY);
  Done := False;
  while not Done do
  begin
    PriorRow := frmGoPhast.PhastModel.CombinedDisplayRow;
    if FModelCube.YOrigin = yoSouth then
    begin
      if ClickDirection = cdNorth then
      begin
        frmGoPhast.PhastModel.CombinedDisplayRow := frmGoPhast.PhastModel.CombinedDisplayRow +
          Increment;
      end
      else if ClickDirection = cdSouth then
      begin
        frmGoPhast.PhastModel.CombinedDisplayRow := frmGoPhast.PhastModel.CombinedDisplayRow -
          Increment;
      end;
    end
    else
    begin
      if ClickDirection = cdNorth then
      begin
        frmGoPhast.PhastModel.CombinedDisplayRow := frmGoPhast.PhastModel.CombinedDisplayRow -
          Increment;
      end
      else if ClickDirection = cdSouth then
      begin
        frmGoPhast.PhastModel.CombinedDisplayRow := frmGoPhast.PhastModel.CombinedDisplayRow +
          Increment;
      end;
    end;
    if FJumpType = jtToMouse then
    begin
      Done := (PriorRow = frmGoPhast.PhastModel.CombinedDisplayRow)
        or (ClickDirection <> FModelCube.ClickDirection(FCubeX, FCubeY));
    end
    else
    begin
      Done := True;
    end;
  end;
  DisplayItem;
end;

procedure TRowSelector.DisplayRow;
begin
  frmGoPhast.sbMain.Panels[1].Text := 'Selected Row: '
    + IntToStr(frmGoPhast.PhastModel.SelectedRow + 1);
end;

procedure TRowSelector.ItemChange(Sender: TObject);
begin
  RowHasChanged;
end;

function TRowSelector.GetViewDataSet: TDataArray;
begin
  if frmGoPhast.Grid = nil then
  begin
    result := nil;
  end
  else
  begin
    result := frmGoPhast.Grid.FrontDataSet;
  end;
end;

{ TLayerSelector }

procedure TLayerSelector.LayerHasChanged;
var
  LayerCount: Integer;
  LocalModel: TPhastModel;
begin
  if frmGoPhast.Grid <> nil then
  begin
    LocalModel := frmGoPhast.PhastModel;
    LayerCount := LocalModel.CombinedLayerCount;
    if LayerCount <= 0 then
    begin
      FModelCube.Selection2 := 0;
      FModelCube.Selection1 := 0;
    end
    else
    begin
      case EvaluatedAt of
        eaBlocks:
          begin
            FModelCube.Selection2 := (LocalModel.CombinedDisplayLayer + 1) / (LayerCount);
            FModelCube.Selection1 := (LocalModel.CombinedDisplayLayer) / (LayerCount);
          end;
        eaNodes:
          begin
            FModelCube.Selection2 := (LocalModel.CombinedDisplayLayer) / (LayerCount);
            FModelCube.Selection1 := FModelCube.Selection2;
          end;
      else
        Assert(False);
      end;

    end;
  end;
  frmGoPhast.TopGridChanged := True;
  frmGoPhast.FrontGridChanged := True;
  frmGoPhast.SideGridChanged := True;
  frmGoPhast.frame3DView.glWidModelView.Invalidate;
  (Owner as TframeView).NeedToRecalculateCellColors := True;
end;

procedure TLayerSelector.ChangeSelectedItem;
begin
  ChangeLayer;
end;

procedure TLayerSelector.DisplayItem;
begin
  DisplayLayer;
end;

procedure TLayerSelector.ChangeLayer;
var
  ClickDirection: TRbwClickDirection;
  Increment: integer;
  Done: Boolean;
  PriorLayer: integer;
begin
  if FJumpType = jtBig then
  begin
    Increment := 10;
  end
  else
  begin
    Increment := 1;
  end;
  ClickDirection := FModelCube.ClickDirection(FCubeX, FCubeY);

  Done := False;
  while not Done do
  begin
    PriorLayer := frmGoPhast.PhastModel.CombinedDisplayLayer;
    if FModelCube.ZOrigin = zoBottom then
    begin
      if ClickDirection = cdUp then
      begin
        frmGoPhast.PhastModel.CombinedDisplayLayer :=
          frmGoPhast.PhastModel.CombinedDisplayLayer + Increment;
      end
      else if ClickDirection = cdDown then
      begin
        frmGoPhast.PhastModel.CombinedDisplayLayer :=
          frmGoPhast.PhastModel.CombinedDisplayLayer - Increment;
      end;
    end
    else
    begin
      if ClickDirection = cdUp then
      begin
        frmGoPhast.PhastModel.CombinedDisplayLayer :=
          frmGoPhast.PhastModel.CombinedDisplayLayer - Increment;
      end
      else if ClickDirection = cdDown then
      begin
        frmGoPhast.PhastModel.CombinedDisplayLayer :=
          frmGoPhast.PhastModel.CombinedDisplayLayer + Increment;
      end;
    end;
    if FJumpType = jtToMouse then
    begin
      Done := (PriorLayer = frmGoPhast.PhastModel.CombinedDisplayLayer)
        or (ClickDirection <> FModelCube.ClickDirection(FCubeX, FCubeY));
    end
    else
    begin
      Done := True;
    end;
  end;
  DisplayItem;
end;

procedure TLayerSelector.DisplayLayer;
begin
  frmGoPhast.sbMain.Panels[1].Text := 'Selected Layer: '
    + IntToStr(frmGoPhast.PhastModel.SelectedLayer + 1);
end;

procedure TLayerSelector.ItemChange(Sender: TObject);
begin
  LayerHasChanged;
end;

function TLayerSelector.GetViewDataSet: TDataArray;
begin
  if frmGoPhast.Grid = nil then
  begin
    result := nil;
  end
  else
  begin
    result := frmGoPhast.Grid.TopDataSet;
  end;
end;

initialization
  SelectionTimer:= TTimer.Create(nil);
  SelectionTimer.Enabled := False;

finalization
  SelectionTimer.Free;

end.
