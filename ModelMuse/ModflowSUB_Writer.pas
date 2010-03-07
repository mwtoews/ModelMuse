unit ModflowSUB_Writer;

interface

uses
  Classes, CustomModflowWriterUnit, ModflowPackageSelectionUnit, UnitList,
  IntListUnit, PhastModelUnit, SysUtils;

type
  TMaterialZone = record
    VerticalK: double;
    ElasticSpecificStorage: double;
    InelasticSpecificStorage: double;
    class operator Equal(Var1, Var2: TMaterialZone): boolean;
    class operator NotEqual(Var1, Var2: TMaterialZone): boolean;
    function ID: Integer;
  end;

  TMaterialZoneIdItem = class(TIDItem)
  private
    FMaterialZoneValues: TMaterialZone;
    FZoneNumber: integer;
    FNextSameID: TMaterialZoneIdItem;
    procedure SetMaterialZoneValues(const Value: TMaterialZone);
    procedure AssignID;
  public
    Constructor Create;
    Destructor Destroy; override;
    property MaterialZoneValues: TMaterialZone read FMaterialZoneValues
      write SetMaterialZoneValues;
    property ZoneNumber: integer read FZoneNumber write FZoneNumber;
    property NextSameID: TMaterialZoneIdItem read FNextSameID write FNextSameID;
  end;

  TMaterialZoneList = class(TObject)
  private
    FMaterialZones: TList;
    FIdList: TIDList;
    function GetItem(Index: integer): TMaterialZoneIdItem;
  public
    Constructor Create;
    Destructor Destroy; override;
    function AddRecord(MaterialZone: TMaterialZone): TMaterialZoneIdItem;
    function Count: integer;
    property Items[Index: integer]: TMaterialZoneIdItem read GetItem; default;
  end;

  TModflowSUB_Writer = class(TCustomPackageWriter)
  private
    // model layer assignments for each system of no-delay interbeds
    FLN: TIntegerList;
    // model layer assignments for each system of delay interbeds
    FLDN: TIntegerList;
    // specifying the factor n-equiv - Delay beds
    FRNB_List: TList;
    // preconsolidation head - No-Delay beds
    FHC_List: TList;
    // elastic skeletal storage coefficient - No-Delay beds
    FSfe_List: TList;
    // inelastic skeletal storage coefficient - No-Delay beds
    FSfv_List: TList;
    // fcstarting compaction - No-Delay beds
    FCom_List: TList;
    // material zones - Delay beds
    FDP_List: TMaterialZoneList;
    FDelayVK_List: TList;
    FDelayElasticSpecificStorage_List: TList;
    FDelayInElasticSpecificStorage_List: TList;
    // starting head - Delay beds
    FDstart_List: TList;
    // starting preconsolidation head - Delay beds
    FDHC_List: TList;
    // starting compaction - Delay beds
    FDCOM_List: TList;
    // equivalent thickness - Delay beds
    FDZ_List: TList;
    // material zone numbers - Delay beds
    FNZ_List: TList;
    FSubPackage: TSubPackageSelection;
    FNameOfFile: string;
    procedure RetrieveArrays;
    procedure EvaluateMaterialZones;
    procedure Evaluate;
    procedure WriteDataSet1;
    procedure WriteDataSet2;
    procedure WriteDataSet3;
    procedure WriteDataSet4;
    procedure WriteDataSets5to8;
    procedure WriteDataSet9;
    procedure WriteDataSets10to14;
    procedure WriteDataSet15;
    procedure WriteDataSet16;
  protected
    function Package: TModflowPackageSelection; override;
    class function Extension: string; override;
  public
    procedure WriteFile(const AFileName: string);
    Constructor Create(Model: TPhastModel); override;
    Destructor Destroy; override;
  end;


implementation

uses
  UnitCRC, Contnrs, LayerStructureUnit, ModflowSubsidenceDefUnit, DataSetUnit,
  GoPhastTypes, RbwParser, ModflowUnitNumbers, frmProgressUnit,
  frmErrorsAndWarningsUnit, ModflowTimeUnit;

function TMaterialZone.ID: Integer;
begin
  result := Integer(CRC32(self, SizeOf(TMaterialZone)));
end;

class operator TMaterialZone.NotEqual(Var1, Var2: TMaterialZone): boolean;
begin
  result := (Var1.VerticalK <> Var2.VerticalK)
    or (Var1.ElasticSpecificStorage <> Var2.ElasticSpecificStorage)
    or (Var1.InelasticSpecificStorage <> Var2.InelasticSpecificStorage)
end;

{ TMaterialZone }

class operator TMaterialZone.Equal(Var1, Var2: TMaterialZone): boolean;
begin
  result := (Var1.VerticalK = Var2.VerticalK)
    and (Var1.ElasticSpecificStorage = Var2.ElasticSpecificStorage)
    and (Var1.InelasticSpecificStorage = Var2.InelasticSpecificStorage)
end;

{ TModflowSUB_Writer }

