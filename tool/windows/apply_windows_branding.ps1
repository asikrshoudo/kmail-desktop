param()

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
$repo = Split-Path -Parent $repo
$windowsDir = Join-Path $repo "windows"
$iconSrc = Join-Path $repo "assets\branding\kmail.ico"

Write-Host "Applying Windows branding in $repo"
if (!(Test-Path $windowsDir)) { throw "windows directory not found: $windowsDir" }
if (!(Test-Path $iconSrc)) { throw "Icon source not found: $iconSrc" }

$iconDst = Join-Path $windowsDir "runner\resources\app_icon.ico"
New-Item -ItemType Directory -Force -Path (Split-Path $iconDst) | Out-Null
Copy-Item $iconSrc $iconDst -Force
Write-Host "Applied icon -> $iconDst"

$pubspecPath = Join-Path $repo "pubspec.yaml"
$pubspec = Get-Content $pubspecPath -Raw
if ($pubspec -match '(?m)^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)\s*$') {
  $maj = $Matches[1]; $min = $Matches[2]; $pat = $Matches[3]; $build = $Matches[4]
} elseif ($pubspec -match '(?m)^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\s*$') {
  $maj = $Matches[1]; $min = $Matches[2]; $pat = $Matches[3]; $build = "0"
} else { throw "Unable to parse version from pubspec.yaml" }
$verComma = "$maj,$min,$pat,$build"
$verDot = "$maj.$min.$pat.$build"
Write-Host "Using version $verDot"

$rootCmake = Join-Path $windowsDir "CMakeLists.txt"
if (Test-Path $rootCmake) {
  $c = Get-Content $rootCmake -Raw
  $c2 = [regex]::Replace($c, 'set\(BINARY_NAME\s+"[^"]+"\)', 'set(BINARY_NAME "Kmail")', 1)
  if ($c -ne $c2) { Set-Content -Path $rootCmake -Value $c2 -Encoding UTF8; Write-Host "Updated BINARY_NAME" }
}

$runnerRc = Join-Path $windowsDir "runner\Runner.rc"
if (Test-Path $runnerRc) {
  $rc = Get-Content $runnerRc -Raw
  $rc = [regex]::Replace($rc, '#define VERSION_AS_NUMBER\s+[0-9,]+', "#define VERSION_AS_NUMBER $verComma")
  $rc = [regex]::Replace($rc, '#define VERSION_AS_STRING\s+"[^"]+"', ('#define VERSION_AS_STRING "' + $verDot + '"'))
  $rc = [regex]::Replace($rc, '(VALUE\s+"CompanyName"\s*,\s*")[^"]*(")', '${1}TheKami${2}')
  $rc = [regex]::Replace($rc, '(VALUE\s+"FileDescription"\s*,\s*")[^"]*(")', '${1}Kmail${2}')
  $rc = [regex]::Replace($rc, '(VALUE\s+"FileVersion"\s*,\s*")[^"]*(")', ('${1}' + $verDot + '${2}'))
  $rc = [regex]::Replace($rc, '(VALUE\s+"InternalName"\s*,\s*")[^"]*(")', '${1}Kmail${2}')
  $rc = [regex]::Replace($rc, '(VALUE\s+"LegalCopyright"\s*,\s*")[^"]*(")', '${1}Copyright (C) 2026 TheKami. All rights reserved.${2}')
  $rc = [regex]::Replace($rc, '(VALUE\s+"OriginalFilename"\s*,\s*")[^"]*(")', '${1}Kmail.exe${2}')
  $rc = [regex]::Replace($rc, '(VALUE\s+"ProductName"\s*,\s*")[^"]*(")', '${1}Kmail${2}')
  $rc = [regex]::Replace($rc, '(VALUE\s+"ProductVersion"\s*,\s*")[^"]*(")', ('${1}' + $verDot + '${2}'))
  Set-Content -Path $runnerRc -Value $rc -Encoding UTF8
  Write-Host "Updated Runner.rc"
}

$mainCpp = Join-Path $windowsDir "runner\main.cpp"
if (Test-Path $mainCpp) {
  $main = Get-Content $mainCpp -Raw
  $original = $main
  if ($main -notmatch 'SetKmailAppUserModelId') {
    $helperLines = @(
      'namespace {',
      '',
      'void SetKmailAppUserModelId() {',
      '  HMODULE shell32 = ::LoadLibraryW(L"shell32.dll");',
      '  if (shell32 == nullptr) { return; }',
      '  typedef HRESULT(WINAPI* SetAppIdFunc)(PCWSTR);',
      '  auto set_app_id = reinterpret_cast<SetAppIdFunc>(',
      '      ::GetProcAddress(shell32, "SetCurrentProcessExplicitAppUserModelID"));',
      '  if (set_app_id != nullptr) { set_app_id(L"TheKami.Kmail"); }',
      '  ::FreeLibrary(shell32);',
      '}',
      '',
      '}  // namespace',
      ''
    )
    $helper = ($helperLines -join "`r`n") + "`r`n"
    $main = [regex]::Replace($main, '(?m)^int APIENTRY wWinMain\(', ($helper + [char]13 + [char]10 + 'int APIENTRY wWinMain('), 1)
    $call = "  SetKmailAppUserModelId();`r`n`r`n"
    if ($main -match '::CoInitializeEx\(nullptr,\s*COINIT_APARTMENTTHREADED\);[^\r\n]*\r?\n') {
      $main = [regex]::Replace($main, '(::CoInitializeEx\(nullptr,\s*COINIT_APARTMENTTHREADED\);[^\r\n]*\r?\n)', ('$1' + [char]13 + [char]10 + $call), 1)
    } elseif ($main -match '(int APIENTRY wWinMain\(.*?\)\s*\{[^\r\n]*\r?\n)') {
      $main = [regex]::Replace($main, '(int APIENTRY wWinMain\(.*?\)\s*\{[^\r\n]*\r?\n)', ('$1' + $call), 1)
    }
  }
  $main = [regex]::Replace($main, 'window\.Create\(L"[^"]+"', 'window.Create(L"Kmail"')
  $main = [regex]::Replace($main, 'window\.CreateAndShow\(L"[^"]+"', 'window.CreateAndShow(L"Kmail"')
  $main = [regex]::Replace($main, 'Win32Window::CreateAndShow\(L"[^"]+"', 'Win32Window::CreateAndShow(L"Kmail"')
  $main = [regex]::Replace($main, 'if \(!window\.Create\(L"[^"]+"', 'if (!window.Create(L"Kmail"')
  $main = [regex]::Replace($main, 'if \(!window\.CreateAndShow\(L"[^"]+"', 'if (!window.CreateAndShow(L"Kmail"')
  if ($main -ne $original) { Set-Content -Path $mainCpp -Value $main -Encoding UTF8; Write-Host "Updated main.cpp" }
}

Write-Host "Windows branding patch complete."
