unit LegendUnit;

interface

uses Classes, GoPhastTypes, ColorSchemes, DataSetUnit, ValueArrayStorageUnit,
  Math, Graphics, SysUtils, EdgeDisplayUnit, Types;

type
  TLegendType = (ltColor, ltContour);

  TValueAssignmentMethod = (vamNoLegend, vamAutomatic, vamManual);

  TLegend = class(TGoPhastPersistent)
  private
    FColoringLimits: TColoringLimits;
    FColorParameters: TColorParameters;
    FLegendType: TLegendType;
    FValues: TValueArrayStorage;
    FValueAssignmentMethod: TValueAssignmentMethod;
    FValueSource: TPersistent;
    FEdgeDataToPlot: integer;
    FFractions: TValueArrayStorage;
    StringValues: TStringList;
    procedure SetColoringLimits(const Value: TColoringLimits);
    procedure SetColorParameters(const Value: TColorParameters);
    procedure SetLegendType(const Value: TLegendType);
    procedure SetValues(const Value: TValueArrayStorage);
    procedure SetValueAssignmentMethod(const Value: TValueAssignmentMethod);
    procedure SetValueSource(const Value: TPersistent);
    procedure HasChanged(Sender: TObject);
    procedure SetEdgeDataToPlot(const Value: integer);
    procedure GetStringValues(StringValues: TStringList; DataArray: TDataArray);
    procedure SetFractions(const Value: TValueArrayStorage);
    procedure GetIntegerLimits(var MinInteger, MaxInteger: Integer;
      DataArray: TDataArray);
    procedure GetRealNumberLimits(var MinReal, MaxReal: real;
      DataArray: TDataArray);
    procedure GetRealLimitsForEdgeDisplay(var MinReal, MaxReal: real;
      EdgeDisplay: TCustomModflowGridEdgeDisplay);
  public
    procedure Assign(Source: TPersistent); override;
    Constructor Create(Model: TObject);
    destructor Destroy; override;
    property ValueSource: TPersistent read FValueSource write SetValueSource;
    procedure AutoAssignValues;
    procedure AssignFractions;
    procedure Draw(Canvas: TCanvas; StartX, StartY: integer;
      out LegendRect: TRect);
    property Fractions: TValueArrayStorage read FFractions write SetFractions;
  published
    property ColorParameters: TColorParameters read FColorParameters
      write SetColorParameters;
    property ColoringLimits: TColoringLimits read FColoringLimits
      write SetColoringLimits;
    property LegendType: TLegendType read FLegendType write SetLegendType;
    property Values: TValueArrayStorage read FValues write SetValues;
    property ValueAssignmentMethod: TValueAssignmentMethod
      read FValueAssignmentMethod write SetValueAssignmentMethod;
    property EdgeDataToPlot: integer read FEdgeDataToPlot
      write SetEdgeDataToPlot;
  end;

implementation

uses
  PhastModelUnit, RbwParser, frmGoPhastUnit;

{ TLegend }

procedure TLegend.Assign(Source: TPersistent);
var
  SourceLegend: TLegend;
begin
  if Source is TLegend then
  begin
    SourceLegend := TLegend(Source);
    ColorParameters := SourceLegend.ColorParameters;
    ColoringLimits := SourceLegend.ColoringLimits;
    LegendType := SourceLegend.LegendType;
    Values := SourceLegend.Values;
    ValueAssignmentMethod := SourceLegend.ValueAssignmentMethod;
    EdgeDataToPlot := SourceLegend.EdgeDataToPlot;
  end
  else
  begin
    inherited;
  end;
end;

procedure TLegend.AssignFractions;
var
  DataArray: TDataArray;
  Index: Integer;
  MinInteger: Integer;
  MaxInteger: Integer;
  IntRange: Integer;
  StringPos: Integer;
  PhastModel: TPhastModel;
  MinReal: real;
  MaxReal: real;
  RealRange: Double;
  EdgeDisplay: TCustomModflowGridEdgeDisplay;
  AFraction: double;
  Contours: TContours;
