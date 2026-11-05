# BinaHub Standard Video Player — Technical Requirements & System Architecture Specification (Phase 2)

**Document Version:** 1.0.0-PROD  
**Authoritative Baseline:** `Standard_Video_Player_SRS_Complete_v1.0.pdf` (SRS v1.0)  
**Visual & Aesthetic Reference:** Cyber Precision Dark OLED (`#000000`, `#111115`, `#00F0FF`, `#8B5CF6`, `#22C55E`, `#EF4444`, `#F59E0B`)  
**Architecture Paradigms:** Clean Architecture, SOLID Principles, Object-Oriented Programming (OOP), Zero-Breakage Guarantee, Automatic Re-linking

---

## 1. Architectural Foundations & System Topology

The BinaHub Standard Video Player is an enterprise-grade, high-performance media client for Android, engineered with a decoupled two-tier architecture:
1. **Frontend Presentation & Workflow Layer (Flutter / Dart)**: Implements reactive user interfaces, state management, permission orchestrations, background service coordination, and transactional state machines.
2. **Native High-Performance Media Core (Android NDK C++ / Vulkan / MediaCodec / Libavcodec)**: Provides hardware-accelerated decoding, Vulkan compute post-processing (denoising, deblurring, CAS upscaling, sharpening, HDR tone-mapping), zero-copy surface rendering, and RAM-only decrypted playback for protected assets.

