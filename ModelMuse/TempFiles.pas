{@name is used to generate the names of new temporary files and
to delete those files when the program closes.  During initialization
of @name, an application-specific temporary directory will be created
if it does not already exist.  If any files are in the directory and
another instance of the program is not already running, the temporary
directory will be cleared.}
unit TempFiles;

interface

uses Windows, SysUtils, Classes;

{@name generates a name for a new temporary file in an application-specific
temporary directory.  When the program
closes, any file whose name matches a name generated by @name will
be deleted if it has not already been deleted.  }
function TempFileName: string;

// @name returns the name of a temporary directory where
// temporary files for an Application can be created.
// If the directory does not exist, @name will create it.
function GetAppSpecificTempDir: string;

type
  // @name is similar to TFileStream but the file is opened with
  // the FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE flags.
  //
  //  Mode must be fmOpenRead, fmOpenWrite, or fmOpenReadWrite
  TTempFileStream = class(THandleStream)
    constructor Create(const AFileName: string; Mode: Word);
  end;

implementation

uses RTLConsts;

var
  TemporaryFiles: TStringList;
  CurrentTempDir: string = '';
  DirCount: integer = 0;
  ErrorCount: integer = 0;
  Directories: TStringList;

// Get the name of an application-specific temporary directory.
// Create the directory if it does not already exist.
function GetAppSpecificTempDir: string;
var
  ApplicationName: string;
  PathName: array[0..260] of Char;
begin
  if GetTempPath(MAX_PATH, @PathName) = 0 then
  begin
    RaiseLastOSError;
  end;
  result := IncludeTrailingPathDelimiter(Trim(PathName));
  ApplicationName := ExtractFileName(ParamStr(0));
  result := IncludeTrailingPathDelimiter(result + ChangeFileExt(ApplicationName, ''));
  if not DirectoryExists(result) then
  begin
    CreateDir(result);
//    Application.ProcessMessages;
  end;
end;

function TempFileName: string;
var
  NewFileName: array[0..MAX_PATH] of Char;
  TempDir: string;
begin
  if CurrentTempDir = '' then
  begin
    CurrentTempDir := GetAppSpecificTempDir;
    if Directories.IndexOf(CurrentTempDir) < 0 then
    begin
      Directories.Add(CurrentTempDir);
//      ShowMessage(CurrentTempDir);
    end;
  end;
  TempDir := CurrentTempDir;
  if not DirectoryExists(TempDir) then
  begin
    CreateDir(TempDir);
    Directories.Add(TempDir);
//    Application.ProcessMessages;
  end;

  if GetTempFileName(PChar(TempDir), 'MM_', 0, @NewFileName) = 0 then
  begin
    if ErrorCount < 5 then
    begin
      Inc(DirCount);
      CurrentTempDir := IncludeTrailingPathDelimiter(
        ExcludeTrailingPathDelimiter(GetAppSpecificTempDir)
        + IntToStr(DirCount));
//      ShowMessage(CurrentTempDir);
      Inc(ErrorCount);
      result := TempFileName;
    end
    else
    begin
      RaiseLastOSError;
    end;
  end
  else
  begin
    ErrorCount := 0;
    result := NewFileName;
  end;
  if Pos('FFFF', ExtractFileName(result)) > 0 then
  begin
    Inc(DirCount);
    CurrentTempDir := IncludeTrailingPathDelimiter(
      ExcludeTrailingPathDelimiter(GetAppSpecificTempDir)
      + IntToStr(DirCount));
    if not DirectoryExists(CurrentTempDir) then
    begin
      CreateDir(CurrentTempDir);
//      Application.ProcessMessages;
      Directories.Add(CurrentTempDir);
//      ShowMessage(CurrentTempDir);
    end;
  end;
  TemporaryFiles.Add(result);
end;

//procedure RemoveDirectories;
//var
//  Index: Integer;
//begin
//  for Index := 0 to Directories.Count - 1 do
//  begin
//    if DirectoryExists(Directories[Index]) then
//    begin
//      // If the directory contains files, RemoveDir will fail.
//      RemoveDir(Directories[Index]);
//    end;
//  end;
//end;

// delete all files that were generated by TempFileName if they have
// not already been deleted.
procedure DeleteFiles;
var
  Index: integer;