begin
  Assert(ValueSource <> nil);
  if (ValueSource is TDataArray) then
  begin
    DataArray := TDataArray(ValueSource);
    DataArray.Initialize;
    Fractions.Count := Values.Count;
    case DataArray.DataType of
      rdtDouble:
        begin
          if Fractions.Count = 1 then
          begin
            Fractions.RealValues[0] := 0.5
          end
          else
          begin
            case LegendType of
              ltColor:
                begin
                  GetRealNumberLimits(MinReal, MaxReal, DataArray);
                end;
              ltContour:
                begin
                  Contours := DataArray.Contours;
                  if Contours = nil then
                  begin
                    Exit;
//                    GetRealNumberLimits(MinReal, MaxReal, DataArray);
                  end
                  else
                  begin
                    if Contours.Count = 0 then
                    begin
                      Exit;
                    end;
                    MinReal := Contours.ContourValues[0];
                    MaxReal := Contours.ContourValues[
                      Length(Contours.ContourValues)-1];
                  end;
                end;
            end;
            if ColoringLimits.LogTransform then
            begin
              if (LegendType = ltContour) or (MinReal > 0) then
              begin
                if LegendType = ltColor then
                begin
                  MinReal := Log10(MinReal);
                  MaxReal := Log10(MaxReal);
                end;
                RealRange := MaxReal - MinReal;
                for Index := 0 to Values.Count - 1 do
                begin
                  AFraction := 1 - (Log10(Values.RealValues[Index]) - MinReal)/RealRange;
                  if AFraction < 0 then
                  begin
                    AFraction := 0;
                  end
                  else if AFraction > 1 then
                  begin
                    AFraction := 1;
                  end;
                  Fractions.RealValues[Index] := AFraction
                end;
              end;
            end
            else
            begin
              RealRange := MaxReal - MinReal;
              for Index := 0 to Values.Count - 1 do
              begin
                AFraction := 1 - (Values.RealValues[Index] - MinReal)/RealRange;
                if AFraction < 0 then
                begin
                  AFraction := 0;
                end
                else if AFraction > 1 then
                begin
                  AFraction := 1;
                end;
                Fractions.RealValues[Index] := AFraction
              end;
            end;
          end;
        end;
      rdtInteger:
        begin
          if Fractions.Count = 1 then
          begin
            Fractions.RealValues[0] := 0.5
          end
          else
          begin
            GetIntegerLimits(MinInteger, MaxInteger, DataArray);
            IntRange := MaxInteger - MinInteger;
            for Index := 0 to Values.Count - 1 do
            begin
              AFraction := 1 - (Values.IntValues[Index] - MinInteger)/IntRange;
              if AFraction < 0 then
              begin
                AFraction := 0;
              end
              else if AFraction > 1 then
              begin
                AFraction := 1;
              end;
              Fractions.RealValues[Index] := AFraction;
            end;
          end;
        end;
      rdtBoolean:
        begin
          if Values.Count = 1 then
          begin
            Fractions.RealValues[0] := 0.5;
          end
          else
          begin
            for Index := 0 to Values.Count - 1 do
            begin
              Fractions.RealValues[Index] := Ord(Values.BooleanValues[Index]);
            end;
          end;
        end;
      rdtString:
        begin
          if Fractions.Count = 1 then
          begin
            Fractions.RealValues[0] := 0.5
          end
          else
          begin
            StringValues := TStringList.Create;
            try
              GetStringValues(StringValues, DataArray);
              for Index := 0 to Values.Count - 1 do
              begin
                StringPos := StringValues.IndexOf(Values.StringValues[Index]);
                if StringPos < 0 then
                begin
                  StringPos := StringValues.Add(Values.StringValues[Index]);
                  StringValues.Delete(StringPos);
                  if StringPos = StringValues.Count then
                  begin
                    Dec(StringPos);
                  end;
                end;
                Fractions.RealValues[Index] := 1 - StringPos/(StringValues.Count -1);
              end;
            finally
              StringValues.Free;
            end;
          end;
        end;
      else Assert(False);
    end;
    PhastModel := frmGoPhast.PhastModel;
    PhastModel.AddDataSetToCache(DataArray);
    PhastModel.CacheDataArrays;
  end
  else
  begin
    EdgeDisplay := ValueSource as TCustomModflowGridEdgeDisplay;
    Fractions.Count := Values.Count;
    if Fractions.Count = 1 then
    begin
      Fractions.RealValues[0] := 0.5
    end
    else
    begin
      GetRealLimitsForEdgeDisplay(MinReal, MaxReal, EdgeDisplay);
      if ColoringLimits.LogTransform then
      begin
        if (MinReal > 0) and (MaxReal > 0) then
        begin
          MinReal := Log10(MinReal);
          MaxReal := Log10(MaxReal);
          RealRange := MaxReal - MinReal;
          for Index := 0 to Values.Count - 1 do
          begin
            AFraction := 1 - (Log10(Values.RealValues[Index]) - MinReal)/RealRange;
            if AFraction < 0 then
            begin
              AFraction := 0;
            end
            else if AFraction > 1 then
            begin
              AFraction := 1;
            end;
            Fractions.RealValues[Index] := AFraction
          end;
        end;
      end
      else
      begin
        RealRange := MaxReal - MinReal;
        for Index := 0 to Values.Count - 1 do
        begin
          AFraction := 1 - (Values.RealValues[Index] - MinReal)/RealRange;
          if AFraction < 0 then
          begin
            AFraction := 0;
          end
          else if AFraction > 1 then
          begin
            AFraction := 1;
          end;
          Fractions.RealValues[Index] := AFraction
        end;
      end;
    end;
  end;