constructor TModflowSUB_Writer.Create(Model: TPhastModel);
begin
  inherited;
  FLN := TIntegerList.Create;
  FLDN := TIntegerList.Create;
  FRNB_List := TList.Create;
  FHC_List := TList.Create;
  FSfe_List := TList.Create;
  FSfv_List := TList.Create;
  FCom_List := TList.Create;
  FDP_List := TMaterialZoneList.Create;
  FDelayVK_List := TList.Create;
  FDelayElasticSpecificStorage_List := TList.Create;
  FDelayInElasticSpecificStorage_List := TList.Create;
  FDstart_List := TList.Create;
  FDHC_List := TList.Create;
  FDCOM_List := TList.Create;
  FDZ_List := TList.Create;
  FNZ_List := TObjectList.Create;
end;

destructor TModflowSUB_Writer.Destroy;
begin
  FNZ_List.Free;
  FDZ_List.Free;
  FDCOM_List.Free;
  FDHC_List.Free;
  FDstart_List.Free;
  FDelayInElasticSpecificStorage_List.Free;
  FDelayElasticSpecificStorage_List.Free;
  FDelayVK_List.Free;
  FDP_List.Free;
  FCom_List.Free;
  FSfv_List.Free;
  FSfe_List.Free;
  FHC_List.Free;
  FRNB_List.Free;
  FLDN.Free;
  FLN.Free;
  inherited;
end;

procedure TModflowSUB_Writer.Evaluate;
begin
  RetrieveArrays;
  EvaluateMaterialZones;
end;

procedure TModflowSUB_Writer.EvaluateMaterialZones;
var
  DataArrayIndex: Integer;
  VK_Array: TDataArray;
  ElasticSSArray: TDataArray;
  InElasticSSArray: TDataArray;
  RowIndex: Integer;
  ColIndex: Integer;
  MaterialZoneRecord: TMaterialZone;
  MaterialZoneObject: TMaterialZoneIdItem;
  MaterialZoneArray: TDataArray;
begin
  FNZ_List.Capacity := FDelayVK_List.Count;
  for DataArrayIndex := 0 to FDelayVK_List.Count - 1 do
  begin
    VK_Array := FDelayVK_List[DataArrayIndex];
    ElasticSSArray := FDelayElasticSpecificStorage_List[DataArrayIndex];
    InElasticSSArray := FDelayInElasticSpecificStorage_List[DataArrayIndex];
    VK_Array.Initialize;
    ElasticSSArray.Initialize;
    InElasticSSArray.Initialize;
    MaterialZoneArray := TDataArray.Create(PhastModel);
    FNZ_List.Add(MaterialZoneArray);
    MaterialZoneArray.Orientation := dsoTop;
    MaterialZoneArray.DataType := rdtInteger;
    MaterialZoneArray.EvaluatedAt := eaBlocks;
    MaterialZoneArray.UpdateDimensions(1, VK_Array.RowCount, VK_Array.ColumnCount);
    for RowIndex := 0 to VK_Array.RowCount - 1 do
    begin
      for ColIndex := 0 to VK_Array.ColumnCount - 1 do
      begin
        MaterialZoneRecord.VerticalK := VK_Array.RealData[0,RowIndex,ColIndex];
        MaterialZoneRecord.ElasticSpecificStorage := ElasticSSArray.RealData[0,RowIndex,ColIndex];
        MaterialZoneRecord.InelasticSpecificStorage := InElasticSSArray.RealData[0,RowIndex,ColIndex];
        MaterialZoneObject := FDP_List.AddRecord(MaterialZoneRecord);
        MaterialZoneArray.IntegerData[0,RowIndex,ColIndex] := MaterialZoneObject.ZoneNumber;
      end;
    end;
    MaterialZoneArray.UpToDate := True;
  end;
end;

class function TModflowSUB_Writer.Extension: string;
begin
  result := '.sub';
end;

function TModflowSUB_Writer.Package: TModflowPackageSelection;
begin
  result := PhastModel.ModflowPackages.SubPackage;
end;

procedure TModflowSUB_Writer.RetrieveArrays;
var
  GroupIndex: Integer;
  Layers: TLayerStructure;
  Group: TLayerGroup;
  SubsidenceIndex: Integer;
  NoDelayItem: TSubNoDelayBedLayerItem;
  PreconsolidationHeadDataArray: TDataArray;
  ElasticSkeletalStorageCoefficientDataArray: TDataArray;
  InelasticSkeletalStorageCoefficientDataArray: TDataArray;
  InitialCompactionDataArray: TDataArray;
  MFLayer_Group: Integer;
  LayerIndex: Integer;
  DelayItem: TSubDelayBedLayerItem;
  EquivNumberDataArray: TDataArray;
  VerticalHydraulicConductivityDataArray: TDataArray;
  ElasticSpecificStorageDataArray: TDataArray;
  InelasticSpecificStorageDataArray: TDataArray;
  InterbedStartingHeadDataArray: TDataArray;
  InterbedPreconsolidationHeadDataArray: TDataArray;
  InterbedStartingCompactionDataArray: TDataArray;
  InterbedEquivalentThicknessDataArray: TDataArray;
