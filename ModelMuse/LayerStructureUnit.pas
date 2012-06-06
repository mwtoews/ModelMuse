unit LayerStructureUnit;

interface

uses OrderedCollectionUnit, Classes, GoPhastTypes, SubscriptionUnit,
  ModflowSubsidenceDefUnit;

type
  TIntTypeMethod = (itmLaytype, itmLayavg, itmLayvka);
  TFloatTypeMethod = (ftmTrpy, ftmTrtp, ftmTrpv, ftmDmcoef);

  TLayerCollection = class;

  TLayerFraction = class(TCollectionItem)
  private
    FFraction: real;
    procedure InvalidateModel;
    procedure SetFraction(const Value: real);
    function IsSame(AnotherLayerFraction: TLayerFraction): boolean;
  public
    function Collection: TLayerCollection;
    procedure Assign(Source: TPersistent); override;
  published
    property Fraction: real read FFraction write SetFraction;
  end;

  TCustomLayerGroup = class;
  TLayerGroup = class;

  TLayerCollection  = class(TCollection)
  Private
    FLayerGroup: TCustomLayerGroup;
    procedure InvalidateModel;
    procedure Sort;
  public
    function IsSame(AnotherLayerCollection: TLayerCollection): boolean;
    procedure Assign(Source: TPersistent); override;
    constructor Create(LayerGroup: TCustomLayerGroup);
  end;

  TCustomLayerStructure = class;
  TLayerStructure = class;

  TCustomLayerGroup = class(TOrderedItem)
  private
    FDataArrayName: string;
    FAquiferName: string;
    FGrowthMethod: TGrowthMethod;
    FGrowthRate: real;
    {@name defines the layer or layers in @classname.}
    FLayerCollection: TLayerCollection;
    procedure SetDataArrayName(const NewName: string);
    procedure SetAquiferName(const Value: string);
    procedure SetGrowthMethod(const Value: TGrowthMethod);
    procedure SetGrowthRate(const Value: real);
    function EvalAt: TEvaluatedAt; virtual;
  protected
    procedure SetLayerCollection(const Value: TLayerCollection); virtual;
    function Collection: TCustomLayerStructure;
    function IsSame(AnotherItem: TOrderedItem): boolean; override;
    procedure Loaded; virtual;
    function StoreLayerCollection: boolean; virtual;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
    function LayerCount: integer; virtual;
  published
    property DataArrayName: string read FDataArrayName write SetDataArrayName;
    property AquiferName: string read FAquiferName write SetAquiferName;
    {
    When a layer group is split into more than one layer, @name defines
    how the thickness of those layers is specified.
    }
    property GrowthMethod: TGrowthMethod read FGrowthMethod
      write SetGrowthMethod;
    {
    When @link(GrowthMethod) is  @link(TGrowthMethod gmUp),
    @link(TGrowthMethod gmDown),
    @link(TGrowthMethod gmMiddle), or @link(TGrowthMethod gmEdge),
    @name is used to help define
    how the thickness of those layers is calculated.
    }
    property GrowthRate: real read FGrowthRate write SetGrowthRate;
    {@name defines the layer or layers in @classname.}
    property LayerCollection: TLayerCollection read FLayerCollection
      write SetLayerCollection stored StoreLayerCollection;
  end;

  TLayerGroup = class(TCustomLayerGroup)
  private
    FSimulated: boolean;
    FAquiferType: integer;
    FInterblockTransmissivityMethod: integer;
    FVerticalHydraulicConductivityMethod: integer;
    FUseStartingHeadForSaturatedThickness: boolean;
    FHorizontalAnisotropy: double;
    FSubNoDelayBedLayers: TSubNoDelayBedLayers;
    FSubDelayBedLayers: TSubDelayBedLayers;
    FWaterTableLayers: TWaterTableLayers;
    FMt3dmsHorzTransDisp: TRealCollection;
    FMt3dmsDiffusionCoef: TRealCollection;
    FMt3dmsVertTransDisp: TRealCollection;
    procedure SetSimulated(const Value: boolean);
    procedure SetAquiferType(const Value: integer);
    procedure SetInterblockTransmissivityMethod(const Value: integer);
    procedure SetVerticalHydraulicConductivityMethod(const Value: integer);
    procedure SetUseStartingHeadForSaturatedThickness(const Value: boolean);
    function GetSimulated: boolean;
    procedure SetHorizontalAnisotropy(const Value: double);
    procedure SetSubDelayBedLayers(const Value: TSubDelayBedLayers);
    procedure SetSubNoDelayBedLayers(const Value: TSubNoDelayBedLayers);
    function SubsidenceLayerCount(SubLayers: TCustomSubLayer): integer;
    procedure SetWaterTableLayers(const Value: TWaterTableLayers);
    procedure UpdateChildModels(PriorCount: Integer);
    procedure SetMt3dmsDiffusionCoef(const Value: TRealCollection);
    procedure SetMt3dmsHorzTransDisp(const Value: TRealCollection);
    procedure SetMt3dmsVertTransDisp(const Value: TRealCollection);
  protected
    procedure Loaded; override;
    procedure SetLayerCollection(const Value: TLayerCollection); override;
    function IsSame(AnotherItem: TOrderedItem): boolean; override;
    function StoreLayerCollection: boolean; override;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(Collection: TCollection); override;
    Destructor Destroy; override;
    function LayerCount: integer; override;
    function ModflowLayerCount: integer;
    procedure WriteLAYCB(const DiscretizationWriter: TObject);
    function SubsidenceDefined: boolean;
    function SwtDefined: boolean;
    function DelayCount: integer;
    function NoDelayCount: integer;
    function WaterTableCount: integer;
  published
    { @name can take on the following values:
     @unorderedlist(
       @item(0, confined)
       @item(1, convertible in LPF and HUF, Unconfined in BCF)
       @item(2, limited convertible in BCF with constant transmissivity)
       @item(3, fully convertible in BCF with variable transmissivity)
      )
      2 and 3 are not defined for LPF and HUF.
    }
    property AquiferType: integer read FAquiferType write SetAquiferType;
    property Simulated: boolean read GetSimulated write SetSimulated;
    // @name represents the first digit of Ltype in the BCF package
    // and LAYAVG in the LPF package. @name is not used in the HUF package.
    // However, Ltype and LAYAVG are not defined in exactly the same way
    // Ltype = 1 in BCF means use an arithmetic mean.  There is no such
    // option in LPF. Options 2 and 3 in BCF correspond to 1 and 2 in LPF.
    property InterblockTransmissivityMethod: integer
      read FInterblockTransmissivityMethod
      write SetInterblockTransmissivityMethod;
    property VerticalHydraulicConductivityMethod: integer
      read FVerticalHydraulicConductivityMethod
      write SetVerticalHydraulicConductivityMethod;
    property UseStartingHeadForSaturatedThickness: boolean
      read FUseStartingHeadForSaturatedThickness
      write SetUseStartingHeadForSaturatedThickness;
    // TRPY in the BCF package.
    property HorizontalAnisotropy: double read FHorizontalAnisotropy
      write SetHorizontalAnisotropy;
    property SubNoDelayBedLayers: TSubNoDelayBedLayers
      read FSubNoDelayBedLayers write SetSubNoDelayBedLayers;
    property SubDelayBedLayers: TSubDelayBedLayers
      read FSubDelayBedLayers write SetSubDelayBedLayers;
    property WaterTableLayers: TWaterTableLayers read FWaterTableLayers
      write SetWaterTableLayers;
    property Mt3dmsHorzTransDisp: TRealCollection read FMt3dmsHorzTransDisp
      write SetMt3dmsHorzTransDisp;
    property Mt3dmsVertTransDisp: TRealCollection read FMt3dmsVertTransDisp
      write SetMt3dmsVertTransDisp;
    property Mt3dmsDiffusionCoef: TRealCollection read FMt3dmsDiffusionCoef
      write SetMt3dmsDiffusionCoef;
  end;

  TSutraLayerGroup = class(TCustomLayerGroup)
  protected
    function EvalAt: TEvaluatedAt; override;

  end;

  TCustomLayerStructure = class(TLayerOwnerCollection)
  public
    function LayerCount: integer;
    procedure Loaded; virtual;
  end;

  TLayerStructure = class(TCustomLayerStructure)
  Private
    FSimulatedNotifier: TObserver;
    FAquiferTypeNotifier: TObserver;
    function GetLayerGroup(const Index: integer): TLayerGroup;
    function IntegerArray(Method: TIntTypeMethod): TOneDIntegerArray;
    function FloatArray(Method: TFloatTypeMethod): TOneDRealArray;
  public
