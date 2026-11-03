$ErrorActionPreference = 'Stop'
$flutterExecutable = Join-Path $PSScriptRoot '.tools\flutter\bin\flutter.bat'
if (-not (Test-Path -LiteralPath $flutterExecutable)) {
    $installedFlutter = Get-Command flutter.bat,flutter -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $installedFlutter) { throw 'Flutter SDK bulunamadı. Flutter bin klasörünü PATH değişkenine ekleyin.' }
    $flutterExecutable = $installedFlutter.Source
}
$flutterArgs = @($args)
if ($flutterArgs.Count -gt 0 -and $flutterArgs[0] -eq 'run' -and
    ($flutterArgs -contains 'edge' -or $flutterArgs -contains 'chrome' -or $flutterArgs -contains 'web-server') -and
    -not ($flutterArgs | Where-Object { $_ -like '--web-port*' })) {
    $flutterArgs += @('--web-port', '7357')
}
& $flutterExecutable @flutterArgs
exit $LASTEXITCODE
