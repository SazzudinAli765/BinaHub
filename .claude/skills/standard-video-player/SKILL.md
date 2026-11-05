---
name: standard-video-player-project
description: Design, implement, debug, review, or test the Standard Video Player Android project using its SRS, Stitch reference, approved product decisions, and engineering quality rules.
---

# Standard Video Player — Project Skill

Use this skill whenever working on the Standard Video Player application: product design, UI implementation, architecture, Flutter/Dart, Kotlin/Android, C/C++ media processing, playback, cloud, Vault, administration, security, backups, debugging, testing, or documentation.

## 1. Source-of-truth order

Before changing the project, locate and read the current project references:

1. **Current SRS PDF** — authoritative for required product behavior and acceptance criteria.
2. **Original Google Stitch design file** — visual reference for the product's intended identity and existing components.
3. **Latest user instructions and approved corrections** — take precedence over older conversational assumptions where they explicitly change a requirement.
4. **This skill's reference files** — compact project context and working rules; they do not override the SRS or a newer explicit user decision.
5. **Existing codebase** — inspect before editing; do not assume its architecture or feature state.

The five recently rejected implementation screenshots are anti-references: do not reproduce their excessive neon accents, pixel/terminal typography, diagnostic-console appearance, overexposed engineering metadata, cramped controls, or unfinished interactions. They are examples of what needs correction, not the approved design.

If the original Stitch file and the rejected screenshots appear to conflict, distinguish the original user-created Stitch design from the generated/rejected output. Do not claim to have inspected a design source unless you actually opened it. If a reference is missing or inaccessible, state exactly what is unavailable and proceed only with grounded information.

## 2. Non-negotiable working rules

- Preserve all approved SRS functionality. Do not simplify a feature merely because it is difficult.
- Preserve the original Stitch brand identity where it is genuinely present, but correct the rejected generated visual treatment.
- The UI should feel like a polished, modern media player—not an engineering dashboard.
- Keep ordinary user screens focused on user tasks. Hide internal implementation details unless they are useful to the user.
- Put advanced user controls in Pro Mode and experimental diagnostics in Development Mode, according to the SRS.
- Every visible control must have a real action or a clearly disabled/Coming Soon state. Never present a mock as functional.
- Do not claim a feature is implemented or tested until its behavior has been verified.
- Do not overwrite or restructure existing code before inspecting it and understanding dependencies.
- Prefer small, reviewable changes. Run relevant tests after each meaningful change.
- Preserve existing working behavior unless a requested change requires altering it.
- Never put secrets, API keys, passwords, recovery codes, private keys, access tokens, or service credentials in source code, logs, screenshots, test fixtures, or documentation.
- Do not include the user's actual bootstrap/master/recovery secret in generated files. Configure secrets out of band through a secure secret store or environment configuration.
- Do not silently invent backend endpoints, provider capabilities, device capabilities, or successful test results.
- If an integration needs credentials, provider approval, device support, or backend deployment, build the correct interface and adapter boundary, then clearly mark the external prerequisite.

## 3. Required initial workflow

For a new task or unfamiliar repository:

1. Inspect the repository tree, current branch, working tree and relevant module files.
2. Find the SRS and design references. Read the relevant sections fully; for a project-wide task, read the complete SRS.
3. Identify the affected requirements and dependencies.
4. Inspect the existing implementation before proposing changes.
5. Make a short plan with files/modules to change and tests to run.
6. Implement the smallest coherent end-to-end slice.
7. Run formatting, static analysis, unit tests, integration tests or UI checks that are available.
8. Inspect the actual rendered screen or runtime behavior where possible.
9. Update the requirements traceability/status record and project notes.
10. Report what changed, what was tested, test results, and any remaining blockers.

Do not ask the user to repeat information already present in the repository, SRS, Stitch reference, or approved decision records. Ask only for a genuinely blocking decision; otherwise use a conservative, documented default.

## 4. Product architecture baseline

The target is an Android-first media application with:

- Flutter/Dart for the primary UI and application layer.
- Kotlin for Android platform integrations where required.
- C/C++ through Android NDK and Flutter FFI for performance-sensitive media-engine and processing components.
- A modular media-engine integration using established technologies where suitable (evaluate FFmpeg, mpv, Android MediaCodec and platform rendering/audio APIs; confirm license, compatibility, maintenance and device constraints before choosing).
- Local structured storage for library metadata, preferences, playlists, history, bookmarks, resume positions and sync state.
- Android Keystore for device-protected cryptographic material where appropriate.
- A backend for authoritative account, admin, activation, approval, audit, expiry and recovery state where the SRS requires server-side authority.

