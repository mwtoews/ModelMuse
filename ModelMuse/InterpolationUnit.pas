{@abstract(@name defines concrete @link(TCustom2DInterpolater)s.)}
unit InterpolationUnit;

interface

uses PhastModelUnit, SysUtils, Classes, Controls, Dialogs, RbwParser, DataSetUnit,
  frmGoPhastUnit, ScreenObjectUnit, FastGEO, GoPhastTypes, QuadTreeClass,
  SfrInterpolatorUnit, NatNeigh;

{ TODO : 
Consider adding bilateral interpolation method for rectangular point
distributions.  Need to define a rectangular point distribution type. }

{ TODO :
Consider adding a finite element basis function interpolation method using
a Delauny triangulation. }

type
  {@abstract(@name is the abstract ancestor of interpolators that support
   anisotropy.)}
  TCustomAnisotropicInterpolator = class(TCustom2DInterpolater)
  private
    // See @link(Anisotropy).
    FAnisotropy: real;
    // See @link(Anisotropy).
    procedure SetAnisotropy(const Value: real);
    procedure GetLimits(var MinY: Real; var MaxY: Real; var MinX: Real; var MaxX: Real; const DataSet: TDataArray);
  protected
    // @name initializes the limits of @link(TRbwQuadTree QuadTree)
    // to the grid limits.
    procedure InitializeQuadTreeLimits(const QuadTree: TRbwQuadTree;
      const DataSet: TDataArray);
    // @name sets Expression and sets the values of all the
    // variables used by Expression and then evaluates
    // Expression.
    procedure InitializeVariablesAndExpression(const Location: TPoint2D;
      const AScreenObject: TScreenObject; var Expression: TExpression);
  public
    // @name copies the Anisotropy of Source to the item that call
    // @name.
    procedure Assign(Source: TPersistent); override;
    // @name creates an instance of @classname.
    constructor Create(AOwner: TComponent); override;
    // @name returns @true if AnotherInterpolator has the same parameters
    // as the @classname being called.
    function SameAs(AnotherInterpolator: TCustom2DInterpolater): boolean;
      override;
  published
    // @name is taken into account when measuring distances by multiplying
    // the Y coordinate by the anisotropy before measuring distances in
    // the normal way.
    //
    // @classname doesn't actually do anything with @name.  Descendants
    // must decide what to do with it.
    property Anisotropy: real read FAnisotropy write SetAnisotropy;
  end;

  {@abstract(@name uses inverse distance squared interpolation to return
   a real-number result.)}
  TInvDistSq2DInterpolator = class(TCustomAnisotropicInterpolator)
  public
    // @name is the name of the interpolator displayed to the user.
    class function InterpolatorName: string; override;
    // @name tells with what types of data this interpolator can be used.
    // (real numbers)
    class function ValidReturnTypes: TRbwDataTypes; override;
    // @name returns the value at location determined by inverse
    // distance squared interpolation.
    function RealResult(const Location: TPoint2D): real; override;
  end;

  {@abstract(@name implements an interpolator that returns the value
   of the @link(TScreenObject) which has a vertex closest
   to the point of interest.)}
  TCustomPoint2DInterpolator = class(TCustomAnisotropicInterpolator)
  protected
    FRealData: array of real;
    FIntegerData: array of integer;
    FBooleanData: array of boolean;
    FStringData: array of string;
    procedure SetArraySize(const DataSet: TDataArray; Count: Integer); virtual;
    procedure StoreDataValue(Count: Integer; const DataSet: TDataArray;
      APoint: TPoint2D; AScreenObject: TScreenObject); virtual; abstract;
    procedure StoreData(Sender: TObject; const DataSet: TDataArray); virtual;
  public
    // @name creates an instance of @classname and assigns
    // @link(TCustom2DInterpolater.OnInitialize).
    constructor Create(AOwner: TComponent); override;
    procedure Finalize(const DataSet: TDataArray); override;
  end;

  TNearestPoint2DInterpolator = class(TCustomPoint2DInterpolator)
  private
    // @name is used to find the closest node on an object
    // to the location of interest.
    FQuadTree: TRbwQuadTree;
    function GetPointerToResult(const Location: TPoint2D): Pointer;
  protected
    procedure SetArraySize(const DataSet: TDataArray; Count: Integer); override;
    procedure StoreData(Sender: TObject; const DataSet: TDataArray); override;
    procedure StoreDataValue(Count: Integer; const DataSet: TDataArray;
      APoint: TPoint2D; AScreenObject: TScreenObject); override;
  public
    procedure Finalize(const DataSet: TDataArray); override;
    // @name is the name of the interpolator displayed to the user.
    class function InterpolatorName: string; override;
    class function ValidReturnTypes: TRbwDataTypes; override;
    // @name gets the boolean value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function BooleanResult(const Location: TPoint2D): boolean; override;
    // @name gets the integer value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function IntegerResult(const Location: TPoint2D): integer; override;
    // @name gets the real-number value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function RealResult(const Location: TPoint2D): real; override;
    // @name gets the string value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function StringResult(const Location: TPoint2D): string; override;
    constructor Create(AOwner: TComponent); override;
  end;

  TInvDistSqPoint2DInterpolator = class(TCustomPoint2DInterpolator)
  private
    FLocations: array of TPoint2D;
  protected
    procedure SetArraySize(const DataSet: TDataArray; Count: Integer); override;
    procedure StoreDataValue(Count: Integer; const DataSet: TDataArray;
      APoint: TPoint2D; AScreenObject: TScreenObject); override;
  public
    procedure Finalize(const DataSet: TDataArray); override;
    // @name is the name of the interpolator displayed to the user.
    class function InterpolatorName: string; override;
    // @name tells with what types of data this interpolator can be used.
    // (real numbers)
    class function ValidReturnTypes: TRbwDataTypes; override;
    // @name returns the value at location determined by inverse
    // distance squared interpolation.
    function RealResult(const Location: TPoint2D): real; override;
  end;

  {@abstract(@name implements an interpolator that returns the value
   of the @link(TScreenObject) nearest to the point of interest.)}
  TNearest2DInterpolator = class(TCustomAnisotropicInterpolator)
  private
    // @name is the TExpression used to assign the result of the
    // interpolation.
    FExpression: TExpression;
    // @name is used to find the closest node on an object
    // to the location of interest.
    FQuadTree: TRbwQuadTree;
    // @name stores all the @link(TScreenObject)s
    // that set the @link(TDataArray)s
    // for this @classname by interpolation.
    FListOfTScreenObjects : TList;
    // @name gets the TExpression for the nearest @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    // sets the variable for it and evaluates it.
    // If there is no closest @link(TScreenObject), @name returns nil.
    function GetExpression(const Location: TPoint2D): TExpression;
  protected
    //  @name adds all the @link(TScreenObject)s that set
    //  DataSet by interpolation to @link(FQuadTree) at each of the
    // @link(TScreenObject)s nodes
    // and then adds all the @link(TScreenObject)
    // that set DataSet by interpolation to @link(FListOfTScreenObjects).
    procedure StoreData(Sender: TObject; const DataSet: TDataArray);
    // @name returns the @link(TScreenObject) that is closest to Location.
    // ClosestLocation is set to the location on the @link(TScreenObject)
    // that is closest to Location.
    //
    // ClosestLocation may be either at a node or along an edge of the
    // @classname.
    function GetNearestScreenObject(const Location: TPoint2D;
      out ClosestLocation: TPoint2D): TScreenObject;
  public
    procedure Finalize(const DataSet: TDataArray); override;
    // @name creates an instance of @classname and assigns
    // @link(TCustom2DInterpolater.OnInitialize).
    constructor Create(AOwner: TComponent); override;
    // @name is the name of the interpolator displayed to the user.
    class function InterpolatorName: string; override;
    // @name destroys an instance of @classname.
    destructor Destroy; override;
    // @name gets the boolean value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function BooleanResult(const Location: TPoint2D): boolean; override;
    // @name gets the integer value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function IntegerResult(const Location: TPoint2D): integer; override;
    // @name gets the real-number value at Location of the closest
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function RealResult(const Location: TPoint2D): real; override;
    // @name gets the string value at Location of the closest 
    // @link(TScreenObject)
    // that sets TCustom2DInterpolater.@link(TCustom2DInterpolater.DataSet)
    // by interpolation,
    function StringResult(const Location: TPoint2D): string; override;
    // @name tells what types of data with which this interpolator can be used.
    // (integer, real-number, boolean, and string)
    class function ValidReturnTypes: TRbwDataTypes; override;
  end;

  TCustomTriangleInterpolator = class(TCustomAnisotropicInterpolator)
  public
    function ShouldInterpolate: boolean;override;
  end;

  TNaturalNeighborInterp = class(TCustomTriangleInterpolator)
  private
    FNatNeigh: TNaturalNeighborInterpolatorTripack;
    procedure StoreData(Sender: TObject; const DataSet: TDataArray);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Finalize(const DataSet: TDataArray); override;
    destructor Destroy; override;
    class function InterpolatorName: string; override;
    class function ValidReturnTypes: TRbwDataTypes; override;
    function RealResult(const Location: TPoint2D): real; override;
  end;

  {@abstract(@name uses inverse distance squared interpolation to return
   a real-number result.)}
  TCustomSfrpackInterpolator = class(TCustomTriangleInterpolator)
  private
    FValidData: boolean;
    FSfrInterpolator: TSfrInterpolator;
  public
    // @name tells with what types of data this interpolator can be used.
    // (real numbers)
    class function ValidReturnTypes: TRbwDataTypes; override;
    procedure StoreData(Sender: TObject; const DataSet: TDataArray);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Finalize(const DataSet: TDataArray); override;
  end;

  TLinearSfrpackInterpolator = class(TCustomSfrpackInterpolator)
  public
    class function InterpolatorName: string; override;
    function RealResult(const Location: TPoint2D): real; override;
  end;

  TFittedSurfaceIntepolator = class(TCustomSfrpackInterpolator)
  public
    class function InterpolatorName: string; override;
    function RealResult(const Location: TPoint2D): real; override;
  end;