begin
  Layers := PhastModel.LayerStructure;
  MFLayer_Group := 0;
  for GroupIndex := 1 to Layers.Count - 1 do
  begin
    Group := Layers.LayerGroups[GroupIndex];
    if Group.Simulated then
    begin
      for SubsidenceIndex := 0 to Group.SubNoDelayBedLayers.Count - 1 do
      begin
        NoDelayItem := Group.SubNoDelayBedLayers[SubsidenceIndex];
        PreconsolidationHeadDataArray := PhastModel.GetDataSetByName(
          NoDelayItem.PreconsolidationHeadDataArrayName);
        Assert(PreconsolidationHeadDataArray <> nil);
        ElasticSkeletalStorageCoefficientDataArray := PhastModel.GetDataSetByName(
          NoDelayItem.ElasticSkeletalStorageCoefficientDataArrayName);
        Assert(ElasticSkeletalStorageCoefficientDataArray <> nil);
        InelasticSkeletalStorageCoefficientDataArray := PhastModel.GetDataSetByName(
          NoDelayItem.InelasticSkeletalStorageCoefficientDataArrayName);
        Assert(InelasticSkeletalStorageCoefficientDataArray <> nil);
        InitialCompactionDataArray := PhastModel.GetDataSetByName(
          NoDelayItem.InitialCompactionDataArrayName);
        Assert(InitialCompactionDataArray <> nil);
        if Group.LayerCount = 1 then
        begin
          FLN.Add(MFLayer_Group+1);
          FHC_List.Add(PreconsolidationHeadDataArray);
          FSfe_List.Add(ElasticSkeletalStorageCoefficientDataArray);
          FSfv_List.Add(InelasticSkeletalStorageCoefficientDataArray);
          FCom_List.Add(InitialCompactionDataArray);
        end
        else
        begin
          if NoDelayItem.UseInAllLayers then
          begin
            for LayerIndex := 1 to Group.LayerCount do
            begin
              FLN.Add(MFLayer_Group+LayerIndex);
              FHC_List.Add(PreconsolidationHeadDataArray);
              FSfe_List.Add(ElasticSkeletalStorageCoefficientDataArray);
              FSfv_List.Add(InelasticSkeletalStorageCoefficientDataArray);
              FCom_List.Add(InitialCompactionDataArray);
            end;
          end
          else
          begin
            for LayerIndex := 1 to Group.LayerCount do
            begin
              if NoDelayItem.UsedLayers.GetItemByLayerNumber(LayerIndex) <> nil then
              begin
                FLN.Add(MFLayer_Group+LayerIndex);
                FHC_List.Add(PreconsolidationHeadDataArray);
                FSfe_List.Add(ElasticSkeletalStorageCoefficientDataArray);
                FSfv_List.Add(InelasticSkeletalStorageCoefficientDataArray);
                FCom_List.Add(InitialCompactionDataArray);
              end;
            end;
          end;
        end;
      end;

      for SubsidenceIndex := 0 to Group.SubDelayBedLayers.Count - 1 do
      begin
        DelayItem := Group.SubDelayBedLayers[SubsidenceIndex];
        EquivNumberDataArray := PhastModel.GetDataSetByName(
          DelayItem.EquivNumberDataArrayName);
        Assert(EquivNumberDataArray <> nil);
        VerticalHydraulicConductivityDataArray := PhastModel.GetDataSetByName(
          DelayItem.VerticalHydraulicConductivityDataArrayName);
        Assert(VerticalHydraulicConductivityDataArray <> nil);
        ElasticSpecificStorageDataArray := PhastModel.GetDataSetByName(
          DelayItem.ElasticSpecificStorageDataArrayName);
        Assert(ElasticSpecificStorageDataArray <> nil);
        InelasticSpecificStorageDataArray := PhastModel.GetDataSetByName(
          DelayItem.InelasticSpecificStorageDataArrayName);
        Assert(InelasticSpecificStorageDataArray <> nil);
        InterbedStartingHeadDataArray := PhastModel.GetDataSetByName(
          DelayItem.InterbedStartingHeadDataArrayName);
        Assert(InterbedStartingHeadDataArray <> nil);
        InterbedPreconsolidationHeadDataArray := PhastModel.GetDataSetByName(
          DelayItem.InterbedPreconsolidationHeadDataArrayName);
        Assert(InterbedPreconsolidationHeadDataArray <> nil);
        InterbedStartingCompactionDataArray := PhastModel.GetDataSetByName(
          DelayItem.InterbedStartingCompactionDataArrayName);
        Assert(InterbedStartingCompactionDataArray <> nil);
        InterbedEquivalentThicknessDataArray := PhastModel.GetDataSetByName(
          DelayItem.InterbedEquivalentThicknessDataArrayName);
        Assert(InterbedEquivalentThicknessDataArray <> nil);
        if Group.LayerCount = 1 then
        begin
          FLDN.Add(MFLayer_Group+1);
          FRNB_List.Add(EquivNumberDataArray);
          FDelayVK_List.Add(VerticalHydraulicConductivityDataArray);
          FDelayElasticSpecificStorage_List.Add(ElasticSpecificStorageDataArray);
          FDelayInElasticSpecificStorage_List.Add(InelasticSpecificStorageDataArray);
          FDstart_List.Add(InterbedStartingHeadDataArray);
          FDHC_List.Add(InterbedPreconsolidationHeadDataArray);
          FDCOM_List.Add(InterbedStartingCompactionDataArray);
          FDZ_List.Add(InterbedEquivalentThicknessDataArray);
        end
        else
        begin
          if DelayItem.UseInAllLayers then
          begin
            for LayerIndex := 1 to Group.LayerCount do
            begin
              FLDN.Add(MFLayer_Group+LayerIndex);
              FRNB_List.Add(EquivNumberDataArray);
              FDelayVK_List.Add(VerticalHydraulicConductivityDataArray);
              FDelayElasticSpecificStorage_List.Add(ElasticSpecificStorageDataArray);
              FDelayInElasticSpecificStorage_List.Add(InelasticSpecificStorageDataArray);
              FDstart_List.Add(InterbedStartingHeadDataArray);
              FDHC_List.Add(InterbedPreconsolidationHeadDataArray);
              FDCOM_List.Add(InterbedStartingCompactionDataArray);
              FDZ_List.Add(InterbedEquivalentThicknessDataArray);
            end;
          end
          else
          begin
            for LayerIndex := 1 to Group.LayerCount do
            begin
              if DelayItem.UsedLayers.GetItemByLayerNumber(LayerIndex) <> nil then
              begin
                FLDN.Add(MFLayer_Group+LayerIndex);
                FRNB_List.Add(EquivNumberDataArray);
                FDelayVK_List.Add(VerticalHydraulicConductivityDataArray);
                FDelayElasticSpecificStorage_List.Add(ElasticSpecificStorageDataArray);
                FDelayInElasticSpecificStorage_List.Add(InelasticSpecificStorageDataArray);
                FDstart_List.Add(InterbedStartingHeadDataArray);
                FDHC_List.Add(InterbedPreconsolidationHeadDataArray);
                FDCOM_List.Add(InterbedStartingCompactionDataArray);
                FDZ_List.Add(InterbedEquivalentThicknessDataArray);
              end;
            end;
          end;
        end;
      end;
      Inc(MFLayer_Group,Group.LayerCount);
    end;
  end;
  Assert(FLN.Count = FHC_List.Count);
  Assert(FLN.Count = FSfe_List.Count);
  Assert(FLN.Count = FSfv_List.Count);
  Assert(FLN.Count = FCom_List.Count);

  Assert(FLDN.Count = FRNB_List.Count);
  Assert(FLDN.Count = FDelayVK_List.Count);
  Assert(FLDN.Count = FDelayElasticSpecificStorage_List.Count);
  Assert(FLDN.Count = FDelayInElasticSpecificStorage_List.Count);
  Assert(FLDN.Count = FDstart_List.Count);
  Assert(FLDN.Count = FDCOM_List.Count);
  Assert(FLDN.Count = FDZ_List.Count);