end;

procedure TLegend.AutoAssignValues;
Const
  IntervalCount = 9;
var
  DataArray: TDataArray;
  EdgeDisplay: TCustomModflowGridEdgeDisplay;
  PhastModel: TPhastModel;
  Delta: extended;
  MaxReal: real;
  MinReal: real;
  Range: integer;
  Index: Integer;
  MaxInteger: Integer;
  MinInteger: Integer;
  IntegerIntervals: Integer;
  MaxBoolean: Boolean;
  MinBoolean: Boolean;
  StringValues: TStringList;
  MaxString: string;
  MinString: string;
  StringPos: Integer;
  Contours: TContours;
  DSIndex: Integer;
begin
  if (ValueAssignmentMethod = vamAutomatic) then
  begin
    Assert(ValueSource <> nil);
    if (ValueSource is TDataArray) then
    begin
      DataArray := TDataArray(ValueSource);
      Values.DataType := DataArray.DataType;
      DataArray.Initialize;
      case LegendType of
        ltColor:
          begin
            case DataArray.DataType of
              rdtDouble:
                begin
                  GetRealNumberLimits(MinReal, MaxReal, DataArray);

                  if MaxReal = MinReal then
                  begin
                    Values.Clear;
                    Values.Add(MaxReal);
                  end
                  else
                  begin
                    Values.Count := IntervalCount+1;

                    if ColoringLimits.LogTransform then
                    begin
                      if MinReal > 0 then
                      begin
                        MinReal := Log10(MinReal);
                        MaxReal := Log10(MaxReal);
                        Delta := (MaxReal - MinReal)/IntervalCount;
                        for Index := 0 to IntervalCount do
                        begin
                          Values.RealValues[Index] := Power(10,
                            MinReal + Delta*Index);
                        end;
                      end;
                    end
                    else
                    begin
                      Delta := (MaxReal - MinReal)/IntervalCount;
                      for Index := 0 to IntervalCount do
                      begin
                        Values.RealValues[Index] := MinReal
                          + Delta*Index
                      end;
                    end;
                  end;
                end;
              rdtInteger:
                begin
                  GetIntegerLimits(MinInteger, MaxInteger, DataArray);

                  if MaxInteger = MinInteger then
                  begin
                    Values.Clear;
                    Values.Add(MaxInteger);
                  end
                  else
                  begin
                    Range := MaxInteger-MinInteger;
                    IntegerIntervals := Min(Range,IntervalCount);
                    Values.Count := Min(Range,IntervalCount)+1;
                    for Index := 0 to Values.Count -1 do
                    begin
                      Values.IntValues[Index] := Round(MinInteger
                        + Range / IntegerIntervals * Index);
                    end;
                  end;
                end;
              rdtBoolean:
                begin
                  if ColoringLimits.UpperLimit.UseLimit then
                  begin
                    MaxBoolean := ColoringLimits.UpperLimit.BooleanLimitValue;
                  end
                  else
                  begin
                    MaxBoolean := True;
                  end;

                  if ColoringLimits.LowerLimit.UseLimit then
                  begin
                    MinBoolean := ColoringLimits.LowerLimit.BooleanLimitValue;
                  end
                  else
                  begin
                    MinBoolean := False;
                  end;

                  if MaxBoolean = MinBoolean then
                  begin
                    Values.Clear;
                    Values.Add(MaxBoolean);
                  end
                  else
                  begin
                    Values.Clear;
                    Values.Add(MinBoolean);
                    Values.Add(MaxBoolean);
                  end;
                end;
              rdtString:
                begin
                  if ColoringLimits.UpperLimit.UseLimit then
                  begin
                    MaxString := ColoringLimits.UpperLimit.StringLimitValue;
                  end
                  else
                  begin
                    MaxString := DataArray.MaxString;
                  end;

                  if ColoringLimits.LowerLimit.UseLimit then
                  begin
                    MinString := ColoringLimits.LowerLimit.StringLimitValue;
                  end
                  else
                  begin
                    MinString := DataArray.MinString;
                  end;

                  if MaxString = MinString then
                  begin
                    Values.Clear;
                    Values.Add(MaxString);
                  end
                  else
                  begin
                    StringValues := TStringList.Create;
                    try
                      GetStringValues(StringValues, DataArray);

                      MinInteger := 0;
                      MaxInteger := StringValues.Count -1;

                      Range := MaxInteger-MinInteger;
                      IntegerIntervals := Min(Range,IntervalCount);
                      Values.Count := Min(Range,IntervalCount)+1;
                      for Index := 0 to Values.Count -1 do
                      begin
                        StringPos := MinInteger
                          + (Range div IntegerIntervals) * Index;
                        Values.StringValues[Index] := StringValues[StringPos];
                      end;
                    finally
                      StringValues.Free;
                    end;
                  end;
                end;
              else Assert(False)
            end;
          end;
        ltContour:
          begin
            Contours := DataArray.Contours;
            if Contours <> nil then
            begin
              Values.Count := Contours.Count;
              case DataArray.DataType of
                rdtDouble:
                  begin
                    if ColoringLimits.LogTransform then
                    begin
                      MinReal := Contours.ContourValues[0];
                      if MinReal > 0 then
                      begin
                        for Index := 0 to Contours.Count - 1 do
                        begin
                          Values.RealValues[Index] := Power(10,Contours.ContourValues[Index]);
                        end;
                      end;
                    end
                    else 
                    begin
                      for Index := 0 to Contours.Count - 1 do
                      begin
                        Values.RealValues[Index] := Contours.ContourValues[Index]
                      end;
                    end;
                  end;
                rdtInteger:
                  begin
                    for Index := 0 to Contours.Count - 1 do
                    begin
                      Values.IntValues[Index] := Round(Contours.ContourValues[Index]);
                    end;
                  end;
                rdtBoolean:
                  begin
                    if Contours.Count = 1 then
                    begin
                      Values.BooleanValues[0] := False;
                    end
                    else if Contours.Count <> 0 then
                    begin
                      Assert(False);
                    end;
                  end;
                  rdtString:
                    begin
                      for Index := 0 to Contours.Count - 1 do
                      begin
                        DSIndex := Round(Contours.ContourValues[Index]);
                        Values.StringValues[Index] :=
                          Contours.ContourStringValues[DSIndex]
                      end;
                    end;
                else
                  Assert(False);
              end;
            end;
          end;
        else
          Assert(False);
      end;
      PhastModel := frmGoPhast.PhastModel;
      PhastModel.AddDataSetToCache(DataArray);
      PhastModel.CacheDataArrays;
    end
    else
    begin
      Assert(ValueSource is TCustomModflowGridEdgeDisplay);
      EdgeDisplay := TCustomModflowGridEdgeDisplay(ValueSource);
      EdgeDisplay.UpdateData;
      Values.DataType := rdtDouble;
      GetRealLimitsForEdgeDisplay(MinReal, MaxReal, EdgeDisplay);

      if MaxReal = MinReal then
      begin
        Values.Clear;
        Values.Add(MaxReal);
      end
      else
      begin
        Values.Count := IntervalCount+1;
        Delta := (MaxReal - MinReal)/IntervalCount;
        for Index := 0 to IntervalCount do
        begin
          Values.RealValues[Index] := MinReal
            + Delta*Index
        end;
      end;
    end;
  end;
