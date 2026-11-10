r"""
Setup Local Android SDK and Build Environment entirely on D: Drive
Location: D:\Projects\BinaHub\tools
Zero bytes written to C: drive.
"""
import os
import sys
import shutil
import zipfile
import subprocess
import urllib.request
import time

BASE_DIR = r"D:\Projects\BinaHub"
TOOLS_DIR = os.path.join(BASE_DIR, "tools")
DOWNLOADS_DIR = os.path.join(TOOLS_DIR, ".downloads")
JDK_DIR = os.path.join(TOOLS_DIR, "jdk-17")
GRADLE_DIR = os.path.join(TOOLS_DIR, "gradle-8.4")
SDK_DIR = os.path.join(TOOLS_DIR, "android-sdk")
GRADLE_USER_HOME = os.path.join(BASE_DIR, ".gradle")
ANDROID_USER_HOME = os.path.join(BASE_DIR, ".android")

os.makedirs(TOOLS_DIR, exist_ok=True)
os.makedirs(DOWNLOADS_DIR, exist_ok=True)
os.makedirs(GRADLE_USER_HOME, exist_ok=True)
os.makedirs(ANDROID_USER_HOME, exist_ok=True)

URLS = {
    "jdk": "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk",
    "cmdline_tools": "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip",
    "gradle": "https://services.gradle.org/distributions/gradle-8.4-bin.zip"
}

def safe_rmtree(path, retries=5, delay=1.0):
    for i in range(retries):
        try:
            if os.path.exists(path):
                shutil.rmtree(path)
            return
        except Exception as e:
            if i == retries - 1:
                print(f"[Warning] Could not remove {path}: {e}")
            time.sleep(delay)

def download_file(url, dest_path, label):
    if os.path.exists(dest_path) and os.path.getsize(dest_path) > 10 * 1024 * 1024:
        print(f"[{label}] Already downloaded ({os.path.getsize(dest_path)/(1024*1024):.1f} MB). Skipping.")
        return dest_path

    print(f"[{label}] Downloading from {url}...")
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
    temp_path = dest_path + ".tmp"
    
    start_time = time.time()
    with urllib.request.urlopen(req) as resp, open(temp_path, "wb") as out_file:
        total_size = int(resp.headers.get("Content-Length", 0))
        downloaded = 0
        last_print = 0
        while True:
            chunk = resp.read(1024 * 512)
            if not chunk:
                break
            out_file.write(chunk)
            downloaded += len(chunk)
            if time.time() - last_print > 3:
                last_print = time.time()
                pct = (downloaded / total_size * 100) if total_size else 0
                mb = downloaded / (1024 * 1024)
                print(f"[{label}] Progress: {mb:.1f} MB ({pct:.1f}%)")

    os.replace(temp_path, dest_path)
    elapsed = time.time() - start_time
    print(f"[{label}] Download completed in {elapsed:.1f}s ({os.path.getsize(dest_path)/(1024*1024):.1f} MB).")
    return dest_path

def setup_jdk():
    java_exe = os.path.join(JDK_DIR, "bin", "java.exe")
    if os.path.exists(java_exe):
        print(f"[JDK 17] Already installed and verified at {java_exe}.")
        return
    dest_zip = os.path.join(DOWNLOADS_DIR, "jdk17.zip")
    download_file(URLS["jdk"], dest_zip, "JDK 17")
    temp_extract = os.path.join(TOOLS_DIR, "_jdk_temp")
    safe_rmtree(temp_extract)
    os.makedirs(temp_extract, exist_ok=True)
    with zipfile.ZipFile(dest_zip, "r") as z:
        z.extractall(temp_extract)
    subdirs = [os.path.join(temp_extract, d) for d in os.listdir(temp_extract) if os.path.isdir(os.path.join(temp_extract, d))]
    extracted_root = subdirs[0] if subdirs else temp_extract
    safe_rmtree(JDK_DIR)
    shutil.move(extracted_root, JDK_DIR)
    safe_rmtree(temp_extract)
    print(f"[JDK 17] Installed to {JDK_DIR}.")