end;

procedure TModflowSUB_Writer.WriteDataSet1;
var
  ISUBCB: Integer;
  ISUBOC: Integer;
  NNDB: Integer;
  NDB: Integer;
  NMZ: integer;
  NN: integer;
  AC1: Double;
  AC2: Double;
  ITMIN: Integer;
  IDSAVE: Integer;
  SaveRestartFileName: string;
  IDREST: Integer;
  ReadRestartFileName: string;
begin
  GetFlowUnitNumber(ISUBCB);
  ISUBOC := FSubPackage.PrintChoices.Count;
  NNDB := PhastModel.LayerStructure.NoDelayCount;
  NDB := PhastModel.LayerStructure.DelayCount;
  NMZ := FDP_List.Count;
  NN := FSubPackage.NumberOfNodes;
  AC1 := FSubPackage.AccelerationParameter1;
  AC2 := FSubPackage.AccelerationParameter2;
  ITMIN := FSubPackage.MinIterations;
  SaveRestartFileName := '';
  if FSubPackage.SaveDelayRestart then
  begin
    IDSAVE := PhastModel.UnitNumbers.UnitNumber(StrSUBSaveRestart);

    SaveRestartFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.rst'));
    WriteToNameFile(StrDATABINARY, IDSAVE,
      SaveRestartFileName, foOutput);
  end
  else
  begin
    IDSAVE := 0;
  end;

  if FSubPackage.ReadDelayRestartFileName = '' then
  begin
    IDREST := 0;
  end
  else
  begin
    IDREST := PhastModel.UnitNumbers.UnitNumber(StrSUBReadRestart);
    ReadRestartFileName := ExtractRelativePath(FNameOfFile, 
      FSubPackage.ReadDelayRestartFileName);
    if SaveRestartFileName = ReadRestartFileName then
    begin
      frmErrorsAndWarnings.AddError(
        'Restart File names identical for SUB package',
        'The restart file saved by the Subsidence package has the same name '
        + 'as the restart file read by Subsidence package to define the '
        + 'starting head and starting preconsolidation head.  '
        + 'You need to change the name of the file read by the Subsidence '
        + 'package in the "Model|Packages and Programs" dialog box.');
    end;
    WriteToNameFile(StrDATABINARY, IDREST,
      ReadRestartFileName, foInput, True);
  end;

  WriteInteger(ISUBCB);
  WriteInteger(ISUBOC);
  WriteInteger(NNDB);
  WriteInteger(NDB);
  WriteInteger(NMZ);
  WriteInteger(NN);
  WriteFloat(AC1);
  WriteFloat(AC2);
  WriteInteger(ITMIN);
  WriteInteger(IDSAVE);
  WriteInteger(IDREST);
  
  WriteString(' # ISUBCB ISUBOC NNDB NDB NMZ NN AC1 AC2 ITMIN IDSAVE IDREST');
  NewLine;
  