//    function First: TLayerGroup;
    function Last: TLayerGroup;
    function NonSimulatedLayersPresent: boolean;
    procedure AssignAssociatedInputDataSets;
    procedure Assign(Source: TPersistent);override;
    constructor Create(Model: TBaseModel);
    destructor Destroy; override;
    property LayerGroups[const Index: integer]: TLayerGroup
      read GetLayerGroup; default;
    procedure Loaded; override;
    function ModflowLayerCount: integer;
    function ModflowConfiningBedCount: integer;
    procedure WriteLAYCB(const DiscretizationWriter: TObject);
    function ModflowLayerBottomDescription(const LayerID: integer): string;
    // @name returns true if a layer in the grid is simulated
    // LayerID is zero-based.
    function IsLayerSimulated(const LayerID: integer): boolean;
    Function Laytyp: TOneDIntegerArray;
    Function Layavg: TOneDIntegerArray;
    function Chani: TOneDIntegerArray;
    Function Layvka: TOneDIntegerArray;
    function Trpy: TOneDRealArray;
    // @name converts a MODFLOW model layer (starting at 1) to the
    // appropriate index in a 3D data array;
    Function ModflowLayerToDataSetLayer(ModflowLayer: integer): integer;
    function DataSetLayerToModflowLayer(DataSetLayer: integer): integer;
    //  @name returns the @link(TLayerGroup) that contains Layer.
    // Layer is zero-based.
    function GetLayerGroupByLayer(const Layer: integer): TLayerGroup;
    property SimulatedNotifier: TObserver read FSimulatedNotifier;
    property AquiferTypeNotifier: TObserver read FAquiferTypeNotifier;
    procedure StopTalkingToAnyone;
    function SubsidenceDefined: boolean;
    function SwtDefined: boolean;
    function DelayCount: integer;
    function NoDelayCount: integer;
    function WaterTableCount: integer;
    Function TRPT: TOneDRealArray;
    function TRPV: TOneDRealArray;
    Function DMCOEF: TOneDRealArray;
  end;

  TSutraLayerStructure = class(TCustomLayerStructure)
  private
    function GetLayerGroup(const Index: integer): TSutraLayerGroup;
  published
  public
    constructor Create(Model: TBaseModel);
    property LayerGroups[const Index: integer]: TSutraLayerGroup
      read GetLayerGroup; default;
  end;

resourcestring
  StrLayerDefinition = 'Layer Definition';

implementation

uses SysUtils, Math, RbwParser, PhastModelUnit, DataSetUnit,
  ModflowDiscretizationWriterUnit;

procedure TLayerGroup.Assign(Source: TPersistent);
var
  AnotherLayerGroup: TLayerGroup;
begin
  // if Assign is updated, update IsSame too.
  inherited;
  AnotherLayerGroup := Source as TLayerGroup;
  if not IsSame(AnotherLayerGroup) then
  begin
    AquiferType := AnotherLayerGroup.AquiferType;
    Simulated := AnotherLayerGroup.Simulated;
    InterblockTransmissivityMethod :=
      AnotherLayerGroup.InterblockTransmissivityMethod;
    VerticalHydraulicConductivityMethod :=
      AnotherLayerGroup.VerticalHydraulicConductivityMethod;
    UseStartingHeadForSaturatedThickness :=
      AnotherLayerGroup.UseStartingHeadForSaturatedThickness;
    HorizontalAnisotropy := AnotherLayerGroup.HorizontalAnisotropy;
    SubNoDelayBedLayers := AnotherLayerGroup.SubNoDelayBedLayers;
    SubDelayBedLayers := AnotherLayerGroup.SubDelayBedLayers;
    WaterTableLayers := AnotherLayerGroup.WaterTableLayers;
    Mt3dmsHorzTransDisp := AnotherLayerGroup.Mt3dmsHorzTransDisp;
    Mt3dmsVertTransDisp := AnotherLayerGroup.Mt3dmsVertTransDisp;
    Mt3dmsDiffusionCoef := AnotherLayerGroup.Mt3dmsDiffusionCoef;
  end;
end;

