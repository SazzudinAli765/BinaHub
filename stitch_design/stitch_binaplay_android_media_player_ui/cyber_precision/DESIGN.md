---
name: Cyber Precision
colors:
  surface: '#0d141d'
  surface-dim: '#0d141d'
  surface-bright: '#333a44'
  surface-container-lowest: '#080f17'
  surface-container-low: '#151c25'
  surface-container: '#192029'
  surface-container-high: '#232a34'
  surface-container-highest: '#2e353f'
  on-surface: '#dce3f0'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#dce3f0'
  inverse-on-surface: '#2a313b'
  outline: '#849495'
  outline-variant: '#3b494b'
  surface-tint: '#00dbe9'
  primary: '#dbfcff'
  on-primary: '#00363a'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#006970'
  secondary: '#d0bcff'
  on-secondary: '#3c0091'
  secondary-container: '#571bc1'
  on-secondary-container: '#c4abff'
  tertiary: '#dcffdb'
  on-tertiary: '#003915'
  tertiary-container: '#60f587'
  on-tertiary-container: '#006e2f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#0d141d'
  on-background: '#dce3f0'
  surface-variant: '#2e353f'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.03em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-mono-lg:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.02em
  label-mono-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-mono-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 12px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.25rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system targets power users, audiophiles, video engineers, and technical enthusiasts who demand uncompromised performance, millisecond-level playback controls, and complete hardware insight on modern OLED displays.

The aesthetic fuses **dark cyber-engineering** with **instrument-grade industrial design**:
- **Pure OLED Pitch Black base**: Eliminates visual noise, maximizes hardware contrast, and preserves battery performance on mobile displays.
- **Instrument Precision**: Information-dense layouts, razor-sharp geometric separation, monospaced numeric readouts, and optical telemetry indicators.
- **Controlled High-Frequency Accents**: Sparse, tactical deployment of Electric Cyan for active signal processing and playhead positions, with Neural Violet reserved for compute indicators, codecs, and specialized hardware acceleration flags.

## Colors

The palette operates on strict functional strata designed specifically for zero-emissive OLED panels:

- **Canvas & Substrates**:
  - `bg-pure-black`: `#000000` (Core canvas, letterboxes, full-bleed viewport layers).
  - `surface-carbon`: `#111115` (HUD overlays, track inspection panes, modular bottom sheets).
  - `surface-carbon-raised`: `#16161C` (Floating controls, scrubber panels, modal flyouts).
  - `border-structural`: `#22222A` (Single-pixel technical dividers, panel boundaries).
  - `border-active`: `rgba(0, 240, 255, 0.4)` (Active focus frames and scrubber heads).

- **Chromatic Signals**:
  - **Primary (`#00F0FF` - Electric Cyan)**: Playhead indicators, active buffer meters, live stream badges, and primary action states.
  - **Secondary (`#8B5CF6` - Neural Violet)**: Hardware decoder status (AV1/HEVC), NPU audio upmixing switches, high-bitrate indicators.
  - **Tertiary (`#22C55E` - Signal Green)**: Real-time 120 FPS indicators, zero-drop frame flags, lossless bitstream confirmations.
  - **Warning/Error (`#EF4444` - Thermal Red)**: Frame drop alerts, audio clipping meters, buffer underrun notices.

- **Content & Textures**:
  - `text-primary`: `#FFFFFF` (High contrast, core metrics, active timecodes).
  - `text-secondary`: `#9CA3AF` (Metadata, audio channels, bitrates, sample rates).
  - `text-tertiary`: `#4B5563` (Inactive tracks, grid indexes, boundary labels).

## Typography

The type hierarchy couples high-clarity sans-serif forms with fixed-pitch monospaced technical readouts:

- **Inter** governs all navigational anchors, track titles, setting headers, and structural UI labels. It ensures immediate legibility against pitch-black backgrounds even under heavy peripheral vibration or active screen movement.
- **JetBrains Mono** drives all temporal, hardware, and numeric telemetry: timecode trackers (`01:42:18:24`), frame counters, buffer percentages, sample frequencies (`96kHz / 24-bit`), and hardware decoders (`VULKAN-HW`).
- Tabular figures (`tnum`) are strictly enforced across all digital clocks, timeline markers, and telemetry counters to prevent spatial jitter during continuous updates.

## Layout & Spacing

Layout geometry follows an instrument rack approach designed to balance thumb reachability in portrait orientation with uncluttered HUD views in landscape playback.

- **System Grid & Fluid Scaling**:
  - **Mobile Portrait (Base)**: 4-column layout with 16px outer safe margins and 16px gutters. Media controls anchor to the lower 35% thumb zone.
  - **Mobile Landscape (Player View)**: Dynamic edge-to-edge frame. On-screen controls pin to dual vertical flanks (left for stream navigation/queue, right for hardware DSP/equalization) leaving the central 70% uninterrupted.
  - **Tablet & Large Formats**: 8 to 12 columns with 24px margins, featuring split-pane inspectors (live timeline + real-time bitstream spectrum).

