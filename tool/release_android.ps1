# Builds the signed Android release APK and copies it to ..\releases\Verso-<version>-android.apk.
#
# - The Google client (tool\google_client.env, git-ignored) is baked in via --dart-define, as on Windows.
# - Signing: android\app\build.gradle.kts reads D:\RandD\Android Apps\AndroidKeys\versoapp.properties
#   (outside the repo; override with $env:VERSO_SIGNING). Without it the APK is signed with the
#   debug key and the script stops, because such an APK can't update an installed release.
# - Pass -Debug to build a debug APK (package design.hadi.verso.debug) instead.
param([switch]$Debug)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$env:JAVA_HOME = "$env:USERPROFILE\.jdks\jbr-21.0.11"   # Gradle fails on Android Studio's Java 25
$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value
$defines = @()
$envFile = Join-Path $PSScriptRoot 'google_client.env'
if (Test-Path $envFile) {
  foreach ($line in Get-Content $envFile) {
    if ($line -match '^\s*([A-Z_]+)=(.+)$') { $defines += "--dart-define=$($Matches[1])=$($Matches[2].Trim())" }
  }
}
$signing = if ($env:VERSO_SIGNING) { $env:VERSO_SIGNING } else { 'D:\RandD\Android Apps\AndroidKeys\versoapp.properties' }
if (-not $Debug -and -not (Test-Path $signing)) { throw "Release key settings not found at $signing" }

$mode = if ($Debug) { '--debug' } else { '--release' }
flutter build apk $mode --no-pub @defines
if ($LASTEXITCODE -ne 0) { throw 'build failed' }

$kind = if ($Debug) { 'debug' } else { 'release' }
$apk = Join-Path $root "build\app\outputs\flutter-apk\app-$kind.apk"
$rel = Join-Path (Split-Path $root -Parent) 'releases'
New-Item -ItemType Directory -Force $rel | Out-Null
$name = if ($Debug) { "Verso-$version-android-debug.apk" } else { "Verso-$version-android.apk" }
$out = Join-Path $rel $name
Copy-Item $apk $out -Force
"APK: $out"
