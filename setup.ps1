$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$localFlutterBin = Join-Path $PSScriptRoot '.tools\flutter\bin'
if (Test-Path -LiteralPath (Join-Path $localFlutterBin 'flutter.bat')) {
    $env:Path = "$localFlutterBin;$env:Path"
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter SDK bulunamadı. Flutter kurup bin klasörünü PATH değişkenine ekleyin.'
}
flutter create --platforms=android,ios,web --project-name=deep_link_demo --org=com.example --no-pub .
if ($LASTEXITCODE -ne 0) { throw 'Platform dosyaları oluşturulamadı.' }
dart tool/configure.dart
if ($LASTEXITCODE -ne 0) { throw 'Deep link ayarları uygulanamadı.' }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Bağımlılıklar yüklenemedi.' }
dart run build_runner build
if ($LASTEXITCODE -ne 0) { throw 'AutoRoute sınıfları üretilemedi.' }
Write-Host 'Hazır. flutter run komutuyla başlatabilirsiniz.'
