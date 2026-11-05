# Standard Video Player — Project Baseline

This is a quick reference for Claude. The current SRS and the user's latest explicit decisions remain authoritative.

## Product
Android-first, offline-first core media player with Video, Audio, Tools and Settings navigation. Earn is a Coming Soon placeholder. Media sources are local files and Google Drive only. No YouTube/YouTube Music, SMB, NAS or DLNA integration.

## Design direction
The original user-created Stitch project is the visual source of truth. The five generated screenshots the user rejected are anti-references. Do not reproduce their diagnostic-console aesthetic, excessive neon cyan/purple/yellow/red, terminal-style fonts, pure-black everywhere, technical labels, crowded controls or overexposed internals. Aim for a clean, premium, readable media-player UI; inspect the actual original Stitch frames before deciding final colors and tokens. Do not assume suggested hex samples were approved.

User-facing detail hierarchy:
- Standard: only task-relevant controls and understandable information.
- Pro: useful advanced controls.
- Development: technical diagnostics and experiments.
- Admin: operational status/audit data, with secrets redacted.

## Technology direction
- Flutter/Dart primary app layer.
- Kotlin for Android platform APIs.
- C/C++ via Android NDK and Flutter FFI for performance-sensitive media/processing.
- Evaluate maintained media-engine libraries such as FFmpeg/mpv/MediaCodec; validate licensing, compatibility and support first.
- Local structured database for metadata/settings/history.
- Android Keystore for device-bound cryptographic keys where supported.
- Backend is authoritative for admin identity, approvals, activation, audit and expiry rules.

## Video playback
- HW, HW+, SW and hybrid decoding paths where supported; capability detection and safe fallback.
- Immersive responsive full-screen playback.
- Single tap reveals controls; controls auto-hide.
- Double tap left/right seeks 10 seconds.
- Center previous/next switches videos, not seek.
- Frame-step buttons are separate.
- HDR-to-SDR tone map when needed; use HDR output when supported.
- Refresh matching where supported.
- Subtitle formats via compatible libraries; local and online subtitle workflows.
- PiP plus separate floating player where Android/device supports it.
- Orientation follows device by default, with temporary player override.
- Player should not show filename/technical diagnostics persistently.

## Audio
- Separate audio library.
- Background playback switch in Settings.
- Queue, playlist import/export (M3U/PLS), shuffle/repeat, album art, lyrics, sleep timer.
- Headphone/Bluetooth media controls configurable where supported.
- Basic EQ in Standard; advanced EQ in Pro.
- Standard selectable presets; Pro allows adjustment/customization.
- Auto output detection for phone speakers, wired headphones and Bluetooth, with manual override.
- Video-as-Audio and local video audio extraction.

## Library and tools
- Scan all accessible media by default; users can filter/exclude folders and types.
- Hidden files ignored by default, optional inclusion.
- Detect new media, scheduled full rescans.
- Separate Video and Audio libraries; global and section-specific search.
- Grid/list/compact/custom layouts; persist preferences separately for Video and Audio.
- Filter by all detected resolutions including 8K/unusual; sort/group by name, date, size, duration, resolution, folder, format and recently played.
- Ask before deleting media; use safe deletion behavior.
- Conversion offers target resolution/quality choice; actual multi-stage processing when upscaling, not metadata-only changes.
- Original preservation/replacement preference configurable in Settings; default safe behavior is separate output unless user chooses otherwise.
- Batch conversion queue: pause/resume/cancel/reorder/retry; parallel only when supported.
- Audio extraction can copy original stream when possible or transcode to chosen format.
- Frame capture, burst extraction/contact sheets, subtitle editing/conversion/synchronization.

## Enhancement and Pro/Development
- Automatic upscaling when compatible.
- Pipeline selected based on source and hardware; manually detailed stage control in Development Mode as specified.
- Deblur and noise/artifact reduction have separate logic, automatic behavior, Pro adjustments and experimental Dev controls.
- Presets include quality/balanced/performance plus custom profiles.
- Thermal/battery adaptation with approved override.
- Before/after split and slider previews.
- Pro is freely unlocked; no Pro passcode.
- Dev is online activation, server authoritative, per-device authorization/expiry/revocation. Manual overrides/experimental tools require Dev. Dev expiry/revocation resets experimental overrides.
- Do not assume Vulkan/NPU/GPU features on every device.

## Vault
- AES-256-GCM authenticated encryption; encrypted filenames/metadata/thumbnails; Android Keystore; hardware-backed key when available.
- Transactional migration: stage, verify integrity, commit encrypted copy, only then delete source if authorized; rollback safely on failure.
- Secure playback without persistent plaintext extraction; protect screenshots and recent-task previews; configurable auto lock.
- Account-only Vault recovery via server-side encrypted key escrow. Distinct from admin recovery and backup encryption. Do not expose plaintext keys.