constructor TLayerGroup.Create(Collection: TCollection);
begin
  inherited;
  FMt3dmsHorzTransDisp := TRealCollection.Create(Model);
  FMt3dmsHorzTransDisp.InitialValue := 0.1;
  FMt3dmsVertTransDisp := TRealCollection.Create(Model);
  FMt3dmsVertTransDisp.InitialValue := 0.01;
  FMt3dmsDiffusionCoef := TRealCollection.Create(Model);
  FMt3dmsDiffusionCoef.InitialValue := 0;
  FSubNoDelayBedLayers := TSubNoDelayBedLayers.Create(Model);
  FSubDelayBedLayers := TSubDelayBedLayers.Create(Model);
  FWaterTableLayers := TWaterTableLayers.Create(Model);
//  AquiferName := 'New Layer Group';
//  AquiferName := '';
  FHorizontalAnisotropy := 1;
  FSimulated := True;
end;

function TLayerGroup.DelayCount: integer;
begin
  Result := SubsidenceLayerCount(SubDelayBedLayers);
end;

destructor TLayerGroup.Destroy;
var
  Model: TPhastModel;
  DataArray: TDataArray;
  ChildIndex: Integer;
//  ChildModel: TChildModel;
  OtherGroup: TLayerGroup;
  Discretization: TChildDiscretizationCollection;
  DisIndex: Integer;
  DisItem: TChildDiscretization;
begin
  FWaterTableLayers.Free;
  FSubDelayBedLayers.Free;
  FSubNoDelayBedLayers.Free;
  if Collection.Model <> nil then
  begin
    Model := Collection.Model as TPhastModel;
    if not (csDestroying in Model.ComponentState) then
    begin
      DataArray := Model.DataArrayManager.GetDataSetByName(DataArrayName);
      if DataArray <> nil then
      begin
        DataArray.Lock := [];
      end;
      for ChildIndex := 0 to Model.ChildModels.Count - 1 do
      begin
        Discretization := Model.ChildModels[ChildIndex].ChildModel.Discretization;
        if Discretization.BottomLayerGroup = self then
        begin
          if Index > 1 then
          begin
            OtherGroup := Collection.Items[Index-1] as TLayerGroup;
            Discretization.BottomLayerInUnit := OtherGroup.LayerCount-1;
          end
          else if Collection.Count > Index+1 then
          begin
            OtherGroup := Collection.Items[Index+1] as TLayerGroup;
            Discretization.BottomLayerInUnit := 0;
          end
          else
          begin
            OtherGroup := nil;
          end;
          Discretization.BottomLayerGroup := OtherGroup;
          for DisIndex := Discretization.Count - 1 downto 0 do
          begin
            DisItem := Discretization[DisIndex];
            if DisItem.LayerGroup = self then
            begin
              Discretization.Delete(DisIndex);
            end;
          end;
        end;
      end;
    end;
  end;
  FMt3dmsDiffusionCoef.Free;
  FMt3dmsVertTransDisp.Free;
  FMt3dmsHorzTransDisp.Free;
  inherited;
end;

function TLayerGroup.GetSimulated: boolean;
var
  PhastModel: TPhastModel;
begin
  result := FSimulated;
  if not result then
  begin
    PhastModel := Model as TPhastModel;
    if (PhastModel <> nil) then
      if (PhastModel.ModflowPackages <> nil) then
      if (PhastModel.ModflowPackages.HufPackage <> nil) then
      if PhastModel.ModflowPackages.HufPackage.IsSelected then
    begin
      result := True;
    end;
  end;
end;

function TLayerGroup.IsSame(AnotherItem: TOrderedItem): boolean;
var
  AnotherLayerGroup : TLayerGroup;
begin
  result := inherited;
  if result then
  begin
    AnotherLayerGroup := AnotherItem as TLayerGroup;
    result := (AnotherLayerGroup.Simulated = Simulated)
      and (AnotherLayerGroup.AquiferType = AquiferType)
      and (AnotherLayerGroup.InterblockTransmissivityMethod =
        InterblockTransmissivityMethod)
      and (AnotherLayerGroup.VerticalHydraulicConductivityMethod =
        VerticalHydraulicConductivityMethod)
      and (AnotherLayerGroup.UseStartingHeadForSaturatedThickness =
        UseStartingHeadForSaturatedThickness)
      and (AnotherLayerGroup.HorizontalAnisotropy = HorizontalAnisotropy)
      and AnotherLayerGroup.SubNoDelayBedLayers.IsSame(SubNoDelayBedLayers)
      and AnotherLayerGroup.SubDelayBedLayers.IsSame(SubDelayBedLayers)
      and AnotherLayerGroup.WaterTableLayers.IsSame(WaterTableLayers)
      and AnotherLayerGroup.Mt3dmsHorzTransDisp.IsSame(Mt3dmsHorzTransDisp)
      and AnotherLayerGroup.Mt3dmsVertTransDisp.IsSame(Mt3dmsVertTransDisp)
      and AnotherLayerGroup.Mt3dmsDiffusionCoef.IsSame(Mt3dmsDiffusionCoef)
  end;
end;

function TLayerGroup.LayerCount: integer;
begin
  if Simulated then
  begin
    result := inherited;
  end
  else
  begin
    result := 1;
  end;
end;

procedure TLayerGroup.Loaded;
begin
  inherited;
  SubNoDelayBedLayers.Loaded;
  SubDelayBedLayers.Loaded;
  WaterTableLayers.Loaded;
end;

function TLayerGroup.ModflowLayerCount: integer;
begin
  if Simulated then
  begin
    result := LayerCollection.Count + 1;
  end
  else
  begin
    result := 0;
  end;
end;

function TLayerGroup.NoDelayCount: integer;
begin
  Result := SubsidenceLayerCount(SubNoDelayBedLayers);
end;

function TLayerGroup.SubsidenceLayerCount(SubLayers: TCustomSubLayer): integer;
var
  Index: Integer;
  UseIndex: Integer;
  Item: TCustomSubLayerItem;
begin
  result := 0;
  if Simulated then
  begin
    if LayerCount > 1 then
    begin
      for Index := 0 to SubLayers.Count - 1 do
      begin
        Item := SubLayers.Items[Index] as TCustomSubLayerItem;
        if Item.UseInAllLayers then
        begin
          Inc(result, LayerCount);
        end
        else
        begin
          for UseIndex := 1 to LayerCount do
          begin
            if Item.UsedLayers.GetItemByLayerNumber(UseIndex) <> nil then
            begin
              Inc(result);
            end;
          end;
        end;
      end;
    end
    else
    begin
      result := SubLayers.Count;
    end;
  end;