implementation

uses Math, AbstractGridUnit, RealListUnit, TripackTypes, GIS_Functions, Types;

type
  TSortRecord = record
    Location : TPoint2D;
    Value: real;
    OriginalIndex: integer;
    Duplicate: boolean;
  end;
  PSortRecord = ^TSortRecord;

function SortRecordCompare(Item1, Item2: Pointer): integer;
var
  PSort1, PSort2: PSortRecord;
  Value1, Value2: single;
begin
  PSort1 := Item1;
  PSort2 := Item2;
  // reduce precision to single precision
  Value1 := PSort1.Location.X;
  Value2 := PSort2.Location.X;
  result := Sign(Value1 - Value2);
  if result = 0 then
  begin
    // reduce precision to single precision
    Value1 := PSort1.Location.Y;
    Value2 := PSort2.Location.Y;
    result := Sign(Value1 - Value2);
    if result = 0 then
    begin
      result := PSort1.OriginalIndex - PSort2.OriginalIndex;
    end;
  end;
end;

function InvertPoint(APoint: TPoint2D): TPoint2D;
begin
  result.x := APoint.y;
  result.y := APoint.x;
end;

{ TNearest2DInterpolator }

class function TNearest2DInterpolator.InterpolatorName: string;
begin
  result := 'Nearest';
end;

destructor TNearest2DInterpolator.Destroy;
begin
  FListOfTScreenObjects.Free;
  inherited;
end;

procedure TNearest2DInterpolator.Finalize(const DataSet: TDataArray);
begin
  FQuadTree.Clear;
  FListOfTScreenObjects.Clear;
  inherited;
end;

{ TInvDistSq2DInterpolator }

class function TInvDistSq2DInterpolator.InterpolatorName: string;
begin
  result := 'Inv. Dist. Sq.';
end;

function TInvDistSq2DInterpolator.RealResult(const Location: TPoint2D):
  real;
var
  Index: integer;
  AScreenObject: TScreenObject;
  DataSetIndex: integer;
  ScreenObjectDistance: real;
  ClosestLocation: TPoint2D;
  ScreenObjectFunction: string;
  Expression: TExpression;
  VariablesUsed: TStringList;
  Cell: T3DCell;
  TopCell: T2DTopCell;
  ADataSet: TDataArray;
  VariableIndex: integer;
  Variable: TCustomValue;
  Weight: real;
  SumWeights: real;
  Sum: real;
  Value: real;
  Compiler: TRbwParser;
  InnerIndex: integer;
  ListOfScreenObjects: TList;
  LocalLocation: TPoint2D;
  LocalAnisotropy: Real;
begin
  SumWeights := 0;
  Sum := 0;

  ListOfScreenObjects := TList.Create;
  try
    FillScreenObjectList(ListOfScreenObjects);

    // Check objects in reverse order because later objects should
    // override earlier ones, so if there is a tie, the later one
    // should win.

    Assert(ListOfScreenObjects.Count > 0);
    AScreenObject := ListOfScreenObjects[0];
    LocalLocation := Location;
    LocalAnisotropy := Anisotropy;
    if AScreenObject.ViewDirection = vdSide then
    begin
      LocalLocation := InvertPoint(Location);
      LocalAnisotropy := 1/Anisotropy
    end;

    for Index := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[Index];

      DataSetIndex := AScreenObject.IndexOfDataSet(DataSet);
      Assert(DataSetIndex >= 0);

      ScreenObjectDistance := AScreenObject.DistanceToScreenObject(
        LocalLocation, ClosestLocation, LocalAnisotropy);


      ScreenObjectFunction := AScreenObject.DataSetFormulas[DataSetIndex];

      Compiler := frmGoPhast.PhastModel.GetCompiler(DataSet.Orientation,
        DataSet.EvaluatedAt);
      try
        Compiler.Compile(ScreenObjectFunction);
      except on E: ERbwParserError do
          ResetScreenObjectFunction(DataSetIndex, AScreenObject, Compiler,
            DataSet.DataType, E.Message, False);
      end;

      Expression := Compiler.CurrentExpression;
      VariablesUsed := Expression.VariablesUsed;
      if VariablesUsed.Count > 0 then
      begin
        case frmGoPhast.ModelSelection of
          msUndefined: Assert(False);
          msPhast:
            begin
              Cell := frmGoPhast.PhastGrid.GetCell(ClosestLocation,
                AScreenObject.ViewDirection, DataSet.EvaluatedAt);
            end;
          msModflow, msModflowLGR:
            begin
              TopCell := frmGoPhast.Grid.TopContainingCell(ClosestLocation,
                DataSet.EvaluatedAt);
              Cell.Col := TopCell.Col;
              Cell.Row := TopCell.Row;
              Cell.Lay := 0;
            end;
          else Assert(False);
        end;
        for InnerIndex := 0 to VariablesUsed.Count - 1 do
        begin
          ADataSet :=
            frmGoPhast.PhastModel.DataArrayManager.GetDataSetByName(VariablesUsed[InnerIndex]);
          if ADataSet <> nil then
          begin