## Google Drive and offline copies
- Link Google account; browse and stream supported media without pre-downloading.
- Upload/save supported media.
- Offline downloads preserve original quality.
- Each download chooses private app storage or a user-selected folder.
- Download manager supports queue, pause/resume, retry, reorder/prioritize, cancel, progress and network rules.
- Adaptive parallel downloads, manual override.
- Optional automatic downloads off by default.
- Automatic-download storage limit is user-configured; ask before increasing/deleting/canceling.
- Offline copy validity: 30 days, then five-day grace/request window. Request does not pause countdown. Admin extension: 1–30 days. Approval applies to all user offline downloads. Rejection notifies immediately; copies remain to original grace deadline. Deletion affects only offline copy, never Drive source.
- In-app + Android daily warning and remaining-days alerts.
- Store cloud metadata/IDs, not media bytes, in sync records. Reconcile server authority when online.

## Admin and security
- Roles: Super Admin, Admin, Support Admin.
- Maximum 3 Super Admin accounts. Initial approved accounts are maintained in secure server config, never hardcoded.
- Both Super Admins have broad authority. Protected ownership may transfer to either by mutual approval; previous owner remains Super Admin unless changed.
- Approved Google accounts + mandatory 2FA; no public registration.
- Admin idle timeout: 30 minutes.
- Max 2 active devices per Super Admin.
- New-device sign-in requires Google login + 2FA; no other-device approval. Notify only the signing-in Super Admin.
- Device list with name/model (custom rename), registration/login/last activity/status and individual revoke.
- Revocation ends sessions/tokens; re-registration requires fresh Google login + 2FA.
- Failed attempts: progressive lockout + alerts to affected Super Admin.
- Alerts: email, dashboard and Android push, as configured.
- Both Super Admins can inspect admin activity; redact secrets. Log every log access.
- Audit log is append-only/tamper-evident; admins cannot delete/edit it. Corrections are appended.
- Risk monitoring detects unusual devices/locations, data access, repeated sensitive changes and unusual account patterns.
- Emergency response can restrict suspicious accounts/devices and revoke sessions. Either Super Admin can initiate or end global lockdown independently; deactivation requires fresh auth, 2FA, master code, reason, audit and notification. No automatic expiry; every 3 hours send reminders with security report through email/dashboard/push.
- Security transport/app/storage layers per SRS: TLS 1.3, application-layer authenticated payload protection where required, managed encryption at rest. At-rest encryption is not a second transport layer.
- Recovery: device-cryptographic identity/registration verification first; separate recovery/reset code fallback if device proof cannot restore access. Recovery code can reset access, add/replace Super Admin emails and import protected admin data backup. Do not add face verification/manual third-party approval unless user changes it.
- Recovery/reset code is secret; do not place literal value in repo/docs. Main Admin may rotate it under approved verification. Master access code is separate.

## Backup and restore
- Manual + automatic.
- Daily critical-data backups/after important changes; weekly full backups; incremental plus periodic full.
- Compress before encrypt.
- Primary storage target/limit 5 GB; connected cloud storage adds capacity.
- Start offload at 70%; oldest backups first.
- Multiple accounts per provider, including multiple Proton Drive accounts where APIs permit.
- Main Admin alone connects additional cloud storage.
- One secondary account per replication operation. If unavailable/full/disconnected, stop and ask Main Admin whether reconnect/use another account/stop. No silent switching.
- Verify integrity and retrievability before deleting primary copy.
- Keep cloud backups indefinitely until manually deleted. Never silently delete for capacity.
- 3 automatic retries with increasing delays; after failure, require Main Admin approval before more attempts.
- Unique ID and tamper-evident verification record per backup; independent encryption key per backup.
- Full and selective restore. Preview before restore. Always pre-restore snapshot.
- Full-system restore requires maintenance mode and another Super Admin approval. Selective restore follows permission.
- Restoration permission can be granted by either Super Admin; export and restore are separate permissions.
- Routine import requires authorized Google login + 2FA. Recovery code is for key-recovery path, not required for every normal import.
- Weekly isolated restore test; weekly and monthly health reports.
- Backups include required admin/user records, settings, approval and audit history, device history and relevant metadata. Exclude plaintext secrets, passwords, private keys, raw biometrics, tokens, active sessions and media bytes unless explicitly approved.
- Removed admin records are packaged into an encrypted archive securely available to configured Main/Super Admins; do not email plaintext attachments.

## Consent, privacy and UI behavior
- Ask consent for analytics/usage collection on first install; persist choice; enable only after consent; allow change in Settings.
- Crash/diagnostic report asks permission per report unless the user enabled future consent.
- Ask before deleting media; offer backup before clearing app data but allow confirmed deletion.
- Hide sensitive Vault preview in recent apps; block screenshots/recordings in Vault.
- Permission strategy and Android behavior must follow current Android versions and the SRS.
