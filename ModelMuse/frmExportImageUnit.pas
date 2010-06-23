unit frmExportImageUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frmCustomGoPhastUnit, StdCtrls, rmOutlook, ExtCtrls, Buttons, Grids,
  Mask, JvExMask, JvSpin, TntStdCtrls, TntExDropDownEdit,
  TntExDropDownVirtualStringTree, JvExStdCtrls, JvCombobox, VirtualTrees,
  DataSetUnit, RbwDataGrid4, RbwDataGrid, Contnrs, DrawTextUnit,
  InPlaceEditUnit, Types, LegendUnit, GR32, RbwRuler, ExtDlgs, ComCtrls,
  DisplaySettingsUnit, TntButtons;

type
  TfrmExportImage = class(TfrmCustomGoPhast)
    ocSettings: TrmOutlookControl;
    pnlControls: TPanel;
    pnlBottom: TPanel;
    btnHelp: TBitBtn;
    btnClose: TBitBtn;
    btnSaveSettings: TButton;
    opText: TrmOutlookPage;
    memoTitle: TMemo;
    lblTitle: TLabel;
    lblSavedSettings: TLabel;
    comboSavedSettings: TComboBox;
    opView: TrmOutlookPage;
    comboView: TComboBox;
    seImageHeight: TJvSpinEdit;
    lblImageHeight: TLabel;
    lblImageWidth: TLabel;
    seImageWidth: TJvSpinEdit;
    btnFont: TButton;
    fdTextFont: TFontDialog;
    sbSelect: TSpeedButton;
    sbText: TSpeedButton;
    btnTitleFont: TButton;
    cbShowColoredGridLines: TCheckBox;
    cbColorLegend: TCheckBox;
    cbContourLegend: TCheckBox;
    spdSaveImage: TSavePictureDialog;
    cbHorizontalScale: TCheckBox;
    cbVerticalScale: TCheckBox;
    pdPrintImage: TPrintDialog;
    scrollBoxPreview: TScrollBox;
    imagePreview: TImage;
    timerDrawImageDelay: TTimer;
    btnRefresh: TBitBtn;
    btnManageSettings: TButton;
    lblSelectedView: TLabel;
    btnSaveImage: TTntBitBtn;
    procedure FormCreate(Sender: TObject); override;
    procedure seImageHeightChange(Sender: TObject);
    procedure seImageWidthChange(Sender: TObject);
    procedure btnTitleFontClick(Sender: TObject);
    procedure memoTitleChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject); override;
    procedure imagePreviewDblClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure imagePreviewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imagePreviewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbColorLegendClick(Sender: TObject);
    procedure cbContourLegendClick(Sender: TObject);
    procedure cbShowColoredGridLinesClick(Sender: TObject);
    procedure comboViewChange(Sender: TObject);
    procedure cbHorizontalScaleClick(Sender: TObject);
    procedure cbVerticalScaleClick(Sender: TObject);
    procedure btnSaveImageClick(Sender: TObject);
    procedure timerDrawImageDelayTimer(Sender: TObject);
    procedure btnSaveSettingsClick(Sender: TObject);
    procedure comboSavedSettingsCloseUp(Sender: TObject);
    procedure comboSavedSettingsChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnManageSettingsClick(Sender: TObject);
    procedure comboSavedSettingsDropDown(Sender: TObject);
  private
    FShouldDraw: Boolean;
    FTextItems: TList;
    FDoubleClicked: Boolean;
    FDefaultFont: TFont;
    FSelectingItem: Boolean;
    FSelectedItem: TDrawItem;
    FChangingFont: Boolean;
    FInPlaceEdit: TRbwInplaceEdit;
    FStartX: Integer;
    FStartY: Integer;
    FPriorX: Integer;
    FPriorY: Integer;
    FModelImage: TBitMap32;
    FChangeTime: TDateTime;
    FShouldChange: Boolean;
    FQuerySaveSettings: boolean;
    FCanDraw: Boolean;
    procedure GetData;
    procedure DrawImageAfterDelay;
    procedure DrawTitle(DrawingRect: TRect; ACanvas: TCanvas;
      out TitleRect: TRect);
    procedure DrawTextItems(ACanvas: TCanvas);
    procedure DefaultFontChanged(Sender: TObject);
    procedure SetSelectedItem(const Value: TDrawItem);
    procedure DrawContourLegend(ACanvas: TCanvas; var LegendY: Integer;
      out ContourRect: TRect);
    property SelectedItem: TDrawItem read FSelectedItem write SetSelectedItem;
    procedure SelectItemToDrag(X: Integer; Y: Integer);
    function DragItem(X, Y: Integer): Boolean;
    function FinishEditingExistingItem: Boolean;
    procedure AddItem;
    procedure ItemChanged(Sender: TObject);
    function CreateInplaceEditForExistingItem(X, Y: Integer): Boolean;
    procedure ResizeInplaceEdit(Sender: TObject);
    procedure CreateInplaceEditForNewItem(X: Integer; Y: Integer);
    procedure DrawColorLegend(ACanvas: TCanvas; var LegendY: Integer;
      out ColorRect: TRect);
    procedure DrawModel(DrawingRect: TRect; ACanvas: TCanvas);
    procedure DrawHorizontalScale(var ACanvas: TCanvas; var DrawingRect: TRect);
    procedure DrawVerticalScale(var ACanvas: TCanvas; var DrawingRect: TRect);
    procedure DrawBackgroundImages(BitMap32: TBitmap32);
    procedure DrawOnCanvas(CanvasWidth, CanvasHeight: Integer;
      ACanvas: TCanvas);
    procedure DrawBackground(ACanvas: TCanvas;
      CanvasHeight, CanvasWidth: Integer);
    procedure DrawOutsideItems(CanvasHeight, CanvasWidth: Integer;
      var DrawingRect: TRect; ACanvas: TCanvas);
    procedure DrawImage;
    procedure SaveContourSettings(
      ContourDisplaySettings: TContourDisplaySettings);
    procedure SaveColorDisplaySettings(
      ColorDisplaySettings: TColorDisplaySettings);
    procedure SaveSettings;
    procedure ApplySettings;
    procedure ApplyContourDisplaySettings(
      ContourDisplaySettings: TContourDisplaySettings);
    procedure ApplyColorDisplaySettings(
      ColorDisplaySettings: TColorDisplaySettings);
    procedure UpdateModelColors;
    { Private declarations }
  public
    { Public declarations }
  end;

var frmExportImage: TfrmExportImage = nil;  

implementation

uses
  EdgeDisplayUnit, Math, JclAnsiStrings, GoPhastTypes, frmGoPhastUnit,
  AbstractGridUnit, BigCanvasMethods, ScreenObjectUnit,
  CompressedImageUnit, frameViewUnit, PhastModelUnit, frmGoToUnit,
  frmContourDataUnit, frmGridColorUnit, UndoItems, frmManageSettingsUnit,
  UndoItemsScreenObjects;

{$R *.dfm}

procedure TfrmExportImage.AddItem;
var
  Item: TDrawItem;
  ARect: TRect;
begin
  if Trim(FInPlaceEdit.Text) <> '' then
  begin
    Item := TDrawItem.Create;
    Item.OnChange := ItemChanged;
    FTextItems.Add(Item);
    ARect := Item.Rect;
    ARect.Left := FPriorX + scrollBoxPreview.HorzScrollBar.Position;
    ARect.Top := FPriorY + scrollBoxPreview.VertScrollBar.Position;
    Item.Rect := ARect;
    Item.Text := FInPlaceEdit.Text;
    Item.Font.Assign(FDefaultFont);
    Item.Selected := True;
    Item.Editing := False;
    SelectedItem := Item;
    FShouldDraw := True;
    FQuerySaveSettings := True;
  end;
end;

procedure TfrmExportImage.btnFontClick(Sender: TObject);
begin
  inherited;
  fdTextFont.Font := FDefaultFont;
  if fdTextFont.Execute then
  begin
    FDefaultFont.Assign(fdTextFont.Font);
    FQuerySaveSettings := True;
  end;
end;

procedure TfrmExportImage.btnManageSettingsClick(Sender: TObject);
begin
  inherited;
  ShowAForm(TfrmManageSettings);
  GetData;
end;

procedure TfrmExportImage.btnSaveImageClick(Sender: TObject);
const

  MillimeterPerInchTimes100 = 2540;
