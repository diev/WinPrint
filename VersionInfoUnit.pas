unit VersionInfoUnit;

interface

uses
  SysUtils;

type
  TFileVersionInfo = record
    FileType,
    CompanyName,
    FileDescription,
    FileVersion,
    InternalName,
    LegalCopyRight,
    LegalTradeMarks,
    OriginalFileName,
    ProductName,
    ProductVersion,
    Comments,
    SpecialBuildStr,
    PrivateBuildStr,
    FileFunction: string;
    DebugBuild,
    PreRelease,
    SpecialBuild,
    PrivateBuild,
    Patched,
    InfoInferred: Boolean;
  end;

function FileVersion2(const sAppNamePath: TFileName): string;
function FileVersion4(const sAppNamePath: TFileName): string;
function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;

implementation

uses
  WinApi.Windows,
  WinApi.ShellApi;

function FileVersion2(const sAppNamePath: TFileName): string; // 1.0 only
var
  Rec: LongRec;
begin
  Rec := LongRec(GetFileVersion(sAppNamePath));
  Result := Format('%d.%d', [Rec.Hi, Rec.Lo])
end;

function FileVersion4(const sAppNamePath: TFileName): string; // 1.0.0.0 full
var
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  Size := GetFileVersionInfoSize(PChar(sAppNamePath), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(sAppNamePath), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d',
    [LongRec(FixedPtr.dwFileVersionMS).Hi,  //major
     LongRec(FixedPtr.dwFileVersionMS).Lo,  //minor
     LongRec(FixedPtr.dwFileVersionLS).Hi,  //release
     LongRec(FixedPtr.dwFileVersionLS).Lo]) //build
end;