end;

procedure TLayerGroup.SetAquiferType(const Value: integer);
var
  Notifier: TObserver;
begin
  if FAquiferType <> Value then
  begin
    Assert(Value  in [0..3]);
    FAquiferType := Value;
    Notifier := (Collection as TLayerStructure).AquiferTypeNotifier;
    Notifier.UpToDate := False;
    Notifier.UpToDate := True;
    InvalidateModel;
  end;
end;

procedure TLayerGroup.SetHorizontalAnisotropy(const Value: double);
begin
  if FHorizontalAnisotropy <> Value then
  begin
    FHorizontalAnisotropy := Value;
    InvalidateModel;
  end;
end;

procedure TLayerGroup.SetInterblockTransmissivityMethod(const Value: integer);
begin
  if FInterblockTransmissivityMethod <> Value then
  begin
    FInterblockTransmissivityMethod := Value;
    InvalidateModel;
  end;
end;

procedure TLayerGroup.SetLayerCollection(const Value: TLayerCollection);
var
  PriorCount: integer;
begin
  PriorCount := LayerCollection.Count;
  inherited;
  UpdateChildModels(PriorCount);
end;

procedure TLayerGroup.SetMt3dmsDiffusionCoef(const Value: TRealCollection);
begin
  FMt3dmsDiffusionCoef.Assign(Value);
end;

procedure TLayerGroup.SetMt3dmsHorzTransDisp(const Value: TRealCollection);
begin
  FMt3dmsHorzTransDisp.Assign(Value);
end;

procedure TLayerGroup.SetMt3dmsVertTransDisp(const Value: TRealCollection);
begin
  FMt3dmsVertTransDisp.Assign(Value);
end;

procedure TLayerGroup.SetSimulated(const Value: boolean);
var
  PhastModel: TPhastModel;
  Notifier: TObserver;
begin
  if FSimulated <> Value then
  begin
    FSimulated := Value;
    PhastModel := Model as TPhastModel;
    if PhastModel <> nil then
    begin
      PhastModel.InvalidateModflowBoundaries;
    end;
    Notifier := (Collection as TLayerStructure).SimulatedNotifier;
    Notifier.UpToDate := False;
    Notifier.UpToDate := True;
    UpdateChildModels(LayerCollection.Count);
    InvalidateModel;
  end;
end;

procedure TLayerGroup.SetSubDelayBedLayers(const Value: TSubDelayBedLayers);
begin
  FSubDelayBedLayers.Assign(Value);
end;

procedure TLayerGroup.SetSubNoDelayBedLayers(const Value: TSubNoDelayBedLayers);
begin
  FSubNoDelayBedLayers.Assign(Value)
end;

procedure TLayerGroup.SetUseStartingHeadForSaturatedThickness(
  const Value: boolean);
begin
  if FUseStartingHeadForSaturatedThickness <> Value then
  begin
    FUseStartingHeadForSaturatedThickness := Value;
    InvalidateModel;
  end;
end;

procedure TLayerGroup.SetVerticalHydraulicConductivityMethod(
  const Value: integer);
begin
  if FVerticalHydraulicConductivityMethod <> Value then
  begin
    FVerticalHydraulicConductivityMethod := Value;
    InvalidateModel;
  end;
end;

procedure TLayerGroup.SetWaterTableLayers(const Value: TWaterTableLayers);
begin
  FWaterTableLayers.Assign(Value);
end;

function TLayerGroup.StoreLayerCollection: boolean;
begin
  result := FSimulated;
end;

function TLayerGroup.SubsidenceDefined: boolean;
begin
  result := Simulated and
    ((SubNoDelayBedLayers.Count > 0) or (SubDelayBedLayers.Count > 0));
end;

function TLayerGroup.SwtDefined: boolean;
begin
  result := Simulated and
    (WaterTableLayers.Count > 0) ;
end;

function TLayerGroup.WaterTableCount: integer;
begin
  result := SubsidenceLayerCount(WaterTableLayers);
end;

procedure TLayerGroup.UpdateChildModels(PriorCount: Integer);
var
  PriorGroup: TLayerGroup;
  Discretization: TChildDiscretizationCollection;
  ChildItem: TChildModelItem;
  ChildIndex: Integer;
  PhastModel: TPhastModel;
begin
  PhastModel := Model as TPhastModel;
  if (PhastModel <> nil) and (PriorCount <> LayerCollection.Count) then
  begin
    for ChildIndex := 0 to PhastModel.ChildModels.Count - 1 do
    begin
      ChildItem := PhastModel.ChildModels[ChildIndex];
      Discretization := ChildItem.ChildModel.Discretization;
      if (Discretization.BottomLayerGroup = self) then
      begin
        if not Simulated then
        begin
          PriorGroup := Collection.Items[Index - 1] as TLayerGroup;
          Discretization.BottomLayerGroup := PriorGroup;
          Discretization.BottomLayerInUnit := PriorGroup.LayerCount - 1;
        end
        else if (Discretization.BottomLayerInUnit = PriorCount) then
        begin
          Discretization.BottomLayerInUnit := LayerCount - 1;
        end
        else if Discretization.BottomLayerInUnit > LayerCount - 1 then
        begin
          Discretization.BottomLayerInUnit := LayerCount - 1;
        end;
      end;
      Discretization.SortAndDeleteExtraItems;
    end;
  end;
end;

procedure TLayerGroup.WriteLAYCB(const DiscretizationWriter: TObject);
var
  DisWriter: TModflowDiscretizationWriter;
  Index: integer;
begin
  DisWriter := DiscretizationWriter as TModflowDiscretizationWriter;
  if Simulated then
  begin
    for Index := 0 to LayerCollection.Count-1 do
    begin
      DisWriter.WriteInteger(0);
    end;
  end
  else
  begin
    DisWriter.WriteInteger(1);
  end;
end;

{ TLayerStructure }
procedure TLayerStructure.Assign(Source: TPersistent);
var
  PhastModel: TPhastModel;
  Index: Integer;
  Child: TChildModelItem;
begin
  inherited;
  if Model <> nil then
  begin
    PhastModel := Model as TPhastModel;
    PhastModel.Grid.LayerCount := LayerCount;
    for Index := 0 to PhastModel.ChildModels.Count - 1 do
    begin
      Child := PhastModel.ChildModels[Index];
      Child.ChildModel.UpdateLayerCount;
    end;
    PhastModel.InvalidateMfEtsEvapLayer(self);
    PhastModel.InvalidateMfEvtEvapLayer(self);
    PhastModel.InvalidateMfRchLayer(self);
    AssignAssociatedInputDataSets;
  end;
