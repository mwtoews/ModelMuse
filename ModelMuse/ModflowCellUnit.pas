unit ModflowCellUnit;

interface

uses Windows, SysUtils, Classes, Contnrs, ZLib, GoPhastTypes;

type
  // @name defines a cell location.
  //  @longcode(
  //  TCellLocation = record
  //    Layer: integer;
  //    Row: integer;
  //    Column: integer;
  //  end;
  //  )
  // @member(Layer Layer is the layer in the grid to for this boundary.)
  // @member(Row Row is the row in the grid to for this boundary.)
  // @member(Column Column is the column in the grid to for this boundary.)
  TCellLocation = record
    Layer: integer;
    Row: integer;
    Column: integer;
    Section: integer;
  end;

  TValueCell = class(TObject)
  private
    FIFace: TIface;
    FScreenObject: TObject;
    procedure SetScreenObject(const Value: TObject);
  protected
    function GetColumn: integer; virtual; abstract;
    function GetLayer: integer; virtual; abstract;
    function GetRow: integer; virtual; abstract;
    function GetIntegerValue(Index: integer): integer; virtual; abstract;
    function GetRealValue(Index: integer): double; virtual; abstract;
    function GetRealAnnotation(Index: integer): string; virtual; abstract;
    function GetIntegerAnnotation(Index: integer): string; virtual; abstract;
    procedure Cache(Comp: TCompressionStream); virtual;
    procedure Restore(Decomp: TDecompressionStream;
      Annotations: TStringList); virtual;
    function GetSection: integer; virtual; abstract;
  public
    Constructor Create; virtual; 
    // @name is the layer number for this cell. Valid values range from 0 to
    // the number of layers in the grid minus 1.
    property Layer: integer read GetLayer;
    // @name is the row number for this cell. Valid values range from 0 to
    // the number of rows in the grid minus 1.
    property Row: integer read GetRow;
    // @name is the column number for this cell. Valid values range from 0 to
    // the number of columns in the grid minus 1.
    property Column: integer read GetColumn;
    property IntegerValue[Index: integer]: integer read GetIntegerValue;
    property RealValue[Index: integer]: double read GetRealValue;
    property RealAnnotation[Index: integer]: string read GetRealAnnotation;
    property IntegerAnnotation[Index: integer]: string read GetIntegerAnnotation;
    property IFace: TIface read FIFace write FIFace;
    // @name is the @link(TScreenObject) used to assign this
    // @classname.  @name is assigned in @link(TModflowBoundary.AssignCells).
    // @name is only assigned for boundary conditions that have
    // observations associated with them. (Drains, General head boundaries,
    // Rivers, and constant head cells.).
    property ScreenObject: TObject read FScreenObject write SetScreenObject;
    property Section: integer read GetSection;
  end;

  TValueCellType = class of TValueCell;

  TValueCellList = class(TObjectList)
  private
    FCachedCount: integer;
    FCached: Boolean;
    FTempFileNames: TStringList;
    FCleared: Boolean;
    FValueCellType: TValueCellType;
    FCondensedCount: integer;
    function GetCount: integer;
    procedure SetCount(const Value: integer);
    function GetItem(Index: integer): TValueCell;
    procedure SetItem(Index: integer; const Value: TValueCell);
    procedure Restore(Start: integer = 0);
    procedure Condense;
  public
    function Add(Item: TValueCell): integer;
    procedure Cache;
    procedure CheckRestore;
    Constructor Create(ValueCellType: TValueCellType);
    property Count: integer read GetCount write SetCount;
    property Items[Index: integer]: TValueCell read GetItem write SetItem; default;
    Destructor Destroy; override;
  end;

procedure WriteCompInt(Stream: TStream; Value: integer);
procedure WriteCompReal(Stream: TStream; Value: double);
procedure WriteCompString(Stream: TStream; Value: string);
procedure WriteCompCell(Stream: TStream; Cell: TCellLocation);

function ReadCompInt(Stream: TStream): integer;
function ReadCompReal(Stream: TStream): double;
function ReadCompString(Stream: TStream; Annotations: TStringList): string;
function ReadCompCell(Stream: TStream): TCellLocation;

