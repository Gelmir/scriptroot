#define MyAppName "QMPDClient (x64 Edition)"
#define MyAppPublisher ""
#define MyAppCopyright "(c) 2008-2009 by Voker57"
#define MyAppURL "http://bitcheese.net/wiki/QMPDClient"
#define MyAppExeName "qmpdclient.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{21E3197A-8E2D-47AD-9C91-DB93C26E86FE}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppCopyright={#MyAppCopyright}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
; Do not allow to change start menu shortcut group during installation
DisableProgramGroupPage=yes
LicenseFile="{#MyFilesRoot}\LICENSE.txt"
Compression=lzma2/ultra
SolidCompression=yes
CompressionThreads=auto
LZMANumBlockThreads=2
; Only install in x64 mode and on x64 OSes (Vista and up)
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
MinVersion=6.0.6000
; Installer icon
SetupIconFile={#MyIcon}
; Use installation rules from previous setup (when updating) if possible
UsePreviousTasks=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbianlatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyFilesRoot}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; OpenSSL
Source: "{#MyFilesRoot}\libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyFilesRoot}\ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion
; Qt shared files
Source: "{#MyFilesRoot}\plugins\*"; DestDir: "{app}\plugins"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#MyFilesRoot}\translations\*"; DestDir: "{app}\translations"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#MyFilesRoot}\qt.conf"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Qt4 version
Source: "{#MyFilesRoot}\QtCore4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtGui4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtNetwork4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtXmlPatterns4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\QtXml4.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; Visual C++ 2013 x64 Redistributable
Source: "{#MyFilesRoot}\msvcp120.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#MyFilesRoot}\msvcr120.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
; App to kill process by name
Source: "{#PACKDIR}\processviewer.exe"; Flags: dontcopy
; License
Source: "{#MyFilesRoot}\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion


[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Code]

// Thanks to http://stackoverflow.com/a/2099805/1477014 for the functions
/////////////////////////////////////////////////////////////////////
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;


/////////////////////////////////////////////////////////////////////
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


/////////////////////////////////////////////////////////////////////
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

/////////////////////////////////////////////////////////////////////
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;
/////////////////////////////////////////////////////////////////////

// Check if qBittorrent.exe is running
function ProductRunning(): Boolean;
var
  ExitCode:    Integer;
begin  
  ExtractTemporaryFile('processviewer.exe');
  if Exec(ExpandConstant('{tmp}\processviewer.exe'), 'qmpdclient.exe', '', SW_HIDE, ewWaitUntilTerminated, ExitCode)
  then
  begin
    // Process found
    Result := ( ExitCode > 0 );
    Exit;    
  end;
  
  Result := False;
end;
  
// Override Setup Init
function InitializeSetup(): Boolean;
begin
  if ProductRunning()
  then
  begin
    MsgBox( 'qmpdclient is already running. Please close all application instances and restart setup.', mbInformation, MB_OK );
    Result := False;
  end
  else
  begin
    Result := True;
  end;
end;