```
+---------------------------------------------------------------------------------------------------+
|                                 FLUTTER PRESENTATION & APPLICATION LAYER                          |
|                                                                                                   |
|  [MainNavigationShell] (SRS 6.1: Video | Audio | Tools | Settings) + Header Coin (Earn Placeholder) |
|         |                        |                       |                        |               |
|  [VideoLibraryScreen]    [AudioLibraryScreen]    [ToolsHubScreen]         [SettingsScreen]        |
|  - Grid & Directory      - Hi-Res / FLAC Hub     - Transcoder / Scaler    - 4-Stage Fallback      |
|  - Resume Card (VID-14)  - 10-Band EQ (AUD-07)   - Audio Extractor        - Refresh Rate (VID-19) |
|  - Video Player HUD      - Vinyl Player (AUD-10) - Repair Tool (TOOL-12)  - Theme & Directories   |
|         |                        |                       |                        |               |
|  [VaultAuth & Browser]   [OfflineExpiryManager]  [BackupSupervisor]       [AdminGovernance]       |
|  - PIN & Biometrics      - 30-Day Leases (EXP)   - 5GB Quota & Cloud Sync - 2FA TOTP (ADM-01)     |
|  - VLT-02 6-Step Tx      - Grace Period (EXP-06) - SHA-256 Restore Points - Lockdown (SEC-04)     |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                   Dart FFI / JNI MethodChannel
                                                  |
+---------------------------------------------------------------------------------------------------+
|                                   ANDROID PLATFORM & NDK LAYER                                    |
|                                                                                                   |
|  [MainActivity.kt & BinaMediaService.kt]                                                          |
|  - Foreground Audio Notification & MediaSession                                                    |
|  - WindowManager FLAG_SECURE enforcement (VLT-07, SEC-05)                                         |
|  - BatteryManager & PowerManager thermal telemetry (ENH-09, TOOL-06)                              |
|                                                                                                   |
|  [Native C++ Media Engine (libbina_media_engine.so)]                                              |
|  - 4-Stage Decoder Engine: HW+ (Vulkan/MediaCodec) -> HW -> Hybrid -> SW (FFmpeg/Libavcodec)      |
|  - Vulkan Compute Post-Processing Pipeline (Denoise -> Deblur -> CAS Upscale -> Sharpen -> HDR)  |
|  - Memory-Mapped RAM Decryption Ring Buffer (zero-disk plaintext footprint)                        |
|  - NIST SP 800-88 3-Pass Overwrite File Shredder (0x00 -> 0xFF -> Cryptographic PRNG -> fsync)   |
|  - Android Keystore TEE Integration (AES-256-GCM / 128-bit MAC Tag verification)                  |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Complete Modular File Tree

```
D:\Projects\BinaHub\
├── .claude/
│   └── launch.json                                # Local testbed server launch configuration
├── android/
│   ├── app/
│   │   ├── build.gradle                           # NDK C++ build flags, Vulkan & MediaCodec linking
│   │   └── src/main/
│   │       ├── AndroidManifest.xml                # Permissions, Foreground Service, Storage, FLAG_SECURE
│   │       ├── cpp/
│   │       │   ├── CMakeLists.txt                 # Native build recipe for libbina_media_engine.so
│   │       │   ├── enhancement_pipeline.hpp       # Vulkan compute pipeline, CAS scaler, shader graph
│   │       │   ├── enhancement_pipeline.cpp       # Native C++ processing implementations
│   │       │   ├── media_engine_native.cpp        # Dart FFI exports & JNI interface bridges
│   │       │   └── shredder_native.cpp            # NIST SP 800-88 3-pass cryptographic wipe engine
│   │       └── kotlin/com/binahub/player/
│   │           ├── MainActivity.kt                # FlutterActivity, FLAG_SECURE, Telemetry, AudioFocus
│   │           └── BinaMediaService.kt            # Foreground notification & background playback service
│   ├── build.gradle
│   └── settings.gradle
├── assets/
│   ├── icons/                                     # Custom SVG/PNG interface glyphs
│   └── images/                                    # Placeholder media banners and vinyl artwork
├── lib/
│   ├── main.dart                                  # Application entry point, service bootstrapping, theme
│   ├── core/
│   │   ├── database/
│   │   │   └── app_database.dart                  # SQLite persistent metadata, indexer, transaction records
│   │   ├── engine/
│   │   │   ├── media_engine_adapter.dart          # Pure abstract OOP contract for media backends
│   │   │   ├── decoder_fallback_controller.dart   # HW+ -> HW -> Hybrid -> SW deterministic fallback
│   │   │   ├── enhancement_pipeline.dart          # Dart FFI bindings to C++ enhancement pipeline
│   │   │   └── playback_state.dart                # Observable playback state models & telemetry
│   │   ├── navigation/
│   │   │   └── main_navigation_shell.dart         # Persistent 4-tab bar (Video, Audio, Tools, Settings)
│   │   ├── security/
│   │   │   ├── audit_logger.dart                  # Immutable SHA-256 chained security ledger
│   │   │   ├── keystore_provider.dart             # Android Keystore TEE key generation & wrapping
│   │   │   ├── vault_security_service.dart        # AES-256-GCM stream encryption/decryption
│   │   │   └── vault_transaction_manager.dart     # 6-step atomic move into vault protocol (VLT-02)
│   │   ├── services/
│   │   │   ├── backup_supervisor.dart             # 5GB quota, 70% threshold offloading & cloud sync
│   │   │   ├── drive_service.dart                 # Google Drive OAuth separation & stream provider
│   │   │   └── offline_expiry_manager.dart        # 30-day lease, 5-day grace, extension & purge supervisor
│   │   ├── theme/
│   │   │   ├── cyber_colors.dart                  # Cyber Precision palette definitions
│   │   │   ├── cyber_shapes.dart                  # Precision 4px/8px borders and pill geometries
│   │   │   ├── cyber_typography.dart              # Inter (UI) + JetBrains Mono (telemetry/status)
│   │   │   └── cyber_theme.dart                   # Dark OLED ThemeData configuration
│   │   └── widgets/
│   │       ├── cyber_app_bar.dart                 # Standardized cyber header with persistent Coin action
│   │       ├── cyber_badge.dart                   # Codec, resolution, and status chip indicators
│   │       ├── cyber_button.dart                  # Primary Cyan, Secondary Violet & Destructive Red buttons
│   │       ├── cyber_card.dart                    # Carbon-surfaced container with structural border
│   │       ├── cyber_chip.dart                    # Interactive filter and category selector
│   │       ├── docked_mini_player.dart            # Persistent docked audio/video mini-player
│   │       ├── precision_scrubber.dart            # High-precision millisecond timeline scrubber
│   │       └── telemetry_slider.dart              # Stepped adjustment slider for EQ, volume & shaders
│   ├── features/
│   │   ├── admin/
│   │   │   ├── models/
│   │   │   │   ├── audit_entry.dart               # SHA-256 hashed ledger record structure
│   │   │   │   └── registered_device.dart         # Keystore P-256 bound device identity record
│   │   │   ├── screens/
│   │   │   │   ├── admin_dashboard_screen.dart    # Super Admin Governance Hub & Lockdown trigger
│   │   │   │   ├── admin_login_screen.dart        # Pre-approved Google account & 2FA TOTP gate
│   │   │   │   ├── audit_log_screen.dart          # Searchable, exportable immutable audit log viewer
│   │   │   │   └── backup_hub_screen.dart         # Multi-cloud provider connection & restore point manager
│   │   │   └── widgets/
│   │   │       ├── device_management_sheet.dart   # Remote token revocation & registered device list
│   │   │       └── lockdown_modal.dart            # Emergency lockdown initiation & deactivation modal
│   │   ├── audio/
│   │   │   ├── models/
│   │   │   │   ├── audio_item.dart                # Track metadata (bitrate, sample rate, FLAC, embedded art)
│   │   │   │   └── playlist_item.dart             # M3U/PLS playlist container model
│   │   │   ├── screens/
│   │   │   │   ├── audio_library_screen.dart      # Audio catalog, artists, albums, folders & Hi-Res filter
│   │   │   │   └── full_audio_player_screen.dart  # Vinyl disc HUD, synchronized lyrics, volume boost limiter
│   │   │   └── widgets/
│   │   │       ├── equalizer_sheet.dart           # Standard 5-band / Pro 10-band equalizer modal
│   │   │       ├── queue_sheet.dart               # Drag-and-drop playback queue manager
│   │   │       └── sleep_timer_dialog.dart        # Countdown and end-of-track sleep timer configuration
│   │   ├── cloud/
│   │   │   └── screens/
│   │   │       ├── download_manager_screen.dart   # 30-day lease monitor, grace period warnings, purge queue
│   │   │       └── drive_browser_screen.dart      # Remote folder hierarchy, stream launcher & selective download
│   │   ├── earn/
│   │   │   └── screens/
│   │   │       └── earn_screen.dart               # SRS 6.1 Coming Soon disclosure baseline card
│   │   ├── pro/
│   │   │   └── screens/
│   │   │       ├── dev_mode_screen.dart           # Device-bound token validation & experimental shaders
│   │   │       └── pro_scaler_studio_screen.dart  # A/B split-slider live comparison with telemetry
│   │   ├── settings/
│   │   │   └── screens/
│   │   │       ├── directory_manager_screen.dart  # Storage volume indexing, inclusion/exclusion rules
│   │   │       └── settings_screen.dart           # 4-stage decoder priority, refresh matching, theme config
│   │   ├── tools/
│   │   │   ├── screens/
│   │   │   │   ├── batch_queue_screen.dart        # Conversion queue supervisor with thermal throttling
│   │   │   │   ├── media_diagnostics_screen.dart  # Pro technical stream inspector & HDR analyzer
│   │   │   │   ├── media_repair_screen.dart       # Non-destructive container repair tool
│   │   │   │   ├── mp3_extractor_screen.dart      # Passthrough stream copy or transcode to MP3/AAC/FLAC
│   │   │   │   ├── smart_muxer_screen.dart        # Audio/subtitle stream remuxer & subtitle sync editor
│   │   │   │   ├── tools_hub_screen.dart          # Consolidated SRS 7.8 media tools workspace
│   │   │   │   └── video_trimmer_screen.dart      # Lossless keyframe trimmer & frame capture tool
│   │   │   └── widgets/
│   │   │       └── staged_graph_indicator.dart    # 6-stage video processing graph visualizer
│   │   └── vault/
│   │       ├── screens/
│   │       │   ├── vault_auth_screen.dart         # Master PIN & biometric prompt with failed attempt lockout
│   │       │   ├── vault_browser_screen.dart      # Encrypted asset browser with decoy folder support
│   │       │   └── vault_player_screen.dart       # RAM-only media player with FLAG_SECURE window protection
│   │       └── widgets/
│   │           └── vault_move_modal.dart          # 6-step transactional move visual progress dialog
│   │   └── video/
│   │       ├── models/
│   │       │   └── video_item.dart                # Video file metadata, container, codec, resolution, last position
│   │       ├── screens/
│   │       │   ├── video_library_screen.dart      # Primary video grid, resume card, sorting & directory tree
│   │       │   └── video_player_screen.dart       # Complete HUD, gesture layers, frame step, A-B repeat
│   │       └── widgets/
│   │           ├── ab_loop_dialog.dart            # A-B loop timestamp marker setter
│   │           ├── aspect_ratio_sheet.dart        # 16:9, 4:3, 21:9, Fit, Fill, Stretch, Crop modal
│   │           ├── audio_track_sheet.dart         # Multi-language audio track switcher
│   │           ├── search_filter_modal.dart       # Video format, resolution, and tag search filter
│   │           └── subtitle_sync_sheet.dart       # Subtitle track selector and -10s..+10s offset stepper
├── test/
│   ├── audit_logger_test.dart                     # Cryptographic hash chain validation
│   ├── backup_supervisor_test.dart                # 70% storage threshold & offloading tests
│   ├── decoder_fallback_controller_test.dart      # Deterministic fallback chain testing
│   ├── offline_expiry_manager_test.dart           # 30-day lease and 5-day grace period logic tests
│   └── vault_transaction_manager_test.dart        # 6-step atomic commit & rollback tests
├── index.html                                     # High-fidelity mobile interactive testbed (412x915)
├── prototype_showcase.html                        # Desktop presentation frame and screen gallery
└── pubspec.yaml                                   # Dependencies, assets & Flutter SDK constraints
```

---

## 3. Class Hierarchy & Architectural Contracts

### 3.1 Core Media Engine Abstraction (`lib/core/engine/`)

```dart
// Pure OOP Abstraction: Decouples Flutter UI from Native Engine Implementations
abstract class MediaEngineAdapter {
  Future<void> initialize();
  Future<void> loadSource(String uri, {DecoderMode decoder = DecoderMode.hwPlus});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> stepFrame(int direction); // -1 for previous, +1 for next (VID-12)
  Future<void> setDecoderMode(DecoderMode mode);
  Future<void> setAudioTrack(int trackId);
  Future<void> setSubtitleTrack(int trackId);
  Future<void> setSubtitleOffset(Duration offset);
  Future<void> setABLoop(Duration? start, Duration? end);
  Future<void> dispose();