end;

procedure TLegend.GetStringValues(StringValues: TStringList;
  DataArray: TDataArray);
var
  RowIndex: Integer;
  LayerIndex: Integer;
  ColIndex: Integer;
  MaxString: string;
  MinString: string;
  StringPos: Integer;
  Index: Integer;
begin
  DataArray.Initialize;

  if ColoringLimits.UpperLimit.UseLimit then
  begin
    MaxString := ColoringLimits.UpperLimit.StringLimitValue;
  end
  else
  begin
    MaxString := DataArray.MaxString;
  end;

  if ColoringLimits.LowerLimit.UseLimit then
  begin
    MinString := ColoringLimits.LowerLimit.StringLimitValue;
  end
  else
  begin
    MinString := DataArray.MinString;
  end;

  StringValues.Clear;
  StringValues.CaseSensitive := False;
  StringValues.Duplicates := dupIgnore;
  StringValues.Sorted := True;
  StringValues.Capacity := DataArray.LayerCount
    * DataArray.RowCount * DataArray.ColumnCount;
  for LayerIndex := 0 to DataArray.LayerCount - 1 do
  begin
    for RowIndex := 0 to DataArray.RowCount - 1 do
    begin
      for ColIndex := 0 to DataArray.ColumnCount - 1 do
      begin
        if DataArray.IsValue[LayerIndex, RowIndex, ColIndex] then
        begin
          StringValues.Add(DataArray.StringData[LayerIndex, RowIndex, ColIndex]);
        end;
      end;
    end;
  end;

  if StringValues[StringValues.Count -1] <> MaxString then
  begin
    StringPos := StringValues.IndexOf(MaxString);
    Assert(StringPos >= 0);
    for Index := StringValues.Count -1 downto StringPos + 1 do
    begin
      StringValues.Delete(Index);
    end;
  end;

  StringPos := StringValues.IndexOf(MinString);
  Assert(StringPos >= 0);
  if StringPos > 0 then
  begin
    for Index := StringPos-1 downto 0 do
    begin
      StringValues.Delete(Index);
    end;
  end;
