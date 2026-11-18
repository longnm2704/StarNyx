# Spec: STX-R018 — Shareable 'Your year' image

**Status:** Backlog / Nice-to-have · kind:feature · depends on: STX-R007

## Goal
Render the home year grid with the user's habit symbol as an image and share it via `share_plus`. No journal text included; user previews before sharing.

## Design

### Image content
- 365-day grid (or 366 for leap years) using the user's habit symbol
- Day states rendered: future dot, missed (low opacity), lit (filled disc), today (ring)
- Current symbol color as accent
- No journal entries, no dates, no text labels on the image itself
- Clean, minimal aesthetic matching the app's night-light theme

### Flow
1. User taps "Share your year" from home shell or settings
2. App renders the grid to an image (offscreen render or screenshot)
3. Preview screen shows the image with a "Share" button
4. User taps Share → `share_plus` share sheet opens

### Implementation
- Use `share_plus` (already a dependency, `^12.0.2`)
- Render grid via a `RepaintBoundary` + `toImage()` or custom painter to image
- Preview screen in `lib/features/home/presentation/pages/year_share_preview_page.dart`
- Share action in `lib/features/home/presentation/widgets/home_shell_view.dart`

### Files
- `lib/features/home/presentation/pages/year_share_preview_page.dart` — preview + share
- `lib/features/home/presentation/widgets/year_grid_image.dart` — grid-to-image rendering
- `lib/features/home/presentation/widgets/home_shell_view.dart` — share entry point

### Acceptance
- Image contains no journal text
- User previews before sharing
- Uses `share_plus` for sharing

## Out of scope
- Editing/annotating the image before sharing
- Scheduling automatic shares
- Multiple year comparison images