//            ADataSet := frmGoPhast.PhastModel.DataSets[DataSetIndex];
            ADataSet.Initialize;
          end;
        end;
        for InnerIndex := 0 to VariablesUsed.Count - 1 do
        begin
          ADataSet :=
            frmGoPhast.PhastModel.DataArrayManager.GetDataSetByName(VariablesUsed[InnerIndex]);
          if ADataSet <> nil then
          begin

//            ADataSet := frmGoPhast.PhastModel.DataSets[DataSetIndex];
//            ADataSet.Initialize;
            VariableIndex := Compiler.IndexOfVariable(
              VariablesUsed[InnerIndex]);
            Variable := Compiler.Variables[VariableIndex];
            Assert(Variable.ResultType = ADataSet.DataType);
            case Variable.ResultType of
              rdtDouble:
                begin
                  TRealVariable(Variable).Value :=
                    ADataSet.RealData[Cell.Lay, Cell.Row, Cell.Col]
                end;
              rdtInteger:
                begin
                  TIntegerVariable(Variable).Value :=
                    ADataSet.IntegerData[Cell.Lay, Cell.Row, Cell.Col]
                end;
              rdtBoolean:
                begin
                  TBooleanVariable(Variable).Value :=
                    ADataSet.BooleanData[Cell.Lay, Cell.Row, Cell.Col]
                end;
              rdtString:
                begin
                  TStringVariable(Variable).Value :=
                    ADataSet.StringData[Cell.Lay, Cell.Row, Cell.Col]
                end;
            else
              Assert(False);
            end;
          end;
        end;
      end;
      UpdateCurrentScreenObject(AScreenObject);
      UpdateCurrentSegment(AScreenObject.Segments[FModel].ClosestSegment(
        ClosestLocation, LocalAnisotropy));
      AScreenObject.UpdateImportedValues(DataSet);
      EvaluateExpression(Compiler, Expression, AScreenObject);

      UpdateCurrentScreenObject(AScreenObject);
      UpdateCurrentSegment(AScreenObject.Segments[FModel].ClosestSegment(
        ClosestLocation, LocalAnisotropy));
      Value := Expression.DoubleResult;
      if ScreenObjectDistance = 0 then
      begin
        result := Value;
        Exit;
      end
      else
      begin
        Weight := 1 / Sqr(ScreenObjectDistance);
        SumWeights := SumWeights + Weight;
        Sum := Sum + Value * Weight;
      end;
    end;
    if SumWeights = 0 then
    begin
      result := 0;
    end
    else
    begin
      result := Sum / SumWeights;
    end;

  finally
    ListOfScreenObjects.Free;
  end;
end;

class function TInvDistSq2DInterpolator.ValidReturnTypes: TRbwDataTypes;
begin
  result := [rdtDouble];
end;

{ TCustomAnisotropicInterpolator }

procedure TCustomAnisotropicInterpolator.Assign(Source: TPersistent);
begin
  if Source is TCustomAnisotropicInterpolator then
  begin
    Anisotropy := TCustomAnisotropicInterpolator(Source).Anisotropy
  end;
  inherited;
end;

constructor TCustomAnisotropicInterpolator.Create(AOwner: TComponent);
begin
  inherited;
  FAnisotropy := 1;
end;

procedure TCustomAnisotropicInterpolator.InitializeQuadTreeLimits(
  const QuadTree: TRbwQuadTree; const DataSet: TDataArray);
var
  MinY: Real;
  MaxY: Real;
  MinX: Real;
  MaxX: Real;
begin
  QuadTree.Clear;
  GetLimits(MinY, MaxY, MinX, MaxX, DataSet);
  QuadTree.Xmax := MaxX;
  QuadTree.Xmin := MinX;
  QuadTree.Ymax := MaxY;
  QuadTree.Ymin := MinY;
end;

function TCustomAnisotropicInterpolator.SameAs(
  AnotherInterpolator: TCustom2DInterpolater): boolean;
begin
  result := inherited SameAs(AnotherInterpolator)
    and (Anisotropy = (AnotherInterpolator
    as TCustomAnisotropicInterpolator).Anisotropy);
end;

procedure TCustomAnisotropicInterpolator.GetLimits(var MinY: Real; var MaxY: Real; var MinX: Real; var MaxX: Real; const DataSet: TDataArray);
var
  ScreenObject: TScreenObject;
  Index: Integer;
  ListOfScreenObjects: TList;
  APoint: TPoint2D;
begin
  Assert(DataSet <> nil);
  case DataSet.Orientation of
    dsoTop:
      begin
        Assert(frmGoPhast.Grid.ColumnCount > 0);
        Assert(frmGoPhast.Grid.RowCount > 0);
        APoint := frmGoPhast.Grid.TwoDElementCorner(0, 0);
        MaxX := APoint.X;
        MinX := APoint.X;
        MaxY := APoint.Y * Anisotropy;
        MinY := APoint.Y * Anisotropy;
        APoint := frmGoPhast.Grid.TwoDElementCorner(frmGoPhast.Grid.ColumnCount, 0);
        if APoint.X > MaxX then
        begin
          MaxX := APoint.X;
        end;
        if APoint.X < MinX then
        begin
          MinX := APoint.X;
        end;
        if APoint.Y * Anisotropy > MaxY then
        begin
          MaxY := APoint.Y * Anisotropy;
        end;
        if APoint.Y * Anisotropy < MinY then
        begin
          MinY := APoint.Y * Anisotropy;
        end;
        APoint := frmGoPhast.Grid.TwoDElementCorner(frmGoPhast.Grid.ColumnCount, frmGoPhast.Grid.RowCount);
        if APoint.X > MaxX then
        begin
          MaxX := APoint.X;
        end;
        if APoint.X < MinX then
        begin
          MinX := APoint.X;
        end;
        if APoint.Y * Anisotropy > MaxY then
        begin
          MaxY := APoint.Y * Anisotropy;
        end;
        if APoint.Y * Anisotropy < MinY then
        begin
          MinY := APoint.Y * Anisotropy;
        end;
        APoint := frmGoPhast.Grid.TwoDElementCorner(0, frmGoPhast.Grid.RowCount);
        if APoint.X > MaxX then
        begin
          MaxX := APoint.X;
        end;
        if APoint.X < MinX then
        begin
          MinX := APoint.X;
        end;
        if APoint.Y * Anisotropy > MaxY then
        begin
          MaxY := APoint.Y * Anisotropy;
        end;
        if APoint.Y * Anisotropy < MinY then
        begin
          MinY := APoint.Y * Anisotropy;
        end;
      end;
    dsoFront:
      begin
        Assert(frmGoPhast.Grid.ColumnCount > 0);
        Assert(frmGoPhast.Grid.LayerCount > 0);
        MaxX := frmGoPhast.Grid.ColumnPosition[frmGoPhast.Grid.ColumnCount];
        MinX := frmGoPhast.Grid.ColumnPosition[0];
        MaxY := frmGoPhast.Grid.HighestElevation * Anisotropy;
        MinY := frmGoPhast.Grid.LowestElevation * Anisotropy;
      end;
    dsoSide:
      begin
        Assert(frmGoPhast.Grid.RowCount > 0);
        Assert(frmGoPhast.Grid.LayerCount > 0);
        MaxX := frmGoPhast.Grid.RowPosition[frmGoPhast.Grid.RowCount];
        MinX := frmGoPhast.Grid.RowPosition[0];
        MaxY := frmGoPhast.Grid.HighestElevation * Anisotropy;
        MinY := frmGoPhast.Grid.LowestElevation * Anisotropy;
      end;
    dso3D:
      begin
      end;
  else
    Assert(False);
  end;
  ListOfScreenObjects := TList.Create;
  try
    FillScreenObjectList(ListOfScreenObjects);
    if ListOfScreenObjects.Count > 0 then
    begin
      for Index := 0 to 100 - 1 do
      begin
        ScreenObject := ListOfScreenObjects[Random(ListOfScreenObjects.Count)];
        if ScreenObject.Count > 0 then
        begin
          APoint := ScreenObject.Points[Random(ScreenObject.Count)];
          case ScreenObject.ViewDirection of
            vdTop:
              begin
                APoint := frmGoPhast.Grid.
                  RotateFromRealWorldCoordinatesToGridCoordinates(APoint);
              end;
            vdFront: ; // do nothing
            vdSide:
              begin
                APoint := InvertPoint(APoint);
              end;
          end;
          APoint.Y := APoint.Y * Anisotropy;
          if APoint.x < MinX then
          begin
            MinX := APoint.x;
          end
          else if APoint.x > MaxX then
          begin
            MaxX := APoint.x;
          end;
          if APoint.y < MinY then
          begin
            MinY := APoint.y;
          end
          else if APoint.y > MaxY then
          begin
            MaxY := APoint.y;
          end;
        end;
      end;
    end;
  finally
    ListOfScreenObjects.Free;
  end;