def setup_gradle():
    gradle_bat = os.path.join(GRADLE_DIR, "bin", "gradle.bat")
    if os.path.exists(gradle_bat):
        print(f"[Gradle 8.4] Already installed at {gradle_bat}.")
        return
    dest_zip = os.path.join(DOWNLOADS_DIR, "gradle84.zip")
    download_file(URLS["gradle"], dest_zip, "Gradle 8.4")
    # Gradle zip has top level folder 'gradle-8.4'
    print(f"[Gradle 8.4] Extracting {dest_zip} directly to {TOOLS_DIR}...")
    with zipfile.ZipFile(dest_zip, "r") as z:
        z.extractall(TOOLS_DIR)
    print(f"[Gradle 8.4] Installed to {GRADLE_DIR}.")

def setup_android_sdk():
    latest_bin = os.path.join(SDK_DIR, "cmdline-tools", "latest", "bin")
    sdkmanager_bat = os.path.join(latest_bin, "sdkmanager.bat")
    
    if not os.path.exists(sdkmanager_bat):
        dest_zip = os.path.join(DOWNLOADS_DIR, "cmdline_tools.zip")
        download_file(URLS["cmdline_tools"], dest_zip, "Android Cmdline-Tools")
        
        target_latest = os.path.join(SDK_DIR, "cmdline-tools", "latest")
        os.makedirs(target_latest, exist_ok=True)
        print(f"[Android SDK] Extracting cmdline-tools to {target_latest}...")
        
        with zipfile.ZipFile(dest_zip, "r") as z:
            for member in z.infolist():
                # zip members start with 'cmdline-tools/'
                parts = member.filename.split("/", 1)
                if len(parts) > 1 and parts[1]:
                    rel_path = parts[1]
                    dest_file = os.path.join(target_latest, rel_path.replace("/", os.sep))
                    if member.is_dir():
                        os.makedirs(dest_file, exist_ok=True)
                    else:
                        os.makedirs(os.path.dirname(dest_file), exist_ok=True)
                        with z.open(member) as src, open(dest_file, "wb") as dst:
                            shutil.copyfileobj(src, dst)
        print(f"[Android SDK] Cmdline-Tools extracted to {target_latest}.")

    # Pre-accept licenses
    licenses_dir = os.path.join(SDK_DIR, "licenses")
    os.makedirs(licenses_dir, exist_ok=True)
    with open(os.path.join(licenses_dir, "android-sdk-license"), "w", encoding="utf-8") as f:
        f.write("24333f8a63b6825ea9c5514f83c2829b004d1fee\n8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n")
    with open(os.path.join(licenses_dir, "android-sdk-preview-license"), "w", encoding="utf-8") as f:
        f.write("84831b9409646a918e30573bab4c9c91346d8abd\n")

    # Install platforms;android-34 and build-tools;34.0.0
    platform_dir = os.path.join(SDK_DIR, "platforms", "android-34")
    build_tools_dir = os.path.join(SDK_DIR, "build-tools", "34.0.0")
    if not os.path.exists(platform_dir) or not os.path.exists(build_tools_dir):
        print("[Android SDK] Installing platforms;android-34 and build-tools;34.0.0...")
        env = os.environ.copy()
        env["JAVA_HOME"] = JDK_DIR
        env["ANDROID_HOME"] = SDK_DIR
        env["ANDROID_SDK_ROOT"] = SDK_DIR
        env["ANDROID_USER_HOME"] = ANDROID_USER_HOME
        cmd = [sdkmanager_bat, "--install", "platforms;android-34", "build-tools;34.0.0"]
        p = subprocess.run(cmd, env=env, input="y\ny\ny\n", capture_output=True, text=True)
        print("[sdkmanager output]", p.stdout[-500:] if p.stdout else "")
        if p.returncode != 0:
            print("[sdkmanager error]", p.stderr[-500:] if p.stderr else "")
        else:
            print("[Android SDK] Packages installed successfully.")

