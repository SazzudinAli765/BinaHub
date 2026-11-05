# Standard Video Player — Claude Project Instructions

This repository implements the Standard Video Player Android application.

## Required project context
- Read the current `Standard_Video_Player_SRS_Complete_v1.0.pdf` (or the latest SRS version present) before project-wide work.
- Inspect the original user-created Google Stitch design before UI work: https://stitch.withgoogle.com/projects/13269746567386415107
- Use the `standard-video-player-project` skill for design, implementation, debugging, review and testing tasks.
- The original Stitch design is the visual reference; the SRS is the functional source of truth.
- The five generated screenshots rejected by the user are anti-references, not approved design examples.

## Core product direction
- Android-first; Flutter/Dart primary UI; Kotlin for Android APIs; C/C++ via NDK/FFI for performance-sensitive media functions.
- Local files + Google Drive only. No YouTube/YouTube Music, SMB, NAS or DLNA.
- Main navigation: Video, Audio, Tools, Settings. Earn is Coming Soon.
- Pro is freely available; Development Mode is separately activated and device-authorized.
- Preserve all approved SRS requirements. Never invent completed integrations or claim untested functionality.

## UI quality
- Build a clean, premium, restrained, readable media-player experience.
- Preserve the original Stitch brand identity after inspecting it.
- Do not repeat the rejected neon diagnostics-console treatment, excessive cyan/purple/yellow/red, pixel/terminal text, internal tool IDs, SRS labels or technical details in normal user screens.
- Standard screens show essential user-facing information only. Pro shows understandable advanced controls. Development shows technical diagnostics when appropriate. Admin screens redact secrets.
- Every control must work or be clearly disabled/Coming Soon. Layouts must be responsive and scrollable.

## Key interaction rules
- Single tap reveals player controls; they auto-hide.
- Double tap left/right seeks 10 seconds.
- Center previous/next switches videos; it is not seeking.
- Frame-step is separate.
- Keep immersive playback free of unnecessary app chrome.

## Safety and security
- Never place secrets, codes, tokens, private keys or credentials in source, docs, logs or fixtures.
- Never reproduce the user's actual bootstrap/recovery secret in output.
- Use secure key management; do not use a human recovery code directly as an AES key.
- Treat server-side state as authoritative for accounts, approvals, admin rights, activation and expiry.
- Device identity is not an immutable hardware ID; use registered cryptographic key proof and document platform limits.
- Keep audit history tamper-evident and redacted.
- Ask consent before analytics and diagnostic/crash reporting.

## Engineering discipline
- Inspect the repository and working tree before changing files.
- Preserve existing architecture unless there is a reasoned migration plan.
- Make scoped, reviewable changes.
- Run formatting, analysis and relevant tests.
- Inspect runtime/screenshot output for UI changes.
- Report what changed, exact tests run, actual results and blockers.
- Maintain a requirements traceability/status record.