Do not build an entire codec/media engine from scratch. Keep engine adapters replaceable and isolate device-specific code. Do not assume every device supports Vulkan, NPU, HDR, passthrough, every codec or every hardware decoder.

Main navigation: **Video, Audio, Tools, Settings**. Keep the persistent Earn entry as specified; Earn is currently a Coming Soon placeholder, not a functioning rewards system.

Supported media sources: local device files and Google Drive. Do not add YouTube/YouTube Music, SMB, NAS, DLNA, or arbitrary network-source integrations unless the user explicitly changes the product scope.

## 5. UI and visual-design rules

### Direction
Create a clean, premium, modern, readable media-player experience. The product should feel comfortable for everyday use, not like a diagnostics console.

- Use a restrained palette with one dominant accent.
- Use neutral surfaces with clear contrast and hierarchy.
- Use readable sans-serif typography for normal application content.
- Use consistent spacing, component sizes, icon weights, radii and states.
- Use color primarily for hierarchy and meaningful states (success, warning, error).
- Use restrained borders and shadows; avoid constant glow effects.
- Keep layouts responsive, scrollable and touch-friendly.
- Use the actual Stitch reference to preserve established brand elements; do not blindly apply a new palette or these example colors without checking the reference.

### Rejected visual treatment — do not repeat
- Excessive competing cyan, purple, yellow and red accents.
- Pure black panels everywhere with harsh contrast.
- Pixel/terminal fonts for ordinary UI.
- Rainbow section headings and frequent glowing outlines.
- Tiny uppercase technical labels.
- Tool IDs, SRS section numbers, internal pipeline stage IDs and engineering codes in user-facing views.
- Exposed AES implementation labels, RAM buffer sizes, key-wrapping details, decoder telemetry, raw frame-drop counters or internal release notes in normal screens.
- Crowded controls, wasted player space, fixed-size layouts, clipped content, or unscrollable screens.

### Information visibility by mode
- **Standard:** show the task, useful media information and essential controls only.
- **Pro:** show understandable advanced controls and useful processing information.
- **Development:** show diagnostics, hardware details, experimental controls and engineering telemetry when explicitly appropriate.
- **Administration:** show operational status and audit information, but redact secrets and sensitive key material in every role.
- Never show passwords, tokens, raw private keys, recovery secrets, master codes or raw biometric material in any mode.

### Video-player interaction contract
- Immersive playback should use the available screen area and adapt to orientation/device size.
- Single tap reveals standard controls; controls auto-hide after the configured interval.
- Double-tap left/right performs 10-second backward/forward seek.
- Center previous/next controls switch to the previous/next video; they are not seek controls.
- Frame stepping has separate controls.
- Advanced controls (subtitle/audio track, speed, aspect ratio, enhancement) must be accessible without cluttering the normal viewing surface.
- Do not leave app navigation or mini-player overlays covering immersive playback when they should be hidden.
- Verify portrait and landscape layouts, gesture hit areas and accessibility labels.

For each new screen, implement loading, empty, error, permission-denied, disabled and success states when relevant. Avoid exposing technical implementation details that do not help the current user task.

## 6. Functional modules to preserve

Use the SRS for exact requirements. The following is an orientation checklist, not an exhaustive substitute for the SRS:

- Video library, scanning, folder filters/exclusions, search, sorting, layouts, resolution filters, favorites, history, resume and thumbnails.
- Video player, decoder selection/fallback, HDR handling, refresh matching, subtitles, audio tracks, gestures, PiP, floating playback, bookmarks and A-B repeat.
- Audio library/player, background playback, queue, playlists, shuffle/repeat, equalizer, presets, lyrics, sleep timer, output detection, headset/Bluetooth controls and video-as-audio.
- Tools: format conversion, target-quality selection, extraction, frame capture, contact sheets, subtitle conversion/editing/synchronization, media details and batch queue.
- Pro: standard-vs-advanced feature separation, color/audio profiles and advanced enhancement settings.
- Development Mode: server-authoritative activation, per-device approvals/expiry/revocation, experiments and diagnostics.
- Secret Vault: transactional encryption/migration, protected metadata, lock behavior, secure playback and account-recovery design.
- Google Drive: linking, browsing, stream-without-download, original-quality offline downloads, upload/save, cache and queue management.
- Administration: role-based authorization, Google login/2FA, session/device control, ownership rules, security alerts, emergency controls and tamper-evident logs.
- Backups: encrypted, compressed, incremental/full, restore points, selective/full restore, cloud replication, integrity verification and failure recovery.
- Privacy/accessibility: permission flow, analytics consent, notification preferences, accessibility and data deletion.

## 7. Media-engine and processing engineering rules