- **Rhythm & Safe Areas**:
  - Strict 4px base increments control internal component density. 
  - Dynamic display cutouts, camera punch-holes, and system navigation pill bars are cushioned via explicit layout margins that preserve technical grid alignment.

## Elevation & Depth

To preserve zero-pixel emissions on OLED displays, the system does not utilize heavy drop shadows or diffused ambient light. Depth is created purely through **tonal stratification** and **luminescent borders**:

1. **Floor (Level 0 - `#000000`)**: Video frame raster, background letterboxes, native screen surface.
2. **Substrate (Level 1 - `#111115`)**: Embedded panes, track details, library collections, drawer backgrounds. Separated from Level 0 via `#22222A` 1px borders.
3. **Floating HUD (Level 2 - `#16161C` at 92% opacity with 12px backdrop blur)**: Media control bars, playback speed selectors, equalizer panels. Outlined with `rgba(255, 255, 255, 0.08)`.
4. **Active Instrument Layer (Level 3 - Luminescent Glow)**: Interactive playheads, current timeline scrub frames, and selected track nodes carry a tight, directional glow (`0 0 8px rgba(0, 240, 255, 0.35)`), highlighting critical interactive points without washing out nearby black levels.

## Shapes

The design system enforces a disciplined, compact shape system (`roundedness: 1`):

- **Micro-radii (4px)**: Buttons, telemetry chips, audio channel badges, queue items, and input fields. Evokes precision hardware modules rather than toy-like software cards.
- **Panel-radii (8px)**: Floating HUD panels, contextual bottom sheets, and modal hardware inspectors.
- **Strict Geometric Sharpness (0px)**: The main video viewport, timeline canvas bars, spectrum visualizer bins, and continuous divider lines remain crisp 90-degree cuts.

## Components

### Buttons
- **Primary Cyber-Action**: `#00F0FF` background, `#000000` text, 4px corner radius, bold Inter styling. Hover/Pressed state: `#00D2E0` with a subtle `0 0 10px rgba(0, 240, 255, 0.5)` halo.
- **Instrument Ghost Action**: `#111115` background, `#FFFFFF` text, bounded by a 1px `#22222A` border. Active state shifts the border to `#00F0FF`.
- **Playback Controls**: Centered transport triggers (Play/Pause, Frame Step) styled with high-contrast glyphs encased in 4px rounded frames. Monospaced indicators display micro-step offsets (`-1F`, `+1F`).

### Telemetry Badges & Chips
- **Codec / Hardware Flags (AV1, HEVC, HW-ACCEL)**: `#16161C` container, `#8B5CF6` micro-label (10px JetBrains Mono), bounded by a 1px `rgba(139, 92, 246, 0.3)` border.
- **Live Stream / Channel Badges**: Pitch black container, `#00F0FF` indicator dot, and monospace text showing audio format parameters (`7.1.4 ATMOS`, `FLAC 192k`).

### Seekbar & Timeline Scrubber
- **Rail**: 2px thick `#22222A` base.
- **Buffered Bar**: 2px thick `rgba(255, 255, 255, 0.25)`.
- **Active Playhead Line**: 2px solid `#00F0FF`.
- **Scrubber Node**: Sharp 2px × 14px vertical diamond/pill in Electric Cyan with an interactive timecode readout floating immediately overhead in JetBrains Mono.

### Lists & Queue Inspector
- Compact rows (44px height), `#111115` background separated by 1px `#16161C` hairline rules.
- Leading indicators display frame thumbnails with hardware tags; trailing indicators display track resolution (`4K UHD`) and audio formats in `#9CA3AF`.

### Toggles, Checkboxes & Selectors
- **Toggles**: Angular switch housing (`#16161C` with `#22222A` border). Switch knob shifts between `#9CA3AF` (inactive) and `#00F0FF` (engaged), radiating a cyan highlight on active state.
- **Checkboxes**: 16px × 16px square with 2px corner radius. `#000000` base with `#22222A` border; checked state turns the entire box `#00F0FF` with a black checkmark.

### Technical Input Fields
- Numeric input fields for audio-delay sync (ms) and subtitle offset calibration.
- Background: `#111115`, Border: 1px `#22222A`, Text: `#FFFFFF` (JetBrains Mono).
- Stepper targets (`+`, `-`) provide instantaneous haptic feedback and increment values in 10ms or 50ms steps.

### Audio Equalizer / Spectrum Cards
- Embedded surfaces in `#111115` with `#22222A` borders.
- Vertical EQ bands feature 2px wide track slots with `#00F0FF` slider caps, with real-time numeric decibel offsets (`+2.4 dB`) positioned cleanly beneath each slider band.