# Builds the Windows release and puts the runner (verso.exe + DLLs + data\) in the
# root of this version folder, plus a zip in ..\releases. Google client from
# tool\google_client.env (KEY=VALUE lines, git-ignored) is baked in via --dart-define.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value
$defines = @()
$envFile = Join-Path $PSScriptRoot 'google_client.env'
if (Test-Path $envFile) {
  foreach ($line in Get-Content $envFile) {
    if ($line -match '^\s*([A-Z_]+)=(.+)$') { $defines += "--dart-define=$($Matches[1])=$($Matches[2].Trim())" }
  }
}
python (Join-Path $PSScriptRoot 'junctions.py') $root | Out-Null
flutter build windows --release --no-pub @defines
if ($LASTEXITCODE -ne 0) { throw 'build failed' }
$bundle = Join-Path $root 'build\windows\x64\runner\Release'
Remove-Item -Recurse -Force (Join-Path $root 'data') -ErrorAction SilentlyContinue
Copy-Item (Join-Path $bundle '*') $root -Recurse -Force
$rel = Join-Path (Split-Path $root -Parent) 'releases'
New-Item -ItemType Directory -Force $rel | Out-Null
$zip = Join-Path $rel "Verso-$version-windows-x64.zip"
Remove-Item $zip -ErrorAction SilentlyContinue
Compress-Archive -Path (Join-Path $bundle '*') -DestinationPath $zip
"Runner: $root\verso.exe"
"Zip:    $zip"