- Prefer established, maintained libraries over custom codec implementations.
- Keep decoder selection explicit and observable in diagnostics.
- Support HW, HW+, SW and hybrid paths where the selected engine/platform makes them available.
- Detect decoder/hardware support at runtime and fall back safely.
- Do not assume fallback is seamless; handle seek, audio state, subtitle state, frame timing and resume consistently.
- Separate upscaling, deblur, noise reduction, artifact reduction, sharpening, tone mapping and rendering into independently testable stages.
- A 360p-to-1080p target selection must invoke real scaling/enhancement processing; changing metadata alone is not upscaling.
- Use automatic recommendations in ordinary modes and expose manual advanced controls according to the SRS.
- Respect thermal, battery, memory and device capability signals, with user overrides only where approved.
- Clearly distinguish actual super-resolution from conventional interpolation/scaling. Never claim recovered source detail that the algorithm cannot infer.
- Use asynchronous processing, progress, cancellation, bounded queues and deterministic cleanup.
- Preserve source files unless the user explicitly confirms replacement according to saved preference.

## 8. Security and privacy baseline

Treat security requirements as architectural, not decorative.

- Apply authentication, authorization, server-side checks, replay protection, rate limits, audit logging and secure error handling.
- The user selected layered protection: TLS 1.3 for transport, application-level authenticated payload encryption where required, and managed-key encryption at rest. Do not describe at-rest encryption as another transport layer.
- Use AES-256-GCM correctly with unique nonces and key separation; use authenticated metadata and versioned envelopes.
- Use Android Keystore/hardware-backed keys where supported; handle key invalidation and device reset.
- Never derive an AES key directly from a human-readable recovery code. Use a proper key hierarchy, key wrapping, a strong KDF where applicable, server-side rate limiting and secure secret management. A short human code alone is not high entropy.
- Do not store secrets in app resources, source control, logs, crash reports or screenshots.
- Keep Vault recovery separate from administrator/backup recovery.
- Device identity is not an immutable universal hardware ID. Prefer hardware-backed key proof plus server-side device registration; document limitations after reset/reinstall.
- Security/audit history is append-only and tamper-evident. Do not permit ordinary admin deletion or editing of security logs.
- Redact sensitive values from all UI, logs, reports and analytics.
- Ask explicit consent before sending crash/diagnostic reports. Respect analytics consent from first run and allow changes in Settings.
- Never claim physical secure erasure from flash storage.

## 9. Approved administration and account behavior

Follow exact details in the SRS and confirm current repository configuration before changes. Known decisions include:

- Role model: Super Admin, Admin and Support Admin with distinct permissions.
- Maximum of 3 Super Admin accounts.
- Two designated initial Super Admin accounts are configured through secure deployment configuration; do not hardcode account secrets in the app.
- Both Super Admins have broad authority; protected ownership can transfer to either by mutual approval. Previous owner remains a Super Admin unless explicitly changed.
- Administrator login uses pre-approved Google accounts and mandatory 2FA; no public registration.
- Administrator inactivity timeout: 30 minutes.
- Maximum 2 simultaneous active devices per Super Admin.
- New-device login uses approved Google login plus 2FA; no approval from another device is required.
- New-device notification goes only to the Super Admin who signed in.
- Each Super Admin can inspect and revoke individual sessions/devices.
- Device revocation terminates the session; re-registration requires fresh Google login and 2FA.
- Failed login attempts use progressive lockout and alert the affected Super Admin.
- Security alerts use email, dashboard and Android push where configured.
- Both Super Admins can see administrative activity; secrets remain redacted.
- Emergency/global lockdown behavior, permissions, deactivation verification, indefinite status and reminder/report cadence must follow the SRS.
- Recovery: first use the agreed cryptographic/device-registration algorithms to verify a registered Super Admin device. If that path cannot establish access, use the separate recovery/reset code flow to reset access, manage replacement Super Admin emails and import an administrator backup. Do not add face verification or manual third-party review unless the user changes this requirement.
- Recovery/reset code is a secret. Never repeat it, include it in this skill, commit it, log it, or display it. The Main Admin can rotate it through the approved verification process; configure the initial value outside source control.
- Master access code and recovery/reset code are separate credentials; preserve the SRS's distinct verification sequences.

## 10. Backup and cloud-storage baseline

