{@abstract(The main purpose of @name is to define @link(TUndoImportDXFFile)
  which is used to import DXF files into GoPhast. It also defines
  @link(TUndoImportDXFFile) which can be used to undo the import.)}
unit frmImportDXFUnit;


interface

uses
  SysUtils, Types, Classes, Variants, Graphics, Controls, Forms,
  Dialogs, StdCtrls, frmCustomGoPhastUnit, Buttons, ExtCtrls,
  Grids, IntListUnit, ScreenObjectUnit, DXF_Structs, DXF_read, DXF_Utils,
  frmImportShapefileUnit, frmCustomImportSimpleFileUnit;

type
  {@abstract(@name is the command used to import
    DXF files or reverse the import.)}
  TUndoImportDXFFile = class(TUndoImportShapefile)
  protected
    // @name describes what @classname does.
    function Description: string; override;
  end;

  {@abstract(@name is used to import DXF files into GoPhast.)
    See @link(TfrmGoPhast.miImportDXFFileClick).}
  TfrmImportDXF = class(TfrmCustomImportSimpleFile)
    // @name calls @link(SetData).
    procedure btnOKClick(Sender: TObject);
    // @name frees @link(FDxfObject).
    procedure FormDestroy(Sender: TObject); override;
  private
    // @name: DXF_Object;
    // @name represents the contents of the DXF file.
    // DXF_Object is defined in DXF_Structs.
    FDxfObject: DXF_Object;
    FDxfName: string;
    // @name is used to transform the coordinates of P
    // based on OCS.
    function CoordConvert(P: Point3D; OCS: pMatrix): Point3D;
    // @name converts the entities from @link(FDxfObject) to
    // @link(TScreenObject)s.
    procedure SetData;
    // @name is used to update @link(frmProgress).
    procedure Think(const Sender: TObject; Message: string);
    { Private declarations }
  public
    // @name is used to open and read a DXF file.  It returns @true
    // if it was able to do so and the file contains something it can use.
    function GetData: boolean;
    { Public declarations }
  end;

implementation

uses frmGoPhastUnit, GoPhastTypes, DataSetUnit, 
  RbwParser, UndoItems, frmProgressUnit, frmDataSetsUnits, ModelMuseUtilities, FastGEO;

{$R *.dfm}

procedure TfrmImportDXF.Think(const Sender: TObject; Message: string);
begin
  frmProgress.ProgressLabelCaption := Message;
end;

function TfrmImportDXF.GetData: boolean;
begin
  inherited;
  UpdateEvalAt;

  result := OpenDialogFile.Execute;
  if result then
  begin
    FDxfName := OpenDialogFile.FileName;
    if not FileExists(FDxfName) then
    begin
      result := False;
      Beep;
      MessageDlg('The ".dxf" file "' + FDxfName + '" does not exist.',
        mtError, [mbOK], 0);
      Exit;
    end;
    Caption := Caption + ' - ' + FDxfName;
    GetDataSets;
    frmProgress.PopupParent := self;
    frmProgress.Show;
    try
      FDxfObject := DXF_Object.Create(name);
      FDxfObject.Progress := frmProgress.pbProgress;
      FDxfObject.OnThinking := Think;
      FDxfObject.ReadFile(FDxfName, frmProgress.memoMessages.Lines);
    finally
      frmProgress.Hide;
    end;

    result := FDxfObject.layer_lists.Count > 0;
    comboDataSets.ItemIndex := 0;
    comboInterpolators.ItemIndex := 4;
  end;
end;

function TfrmImportDXF.CoordConvert(P: Point3D; OCS: pMatrix): Point3D;
begin
  if OCS = nil then
  begin
    result := P;
  end
  else
  begin
    result := TransformPoint(OCS^, P);
  end;
end;

procedure TfrmImportDXF.SetData;
var
  AScreenObject: TScreenObject;
  UndoCreateScreenObject: TCustomUndo;
  ScreenObjectList: TList;
  PointIndex: integer;
  DataSetName: string;
  Position: integer;
  DataSet: TDataArray;
  EntityCount: Integer;
  LayerIndex: integer;
  ALayer: DXF_Layer;
  EntityListIndex: integer;
  EList: Entity_List;
  EntityIndex: integer;
  Entity: DXF_Entity;
  PrimitiveList: TPrimitiveList;
  PrimitiveIndex: integer;
  Points: pointlist;
  InvalidPointCount: integer;
  Undo: TUndoImportDXFFile;
  Root: string;
  ExistingObjectCount: integer;
  NewDataSets: TList;
  function ConvertPoint(const DXF_Point: Point3D): TPoint2D;
  begin
    result.X := DXF_Point.X;
    result.Y := DXF_Point.Y;
  end;
