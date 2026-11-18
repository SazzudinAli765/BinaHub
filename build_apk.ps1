# BinaHub 1-Click Local Release APK Builder (D: Drive Storage Only)
# Signed under SazzudinAli with Minor Integrity Protection
$ErrorActionPreference = "Stop"
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "[BinaHub] Building Signed Release APK on D: Drive" -ForegroundColor Cyan
Write-Host "Owner: SazzudinAli (Protection Active)" -ForegroundColor Green
Write-Host "Zero C: drive usage. Everything configured on D:" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan

$env:JAVA_HOME = "D:\Projects\BinaHub\tools\jdk-17"
$env:ANDROID_HOME = "D:\Projects\BinaHub\tools\android-sdk"
$env:ANDROID_SDK_ROOT = "D:\Projects\BinaHub\tools\android-sdk"
$env:GRADLE_USER_HOME = "D:\Projects\BinaHub\.gradle"
$env:ANDROID_USER_HOME = "D:\Projects\BinaHub\.android"
$env:PATH = "D:\Projects\BinaHub\tools\jdk-17\bin;D:\Projects\BinaHub\tools\gradle-8.4\bin;D:\Projects\BinaHub\tools\android-sdk\cmdline-tools\latest\bin;D:\Projects\BinaHub\tools\android-sdk\build-tools\34.0.0;D:\Projects\BinaHub\tools\android-sdk\platform-tools;" + $env:PATH

Set-Location "D:\Projects\BinaHub\android"
Write-Host "Running Gradle assembleRelease..." -ForegroundColor Yellow
& "D:\Projects\BinaHub\tools\gradle-8.4\bin\gradle.bat" assembleRelease --stacktrace

if ($LASTEXITCODE -eq 0) {
    $sourceApk = "D:\Projects\BinaHub\android\app\build\outputs\apk\release\app-release.apk"
    $destApk = "D:\Projects\BinaHub\BinaHub-v1.0.apk"
    Copy-Item -Path $sourceApk -Destination $destApk -Force
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "[SUCCESS] Signed Release APK built and ready at: $destApk" -ForegroundColor Green
    Write-Host "Verifying signature under SazzudinAli..." -ForegroundColor Yellow
    & "D:\Projects\BinaHub\tools\android-sdk\build-tools\34.0.0\apksigner.bat" verify --verbose $destApk
    Write-Host "===================================================" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Build failed with code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
