@echo off
setlocal
echo ===================================================
echo [BinaHub] Building Android APK Locally on D: Drive
echo ===================================================

set "JAVA_HOME=D:\Projects\BinaHub\tools\jdk-17"
set "ANDROID_HOME=D:\Projects\BinaHub\tools\android-sdk"
set "ANDROID_SDK_ROOT=D:\Projects\BinaHub\tools\android-sdk"
set "GRADLE_USER_HOME=D:\Projects\BinaHub\.gradle"
set "ANDROID_USER_HOME=D:\Projects\BinaHub\.android"
set "PATH=D:\Projects\BinaHub\tools\jdk-17\bin;D:\Projects\BinaHub\tools\gradle-8.4\bin;D:\Projects\BinaHub\tools\android-sdk\cmdline-tools\latest\bin;D:\Projects\BinaHub\tools\android-sdk\platform-tools;%PATH%"

cd /d "D:\Projects\BinaHub\android"
echo Running Gradle assembleDebug...
call "D:\Projects\BinaHub\tools\gradle-8.4\bin\gradle.bat" assembleDebug --stacktrace
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo [SUCCESS] APK built successfully!
    echo Output: D:\Projects\BinaHub\android\app\build\outputs\apk\debug\app-debug.apk
    copy /y "D:\Projects\BinaHub\android\app\build\outputs\apk\debug\app-debug.apk" "D:\Projects\BinaHub\BinaHub-v1.0.apk"
    echo Local APK updated: D:\Projects\BinaHub\BinaHub-v1.0.apk
    echo ===================================================
) else (
    echo.
    echo [ERROR] Gradle build failed with exit code %ERRORLEVEL%
)