end;

procedure TModflowSUB_Writer.WriteDataSet15;
var
  Ifm1: Integer;
  Iun1: Integer;
  AFileName: string;
  Ifm2: Integer;
  Iun2: Integer;
  Ifm3: Integer;
  Iun3: Integer;
  Ifm4: Integer;
  Iun4: Integer;
  Ifm5: Integer;
  Iun5: Integer;
  Ifm6: Integer;
  Iun6: Integer;
  Index: Integer;
  PrintChoice: TSubPrintItem;
  Save1: Boolean;
  Save2: Boolean;
  Save3: Boolean;
  Save4: Boolean;
  Save5: Boolean;
  Save6: Boolean;
  SubFileName: string;
  function GetCombinedUnitNumber: integer;
  begin
    result := PhastModel.UnitNumbers.UnitNumber(StrSubSUB_Out);
    if SubFileName = '' then
    begin
      SubFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.Sub_Out'));
      WriteToNameFile(StrDATABINARY, result,
        SubFileName, foOutput);
    end;
  end;
begin

  if FSubPackage.PrintChoices.Count > 0 then
  begin
    Save1 := False;
    Save2 := False;
    Save3 := False;
    Save4 := False;
    Save5 := False;
    Save6 := False;
    for Index := 0 to FSubPackage.PrintChoices.Count - 1 do
    begin
      PrintChoice := FSubPackage.PrintChoices[Index];
      Save1 := Save1 or PrintChoice.SaveSubsidence;
      Save2 := Save2 or PrintChoice.SaveCompactionByModelLayer;
      Save3 := Save3 or PrintChoice.SaveCompactionByInterbedSystem;
      Save4 := Save4 or PrintChoice.SaveVerticalDisplacement;
      Save5 := Save5 or PrintChoice.SaveCriticalHeadNoDelay;
      Save6 := Save6 or PrintChoice.SaveCriticalHeadDelay;
      if Save1 and Save2 and Save3 and Save4 and Save5 and Save6 then
      begin
        break;
      end;
    end;
    Ifm1 := FSubPackage.PrintFormats.SubsidenceFormat;
    SubFileName := '';
    Iun1 := 0;
    if Save1 then
    begin
      case FSubPackage.BinaryOutputChoice of
        sbocSingleFile:
          begin
            Iun1 := GetCombinedUnitNumber;
          end;
        sbocMultipleFiles:
          begin
            Iun1 := PhastModel.UnitNumbers.UnitNumber(StrSubSUB_Out);
            AFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.SubSubOut'));
            WriteToNameFile(StrDATABINARY, Iun1,
              AFileName, foOutput);
          end
        else Assert(False);
      end;
    end;

    Ifm2 := FSubPackage.PrintFormats.CompactionByModelLayerFormat;
    Iun2 := 0;
    if Save2 then
    begin
      case FSubPackage.BinaryOutputChoice of
        sbocSingleFile:
          begin
            Iun2 := GetCombinedUnitNumber;
          end;
        sbocMultipleFiles:
          begin
            Iun2 := PhastModel.UnitNumbers.UnitNumber(StrSubCOM_ML_Out);
            AFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.SubComMlOut'));
            WriteToNameFile(StrDATABINARY, Iun2,
              AFileName, foOutput);
          end
        else Assert(False);
      end;
    end;

    Ifm3 := FSubPackage.PrintFormats.CompactionByInterbedSystemFormat;
    Iun3 := 0;
    if Save3 then
    begin
      case FSubPackage.BinaryOutputChoice of
        sbocSingleFile:
          begin
            Iun3 := GetCombinedUnitNumber;
          end;
        sbocMultipleFiles:
          begin
            Iun3 := PhastModel.UnitNumbers.UnitNumber(StrSubCOM_IS_Out);
            AFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.SubComIsOut'));
            WriteToNameFile(StrDATABINARY, Iun3,
              AFileName, foOutput);
          end
        else Assert(False);
      end;
    end;

    Ifm4 := FSubPackage.PrintFormats.VerticalDisplacementFormat;
    Iun4 := 0;
    if Save4 then
    begin
      case FSubPackage.BinaryOutputChoice of
        sbocSingleFile:
          begin
            Iun4 := GetCombinedUnitNumber;
          end;
        sbocMultipleFiles:
          begin
            Iun4 := PhastModel.UnitNumbers.UnitNumber(StrSub_VD_Out);
            AFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.SubVdOut'));
            WriteToNameFile(StrDATABINARY, Iun4,
              AFileName, foOutput);
          end
        else Assert(False);
      end;
    end;

    Ifm5 := FSubPackage.PrintFormats.NoDelayPreconsolidationHeadFormat;
    Iun5 := 0;
    if Save5 then
    begin
      case FSubPackage.BinaryOutputChoice of
        sbocSingleFile:
          begin
            Iun5 := GetCombinedUnitNumber;
          end;
        sbocMultipleFiles:
          begin
            Iun5 := PhastModel.UnitNumbers.UnitNumber(StrSub_NDPCH_Out);
            AFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.SubNdCritHeadOut'));
            WriteToNameFile(StrDATABINARY, Iun5,
              AFileName, foOutput);
          end
        else Assert(False);
      end;
    end;

    Ifm6 := FSubPackage.PrintFormats.DelayPreconsolidationHeadFormat;
    Iun6 := 0;
    if Save6 then
    begin
      case FSubPackage.BinaryOutputChoice of
        sbocSingleFile:
          begin
            Iun6 := GetCombinedUnitNumber;
          end;
        sbocMultipleFiles:
          begin
            Iun6 := PhastModel.UnitNumbers.UnitNumber(StrSub_DPCH_Out);
            AFileName := ExtractFileName(ChangeFileExt(FNameOfFile, '.SubDCritHeadOut'));
            WriteToNameFile(StrDATABINARY, Iun6,
              AFileName, foOutput);
          end
        else Assert(False);
      end;
    end;

    WriteInteger(Ifm1);
    WriteInteger(Iun1);
    WriteInteger(Ifm2);
    WriteInteger(Iun2);
    WriteInteger(Ifm3);
    WriteInteger(Iun3);
    WriteInteger(Ifm4);
    WriteInteger(Iun4);
    WriteInteger(Ifm5);
    WriteInteger(Iun5);
    WriteInteger(Ifm6);
    WriteInteger(Iun6);
    WriteString(' # Ifm1 Iun1 Ifm2 Iun2 Ifm3 Iun3 Ifm4 Iun4 Ifm5 Iun5 Ifm6 Iun6');
    NewLine;
  end;