//  EmpricalFactor = 30;
var
  MetaFile: TMetaFile;
  MetaFileCanvas: TMetaFileCanvas;
  CanvasWidth: Integer;
  CanvasHeight: Integer;
  DrawingRect: TRect;
  Factor: integer;
  DC: HDC;
  RealPixelsPerInch: Integer;
  VerticalSize: Integer;
  VerticalSizeInches: double;
  VerticalResolution: Integer;
begin
  inherited;
  // You would think that Screen.PixelsPerInch would give you
  // what you need here but no such luck.
  DC := GetDC(0);
  VerticalSize := GetDeviceCaps(DC, VERTSIZE);
  VerticalSizeInches := VerticalSize/25.4;
  VerticalResolution := GetDeviceCaps(DC, VERTRES);
  RealPixelsPerInch := Trunc(VerticalResolution / VerticalSizeInches);
  ReleaseDC(0, DC);
  Factor := MillimeterPerInchTimes100 div RealPixelsPerInch;
  if spdSaveImage.Execute then
  begin
    MetaFile := TMetaFile.Create;
    try
      MetaFile.MMWidth := seImageWidth.AsInteger
        * MillimeterPerInchTimes100 div RealPixelsPerInch;
      MetaFile.MMHeight := seImageHeight.AsInteger
        * MillimeterPerInchTimes100 div RealPixelsPerInch;
      CanvasWidth := MetaFile.MMWidth;
      CanvasHeight := MetaFile.MMHeight;
      MetaFileCanvas := TMetaFileCanvas.Create(MetaFile, 0);
      try
        DrawOutsideItems(CanvasHeight, CanvasWidth, DrawingRect, MetaFileCanvas);
      finally
        MetaFileCanvas.Free;
      end;
    finally
      MetaFile.Free;
    end;

    MetaFile := TMetaFile.Create;
    try
      MetaFile.MMWidth := seImageWidth.AsInteger
        + ((CanvasWidth - DrawingRect.Right)
        + DrawingRect.Left);
      MetaFile.MMWidth := MetaFile.MMWidth * Factor;

      MetaFile.MMHeight := seImageHeight.AsInteger
        + ((CanvasHeight - DrawingRect.Bottom)
        + DrawingRect.Top);
      MetaFile.MMHeight := MetaFile.MMHeight * Factor;

      MetaFileCanvas := TMetaFileCanvas.Create(MetaFile, 0);
      try
        DrawOnCanvas(
          MetaFile.MMWidth div Factor,
          MetaFile.MMHeight div Factor,
          MetaFileCanvas);
      finally
        MetaFileCanvas.Free;
      end;
      imagePreview.Picture.Assign(MetaFile);
      MetaFile.SaveToFile(spdSaveImage.FileName);
    finally
      MetaFile.Free;
    end;
  end;
end;

procedure TfrmExportImage.btnSaveSettingsClick(Sender: TObject);
begin
  inherited;
  if (comboSavedSettings.ItemIndex = 0) or (comboSavedSettings.Text = '') then
  begin
    Beep;
    MessageDlg('You must enter a name for these settings to save them.  '
    + 'Type the name in the "Saved settings" box.',
      mtError, [mbOK], 0);
  end
  else
  begin
    SaveSettings;
  end;
end;

procedure TfrmExportImage.btnTitleFontClick(Sender: TObject);
begin
  inherited;
  fdTextFont.Font := memoTitle.Font;
  if fdTextFont.Execute then
  begin
    memoTitle.Font := fdTextFont.Font;
    DrawImage;
    FQuerySaveSettings := True;
  end;
end;

procedure TfrmExportImage.cbColorLegendClick(Sender: TObject);
begin
  inherited;
  DrawImage;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.cbContourLegendClick(Sender: TObject);
begin
  inherited;
  DrawImage;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.cbHorizontalScaleClick(Sender: TObject);
begin
  inherited;
  DrawImage;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.cbShowColoredGridLinesClick(Sender: TObject);
begin
  inherited;
  FreeAndNil(FModelImage);
  DrawImageAfterDelay;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.cbVerticalScaleClick(Sender: TObject);
begin
  inherited;
  DrawImage;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.comboSavedSettingsChange(Sender: TObject);
begin
  inherited;
  if FShouldChange then
  begin
    ApplySettings;
    FreeAndNil(FModelImage);
    DrawImage;
  end;
  FShouldChange := False;
end;

procedure TfrmExportImage.comboSavedSettingsCloseUp(Sender: TObject);
begin
  inherited;
  FShouldChange := True;
end;