  Stream<Duration> get onPositionChanged;
  Stream<Duration> get onDurationChanged;
  Stream<PlaybackState> get onStateChanged;
  Stream<DecoderMode> get onDecoderChanged;
  Stream<PlaybackTelemetry> get onTelemetryUpdated;
}

// Concrete Implementation wrapping Android C++ NDK Engine via Dart FFI
class NativeMediaEngineAdapter implements MediaEngineAdapter {
  final DynamicLibrary _nativeLib;
  // FFI Function pointers to libbina_media_engine.so
  ...
}

// 4-Stage Fallback Supervisor (SRS VID-06, VID-07)
class DecoderFallbackController {
  DecoderMode _currentMode = DecoderMode.hwPlus;
  final List<DecoderFailureRecord> _failureHistory = [];

  // Chain: HW+ (MediaCodec+Vulkan) -> HW (MediaCodec) -> Hybrid -> SW (FFmpeg/libavcodec)
  Future<DecoderMode?> handleDecoderFailure({
    required String errorMessage,
    required Future<bool> Function(DecoderMode fallbackMode) tryInitialize,
  });
}
```

### 3.2 Secret Vault Privacy Engine (`lib/core/security/`)

```dart
// Cryptographic Provider interfacing with Android Keystore TEE
abstract class KeyStoreProvider {
  Future<Uint8List> getOrCreateMasterKey(String alias);
  Future<void> rotateMasterKey(String alias);
}