def write_build_scripts():
    bat_content = f"""@echo off
setlocal
echo ===================================================
echo [BinaHub] Building Android APK Locally on D: Drive
echo ===================================================

set "JAVA_HOME={JDK_DIR}"
set "ANDROID_HOME={SDK_DIR}"
set "ANDROID_SDK_ROOT={SDK_DIR}"
set "GRADLE_USER_HOME={GRADLE_USER_HOME}"
set "ANDROID_USER_HOME={ANDROID_USER_HOME}"
set "PATH={JDK_DIR}\\bin;{GRADLE_DIR}\\bin;{SDK_DIR}\\cmdline-tools\\latest\\bin;{SDK_DIR}\\platform-tools;%PATH%"

cd /d "{BASE_DIR}\\android"
echo Running Gradle assembleDebug...
call "{GRADLE_DIR}\\bin\\gradle.bat" assembleDebug --stacktrace
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================================
    echo [SUCCESS] APK built successfully!
    echo Output: {BASE_DIR}\\android\\app\\build\\outputs\\apk\\debug\\app-debug.apk
    copy /y "{BASE_DIR}\\android\\app\\build\\outputs\\apk\\debug\\app-debug.apk" "{BASE_DIR}\\BinaHub-v1.0.apk"
    echo Local APK updated: {BASE_DIR}\\BinaHub-v1.0.apk
    echo ===================================================
) else (
    echo.
    echo [ERROR] Gradle build failed with exit code %ERRORLEVEL%
)
"""
    bat_path = os.path.join(BASE_DIR, "build_apk.bat")
    with open(bat_path, "w", encoding="utf-8") as f:
        f.write(bat_content)

    ps1_content = f"""# BinaHub 1-Click Local APK Builder (D: Drive Storage Only)
$ErrorActionPreference = "Stop"
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "[BinaHub] Building Android APK Locally on D: Drive" -ForegroundColor Cyan
Write-Host "Zero C: drive usage. Everything configured on D:" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan

$env:JAVA_HOME = "{JDK_DIR}"
$env:ANDROID_HOME = "{SDK_DIR}"
$env:ANDROID_SDK_ROOT = "{SDK_DIR}"
$env:GRADLE_USER_HOME = "{GRADLE_USER_HOME}"
$env:ANDROID_USER_HOME = "{ANDROID_USER_HOME}"
$env:PATH = "{JDK_DIR}\\bin;{GRADLE_DIR}\\bin;{SDK_DIR}\\cmdline-tools\\latest\\bin;{SDK_DIR}\\platform-tools;" + $env:PATH

Set-Location "{BASE_DIR}\\android"
Write-Host "Running Gradle assembleDebug..." -ForegroundColor Yellow
& "{GRADLE_DIR}\\bin\\gradle.bat" assembleDebug --stacktrace

if ($LASTEXITCODE -eq 0) {{
    $sourceApk = "{BASE_DIR}\\android\\app\\build\\outputs\\apk\\debug\\app-debug.apk"
    $destApk = "{BASE_DIR}\\BinaHub-v1.0.apk"
    Copy-Item -Path $sourceApk -Destination $destApk -Force
    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "[SUCCESS] APK built and ready at: $destApk" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green
}} else {{
    Write-Host "[ERROR] Build failed with code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}}
"""
    ps1_path = os.path.join(BASE_DIR, "build_apk.ps1")
    with open(ps1_path, "w", encoding="utf-8") as f:
        f.write(ps1_content)

    print(f"[Scripts] Created {bat_path} and {ps1_path}.")

if __name__ == "__main__":
    print("=== BinaHub Local Android Toolchain Setup (D: Drive Storage Only) ===")
    setup_jdk()
    setup_gradle()
    setup_android_sdk()
    write_build_scripts()
    print("=== Toolchain setup completed successfully! ===")
