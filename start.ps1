param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot 'flutter.ps1') build web --release
    if ($LASTEXITCODE -ne 0) { throw 'Uygulama derlenemedi.' }
}
$dartExecutable = Join-Path $PSScriptRoot '.tools\flutter\bin\dart.bat'
if (-not (Test-Path -LiteralPath $dartExecutable)) {
    $installedDart = Get-Command dart.bat,dart -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $installedDart) { throw 'Dart SDK bulunamadı. Flutter bin klasörünü PATH değişkenine ekleyin.' }
    $dartExecutable = $installedDart.Source
}
& $dartExecutable tool/serve.dart
exit $LASTEXITCODE