// Authenticated AES-256-GCM Streaming Cipher
class VaultSecurityService {
  static final VaultSecurityService instance = VaultSecurityService._internal();
  
  // Encrypts media stream generating 12-byte IV and 128-bit Authentication Tag
  Future<EncryptedPayload> encryptStream(Stream<List<int>> inputStream, String keyAlias);
  
  // Decrypts directly into allocated RAM ring buffer (Zero unencrypted disk footprint - VLT-04)
  Future<Uint8List> decryptToMemory(String encryptedPath, String keyAlias);
}

// 6-Step Transactional Move Coordinator (SRS VLT-02 & Section 10.2)
class VaultTransactionManager {
  // Step 1: Pre-check SHA-256 hash & destination storage headroom
  Future<String> beginTransaction({required String sourcePath, required int sizeBytes});
  
  // Step 2 & 3: Encrypt into staging sandbox & verify 128-bit MAC tag
  Future<bool> stageAndVerify({required String transactionId, required Uint8List sourceBytes});
  
  // Step 4 & 5: Commit to /app_vault/ and invoke NIST SP 800-88 3-pass file shredder
  Future<bool> commitAndShred({required String transactionId});
  
  // Step 6: Purge system MediaStore and write immutable audit log entry
  Future<void> finalizeTransaction({required String transactionId});
  