end;

function TLayerStructure.Chani: TOneDIntegerArray;
var
  Index: Integer;
begin
  SetLength(result, ModflowLayerCount);
  for Index := 0 to Length(result) - 1 do
  begin
    result[Index] := -1;
  end;
end;

constructor TLayerStructure.Create(Model: TBaseModel);
begin
  inherited Create(TLayerGroup, Model);
  FSimulatedNotifier := TObserver.Create(nil);
  FSimulatedNotifier.Name := 'Simulated_Notifyier';
  FAquiferTypeNotifier := TObserver.Create(nil);
  FAquiferTypeNotifier.Name := 'AquiferType_Notifier'
end;

function TLayerStructure.GetLayerGroup(const Index: integer): TLayerGroup;
begin
  result := Items[Index] as TLayerGroup;
end;

function TLayerStructure.GetLayerGroupByLayer(
  const Layer: integer): TLayerGroup;
var
  HufUnitIndex: Integer;
  HufUnit: TLayerGroup;
  LocalLayerCount : integer;
begin
  Assert(Layer >= 0);
  result := nil;
  LocalLayerCount := 0;
  for HufUnitIndex := 1 to Count - 1 do
  begin
    HufUnit := LayerGroups[HufUnitIndex];
    LocalLayerCount := LocalLayerCount + HufUnit.LayerCount;
    if LocalLayerCount > Layer then
    begin
      result := HufUnit;
      Exit;
    end;
  end;
end;

function TLayerStructure.IsLayerSimulated(const LayerID: integer): boolean;
var
  LayerGroup: TLayerGroup;
  LayerGroupIndex: integer;
  LayerCount: integer;
begin
  Assert(LayerID >= 0);
  LayerCount := 0;
  result := False;
  for LayerGroupIndex := 1 to Count - 1 do
  begin
    LayerGroup := LayerGroups[LayerGroupIndex];
    LayerCount := LayerCount + LayerGroup.LayerCount;
    if LayerCount >= LayerID+1 then
    begin
      result := LayerGroup.Simulated;
      Exit;
    end;
  end;
  Assert(False);
end;

function TLayerStructure.IntegerArray(Method: TIntTypeMethod):
  TOneDIntegerArray;
var
  LayerCount: integer;
  GroupIndex: Integer;
  Group: TLayerGroup;
  LayerIndex: Integer;
  MFLayIndex: integer;
  PhastModel: TPhastModel;
begin
  PhastModel := Model as TPhastModel;
  LayerCount := ModflowLayerCount;
  SetLength(result, LayerCount);
  MFLayIndex := 0;
  for GroupIndex := 1 to Count - 1 do
  begin
    Group := LayerGroups[GroupIndex];
    if Group.Simulated then
    begin
      for LayerIndex := 0 to Group.ModflowLayerCount - 1 do
      begin
        Assert(MFLayIndex < LayerCount);
        case Method of
          itmLaytype:
            begin
              result[MFLayIndex] := Group.AquiferType;
              if (Group.AquiferType = 1) and
                Group.UseStartingHeadForSaturatedThickness
                and PhastModel.ModflowPackages.LpfPackage.isSelected
                and PhastModel.ModflowPackages.LpfPackage.UseSaturatedThickness then
              begin
                result[MFLayIndex] := -1;
              end;
              if PhastModel.ModflowPackages.BcfPackage.isSelected then
              begin
                if (MFLayIndex > 0) and (result[MFLayIndex] = 1) then
                begin
                  result[MFLayIndex] := 3;
                end;
                result[MFLayIndex] := result[MFLayIndex]
                  + Group.InterblockTransmissivityMethod*10;
              end;
            end;
          itmLayavg: result[MFLayIndex] := Group.InterblockTransmissivityMethod;
          itmLayvka: result[MFLayIndex] :=
            Group.VerticalHydraulicConductivityMethod;
          else Assert(False);
        end;
        Inc(MFLayIndex);
      end;
    end;
  end;
  Assert(MFLayIndex = LayerCount);
end;

function TLayerStructure.Last: TLayerGroup;
begin
  result := inherited Last as TLayerGroup;
end;

function TLayerStructure.Layavg: TOneDIntegerArray;
begin
  result := IntegerArray(itmLayavg);
end;

function TLayerStructure.Laytyp: TOneDIntegerArray;
begin
  result := IntegerArray(itmLaytype);
end;

function TLayerStructure.Layvka: TOneDIntegerArray;
begin
  result := IntegerArray(itmLayvka);
end;

procedure TLayerStructure.Loaded;
begin
  inherited;
  AssignAssociatedInputDataSets;
end;

function TLayerStructure.ModflowLayerBottomDescription(
  const LayerID: integer): string;
var
  LayerGroup: TLayerGroup;
  LayerGroupIndex: integer;
  LayerCount: integer;
  LayerNumber: integer;
begin
  Assert(LayerID >= 0);
  LayerCount := 0;
  result := '';
  LayerNumber := LayerID+1;
  for LayerGroupIndex := 1 to Count - 1 do
  begin
    LayerGroup := LayerGroups[LayerGroupIndex];
    LayerCount := LayerCount + LayerGroup.LayerCount;
    if LayerCount >= LayerID+1 then
    begin
      result := LayerGroup.AquiferName;
      if LayerGroup.LayerCollection.Count > 0 then
      begin
        result := result + ' Layer ' + IntToStr(LayerNumber);
      end;
      Exit;
    end;
    LayerNumber := LayerID+1 - LayerCount;
  end;
end;

function TLayerStructure.ModflowConfiningBedCount: integer;
var
  Index: Integer;
  LayerGroup: TLayerGroup;
begin
  result := 0;
  // Skip the top of the model: it doesn't count.
  for Index := 1 to Count - 1 do
  begin
    LayerGroup := Items[Index] as TLayerGroup;
    if not LayerGroup.Simulated then
    begin
      Inc(result);
    end;
  end;
end;

function TLayerStructure.ModflowLayerCount: integer;
var
  Index: Integer;
  LayerGroup: TLayerGroup;
begin
  result := 0;
  // Skip the top of the model: it doesn't count.
  for Index := 1 to Count - 1 do
  begin
    LayerGroup := Items[Index] as TLayerGroup;
    result := result + LayerGroup.ModflowLayerCount;
  end;