implementation

uses TempFiles, ScreenObjectUnit, frmGoPhastUnit;

const
  MaxCondensed = 100;

procedure WriteCompInt(Stream: TStream; Value: integer);
begin
  Stream.Write(Value, SizeOf(Value));
end;

function ReadCompInt(Stream: TStream): integer;
begin
  Stream.Read(result, SizeOf(result));
end;

procedure WriteCompReal(Stream: TStream; Value: double);
begin
  Stream.Write(Value, SizeOf(Value));
end;

function ReadCompReal(Stream: TStream): double;
begin
  Stream.Read(result, SizeOf(result));
end;

procedure WriteCompString(Stream: TStream; Value: string);
var
  StringLength: integer;
begin
  StringLength := Length(Value);
  WriteCompInt(Stream, StringLength);
  Stream.WriteBuffer(Pointer(Value)^, StringLength * SizeOf(Char));
end;

function ReadCompString(Stream: TStream; Annotations: TStringList): string;
var
  CommentLength: Integer;
  StringPostion: integer;
begin
  Stream.Read(CommentLength, SizeOf(CommentLength));
  SetString(result, nil, CommentLength);
  Stream.Read(Pointer(result)^, CommentLength * SizeOf(Char));
  StringPostion := Annotations.IndexOf(result);
  if StringPostion < 0 then
  begin
    Annotations.Add(result);
  end
  else
  begin
    result := Annotations[StringPostion]
  end;
end;

procedure WriteCompCell(Stream: TStream; Cell: TCellLocation);
begin
  Stream.Write(Cell, SizeOf(Cell));
end;

function ReadCompCell(Stream: TStream): TCellLocation;
begin
  Stream.Read(result, SizeOf(result));
end;


{ TValueCellList }

function TValueCellList.Add(Item: TValueCell): integer;
begin
//  if FCached and fCleared then
//  begin
//    Restore;
//  end;
  FCached := False;
  result := inherited Add(Item);
end;

procedure TValueCellList.Condense;
var
  TempList: TList;
  Index: Integer;
begin
  if FCondensedCount >= MaxCondensed then
  begin
    FCondensedCount := 0;
  end;
  TempList := TList.Create;
  try
    TempList.Capacity := inherited Count;
    for Index := 0 to inherited Count - 1 do
    begin
      TempList.Add(inherited Items[Index])
    end;
    OwnsObjects := False;
    Clear;
    FCleared := True;
    OwnsObjects := True;
    FCached := True;
    Restore(FCondensedCount);
    for Index := 0 to TempList.Count - 1 do
    begin
      Add(TempList[Index]);
    end;
    Inc(FCondensedCount);
  finally
    TempList.Free;
  end;
end;

procedure TValueCellList.Cache;
var
  TempFile: TTempFileStream;
  Compressor: TCompressionStream;
  Index: Integer;
  Cell: TValueCell;
  LocalCount: integer;
  NewTempFileName: string;
begin
  LocalCount := inherited Count;
  if LocalCount > 0 then
  begin
    if FTempFileNames.Count  >= FCondensedCount + MaxCondensed then
    begin
      Condense;
      LocalCount := inherited Count;
    end;
    NewTempFileName := TempFileName;
    FTempFileNames.Add(NewTempFileName);
    TempFile := TTempFileStream.Create(NewTempFileName, fmOpenReadWrite);
    Compressor := TCompressionStream.Create(clDefault, TempFile);
    try
      FCachedCount := FCachedCount + LocalCount;
      WriteCompInt(Compressor, LocalCount);
      for Index := 0 to LocalCount - 1 do
      begin
        Cell := inherited Items[Index] as TValueCell;
        Cell.Cache(Compressor);
      end;
    finally
      Compressor.Free;
      TempFile.Free;
    end;
    FCached := True;
  end;
  Clear;
  FCleared := True;
end;

procedure TValueCellList.CheckRestore;
begin
  if FCached and FCleared then
  begin
    Restore;
  end;