  // Atomic Rollback: Cleans staging area if any intermediate step fails
  Future<void> rollbackTransaction(String transactionId, String reason);
}
```

### 3.3 Google Drive & 30-Day Expiry Supervisor (`lib/core/services/`)

```dart
// Isolated Google Drive Client (SRS DRV-02: Scopes strictly segregated from User Profile)
class DriveService {
  Future<bool> authenticateDriveScope();
  Future<List<DriveFileItem>> listFolder(String folderId);
  Future<Stream<List<int>>> openMediaStream(String fileId);
  Future<void> downloadOriginalQuality(String fileId, String destinationPath);
}

// Automated 30-Day Expiry & Grace Period Supervisor (SRS EXP-01..12)
class OfflineExpiryManager extends ChangeNotifier {
  // Evaluates offline leases every 30 minutes
  Future<void> checkAllExpiries();
  
  // Tracks 30-day base lease, 5-day grace period, daily warnings (EXP-06)
  ExpiryState calculateState(DateTime expiryDate, int graceDays);
  
  // Admin Extension Request Workflow (EXP-08)
  Future<bool> requestExtension(String driveId, int requestedDays, String reason);
  
  // Cryptographically signed extension token verification (EXP-09)
  Future<bool> applyExtensionToken(String driveId, String signedToken);
  
  // Automated purge on grace period expiration (EXP-11)
  Future<void> purgeExpiredItem(String driveId);
}
```

### 3.4 Governance & Security Audit Engine (`lib/core/security/` & `lib/features/admin/`)

```dart
// Cryptographically Chained Immutable Audit Ledger (SRS AUDIT-01..07)
class AuditLogger {
  static final AuditLogger instance = AuditLogger._internal();
  String _previousHash = '0000000000000000000000000000000000000000000000000000000000000000';

  // Entry = SHA-256(index + timestamp + action + actor + details + previousHash)
  Future<void> logEvent({
    required String action,
    required String actor,
    required Map<String, dynamic> details,
  });

  // Verifies mathematical integrity of the entire cryptographic chain
  Future<bool> verifyChainIntegrity();
}

// Super Admin Governance & Lockdown Controller (SRS Section 12 & SEC-04..08)
class AdminGovernanceService {
  // Pre-approved Google Account + 2FA TOTP verification
  Future<bool> authenticateSuperAdmin(String email, String totpCode);
  
  // Device identity binding (Keystore P-256 keypair)
  Future<bool> registerDevice(String deviceId, Uint8List publicKey);
  
  // Remote token revocation
  Future<void> revokeDeviceSession(String deviceId);
  
  // Emergency Global Lockdown (SEC-04)
  Future<void> triggerGlobalLockdown(String masterAccessCode, String reason);
  
  // Lockdown Deactivation: Requires Master Access Code + 2FA + Reason + Audit entry
  Future<bool> deactivateLockdown(String masterAccessCode, String totp, String reason);
}
```

---

## 4. Native C++ NDK & JNI Interface Contracts

### 4.1 FFI Function Signatures (`media_engine_native.cpp`)

```cpp
extern "C" {
    // Pipeline Initialization and Tear-down
    DART_EXPORT void bina_native_init_pipeline();
    DART_EXPORT void bina_native_destroy_pipeline();

    // Enhancement Shader Controls
    DART_EXPORT void bina_native_set_denoise(int32_t enabled, float intensity);
    DART_EXPORT void bina_native_set_deblur(int32_t enabled, float intensity);
    DART_EXPORT void bina_native_set_scaler(int32_t scalerType, float intensity);
    DART_EXPORT void bina_native_set_sharpening(int32_t enabled, float intensity);
    DART_EXPORT void bina_native_set_hdr(int32_t enabled);
    DART_EXPORT void bina_native_set_comparison(int32_t mode, float splitPosition);
    DART_EXPORT void bina_native_set_thermal_throttled(int32_t throttled);

    // High-Performance Frame Processing Bridge
    DART_EXPORT void bina_native_process_frame(
        const uint8_t* inRgba,
        int32_t inW,
        int32_t inH,
        uint8_t* outRgba,
        int32_t outW,
        int32_t outH
    );

    // NIST SP 800-88 3-Pass Cryptographic File Shredder
    DART_EXPORT int32_t bina_native_shred_file(const char* filePath);
}
```

### 4.2 NIST SP 800-88 3-Pass Overwrite Implementation (`shredder_native.cpp`)

```cpp
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <openssl/rand.h>