begin
  SetLength(Points, 0);
  InvalidPointCount := 0;
  frmGoPhast.PhastModel.BeginScreenObjectUpdate;
  frmGoPhast.CanDraw := False;
  try
    NewDataSets := TList.Create;
    try
      MakeNewDataSet(NewDataSets, '_DXF_Z',
        strDefaultClassification + '|Imported from DXF files');
      EntityCount := 0;
      for LayerIndex := 0 to FDxfObject.layer_lists.Count - 1 do
      begin
        ALayer := FDxfObject.layer_lists[LayerIndex];
        for EntityListIndex := 0 to ALayer.entity_lists.Count - 1 do
        begin
          if ALayer.entity_names[EntityListIndex] <> Block_.ClassName then
          begin
            EList := ALayer.entity_lists[EntityListIndex];
            EntityCount := EntityCount + EList.entities.Count;
          end;
        end;
      end;
      frmProgress.Prefix := 'Object ';
      frmProgress.PopupParent := self;
      frmProgress.Show;
      frmProgress.pbProgress.Max := EntityCount;
      frmProgress.pbProgress.Position := 0;
      frmProgress.ProgressLabelCaption := '0 out of '
        + IntToStr(EntityCount) + '.';
      DataSetName := comboDataSets.Text;
  //    Position := frmGoPhast.PhastModel.IndexOfDataSet(DataSetName);
    //  Assert(Position >= 0);
      DataSet := frmGoPhast.PhastModel.GetDataSetByName(DataSetName);
      Assert(DataSet <> nil);
      ScreenObjectList := TList.Create;
      //MultipleParts := false;
      try
        Undo := TUndoImportDXFFile.Create;
        try
          Root := TScreenObject.ValidName(
            ExtractFileRoot(OpenDialogFile.FileName)+ '_');
          ScreenObjectList.Capacity := EntityCount;
          ExistingObjectCount :=
            frmGoPhast.PhastModel.NumberOfLargestScreenObjectsStartingWith(Root);
          for LayerIndex := 0 to FDxfObject.layer_lists.Count - 1 do
          begin
            ALayer := FDxfObject.layer_lists[LayerIndex];
            for EntityListIndex := 0 to ALayer.entity_lists.Count - 1 do
            begin
              if ALayer.entity_names[EntityListIndex] <> Block_.ClassName then
              begin
                EList := ALayer.entity_lists[EntityListIndex];
                for EntityIndex := 0 to EList.entities.Count - 1 do
                begin
                  Entity := EList.entities[EntityIndex];
                  SetLength(PrimitiveList, 0);
                  Entity.GetCoordinates(PrimitiveList, CoordConvert, nil);
                  for PrimitiveIndex := 0 to Length(PrimitiveList) - 1 do
                  begin
                    Points := PrimitiveList[PrimitiveIndex];
                    if Length(Points) > 0 then
                    begin
                      AScreenObject :=
                        TScreenObject.CreateWithViewDirection(
                        frmGoPhast.PhastModel, vdTop,
                        UndoCreateScreenObject, False);
                      Inc(ExistingObjectCount);
                      AScreenObject.Name := Root + IntToStr(ExistingObjectCount);
                      AScreenObject.SetValuesOfEnclosedCells
                        := cbEnclosedCells.Checked;
                      AScreenObject.SetValuesOfIntersectedCells
                        := cbIntersectedCells.Checked;
                      AScreenObject.SetValuesByInterpolation
                        := cbInterpolation.Checked;
                      AScreenObject.ColorLine := Entity.colour <> clBlack;
                      AScreenObject.LineColor := Entity.colour;
                      AScreenObject.FillScreenObject := AScreenObject.ColorLine;
                      AScreenObject.FillColor := Entity.colour;
                      AScreenObject.ElevationCount := ecZero;
                      AScreenObject.Capacity := Length(Points);
                      AScreenObject.EvaluatedAt :=
                        TEvaluatedAt(rgEvaluatedAt.ItemIndex);
                      try
                        for PointIndex := 0 to Length(Points) - 1 do
                        begin
                          AScreenObject.AddPoint(ConvertPoint(Points[PointIndex]), False);
                        end;
                        ScreenObjectList.Add(AScreenObject);
                        Position := AScreenObject.AddDataSet(DataSet);
                        Assert(Position >= 0);
                        AScreenObject.DataSetFormulas[Position]
                          := FloatToStr(Entity.p1.z);
                      except on E: EScreenObjectError do
                        begin
                          Inc(InvalidPointCount);
                          AScreenObject.Free;
                        end
                      end;
                    end;
                  end;
                  frmProgress.StepIt;
                  Application.ProcessMessages;
                end;
              end;
            end;
          end;
          if ScreenObjectList.Count > 0 then
          begin
            Undo.StoreNewScreenObjects(ScreenObjectList);
            Undo.StoreNewDataSets(NewDataSets);
            frmGoPhast.UndoStack.Submit(Undo);
            frmGoPhast.PhastModel.AddFileToArchive(FDxfName);
          end
          else
          begin
            Undo.Free
          end;
        except
          Undo.Free;
          raise;
        end;
      finally
        ScreenObjectList.Free;
        frmProgress.Hide;
      end;
    finally
      NewDataSets.Free;
    end;
  finally
    frmGoPhast.CanDraw := True;
    frmGoPhast.PhastModel.EndScreenObjectUpdate;
  end;
  if InvalidPointCount > 0 then
  begin
    Beep;
    MessageDlg(IntToStr(InvalidPointCount) + ' objects were invalid because they cross '
      + 'themselves and have been skipped.',
      mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmImportDXF.btnOKClick(Sender: TObject);
begin
  inherited;
  Hide;
  SetData;
end;

procedure TfrmImportDXF.FormDestroy(Sender: TObject);
begin
  inherited;
  FDxfObject.Free;
end;

{ TUndoImportDXFFile }

function TUndoImportDXFFile.Description: string;
begin
  result := 'import DXF file';
end;

end.