end;

const
  Epsilon = 1e-6;

function StartTimeOK(Time: double; PrintChoice: TSubPrintItem): boolean;
begin
  result := PrintChoice.StartTime + Abs(PrintChoice.StartTime)*Epsilon <= Time
end;

function EndTimeOK(Time: double; PrintChoice: TSubPrintItem): boolean;
begin
  result := Time >= PrintChoice.EndTime - Abs(PrintChoice.EndTime)*Epsilon;
end;

procedure TModflowSUB_Writer.WriteDataSet16;
var
  PrintChoice: TSubPrintItem;
  ISP1, ISP2, ITS1, ITS2: integer;
  StressPeriod: TModflowStressPeriod;
  LengthOfTimeStep: Double;
  PrintChoiceIndex: Integer;
  StressPeriodIndex: Integer;
  TimeStepIndex: Integer;
  Ifl1: Integer;
  Ifl2: Integer;
  Ifl3: Integer;
  Ifl4: Integer;
  Ifl5: Integer;
  Ifl6: Integer;
  Ifl7: Integer;
  Ifl8: Integer;
  Ifl9: Integer;
  Ifl10: Integer;
  Ifl11: Integer;
  Ifl12: Integer;
  Ifl13: Integer;
  Time: double;
begin
  FSubPackage.PrintChoices.ReportErrors;
  for PrintChoiceIndex := 0 to FSubPackage.PrintChoices.Count -1 do
  begin
    PrintChoice := FSubPackage.PrintChoices[PrintChoiceIndex];
    if PrintChoice.StartTime <= PrintChoice.EndTime then
    begin
      ISP1 := 0;
      ITS1 := 0;
      ISP2 := 0;
      ITS2 := 0;
      StressPeriod := PhastModel.ModflowFullStressPeriods[0];
      if StartTimeOK(StressPeriod.StartTime, PrintChoice) then
//      if PrintChoice.StartTime <= StressPeriod.StartTime then
      begin
        ISP1 := 1;
        ITS1 := 1;
      end
      else
      begin
        for StressPeriodIndex := 0 to PhastModel.ModflowFullStressPeriods.Count - 1 do
        begin
          StressPeriod := PhastModel.ModflowFullStressPeriods[StressPeriodIndex];
          if StressPeriod.EndTime > PrintChoice.StartTime then
          begin
            ISP1 := StressPeriodIndex+1;
            if StartTimeOK(StressPeriod.StartTime, PrintChoice) then
//            if PrintChoice.StartTime <= StressPeriod.StartTime then
            begin
              ITS1 := 1;
            end
            else
            begin
              Time := StressPeriod.StartTime;
              LengthOfTimeStep := StressPeriod.LengthOfFirstTimeStep;
              for TimeStepIndex := 0 to StressPeriod.NumberOfSteps - 1 do
              begin
                Time := Time + LengthOfTimeStep;
                if StartTimeOK(Time, PrintChoice) then
//                if PrintChoice.StartTime <= Time then
                begin
                  ITS1 := TimeStepIndex;
                  if ITS1 = 0 then
                  begin
                    ITS1 := 1;
                  end;
                  break;
                end;
                LengthOfTimeStep := LengthOfTimeStep 
                  * StressPeriod.TimeStepMultiplier;
              end;
              if ITS1 = 0 then
              begin
                ITS1 := StressPeriod.NumberOfSteps;
              end;
            end;
            break;
          end;
        end;
      end;


      StressPeriod := PhastModel.ModflowFullStressPeriods[
        PhastModel.ModflowFullStressPeriods.Count-1];
      if PrintChoice.EndTime >= StressPeriod.EndTime then
      begin
        ISP2 := PhastModel.ModflowFullStressPeriods.Count;
        ITS2 := StressPeriod.NumberOfSteps;
      end
      else
      begin
        for StressPeriodIndex := ISP1-1 to PhastModel.ModflowFullStressPeriods.Count - 1 do
        begin
          StressPeriod := PhastModel.ModflowFullStressPeriods[StressPeriodIndex];
          if EndTimeOK(StressPeriod.EndTime, PrintChoice) then