int32_t bina_native_shred_file(const char* filePath) {
    int fd = open(filePath, O_WRONLY);
    if (fd < 0) return -1;

    struct stat st;
    if (fstat(fd, &st) < 0) { close(fd); return -2; }
    off_t fileSize = st.st_size;

    const size_t bufferSize = 64 * 1024; // 64 KB chunk
    uint8_t buffer[bufferSize];

    // Pass 1: Overwrite with all zeros (0x00)
    memset(buffer, 0x00, bufferSize);
    lseek(fd, 0, SEEK_SET);
    for (off_t written = 0; written < fileSize; ) {
        size_t toWrite = std::min((off_t)bufferSize, fileSize - written);
        write(fd, buffer, toWrite);
        written += toWrite;
    }
    fsync(fd);

    // Pass 2: Overwrite with all ones (0xFF)
    memset(buffer, 0xFF, bufferSize);
    lseek(fd, 0, SEEK_SET);
    for (off_t written = 0; written < fileSize; ) {
        size_t toWrite = std::min((off_t)bufferSize, fileSize - written);
        write(fd, buffer, toWrite);
        written += toWrite;
    }
    fsync(fd);

    // Pass 3: Overwrite with cryptographically secure random bytes
    lseek(fd, 0, SEEK_SET);
    for (off_t written = 0; written < fileSize; ) {
        size_t toWrite = std::min((off_t)bufferSize, fileSize - written);
        RAND_bytes(buffer, toWrite);
        write(fd, buffer, toWrite);
        written += toWrite;
    }
    fsync(fd);

    close(fd);
    // Unlink the shredded file from the filesystem
    unlink(filePath);
    return 0; // Success
}
```

---

## 5. UI/UX Navigation Topology (SRS Section 6.1 Compliance)

1. **Persistent Bottom Navigation Shell (`MainNavigationShell`)**:
   - `Tab 0: Video` (`VideoLibraryScreen`) — Default landing, grid/list view, directory navigation, last-interrupted resume card (VID-14).
   - `Tab 1: Audio` (`AudioLibraryScreen`) — Hi-Res FLAC catalog, queue manager (AUD-04), 10-band equalizer (AUD-07), vinyl lyrics player (AUD-10).
   - `Tab 2: Tools` (`ToolsHubScreen`) — Format transcoder with mandatory TOOL-02 disclosure, audio extractor, frame tools, safe repair (TOOL-12), and conversion queue supervisor (TOOL-06).
   - `Tab 3: Settings` (`SettingsScreen`) — 4-stage decoder priority selector, refresh rate matching (VID-19), directory indexing rules, and theme parameters.

2. **Persistent Header Action Row (`CyberAppBar`)**:
   - Left: BinaHub brand badge + active route breadcrumb.
   - Right: Search toggle, Vault Lock trigger (`VaultAuthScreen`), Storage Folder manager (`DirectoryManagerScreen`), Super Admin Profile gate (`AdminLoginScreen`), and **Coin Icon** (`EarnScreen`).

3. **Earn Destination (`EarnScreen`)**:
   - Accessible strictly via header Coin Icon.
   - Enforces exact SRS 6.1 baseline disclosure: *"The current Earn destination is a Coming Soon placeholder; no earning, rewards, or payment workflow is included in this release baseline."*

---

## 6. Zero-Breakage & Safe Modular Development Guidelines (Phase 3)

1. **Strict Dependency Injection**: All services (`AppDatabase`, `AuditLogger`, `BackupSupervisor`, `OfflineExpiryManager`, `VaultTransactionManager`) utilize singleton service locator accessors with explicit asynchronous initialization barriers in `lib/main.dart`.
2. **Import Integrity Guarantee**: Whenever a component or screen is updated, all inbound routes in `MainNavigationShell`, `BinaHubApp`, and navigation sheets are traced and verified to prevent unlinked symbols.
3. **Hardware Fallback Grace**: Any failure in Vulkan compute or NDK shared library loading automatically falls back to standard MediaCodec and pure Dart implementations without application crash.
4. **Test Suite Coverage**: All core state machines are guarded by dedicated automated tests in `test/` verifying cryptographic hashing, 6-step transactional commit, 4-stage decoder fallbacks, and 30-day offline expiry timers.
