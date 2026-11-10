# BinaHub 1-Click Local APK Builder (D: Drive Storage Only)
$ErrorActionPreference = "Stop"
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "[BinaHub] Building Android APK Locally on D: Drive" -ForegroundColor Cyan
Write-Host "Zero C: drive usage. Everything configured on D:" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan

$env:JAVA_HOME = "D:\Projects\BinaHub\tools\jdk-17"
$env:ANDROID_HOME = "D:\Projects\BinaHub\tools\android-sdk"
$env:ANDROID_SDK_ROOT = "D:\Projects\BinaHub\tools\android-sdk"
$env:GRADLE_USER_HOME = "D:\Projects\BinaHub\.gradle"
$env:ANDROID_USER_HOME = "D:\Projects\BinaHub\.android"
$env:PATH = "D:\Projects\BinaHub\tools\jdk-17\bin;D:\Projects\BinaHub\tools\gradle-8.4\bin;D:\Projects\BinaHub\tools\android-sdk\cmdline-tools\latest\bin;D:\Projects\BinaHub\tools\android-sdk\platform-tools;" + $env:PATH

Set-Location "D:\Projects\BinaHub\android"
Write-Host "Running Gradle assembleDebug..." -ForegroundColor Yellow
& "D:\Projects\BinaHub\tools\gradle-8.4\bin\gradle.bat" assembleDebug --stacktrace

if ($LASTEXITCODE -eq 0) {
    $sourceApk = "D:\Projects\BinaHub\android\app\build\outputs\apk\debug\app-debug.apk"
    $destApk = "D:\Projects\BinaHub\BinaHub-v1.0.apk"
    Copy-Item -Path $sourceApk -Destination $destApk -Force
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "[SUCCESS] APK built and ready at: $destApk" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Build failed with code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
