# Verification Checklist

## Build and repository hygiene
- [ ] Inspect existing git state; do not overwrite unrelated work.
- [ ] Build succeeds using documented commands.
- [ ] Formatting passes.
- [ ] Static analysis/lint passes.
- [ ] No secrets or credentials in source, fixtures, logs or committed config.
- [ ] Dependencies and licenses are reviewed.

## UI
- [ ] Visual system derives from original Stitch reference.
- [ ] Rejected diagnostics-console styling is not repeated.
- [ ] Every screen has clear task hierarchy.
- [ ] Screens are responsive and scroll when required.
- [ ] No clipping, overflow or tiny unreadable labels.
- [ ] Light/dark/system modes remain coherent.
- [ ] All buttons, icons and controls work or are clearly disabled/Coming Soon.
- [ ] Loading, empty, error, success and permission states exist.

## Video
- [ ] HW/HW+/SW/hybrid paths tested where available.
- [ ] Fallback behavior tested.
- [ ] Playback survives orientation changes.
- [ ] Single tap reveals controls and auto-hide works.
- [ ] Double tap left/right seeks 10 seconds.
- [ ] Previous/next switches videos.
- [ ] Frame-step is separate.
- [ ] Subtitle/audio-track selection works.
- [ ] HDR/SDR paths tested where hardware permits.
- [ ] PiP/floating behavior tested where supported.
- [ ] Resume/bookmark/A-B repeat/speed tested.

## Audio
- [ ] Background playback setting works.
- [ ] Queue/playlist/shuffle/repeat work.
- [ ] Bluetooth/headphone controls tested where available.
- [ ] EQ and profiles respect Standard/Pro boundaries.
- [ ] Lyrics and sleep timer behave correctly.
- [ ] Video-as-Audio works.

## Tools and enhancement
- [ ] Conversion uses real processing and correct target output.
- [ ] 360p→1080p does not merely alter metadata.
- [ ] Original-file protection works.
- [ ] Queue pause/resume/reorder/retry/cancel work.
- [ ] Audio extraction copies stream when possible and transcodes when selected.
- [ ] Frame capture/contact sheets work.
- [ ] Subtitle operations work.
- [ ] Upscaling/deblur/denoise stages are distinct and testable.
- [ ] Thermal/battery adaptation works where signals are available.
- [ ] Before/after comparison works.

## Vault and cloud
- [ ] Vault encryption/authentication/integrity tested.
- [ ] Failed Vault migration rolls back.
- [ ] Screenshot/recent-app protection works where Android permits.
- [ ] Drive stream does not force a download.
- [ ] Offline copy retains original quality.
- [ ] Deleting offline copy never deletes Drive original.
- [ ] Expiry and extension rules tested online/offline/reconnect.
- [ ] Downloads honor destination/network/queue settings.

## Admin and backups
- [ ] Roles and server-side authorization tested.
- [ ] Google login/2FA and session expiry tested.
- [ ] Max two active devices per Super Admin enforced.
- [ ] Device revocation ends active sessions.
- [ ] Progressive lockout and alerts tested.
- [ ] Recovery flow follows device proof then recovery-code fallback.
- [ ] Audit log is append-only and redacted.
- [ ] Lockdown activate/deactivate rules tested.
- [ ] Backup encryption uses unique key per backup and authenticated metadata.
- [ ] Replicated copy verified before local deletion.
- [ ] Cloud outage prompts Main Admin; no silent account switching/deletion.
- [ ] Restore preview and pre-restore snapshot work.
- [ ] Full restore maintenance mode and required approval work.
- [ ] Selective restore permissions work.
- [ ] Isolated restore test and health reports work.

## Reporting
For each task, report exact commands run and pass/fail results. Distinguish implemented, tested, blocked and requires external configuration.