end;

function TLayerStructure.DataSetLayerToModflowLayer(
  DataSetLayer: integer): integer;
var
  GroupIndex: Integer;
  Group: TLayerGroup;
  GridLayerCount: integer;
begin
  GridLayerCount := 0;
  result := 0;
  for GroupIndex := 1 to Count - 1 do
  begin
    Group := LayerGroups[GroupIndex];
    if Group.Simulated then
    begin
      GridLayerCount := GridLayerCount + Group.ModflowLayerCount;
      result := result + Group.ModflowLayerCount;
    end
    else
    begin
      GridLayerCount := GridLayerCount + 1;
    end;
    if GridLayerCount >= DataSetLayer then
    begin
      result := result - (GridLayerCount-DataSetLayer)+1;
      Exit;
    end;
  end;
  Assert(False);
end;

function TLayerStructure.DelayCount: integer;
var
  Index: Integer;
  Group: TLayerGroup;
begin
  result := 0;
  for Index := 0 to Count - 1 do
  begin
    Group := LayerGroups[Index];
    result := result + Group.DelayCount;
  end;
end;

destructor TLayerStructure.Destroy;
begin
  FAquiferTypeNotifier.Free;
  FSimulatedNotifier.Free;
  inherited;
end;

function TLayerStructure.DMCOEF: TOneDRealArray;
begin
  Result := FloatArray(ftmDmcoef);
end;

//function TLayerStructure.First: TLayerGroup;
//begin
//  result := inherited First as TLayerGroup;
//end;

function TLayerStructure.FloatArray(Method: TFloatTypeMethod): TOneDRealArray;
var
  LayerCount: integer;
  GroupIndex: Integer;
  Group: TLayerGroup;
  LayerIndex: Integer;
  MFLayIndex: integer;
begin
  LayerCount := ModflowLayerCount;
  SetLength(result, LayerCount);
  MFLayIndex := 0;
  for GroupIndex := 1 to Count - 1 do
  begin
    Group := LayerGroups[GroupIndex];
    if Group.Simulated then
    begin
      for LayerIndex := 0 to Group.ModflowLayerCount - 1 do
      begin
        Assert(MFLayIndex < LayerCount);
        case Method of
          ftmTrpy:
            begin
              result[MFLayIndex] := Group.HorizontalAnisotropy;
            end;
          ftmTrtp:
            begin
              while LayerIndex >= Group.Mt3dmsHorzTransDisp.Count do
              begin
                Group.Mt3dmsHorzTransDisp.Add;
                if LayerIndex > 0 then
                begin
                  Group.Mt3dmsHorzTransDisp[LayerIndex].Assign(Group.Mt3dmsHorzTransDisp[LayerIndex-1]);
                end;
              end;
              result[MFLayIndex] := Group.Mt3dmsHorzTransDisp[LayerIndex].Value;
            end;
          ftmTrpv:
            begin
              while LayerIndex >= Group.Mt3dmsVertTransDisp.Count do
              begin
                Group.Mt3dmsVertTransDisp.Add;
                if LayerIndex > 0 then
                begin
                  Group.Mt3dmsVertTransDisp[LayerIndex].Assign(Group.Mt3dmsVertTransDisp[LayerIndex-1]);
                end;
              end;
              result[MFLayIndex] := Group.Mt3dmsVertTransDisp[LayerIndex].Value;
            end;
          ftmDmcoef:
            begin
              while LayerIndex >= Group.Mt3dmsDiffusionCoef.Count do
              begin
                Group.Mt3dmsDiffusionCoef.Add;
                if LayerIndex > 0 then
                begin
                  Group.Mt3dmsDiffusionCoef[LayerIndex].Assign(Group.Mt3dmsDiffusionCoef[LayerIndex-1]);
                end;
              end;
              result[MFLayIndex] := Group.Mt3dmsDiffusionCoef[LayerIndex].Value;
            end
          else Assert(False);
        end;
        Inc(MFLayIndex);
      end;
    end;
  end;
  Assert(MFLayIndex = LayerCount);
end;

procedure TLayerStructure.AssignAssociatedInputDataSets;
var
  Index: Integer;
  PhastModel: TPhastModel;
  Name: string;
  DataSet: TDataArray;
begin
  PhastModel := Model as TPhastModel;
  Assert(PhastModel <> nil);
  for Index := 0 to Count - 1 do
  begin
    Name := LayerGroups[Index].DataArrayName;
    DataSet := PhastModel.DataArrayManager.GetDataSetByName(Name);
    if Index = 0 then
    begin
      DataSet.AssociatedDataSets := 'MODFLOW DIS: Top';
    end
    else
    begin
      DataSet.AssociatedDataSets := 'MODFLOW DIS: BOTM';
    end;
  end;
end;

function TLayerStructure.ModflowLayerToDataSetLayer(
  ModflowLayer: integer): integer;
var
  GroupIndex: Integer;
  Group: TLayerGroup;
  LayerCount: integer;
begin
  Assert((ModflowLayer >= 1) and (ModflowLayer <= ModflowLayerCount));
  LayerCount := 0;
  result := -1;
  for GroupIndex := 1 to Count - 1 do
  begin
    Group := LayerGroups[GroupIndex];
    LayerCount := LayerCount + Group.ModflowLayerCount;
    if Group.Simulated then
    begin
      result := result + Group.ModflowLayerCount;
    end
    else
    begin
      result := result + 1;
    end;

    if LayerCount >= ModflowLayer then
    begin
      result := result - (LayerCount - ModflowLayer);
      Exit;
    end;
  end;
  Assert(False);
end;

function TLayerStructure.NoDelayCount: integer;
var
  Index: Integer;
  Group: TLayerGroup;
begin
  result := 0;
  for Index := 0 to Count - 1 do
  begin
    Group := LayerGroups[Index];
    result := result + Group.NoDelayCount;
  end;
end;

function TLayerStructure.NonSimulatedLayersPresent: boolean;
var
  Index: Integer;
  LayerGroup: TLayerGroup;
begin
  result := false;
  for Index := 1 to Count - 1 do
  begin
    LayerGroup := Items[Index] as TLayerGroup;
    if not LayerGroup.Simulated then
    begin
      result := True;
      Exit;
    end;
  end;
end;

procedure TLayerStructure.StopTalkingToAnyone;
begin
  SimulatedNotifier.StopTalkingToAnyone;
  AquiferTypeNotifier.StopTalkingToAnyone;
end;

