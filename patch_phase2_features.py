"""
Patch index.html with Phase 2 Features:
1. Native Android MediaStore Scanner Bridge (scan real phone videos & songs)
2. Full SRT / VTT Subtitle File Loader & Live Synchronizer
3. Touch Gesture Controller (Brightness, Volume, Seek, Floating Gesture HUD)
"""

import re

FILE_PATH = r"d:\Projects\BinaHub\index.html"

with open(FILE_PATH, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add Gesture HUD Badge and Subtitle File Input to screen-video-player
gesture_badge_html = """
        <!-- Floating Touch Gesture HUD Badge (BRIGHTNESS / VOLUME / SEEK) -->
        <div id="gesture-hud-badge" class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 pointer-events-none hidden px-4 py-2.5 rounded-lg bg-black/85 backdrop-blur-md border border-primary-cyan text-white flex items-center space-x-2.5 shadow-[0_0_24px_rgba(0,240,255,0.5)] transition-opacity duration-150">
          <span id="gesture-hud-icon" class="material-symbols-outlined text-primary-cyan text-2xl">wb_sunny</span>
          <span id="gesture-hud-text" class="text-sm font-mono font-bold tracking-wide">100%</span>
        </div>
        <!-- Real Subtitle File Input (SRT / VTT / ASS) -->
        <input type="file" id="real-sub-file-input" accept=".srt,.vtt,.txt,.ass" class="hidden" onchange="handleRealSubtitleFile(event)">
"""

if 'id="gesture-hud-badge"' not in content:
    content = content.replace(
        '<!-- Dual Seek Zones (Left 10s / Right 10s)',
        gesture_badge_html + '\n        <!-- Dual Seek Zones (Left 10s / Right 10s)'
    )
    print("[1] Injected gesture-hud-badge and real-sub-file-input.")

# 2. Wire "Load Local .SRT" button to trigger real-sub-file-input
old_load_sub = 'onclick="showToast(\'Loaded external subtitle: Cyberpunk_EP10_Director.srt (SUB-02)\')"'
new_load_sub = 'onclick="document.getElementById(\'real-sub-file-input\').click()"'
if old_load_sub in content:
    content = content.replace(old_load_sub, new_load_sub)
    print("[2] Wired Load Local .SRT button to file picker.")

# 3. Add Javascript Logic for MediaStore Bridge, Subtitles, and Touch Gestures
js_additions = """
    /* =========================================================================
       PHASE 2 ENGINE: REAL DEVICE MEDIA SCANNER, SUBTITLES & TOUCH GESTURES
       ========================================================================= */

    // --- A. Touch Gesture Controller (Brightness, Volume, Seek) ---
    let gestureTouchStartX = 0;
    let gestureTouchStartY = 0;
    let gestureTouchStartTime = 0;
    let gestureActiveMode = null; // 'brightness' | 'volume' | 'seek'
    let gestureInitialBrightness = 1.0;
    let gestureInitialVolume = 1.0;
    let gestureInitialSec = 0;
    let gestureHudTimer = null;
    let currentVideoBrightness = 1.0;

    function showGestureHUD(iconName, labelText) {
      const badge = document.getElementById('gesture-hud-badge');
      const icon = document.getElementById('gesture-hud-icon');
      const text = document.getElementById('gesture-hud-text');
      if (!badge || !icon || !text) return;
      icon.innerText = iconName;
      text.innerText = labelText;
      badge.classList.remove('hidden');
      badge.style.opacity = '1';
      clearTimeout(gestureHudTimer);
      gestureHudTimer = setTimeout(() => {
        badge.style.opacity = '0';
        setTimeout(() => badge.classList.add('hidden'), 150);
      }, 900);
    }

    function initPlayerTouchGestures() {
      const canvasArea = document.getElementById('video-player-canvas-area');
      const videoElem = document.getElementById('native-video-elem');
      if (!canvasArea) return;

      canvasArea.addEventListener('touchstart', (e) => {
        if (e.touches.length !== 1) return;
        const t = e.touches[0];
        gestureTouchStartX = t.clientX;
        gestureTouchStartY = t.clientY;
        gestureTouchStartTime = Date.now();
        gestureActiveMode = null;
        gestureInitialBrightness = currentVideoBrightness;
        gestureInitialVolume = videoElem ? videoElem.volume : 1.0;
        gestureInitialSec = (videoElem && !isNaN(videoElem.currentTime)) ? videoElem.currentTime : videoSec;
      }, { passive: true });

      canvasArea.addEventListener('touchmove', (e) => {
        if (e.touches.length !== 1) return;
        const t = e.touches[0];
        const deltaX = t.clientX - gestureTouchStartX;
        const deltaY = t.clientY - gestureTouchStartY;

        // Threshold check
        if (!gestureActiveMode) {
          if (Math.abs(deltaY) > 12 && Math.abs(deltaY) > Math.abs(deltaX)) {
            // Vertical swipe: Left = Brightness, Right = Volume
            const screenWidth = window.innerWidth || 412;
            gestureActiveMode = (gestureTouchStartX < screenWidth / 2) ? 'brightness' : 'volume';
          } else if (Math.abs(deltaX) > 20) {
            // Horizontal swipe: Seek
            gestureActiveMode = 'seek';
          }
        }

        if (gestureActiveMode === 'brightness') {
          // Adjust brightness from 0.2 to 1.8
          const deltaB = -(deltaY / 220);
          currentVideoBrightness = Math.max(0.2, Math.min(1.8, gestureInitialBrightness + deltaB));
          if (videoElem) {
            videoElem.style.filter = `brightness(${currentVideoBrightness})`;
          }
          const svgFallback = document.getElementById('native-video-svg-fallback');
          if (svgFallback) {
            svgFallback.style.filter = `brightness(${currentVideoBrightness})`;
          }
          const pct = Math.round((currentVideoBrightness / 1.0) * 100);
          showGestureHUD('wb_sunny', `Brightness: ${pct}%`);
        } else if (gestureActiveMode === 'volume') {
          // Adjust volume from 0.0 to 1.0
          const deltaV = -(deltaY / 220);
          const newVol = Math.max(0, Math.min(1.0, gestureInitialVolume + deltaV));
          if (videoElem) {
            videoElem.volume = newVol;
          }
          const volPct = Math.round(newVol * 100);
          const icon = (volPct > 50) ? 'volume_up' : ((volPct > 0) ? 'volume_down' : 'volume_mute');
          showGestureHUD(icon, `Volume: ${volPct}%`);
        } else if (gestureActiveMode === 'seek') {
          // Seek scrub: 1px = ~0.2s
          const seekOffset = Math.round(deltaX * 0.2);
          const targetSec = Math.max(0, Math.min(videoTotalSec || 300, gestureInitialSec + seekOffset));
          const m = String(Math.floor(targetSec / 60)).padStart(2, '0');
          const s = String(Math.floor(targetSec % 60)).padStart(2, '0');
          const sign = seekOffset >= 0 ? '+' : '';
          showGestureHUD(seekOffset >= 0 ? 'fast_forward' : 'fast_rewind', `Seek: ${m}:${s} (${sign}${seekOffset}s)`);
        }
      }, { passive: true });

      canvasArea.addEventListener('touchend', (e) => {
        if (gestureActiveMode === 'seek') {
          const t = e.changedTouches[0];
          const deltaX = t.clientX - gestureTouchStartX;
          const seekOffset = Math.round(deltaX * 0.2);
          const targetSec = Math.max(0, Math.min(videoTotalSec || 300, gestureInitialSec + seekOffset));
          seekToSec(targetSec);
          if (videoElem) videoElem.currentTime = targetSec;
        }
        gestureActiveMode = null;
      }, { passive: true });
    }

    // --- B. Real Subtitle File Loader & Parser (SRT / VTT) ---
    function handleRealSubtitleFile(event) {
      const file = event.target.files && event.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = function(e) {
        const raw = e.target.result;
        parseAndApplySubtitleText(raw, file.name);
      };
      reader.readAsText(file);
    }

    function parseAndApplySubtitleText(rawText, filename) {
      const srtPattern = /(?:(\d+)\s*\r?\n)?(\d{2}:\d{2}:\d{2}[,\.]\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}[,\.]\d{3})\s*\r?\n([\s\S]*?)(?=\r?\n\s*\d+\s*\r?\n|\r?\n*$)/g;
      function parseTs(ts) {
        ts = ts.replace(',', '.');
        const parts = ts.split(':');
        return parseFloat(parts[0]) * 3600 + parseFloat(parts[1]) * 60 + parseFloat(parts[2]);
      }
      const parsedCues = [];
      let match;
      while ((match = srtPattern.exec(rawText + '\\n\\n')) !== null) {
        const start = parseTs(match[2]);
        const end = parseTs(match[3]);
        const cueText = match[4].trim().replace(/\\r?\\n/g, ' ').replace(/<[^>]+>/g, '');
        if (cueText) parsedCues.push({ start, end, text: cueText });
      }

      if (parsedCues.length > 0) {
        subtitleTracks['custom'] = parsedCues;
        currentSubTrack = 'custom';
        const trackList = document.getElementById('subtitle-tracks-list');
        if (trackList) {
          const customEl = document.createElement('div');
          customEl.onclick = function() { selectSubtitleTrack('custom', customEl); };
          customEl.className = 'p-2 bg-surface-carbon border border-primary-cyan rounded text-xs flex justify-between cursor-pointer mb-1';
          customEl.innerHTML = `<span class="text-white truncate max-w-[190px]">${filename}</span><span class="text-primary-cyan font-mono text-[10px]">LOADED (${parsedCues.length} cues)</span>`;
          trackList.prepend(customEl);
        }
        updateLiveSubtitleCue(videoSec);
        showToast(`Loaded ${parsedCues.length} subtitle cues from ${filename}`);
      } else {
        showToast('Could not parse subtitle timestamps');
      }
    }

    // --- C. Real Native Android MediaStore Scanner Bridge ---
    let realDeviceVideos = [];
    let realDeviceAudios = [];

    function scanRealDeviceStorage() {
      if (!window.BinaMediaBridge) {
        console.log('BinaMediaBridge not available (Running in browser mode). Running simulated scan.');
        startSimulatedScan();
        return;
      }

      const hasPerm = window.BinaMediaBridge.checkPermissions();
      if (!hasPerm) {
        showToast('Requesting Android storage permissions...');
        window.BinaMediaBridge.requestPermissions();
        window.onStoragePermissionsResult = function(granted) {
          if (granted) {
            executeDeviceStorageScan();
          } else {
            showToast('Storage permission denied by user.');
          }
        };
        return;
      }

      executeDeviceStorageScan();
    }

    function executeDeviceStorageScan() {
      document.getElementById('scan-modal-title').innerText = 'Scanning Device Storage via MediaStore';
      document.getElementById('scan-spinner-icon').classList.add('animate-spin');
      document.getElementById('scan-current-dir').innerText = 'Querying Android MediaStore (Video & Audio)...';
      document.getElementById('scan-pct-label').innerText = '40%';
      document.getElementById('scan-progress-bar').style.width = '40%';

      setTimeout(() => {
        try {
          const rawVids = window.BinaMediaBridge.getDeviceVideos();
          const rawAuds = window.BinaMediaBridge.getDeviceAudios();
          realDeviceVideos = JSON.parse(rawVids || '[]');
          realDeviceAudios = JSON.parse(rawAuds || '[]');

          document.getElementById('scan-count-videos').innerText = '+' + realDeviceVideos.length;
          document.getElementById('scan-count-audio').innerText = '+' + realDeviceAudios.length;
          document.getElementById('scan-count-files').innerText = realDeviceVideos.length + realDeviceAudios.length;
          document.getElementById('scan-pct-label').innerText = '100%';
          document.getElementById('scan-progress-bar').style.width = '100%';
          document.getElementById('scan-current-dir').innerText = `Scan complete: ${realDeviceVideos.length} videos, ${realDeviceAudios.length} songs found.`;
          document.getElementById('scan-spinner-icon').classList.remove('animate-spin');
          document.getElementById('scan-done-btn').innerText = 'Done';
          document.getElementById('scan-done-btn').className = 'w-full py-2 rounded bg-primary-cyan text-black font-bold text-xs uppercase font-mono';

          // Inject into Video Library
          if (realDeviceVideos.length > 0) {
            populateDeviceVideos(realDeviceVideos);
          }
          if (realDeviceAudios.length > 0) {
            populateDeviceAudios(realDeviceAudios);
          }

          showToast(`Discovered ${realDeviceVideos.length} videos & ${realDeviceAudios.length} songs on your device!`);
        } catch (e) {
          console.error('Error parsing device media', e);
          showToast('Error querying device media: ' + e.message);
        }
      }, 600);
    }

    function populateDeviceVideos(vids) {
      const container = document.getElementById('video-cards-container');
      if (!container) return;

      // Add to playlist array
      vids.forEach(v => {
        videoPlaylist.unshift({
          title: v.fileName,
          totalTime: v.durationFormatted,
          totalSec: v.durationSec,
          res: v.resolution,
          codec: 'Hardware Native',
          size: v.sizeFormatted,
          url: v.src,
          isDevice: true
        });

        // Create DOM card
        const card = document.createElement('div');
        card.className = 'video-card bg-surface-carbon border border-primary-cyan/60 rounded-xl overflow-hidden cursor-pointer active:border-primary-cyan transition flex flex-col justify-between group hover:border-primary-cyan';
        card.setAttribute('data-resolution', v.tag);
        card.setAttribute('data-title', v.fileName);
        card.onclick = function() {
          launchVideoPlayer(v.fileName, v.durationFormatted, v.resolution, 'Hardware Native', v.sizeFormatted);
        };

        card.innerHTML = `
          <div class="relative aspect-video flex items-center justify-center overflow-hidden bg-black/90">
            <div class="flex flex-col items-center justify-center text-primary-cyan">
              <span class="material-symbols-outlined text-3xl group-hover:scale-110 transition">movie</span>
              <span class="text-[9px] font-mono mt-1 text-white/80 uppercase tracking-wider">Device Media</span>
            </div>
            <span class="absolute top-1 left-1 px-1.5 py-0.5 rounded text-[9px] font-mono bg-primary-cyan text-black font-bold z-10">${v.tag}</span>
            <span class="absolute bottom-1 right-1 px-1 py-0.5 rounded text-[9px] font-mono bg-black/80 text-white z-10 font-medium">${v.durationFormatted}</span>
          </div>
          <div class="p-2.5 flex-1 flex flex-col justify-between">
            <p class="text-xs font-semibold text-white line-clamp-2">${v.title}</p>
            <div class="mt-2 flex items-center justify-between">
              <span class="text-[9px] font-mono px-1.5 py-0.5 rounded bg-surface-carbon-raised border border-primary-cyan/40 text-primary-cyan font-semibold">PHONE STORAGE</span>
              <span class="text-[10px] font-mono text-text-muted">${v.sizeFormatted}</span>
            </div>
          </div>
        `;

        container.prepend(card);
      });
    }

    function populateDeviceAudios(auds) {
      const audioList = document.getElementById('audio-tracks-list') || document.querySelector('#screen-audio-library .space-y-1\\.5');
      if (!audioList) return;

      auds.forEach(a => {
        const item = document.createElement('div');
        item.className = 'p-2.5 rounded bg-surface-carbon border border-border-structural hover:border-secondary-violet flex items-center justify-between cursor-pointer group transition';
        item.onclick = function() {
          openFullAudioPlayer(a.title, a.artist, 'Audio', a.durationFormatted, a.src, '');
        };
        item.innerHTML = `
          <div class="flex items-center space-x-3 min-w-0 flex-1">
            <div class="w-10 h-10 rounded bg-secondary-violet/20 border border-secondary-violet/50 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-secondary-violet text-lg">audiotrack</span>
            </div>
            <div class="min-w-0 flex-1">
              <p class="text-xs font-semibold text-white truncate">${a.title}</p>
              <p class="text-[10px] font-mono text-text-secondary truncate mt-0.5">${a.artist} • ${a.album}</p>
            </div>
          </div>
          <div class="text-right shrink-0 ml-2">
            <span class="text-[10px] font-mono text-text-muted">${a.durationFormatted}</span>
            <span class="block text-[8px] font-mono text-secondary-violet font-bold">LOCAL</span>
          </div>
        `;
        audioList.prepend(item);
      });
    }

    // Auto-hook Phase 2 systems on DOM ready
    window.addEventListener('DOMContentLoaded', () => {
      initPlayerTouchGestures();
      // If running inside Android WebView with bridge, trigger initial scan check
      if (window.BinaMediaBridge && window.BinaMediaBridge.checkPermissions()) {
        setTimeout(executeDeviceStorageScan, 500);
      }
    });
"""

if 'PHASE 2 ENGINE: REAL DEVICE MEDIA SCANNER' not in content:
    content = content.replace(
        '</script>\n</body>',
        js_additions + '\n  </script>\n</body>'
    )
    print("[3] Injected Phase 2 JavaScript engine.")

# 4. In Video Library header, connect rescan button to scanRealDeviceStorage()
content = content.replace(
    "openModal('scan-progress-modal'); startSimulatedScan()",
    "openModal('scan-progress-modal'); scanRealDeviceStorage()"
)
print("[4] Connected Library rescan button to scanRealDeviceStorage().")

with open(FILE_PATH, "w", encoding="utf-8") as f:
    f.write(content)

print("[Success] All Phase 2 enhancements patched into index.html successfully!")