begin
  for Index := 0 to TemporaryFiles.Count - 1 do
  begin
    if FileExists(TemporaryFiles[Index]) then
    begin
      DeleteFile(TemporaryFiles[Index]);
    end;
  end;
  TemporaryFiles.Clear;
end;

var
  ShouldReleaseMutex: boolean = False;
  MutexHandle: THandle;

// Check if the program is already running.  If not, create a mutex
// that subsequent instances can use to check if another version is already
// running.
function AlreadyRunning: boolean;
var
  MutexName: string;
begin
  MutexName := ExtractFileName(ParamStr(0));
  if OpenMutex(MUTEX_ALL_ACCESS, False, PChar(MutexName)) <> 0 then
  begin
    result := True;
  end
  else
  begin
    result := False;
    MutexHandle := CreateMutex(nil, TRUE, PChar(MutexName));
    ShouldReleaseMutex := True;
  end;
end;

// Delete all files in the application-specific temporary directory.
procedure ClearAppSpecificTempDirectory;
var
  TempPath: string;
  F: TSearchRec;
  Files: TStringList;
  Index: Integer;
  FoundFile: boolean;
  FirstDir: string;
  DirCount: Integer;
begin
  FirstDir := GetAppSpecificTempDir;
  DirCount := 0;
  TempPath := FirstDir;

  Files := TStringList.Create;
  try
    While True do
    begin
      FoundFile := FindFirst(TempPath + '*.*', 0, F) = 0;
      try
        if FoundFile then
        begin
          Files.Add(TempPath + F.Name);
          While FindNext(F) = 0 do
          begin
            Files.Add(TempPath + F.Name);
          end;
        end;
      finally
        FindClose(F);
      end;
      for Index := 0 to Files.Count - 1 do
      begin
        if FileExists(Files[Index]) then
        begin
          DeleteFile(Files[Index]);
        end;
      end;
      Files.Clear;
      if DirectoryExists(TempPath) then
      begin
        RemoveDir(TempPath);
      end;
      Inc(DirCount);
      TempPath := IncludeTrailingPathDelimiter(
        ExcludeTrailingPathDelimiter(FirstDir)
        + IntToStr(DirCount));
      if not DirectoryExists(TempPath) then
      begin
        break;
      end;
    end;
  finally
    Files.Free;
  end;
end;

{ TTempFileStream }

constructor TTempFileStream.Create(const AFileName: string; Mode: Word);
const
  AccessModes: array[0..2] of DWORD =
    (GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE);
  ShareMode: DWORD = FILE_SHARE_DELETE or FILE_SHARE_READ or FILE_SHARE_WRITE;
  Flags : DWORD = FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE;
var
  AHandle: THandle;
  FileAlreadyExists: Boolean;
  CreateDispostion: DWORD;
begin
  Assert(Mode in [fmOpenRead, fmOpenWrite, fmOpenReadWrite]);

  FileAlreadyExists := FileExists(AFileName);
  if FileAlreadyExists then
  begin
    CreateDispostion := OPEN_EXISTING;
  end
  else
  begin
    CreateDispostion := OPEN_ALWAYS;
  end;
  AHandle := CreateFile(PChar(AFileName), AccessModes[Mode], ShareMode, nil,
    CreateDispostion, Flags, 0);
  inherited  Create(Integer(AHandle));
  if Handle < 0 then
  begin
    if FileAlreadyExists then
    begin
      raise EFCreateError.CreateResFmt(@SFCreateErrorEx,
        [ExpandFileName(AFileName), SysErrorMessage(GetLastError)]);
    end
    else
    begin
      raise EFOpenError.CreateResFmt(@SFOpenErrorEx,
        [ExpandFileName(AFileName), SysErrorMessage(GetLastError)]);
    end;
  end;
end;

initialization
  if not AlreadyRunning then
  begin
    ClearAppSpecificTempDirectory;
  end;
  TemporaryFiles:= TStringList.Create;
  Directories := TStringList.Create;

finalization
  DeleteFiles;
  // another instance of ModelMuse may need directories
  // created by this version
//  RemoveDirectories;
  TemporaryFiles.Free;
  Directories.Free;
  if ShouldReleaseMutex then
  begin
    ReleaseMutex(MutexHandle);
  end;

end.