//          if StressPeriod.EndTime >= PrintChoice.EndTime then
          begin
            ISP2 := StressPeriodIndex+1;
            if StressPeriod.EndTime = PrintChoice.EndTime then
            begin
              ITS2 := StressPeriod.NumberOfSteps;
            end
            else
            begin
              Time := StressPeriod.StartTime;
              LengthOfTimeStep := StressPeriod.LengthOfFirstTimeStep;
              for TimeStepIndex := 0 to StressPeriod.NumberOfSteps - 1 do
              begin
                Time := Time + LengthOfTimeStep;
                if EndTimeOK(Time, PrintChoice) then
//                if Time >= PrintChoice.EndTime then
                begin
                  ITS2 := TimeStepIndex + 1;
                  break;
                end;
                LengthOfTimeStep := LengthOfTimeStep
                  * StressPeriod.TimeStepMultiplier;
              end;
              if ITS2 = 0 then
              begin
                ITS2 := StressPeriod.NumberOfSteps;
              end;
            end;
            break;
          end;
        end;
      end;
      Ifl1 := Ord(PrintChoice.PrintSubsidence);
      Ifl2  := Ord(PrintChoice.SaveSubsidence);
      Ifl3 := Ord(PrintChoice.PrintCompactionByModelLayer);
      Ifl4 := Ord(PrintChoice.SaveCompactionByModelLayer);
      Ifl5 := Ord(PrintChoice.PrintCompactionByInterbedSystem);
      Ifl6 := Ord(PrintChoice.SaveCompactionByInterbedSystem);
      Ifl7 := Ord(PrintChoice.PrintVerticalDisplacement);
      Ifl8 := Ord(PrintChoice.SaveVerticalDisplacement);
      Ifl9 := Ord(PrintChoice.PrintCriticalHeadNoDelay);
      Ifl10 := Ord(PrintChoice.SaveCriticalHeadNoDelay);
      Ifl11 := Ord(PrintChoice.PrintCriticalHeadDelay);
      Ifl12 := Ord(PrintChoice.SaveCriticalHeadDelay);
      Ifl13 := Ord(PrintChoice.PrintDelayBudgets); 
      WriteInteger(ISP1);
      WriteInteger(ISP2);
      WriteInteger(ITS1);
      WriteInteger(ITS2);
      WriteInteger(Ifl1);
      WriteInteger(Ifl2);
      WriteInteger(Ifl3);
      WriteInteger(Ifl4);
      WriteInteger(Ifl5);
      WriteInteger(Ifl6);
      WriteInteger(Ifl7);
      WriteInteger(Ifl8);
      WriteInteger(Ifl9);
      WriteInteger(Ifl10);
      WriteInteger(Ifl11);
      WriteInteger(Ifl12);
      WriteInteger(Ifl13);
      WriteString(' # ISP1 ISP2 ITS1 ITS2 Ifl1 Ifl2 Ifl3 Ifl4 Ifl5 Ifl6 Ifl7 Ifl8 Ifl9 Ifl10 Ifl11 Ifl12 Ifl13');   
      NewLine;
    end;
  end;

end;

procedure TModflowSUB_Writer.WriteDataSet2;
var
  Index: Integer;
begin
  if FLN.Count = 0 then
  begin
    Exit;
  end;
  for Index := 0 to FLN.Count - 1 do
  begin
    WriteInteger(FLN[Index]);
  end;
  WriteString(' # LN');
  NewLine;
end;

procedure TModflowSUB_Writer.WriteDataSet3;
var
  Index: Integer;
begin
  if FLDN.Count = 0 then
  begin
    Exit;
  end;
  for Index := 0 to FLDN.Count - 1 do
  begin
    WriteInteger(FLDN[Index]);
  end;
  WriteString(' # LDN');
  NewLine;
end;

procedure TModflowSUB_Writer.WriteDataSet4;
var
  Index: Integer;
  DataArray: TDataArray;
begin
  for Index := 0 to FRNB_List.Count - 1 do
  begin
    DataArray := FRNB_List[Index];
    WriteArray(DataArray, 0, 'RNB');
    PhastModel.AddDataSetToCache(DataArray);
  end;
  PhastModel.CacheDataArrays;
end;

procedure TModflowSUB_Writer.WriteDataSet9;
var
  MaterialZone: TMaterialZoneIdItem;
  Index: Integer;
begin
  if FDP_List.Count = 0 then
  begin
    Exit;
  end;
  for Index := 0 to FDP_List.Count - 1 do
  begin
    MaterialZone := FDP_List[Index];
    WriteFloat(MaterialZone.FMaterialZoneValues.VerticalK);
    WriteFloat(MaterialZone.FMaterialZoneValues.ElasticSpecificStorage);
    WriteFloat(MaterialZone.FMaterialZoneValues.InelasticSpecificStorage);
    WriteString(' # DP');
    NewLine;
  end;
end;

procedure TModflowSUB_Writer.WriteDataSets10to14;
var
  Index: Integer;
  DataArray: TDataArray;
