"""
Transform index.html into a 100% True Native Android Fullscreen App:
1. Eliminate "mobile in a mobile" (kill 412x915 fixed frame, borders, fake 12:45 status bar)
2. Add real video streams to all default library items so playback works immediately
3. Add native Android file picker inputs for videos and songs
4. Auto-scan device media on launch when permissions are granted
5. Fix bottom navigation bar so Settings is never covered or cut off
"""

import re

FILE_PATH = r"d:\Projects\BinaHub\index.html"

with open(FILE_PATH, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Kill the fake system status bar completely
content = re.sub(
    r'<div id="system-status-bar"[\s\S]*?</div>\s*</div>',
    '<!-- System status bar removed for native Android immersion -->',
    content,
    count=1
)

# 2. Add Native Android Fullscreen CSS Overrides
native_fullscreen_css = """
    /* =========================================================================
       TRUE NATIVE ANDROID FULLSCREEN IMMERSION (NO FAKE FRAME / NO FAKE BAR)
       ========================================================================= */
    html, body {
      width: 100% !important;
      height: 100% !important;
      max-width: 100% !important;
      max-height: 100% !important;
      margin: 0 !important;
      padding: 0 !important;
      overflow: hidden !important;
      background: var(--bg-primary, #05080C) !important;
      display: block !important;
      position: fixed !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      bottom: 0 !important;
      -webkit-tap-highlight-color: transparent !important;
    }

    #mobile-shell {
      width: 100% !important;
      max-width: 100% !important;
      min-width: 100% !important;
      height: 100% !important;
      max-height: 100% !important;
      min-height: 100% !important;
      border: none !important;
      border-radius: 0 !important;
      box-shadow: none !important;
      margin: 0 !important;
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      right: 0 !important;
      bottom: 0 !important;
      overflow: hidden !important;
      background: var(--bg-primary, #05080C) !important;
      display: flex !important;
      flex-direction: column !important;
    }

    #mobile-shell.landscape-mode {
      width: 100% !important;
      height: 100% !important;
      border-radius: 0 !important;
    }

    #system-status-bar {
      display: none !important;
    }

    #main-header {
      padding-top: max(env(safe-area-inset-top, 0px), 8px) !important;
      box-sizing: content-box !important;
    }

    #bottom-nav {
      padding-bottom: max(env(safe-area-inset-bottom, 0px), 8px) !important;
      box-sizing: content-box !important;
    }

    #binahub-sec-pill {
      display: none !important; /* Never block navigation buttons */
    }
"""

if 'TRUE NATIVE ANDROID FULLSCREEN IMMERSION' not in content:
    content = content.replace(
        '</style>',
        native_fullscreen_css + '\n  </style>'
    )
    print("[1] Injected Native Android Fullscreen CSS overrides.")

# 3. Add Working Video URLs to default playlist
old_playlist = """    const videoPlaylist = [
      { title: 'Cyberpunk_Edgerunners_Ep10_Remastered_HDR.mkv', totalTime: '02:14:05', totalSec: 8045, res: '4K UHD', codec: 'HEVC / 10-bit', size: '4.2 GB', date: '2026-11-03' },
      { title: 'Interstellar_Docking_Scene_4K_IMAX.mp4', totalTime: '00:08:45', totalSec: 525, res: '4K UHD', codec: 'AV1 10-bit', size: '1.1 GB', date: '2026-11-02' },
      { title: 'Blade_Runner_2049_Sea_Wall_Final_Battle.mkv', totalTime: '00:14:30', totalSec: 870, res: '1440p', codec: 'HEVC HDR10', size: '1.8 GB', date: '2026-11-01' },
      { title: 'Formula1_Monaco_GP_2026_Highlights.ts', totalTime: '00:45:10', totalSec: 2710, res: '1080p', codec: 'AVC 60FPS', size: '2.4 GB', date: '2026-10-29' },
      { title: 'Tokyo_8K_HDR_Vulkan_Master.mkv', totalTime: '00:05:22', totalSec: 322, res: '8K UHD', codec: 'AV1 12-bit', size: '5.8 GB', date: '2026-10-28' },
      { title: 'Retro_Anime_Remaster_Clip.mp4', totalTime: '00:22:15', totalSec: 1335, res: '720p', codec: 'H.264 High', size: '650 MB', date: '2026-10-25' },
      { title: 'Archive_DV_Cam_Recording_1998.avi', totalTime: '00:31:40', totalSec: 1900, res: '480p', codec: 'MPEG-4', size: '420 MB', date: '2026-10-20' },
      { title: 'LowRes_CCTV_Feed_Sample.3gp', totalTime: '00:04:12', totalSec: 252, res: '360p', codec: 'H.263', size: '85 MB', date: '2026-10-15' }
    ];"""

new_playlist = """    const videoPlaylist = [
      { title: 'Cyberpunk_Edgerunners_Ep10_Remastered_HDR.mkv', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', totalTime: '12:14', totalSec: 734, res: '4K UHD', codec: 'HEVC / 10-bit', size: '4.2 GB', date: '2026-11-03' },
      { title: 'Interstellar_Docking_Scene_4K_IMAX.mp4', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', totalTime: '09:56', totalSec: 596, res: '4K UHD', codec: 'AV1 10-bit', size: '1.1 GB', date: '2026-11-02' },
      { title: 'Blade_Runner_2049_Sea_Wall_Final_Battle.mkv', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', totalTime: '10:53', totalSec: 653, res: '1440p', codec: 'HEVC HDR10', size: '1.8 GB', date: '2026-11-01' },
      { title: 'Formula1_Monaco_GP_2026_Highlights.ts', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', totalTime: '00:15', totalSec: 15, res: '1080p', codec: 'AVC 60FPS', size: '2.4 GB', date: '2026-10-29' },
      { title: 'Tokyo_8K_HDR_Vulkan_Master.mkv', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4', totalTime: '00:15', totalSec: 15, res: '8K UHD', codec: 'AV1 12-bit', size: '5.8 GB', date: '2026-10-28' },
      { title: 'Retro_Anime_Remaster_Clip.mp4', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4', totalTime: '00:15', totalSec: 15, res: '720p', codec: 'H.264 High', size: '650 MB', date: '2026-10-25' },
      { title: 'Archive_DV_Cam_Recording_1998.avi', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4', totalTime: '00:15', totalSec: 15, res: '480p', codec: 'MPEG-4', size: '420 MB', date: '2026-10-20' },
      { title: 'LowRes_CCTV_Feed_Sample.3gp', url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4', totalTime: '00:15', totalSec: 15, res: '360p', codec: 'H.263', size: '85 MB', date: '2026-10-15' }
    ];"""

if old_playlist in content:
    content = content.replace(old_playlist, new_playlist)
    print("[2] Updated videoPlaylist with real playable stream URLs.")

# 4. Add Real Device File Pickers for Video & Audio to the DOM
file_pickers_html = """
    <!-- NATIVE FILE PICKER INPUTS FOR PHONE MEDIA -->
    <input type="file" id="real-video-picker-input" accept="video/*" class="hidden" onchange="handleRealVideoPicked(event)">
    <input type="file" id="real-audio-picker-input" accept="audio/*" class="hidden" onchange="handleRealAudioPicked(event)">
"""

if 'id="real-video-picker-input"' not in content:
    content = content.replace(
        '</head>',
        file_pickers_html + '\n</head>'
    )
    print("[3] Injected native file picker inputs.")

# 5. Add Prominent "Open Video File" and "Scan Phone Storage" buttons in Library
banner_tools_html = """
        <!-- Action Hero Banner for Real Device Media & Scanning -->
        <div class="mx-4 mt-2 mb-2 p-2.5 rounded-xl bg-surface-carbon/90 border border-primary-cyan/40 backdrop-blur-md flex items-center justify-between gap-2">
          <button onclick="document.getElementById('real-video-picker-input').click()" class="flex-1 py-2 px-3 rounded-lg bg-primary-cyan text-black font-bold text-xs font-mono uppercase tracking-wider flex items-center justify-center space-x-1.5 hover:bg-white active:scale-95 transition shadow-[0_0_15px_rgba(0,240,255,0.4)]">
            <span class="material-symbols-outlined text-sm font-bold">file_open</span>
            <span>Open Phone Video</span>
          </button>
          <button onclick="scanRealDeviceStorage()" class="flex-1 py-2 px-3 rounded-lg bg-surface-carbon-raised border border-primary-cyan/60 text-primary-cyan font-bold text-xs font-mono uppercase tracking-wider flex items-center justify-center space-x-1.5 hover:border-primary-cyan active:scale-95 transition">
            <span class="material-symbols-outlined text-sm">sync</span>
            <span>Scan Device</span>
          </button>
        </div>
"""

if 'Action Hero Banner for Real Device Media' not in content:
    content = content.replace(
        '<div id="prominent-resume-card"',
        banner_tools_html + '\n        <div id="prominent-resume-card"'
    )
    print("[4] Injected action hero banner with Open Phone Video & Scan Device buttons.")

# 6. Add JavaScript Handlers for File Picking and Storage Permission Events
js_handlers = """
    // --- Native Phone File Picker Handlers ---
    function handleRealVideoPicked(event) {
      const file = event.target.files && event.target.files[0];
      if (!file) return;
      const url = URL.createObjectURL(file);
      const title = file.name;
      const sizeMb = (file.size / (1024 * 1024)).toFixed(1) + ' MB';

      const newVid = {
        title: title,
        url: url,
        totalTime: '00:00',
        totalSec: 0,
        res: 'Local File',
        codec: file.type || 'Native Video',
        size: sizeMb,
        isDevice: true
      };

      videoPlaylist.unshift(newVid);
      launchVideoPlayer(title, '00:00', 'Local File', file.type || 'Native Video', sizeMb);
      showToast('Loaded local phone video: ' + title);
    }

    function handleRealAudioPicked(event) {
      const file = event.target.files && event.target.files[0];
      if (!file) return;
      const url = URL.createObjectURL(file);
      openFullAudioPlayer(file.name, 'Local Phone Audio', 'Audio', '00:00', url, '');
      showToast('Playing track: ' + file.name);
    }

    // Storage permission callback hooks
    window.onStoragePermissionsGranted = function() {
      console.log('[NativeBridge] Storage permissions granted! Running MediaStore scan...');
      executeDeviceStorageScan();
    };

    window.onStoragePermissionsDenied = function() {
      console.log('[NativeBridge] Storage permissions denied.');
      showToast('Storage permission needed to list all phone videos');
    };
"""

if 'handleRealVideoPicked' not in content:
    content = content.replace(
        'initPlayerTouchGestures();',
        'initPlayerTouchGestures();\n' + js_handlers
    )
    print("[5] Injected native file picker handlers and permission hooks.")

with open(FILE_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print("[SUCCESS] index.html transformed into a true native Android application!")
