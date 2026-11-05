# Design Review and Acceptance Checklist

## Source distinction
- Original Stitch design supplied by the user = primary visual reference.
- Five rejected generated implementation screenshots = anti-reference only.
- Do not confuse the two or claim source inspection without actually opening it.

## What the rejected screenshots got wrong
- Looked like a technical diagnostics console, not a consumer media player.
- Used excessive competing neon cyan, purple, yellow and red.
- Used near-black panels everywhere and harsh contrast.
- Used pixel/terminal typography for normal app content.
- Put SRS identifiers, tool IDs, technical encryption details, RAM values and internal processing labels in user-facing screens.
- Filled the top bar with too many icons.
- Made the normal Vault playback screen expose internal crypto/memory implementation.
- Made the Earn placeholder a release-note/engineering page.
- Made conversion UI expose numbered internal stages to ordinary users.
- Left too much unused space in the video player and used poorly balanced control placement.
- Had controls/interactions that appeared unfinished or nonfunctional.

## Design goals
- Premium, clean, restrained, readable, modern media-player UI.
- Preserve the user's actual brand identity and any reusable Stitch components.
- Refine the palette without blindly copying the rejected generated palette.
- One main accent color; other colors only for meaningful status.
- Clear distinction between background, surface and elevated surface.
- Readable sans-serif type hierarchy.
- Consistent spacing and touch targets.
- Minimal useful top-level actions; context-specific actions only.
- Normal users see human-friendly names and choices, not internal engineering terminology.
- No persistent video title/technical overlays during immersive playback unless user reveals controls.
- Player controls prioritize content and usability.
- Tools use task-oriented workflows (select file → choose output → destination → process → result).
- Vault communicates protection with simple status language, not raw cryptographic implementation.
- Earn shows only a clean Coming Soon state.
- Settings are grouped logically; advanced settings separated.
- Development Mode and admin screens may show technical detail when relevant, but still use consistent typography and hierarchy.

## Per-screen review questions
1. Does this screen solve one clear user task?
2. Is the primary action obvious?
3. Is visible information relevant at this moment?
4. Are implementation details hidden unless needed?
5. Does it match the Stitch-derived tokens and components?
6. Does the content fit/scroll at small sizes?
7. Are touch targets usable?
8. Are loading/empty/error/success/permission states present?
9. Do controls have working actions?
10. Is the screen coherent in light/dark/system modes?

## Required visual QA
- Capture screenshots at at least one small phone, one common phone and one large phone/tablet size where supported.
- Check portrait and landscape video-player layouts.
- Inspect overflow, truncation, clipping and scroll behavior.
- Inspect text contrast and font scaling.
- Check selected, pressed, disabled, loading, error and focus states.
- Compare screenshots with the original Stitch design and this anti-pattern list.