end;

constructor TValueCellList.Create(ValueCellType: TValueCellType);
begin
  inherited Create;
  FTempFileNames := TStringList.Create;
  FValueCellType := ValueCellType;
end;

destructor TValueCellList.Destroy;
var
  Index: Integer;
begin
  for Index := 0 to FTempFileNames.Count - 1 do
  begin
    if FileExists(FTempFileNames[Index]) then
    begin
      DeleteFile(FTempFileNames[Index]);
    end;
  end;
  FTempFileNames.Free;
  inherited;
end;

function TValueCellList.GetCount: integer;
begin
  if FCached and FCleared then
  begin
    result := FCachedCount;
  end
  else
  begin
    result := inherited Count;
  end;
end;

function TValueCellList.GetItem(Index: integer): TValueCell;
begin
  CheckRestore;
  result := inherited Items[Index] as TValueCell;
end;

procedure TValueCellList.Restore(Start: integer = 0);
var
  TempFile: TTempFileStream;
  DecompressionStream: TDecompressionStream;
  ValueCell: TValueCell;
  Index: Integer;
  LocalCount : integer;
  CacheFileName: string;
  CellIndex: Integer;
  SumOfLocalCounts: integer;
  Annotations: TStringList;
begin
  Assert(FCached);
  Assert(FCleared);

  Annotations := TStringList.Create;
  try
    Annotations.Sorted := True;
    Capacity := FCachedCount;
    SumOfLocalCounts := 0;
    for Index := Start to FTempFileNames.Count -1 do
    begin
      CacheFileName := FTempFileNames[Index];
      Assert(FileExists(CacheFileName));
      TempFile := TTempFileStream.Create(CacheFileName, fmOpenRead);
      DecompressionStream := TDecompressionStream.Create(TempFile);
      try
        LocalCount := ReadCompInt(DecompressionStream);
        SumOfLocalCounts := SumOfLocalCounts + LocalCount;
        for CellIndex := 0 to LocalCount - 1 do
        begin
          ValueCell := FValueCellType.Create;
          inherited Add(ValueCell);
          ValueCell.Restore(DecompressionStream, Annotations);
        end;
      finally
        DecompressionStream.Free;
        TempFile.Free;
        DeleteFile(CacheFileName);
      end;
    end;
    FCleared := False;
    While FTempFileNames.Count > Start do
    begin
      FTempFileNames.Delete(FTempFileNames.Count-1);
    end;
    FCachedCount := FCachedCount - SumOfLocalCounts;
  finally
    Annotations.Free;
  end;
end;

procedure TValueCellList.SetCount(const Value: integer);
begin
  if FCached and FCleared then
  begin
    Restore;
  end;
  inherited Count := Value;
end;

procedure TValueCellList.SetItem(Index: integer; const Value: TValueCell);
begin
  inherited Items[Index] := Value;
end;

{ TValueCell }

procedure TValueCell.Cache(Comp: TCompressionStream);
begin
  Comp.Write(FIface, SizeOf(FIface));
  if ScreenObject = nil then
  begin
    WriteCompString(Comp, '');
  end
  else
  begin
    WriteCompString(Comp, TScreenObject(ScreenObject).Name);
  end;
end;

constructor TValueCell.Create;
begin

end;

procedure TValueCell.Restore(Decomp: TDecompressionStream;
  Annotations: TStringList);
var
  ScreenObjectName: string;
begin
  Decomp.Read(FIFace, SizeOf(FIFace));
  ScreenObjectName := ReadCompString(Decomp, Annotations);
  if ScreenObjectName = '' then
  begin
    ScreenObject := nil;
  end
  else
  begin
    ScreenObject := frmGoPhast.PhastModel.
      GetScreenObjectByName(ScreenObjectName);
    Assert(ScreenObject <> nil);
  end;
end;

procedure TValueCell.SetScreenObject(const Value: TObject);
begin
  if Value <> nil then
  begin
    Assert(Value is TScreenObject)
  end;
  FScreenObject := Value;
end;

end.