function TLayerStructure.SubsidenceDefined: boolean;
var
  Index: Integer;
  Group: TLayerGroup;
begin
  result := False;
  for Index := 0 to Count - 1 do
  begin
    Group := LayerGroups[Index];
    result := Group.SubsidenceDefined;
    if result then
    begin
      Exit;
    end;
  end;
end;

function TLayerStructure.SwtDefined: boolean;
var
  Index: Integer;
  Group: TLayerGroup;
begin
  result := False;
  for Index := 0 to Count - 1 do
  begin
    Group := LayerGroups[Index];
    result := Group.SwtDefined;
    if result then
    begin
      Exit;
    end;
  end;
end;

function TLayerStructure.TRPT: TOneDRealArray;
begin
  Result := FloatArray(ftmTrtp);
end;

function TLayerStructure.TRPV: TOneDRealArray;
begin
  Result := FloatArray(ftmTrpv);
end;

function TLayerStructure.Trpy: TOneDRealArray;
begin
  result := FloatArray(ftmTrpy);
end;

function TLayerStructure.WaterTableCount: integer;
var
  Index: Integer;
  Group: TLayerGroup;
begin
  result := 0;
  for Index := 0 to Count - 1 do
  begin
    Group := LayerGroups[Index];
    result := result + Group.WaterTableCount;
  end;
end;

procedure TLayerStructure.WriteLAYCB(const DiscretizationWriter: TObject);
var
  Index: Integer;
  LayerGroup: TLayerGroup;
  DisWriter: TModflowDiscretizationWriter;
  ItemIndex: Integer;
begin
  DisWriter := DiscretizationWriter as TModflowDiscretizationWriter;
  // Skip the top of the model: it doesn't count.
  for Index := 1 to Count - 1 do
  begin
//    LayerGroup.WriteLAYCB(DisWriter);
    LayerGroup := Items[Index] as TLayerGroup;
    if LayerGroup.Simulated then
    begin
      for ItemIndex := 0 to LayerGroup.LayerCollection.Count-1 do
      begin
        DisWriter.WriteInteger(0);
      end;
      if Index < Count - 1 then
      begin
        LayerGroup := Items[Index+1] as TLayerGroup;
        if LayerGroup.Simulated then
        begin
          DisWriter.WriteInteger(0);
        end
        else
        begin
          DisWriter.WriteInteger(1);
        end;
      end
      else
      begin
        DisWriter.WriteInteger(0);
      end;
    end;
  end;
  DisWriter.WriteString(' # LAYCB');
  DisWriter.NewLine;
end;

{ TLayerFraction }

procedure TLayerFraction.Assign(Source: TPersistent);
begin
  // if Assign is updated, update IsSame too.
  Fraction := (Source as TLayerFraction).Fraction;
end;

function TLayerFraction.Collection: TLayerCollection;
begin
  result := inherited Collection as TLayerCollection;
end;

procedure TLayerFraction.InvalidateModel;
begin
  Collection.InvalidateModel;
end;

function TLayerFraction.IsSame(AnotherLayerFraction: TLayerFraction): boolean;
begin
  result := Fraction = AnotherLayerFraction.Fraction;
end;

procedure TLayerFraction.SetFraction(const Value: real);
begin
  if FFraction <> Value then
  begin
    FFraction := Value;
    InvalidateModel;
  end;
end;

{ TLayerCollection }

procedure TLayerCollection.Assign(Source: TPersistent);
begin
  // if Assign is updated, update IsSame too.
  if not IsSame(Source as TLayerCollection) then
  begin
    inherited;
  end;
  Sort;
end;

constructor TLayerCollection.Create(LayerGroup: TCustomLayerGroup);
begin
  inherited Create(TLayerFraction);
  Assert(LayerGroup <> nil);
  FLayerGroup := LayerGroup;
end;

procedure TLayerCollection.InvalidateModel;
begin
  FLayerGroup.InvalidateModel;
end;

function TLayerCollection.IsSame(
  AnotherLayerCollection: TLayerCollection): boolean;
var
  Index: Integer;
begin
  result := Count = AnotherLayerCollection.Count;
  if result then
  begin
    for Index := 0 to Count - 1 do
    begin
      result := (Items[Index] as TLayerFraction).IsSame(
        AnotherLayerCollection.Items[Index] as TLayerFraction);
      if not result then Exit;
    end;
  end;
end;

function CompareLayerFractions(Item1, Item2: Pointer): Integer;
var
  Frac1, Frac2: TLayerFraction;
begin
  Frac1 := Item1;
  Frac2 := Item2;
  result := Sign(Frac2.Fraction - Frac1.Fraction);
end;

procedure TLayerCollection.Sort;
var
  List: TList;
  Index: integer;
  Item: TLayerFraction;
begin
  List := TList.Create;
  try
    for Index := 0 to Count - 1 do
    begin
      List.Add(Items[Index]);
    end;
    List.Sort(CompareLayerFractions);
    for Index := 0 to List.Count - 1 do
    begin
      Item := List[Index];
      Item.Index := Index;
    end;
  finally
    List.Free;
  end;
end;

procedure TCustomLayerGroup.Assign(Source: TPersistent);
var
  AnotherLayerGroup: TCustomLayerGroup;
begin
  // if Assign is updated, update IsSame too.
  inherited;
  AnotherLayerGroup := Source as TCustomLayerGroup;
  if not IsSame(AnotherLayerGroup) then
  begin
    // It is important for AquiferName to be assigned after DataArrayName
    // because if AquiferName has changed, DataArrayName will
    // need to be changed too and that change should not be overwritten
    // by another assignment to DataArrayName.
    if AnotherLayerGroup.DataArrayName <> '' then
    begin
      DataArrayName := AnotherLayerGroup.DataArrayName;
    end;
    AquiferName := AnotherLayerGroup.AquiferName;
    GrowthMethod := AnotherLayerGroup.GrowthMethod;
    GrowthRate := AnotherLayerGroup.GrowthRate;
    LayerCollection := AnotherLayerGroup.LayerCollection;
  end;
end;

function TCustomLayerGroup.Collection: TCustomLayerStructure;
begin
  result := inherited Collection as TCustomLayerStructure;
end;

function TCustomLayerGroup.EvalAt: TEvaluatedAt;
begin
  result := eaBlocks
end;

procedure TCustomLayerGroup.SetDataArrayName(const NewName: string);
var
  Model: TPhastModel;
  DataArray: TDataArray;
  UnitAbove, UnitBelow: TCustomLayerGroup;
  NewFormula: string;
