# Engineering Rules and Module Boundaries

## Suggested high-level modules
Adapt to the existing repository; do not force this structure if a sound architecture already exists.

- `app`: app startup, routing, app lifecycle and dependency composition.
- `core`: shared types, error model, logging redaction, feature flags and utilities.
- `design_system`: design tokens, typography, components and theme modes.
- `video_library`: scanning, indexing, folders, filters, sorting and thumbnails.
- `audio_library`: tracks, albums, artists, favorites and playlists.
- `player`: playback state, gestures, controls, track selection and resume.
- `media_engine`: engine adapters, decoder capabilities, rendering and native bridge.
- `audio_engine`: output routing, EQ, profiles and audio processing.
- `media_tools`: conversion, extraction, subtitle and frame operations.
- `enhancement`: upscaling, deblur, denoise, artifact reduction, tone mapping.
- `pro`: Pro feature surfaces and configuration.
- `development`: activation-gated diagnostic/experimental features.
- `vault`: encrypted storage, metadata, authentication and recovery.
- `cloud_drive`: Google Drive connection, listing, stream and upload adapters.
- `downloads`: queue, destination, network constraints, expiry and notifications.
- `backup`: snapshots, manifests, encryption envelope, replication and restore.
- `admin`: identity, roles, sessions, device management and approvals.
- `security`: keys, authentication, audit, risk controls and secret handling.
- `settings`: persisted preferences.
- `notifications`: user and security notifications.

## Engineering expectations
- Define interfaces between Dart and native C/C++ before broad implementation.
- Keep platform-specific code behind adapters.
- Treat media engine callbacks as asynchronous; guard lifecycle and stale events.
- Use explicit ownership/lifetime management for native resources.
- Do not block the Flutter UI isolate with decoding, conversion, hashing, scanning or enhancement work.
- Use bounded queues, cancellation tokens and cleanup paths.
- Model jobs with durable states (queued/running/paused/failed/completed/cancelled).
- Persist resumable job state where safe.
- Make file moves/copies transactional; write to staging, verify, then commit.
- Preserve original files unless the user approves replacement.
- Treat online/backend state as authoritative for account, approval, admin, activation and expiry.
- Use idempotency for retryable cloud and server operations.
- Never log secrets or entire authentication headers.
- Pin and review dependency versions; verify licenses for redistributable media libraries.
- Document native ABI and plugin build requirements.
- Add unit tests for pure logic and integration tests for platform adapters.