function FileVersionInfo(const sAppNamePath: TFileName): TFileVersionInfo;
var
  rSHFI: TSHFileInfo;
  iRet: Integer;
  VerSize: Integer;
  VerBuf: PChar;
  VerBufValue: Pointer;
  VerHandle: Cardinal;
  VerBufLen: Cardinal;
  VerKey: string;
  FixedFileInfo: PVSFixedFileInfo;

  // dwFileType, dwFileSubtype
  function GetFileSubType(FixedFileInfo: PVSFixedFileInfo): string;
  begin
    case FixedFileInfo.dwFileType of

      VFT_UNKNOWN: Result    := 'Unknown';
      VFT_APP: Result        := 'Application';
      VFT_DLL: Result        := 'DLL';
      VFT_STATIC_LIB: Result := 'Static-link Library';

      VFT_DRV:
        case
          FixedFileInfo.dwFileSubtype of
          VFT2_UNKNOWN: Result         := 'Unknown Driver';
          VFT2_DRV_COMM: Result        := 'Communications Driver';
          VFT2_DRV_PRINTER: Result     := 'Printer Driver';
          VFT2_DRV_KEYBOARD: Result    := 'Keyboard Driver';
          VFT2_DRV_LANGUAGE: Result    := 'Language Driver';
          VFT2_DRV_DISPLAY: Result     := 'Display Driver';
          VFT2_DRV_MOUSE: Result       := 'Mouse Driver';
          VFT2_DRV_NETWORK: Result     := 'Network Driver';
          VFT2_DRV_SYSTEM: Result      := 'System Driver';
          VFT2_DRV_INSTALLABLE: Result := 'InstallableDriver';
          VFT2_DRV_SOUND: Result       := 'Sound Driver';
        end;
      VFT_FONT:
        case FixedFileInfo.dwFileSubtype of
          VFT2_UNKNOWN: Result       := 'Unknown Font';
          VFT2_FONT_RASTER: Result   := 'Raster Font';
          VFT2_FONT_VECTOR: Result   := 'Vector Font';
          VFT2_FONT_TRUETYPE: Result := 'Truetype Font';
          else;
        end;
      VFT_VXD: Result := 'Virtual Defice Identifier = ' +
          IntToHex(FixedFileInfo.dwFileSubtype, 8);
    end;
  end;

  function HasdwFileFlags(FixedFileInfo: PVSFixedFileInfo; Flag: Word): Boolean;
  begin
    Result := (FixedFileInfo.dwFileFlagsMask and
      FixedFileInfo.dwFileFlags and
      Flag) = Flag;
  end;

  function GetFixedFileInfo: PVSFixedFileInfo;
  begin
    if not VerQueryValue(VerBuf, '', Pointer(Result), VerBufLen) then
      Result := nil
  end;

  function GetInfo(const aKey: string): string;
  begin
    Result := '';
    VerKey := Format('\StringFileInfo\%.4x%.4x\%s',
      [LoWord(Integer(VerBufValue^)),
      HiWord(Integer(VerBufValue^)), aKey]);
    if VerQueryValue(VerBuf, PChar(VerKey), VerBufValue, VerBufLen) then
      Result := PChar(VerBufValue);
  end;

  function QueryValue(const aValue: string): string;
  begin
    Result := '';
    // obtain version information about the specified file
    if GetFileVersionInfo(PChar(sAppNamePath), VerHandle, VerSize, VerBuf) and
      // return selected version information
      VerQueryValue(VerBuf, '\VarFileInfo\Translation', VerBufValue, VerBufLen) then
      Result := GetInfo(aValue);
  end;

  begin
    // Initialize the Result
    with Result do
      begin
      FileType         := '';
      CompanyName      := '';
      FileDescription  := '';
      FileVersion      := '';
      InternalName     := '';
      LegalCopyRight   := '';
      LegalTradeMarks  := '';
      OriginalFileName := '';
      ProductName      := '';
      ProductVersion   := '';
      Comments         := '';
      SpecialBuildStr  := '';
      PrivateBuildStr  := '';
      FileFunction     := '';
      DebugBuild       := False;
      Patched          := False;
      PreRelease       := False;
      SpecialBuild     := False;
      PrivateBuild     := False;
      InfoInferred     := False;
    end;

    // Get the file type
    if SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI),
      SHGFI_TYPENAME) <> 0 then
    begin
      Result.FileType := rSHFI.szTypeName;
    end;

    iRet := SHGetFileInfo(PChar(sAppNamePath), 0, rSHFI, SizeOf(rSHFI), SHGFI_EXETYPE);
    if iRet <> 0 then
    begin
      // determine whether the OS can obtain version information
      VerSize := GetFileVersionInfoSize(PChar(sAppNamePath), VerHandle);
      if VerSize > 0 then
      begin
        VerBuf := AllocMem(VerSize);
        try
          with Result do
          begin
            CompanyName      := QueryValue('CompanyName');
            FileDescription  := QueryValue('FileDescription');
            FileVersion      := FileVersion4(sAppNamePath); // QueryValue('FileVersion');
            InternalName     := QueryValue('InternalName');
            LegalCopyRight   := QueryValue('LegalCopyRight');
            LegalTradeMarks  := QueryValue('LegalTradeMarks');
            OriginalFileName := QueryValue('OriginalFileName');
            ProductName      := QueryValue('ProductName');
            ProductVersion   := QueryValue('ProductVersion');
            Comments         := QueryValue('Comments');
            SpecialBuildStr  := QueryValue('SpecialBuild');
            PrivateBuildStr  := QueryValue('PrivateBuild');
            // Fill the VS_FIXEDFILEINFO structure
            FixedFileInfo := GetFixedFileInfo;
            DebugBuild    := HasdwFileFlags(FixedFileInfo, VS_FF_DEBUG);
            PreRelease    := HasdwFileFlags(FixedFileInfo, VS_FF_PRERELEASE);
            PrivateBuild  := HasdwFileFlags(FixedFileInfo, VS_FF_PRIVATEBUILD);
            SpecialBuild  := HasdwFileFlags(FixedFileInfo, VS_FF_SPECIALBUILD);
            Patched       := HasdwFileFlags(FixedFileInfo, VS_FF_PATCHED);
            InfoInferred  := HasdwFileFlags(FixedFileInfo, VS_FF_INFOINFERRED);
            FileFunction  := GetFileSubType(FixedFileInfo);
          end;
        finally
          FreeMem(VerBuf, VerSize);
        end
      end;
    end;
  end;
end.
