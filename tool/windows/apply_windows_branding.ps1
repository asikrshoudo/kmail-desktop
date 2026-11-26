param()

Continue = "Stop"
 = Split-Path -Parent 
 = Split-Path -Parent 
 = Join-Path  "windows"
 = Join-Path  "assets\branding\kmail.ico"

if (!(Test-Path )) { throw "windows directory not found: " }
if (!(Test-Path )) { throw "Icon source not found: " }

# --- Icon ---
 = Join-Path  "runner\resources\app_icon.ico"
New-Item -ItemType Directory -Force -Path (Split-Path ) | Out-Null
Copy-Item   -Force
Write-Host "Applied icon -> "

# --- Version from pubspec.yaml ---
 = Join-Path  "pubspec.yaml"
 = Get-Content  -Raw
if ( -match '(?m)^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)\s*$') {
  =[1]; =[2]; =[3]; =[4]
} elseif ( -match '(?m)^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\s*$') {
  =[1]; =[2]; =[3]; ='0'
} else {
  throw "Unable to parse version from pubspec.yaml"
}
 = ",,,"
 = "..."
Write-Host "Using version "

# --- Root CMakeLists.txt: BINARY_NAME ---
 = Join-Path  "CMakeLists.txt"
if (Test-Path ) {
   = Get-Content  -Raw
   = [regex]::Replace(, 'set\(BINARY_NAME\s+"[^"]+"\)', 'set(BINARY_NAME "Kmail")', 1)
  if ( -ne ) { Set-Content -Path  -Value  -Encoding UTF8; Write-Host "Updated BINARY_NAME in windows/CMakeLists.txt" }
}

# --- Runner.rc ---
 = Join-Path  "runner\Runner.rc"
if (Test-Path ) {
   = Get-Content  -Raw
   = [regex]::Replace(, '#define VERSION_AS_NUMBER\s+[0-9,]+', "#define VERSION_AS_NUMBER ")
   = [regex]::Replace(, '#define VERSION_AS_STRING\s+"[^"]+"', "#define VERSION_AS_STRING """)
   = [regex]::Replace(, '(VALUE\s+"CompanyName"\s*,\s*")[^"]*(")', 'TheKami')
   = [regex]::Replace(, '(VALUE\s+"FileDescription"\s*,\s*")[^"]*(")', 'Kmail')
   = [regex]::Replace(, '(VALUE\s+"FileVersion"\s*,\s*")[^"]*(")', '' +  + '')
   = [regex]::Replace(, '(VALUE\s+"InternalName"\s*,\s*")[^"]*(")', 'Kmail')
   = [regex]::Replace(, '(VALUE\s+"LegalCopyright"\s*,\s*")[^"]*(")', 'Copyright (C) 2026 TheKami. All rights reserved.')
   = [regex]::Replace(, '(VALUE\s+"OriginalFilename"\s*,\s*")[^"]*(")', 'Kmail.exe')
   = [regex]::Replace(, '(VALUE\s+"ProductName"\s*,\s*")[^"]*(")', 'Kmail')
   = [regex]::Replace(, '(VALUE\s+"ProductVersion"\s*,\s*")[^"]*(")', '' +  + '')
  Set-Content -Path  -Value  -Encoding UTF8
  Write-Host "Updated Runner.rc metadata"
}

# --- main.cpp: AppUserModelID and window title ---
 = Join-Path  "runner\main.cpp"
if (Test-Path ) {
   = Get-Content  -Raw
   = 

  if ( -notmatch 'SetAppUserModelID') {
    # Insert a small helper that avoids extra link dependencies.
     = @'
namespace {

void SetKmailAppUserModelId() {
  // Set Windows AppUserModelID for taskbar/notification identity.
  // Use dynamic lookup to avoid link-time dependency changes in generated runner.
  HMODULE shell32 = ::LoadLibraryW(L"shell32.dll");
  if (shell32 == nullptr) {
    return;
  }
  typedef HRESULT(WINAPI* SetAppIdFunc)(PCWSTR);
  auto set_app_id = reinterpret_cast<SetAppIdFunc>(
      ::GetProcAddress(shell32, "SetCurrentProcessExplicitAppUserModelID"));
  if (set_app_id != nullptr) {
    set_app_id(L"TheKami.Kmail");
  }
  ::FreeLibrary(shell32);
}

}  // namespace

'@
    # Add helper before wWinMain
    if ( -match '(?m)^int APIENTRY wWinMain\(') {
       = [regex]::Replace(, '(?m)^int APIENTRY wWinMain\(', ( + 'int APIENTRY wWinMain('), 1)
    }

    # Call helper early in wWinMain
     = '  SetKmailAppUserModelId();' + "

"
    if ( -match '::CoInitializeEx\(nullptr,\s*COINIT_APARTMENTTHREADED\);[^\r\n]*\r?\n') {
       = [regex]::Replace(, '(::CoInitializeEx\(nullptr,\s*COINIT_APARTMENTTHREADED\);[^\r\n]*\r?\n)', "$1
", 1)
    } elseif ( -match '(int APIENTRY wWinMain\(.*?\)\s*\{[^\r\n]*\r?\n)') {
       = [regex]::Replace(, '(int APIENTRY wWinMain\(.*?\)\s*\{[^\r\n]*\r?\n)', "$1", 1)
    }
  } else {
     = [regex]::Replace(, 'L"TheKami\.Kmail"', 'L"TheKami.Kmail"')
  }

  # Window title - common Flutter patterns
   = [regex]::Replace(, 'window\.Create\(L"[^"]+"', 'window.Create(L"Kmail"')
   = [regex]::Replace(, 'window\.CreateAndShow\(L"[^"]+"', 'window.CreateAndShow(L"Kmail"')
   = [regex]::Replace(, 'Win32Window::CreateAndShow\(L"[^"]+"', 'Win32Window::CreateAndShow(L"Kmail"')
   = [regex]::Replace(, 'if \(!window\.Create\(L"[^"]+"', 'if (!window.Create(L"Kmail"')
   = [regex]::Replace(, 'if \(!window\.CreateAndShow\(L"[^"]+"', 'if (!window.CreateAndShow(L"Kmail"')

  if ( -ne ) {
    Set-Content -Path  -Value  -Encoding UTF8
    Write-Host "Updated main.cpp identity/window title"
  }
}

Write-Host "Windows branding patch complete."
