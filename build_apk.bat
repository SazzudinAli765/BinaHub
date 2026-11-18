@echo off
setlocal
echo ===================================================
echo [BinaHub] Building Signed Release APK on D: Drive
echo Owner: SazzudinAli (Protection Active)
echo ===================================================

set "JAVA_HOME=D:\Projects\BinaHub\tools\jdk-17"
set "ANDROID_HOME=D:\Projects\BinaHub\tools\android-sdk"
set "ANDROID_SDK_ROOT=D:\Projects\BinaHub\tools\android-sdk"
set "GRADLE_USER_HOME=D:\Projects\BinaHub\.gradle"
set "ANDROID_USER_HOME=D:\Projects\BinaHub\.android"
set "PATH=D:\Projects\BinaHub\tools\jdk-17\bin;D:\Projects\BinaHub\tools\gradle-8.4\bin;D:\Projects\BinaHub\tools\android-sdk\cmdline-tools\latest\bin;D:\Projects\BinaHub\tools\android-sdk\build-tools\34.0.0;D:\Projects\BinaHub\tools\android-sdk\platform-tools;%PATH%"

cd /d "D:\Projects\BinaHub\android"
echo Running Gradle assembleRelease...
call "D:\Projects\BinaHub\tools\gradle-8.4\bin\gradle.bat" assembleRelease --stacktrace

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo [SUCCESS] Signed Release APK built successfully!
    echo Output: D:\Projects\BinaHub\android\app\build\outputs\apk\release\app-release.apk
    copy /y "D:\Projects\BinaHub\android\app\build\outputs\apk\release\app-release.apk" "D:\Projects\BinaHub\BinaHub-v1.0.apk"
    echo Local APK updated: D:\Projects\BinaHub\BinaHub-v1.0.apk
    echo.
    echo Verifying APK signature under SazzudinAli...
    call "D:\Projects\BinaHub\tools\android-sdk\build-tools\34.0.0\apksigner.bat" verify --verbose "D:\Projects\BinaHub\BinaHub-v1.0.apk"
    echo ===================================================
) else (
    echo.
    echo [ERROR] Gradle build failed with exit code %ERRORLEVEL%
)