end;

procedure TCustomAnisotropicInterpolator.SetAnisotropy(const Value: real);
begin
  if Value <= 0 then
  begin
    FAnisotropy := 1;
  end
  else
  begin
    FAnisotropy := Value;
  end;
end;

{ TNearestPoint2DInterpolator }

constructor TCustomPoint2DInterpolator.Create(AOwner: TComponent);
begin
  inherited;

  OnInitialize := StoreData;
end;

procedure TCustomPoint2DInterpolator.Finalize(const DataSet: TDataArray);
begin
  inherited;
  SetLength(FRealData, 0);
  SetLength(FIntegerData, 0);
  SetLength(FBooleanData, 0);
  SetLength(FStringData, 0);
end;

procedure TCustomPoint2DInterpolator.SetArraySize(
  const DataSet: TDataArray; Count: Integer);
begin
  case DataSet.DataType of
    rdtDouble:
      begin
        SetLength(FRealData, Count);
      end;
    rdtInteger:
      begin
        SetLength(FIntegerData, Count);
      end;
    rdtBoolean:
      begin
        SetLength(FBooleanData, Count);
      end;
    rdtString:
      begin
        SetLength(FStringData, Count);
      end;
  else
    Assert(False);
  end;
end;

function TNearest2DInterpolator.BooleanResult(
  const Location: TPoint2D): boolean;
var
  Expression: TExpression;
begin
  Expression := GetExpression(Location);
  if Expression = nil then
  begin
    result := inherited BooleanResult(Location);
  end
  else
  begin
    result := FExpression.BooleanResult;
  end;
end;

function TNearest2DInterpolator.IntegerResult(
  const Location: TPoint2D): integer;
var
  Expression: TExpression;
begin
  Expression := GetExpression(Location);
  if Expression = nil then
  begin
    result := inherited IntegerResult(Location);
  end
  else
  begin
    result := FExpression.IntegerResult;
  end;
end;

function TNearest2DInterpolator.RealResult(const Location: TPoint2D): real;
var
  Expression: TExpression;
begin
  Expression := GetExpression(Location);
  if Expression = nil then
  begin
    result := inherited RealResult(Location);
  end
  else
  begin
    result := FExpression.DoubleResult;
  end;
end;

function TNearest2DInterpolator.StringResult(const Location: TPoint2D): string;
var
  Expression: TExpression;
begin
  Expression := GetExpression(Location);
  if Expression = nil then
  begin
    result := inherited StringResult(Location);
  end
  else
  begin
    result := FExpression.StringResult;
  end;
end;

class function TNearest2DInterpolator.ValidReturnTypes: TRbwDataTypes;
begin
  result := [rdtDouble, rdtInteger, rdtBoolean, rdtString];
end;

constructor TNearest2DInterpolator.Create(AOwner: TComponent);
begin
  inherited;
  FQuadTree := TRbwQuadTree.Create(self);
  FListOfTScreenObjects := TList.Create;

  OnInitialize := StoreData;
end;

function TNearest2DInterpolator.GetExpression(
  const Location: TPoint2D): TExpression;
var
  NearestScreenObject: TScreenObject;
  ClosestLocation: TPoint2D;
begin
  result := nil;
  NearestScreenObject := GetNearestScreenObject(Location, ClosestLocation);
  if NearestScreenObject <> nil then
  begin
    InitializeVariablesAndExpression(ClosestLocation, NearestScreenObject,
      FExpression);
    result := FExpression;
  end;
end;

procedure TNearest2DInterpolator.StoreData(Sender: TObject;
  const DataSet: TDataArray);
var
  ScreenObjectIndex: integer;
  AScreenObject: TScreenObject;
  PointCount: integer;
  PointIndex: integer;
  APoint: TPoint2D;
  SectionIndex: integer;
begin
  InitializeQuadTreeLimits(FQuadTree, DataSet);

  FillScreenObjectList(FListOfTScreenObjects);

  // Check objects in reverse order because later objects should
  // override earlier ones, so if there is a tie, the later one
  // should win.

  for ScreenObjectIndex := FListOfTScreenObjects.Count - 1 downto 0 do
  begin
    AScreenObject := FListOfTScreenObjects[ScreenObjectIndex];

    PointCount := AScreenObject.Count;
    SectionIndex := 0;
    for PointIndex := 0 to PointCount - 1 do
    begin
      if AScreenObject.SectionEnd[SectionIndex] = PointIndex then
      begin
        Inc(SectionIndex);
        if AScreenObject.SectionClosed[SectionIndex-1] then
        begin
          Continue;
        end;
      end;
      APoint := AScreenObject.Points[PointIndex];
      if AScreenObject.ViewDirection = vdSide then
      begin
        APoint := InvertPoint(APoint);
      end;
      FQuadTree.AddPoint(APoint.X, APoint.Y * Anisotropy, AScreenObject);
    end;
    AScreenObject.CacheSegments;
  end;
end;

procedure TCustomAnisotropicInterpolator.InitializeVariablesAndExpression(
  const Location: TPoint2D; const AScreenObject: TScreenObject;
  var Expression: TExpression);
var
  Index: integer;
  DataSetIndex: Integer;
  ScreenObjectFunction: string;
  Compiler: TRbwParser;
  VariablesUsed: TStringList;
  Cell: T3DCell;
  ADataSet: TDataArray;
  VariableIndex: integer;
  Variable: TCustomValue;
  IsBoundary: boolean;
  TopCell: T2DTopCell;
  NearestSegment: TCellElementSegment;
  Model: TCustomModel;