begin
  for Index := 0 to FDstart_List.Count - 1 do
  begin
    if self.FSubPackage.ReadDelayRestartFileName = '' then
    begin
      DataArray := FDstart_List[Index];
      WriteArray(DataArray, 0, 'Dstart');
      PhastModel.AddDataSetToCache(DataArray);

      DataArray := FDHC_List[Index];
      WriteArray(DataArray, 0, 'DHC');
      PhastModel.AddDataSetToCache(DataArray);
    end;

    DataArray := FDCOM_List[Index];
    WriteArray(DataArray, 0, 'DCOM');
    PhastModel.AddDataSetToCache(DataArray);
    
    DataArray := FDZ_List[Index];
    WriteArray(DataArray, 0, 'DZ');
    PhastModel.AddDataSetToCache(DataArray);
    
    DataArray := FNZ_List[Index];
    WriteArray(DataArray, 0, 'NZ');
    // This one isn't cached because it is temporary
  end;
  PhastModel.CacheDataArrays;
end;

procedure TModflowSUB_Writer.WriteDataSets5to8;
var
  Index: Integer;
  DataArray: TDataArray;
begin
  for Index := 0 to FHC_List.Count - 1 do
  begin
    DataArray := FHC_List[Index];
    WriteArray(DataArray, 0, 'HC');
    PhastModel.AddDataSetToCache(DataArray);
    DataArray := FSfe_List[Index];
    WriteArray(DataArray, 0, 'Sfe');
    PhastModel.AddDataSetToCache(DataArray);
    DataArray := FSfv_List[Index];
    WriteArray(DataArray, 0, 'Sfv');
    PhastModel.AddDataSetToCache(DataArray);
    DataArray := FCom_List[Index];
    WriteArray(DataArray, 0, 'Com');
    PhastModel.AddDataSetToCache(DataArray);
  end;
  PhastModel.CacheDataArrays;
end;

procedure TModflowSUB_Writer.WriteFile(const AFileName: string);
begin
  FSubPackage := Package as TSubPackageSelection;
  if not FSubPackage.IsSelected then
  begin
    Exit
  end;
  if PhastModel.PackageGeneratedExternally(StrSUB) then
  begin
    Exit;
  end;
  FNameOfFile := FileName(AFileName);
  WriteToNameFile(StrSUB, PhastModel.UnitNumbers.UnitNumber(StrSUB),
    FNameOfFile, foInput);
  Evaluate;
  OpenFile(FNameOfFile);
  try
    frmProgress.AddMessage('Writing SUB Package input.');

    WriteDataSet0;

    frmProgress.AddMessage('  Writing Data Set 1.');
    WriteDataSet1;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 2.');
    WriteDataSet2;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 3.');
    WriteDataSet3;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 4.');
    WriteDataSet4;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Sets 5 to 8.');
    WriteDataSets5to8;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 9.');
    WriteDataSet9;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Sets 10 to 14.');
    WriteDataSets10to14;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 15.');
    WriteDataSet15;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

    frmProgress.AddMessage('  Writing Data Set 16.');
    WriteDataSet16;
    if not frmProgress.ShouldContinue then
    begin
      Exit;
    end;

  finally
    CloseFile;
  end;
end;

{ TMaterialZoneIdItem }

procedure TMaterialZoneIdItem.AssignID;
begin
  ID := MaterialZoneValues.ID;
end;

constructor TMaterialZoneIdItem.Create;
begin
  FNextSameID := nil;
end;

destructor TMaterialZoneIdItem.Destroy;
begin
  NextSameID.Free;
  inherited;
end;

procedure TMaterialZoneIdItem.SetMaterialZoneValues(const Value: TMaterialZone);
begin
  FMaterialZoneValues := Value;
  AssignID;
end;

{ TMaterialZoneList }

function TMaterialZoneList.AddRecord(
  MaterialZone: TMaterialZone): TMaterialZoneIdItem;
var
  LastResult: TMaterialZoneIdItem;
begin
  result := FIdList.ByID[MaterialZone.ID] as TMaterialZoneIdItem;
  if result = nil then
  begin
    result := TMaterialZoneIdItem.Create;
    result.MaterialZoneValues := MaterialZone;
    result.ZoneNumber := FMaterialZones.Add(result)+1;
    FIdList.Add(result);
  end
  else
  begin
    LastResult := nil;
    while Assigned(result) and (result.MaterialZoneValues <> MaterialZone) do
    begin
      LastResult := result;
      result := result.NextSameID;
    end;
    if result = nil then
    begin
      result := TMaterialZoneIdItem.Create;
      result.MaterialZoneValues := MaterialZone;
      result.ZoneNumber := FMaterialZones.Add(result)+1;
      LastResult.NextSameID := result;
    end;
  end;
end;

function TMaterialZoneList.Count: integer;
begin
  result := FMaterialZones.Count;
end;

constructor TMaterialZoneList.Create;
begin
  FMaterialZones:= TList.Create;
  FIdList := TIDList.Create;
end;

destructor TMaterialZoneList.Destroy;
begin
  FIdList.Free;
  FMaterialZones.Free;
  inherited;
end;

function TMaterialZoneList.GetItem(Index: integer): TMaterialZoneIdItem;
begin
  result := FMaterialZones[Index];
end;

end.