end;

constructor TLegend.Create(Model: TObject);
begin
  inherited;
  FValueSource := nil;
  FValues := TValueArrayStorage.Create;
  FFractions := TValueArrayStorage.Create;
  FFractions.DataType := rdtDouble;
  FColoringLimits := TColoringLimits.Create;
  FColorParameters := TColorParameters.Create;

  FColoringLimits.OnChange := HasChanged;
  FColorParameters.OnChange := HasChanged;
end;

destructor TLegend.Destroy;
begin
  FColorParameters.Free;
  FColoringLimits.Free;
  FFractions.Free;
  FValues.Free;
  inherited;
end;

procedure TLegend.Draw(Canvas: TCanvas; StartX, StartY: integer;
  out LegendRect: TRect);
var
  Index: Integer;
  X: Integer;
  AColor: TColor;
  Y: Integer;
  YLine: Integer;
  LegendText: string;
  TextHeight: Integer;
  TextX: Integer;
  DeltaY: integer;
  BoxWidth: integer;
  TextSeparation: integer;
  ARect: TRect;
  Extent: TSize;
begin
  LegendRect.Top := StartY;
  LegendRect.Left := StartX;
  LegendRect.BottomRight := LegendRect.TopLeft;

  TextHeight := Canvas.TextHeight('0');
  DeltaY := (TextHeight * 3) div 2;
  BoxWidth := DeltaY * 2;
  TextSeparation := DeltaY div 2;
  X := StartX;
  TextX := X + BoxWidth + TextSeparation;

  Canvas.Pen.Color := clBlack;

  case LegendType of
    ltColor: LegendText := 'Color legend';
    ltContour: LegendText := 'Contour legend';
    else Assert(False);
  end;
  Extent := Canvas.TextExtent(LegendText);
  ARect.Left := StartX;
  ARect.Top := StartY;
  ARect.Right := TextX + Extent.cx;
  ARect.Bottom := StartY + Extent.cy;
  UnionRect(LegendRect, LegendRect, ARect);

  Canvas.TextOut(X, StartY, LegendText);
  StartY := StartY + DeltaY;

  for Index := 0 to Values.Count - 1 do
  begin
    AColor := ColorParameters.FracToColor(Fractions.RealValues[Index]);
    Y := StartY + DeltaY*Index;
    Canvas.Brush.Color := AColor;
    case LegendType of
      ltColor:
        begin
          ARect := Rect(X,Y,X+BoxWidth,Y+DeltaY);
        end;
      ltContour:
        begin
          Canvas.Pen.Color := AColor;
          YLine := Y + DeltaY div 2;
          ARect := Rect(X,YLine-1,X+BoxWidth,YLine+1);
        end;
      else Assert(False);
    end;
    Canvas.Rectangle(ARect);
    UnionRect(LegendRect, LegendRect, ARect);

    Canvas.Brush.Color := clWhite;
    Y := Y + ((DeltaY - TextHeight) div 2);

    case Values.DataType of
      rdtDouble:
        begin
          if ColoringLimits.LogTransform then
          begin
            LegendText := FloatToStrF(Values.RealValues[Index], ffGeneral, 7, 0);
          end
          else
          begin
            LegendText := FloatToStrF(Values.RealValues[Index], ffGeneral, 7, 0);
          end;
        end;
      rdtInteger:
        begin
          LegendText := IntToStr(Values.IntValues[Index])
        end;
      rdtBoolean: 
        begin
          if Values.BooleanValues[Index] then
          begin
            LegendText := 'True';
          end
          else
          begin
            LegendText := 'False';
          end;
        end;
      rdtString:
        begin
          LegendText := Values.StringValues[Index];
        end;
      else Assert(False);
    end;

    Extent := Canvas.TextExtent(LegendText);
    ARect.Left := TextX;
    ARect.Top := Y;
    ARect.Right := TextX + Extent.cx;
    ARect.Bottom := Y + Extent.cy;
    UnionRect(LegendRect, LegendRect, ARect);

    Canvas.TextOut(TextX, Y, LegendText);
  end;
