#define MyAppName "Kmail"
#define MyAppPublisher "TheKami"
#define MyAppURL "https://github.com/asikrshoudo/kmail-desktop"
#define MyAppExeName "Kmail.exe"
#define MyAppId "com.thekami.kmail"

[Setup]
AppId={{8D8F9D5A-3F1E-4B8D-9A5F-2D1B7C6E4A11}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Installer metadata
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} Setup
VersionInfoProductName={#MyAppName}
VersionInfoVersion={#MyAppVersion}
; Output
OutputDir={#OutputDir}
OutputBaseFilename=Kmail-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Icons
SetupIconFile={#RepoDir}\assets\branding\kmail.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
; Privileges - prefer per-user install when possible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Behavior
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "TheKami.Kmail"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; AppUserModelID: "TheKami.Kmail"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Keep user data by default. No Type: filesandordirs deletion for app data.

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;