procedure TfrmExportImage.comboSavedSettingsDropDown(Sender: TObject);
begin
  inherited;
  if FQuerySaveSettings then
  begin
    FQuerySaveSettings := False;
    if (MessageDlg('Do you want to save the current image settings.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      btnSaveSettingsClick(nil);
    end;
  end;
end;

procedure TfrmExportImage.comboViewChange(Sender: TObject);
var
  ViewDirection: TViewDirection;
begin
  inherited;
  FreeAndNil(FModelImage);
  ViewDirection := TViewDirection(comboView.ItemIndex);
  case ViewDirection of
    vdTop:
      begin
        seImageHeight.AsInteger := frmGoPhast.frameTopView.ZoomBox.Height;
        seImageWidth.AsInteger := frmGoPhast.frameTopView.ZoomBox.Width;
      end;
    vdFront:
      begin
        seImageHeight.AsInteger := frmGoPhast.frameFrontView.ZoomBox.Height;
        seImageWidth.AsInteger := frmGoPhast.frameFrontView.ZoomBox.Width;
      end;
    vdSide:
      begin
        seImageHeight.AsInteger := frmGoPhast.frameSideView.ZoomBox.Width;
        seImageWidth.AsInteger := frmGoPhast.frameSideView.ZoomBox.Height;
      end;
  end;
  DrawImageAfterDelay;
  FQuerySaveSettings := True;
end;

function TfrmExportImage.CreateInplaceEditForExistingItem(X,
  Y: Integer): Boolean;
var
  Index: Integer;
  Item: TDrawItem;
  CanSelect: boolean;
  EditText: string;
  ARect: TRect;
begin
  result := False;
  SelectedItem := nil;
  if sbText.Down then
  begin
    CanSelect := True;
    for Index := FTextItems.Count - 1 downto 0 do
    begin
      Item := FTextItems[Index];
      if CanSelect and PtInRect(Item.Rect, Point(X, Y)) then
      begin
        CanSelect := False;
        Item.Selected := True;
        SelectedItem := Item;
        if FDoubleClicked then
        begin
          Item.Editing := True;
          FDoubleClicked := False;
          FInPlaceEdit := TRbwInplaceEdit.Create(self);
          try
            EditText := Item.Text;
            ARect.Left := Item.Rect.Left + scrollBoxPreview.Left - 3
              - scrollBoxPreview.HorzScrollBar.Position;
            ARect.Top := Item.Rect.Top
              - scrollBoxPreview.VertScrollBar.Position;
            ARect.Right := Item.Rect.Left + 16;
            ARect.Bottom := Item.Rect.Top + 8;

            FInPlaceEdit.Parent := self;
            FInPlaceEdit.Font := FDefaultFont;
            FInPlaceEdit.SetBounds(ARect.Left, ARect.Top,
              ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
            FInPlaceEdit.OnChange := ResizeInplaceEdit;
            FInPlaceEdit.Text := EditText;
            FShouldDraw := True;
            FInPlaceEdit.SelectAll;
            FInPlaceEdit.SetFocus;
            FInPlaceEdit.MouseCapture := False;
            FInPlaceEdit.Run;
            SelectedItem := nil;
            if (FInPlaceEdit <> nil) and (FInPlaceEdit.ModalResult = mrOK) then
            begin
              if FInPlaceEdit.Text = '' then
              begin
                FTextItems.Remove(Item);
                FQuerySaveSettings := True;
              end
              else
              begin
                Item.Text := FInPlaceEdit.Text;
                Item.Editing := False;
                FQuerySaveSettings := True;
              end;
            end;
            Item.Editing := False;
            result := True;
          finally
            FreeAndNil(FInPlaceEdit);
          end;
        end
        else
        begin
          Item.Editing := False;
          result := True;
        end;
      end
      else
      begin
        Item.Selected := False;
        Item.Editing := False;
      end;
    end;
  end;
end;

procedure TfrmExportImage.CreateInplaceEditForNewItem(X, Y: Integer);
var
  Extent: TSize;
  EditText: string;
  ARect: TRect;
begin
  if FShouldDraw then
  begin
    DrawImage;
  end;
  if sbText.Down then
  begin
    if SelectedItem <> nil then
    begin
      SelectedItem.Selected := False;
      SelectedItem.Editing := False;
    end;
    SelectedItem := nil;
    Extent := Canvas.TextExtent(' ');
    FInPlaceEdit := TRbwInplaceEdit.Create(self);
    try
      FPriorX := X - scrollBoxPreview.HorzScrollBar.Position;
      FPriorY := Y - scrollBoxPreview.VertScrollBar.Position;
      EditText := ' ';
      ARect.Left := FPriorX + scrollBoxPreview.Left - 3;
      ARect.Top := FPriorY;
      ARect.Right := ARect.Left + Extent.cx + 16;
      ARect.Bottom := ARect.Top + Extent.cy + 8;

      FInPlaceEdit.Parent := self;
      FInPlaceEdit.Font := FDefaultFont;
      FInPlaceEdit.SetBounds(ARect.Left, ARect.Top,
        ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
      FInPlaceEdit.OnChange := ResizeInplaceEdit;
      FInPlaceEdit.Text := EditText;
      FInPlaceEdit.SelectAll;
      FInPlaceEdit.SetFocus;
      FInPlaceEdit.MouseCapture := True;
      FInPlaceEdit.Run;
      if (FInPlaceEdit <> nil) and (FInPlaceEdit.ModalResult = mrOK) then
      begin
        AddItem;
      end;
    finally
      FreeAndNil(FInPlaceEdit);
    end;
  end;
end;

procedure TfrmExportImage.DrawColorLegend(ACanvas: TCanvas;
  var LegendY: Integer; Out ColorRect: TRect);
var
  ViewDirection: TViewDirection;
  PhastModel: TPhastModel;
  Grid: TCustomGrid;
  ShowLegend: Boolean;
begin
  ColorRect.Left := 0;
  ColorRect.Top := 0;
  ColorRect.BottomRight := ColorRect.TopLeft;

  if cbColorLegend.Checked then
  begin
    ViewDirection := TViewDirection(comboView.ItemIndex);
    PhastModel := frmGoPhast.PhastModel;
    Grid := PhastModel.Grid;
    ShowLegend := False;
    case ViewDirection of
      vdTop:
        begin
          ShowLegend := (Grid.TopDataSet <> nil)
            or (PhastModel.EdgeDisplay <> nil);
        end;
      vdFront:
        begin
          ShowLegend := (Grid.FrontDataSet <> nil);
        end;
      vdSide:
        begin
          ShowLegend := (Grid.SideDataSet <> nil);
        end;
    else
      Assert(False);
    end;
    if ShowLegend then
    begin
      PhastModel.ColorLegend.Draw(ACanvas, 10, LegendY, ColorRect);
    end;
  end;
end;

procedure TfrmExportImage.DrawModel(DrawingRect: TRect; ACanvas: TCanvas);
var
  TempBMP: TBitmap;
  AScreenObject: TScreenObject;
  ScreenObjectIndex: Integer;
  ViewDirection: TViewDirection;
  Orientation: TDataSetOrientation;
begin
  if FModelImage = nil then
  begin
    UpdateModelColors;
    FModelImage := TBitmap32.Create;
    ViewDirection := TViewDirection(comboView.ItemIndex);
    if ViewDirection = vdSide then
    begin
      FModelImage.Width := DrawingRect.Bottom - DrawingRect.Top;
      FModelImage.Height := DrawingRect.Right - DrawingRect.Left;
    end
    else
    begin
      FModelImage.Height := DrawingRect.Bottom - DrawingRect.Top;
      FModelImage.Width := DrawingRect.Right - DrawingRect.Left;
    end;
    DrawBigRectangle32(FModelImage, clBlack32, clWhite32, 1, 0, 0,
      FModelImage.Width - 1, FModelImage.Height - 1);

    DrawBackgroundImages(FModelImage);

    frmGoPhast.Grid.DrawColoredGridLines := cbShowColoredGridLines.Checked;
    try
      frmGoPhast.Grid.Draw(FModelImage, ViewDirection);
    finally
      frmGoPhast.Grid.DrawColoredGridLines := True;
    end;

    for ScreenObjectIndex := 0 to
      frmGoPhast.PhastModel.ScreenObjectCount - 1 do
    begin
      AScreenObject := frmGoPhast.PhastModel.ScreenObjects[ScreenObjectIndex];
      AScreenObject.Draw(FModelImage, ViewDirection);
    end;

    Orientation := dsoTop;
    case ViewDirection of
      vdTop: Orientation := dsoTop;
      vdFront: Orientation := dsoFront;
      vdSide: Orientation := dsoSide;
      else Assert(False);
    end;
    frmGoPhast.PhastModel.Pathline.Draw(Orientation, FModelImage);
    frmGoPhast.PhastModel.EndPoints.Draw(Orientation, FModelImage);
    frmGoPhast.PhastModel.TimeSeries.Draw(Orientation, FModelImage);

    if ViewDirection = vdSide then
    begin
      FModelImage.Rotate90;
    end;
  end;

  TempBMP := TBitMap.Create;
  try
    TempBMP.Assign(FModelImage);
    ACanvas.Draw(DrawingRect.Left, DrawingRect.Top, TempBMP);
  finally
    TempBMP.Free;
  end;
end;

procedure TfrmExportImage.DrawHorizontalScale(var ACanvas: TCanvas;
  var DrawingRect: TRect);
const
  LeftHorizontalRulerOffset = 20;
var
  RulerRect: TRect;
  HRuler: TRulerPainter;
  ViewDirection: TViewDirection;
  Ruler: TRbwRuler;
  RightHorizontalRulerOffset: integer;
begin
  if cbHorizontalScale.Checked then
  begin
    RightHorizontalRulerOffset := 20;
    if cbVerticalScale.Checked then
    begin
      Inc(RightHorizontalRulerOffset, 60);
    end;
    ACanvas.Font := Font;
    ACanvas.Pen.Color := clBlack;
    ACanvas.Pen.Style := psSolid;
    HRuler := TRulerPainter.Create(nil);
    try
      HRuler.RulerPosition := rpBottom;
      HRuler.RulerStart := sTopLeft;
      ViewDirection := TViewDirection(comboView.ItemIndex);
      Ruler := nil;
      case ViewDirection of
        vdTop:
          Ruler := frmGoPhast.frameTopView.rulHorizontal;
        vdFront:
          Ruler := frmGoPhast.frameFrontView.rulHorizontal;
        vdSide:
          Ruler := frmGoPhast.frameSideView.rulVertical;
      else
        Assert(False);
      end;
      HRuler.RulerDesiredSpacing := Ruler.RulerDesiredSpacing;
      HRuler.RulerDigits := Ruler.RulerDigits;
      HRuler.RulerLinePosition := Ruler.RulerLinePosition;
      HRuler.RulerMajorTickLength := Ruler.RulerMajorTickLength;
      HRuler.RulerMinorTickLength := Ruler.RulerMinorTickLength;
      HRuler.RulerPrecision := Ruler.RulerPrecision;
      HRuler.RulerTextOffset := Ruler.RulerTextOffset;
      HRuler.RulerTextPosition := Ruler.RulerTextPosition;
      HRuler.RulerEnds.Lower := LeftHorizontalRulerOffset;
      HRuler.RulerEnds.Upper := DrawingRect.Right -DrawingRect.Left
        - RightHorizontalRulerOffset;
      case ViewDirection of
        vdTop:
          begin
            HRuler.RulerValues.Lower := frmGoPhast.frameTopView.ZoomBox.X(
              LeftHorizontalRulerOffset);
            HRuler.RulerValues.Upper := frmGoPhast.frameTopView.ZoomBox.X(
              HRuler.RulerEnds.Upper);
          end;
        vdFront:
          begin
            HRuler.RulerValues.Lower := frmGoPhast.frameFrontView.ZoomBox.X(
              LeftHorizontalRulerOffset);
            HRuler.RulerValues.Upper := frmGoPhast.frameFrontView.ZoomBox.X(
              HRuler.RulerEnds.Upper);
          end;
        vdSide:
          begin
            HRuler.RulerValues.Lower := frmGoPhast.frameSideView.ZoomBox.Y(
              DrawingRect.Right - DrawingRect.Left - LeftHorizontalRulerOffset);
            HRuler.RulerValues.Upper := frmGoPhast.frameSideView.ZoomBox.Y(
              RightHorizontalRulerOffset);
          end;
      else
        Assert(False);
      end;
      HRuler.DrawRuler(ACanvas, DrawingRect, RulerRect);
      DrawingRect.Bottom := RulerRect.Top - 20;
    finally
      HRuler.Free;
    end;
  end;
end;

procedure TfrmExportImage.DrawVerticalScale(var ACanvas: TCanvas;
  var DrawingRect: TRect);
const
  UpperVerticalRulerOffset = 20;
  LowerVerticalRulerOffset = 20;
var
  Ruler: TRbwRuler;
  ViewDirection: TViewDirection;
  VRuler: TRulerPainter;
  RulerRect: TRect;
begin
  if cbVerticalScale.Checked then
  begin
    ACanvas.Font := Font;
    ACanvas.Pen.Color := clBlack;
    ACanvas.Pen.Style := psSolid;
    VRuler := TRulerPainter.Create(nil);
    try
      VRuler.RulerPosition := rpRight;
      VRuler.RulerStart := sBottomRight;
      ViewDirection := TViewDirection(comboView.ItemIndex);
      Ruler := nil;
      case ViewDirection of
        vdTop:
          Ruler := frmGoPhast.frameTopView.rulVertical;
        vdFront:
          Ruler := frmGoPhast.frameFrontView.rulVertical;
        vdSide:
          Ruler := frmGoPhast.frameSideView.rulHorizontal;
      else
        Assert(False);
      end;
      VRuler.RulerDesiredSpacing := Ruler.RulerDesiredSpacing;
      VRuler.RulerDigits := Ruler.RulerDigits;
      VRuler.RulerLinePosition := Ruler.RulerLinePosition;
      VRuler.RulerMajorTickLength := Ruler.RulerMajorTickLength;
      VRuler.RulerMinorTickLength := Ruler.RulerMinorTickLength;
      VRuler.RulerPrecision := Ruler.RulerPrecision;
      VRuler.RulerTextOffset := Ruler.RulerTextOffset;
      VRuler.RulerTextPosition := Ruler.RulerTextPosition;
      VRuler.RulerEnds.Upper := DrawingRect.Bottom - DrawingRect.Top
        - LowerVerticalRulerOffset;
      VRuler.RulerEnds.Lower := UpperVerticalRulerOffset;
      case ViewDirection of
        vdTop:
          begin
            VRuler.RulerValues.Lower := frmGoPhast.frameTopView.ZoomBox.Y(
              DrawingRect.Bottom - DrawingRect.Top - LowerVerticalRulerOffset);
            VRuler.RulerValues.Upper := frmGoPhast.frameTopView.ZoomBox.Y(
              UpperVerticalRulerOffset);
          end;
        vdFront:
          begin
            VRuler.RulerValues.Lower := frmGoPhast.frameFrontView.ZoomBox.Y(
              DrawingRect.Bottom - DrawingRect.Top - LowerVerticalRulerOffset);
            VRuler.RulerValues.Upper := frmGoPhast.frameFrontView.ZoomBox.Y(
              UpperVerticalRulerOffset);
          end;
        vdSide:
          begin
            VRuler.RulerValues.Lower := frmGoPhast.frameSideView.ZoomBox.X(
              DrawingRect.Bottom - DrawingRect.Top - LowerVerticalRulerOffset);
            VRuler.RulerValues.Upper := frmGoPhast.frameSideView.ZoomBox.X(
              UpperVerticalRulerOffset);
          end;
      else
        Assert(False);
      end;
      VRuler.DrawRuler(ACanvas, DrawingRect, RulerRect);
      DrawingRect.Right := RulerRect.Left - 20;
    finally
      VRuler.Free;
    end;
  end;
end;

procedure TfrmExportImage.DrawBackgroundImages(BitMap32: TBitmap32);
var
  ViewDirection: TViewDirection;
  BitmapIndex: Integer;
  Item: TCompressedBitmapItem;
begin
  ViewDirection := TViewDirection(comboView.ItemIndex);
  for BitmapIndex := 0 to frmGoPhast.PhastModel.Bitmaps.Count - 1 do
  begin
    Item := frmGoPhast.PhastModel.Bitmaps.Items[BitmapIndex]
      as TCompressedBitmapItem;
    if Item.Visible and Item.CanShow
      and (Item.ViewDirection = ViewDirection) then
    begin
      try
        Item.DrawCompressedImage(BitMap32);
      except
        on EOutOfResources do
        begin
          Item.CanShow := False;
          if Item.DisplayMessage then
          begin
            MessageDlg('The ' + Item.Name
              + ' image can not be shown at this magnification. '
              + 'When the magnification is reduced, '
              + 'it will be displayed again.', mtInformation, [mbOK], 0);
            Item.DisplayMessage := False;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmExportImage.DrawOnCanvas(CanvasWidth, CanvasHeight: Integer;
  ACanvas: TCanvas);
var
  DrawingRect: TRect;
begin
  DrawBackground(ACanvas, CanvasHeight, CanvasWidth);

  DrawOutsideItems(CanvasHeight, CanvasWidth, DrawingRect, ACanvas);

  DrawModel(DrawingRect, ACanvas);

  DrawTextItems(ACanvas);
end;

procedure TfrmExportImage.DrawBackground(ACanvas: TCanvas;
  CanvasHeight, CanvasWidth: Integer);
begin
  ACanvas.Brush.Color := clWhite;
  ACanvas.Pen.Style := psClear;
  ACanvas.Rectangle(0, 0, CanvasWidth, CanvasHeight);
end;

procedure TfrmExportImage.DrawOutsideItems(CanvasHeight, CanvasWidth: Integer;
  var DrawingRect: TRect; ACanvas: TCanvas);
var
  TitleRect: TRect;
  LegendY: Integer;
  ColorRect: TRect;
  ContourRect: TRect;
begin
  ACanvas.Font := Font;
  LegendY := 60;
  DrawColorLegend(ACanvas, LegendY, ColorRect);
  LegendY := ColorRect.Bottom + 40;
  DrawContourLegend(ACanvas, LegendY, ContourRect);

  DrawingRect.Left := Max(ColorRect.Right, ContourRect.Right);
  DrawingRect.Top := 0;
    DrawingRect.Right := CanvasWidth;
  DrawingRect.Bottom := CanvasHeight;

  DrawTitle(DrawingRect, ACanvas, TitleRect);
  DrawingRect.Top := TitleRect.Bottom;

  DrawHorizontalScale(ACanvas, DrawingRect);
  DrawVerticalScale(ACanvas, DrawingRect);
end;

procedure TfrmExportImage.DrawImage;
var
  BitMap: TBitmap;
  CanvasWidth: Integer;
  CanvasHeight: Integer;
  DrawingRect: TRect;
begin
  if not FCanDraw then
  begin
    Exit;
  end;
  BitMap := TBitMap.Create;
  try
    BitMap.Width := seImageWidth.AsInteger;
    BitMap.Height := seImageHeight.AsInteger;
    CanvasWidth := BitMap.Width;
    CanvasHeight := BitMap.Height;
    DrawOutsideItems(CanvasHeight, CanvasWidth, DrawingRect, BitMap.Canvas);
  finally
    BitMap.Free;
  end;
  BitMap := TBitMap.Create;
  try
    BitMap.Width := CanvasWidth + (CanvasWidth - DrawingRect.Right)
      + DrawingRect.Left;
    BitMap.Height := CanvasHeight + (CanvasHeight - DrawingRect.Bottom)
      + DrawingRect.Top;
    CanvasWidth := BitMap.Width;
    CanvasHeight := BitMap.Height;
    DrawOnCanvas(CanvasWidth, CanvasHeight, BitMap.Canvas);
    imagePreview.Height := CanvasHeight;
    imagePreview.Width := CanvasWidth;
    imagePreview.Picture.Assign(BitMap);
  finally
    BitMap.Free;
    Screen.Cursor := crDefault;
  end;
  FShouldDraw := False;
end;

procedure TfrmExportImage.SaveContourSettings(
  ContourDisplaySettings: TContourDisplaySettings);
var
  DataArray: TDataArray;
  Grid: TCustomGrid;
begin
  Grid := frmGoPhast.PhastModel.Grid;
  DataArray := nil;
  case TViewDirection(comboView.ItemIndex) of
    vdTop:
      begin
        DataArray := Grid.TopContourDataSet;
      end;
    vdFront:
      begin
        DataArray := Grid.FrontContourDataSet;
      end;
    vdSide:
      begin
        DataArray := Grid.SideContourDataSet;
      end;
  else
    Assert(False);
  end;
  if DataArray = nil then
  begin
    ContourDisplaySettings.DataSetName := '';
    ContourDisplaySettings.LegendVisible := False;
  end
  else
  begin
    ContourDisplaySettings.DataSetName := DataArray.Name;
    ContourDisplaySettings.LegendVisible := cbContourLegend.Checked;
    ContourDisplaySettings.Legend := frmGoPhast.PhastModel.ContourLegend;
    ContourDisplaySettings.Limits := DataArray.Limits;
  end;
end;

procedure TfrmExportImage.SaveColorDisplaySettings(
  ColorDisplaySettings: TColorDisplaySettings);
var
  ATime: Double;
  TimeList: TCustomTimeList;
  DataArray: TDataArray;
  Grid: TCustomGrid;
  PhastModel: TPhastModel;
begin
  PhastModel := frmGoPhast.PhastModel;
  Grid := frmGoPhast.PhastModel.Grid;
  TimeList := nil;
  DataArray := nil;
  ATime := 0;
  case TViewDirection(comboView.ItemIndex) of
    vdTop:
      begin
        DataArray := Grid.TopDataSet;
        TimeList := PhastModel.TopTimeList;
        ATime := PhastModel.TopDisplayTime;
      end;
    vdFront:
      begin
        DataArray := Grid.FrontDataSet;
        TimeList := PhastModel.FrontTimeList;
        ATime := PhastModel.FrontDisplayTime;
      end;
    vdSide:
      begin
        DataArray := Grid.SideDataSet;
        TimeList := PhastModel.SideTimeList;
        ATime := PhastModel.SideDisplayTime;
      end;
  else
    Assert(False);
  end;
  if DataArray = nil then
  begin
    ColorDisplaySettings.DataSetName := '';
    ColorDisplaySettings.LegendVisible := False;
  end
  else
  begin
    ColorDisplaySettings.DataSetName := DataArray.Name;
    ColorDisplaySettings.LegendVisible := cbColorLegend.Checked;
    ColorDisplaySettings.Legend := PhastModel.ColorLegend;
    ColorDisplaySettings.Limits := DataArray.Limits;
  end;
  if TimeList = nil then
  begin
    ColorDisplaySettings.TimeListName := '';
    ColorDisplaySettings.Time := 0;
  end
  else
  begin
    ColorDisplaySettings.TimeListName := TimeList.Name;
    ColorDisplaySettings.Time := ATime;
    ColorDisplaySettings.Limits := TimeList.Limits;
  end;
end;

procedure TfrmExportImage.ApplySettings;
var
  PhastModel: TPhastModel;
  DisplaySettings: TDisplaySettingsCollection;
  ASetting: TDisplaySettingsItem;
  Frame: TframeView;
  Index: Integer;
  DrawItem: TDrawItem;
  TextItem: TTextItem;
  AScreenObject: TScreenObject;
  NewVisibility: Boolean;
  VisibilityChanged: Boolean;
  UndoShowHideObjects: TUndoShowHideScreenObject;
begin
  PhastModel := frmGoPhast.PhastModel;
  DisplaySettings := PhastModel.DisplaySettings;
  ASetting := DisplaySettings.GetItemByName(comboSavedSettings.Text);
  if ASetting = nil then
  begin
    Exit;
  end;
  comboView.ItemIndex := Ord(ASetting.ViewToDisplay);
  PhastModel.Exaggeration := ASetting.VerticalExaggeration;
  frmGoPhast.frameTopView.ZoomBox.Magnification := ASetting.Magnification;
  frmGoPhast.frameFrontView.ZoomBox.Magnification := ASetting.Magnification;
  frmGoPhast.frameSideView.ZoomBox.Magnification := ASetting.Magnification;
  case ASetting.ViewToDisplay of
    vdTop:
      begin
        SetTopCornerPosition(ASetting.ReferencePointX, ASetting.ReferencePointY)
      end;
    vdFront:
      begin
        SetFrontCornerPosition(ASetting.ReferencePointX, ASetting.ReferencePointY)
      end;
    vdSide:
      begin
        SetSideCornerPosition(ASetting.ReferencePointY, ASetting.ReferencePointX)
      end;
    else Assert(false);
  end;
  Frame := nil;
  case ASetting.ViewToDisplay of
  vdTop:
    begin
      Frame := frmGoPhast.frameTopView;
    end;
  vdFront:
    begin
      Frame := frmGoPhast.frameFrontView;
    end;
  vdSide:
    begin
      Frame := frmGoPhast.frameSideView;
    end;
  else
    Assert(False);
  end;
  if ASetting.ViewToDisplay = vdSide then
  begin
    Frame.rulVertical.Assign(ASetting.HorizontalRuler);
    Frame.rulHorizontal.Assign(ASetting.VerticalRuler);
  end
  else
  begin
    Frame.rulVertical.Assign(ASetting.VerticalRuler);
    Frame.rulHorizontal.Assign(ASetting.HorizontalRuler);
  end;
  cbHorizontalScale.Checked := ASetting.HorizontalRuler.Visible;
  cbVerticalScale.Checked := ASetting.VerticalRuler.Visible;
  seImageHeight.AsInteger := ASetting.ImageHeight;
  seImageWidth.AsInteger := ASetting.ImageWidth;
  cbShowColoredGridLines.Checked := ASetting.ShowColoredGridLines;
  case ASetting.GridDisplayChoice of
    gldcAll:
      begin
        frmGoPhast.acShowAllGridLines.Checked := True;
      end;
    gldcExterior:
      begin
        frmGoPhast.acShowExteriorGridLines.Checked := True;
      end;
    gldcActive:
      begin
        frmGoPhast.acShowActiveGridLines.Checked := True;
      end;
    gldcActiveEdge:
      begin
        frmGoPhast.acShowActiveEdge.Checked := True;
      end;
    else Assert(false);
  end;
  frmGoPhast.SetGridLineDrawingChoice(nil);

  UndoShowHideObjects := TUndoShowHideScreenObject.Create;
  try
    VisibilityChanged := False;
    for Index := 0 to PhastModel.ScreenObjectCount - 1 do
    begin
      AScreenObject := PhastModel.ScreenObjects[Index];
      NewVisibility := (not AScreenObject.Deleted) and
      (ASetting.VisibleObjects.IndexOf(AScreenObject.Name) >= 0);
      if AScreenObject.Visible <> NewVisibility then
      begin
        VisibilityChanged := True;
      end;
      AScreenObject.Visible := NewVisibility;
    end;
    UndoShowHideObjects.SetPostSelection;
    if VisibilityChanged then
    begin
      frmGoPhast.UndoStack.Submit(UndoShowHideObjects);
    end
    else
    begin
      UndoShowHideObjects.Free;
    end;
  except
    UndoShowHideObjects.Free;
    raise;
  end;

  PhastModel.EndPoints.Assign(ASetting.ModpathEndPointSettings);
  PhastModel.PathLine.Assign(ASetting.ModpathPathLineSettings);
  PhastModel.TimeSeries.Assign(ASetting.ModpathTimeSeriesSettings);

  ApplyContourDisplaySettings(ASetting.ContourDisplaySettings);
  ApplyColorDisplaySettings(ASetting.ColorDisplaySettings);

  if ASetting.EdgeDisplaySettings.Visible then
  begin
    PhastModel.EdgeDisplay := PhastModel.HfbDisplayer;
    PhastModel.EdgeDisplay.Assign(ASetting.EdgeDisplaySettings);
  end
  else
  begin
    PhastModel.EdgeDisplay := nil;
  end;

  FTextItems.Clear;
  for Index := 0 to ASetting.AdditionalText.Count - 1 do
  begin
    DrawItem := TDrawItem.Create;
    TextItem := ASetting.AdditionalText.Items[Index] as TTextItem;
    DrawItem.Assign(TextItem);
    FTextItems.Add(DrawItem);
  end;

  memoTitle.Lines.Text := ASetting.Title.Text;
  memoTitle.Font := ASetting.Title.Font;
  UpdateModelColors;
  FQuerySaveSettings := False;

end;


procedure TfrmExportImage.btnRefreshClick(Sender: TObject);
begin
  inherited;
  FreeAndNil(FModelImage);
  DrawImage;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.SaveSettings;
var
  TextItem: TTextItem;
  PhastModel: TPhastModel;
  ModifiedDisplaySettings: TDisplaySettingsCollection;
  ASetting: TDisplaySettingsItem;
  Frame: TframeView;
  Index: Integer;
  DrawItem: TDrawItem;
  Undo: TUndoEditDisplaySettings;
  AScreenObject: TScreenObject;
begin
  PhastModel := frmGoPhast.PhastModel;
  ModifiedDisplaySettings := TDisplaySettingsCollection.Create(nil);
  try
    ModifiedDisplaySettings.Assign(PhastModel.DisplaySettings);
    ASetting := ModifiedDisplaySettings.GetItemByName(comboSavedSettings.Text);
    if ASetting = nil then
    begin
      ASetting := ModifiedDisplaySettings.Add as TDisplaySettingsItem;
      ASetting.Name := comboSavedSettings.Text;
      comboSavedSettings.Items.Add(ASetting.Name)
    end;
    ASetting.ViewToDisplay := TViewDirection(comboView.ItemIndex);
    Frame := nil;
    case ASetting.ViewToDisplay of
      vdTop:
        begin
          Frame := frmGoPhast.frameTopView;
        end;
      vdFront:
        begin
          Frame := frmGoPhast.frameFrontView;
        end;
      vdSide:
        begin
          Frame := frmGoPhast.frameSideView;
        end;
    else
      Assert(False);
    end;
    ASetting.Magnification := Frame.ZoomBox.Magnification;
    ASetting.ReferencePointX := Frame.ZoomBox.X(0);
    ASetting.ReferencePointY := Frame.ZoomBox.Y(0);
    ASetting.VerticalExaggeration := PhastModel.Exaggeration;
    if ASetting.ViewToDisplay = vdSide then
    begin
      ASetting.HorizontalRuler.Assign(Frame.rulVertical);
      ASetting.VerticalRuler.Assign(Frame.rulHorizontal);
    end
    else
    begin
      ASetting.HorizontalRuler.Assign(Frame.rulHorizontal);
      ASetting.VerticalRuler.Assign(Frame.rulVertical);
    end;
    ASetting.HorizontalRuler.Visible := cbHorizontalScale.Checked;
    ASetting.VerticalRuler.Visible := cbVerticalScale.Checked;

    ASetting.ImageHeight := seImageHeight.AsInteger;
    ASetting.ImageWidth := seImageWidth.AsInteger;

    ASetting.ShowColoredGridLines := cbShowColoredGridLines.Checked;
    ASetting.GridDisplayChoice := PhastModel.Grid.GridLineDrawingChoice;
    ASetting.ModpathEndPointSettings := PhastModel.EndPoints;
    ASetting.ModpathPathLineSettings := PhastModel.PathLine;
    ASetting.ModpathTimeSeriesSettings := PhastModel.TimeSeries;
    SaveContourSettings(ASetting.ContourDisplaySettings);
    SaveColorDisplaySettings(ASetting.ColorDisplaySettings);
    ASetting.EdgeDisplaySettings.Assign(PhastModel.EdgeDisplay);
    while ASetting.AdditionalText.Count > FTextItems.Count do
    begin
      ASetting.AdditionalText.Delete(ASetting.AdditionalText.Count - 1);
    end;
    while ASetting.AdditionalText.Count < FTextItems.Count do
    begin
      ASetting.AdditionalText.Add;
    end;
    for Index := 0 to FTextItems.Count - 1 do
    begin
      DrawItem := FTextItems[Index];
      TextItem := ASetting.AdditionalText.Items[Index] as TTextItem;
      TextItem.Assign(DrawItem);
    end;
    ASetting.Title.Text := memoTitle.Lines.Text;
    ASetting.Title.Font := memoTitle.Font;
    ASetting.VisibleObjects.Clear;
    ASetting.VisibleObjects.Capacity := PhastModel.ScreenObjectCount;
    for Index := 0 to PhastModel.ScreenObjectCount - 1 do
    begin
      AScreenObject := PhastModel.ScreenObjects[Index];
      if AScreenObject.Visible and (not AScreenObject.Deleted) then
      begin
        ASetting.VisibleObjects.Add(AScreenObject.Name);
      end;
    end;
    ASetting.VisibleObjects.Sorted := True;

    Undo := TUndoEditDisplaySettings.Create(ModifiedDisplaySettings);
    frmGoPhast.UndoStack.Submit(Undo);
    FQuerySaveSettings := False;

  finally
    ModifiedDisplaySettings.Free;
    btnManageSettings.Enabled := frmGoPhast.PhastModel.DisplaySettings.Count > 0;
  end;
end;

procedure TfrmExportImage.ApplyContourDisplaySettings(
  ContourDisplaySettings: TContourDisplaySettings);
var
  DataArray: TDataArray;
  PhastModel: TPhastModel;
begin
  PhastModel := frmGoPhast.PhastModel;
  if ContourDisplaySettings.DataSetName = '' then
  begin
    DataArray := nil;
  end
  else
  begin
    DataArray := PhastModel.GetDataSetByName(
      ContourDisplaySettings.DataSetName);
  end;
  if DataArray = nil then
  begin
    PhastModel.Grid.TopContourDataSet := nil;
    PhastModel.Grid.FrontContourDataSet := nil;
    PhastModel.Grid.SideContourDataSet := nil;
    PhastModel.Grid.ThreeDContourDataSet := nil;
  end
  else
  begin
    DataArray.Initialize;
    case DataArray.Orientation of
      dsoTop:
        begin
          PhastModel.Grid.TopContourDataSet := DataArray;
          PhastModel.Grid.FrontContourDataSet := nil;
          PhastModel.Grid.SideContourDataSet := nil;
        end;
      dsoFront:
        begin
          PhastModel.Grid.TopContourDataSet := nil;
          PhastModel.Grid.FrontContourDataSet := DataArray;
          PhastModel.Grid.SideContourDataSet := nil;
        end;
      dsoSide:
        begin
          PhastModel.Grid.TopContourDataSet := nil;
          PhastModel.Grid.FrontContourDataSet := nil;
          PhastModel.Grid.SideContourDataSet := DataArray;
        end;
      dso3D:
        begin
          PhastModel.Grid.TopContourDataSet := DataArray;
          PhastModel.Grid.FrontContourDataSet := DataArray;
          PhastModel.Grid.SideContourDataSet := DataArray;
        end;
    else
      Assert(false);
    end;
    PhastModel.Grid.ThreeDContourDataSet := DataArray;
    PhastModel.ContourLegend.Assign(ContourDisplaySettings.Legend);
    PhastModel.ContourLegend.ValueSource := DataArray;
    PhastModel.ContourLegend.AssignFractions;
    DataArray.UpdateMinMaxValues;
  end;
  cbContourLegend.Checked := ContourDisplaySettings.LegendVisible;
  UpdateFrmContourData;
end;

procedure TfrmExportImage.ApplyColorDisplaySettings(
  ColorDisplaySettings: TColorDisplaySettings);
var
  TimeList: TCustomTimeList;
  TimeListIndex: Integer;
  ADataArray: TDataArray;
  DataArray: TDataArray;
  PhastModel: TPhastModel;
begin
  PhastModel := frmGoPhast.PhastModel;
  if ColorDisplaySettings.TimeListName = '' then
  begin
    TimeList := nil;
  end
  else
  begin
    PhastModel.EdgeDisplay := nil;
    TimeList := PhastModel.GetTimeListByName(ColorDisplaySettings.TimeListName);
  end;
  if TimeList <> nil then
  begin
    TimeList.Limits := ColorDisplaySettings.Limits;
    PhastModel.ColorLegend.Assign(ColorDisplaySettings.Legend);
    if TimeList.UpToDate then
    begin
      for TimeListIndex := 0 to TimeList.Count - 1 do
      begin
        ADataArray := TimeList[TimeListIndex];
        ADataArray.Limits := ColorDisplaySettings.Limits;
      end;
    end
    else
    begin
      TimeList.Initialize;
    end;
    PhastModel.UpdateThreeDTimeDataSet(TimeList, ColorDisplaySettings.Time);
    ADataArray := PhastModel.Grid.ThreeDDataSet;
    case TimeList.Orientation of
      dsoTop:
        begin
          PhastModel.UpdateTopTimeDataSet(TimeList, Time);
          PhastModel.Grid.FrontDataSet := nil;
          PhastModel.FrontTimeList := nil;
          PhastModel.Grid.SideDataSet := nil;
          PhastModel.SideTimeList := nil;
        end;
      dsoFront:
        begin
          PhastModel.Grid.TopDataSet := nil;
          PhastModel.TopTimeList := nil;
          PhastModel.UpdateFrontTimeDataSet(TimeList, Time);
          PhastModel.Grid.SideDataSet := nil;
          PhastModel.SideTimeList := nil;
        end;
      dsoSide:
        begin
          PhastModel.Grid.TopDataSet := nil;
          PhastModel.TopTimeList := nil;
          PhastModel.Grid.FrontDataSet := nil;
          PhastModel.FrontTimeList := nil;
          PhastModel.UpdateSideTimeDataSet(TimeList, Time);
        end;
      dso3D:
        begin
          PhastModel.UpdateTopTimeDataSet(TimeList, Time);
          PhastModel.UpdateFrontTimeDataSet(TimeList, Time);
          PhastModel.UpdateSideTimeDataSet(TimeList, Time);
        end;
    end;
    PhastModel.ColorLegend.ValueSource := ADataArray;
    PhastModel.ColorLegend.AssignFractions;
  end
  else
  begin
    PhastModel.TopTimeList := nil;
    PhastModel.FrontTimeList := nil;
    PhastModel.SideTimeList := nil;
    PhastModel.ThreeDTimeList := nil;
    if ColorDisplaySettings.DataSetName = '' then
    begin
      DataArray := nil;
    end
    else
    begin
      PhastModel.EdgeDisplay := nil;
      DataArray := PhastModel.GetDataSetByName(
        ColorDisplaySettings.DataSetName);
    end;
    if DataArray = nil then
    begin
      PhastModel.Grid.ThreeDDataSet := nil;
      PhastModel.Grid.TopDataSet := nil;
      PhastModel.Grid.FrontDataSet := nil;
      PhastModel.Grid.SideDataSet := nil;
    end
    else
    begin
      DataArray.Initialize;
      PhastModel.ColorLegend.Assign(ColorDisplaySettings.Legend);
      DataArray.Limits := ColorDisplaySettings.Limits;
      PhastModel.Grid.ThreeDDataSet := DataArray;
      PhastModel.ThreeDTimeList := nil;
      case DataArray.Orientation of
        dsoTop:
          begin
            PhastModel.Grid.TopDataSet := DataArray;
            PhastModel.Grid.FrontDataSet := nil;
            PhastModel.Grid.SideDataSet := nil;
          end;
        dsoFront:
          begin
            PhastModel.Grid.TopDataSet := nil;
            PhastModel.Grid.FrontDataSet := DataArray;
            PhastModel.Grid.SideDataSet := nil;
          end;
        dsoSide:
          begin
            PhastModel.Grid.TopDataSet := nil;
            PhastModel.Grid.FrontDataSet := nil;
            PhastModel.Grid.SideDataSet := DataArray;
          end;
        dso3D:
          begin
            PhastModel.Grid.TopDataSet := DataArray;
            PhastModel.Grid.FrontDataSet := DataArray;
            PhastModel.Grid.SideDataSet := DataArray;
          end;
      else
        Assert(False);
      end;
      PhastModel.ColorLegend.ValueSource := DataArray;
      PhastModel.ColorLegend.AssignFractions;
      DataArray.UpdateMinMaxValues;
    end;
  end;
  cbColorLegend.Checked := ColorDisplaySettings.LegendVisible;
  UpdateFrmGridColor;
end;

procedure TfrmExportImage.UpdateModelColors;
var
  PhastModel: TPhastModel;
  Is3DSelected: boolean;
begin
  PhastModel := frmGoPhast.PhastModel;
  Is3DSelected := (PhastModel.Grid.ThreeDDataSet <> nil);
  if frmGoPhast.Grid.NeedToRecalculateTopCellColors then
  begin
    frmGoPhast.Grid.ResetTopCellColors;
    frmGoPhast.Grid.UpdateCellColors(vdTop);
  end;
  if frmGoPhast.Grid.NeedToRecalculateFrontCellColors then
  begin
    frmGoPhast.Grid.ResetFrontCellColors;
    frmGoPhast.Grid.UpdateCellColors(vdFront);
  end;
  if frmGoPhast.Grid.NeedToRecalculateSideCellColors then
  begin
    frmGoPhast.Grid.ResetSideCellColors;
    frmGoPhast.Grid.UpdateCellColors(vdSide);
  end;
  frmGoPhast.acColoredGrid.Enabled :=
    (frmGoPhast.Grid.ThreeDDataSet <> nil)
    or (frmGoPhast.PhastModel.EdgeDisplay <> nil);
  if not frmGoPhast.acColoredGrid.Enabled then
  begin
    frmGoPhast.acColoredGrid.Checked := False;
    frmGoPhast.tb3DColors.Down := False;
  end;
  if frmGoPhast.acColoredGrid.Enabled and not Is3DSelected then
  begin
    frmGoPhast.acColoredGrid.Checked := True;
    frmGoPhast.tb3DColors.Down := True;
  end;
  frmGoPhast.PhastModel.Grid.GridChanged;
end;

procedure TfrmExportImage.DrawContourLegend(ACanvas: TCanvas;
  var LegendY: Integer; out ContourRect: TRect);
var
  ViewDirection: TViewDirection;
  PhastModel: TPhastModel;
  Grid: TCustomGrid;
  ShowLegend: Boolean;

begin
  ContourRect.Left := 0;
  ContourRect.Top := 0;
  ContourRect.BottomRight := ContourRect.TopLeft;
  
  if cbContourLegend.Checked then
  begin
    ViewDirection := TViewDirection(comboView.ItemIndex);
    PhastModel := frmGoPhast.PhastModel;
    Grid := PhastModel.Grid;
    ShowLegend := False;
    case ViewDirection of
      vdTop:
        begin
          ShowLegend := (Grid.TopContourDataSet <> nil);
        end;
      vdFront:
        begin
          ShowLegend := (Grid.FrontContourDataSet <> nil);
        end;
      vdSide:
        begin
          ShowLegend := (Grid.SideContourDataSet <> nil);
        end;
    else
      Assert(False);
    end;
    if ShowLegend then
    begin
      PhastModel.ContourLegend.Draw(ACanvas, 10, LegendY, ContourRect);
      LegendY := ContourRect.Bottom + 40;
    end;
  end;
end;

procedure TfrmExportImage.DefaultFontChanged(Sender: TObject);
begin
  if not FSelectingItem and Assigned(FDefaultFont)
    and Assigned(SelectedItem) then
  begin
    SelectedItem.Font := FDefaultFont;
    FQuerySaveSettings := True;
    DrawImage;
  end;

  if Assigned(FInPlaceEdit) then
  begin
    FInPlaceEdit.Font := FDefaultFont;
  end;

  if FChangingFont or not Assigned(FDefaultFont) then
  begin
    Exit;
  end;

  FChangingFont := True;
  try
    if (SelectedItem <> nil) and not FSelectingItem then
    begin
      SelectedItem.Font := FDefaultFont;
      FQuerySaveSettings := True;
      DrawImage;
    end;
  finally
    FChangingFont := False;
  end;
end;

function TfrmExportImage.DragItem(X, Y: Integer): Boolean;
var
  ARect: TRect;
begin
  result := False;
  if sbSelect.Down and Assigned(FSelectedItem)
    and ((Abs(FStartX - X) > 4) or (Abs(FStartY - Y) > 4)) then
  begin
    ARect := FSelectedItem.Rect;
    OffSetRect(ARect, X - FStartX, Y - FStartY);
    FSelectedItem.Rect := ARect;
    result := True;
    FQuerySaveSettings := True;
    FShouldDraw := True;
  end;
end;

procedure TfrmExportImage.DrawImageAfterDelay;
begin
  Screen.Cursor := crHourGlass;
  FChangeTime := Now;
  timerDrawImageDelay.Enabled := True;

end;

procedure TfrmExportImage.DrawTitle(DrawingRect: TRect; ACanvas: TCanvas;
  out TitleRect: TRect);
var
  X: Integer;
  Y: Integer;
  Extent: TSize;
  ALine: string;
  Index: Integer;
  ARect: TRect;
begin
  TitleRect.Left := 0;
  TitleRect.Top := 0;
  TitleRect.BottomRight := TitleRect.TopLeft;

  ACanvas.Font := memoTitle.Font;
  Y := 20;
  for Index := 0 to memoTitle.Lines.Count - 1 do
  begin
    ALine := memoTitle.Lines[Index];
    if ALine = '' then
    begin
      Extent := ACanvas.TextExtent(' ');
    end
    else
    begin
      Extent := ACanvas.TextExtent(ALine);
    end;
    X := (DrawingRect.Right - Extent.cx) div 2;
    ARect.Left := X;
    ARect.Top := Y;
    ARect.Right := X + Extent.cx;
    ARect.Bottom := Y + Extent.cy;
    ACanvas.TextOut(X, Y, ALine);
    Y := Y + Extent.cy;
    UnionRect(TitleRect, TitleRect, ARect);
  end;
  if TitleRect.Bottom > 0 then
  begin
    Inc(TitleRect.Bottom, 20);
  end;
end;

procedure TfrmExportImage.DrawTextItems(ACanvas: TCanvas);
var
  Index: Integer;
  Item: TDrawItem;
begin
  for Index := 0 to FTextItems.Count - 1 do
  begin
    Item := FTextItems[Index];
    Item.Draw(ACanvas);
  end;
end;

function TfrmExportImage.FinishEditingExistingItem: Boolean;
begin
  result := False;
  if Assigned(FInPlaceEdit) then
  begin
    if (FInPlaceEdit.ModalResult = mrOK) then
    begin
      if SelectedItem = nil then
      begin
        AddItem;
      end
      else
      begin
        if FInPlaceEdit.Text = '' then
        begin
          FTextItems.Remove(SelectedItem);
          FQuerySaveSettings := True;
        end
        else
        begin
          SelectedItem.Text := FInPlaceEdit.Text;
          SelectedItem.Editing := False;
          SelectedItem.Selected := False;
          FQuerySaveSettings := True;
        end;
        SelectedItem := nil;
        FShouldDraw := True;
        result := True;
      end;
    end
    else
    begin
      if SelectedItem <> nil then
      begin
        SelectedItem.Editing := False;
        SelectedItem.Selected := False;
      end;
      FShouldDraw := True;
    end;
    FreeAndNil(FInPlaceEdit);
  end;
end;

procedure TfrmExportImage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FQuerySaveSettings then
  begin
    FQuerySaveSettings := False;
    if (MessageDlg('Do you want to save the current image settings.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      btnSaveSettingsClick(nil);
      Action := caNone;
      Exit;
    end;
  end;
  frmExportImage := nil;
  Release;
end;

procedure TfrmExportImage.FormCreate(Sender: TObject);
begin
  inherited;
  FCanDraw := False;
  ocSettings.ActivePage := opView;

  FTextItems:= TObjectList.Create;

  FDefaultFont := TFont.Create;
  FDefaultFont.OnChange :=  DefaultFontChanged;
  FDefaultFont.Assign(Font);

  timerDrawImageDelay.Interval := 1;

  GetData;

  FCanDraw := True;
  comboViewChange(nil);
  FQuerySaveSettings := False;
end;

procedure TfrmExportImage.FormDestroy(Sender: TObject);
begin
  inherited;
  FDefaultFont.Free;
  FTextItems.Free;
  FModelImage.Free;
end;

procedure TfrmExportImage.GetData;
var
  Index: Integer;
  ASetting: TDisplaySettingsItem;
  SettingsList: TStringList;
  CurrentText: string;
  ComboIndex: Integer;
begin
  CurrentText := comboSavedSettings.Text;
  SettingsList := TStringList.Create;
  try
    SettingsList.Capacity := frmGoPhast.PhastModel.DisplaySettings.Count+1;
    for Index := 0 to frmGoPhast.PhastModel.DisplaySettings.Count - 1 do
    begin
      ASetting := frmGoPhast.PhastModel.DisplaySettings.Items[Index]
        as TDisplaySettingsItem;
      SettingsList.Add(ASetting.Name);
    end;
    SettingsList.CaseSensitive := False;
    SettingsList.Sorted := True;
    SettingsList.Sorted := False;
    SettingsList.Insert(0, '(none)');
    comboSavedSettings.Items.Assign(SettingsList);
  finally
    SettingsList.Free;
  end;
  ComboIndex := comboSavedSettings.Items.IndexOf(CurrentText);
  if ComboIndex < 0 then
  begin
    ComboIndex := 0;
  end;
  comboSavedSettings.ItemIndex := ComboIndex;
  btnManageSettings.Enabled := frmGoPhast.PhastModel.DisplaySettings.Count > 0;
end;

procedure TfrmExportImage.imagePreviewDblClick(Sender: TObject);
begin
  inherited;
  FDoubleClicked := True;
end;

procedure TfrmExportImage.imagePreviewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  SelectItemToDrag(X, Y);

  if FShouldDraw then
  begin
    DrawImage;
  end;
end;

procedure TfrmExportImage.imagePreviewMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FShouldDraw := False;
  try
    if DragItem(X, Y) then
    begin
      Exit;
    end;

    if FinishEditingExistingItem then
    begin
      Exit;
    end;

    if CreateInplaceEditForExistingItem(X, Y) then
    begin
      Exit;
    end;

    CreateInplaceEditForNewItem(X, Y);
  finally
    if FShouldDraw then
    begin
      DrawImage;
    end;
  end;
end;

procedure TfrmExportImage.ItemChanged(Sender: TObject);
begin
  FShouldDraw := True;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.memoTitleChange(Sender: TObject);
begin
  inherited;
  DrawImage;
end;

procedure TfrmExportImage.ResizeInplaceEdit(Sender: TObject);
var
  Extent: TSize;
  Lines: TStringList;
  LineIndex: Integer;
  ARect: TRect;
  MaskEdit: TCustomMaskEdit;
begin
  if SelectedItem <> nil then
  begin
    Assert(SelectedItem.Selected);
    Assert(SelectedItem.Editing);
    DrawImage;
  end;
  MaskEdit := Sender as TCustomMaskEdit;
  if Assigned(MaskEdit) then
  begin
    ARect.Left := MaskEdit.Left;
    ARect.Top := MaskEdit.Top;
    Lines := TStringList.Create;
    try
      imagePreview.Canvas.Font := FDefaultFont;
      Lines.Text := MaskEdit.Text;
      if StrRight(MaskEdit.Text, 2) = #13#10 then
      begin
        Lines.Add(' ')
      end;

      for LineIndex := 0 to Lines.Count - 1 do
      begin
        Extent := imagePreview.Canvas.TextExtent(Lines[LineIndex]+' ');
        if LineIndex = 0 then
        begin
          ARect.Right := ARect.Left + Extent.cx;
        end
        else
        begin
          ARect.Right := Max(ARect.Right,
            ARect.Left + Extent.cx);
        end;
        ARect.Bottom := ARect.Top + Extent.cy*(LineIndex+1);
      end;
    finally
      Lines.Free;
    end;

    MaskEdit.SetBounds(
      MaskEdit.Left,
      MaskEdit.Top,
      ARect.Right - ARect.Left + 16,
      ARect.Bottom - ARect.Top + 8);
  end;
end;

procedure TfrmExportImage.seImageHeightChange(Sender: TObject);
begin
  inherited;
  FreeAndNil(FModelImage);
  DrawImageAfterDelay;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.seImageWidthChange(Sender: TObject);
begin
  inherited;
  FreeAndNil(FModelImage);
  DrawImageAfterDelay;
  FQuerySaveSettings := True;
end;

procedure TfrmExportImage.SelectItemToDrag(X, Y: Integer);
var
  Index: Integer;
  Item: TDrawItem;
  CanSelect: Boolean;
begin
  FSelectedItem := nil;
  if sbSelect.Down then
  begin
    CanSelect := True;
    for Index := FTextItems.Count - 1 downto 0 do
    begin
      Item := FTextItems[Index];
      if CanSelect and PtInRect(Item.Rect, Point(X, Y)) then
      begin
        CanSelect := False;
        FSelectedItem := Item;
        FSelectedItem.Selected := True;
        FStartX := X;
        FStartY := Y;
      end
      else
      begin
        Item.Selected := False;
      end;
    end;
  end;
end;

procedure TfrmExportImage.SetSelectedItem(const Value: TDrawItem);
begin
  FSelectedItem := Value;
  if FSelectedItem <> nil then
  begin
    FSelectingItem := True;
    try
      FDefaultFont.Assign(FSelectedItem.Font);
    finally
      FSelectingItem := False;
    end;
  end;
end;

procedure TfrmExportImage.timerDrawImageDelayTimer(Sender: TObject);
const
  OneSecond = 1/24/3600;
begin
  inherited;

  if (Now - FChangeTime > OneSecond)
    or (timerDrawImageDelay.Interval <> 100) then
  begin
    timerDrawImageDelay.Enabled := False;
    timerDrawImageDelay.Interval := 100;
    DrawImage;
  end;
end;

end.
