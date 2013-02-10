unit frameSutraBoundaryUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, frameCustomSutraFeatureUnit,
  ArgusDataEntry, StdCtrls, Grids, RbwDataGrid4, Buttons, Mask,
  JvExMask, JvSpin, ExtCtrls, UndoItemsScreenObjects, SutraBoundariesUnit,
  GoPhastTypes;

type
  TSutraBoundaryGridColumns = (sbgtTime, sbgtUsed, sbgtVariable1, sbgtVariable2);

  TframeSutraBoundary = class(TframeCustomSutraFeature)
    pnlEditGrid: TPanel;
    lblFormula: TLabel;
    rdeFormula: TRbwDataEntry;
    procedure edNameChange(Sender: TObject);
    procedure seNumberOfTimesChange(Sender: TObject);
    procedure comboScheduleChange(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure edNameExit(Sender: TObject);
    procedure rdgSutraFeatureColSize(Sender: TObject; ACol,
      PriorWidth: Integer);
    procedure rdgSutraFeatureHorizontalScroll(Sender: TObject);
    procedure rdgSutraFeatureMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rdeFormulaChange(Sender: TObject);
    procedure rdgSutraFeatureSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure rdgSutraFeatureBeforeDrawCell(Sender: TObject; ACol,
      ARow: Integer);
    procedure rdgSutraFeatureEndUpdate(Sender: TObject);
  private
    FInitialTime: Double;
    FBoundaryType: TSutraBoundaryType;
    FBoundariesTheSame: Boolean;
    procedure GetScheduleName(BoundaryList: TSutraBoundaryList);
    procedure ClearBoundaries;
    procedure DisplayBoundaries(BoundColl: TCustomSutraBoundaryCollection);
    procedure SetBoundaryType(const Value: TSutraBoundaryType);
    procedure InitializeColumnHeadings;
    procedure GetBoundaryValues(BoundaryList: TSutraBoundaryList);
    procedure SetBoundaryValues(BoundValues: TCustomSutraBoundaryCollection);
    procedure AdjustBoundaryValues(SutraValues: TCustomSutraBoundaryCollection);
    procedure LayoutMultiEditControls;
    function GetValidTime(ACol, ARow: integer): Boolean;
    { Private declarations }
  public
    property BoundaryType: TSutraBoundaryType read FBoundaryType write SetBoundaryType;
    procedure GetData(ScreenObjects: TScreenObjectEditCollection); override;
    procedure SetData(ScreenObjects: TScreenObjectEditCollection; SetAll,
      ClearAll: boolean); override;
    { Public declarations }
  end;

var
  frameSutraBoundary: TframeSutraBoundary;

//procedure AdjustBoundaryTimes(TimeValues: TOneDRealArray;
//  Values: TCustomSutraBoundaryCollection);

implementation

uses
  ModflowBoundaryUnit, Generics.Collections, ScreenObjectUnit,
  frmGoPhastUnit, SutraTimeScheduleUnit,
  frmSutraTimeAdjustChoiceUnit, RealListUnit, frmCustomGoPhastUnit,
  SutraOptionsUnit;

resourcestring
  StrFluidSource = 'Fluid source';
  StrAssociatedConcentra = 'Associated concentration';
  StrAssociatedTemp = 'Associated temperature';
  StrSoluteSource = 'Solute source';
  StrEnergySouce = 'Energy source';
  StrSpecifiedPressure = 'Specified pressure';
  StrSpecifiedTemperatur = 'Specified temperature';
  StrSpecifiedConcentration = 'Specified concentration';
  StrTime = 'Time';
  StrUsed = 'Used';
  StrYouMustSpecifyAT = 'You must specify a time that is greater than or equ' +
  'al to the initial time.';
  StrYouMustSpecifyG = 'You must specify a time that is greater than ' +
  'the initial time.';

{$R *.dfm}

{ TframeCustomSutraBoundary }


procedure TframeSutraBoundary.GetData(
  ScreenObjects: TScreenObjectEditCollection);
var
  index: Integer;
  BoundaryList: TSutraBoundaryList;
  SutraBoundaries: TSutraBoundaries;
  ABoundary: TSutraBoundary;
begin
  inherited;
  FInitialTime := frmGoPhast.PhastModel.SutraTimeOptions.InitialTime;
  FGettingData := True;
  BoundaryList := TSutraBoundaryList.Create;
  try
    for index := 0 to ScreenObjects.Count - 1 do
    begin
      ABoundary := nil;
      SutraBoundaries := ScreenObjects[index].ScreenObject.SutraBoundaries;
      case BoundaryType of
        sbtFluidSource:
          begin
            ABoundary := SutraBoundaries.FluidSource;
          end;
        sbtMassEnergySource:
          begin
            ABoundary := SutraBoundaries.MassEnergySource;
          end;
        sbtSpecPress:
          begin
            ABoundary := SutraBoundaries.SpecifiedPressure;
          end;
        sbtSpecConcTemp:
          begin
            ABoundary := SutraBoundaries.SpecifiedConcTemp;
          end;
        else
          Assert(False);
      end;
      if ABoundary.Used then
      begin
        BoundaryList.Add(ABoundary);
      end;
    end;

    if BoundaryList.Count = 0 then
    begin
      FCheckState := cbUnchecked;
    end
    else if ScreenObjects.Count = BoundaryList.Count then
    begin
      FCheckState := cbChecked;
    end
    else
    begin
      FCheckState := cbGrayed;
    end;
    if Assigned(OnActivate) then
    begin
      OnActivate(self, FCheckState);
    end;

    if BoundaryList.Count = 0 then
    begin
      Exit;
    end;
    GetScheduleName(BoundaryList);
    GetBoundaryValues(BoundaryList);
    comboScheduleChange(nil);
//    CheckSchedule(BoundaryList);


  finally
    BoundaryList.Free;
    FGettingData := False;
  end;
end;

procedure TframeSutraBoundary.SetBoundaryType(
  const Value: TSutraBoundaryType);
begin
  FBoundaryType := Value;
  case FBoundaryType of
    sbtFluidSource:
      begin
        rdgSutraFeature.ColCount := 4;
      end;
    sbtMassEnergySource:
      begin
        rdgSutraFeature.ColCount := 3;
      end;
    sbtSpecPress:
      begin
        rdgSutraFeature.ColCount := 4;
      end;
    sbtSpecConcTemp:
      begin
        rdgSutraFeature.ColCount := 3;
      end;
    else Assert(False);
  end;
  InitializeColumnHeadings;

end;

procedure TframeSutraBoundary.SetData(
  ScreenObjects: TScreenObjectEditCollection; SetAll, ClearAll: boolean);
var
  BoundaryList: TSutraBoundaryList;
  index: integer;
  SutraBoundaries: TSutraBoundaries;
  ABoundary: TSutraBoundary;
  LocalScreenObjects: TList<TScreenObject>;
//  BoundaryName: string;
  BoundValues: TCustomSutraBoundaryCollection;
begin
  inherited;
  LocalScreenObjects := TList<TScreenObject>.Create;
  BoundaryList := TSutraBoundaryList.Create;
  try
    for index := 0 to ScreenObjects.Count - 1 do
    begin
      ABoundary := nil;
      SutraBoundaries := ScreenObjects[index].ScreenObject.SutraBoundaries;
      case BoundaryType of
        sbtFluidSource:
          begin
            ABoundary := SutraBoundaries.FluidSource;
          end;
        sbtMassEnergySource:
          begin
            ABoundary := SutraBoundaries.MassEnergySource;
          end;
        sbtSpecPress:
          begin
            ABoundary := SutraBoundaries.SpecifiedPressure;
          end;
        sbtSpecConcTemp:
          begin
            ABoundary := SutraBoundaries.SpecifiedConcTemp;
          end;
        else
          Assert(False);
      end;
      if ClearAll then
      begin
        ABoundary.Values.Clear;
      end
      else if SetAll or ABoundary.Used then
      begin
        BoundaryList.Add(ABoundary);
        LocalScreenObjects.Add(ScreenObjects[index].ScreenObject);
      end;
    end;

    for index := 0 to BoundaryList.Count - 1 do
    begin
      ABoundary := BoundaryList[index];
      BoundValues := ABoundary.Values as TCustomSutraBoundaryCollection;

//      if BoundaryList.Count = 1 then
//      begin
//        BoundaryName := Trim(edName.Text);
//        if BoundaryName = '' then
//        begin
//          BoundaryName := LocalScreenObjects.Items[index].Name;
//        end;
//        BoundValues.BoundaryName := AnsiString(BoundaryName);
//      end;

      if comboSchedule.ItemIndex > 0 then
      begin
        BoundValues.ScheduleName := AnsiString(comboSchedule.Text);
      end
      else
      begin
        BoundValues.ScheduleName := '';
      end;

      SetBoundaryValues(BoundValues);
    end;

  finally
    BoundaryList.Free;
    LocalScreenObjects.Free;
  end;
end;

function TframeSutraBoundary.GetValidTime(ACol, ARow: integer): Boolean;
var
  TestValue: Double;
  TestText: string;
begin
  result := True;
  if (ACol = Ord(sbgtTime)) and (ARow > 0) then
  begin
    TestText := rdgSutraFeature.Cells[ACol, ARow];
    if TryStrToFloat(TestText, TestValue) then
    begin
      case FBoundaryType of
        sbtFluidSource, sbtSpecPress:
          begin
            if TestValue < FInitialTime then
            begin
              result := False;
            end;
          end;
        sbtMassEnergySource, sbtSpecConcTemp:
          begin
            if TestValue <= FInitialTime then
            begin
              result := False;
            end;
          end;
      else
        Assert(False);
      end;
    end;
  end;
end;

procedure TframeSutraBoundary.AdjustBoundaryValues(
  SutraValues: TCustomSutraBoundaryCollection);
var
//  SutraValues: TCustomSutraBoundaryCollection;
  ASchedule: TSutraTimeSchedule;
//  SameValues: Boolean;
  TimeIndex: Integer;
//  Form: TfrmSutraTimeAdjustChoice;
//  AdjustChoice: TAdjustChoice;
  SutraTimeOptions: TSutraTimeOptions;
  TimeValues: TOneDRealArray;
  TimeList: TRealList;
  Item: TCustomBoundaryItem;
  TimePos: Integer;
begin
  SutraTimeOptions := frmGoPhast.PhastModel.SutraTimeOptions;
  ASchedule := comboSchedule.Items.Objects[comboSchedule.ItemIndex]
    as TSutraTimeSchedule;
  TimeValues := ASchedule.TimeValues(SutraTimeOptions.InitialTime,
     SutraTimeOptions.Schedules);

  TimeList := TRealList.Create;
  try
    for TimeIndex := 0 to Length(TimeValues) - 1 do
    begin
      TimeList.Add(TimeValues[TimeIndex]);
    end;
    TimeList.Sort;

    for TimeIndex := SutraValues.Count - 1 downto 0 do
    begin
      Item := SutraValues[TimeIndex];
      TimePos := TimeList.IndexOfClosest(Item.StartTime);
      Item.StartTime := TimeList[TimePos];
    end;

    for TimeIndex := SutraValues.Count - 1 downto 1 do
    begin
      if SutraValues[TimeIndex].StartTime = SutraValues[TimeIndex-1].StartTime then
      begin
        SutraValues.Delete(TimeIndex-1);
      end;
    end;
  finally
    TimeList.Free;
  end;

//  SameValues := Length(TimeValues) = SutraValues.Count;
//  if SameValues then
//  begin
//    for TimeIndex := 0 to SutraValues.Count - 1 do
//    begin
//      SameValues := TimeValues[TimeIndex] = SutraValues[TimeIndex].StartTime;
//      if not SameValues then
//      begin
//        break;
//      end;
//    end;
//  end;
//  if not SameValues then
//  begin
//    Beep;
//    Form := TfrmSutraTimeAdjustChoice.Create(nil);
//    try
//      Form.ShowModal;
//      AdjustChoice := Form.AdjustChoice;
//    finally
//      Form.Free;
//    end;
//    case AdjustChoice of
//      acUseSchedule:
//        begin
//          if Length(TimeValues) = SutraValues.Count then
//          begin
//            for TimeIndex := 0 to SutraValues.Count - 1 do
//            begin
//              SutraValues[TimeIndex].StartTime := TimeValues[TimeIndex];
//            end;
//          end
//          else
//          begin
//            AdjustBoundaryTimes(TimeValues, SutraValues);
//          end;
//          DisplayBoundaries(SutraValues);
//        end;
//      acConvert:
//        begin
//          comboSchedule.ItemIndex := 0;
//        end;
//    else
//      Assert(False);
//    end;
//  end;
end;

procedure TframeSutraBoundary.SetBoundaryValues(
  BoundValues: TCustomSutraBoundaryCollection);
var
  ColIndex: Integer;
  AssocItem: TCustomSutraAssociatedBoundaryItem;
  ItemIndex: Integer;
  RowIndex: Integer;
  BoundItem: TCustomSutraBoundaryItem;
  ATime: Extended;
  OK: Boolean;
begin
//  FSettingData := True;
//  try
    if seNumberOfTimes.AsInteger > 0 then
    begin
      ItemIndex := 0;
      for RowIndex := 1 to seNumberOfTimes.AsInteger do
      begin
        if TryStrToFloat(rdgSutraFeature.Cells[0, RowIndex], ATime) then
        begin
          OK := False;
          if not rdgSutraFeature.Checked[1, RowIndex] then
          begin
            OK := True;
          end
          else
          begin
            for ColIndex := 2 to rdgSutraFeature.ColCount - 1 do
            begin
              OK := rdgSutraFeature.Cells[ColIndex, RowIndex] <> '';
              if not OK then
              begin
                Break;
              end;
            end;
          end;
          if OK then
          begin
            if ItemIndex < BoundValues.Count then
            begin
              BoundItem := BoundValues.Items[ItemIndex] as TCustomSutraBoundaryItem;
            end
            else
            begin
              BoundItem := BoundValues.Add as TCustomSutraBoundaryItem;
            end;
            BoundItem.StartTime := ATime;
            BoundItem.Used := rdgSutraFeature.Checked[1, RowIndex];
            if BoundItem.Used then
            begin
              if BoundItem is TCustomSutraAssociatedBoundaryItem then
              begin
                AssocItem := TCustomSutraAssociatedBoundaryItem(BoundItem);
                AssocItem.PQFormula := rdgSutraFeature.Cells[2, RowIndex];
                AssocItem.UFormula := rdgSutraFeature.Cells[3, RowIndex];
              end
              else
              begin
                BoundItem.UFormula := rdgSutraFeature.Cells[2, RowIndex];
              end;
            end;
            Inc(ItemIndex);
          end;
        end;
      end;
      while BoundValues.Count > ItemIndex do
      begin
        BoundValues.Delete(BoundValues.Count - 1);
      end;
    end;
//  finally
//    FSettingData := False;
//  end;
end;

//procedure AdjustBoundaryTimes(TimeValues: TOneDRealArray;
//  Values: TCustomSutraBoundaryCollection);
//var
//  StartIndex: Integer;
//  TimeIndex: Integer;
//  Item: TCustomBoundaryItem;
//  InsertNewItem: Boolean;
//  DeleteItem: Boolean;
//  AnotherItem: TCustomBoundaryItem;
//  NewItem: TCustomBoundaryItem;
//  InsertPosition: integer;
//begin
//  StartIndex := Length(TimeValues)-1;
//  for TimeIndex := Values.Count - 1 downto 0 do
//  begin
//    if Length(TimeValues) = Values.Count then
//    begin
//      break;
//    end;
//    Item := Values[TimeIndex];
//    InsertNewItem := False;
//    DeleteItem := False;
//
//    InsertPosition := -1;
//    if (StartIndex < 0) then
//    begin
//      InsertNewItem := True;
//      InsertPosition := 0;
//    end
//    else if (Item.StartTime <> TimeValues[StartIndex]) then
//    begin
//      if Item.StartTime > TimeValues[StartIndex] then
//      begin
//        if (TimeIndex >= 1) then
//        begin
//          // Check if the item before this one has a starting time
//          // that is equal to or after the time value in the
//          // schedule. If so, delete this item.
//          AnotherItem := Values[TimeIndex-1];
//          if AnotherItem.StartTime >= TimeValues[StartIndex] then
//          begin
//            DeleteItem := True;
//          end;
//        end
//        else
//        begin
//          // this is the first item so you have to insert a new
//          // item.
//          InsertNewItem := True;
//          InsertPosition := 0;
//        end;
//      end
//      else
//      begin
//        // Item.StartTime is less than TimeValues[StartIndex]
//        if StartIndex >= 1 then
//        begin
//          if Item.StartTime <= TimeValues[StartIndex-1] then
//          begin
//            InsertNewItem := True;
//            InsertPosition := TimeIndex+1;
//          end;
//        end
//        else
//        begin
//          DeleteItem := True;
//        end;
//      end;
//    end;
//    if InsertNewItem then
//    begin
//      if (InsertPosition-1 >= 0) and (InsertPosition-1 < Values.Count) then
//      begin
//        AnotherItem := Values[InsertPosition-1]
//      end
//      else if (InsertPosition >= 0) and (InsertPosition < Values.Count) then
//      begin
//        AnotherItem := Values[InsertPosition]
//      end
//      else
//      begin
//        AnotherItem := nil;
//      end;
//      NewItem := Values.Insert(InsertPosition)
//        as TCustomBoundaryItem;
//      if AnotherItem <> nil then
//      begin
//        NewItem.Assign(AnotherItem);
//      end;
//      Dec(StartIndex);
//    end
//    else if DeleteItem then
//    begin
//      Values.Delete(TimeIndex);
//      // Don't decrement StartIndex.
//    end
//    else
//    begin
//      Dec(StartIndex);
//    end;
//  end;
//  if Values.Count > 0 then
//  begin
//    AnotherItem := Values[0];
//  end
//  else
//  begin
//    AnotherItem := nil;
//  end;
//  TimeIndex := Length(TimeValues) - Values.Count;
//  while TimeIndex > 0 do
//  begin
//    Dec(TimeIndex);
//    NewItem := Values.Insert(0) as TCustomBoundaryItem;
//    if AnotherItem <> nil then
//    begin
//      NewItem.Assign(AnotherItem);
//    end;
//  end;
//  while Values.Count > Length(TimeValues) do
//  begin
//    Values.Delete(Values.Count-1);
//  end;
//  for TimeIndex := 0 to Values.Count - 1 do
//  begin
//    Values[TimeIndex].StartTime := TimeValues[TimeIndex];
//  end;
//end;

procedure TframeSutraBoundary.btnDeleteClick(Sender: TObject);
begin
  inherited;
//
end;

procedure TframeSutraBoundary.btnInsertClick(Sender: TObject);
begin
  inherited;
//
end;
//
//procedure TframeSutraBoundary.CheckSchedule(
//  BoundaryList: TSutraBoundaryList);
//var
//  Values: TCustomSutraBoundaryCollection;
//  FirstBoundary: TSutraBoundary;
//begin
//  if FBoundariesTheSame and (comboSchedule.ItemIndex >= 1) then
//  begin
//    FirstBoundary := BoundaryList[0];
//    Values := FirstBoundary.Values as TCustomSutraBoundaryCollection;
//    AdjustBoundaryValues(Values);
//
//  end;
//end;

procedure TframeSutraBoundary.GetBoundaryValues(
  BoundaryList: TSutraBoundaryList);
var
  FirstBoundary: TSutraBoundary;
  Same: Boolean;
  BoundColl: TCustomSutraBoundaryCollection;
  Index: Integer;
  ABoundary: TSutraBoundary;
begin
  FirstBoundary := BoundaryList[0];
  BoundColl := FirstBoundary.Values as TCustomSutraBoundaryCollection;
  Same := True;
  for Index := 1 to BoundaryList.Count - 1 do
  begin
    ABoundary := BoundaryList[Index];
    Same := BoundColl.isSame(ABoundary.Values);
    if not Same then
    begin
      Break;
    end;
  end;
  FBoundariesTheSame := Same;
  if Same then
  begin
    if comboSchedule.ItemIndex >= 1 then
    begin
      AdjustBoundaryValues(BoundColl);
    end;
//    CheckSchedule(BoundaryList);
    DisplayBoundaries(BoundColl);
  end
  else
  begin
    ClearBoundaries;
  end;
end;

procedure TframeSutraBoundary.ClearBoundaries;
var
  ColIndex: Integer;
begin
  seNumberOfTimes.AsInteger := 0;
  rdgSutraFeature.RowCount := 2;
  for ColIndex := 0 to rdgSutraFeature.ColCount - 1 do
  begin
    rdgSutraFeature.Cells[ColIndex,1] := '';
  end;
  rdgSutraFeature.Checked[1,1] := False;
end;

procedure TframeSutraBoundary.comboScheduleChange(Sender: TObject);
var
  SutraTimeOptions: TSutraTimeOptions;
  ASchedule: TSutraTimeSchedule;
  TimeValues: TOneDRealArray;
  TimeIndex: Integer;
  PickList: TStrings;
  TimeList: TRealList;
  RowIndex: Integer;
  AValue: double;
  TimePos: Integer;
  Initialtime: Double;
begin
  inherited;
  if (comboSchedule.ItemIndex > 0) then
  begin
    SutraTimeOptions := frmGoPhast.PhastModel.SutraTimeOptions;
    ASchedule := comboSchedule.Items.Objects[comboSchedule.ItemIndex]
      as TSutraTimeSchedule;
    Initialtime := SutraTimeOptions.InitialTime;
    TimeValues := ASchedule.TimeValues(InitialTime,
       SutraTimeOptions.Schedules);

    PickList := rdgSutraFeature.Columns[0].PickList;
    PickList.Clear;
//    FSettingTimes := True;
    rdgSutraFeature.BeginUpdate;
    TimeList := TRealList.Create;
    try
      for TimeIndex := 0 to Length(TimeValues) - 1 do
      begin
        case FBoundaryType of
          sbtFluidSource, sbtSpecPress:
            begin
              TimeList.Add(TimeValues[TimeIndex]);
            end;
          sbtMassEnergySource, sbtSpecConcTemp:
            begin
              if TimeValues[TimeIndex] <> Initialtime then
              begin
                TimeList.Add(TimeValues[TimeIndex]);
              end;
            end;
        else
          Assert(False)
        end;

      end;
      TimeList.Sort;
      for TimeIndex := 0 to TimeList.Count - 1 do
      begin
        PickList.Add(FloatToStr(TimeList[TimeIndex]));
      end;

      for RowIndex := 1 to rdgSutraFeature.RowCount - 1 do
      begin
        if TryStrToFloat(rdgSutraFeature.Cells[0,RowIndex], AValue) then
        begin
          TimePos := TimeList.IndexOfClosest(AValue);
          if TimeList[TimePos] <> AValue then
          begin
            rdgSutraFeature.Cells[0,RowIndex] := FloatToStr(TimeList[TimePos]);
          end;
        end;
      end;
      for RowIndex := rdgSutraFeature.RowCount - 2 downto 1 do
      begin
        if rdgSutraFeature.Cells[0,RowIndex+1] = rdgSutraFeature.Cells[0,RowIndex] then
        begin
          rdgSutraFeature.DeleteRow(RowIndex+1);
        end;
      end;
    finally
      TimeList.Free;
      rdgSutraFeature.EndUpdate;
//      FSettingTimes := False;
    end;
    rdgSutraFeature.Columns[0].LimitToList := True;

//    if (seNumberOfTimes.AsInteger > 0) then
//    begin
//      BoundValues := nil;
//      try
//        case BoundaryType of
//          sbtFluidSource: BoundValues := TSutraFluidBoundaryCollection.Create(nil, nil, nil);
//          sbtMassEnergySource: BoundValues := TSutraMassEnergySourceSinkCollection.Create(nil, nil, nil);
//          sbtSpecPress: BoundValues := TSutraSpecifiedPressureCollection.Create(nil, nil, nil);
//          sbtSpecConcTemp: BoundValues := TSutraSpecifiedConcTempCollection.Create(nil, nil, nil);
//        end;
//        SetBoundaryValues(BoundValues);
//
//        if Length(TimeValues) = BoundValues.Count then
//        begin
//          for TimeIndex := 0 to BoundValues.Count - 1 do
//          begin
//            BoundValues[TimeIndex].StartTime := TimeValues[TimeIndex];
//          end;
//        end
//        else
//        begin
//          AdjustBoundaryTimes(TimeValues, BoundValues);
//        end;
//
//        DisplayBoundaries(BoundValues);
//      finally
//        BoundValues.Free;
//      end;
//  //    BoundValues: TCustomSutraBoundaryCollection
//    end
//    else
//    begin
//      FSettingTimes := True;
//      rdgSutraFeature.BeginUpdate;
//      try
//        seNumberOfTimes.AsInteger := Length(TimeValues);
//        for TimeIndex := 0 to Length(TimeValues) - 1 do
//        begin
//          rdgSutraFeature.Cells[0,TimeIndex+1] := FloatToStr(TimeValues[TimeIndex]);
//          rdgSutraFeature.Checked[1,TimeIndex+1] := True;
//        end;
//      finally
//        rdgSutraFeature.EndUpdate;
//        FSettingTimes := False;
//      end;
//    end;
  end
  else
  begin
    SutraTimeOptions := frmGoPhast.PhastModel.SutraTimeOptions;

    ASchedule := SutraTimeOptions.Schedules[0].Schedule;
    TimeValues := ASchedule.TimeValues(SutraTimeOptions.InitialTime,
       SutraTimeOptions.Schedules);

    PickList := rdgSutraFeature.Columns[0].PickList;
    PickList.Clear;
//    FSettingTimes := True;
    for TimeIndex := 0 to Length(TimeValues) - 1 do
    begin
      case FBoundaryType of
        sbtFluidSource, sbtSpecPress:
          begin
            PickList.Add(FloatToStr(TimeValues[TimeIndex]));
          end;
        sbtMassEnergySource, sbtSpecConcTemp:
          begin
            if TimeIndex <> 0 then
            begin
              PickList.Add(FloatToStr(TimeValues[TimeIndex]));
            end;
          end;
      else
        Assert(False)
      end;

    end;
    rdgSutraFeature.Columns[0].LimitToList := False;
  end;

end;

procedure TframeSutraBoundary.DisplayBoundaries(
  BoundColl: TCustomSutraBoundaryCollection);
var
  ItemIndex: Integer;
  Item: TCustomSutraBoundaryItem;
  AssocItem: TCustomSutraAssociatedBoundaryItem;
begin
//  FDisplayingData := True;
  rdgSutraFeature.BeginUpdate;
  try
    seNumberOfTimes.AsInteger := BoundColl.Count;
    rdgSutraFeature.RowCount := BoundColl.Count+1;
    for ItemIndex := 0 to BoundColl.Count - 1 do
    begin
      Item := BoundColl[ItemIndex] as TCustomSutraBoundaryItem;
      rdgSutraFeature.Cells[0,ItemIndex+1] := FloatToStr(Item.StartTime);
      rdgSutraFeature.Checked[1,ItemIndex+1] := Item.Used;
      if Item is TCustomSutraAssociatedBoundaryItem then
      begin
        if Item.Used then
        begin
          AssocItem := TCustomSutraAssociatedBoundaryItem(Item);
          rdgSutraFeature.Cells[2,ItemIndex+1] := AssocItem.PQFormula;
          rdgSutraFeature.Cells[3,ItemIndex+1] := AssocItem.UFormula;
        end
        else
        begin
          rdgSutraFeature.Cells[2,ItemIndex+1] := '';
          rdgSutraFeature.Cells[3,ItemIndex+1] := '';
        end;
      end
      else
      begin
        if Item.Used then
        begin
          rdgSutraFeature.Cells[2,ItemIndex+1] := Item.UFormula;
        end
        else
        begin
          rdgSutraFeature.Cells[2,ItemIndex+1] := '';
        end;
      end;
    end;
  finally
    rdgSutraFeature.EndUpdate;
//    FDisplayingData := False;
  end;
end;

procedure TframeSutraBoundary.edNameChange(Sender: TObject);
begin
  inherited;
  UpdateCheckState;
end;

procedure TframeSutraBoundary.edNameExit(Sender: TObject);
begin
  inherited;
//
end;

procedure TframeSutraBoundary.GetScheduleName(BoundaryList: TSutraBoundaryList);
var
  ScheduleName: AnsiString;
  Same: Boolean;
  FirstBoundary: TSutraBoundary;
  ABoundColl: TCustomSutraBoundaryCollection;
  BoundColl: TCustomSutraBoundaryCollection;
  Index: Integer;
  ABoundary: TSutraBoundary;
begin
  FirstBoundary := BoundaryList[0];
  BoundColl := FirstBoundary.Values as TCustomSutraBoundaryCollection;
  ScheduleName := BoundColl.ScheduleName;
  Same := True;
  for Index := 1 to BoundaryList.Count - 1 do
  begin
    ABoundary := BoundaryList[Index];
    ABoundColl := ABoundary.Values as TCustomSutraBoundaryCollection;
    Same := ScheduleName = ABoundColl.ScheduleName;
    if not Same then
    begin
      Break;
    end;
  end;
  SetScheduleIndex(ScheduleName, Same);
end;

procedure TframeSutraBoundary.InitializeColumnHeadings;
var
  NewColWidth: Integer;
  ColIndex: Integer;
  TransportChoice: TTransportChoice;
begin
  rdgSutraFeature.Cells[0,0] := StrTime;
  rdgSutraFeature.Cells[1,0] := StrUsed;

  NewColWidth := rdgSutraFeature.ClientWidth -
    (rdgSutraFeature.ColWidths[0] + rdgSutraFeature.ColWidths[1]);
  if rdgSutraFeature.ColCount = 4 then
  begin
    NewColWidth := (NewColWidth div 2) -20;
  end
  else
  begin
    NewColWidth := NewColWidth -20;
  end;

  for ColIndex := 2 to rdgSutraFeature.ColCount - 1 do
  begin
    rdgSutraFeature.ColWidths[ColIndex] := NewColWidth;
  end;

  TransportChoice := frmGoPhast.PhastModel.SutraOptions.TransportChoice;

  case FBoundaryType of
    sbtFluidSource:
      begin
        rdgSutraFeature.Cells[2,0] := StrFluidSource;
        case TransportChoice of
          tcSolute: rdgSutraFeature.Cells[3,0] := StrAssociatedConcentra;
          tcEnergy: rdgSutraFeature.Cells[3,0] := StrAssociatedTemp;
          else Assert(False);
        end;
      end;
    sbtMassEnergySource:
      begin
        case TransportChoice of
          tcSolute: rdgSutraFeature.Cells[2,0] := StrSoluteSource;
          tcEnergy: rdgSutraFeature.Cells[2,0] := StrEnergySouce;
          else Assert(False);
        end;
      end;
    sbtSpecPress:
      begin
        rdgSutraFeature.Cells[2,0] := StrSpecifiedPressure;
        case TransportChoice of
          tcSolute: rdgSutraFeature.Cells[3,0] := StrAssociatedConcentra;
          tcEnergy: rdgSutraFeature.Cells[3,0] := StrAssociatedTemp;
          else Assert(False);
        end;
      end;
    sbtSpecConcTemp:
      begin
        case TransportChoice of
          tcSolute: rdgSutraFeature.Cells[2,0] := StrSpecifiedConcentration;
          tcEnergy: rdgSutraFeature.Cells[2,0] := StrSpecifiedTemperatur;
          else Assert(False);
        end;
      end;
    else Assert(False);
  end;

  for ColIndex := 2 to rdgSutraFeature.ColCount - 1 do
  begin
    rdgSutraFeature.Columns[ColIndex].AutoAdjustColWidths := false;
  end;

end;

procedure TframeSutraBoundary.LayoutMultiEditControls;
var
  Col: Integer;
  Index: Integer;
begin
  if [csLoading, csReading] * ComponentState <> [] then
  begin
    Exit
  end;
  Col := 2;
  for Index := 2 to rdgSutraFeature.ColCount - 1 do
  begin
    if rdgSutraFeature.ColVisible[Index] then
    begin
      Col := Index;
      break;
    end;
  end;
  LayoutControls(rdgSutraFeature, rdeFormula, lblFormula, Col);

end;

procedure TframeSutraBoundary.rdeFormulaChange(Sender: TObject);
begin
  inherited;
  ChangeSelectedCellsInColumn(rdgSutraFeature, 2, rdeFormula.Text);
  if rdgSutraFeature.ColCount >= 4 then
  begin
    ChangeSelectedCellsInColumn(rdgSutraFeature, 3, rdeFormula.Text);
  end;
end;

procedure TframeSutraBoundary.rdgSutraFeatureBeforeDrawCell(Sender: TObject;
  ACol, ARow: Integer);
begin
  inherited;
  if not GetValidTime(ACol, ARow) then
  begin
    rdgSutraFeature.Canvas.Brush.Color := clRed;
  end;
end;

procedure TframeSutraBoundary.rdgSutraFeatureColSize(Sender: TObject; ACol,
  PriorWidth: Integer);
begin
  inherited;
  LayoutMultiEditControls;
end;

procedure TframeSutraBoundary.rdgSutraFeatureEndUpdate(Sender: TObject);
var
  RowIndex: Integer;
begin
  inherited;
  for RowIndex := 1 to rdgSutraFeature.RowCount - 1 do
  begin
    if not GetValidTime(Ord(sbgtTime), RowIndex) then
    begin
      case FBoundaryType of
        sbtFluidSource, sbtSpecPress:
          begin
            Beep;
            MessageDlg(StrYouMustSpecifyAT, mtError, [mbOK], 0);
            break;
          end;
        sbtMassEnergySource, sbtSpecConcTemp:
          begin
            Beep;
            MessageDlg(StrYouMustSpecifyG, mtError, [mbOK], 0);
            break;
          end;
        else Assert(False);
      end;
    end;
  end;

end;

procedure TframeSutraBoundary.rdgSutraFeatureHorizontalScroll(Sender: TObject);
begin
  inherited;
  LayoutMultiEditControls;
end;

procedure TframeSutraBoundary.rdgSutraFeatureMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if rdgSutraFeature.ColCount = 3 then
  begin
    EnableMultiEditControl(rdgSutraFeature, rdeFormula, 2);
  end
  else
  begin
    EnableMultiEditControl(rdgSutraFeature, rdeFormula, [2,3]);
  end;

end;

procedure TframeSutraBoundary.rdgSutraFeatureSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  inherited;
  if Value <> '' then
  begin
    seNumberOfTimes.AsInteger := rdgSutraFeature.RowCount -1;
  end;
end;

procedure TframeSutraBoundary.seNumberOfTimesChange(Sender: TObject);
begin
  inherited;
  UpdateCheckState;
end;

end.