- Support manual and automatic backup.
- Critical-data backups: daily and after important changes.
- Full backups: weekly.
- Use incremental backups plus periodic full backups.
- Compress before encrypting.
- Primary backup storage target/limit: 5 GB; connected cloud accounts provide additional capacity.
- Begin offloading at 70% primary storage usage.
- Offload oldest backups first.
- Use one secondary cloud account at a time for a replication operation.
- Support multiple accounts per provider, including multiple Proton Drive accounts, subject to available official APIs and access.
- The Main Admin alone connects additional cloud storage.
- Verify the replicated backup's integrity and retrievability before removing its primary copy.
- When a secondary account is unavailable/full/disconnected, stop offloading and ask the Main Admin whether to reconnect, use another account or stop. Do not silently switch accounts.
- Never silently delete a backup to free space. Cloud backups are retained indefinitely until manually deleted.
- If all three automatic retries fail, stop and request Main Admin approval before further retry.
- Backups receive unique IDs and tamper-evident verification records.
- Use a separate unique encryption key per backup and a secure key-wrapping design.
- Routine import requires authorized administrator authentication and 2FA; recovery-code-based key recovery is a distinct step and must not be imposed on every routine import unless key recovery is actually needed.
- Full restoration enters maintenance mode and follows the additional Super Admin approval rule. Selective restoration follows its own permission.
- Create a pre-restore snapshot before any restore; preview the restore point first.
- Test restores weekly in an isolated environment and generate weekly/monthly health reports.
- Backups may include necessary application/admin configuration, user records, approval history, metadata and audit history as specified, but must not include plaintext passwords, master/recovery codes, private keys, raw biometrics, active session tokens, Drive OAuth refresh tokens or actual media files unless the SRS explicitly requires a separately approved media backup.
- If an administrator is removed, package their required records into a protected archive for the configured Main Admins/Super Admins. Do not email plaintext ZIP attachments; provide a securely encrypted archive/download and audit access.

## 11. Google Drive downloads — preserve the agreed lifecycle

Follow the SRS for exact lifecycle and notification wording. Known rules:

- Offline copies retain original file quality; do not transcode/compress downloaded originals.
- Download destination is chosen per download: private app storage or a user-selected accessible folder.
- Full queue management is required.
- Network restrictions and adaptive concurrency are configurable.
- Optional auto-download is off by default and follows user-defined rules.
- Offline copy validity is 30 days, followed by a five-day grace/request window. Extension is 1–30 days through the designated request/approval workflow.
- A pending extension request does not pause the expiry countdown.
- Approval applies to all of that user's offline downloads, under the selected policy.
- Rejected requests notify immediately; files remain through the original grace period unless the authoritative SRS states otherwise.
- Expiry deletion removes only the offline copy, never the source Drive file.
- Send the agreed daily in-app and Android notifications and remaining-time warnings.
- Cloud records store identifiers/metadata/status, not the media bytes.
- Offline clients cannot receive immediate server decisions; enforce local signed expiry metadata and reconcile server authority on reconnect.

## 12. Quality gates and testing

Before marking work complete:

- Build succeeds with documented commands.
- Formatter and static analysis pass.
- Relevant unit tests pass.
- Relevant integration/UI tests pass.
- Manual runtime behavior has been checked where possible.
- No secrets appear in logs or repository.
- No broken navigation or inert controls remain.
- Responsive behavior is checked on supported sizes/orientations.
- Loading, empty, failure, permission and success states exist.
- Requirements traceability is updated.
- Known limitations and external setup are documented.

For UI work, inspect actual screenshots/runtime renders, not just source code. Compare them against the original Stitch reference and the rejected screenshots' anti-patterns.

For media work, test actual sample files and device paths. Do not treat a mocked player as proof of media-engine integration.

For security work, test both success and failure paths, including interruption, revoked sessions, invalid credentials, expired state, cloud unavailability and partial restore. Never claim an external security certification without one.

## 13. Project status reporting

At the end of each task, report:

1. What you inspected.
2. What you changed.
3. Which requirements were addressed.
4. Files/modules changed.
5. Tests and commands run, with actual results.
6. What remains incomplete.
7. External configuration or credentials still required.
8. Risks or decisions that genuinely need the user's input.

Use requirement statuses:
- Not started
- In progress
- Implemented
- Tested
- Blocked
- Requires external configuration

Do not label a feature "Implemented" merely because a screen or placeholder exists.

## 14. When invoked

Interpret the user's request in the context of the complete project. Do not automatically redesign or rewrite the entire repository for a narrow bug fix. Apply only the relevant parts of this skill, preserve working behavior, and test the affected module.

Useful invocation examples:
- "Use the Standard Video Player skill to audit the current player screen."
- "Use this skill to implement decoder fallback and test HW/HW+/SW/hybrid paths."
- "Use this skill to compare the current UI with the original Stitch reference and correct the design."
- "Use this skill to implement encrypted backup replication."
- "Use this skill to review whether the current Vault flow meets the SRS."

When doing a project-wide task, follow the full workflow. When doing a small task, keep the change scoped but still respect the baseline."
