# Protanomaly-Friendly Gnome Terminal Color Scheme

## Problem

Standard terminal color schemes rely on deep reds (rgb ~192,28,40) for errors, alerts, and standard red slots. Protanomaly (red-weak) vision cannot distinguish these from dark backgrounds, making error messages, diffs, and syntax-highlighted identifiers invisible.

## Solution

Store a permanent, reusable script in the repo that creates a dedicated gnome-terminal profile named "ProtanomalySafe" with a protanomaly-safe palette.

### Approach: Dedicated Profile

Instead of mutating the existing profile in-place, the script will:
1. Create a new profile via `dconf` if it doesn't already exist
2. Name it "ProtanomalySafe" (visible-name)
3. Apply the protanomaly-safe palette to that profile
4. Leave existing profiles untouched

### Color Mapping

| Slot | Original (typical) | Replacement |
|------|-------------------|-------------|
| 1 Red | `rgb(192,28,40)` deep red | `rgb(230,150,0)` amber |
| 2 Green | `rgb(38,162,105)` dark green | `rgb(80,220,80)` bright lime |
| 5 Magenta | `rgb(163,71,186)` | `rgb(180,120,240)` violet |
| 8 Bright Black | `rgb(94,92,100)` dark gray | `rgb(160,160,170)` |
| 9 Bright Red | `rgb(246,97,81)` | `rgb(255,180,40)` bright orange |

### File Placement

- Script: `scripts/protanomaly-terminal.py`
- Creates profile named "ProtanomalySafe" via dconf
- Idempotent — safe to re-run, won't create duplicates
- User will set "ProtanomalySafe" as default via gnome-terminal preferences

### Success Criteria

- [ ] SC1: `scripts/protanomaly-terminal.py` exists in the repo
- [ ] SC2: Script creates a profile named "ProtanomalySafe" (or updates existing one)
- [ ] SC3: Script applies all 16 ANSI colors plus foreground/background/cursor
- [ ] SC4: NO color in the palette has a red channel > 60 when green < 100 (no deep reds)
- [ ] SC5: Color 8 (bright black) is distinguishable from background on typical displays
- [ ] SC6: Running the script multiple times is idempotent (no duplicate profiles)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