begin
  if FDataArrayName <> NewName then
  begin
    if Collection.Model <> nil then
    begin
      Model := Collection.Model as TPhastModel;
      if not(csLoading in Model.ComponentState) then
      begin
        DataArray := Model.DataArrayManager.GetDataSetByName(FDataArrayName);
        if DataArray <> nil then
        begin
          Model.RenameDataArray(DataArray, NewName);
        end
        else
        begin
          DataArray := Model.DataArrayManager.GetDataSetByName(NewName);
        end;
        if DataArray = nil then
        begin
          // create a new data array.
          // First get formula for new layer.
          if Collection.Count = 1 then
          begin
            NewFormula := '0';
          end
          else if Index <= 0 then
          begin
            // No unit can be inserted above the top of the model.
            Assert(False);
          end
          else if Index = Collection.Count - 1 then
          begin
            UnitAbove := Collection.Items[Index - 1] as TCustomLayerGroup;
            NewFormula := UnitAbove.DataArrayName + ' - 1';
          end
          else
          begin
            UnitAbove := Collection.Items[Index - 1] as TCustomLayerGroup;
            UnitBelow := Collection.Items[Index + 1] as TCustomLayerGroup;
            NewFormula := '(' + UnitAbove.DataArrayName + ' + ' +
              UnitBelow.DataArrayName + ') / 2';
          end;
          // create new data array.
          DataArray := Model.DataArrayManager.CreateNewDataArray(TDataArray,
            NewName, NewFormula, [dcName, dcType, dcOrientation, dcEvaluatedAt],
            rdtDouble, EvalAt, dsoTop, StrLayerDefinition);
          DataArray.OnDataSetUsed := Model.ModelLayerDataArrayUsed;
          Collection.AddOwnedDataArray(DataArray);
        end;
        Model.TopGridObserver.TalksTo(DataArray);
        DataArray.TalksTo(Model.ThreeDGridObserver);
        Model.ThreeDGridObserver.StopsTalkingTo(DataArray);
        Model.UpdateDataArrayDimensions(DataArray);
        // DataArray.UpdateDimensions(Model.Grid.LayerCount,
        // Model.Grid.RowCount, Model.Grid.ColumnCount);
      end;
    end;
    FDataArrayName := NewName;
    InvalidateModel;
  end;
end;

constructor TCustomLayerGroup.Create(Collection: TCollection);
begin
  inherited;
  FLayerCollection:= TLayerCollection.Create(self);
  FGrowthRate := 1.2;
end;

destructor TCustomLayerGroup.Destroy;
begin
  FLayerCollection.Free;
  inherited;
end;

function TCustomLayerGroup.IsSame(AnotherItem: TOrderedItem): boolean;
var
  AnotherLayerGroup : TCustomLayerGroup;
begin
  AnotherLayerGroup := AnotherItem as TCustomLayerGroup;
  result := (AnotherLayerGroup.AquiferName = AquiferName)
    and (AnotherLayerGroup.DataArrayName = DataArrayName)
    and (AnotherLayerGroup.GrowthMethod = GrowthMethod)
    and (AnotherLayerGroup.GrowthRate = GrowthRate)
    and AnotherLayerGroup.LayerCollection.IsSame(LayerCollection)
end;

function TCustomLayerGroup.LayerCount: integer;
begin
  result := LayerCollection.Count + 1;
end;

procedure TCustomLayerGroup.Loaded;
var
  Model: TPhastModel;
  DataArray: TDataArray;
begin
  Model := Collection.Model as TPhastModel;
  DataArray := Model.DataArrayManager.GetDataSetByName(FDataArrayName);
  Assert( DataArray <> nil);
  Model.TopGridObserver.TalksTo(DataArray);
  DataArray.TalksTo(Model.ThreeDGridObserver);
  Model.ThreeDGridObserver.StopsTalkingTo(DataArray);
end;

procedure TCustomLayerGroup.SetAquiferName(const Value: string);
begin
  Assert(Value <> '');
  if FAquiferName <> Value then
  begin
    if Collection.Model <> nil then
    begin
      if UpperCase(FAquiferName) = UpperCase(Value) then
      begin
        // Change case of the data set
        DataArrayName := StringReplace(DataArrayName,
          GenerateNewRoot(FAquiferName), GenerateNewRoot(Value), []);
      end
      else
      begin
        if Index = 0 then
        begin
          DataArrayName := GenerateNewName(Value);
        end
        else
        begin
          DataArrayName := GenerateNewRoot(Value + '_Bottom');
        end;
      end;
    end;
    FAquiferName := Value;
    InvalidateModel;
  end;
end;

procedure TCustomLayerGroup.SetGrowthMethod(const Value: TGrowthMethod);
begin
  if FGrowthMethod <> Value then
  begin
    FGrowthMethod := Value;
    InvalidateModel;
  end;
end;

procedure TCustomLayerGroup.SetGrowthRate(const Value: real);
begin
  if FGrowthRate <> Value then
  begin
    FGrowthRate := Value;
    InvalidateModel;
  end;
end;

function TCustomLayerGroup.StoreLayerCollection: boolean;
begin
  result := True;
end;

procedure TCustomLayerGroup.SetLayerCollection(const Value: TLayerCollection);
begin
  FLayerCollection.Assign(Value);
end;

function TCustomLayerStructure.LayerCount: integer;
var
  Index: integer;
  LayerGroup: TCustomLayerGroup;
begin
  Result := 0;
  // Skip the top of the model: it doesn't count.
  for Index := 1 to Count - 1 do
  begin
    LayerGroup := Items[Index] as TCustomLayerGroup;
    Result := Result + LayerGroup.LayerCount;
  end;
end;

procedure TCustomLayerStructure.Loaded;
var
  Index: Integer;
begin
  for Index := 0 to Count - 1 do
  begin
    (Items[Index] as TCustomLayerGroup).Loaded;
  end;
end;

{ TSutraLayerStructure }

constructor TSutraLayerStructure.Create(Model: TBaseModel);
begin
  inherited Create(TSutraLayerGroup, Model);
end;

function TSutraLayerStructure.GetLayerGroup(
  const Index: integer): TSutraLayerGroup;
begin
  result := Items[Index] as TSutraLayerGroup;
end;

{ TSutraLayerGroup }

function TSutraLayerGroup.EvalAt: TEvaluatedAt;
begin
  result := eaNodes;
end;

end.