end;

procedure TLegend.GetRealLimitsForEdgeDisplay(var MinReal, MaxReal: real;
  EdgeDisplay: TCustomModflowGridEdgeDisplay);
var
  Index: Integer;
  Edge: TCustomModflowGridEdgeFeature;
begin
  MaxReal := 0;
  MinReal := 0;
  for Index := 0 to EdgeDisplay.Count - 1 do
  begin
    Edge := EdgeDisplay.Edges[Index];
    if Index = 0 then
    begin
      MaxReal := Edge.RealValue[EdgeDataToPlot];
      MinReal := MaxReal;
    end
    else
    begin
      if MaxReal < Edge.RealValue[EdgeDataToPlot] then
      begin
        MaxReal := Edge.RealValue[EdgeDataToPlot];
      end;
      if MinReal > Edge.RealValue[EdgeDataToPlot] then
      begin
        MinReal := Edge.RealValue[EdgeDataToPlot];
      end;
    end;
  end;
  if ColoringLimits.UpperLimit.UseLimit then
  begin
    MaxReal := ColoringLimits.UpperLimit.RealLimitValue;
  end;
  if ColoringLimits.LowerLimit.UseLimit then
  begin
    MinReal := ColoringLimits.LowerLimit.RealLimitValue;
  end;
end;

