unit frmRunModflowUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CustomExtendedDialogForm;

type
  TfrmRunModflow = class(TCustomExtendedDialog)
    cbRun: TCheckBox;
    comboModelSelection: TComboBox;
    cbModpath: TCheckBox;
    cbForceCBF: TCheckBox;
    cbExportZoneBudget: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRunModflow: TfrmRunModflow;

implementation

{$R *.dfm}

end.
