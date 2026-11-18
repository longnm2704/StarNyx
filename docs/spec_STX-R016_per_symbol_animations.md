# Spec: STX-R016 — Per-symbol light-up animations

**Status:** Backlog / Nice-to-have · kind:polish · depends on: STX-R008

## Goal
Add optional per-symbol animation variants on top of the shared bloom effect when a day lights up in the home grid. Symbols without a custom animation fall back to the shared bloom.

## Design

### Animation variants
| Symbol | Animation | Description |
|--------|-----------|-------------|
| `flame` | Flicker | Flame shape pulses with varying opacity/size |
| `heart` | Beat | Heart scales up/down gently |
| `clover` | Spin | Clover rotates slightly |
| `leaf` | Float | Leaf drifts up/down |
| All others | Bloom | Shared bloom painter (default fallback) |

### Implementation
- Extend `_BloomPainter` or create per-symbol painter subclasses
- `_GridStarCell` selects the painter based on `symbolKey`
- Animation respects `MediaQuery.disableAnimations` (no animation when reduced motion is on)
- Default fallback: shared `_BloomPainter` for unknown symbols

### Files
- `lib/features/home/presentation/widgets/home_star_grid.dart` — painter selection logic
- New: `lib/features/home/presentation/widgets/symbol_animations.dart` — per-symbol painters

### Acceptance
- Falls back to shared bloom for symbols without custom animation
- Respects reduced motion (`MediaQuery.disableAnimations`)
- No change to existing bloom behavior for default symbols

## Out of scope
- Sound effects
- Haptic differentiation per symbol
- User-configurable animations