begin
  Assert(DataSet <> nil);
  DataSetIndex := AScreenObject.IndexOfDataSet(DataSet);
  if DataSetIndex >= 0 then
  begin
    IsBoundary := False;
    AScreenObject.UpdateImportedValues(DataSet);
    ScreenObjectFunction := AScreenObject.DataSetFormulas[DataSetIndex];
  end
  else
  begin
     { TODO : I don't think it can ever get here. }
    IsBoundary := True;
    DataSetIndex := AScreenObject.IndexOfBoundaryDataSet(DataSet);
    Assert(DataSetIndex >= 0);
    ScreenObjectFunction :=
      AScreenObject.BoundaryDataSetFormulas[DataSetIndex];
  end;

  Model := DataSet.Model as TCustomModel;
  Assert(FModel = Model);
  Compiler := Model.GetCompiler(
    DataSet.Orientation, DataSet.EvaluatedAt);
  try
    Compiler.Compile(ScreenObjectFunction);
  except on E: ERbwParserError do
    begin
      ResetScreenObjectFunction(DataSetIndex, AScreenObject, Compiler,
        DataSet.DataType, E.Message, IsBoundary);
    end;
  end;

  Expression := Compiler.CurrentExpression;
  VariablesUsed := Expression.VariablesUsed;
  if Model.ModelSelection = msPhast then
  begin
    Cell := Model.PhastGrid.GetCell(Location,
      AScreenObject.ViewDirection, DataSet.EvaluatedAt);
  end
  else
  begin
    // With MODFLOW, the only 2D data sets are in the top view.
    Assert(DataSet.Orientation = dsoTop);
    Assert(AScreenObject.ViewDirection = vdTop);
    TopCell := Model.ModflowGrid.TopContainingCell(Location,
      DataSet.EvaluatedAt);
    Cell.Col := TopCell.Col;
    Cell.Row := TopCell.Row;
    Cell.Lay := 0;
  end;
  if Cell.Col < 0 then
  begin
    Cell.Col := 0;
  end;
  if Cell.Row < 0 then
  begin
    Cell.Row := 0;
  end;
  case DataSet.EvaluatedAt of
    eaBlocks:
      begin
        if Cell.Col >= Model.Grid.ColumnCount then
        begin
          Cell.Col := Model.Grid.ColumnCount-1;
        end;
        if Cell.Row >= Model.Grid.RowCount then
        begin
          Cell.Row := Model.Grid.RowCount-1;
        end;
        if Cell.Lay >= Model.Grid.LayerCount then
        begin
          Cell.Lay := Model.Grid.LayerCount-1;
        end;
      end;
    eaNodes:
      begin
        if Cell.Col >= Model.Grid.ColumnCount+1 then
        begin
          Cell.Col := Model.Grid.ColumnCount;
        end;
        if Cell.Row >= Model.Grid.RowCount+1 then
        begin
          Cell.Row := Model.Grid.RowCount;
        end;
        if Cell.Lay >= Model.Grid.LayerCount+1 then
        begin
          Cell.Lay := Model.Grid.LayerCount;
        end;
      end;
    else Assert(False);
  end;
  NearestSegment := AScreenObject.Segments[FModel].ClosestSegment(
    Location, Anisotropy);
  UpDateGlobalLocations(Cell.Col, Cell.Row, Cell.Lay, DataSet.EvaluatedAt,
    DataSet.Model);
  UpdateCurrentScreenObject(AScreenObject);
  UpdateCurrentSegment(NearestSegment);
  if VariablesUsed.Count > 0 then
  begin
    for Index := 0 to VariablesUsed.Count - 1 do
    begin
      ADataSet := Model.DataArrayManager.GetDataSetByName(
        VariablesUsed[Index]);
      if ADataSet <> nil then
      begin
        ADataSet.Initialize;
      end;
    end;
    for Index := 0 to VariablesUsed.Count - 1 do
    begin
      ADataSet := Model.DataArrayManager.GetDataSetByName(
        VariablesUsed[Index]);
      if ADataSet <> nil then
      begin
        VariableIndex := Compiler.IndexOfVariable(VariablesUsed[Index]);
        Variable := Compiler.Variables[VariableIndex];
        Assert(Variable.ResultType = ADataSet.DataType);
        case Variable.ResultType of
          rdtDouble:
            begin
              TRealVariable(Variable).Value :=
                ADataSet.RealData[Cell.Lay, Cell.Row, Cell.Col]
            end;
          rdtInteger:
            begin
              TIntegerVariable(Variable).Value :=
                ADataSet.IntegerData[Cell.Lay, Cell.Row, Cell.Col]
            end;
          rdtBoolean:
            begin
              TBooleanVariable(Variable).Value :=
                ADataSet.BooleanData[Cell.Lay, Cell.Row, Cell.Col]
            end;
          rdtString:
            begin
              TStringVariable(Variable).Value :=
                ADataSet.StringData[Cell.Lay, Cell.Row, Cell.Col]
            end;
        else
          Assert(False);
        end;
      end;
    end;
  end;
  UpDateGlobalLocations(Cell.Col, Cell.Row, Cell.Lay, DataSet.EvaluatedAt,
    DataSet.Model);
  UpdateCurrentScreenObject(AScreenObject);
  UpdateCurrentSegment(NearestSegment);
  AScreenObject.UpdateImportedValues(DataSet);
  EvaluateExpression(Compiler, Expression, AScreenObject);
end;

function TNearest2DInterpolator.GetNearestScreenObject(
  const Location: TPoint2D; out ClosestLocation: TPoint2D): TScreenObject;
var
  Index: integer;
  AScreenObject: TScreenObject;
  ScreenObjectDistance: real;
  X, Y: double;
  Data: TPointerArray;
  LocalAnisotropy: Real;
  LocalLocation: TPoint2D;
begin
  result := nil;

  if FListOfTScreenObjects.Count = 0 then
  begin
    Exit;
  end;

  X := Location.X;
  Y := Location.Y * Anisotropy;
  FQuadTree.FindClosestPointsData(X, Y, Data);
  ClosestLocation.X := X;
  ClosestLocation.Y := Y / Anisotropy;
  if Length(Data) > 0 then
  begin
    result := Data[0];
  end
  else
  begin
    result := nil;
  end;
  Assert(result <> nil);

  ScreenObjectDistance :=
    Sqrt(Sqr(Location.X - ClosestLocation.X) +
      Sqr((Location.Y - ClosestLocation.Y)*Anisotropy));

  if ScreenObjectDistance = 0 then
  begin
    Exit;
  end;

  LocalAnisotropy := Anisotropy;
  LocalLocation := Location;
  if result.ViewDirection = vdSide then
  begin
    LocalAnisotropy := 1/Anisotropy;
    LocalLocation := InvertPoint(Location);
    ClosestLocation := InvertPoint(ClosestLocation);
  end;

  // Check objects in reverse order because later objects should
  // override earlier ones, so if there is a tie, the later one
  // should win.
  for Index := FListOfTScreenObjects.Count - 1 downto 0 do
  begin
    AScreenObject := FListOfTScreenObjects[Index];
    // ScreenObjectDistance and ClosestLocation are changed if and only
    // if IsAnyPointCloser returns True.
    if AScreenObject.IsAnyPointCloser(LocalLocation, ScreenObjectDistance,
      ClosestLocation, LocalAnisotropy) then
    begin
      result := AScreenObject;
      if ScreenObjectDistance = 0 then
      begin
        Exit;
      end;
    end;
  end;
end;

procedure TCustomPoint2DInterpolator.StoreData(Sender: TObject;
  const DataSet: TDataArray);
var
  ScreenObjectIndex: integer;
  AScreenObject: TScreenObject;
  PointCount: integer;
  PointIndex: integer;
  APoint: TPoint2D;
  ListOfScreenObjects: TList;
  SectionIndex: integer;
  Count: integer;
begin
  ListOfScreenObjects := TList.Create;
  try
    FillScreenObjectList(ListOfScreenObjects);

    // Check objects in reverse order because later objects should
    // override earlier ones, so if there is a tie, the later one
    // should win.

    Count := 0;
    for ScreenObjectIndex := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[ScreenObjectIndex];

      PointCount := AScreenObject.Count;
      SectionIndex := 0;
      for PointIndex := 0 to PointCount - 1 do
      begin
        if AScreenObject.SectionEnd[SectionIndex] = PointIndex then
        begin
          Inc(SectionIndex);
          if AScreenObject.SectionClosed[SectionIndex-1] then
          begin
            Continue;
          end;
        end;
        Inc(Count);
      end;
    end;
    SetArraySize(DataSet, Count);
    Count := 0;
    for ScreenObjectIndex := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[ScreenObjectIndex];

      PointCount := AScreenObject.Count;
      SectionIndex := 0;
      for PointIndex := 0 to PointCount - 1 do
      begin
        if AScreenObject.SectionEnd[SectionIndex] = PointIndex then
        begin
          Inc(SectionIndex);
          if AScreenObject.SectionClosed[SectionIndex-1] then
          begin
            Continue;
          end;
        end;
        APoint := AScreenObject.Points[PointIndex];
        if AScreenObject.ViewDirection = vdSide then
        begin
          APoint := InvertPoint(APoint);
        end;

        StoreDataValue(Count, DataSet, APoint, AScreenObject);
        Inc(Count);

      end;
      AScreenObject.CacheSegments;
    end;
  finally
    ListOfScreenObjects.Free;
  end;
end;

{ TNearestPoint2DInterpolator }

function TNearestPoint2DInterpolator.BooleanResult(
  const Location: TPoint2D): boolean;
var
  APointer: Pointer;
begin
  APointer := GetPointerToResult(Location);

  if APointer = nil then
  begin
    result := False;
  end
  else
  begin
    result := PBoolean(APointer)^;
  end;
end;

constructor TNearestPoint2DInterpolator.Create(AOwner: TComponent);
begin
  inherited;
  FQuadTree := TRbwQuadTree.Create(self);
//  FQuadTree.MaxPoints := 10;

end;

procedure TNearestPoint2DInterpolator.Finalize(const DataSet: TDataArray);
begin
  FQuadTree.Clear;
  inherited;

end;

function TNearestPoint2DInterpolator.GetPointerToResult(
  const Location: TPoint2D): Pointer;
var
  X: Double;
  Y: Double;
  Data: TPointerArray;
begin
  X := Location.X;
  Y := Location.Y * Anisotropy;
  FQuadTree.FindClosestPointsData(X, Y, Data);
  if Length(Data) > 0 then
  begin
    result := Data[0];
  end
  else
  begin
    result := nil;
  end;
end;

function TNearestPoint2DInterpolator.IntegerResult(
  const Location: TPoint2D): integer;
var
  APointer: Pointer;
begin
  APointer := GetPointerToResult(Location);

  if APointer = nil then
  begin
    result := 0;
  end
  else
  begin
    result := PInteger(APointer)^;
  end;
end;

class function TNearestPoint2DInterpolator.InterpolatorName: string;
begin
  result := 'Nearest Point';
end;

function TNearestPoint2DInterpolator.RealResult(
  const Location: TPoint2D): real;
var
  APointer: Pointer;
begin
  APointer := GetPointerToResult(Location);

  if APointer = nil then
  begin
    result := 0;
  end
  else
  begin
    result := PReal(APointer)^;
  end;
end;

procedure TNearestPoint2DInterpolator.SetArraySize(const DataSet: TDataArray;
  Count: Integer);
begin
  inherited;
  FQuadTree.MaxPoints := Max(100, Count div 1000);
end;

procedure TNearestPoint2DInterpolator.StoreData(Sender: TObject;
  const DataSet: TDataArray);
begin
  InitializeQuadTreeLimits(FQuadTree, DataSet);
  inherited StoreData(Sender, DataSet);
end;

procedure TNearestPoint2DInterpolator.StoreDataValue(Count: Integer;
  const DataSet: TDataArray; APoint: TPoint2D; AScreenObject: TScreenObject);
var
  Expression: TExpression;
begin
  InitializeVariablesAndExpression(APoint, AScreenObject, Expression);
//  AScreenObject.UpdateImportedValues(DataSet);
  case DataSet.DataType of
    rdtDouble:
      begin
        FRealData[Count] := Expression.DoubleResult;
        FQuadTree.AddPoint(APoint.X, APoint.Y * Anisotropy,
          Addr(FRealData[Count]));
      end;
    rdtInteger:
      begin
        FIntegerData[Count] := Expression.IntegerResult;
        FQuadTree.AddPoint(APoint.X, APoint.Y * Anisotropy,
          Addr(FIntegerData[Count]));
      end;
    rdtBoolean:
      begin
        FBooleanData[Count] := Expression.BooleanResult;
        FQuadTree.AddPoint(APoint.X, APoint.Y * Anisotropy,
          Addr(FBooleanData[Count]));
      end;
    rdtString:
      begin
        FStringData[Count] := Expression.StringResult;
        FQuadTree.AddPoint(APoint.X, APoint.Y * Anisotropy,
          Addr(FStringData[Count]));
      end;
  else
    Assert(False);
  end;
end;

function TNearestPoint2DInterpolator.StringResult(
  const Location: TPoint2D): string;
var
  APointer: Pointer;
begin
  APointer := GetPointerToResult(Location);

  if APointer = nil then
  begin
    result := '';
  end
  else
  begin
    result := PString(APointer)^;
  end;
end;

class function TNearestPoint2DInterpolator.ValidReturnTypes: TRbwDataTypes;
begin
  result := [rdtDouble, rdtInteger, rdtBoolean, rdtString];
end;

{ TCustomSfrpackInterpolator }

constructor TCustomSfrpackInterpolator.Create(AOwner: TComponent);
begin
  inherited;
  FSfrInterpolator := TSfrInterpolator.Create;
  OnInitialize := StoreData;
end;

destructor TCustomSfrpackInterpolator.Destroy;
begin
  FSfrInterpolator.Free;
  inherited;
end;

procedure TCustomSfrpackInterpolator.Finalize(const DataSet: TDataArray);
begin
  inherited;
  FSfrInterpolator.Finalize;
end;

procedure TCustomSfrpackInterpolator.StoreData(Sender: TObject;
  const DataSet: TDataArray);
var
  ListOfScreenObjects: TList;
  AScreenObject: TScreenObject;
  ScreenObjectIndex: Integer;
  Count: integer;
  PointCount: Integer;
  APoint, Point1, Point2: TPoint2D;
  PointIndex: Integer;
  Expression: TExpression;
  XArray: TFloatArray;
  YArray: TFloatArray;
  ZArray: TFloatArray;
  Index: Integer;
  SectionIndex: integer;
  SortArray: array of TSortRecord;
  SortIndex: integer;
  SortList: TList;
  PSort1, PSort2: PSortRecord;
  X_Single1: single;
  X_Single2: single;
  Y_Single1: single;
  Y_Single2: single;
begin
  FValidData := False;
  ListOfScreenObjects := TList.Create;
  try
    // Get a list of the TScreenObjects that set the value of DataSet
    // by interpolation.
    FillScreenObjectList(ListOfScreenObjects);

    // Set the capacity of X, Y, and Z.
    Count := 0;
    for ScreenObjectIndex := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[ScreenObjectIndex];
      Count := Count + AScreenObject.Count;
    end;
    SetLength(SortArray, Count);

    SortIndex := 0;
    // Add values to X, Y, and Z at each unique location.
    // Iterate from the end to the beginning to make sure that
    // if any points are non-unique, the points of the later objects
    // win out.
    for ScreenObjectIndex := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[ScreenObjectIndex];

      SectionIndex := 0;
      PointCount := AScreenObject.Count;
      for PointIndex := 0 to PointCount - 1 do
      begin
        if AScreenObject.SectionEnd[SectionIndex] = PointIndex then
        begin
          Inc(SectionIndex);
          if AScreenObject.SectionClosed[SectionIndex-1] then
          begin
            Continue;
          end;
        end;
        APoint := AScreenObject.Points[PointIndex];
        if AScreenObject.ViewDirection = vdSide then
        begin
          APoint := InvertPoint(APoint);
        end;
        Point1.X := APoint.x;
        Point1.y := APoint.y * Anisotropy;
        Point2 := Point1;

        SortArray[SortIndex].Location := Point2;
        InitializeVariablesAndExpression(Point2, AScreenObject, Expression);
        SortArray[SortIndex].Value := Expression.DoubleResult;
        SortArray[SortIndex].Duplicate := False;
        SortArray[SortIndex].OriginalIndex := SortIndex;
        Inc(SortIndex);
      end;
    end;

    SortList := TList.Create;
    try
      SortList.Capacity := SortIndex;
      for SortIndex := 0 to SortList.Capacity - 1 do
      begin
        SortList.Add(Addr(SortArray[SortIndex]));
      end;

      SortList.Sort(SortRecordCompare);

      Count := 1;
      for SortIndex := 0 to SortList.Count - 2 do
      begin
        PSort1 := SortList[SortIndex];
        PSort2 := SortList[SortIndex+1];
        // reduce precision to single precision.
        X_Single1 := PSort1.Location.x;
        X_Single2 := PSort2.Location.x;
        Y_Single1 := PSort1.Location.y;
        Y_Single2 := PSort2.Location.y;
        PSort2.Duplicate := (X_Single1 = X_Single2)
          and (Y_Single1 = Y_Single2);
        if not PSort2.Duplicate then
        begin
          Inc(Count);
        end;
      end;

      // transfer X, Y, and Z to XArray, YArray, and ZArray.
      SetLength(XArray, Count);
      SetLength(YArray, Count);
      SetLength(ZArray, Count);

      SortIndex := 0;
      for Index := 0 to SortList.Count - 1 do
      begin
        if not SortArray[Index].Duplicate then
        begin
          XArray[SortIndex] := SortArray[Index].Location.X;
          YArray[SortIndex] := SortArray[Index].Location.Y;
          ZArray[SortIndex] := SortArray[Index].Value;
          Inc(SortIndex);
        end;
      end;
    finally
      SortList.Free;
    end;

    // Initialize FSfrInterpolator.  If all goes well,
    // indicate that the data is valid.  Otherwise, inform the user
    // of the problem.
    try
      FSfrInterpolator.Initialize(XArray, YArray, ZArray);
      FValidData := True;
    except on E: ESfrError do
      begin
        Beep;
        MessageDlg('Error encouterered in initializing ' + InterpolatorName
          + ' for the ' + DataSet.Name + '.  Error was ' + E.Message,
          mtError, [mbOK], 0);
      end;
    end;
  finally
    ListOfScreenObjects.Free;
  end;
end;

class function TCustomSfrpackInterpolator.ValidReturnTypes: TRbwDataTypes;
begin
  result := [rdtDouble];
end;

{ TLinearSfrpackInterpolator }

class function TLinearSfrpackInterpolator.InterpolatorName: string;
begin
  result := 'Triangle Interp.';
end;

function TLinearSfrpackInterpolator.RealResult(const Location: TPoint2D): real;
begin
  if FValidData then
  begin
    try
      result := FSfrInterpolator.Interpolate1(
        Location.x, Location.y * Anisotropy)
    except on E: ESfrError do
      begin
        FValidData := False;
        Beep;
        MessageDlg('Error encouterered in evaluating ' + InterpolatorName
          + ' for the ' + DataSet.Name + '.  Error was ' + E.Message,
          mtError, [mbOK], 0);
        result := 0;
      end;
    end;
  end
  else
  begin
    result := 0;
  end;
end;

{ TCurvilinearSfrpackInterpolator }

class function TFittedSurfaceIntepolator.InterpolatorName: string;
begin
  result := 'Fitted Surface';
end;

function TFittedSurfaceIntepolator.RealResult(
  const Location: TPoint2D): real;
begin
  if FValidData then
  begin
    try
      result := FSfrInterpolator.Interpolate2(
        Location.x, Location.y * Anisotropy)
    except on E: ESfrError do
      begin
        FValidData := False;
        Beep;
        MessageDlg('Error encouterered in evaluating ' + InterpolatorName
          + ' for the ' + DataSet.Name + '.  Error was ' + E.Message,
          mtError, [mbOK], 0);
        result := 0;
      end;
    end;
  end
  else
  begin
    result := 0;
  end;
end;

{ TInvDistSqPoint2DInterpolator }

procedure TInvDistSqPoint2DInterpolator.Finalize(const DataSet: TDataArray);
begin
  inherited;
  SetLength(FLocations, 0);
end;

class function TInvDistSqPoint2DInterpolator.InterpolatorName: string;
begin
  result := 'Point Inv. Dist. Sq.';
end;

function TInvDistSqPoint2DInterpolator.RealResult(
  const Location: TPoint2D): real;
var
  Index: integer;
  PointDistance: real;
  PointLocation: TPoint2D;
  Weight: real;
  SumWeights: real;
  Sum: real;
  Value: real;
  AdjustedLocaton: TPoint2D;
begin
  SumWeights := 0;
  Sum := 0;

  AdjustedLocaton.x := Location.x;
  AdjustedLocaton.y := Location.y * Anisotropy;
  for Index := 0 to Length(FLocations) -1 do
  begin
    Value := FRealData[Index];
    PointLocation := FLocations[Index];
    PointDistance := Distance(PointLocation, AdjustedLocaton);
    if PointDistance = 0 then
    begin
      result := Value;
      Exit;
    end
    else
    begin
      Weight := 1 / Sqr(PointDistance);
      SumWeights := SumWeights + Weight;
      Sum := Sum + Value * Weight;
    end;
  end;
  if SumWeights = 0 then
  begin
    result := 0;
  end
  else
  begin
    result := Sum / SumWeights;
  end;
end;

procedure TInvDistSqPoint2DInterpolator.SetArraySize(const DataSet: TDataArray;
  Count: Integer);
begin
  inherited;
  SetLength(FLocations, Count);
end;

procedure TInvDistSqPoint2DInterpolator.StoreDataValue(Count: Integer;
  const DataSet: TDataArray; APoint: TPoint2D; AScreenObject: TScreenObject);
var
  Expression: TExpression;
begin
  inherited;
  InitializeVariablesAndExpression(APoint, AScreenObject, Expression);
  Assert(DataSet.DataType = rdtDouble);
  FRealData[Count] := Expression.DoubleResult;
  FLocations[Count].X := APoint.X;
  FLocations[Count].Y := APoint.Y * Anisotropy;
end;

class function TInvDistSqPoint2DInterpolator.ValidReturnTypes: TRbwDataTypes;
begin
  result := [rdtDouble];
end;

function TCustomTriangleInterpolator.ShouldInterpolate: boolean;
var
  Index: Integer;
  AScreenObject: TScreenObject;
  DataSetIndex: Integer;
  PointCount: integer;
begin
  result := False;
  PointCount := 0;
  for Index := 0 to frmGoPhast.PhastModel.ScreenObjectCount - 1 do
  begin
    AScreenObject := frmGoPhast.PhastModel.ScreenObjects[Index];
    if AScreenObject.Deleted or not AScreenObject.SetValuesByInterpolation
      then
    begin
      continue;
    end;
    DataSetIndex := AScreenObject.IndexOfDataSet(DataSet);
    if DataSetIndex < 0 then
    begin
      continue;
    end;
    PointCount := PointCount + AScreenObject.Count;
    if PointCount >= 3 then
    begin
      result := True;
      break;
    end;
  end;
end;

{ TNaturalNeighborInterp }

constructor TNaturalNeighborInterp.Create(AOwner: TComponent);
begin
  inherited;
  OnInitialize := StoreData;
end;

destructor TNaturalNeighborInterp.Destroy;
begin
  FNatNeigh.Free;
  inherited;
end;

procedure TNaturalNeighborInterp.Finalize(const DataSet: TDataArray);
begin
  inherited;
  FreeAndNil(FNatNeigh);
end;

class function TNaturalNeighborInterp.InterpolatorName: string;
begin
  result := 'Natural Neighbor';
end;

function TNaturalNeighborInterp.RealResult(const Location: TPoint2D): real;
begin
  result := FNatNeigh.Interpolate(Location.x, Location.y);
end;

procedure TNaturalNeighborInterp.StoreData(Sender: TObject;
  const DataSet: TDataArray);
var  
  ListOfScreenObjects: TList;
  AScreenObject: TScreenObject;
  ScreenObjectIndex: Integer;
  Count: integer;
  PointCount: Integer;
  APoint, Point1, Point2: TPoint2D;
  PointIndex: Integer;
  Expression: TExpression;
  XArray: TFloatArray;
  YArray: TFloatArray;
  ZArray: TFloatArray;
  Index: Integer;
  SectionIndex: integer;
  SortArray: array of TSortRecord;
  SortIndex: integer;
  SortList: TList;
  PSort1, PSort2: PSortRecord;
  X_Single1: single;
  X_Single2: single;
  Y_Single1: single;
  Y_Single2: single;
  MinY: Real;
  MaxY: Real;
  MinX: Real;
  MaxX: Real;
begin
  ListOfScreenObjects := TList.Create;
  try
    // Get a list of the TScreenObjects that set the value of DataSet
    // by interpolation.
    FillScreenObjectList(ListOfScreenObjects);

    // Set the capacity of X, Y, and Z.
    Count := 0;
    for ScreenObjectIndex := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[ScreenObjectIndex];
      Count := Count + AScreenObject.Count;
    end;
    SetLength(SortArray, Count);

    SortIndex := 0;
    // Add values to X, Y, and Z at each unique location.
    // Iterate from the end to the beginning to make sure that
    // if any points are non-unique, the points of the later objects
    // win out.
    for ScreenObjectIndex := ListOfScreenObjects.Count - 1 downto 0 do
    begin
      AScreenObject := ListOfScreenObjects[ScreenObjectIndex];

      SectionIndex := 0;
      PointCount := AScreenObject.Count;
      for PointIndex := 0 to PointCount - 1 do
      begin
        if AScreenObject.SectionEnd[SectionIndex] = PointIndex then
        begin
          Inc(SectionIndex);
          if AScreenObject.SectionClosed[SectionIndex-1] then
          begin
            Continue;
          end;
        end;
        APoint := AScreenObject.Points[PointIndex];
        if AScreenObject.ViewDirection = vdSide then
        begin
          APoint := InvertPoint(APoint);
        end;
        Point1.X := APoint.x;
        Point1.y := APoint.y * Anisotropy;
        Point2 := Point1;

        SortArray[SortIndex].Location := Point2;
        InitializeVariablesAndExpression(Point2, AScreenObject, Expression);
        SortArray[SortIndex].Value := Expression.DoubleResult;
        SortArray[SortIndex].Duplicate := False;
        SortArray[SortIndex].OriginalIndex := SortIndex;
        Inc(SortIndex);
      end;
    end;

    SortList := TList.Create;
    try
      SortList.Capacity := SortIndex;
      for SortIndex := 0 to SortList.Capacity - 1 do
      begin
        SortList.Add(Addr(SortArray[SortIndex]));
      end;

      SortList.Sort(SortRecordCompare);

      Count := 1;
      for SortIndex := 0 to SortList.Count - 2 do
      begin
        PSort1 := SortList[SortIndex];
        PSort2 := SortList[SortIndex+1];
        // reduce precision to single precision.
        X_Single1 := PSort1.Location.x;
        X_Single2 := PSort2.Location.x;
        Y_Single1 := PSort1.Location.y;
        Y_Single2 := PSort2.Location.y;
        PSort2.Duplicate := (Abs(X_Single1 - X_Single2) < 1e-5)
          and (Abs(Y_Single1 - Y_Single2) < 1e-5);
        if not PSort2.Duplicate then
        begin
          Inc(Count);
        end;
      end;

      // transfer X, Y, and Z to XArray, YArray, and ZArray.
      SetLength(XArray, Count);
      SetLength(YArray, Count);
      SetLength(ZArray, Count);

      SortIndex := 0;
      for Index := 0 to SortList.Count - 1 do
      begin
        if not SortArray[Index].Duplicate then
        begin
          XArray[SortIndex] := SortArray[Index].Location.X;
          YArray[SortIndex] := SortArray[Index].Location.Y;
          ZArray[SortIndex] := SortArray[Index].Value;
          Inc(SortIndex);
        end;
      end;
    finally
      SortList.Free;
    end;
  finally
    ListOfScreenObjects.Free;
  end;
  GetLimits(MinY, MaxY, MinX, MaxX, DataSet);
//  case DataSet.Orientation of
//    dsoTop, dsoFront:
//      begin
        FNatNeigh := TNaturalNeighborInterpolatorTripack.Create(
          XArray, YArray, ZArray, MinX, MinY, MaxX, MaxY);
//      end;
//    dsoSide:
//      begin
//        FNatNeigh := TNaturalNeighborInterpolatorTripack.Create(
//          YArray, XArray, ZArray, MinY, MinX, MaxY, MaxX);
//      end
//    else
//    begin
//      Assert(False);
//    end;
//  end;
end;

class function TNaturalNeighborInterp.ValidReturnTypes: TRbwDataTypes;
begin
  result := [rdtDouble];
end;

initialization
  RegisterClass(TNearest2DInterpolator);
  RegisterClass(TInvDistSq2DInterpolator);
  RegisterClass(TNearestPoint2DInterpolator);
  RegisterClass(TLinearSfrpackInterpolator);
  RegisterClass(TFittedSurfaceIntepolator);
  RegisterClass(TInvDistSqPoint2DInterpolator);
  RegisterClass(TNaturalNeighborInterp);

end.