procedure TLegend.GetRealNumberLimits(var MinReal, MaxReal: real;
  DataArray: TDataArray);
var
  MinPositive: Real;
begin
  frmGoPhast.Grid.GetRealMinMax(DataArray, MinReal, MaxReal, MinPositive);
  if ColoringLimits.LogTransform then
  begin
    MinReal := MinPositive;
  end;
//  if ColoringLimits.UpperLimit.UseLimit then
//  begin
//    MaxReal := ColoringLimits.UpperLimit.RealLimitValue;
//  end
//  else
//  begin
//    MaxReal := DataArray.MaxReal;
//  end;
//  if ColoringLimits.LowerLimit.UseLimit then
//  begin
//    MinReal := ColoringLimits.LowerLimit.RealLimitValue;
//  end
//  else
//  begin
//    MinReal := DataArray.MinReal;
//  end;
end;

procedure TLegend.GetIntegerLimits(var MinInteger, MaxInteger: Integer;
  DataArray: TDataArray);
begin
  if ColoringLimits.UpperLimit.UseLimit then
  begin
    MaxInteger := ColoringLimits.UpperLimit.IntegerLimitValue;
  end
  else
  begin
    MaxInteger := DataArray.MaxInteger;
  end;
  if ColoringLimits.LowerLimit.UseLimit then
  begin
    MinInteger := ColoringLimits.LowerLimit.IntegerLimitValue;
  end
  else
  begin
    MinInteger := DataArray.MinInteger;
  end;
end;

procedure TLegend.HasChanged(Sender: TObject);
begin
  InvalidateModel;
end;

procedure TLegend.SetColoringLimits(const Value: TColoringLimits);
begin
  FColoringLimits.Assign(Value);
end;

procedure TLegend.SetColorParameters(const Value: TColorParameters);
begin
  FColorParameters.Assign(Value);
end;

procedure TLegend.SetEdgeDataToPlot(const Value: integer);
begin
  if FEdgeDataToPlot <> Value then
  begin
    FEdgeDataToPlot := Value;
    InvalidateModel;
  end;
end;

procedure TLegend.SetFractions(const Value: TValueArrayStorage);
begin
  FFractions.Assign(Value);
end;

procedure TLegend.SetLegendType(const Value: TLegendType);
begin
  if FLegendType <> Value then
  begin
    FLegendType := Value;
    InvalidateModel;
  end;
end;

procedure TLegend.SetValueAssignmentMethod(const Value: TValueAssignmentMethod);
begin
  if FValueAssignmentMethod <> Value then
  begin
    FValueAssignmentMethod := Value;
    InvalidateModel;
  end;
end;

procedure TLegend.SetValues(const Value: TValueArrayStorage);
begin
  FValues.Assign(Value);
end;

procedure TLegend.SetValueSource(const Value: TPersistent);
begin
  if FValueSource <> Value then
  begin
    if Value <> nil then
    begin
      Assert((Value is TDataArray) or (Value is TCustomModflowGridEdgeDisplay));
    end;
    FValueSource := Value;
    InvalidateModel;
  end;
end;

end.