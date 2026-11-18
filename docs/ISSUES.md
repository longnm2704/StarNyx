# StarNyx Redesign: Issues

Redesign from fixed stars to user-chosen Hugeicons symbols ("Night Lights" concept).
Hugeicons **Free** package (`stroke-rounded` style only).

Tick `[x]` when an issue is done.

**Rule:** when an issue is done, tick its `[x]` in this file and commit the change (issue work + this file) before moving on to the next issue.

**Suggested order:** R001 → R003 → R004 → R005 → (R006, R007) → (R008, R009) → R015. R012 and R013 can run in parallel from the start.


## Epic R-A - Icon Foundation

- [x] **STX-R001**: Add hugeicons and an AppIcon widget to replace AppSvgIcon
  - _Must-have · kind:setup · depends on: —_
  - Adopt Hugeicons (free package, `stroke-rounded` style only) as the app's icon system and introduce one shared `AppIcon` widget.
  - Acceptance criteria:
    - `hugeicons` is added to `pubspec.yaml`; only `package:hugeicons/styles/stroke_rounded.dart` is imported so unused styles are tree-shaken.
    - `AppIcon` exposes `icon`, `color`, `size`, `strokeWidth`; below ~14px it bumps `strokeWidth` so glyphs stay legible.
    - `AppSvgIcon` is removed once R002 lands; `flutter_svg` is dropped if nothing else uses it.
  - Notes:
    - Free package = stroke-rounded only. Filled states must be built with shapes (see R007), not solid icon styles.
- [x] **STX-R002**: Migrate all UI icons to Hugeicons and delete unused SVG assets
  - _Must-have · kind:polish · depends on: STX-R001_
  - Replace the 22 custom SVGs in `assets/icons/` and the 11 `Icons.*` usages (chevrons, check, send, language, circle) with Hugeicons equivalents.
  - Acceptance criteria:
    - No `assets/icons/ic_*.svg` references remain in `lib/`; unused SVG files are deleted.
    - Flag images `vn.png`, `us.png`, `jp.png` are kept.
    - No `Icons.*` / `CupertinoIcons.*` usages remain unless no Hugeicons equivalent exists (documented in the PR).
    - Visual check on welcome, home, switcher sheet, form, journal, settings, backup, about.
- [ ] **STX-R003**: Curate the habit symbol catalog (habit_symbols.dart)
  - _Must-have · kind:architecture · depends on: STX-R001_
  - Define the set of ~20 Hugeicons users can pick as a habit's symbol, keyed by stable string ids.
  - Acceptance criteria:
    - Single `const` map from stable key (e.g. `star`, `clover`, `flame`, `heart`, `moon`, `sprout`) to Hugeicons icon, grouped: Nature, Feelings, Energy, Sky, Daily life.
    - `star` is included and is the default/fallback key.
    - Lookup of an unknown key returns the `star` icon (never throws).
    - Every icon is checked at 10px on the dark background; screenshot sheet attached to the PR; illegible icons are excluded.
  - Notes:
    - Keys are a persisted data contract (DB + backups): never rename or reuse a key.

## Epic R-B - Data

- [ ] **STX-R004**: Add icon column to starnyxs (schema v3 → v4)
  - _Must-have · kind:architecture · depends on: STX-R003_
  - Persist the chosen symbol per habit.
  - Acceptance criteria:
    - `starnyxs.icon TEXT NOT NULL DEFAULT 'star'`; `schemaVersion` bumped to 4 with a migration from v3.
    - `StarNyx` entity, `copyWith`, `props`, mappers, DAO, create/update use cases carry `icon`.
    - Existing habits read back as `star` after migration.
    - Unknown keys render as `star` (via R003 fallback), no crash.
- [ ] **STX-R005**: Support optional icon field in backup export/import
  - _Must-have · kind:backup · depends on: STX-R004_
  - Include `icon` in backups without breaking existing backup files.
  - Acceptance criteria:
    - Export writes `icon` for each StarNyx.
    - Import treats `icon` as optional; missing → `star`; unknown key is kept/falls back without failing validation.
    - `backupFileVersion` is NOT bumped (the codec checks version equality, so a bump would reject every existing backup).
    - Tests: import an old backup without `icon`; round-trip a new backup with `icon`.

## Epic R-C - Form

- [ ] **STX-R006**: Symbol picker and 7-day preview in create/edit form
  - _Must-have · kind:feature · depends on: STX-R003, STX-R004_
  - Let users choose the symbol that lights up for each habit.
  - Acceptance criteria:
    - `StarnyxFormBloc` holds `icon` state with a change event; create defaults to `star`, edit loads the saved key.
    - Symbol grid (6 columns, grouped) sits above the color selector; selected item is clearly marked and has a semantics label.
    - Live preview row of 7 days (mix of lit / missed / future) using the selected symbol + color.
    - Saving persists the key; bloc and widget tests cover selection and save.

## Epic R-D - Home

- [ ] **STX-R007**: Render habit symbol and new day states in the year grid
  - _Must-have · kind:feature · depends on: STX-R001, STX-R004_
  - Replace fixed star assets in `HomeStarGrid` with the habit's symbol and make day states readable at ~10px.
  - Acceptance criteria:
    - Future / before-start: small dot.
    - Missed: symbol stroke at ~0.15 opacity, no glow.
    - Lit: filled accent-colored disc with soft glow, symbol drawn dark inside (state must read even if the glyph does not).
    - Today: ring outline when not lit; keeps current size emphasis.
    - Existing test keys `home-*-star-cell-*` are preserved.
- [ ] **STX-R008**: Replace firework with bloom animation and add haptics
  - _Must-have · kind:polish · depends on: STX-R007_
  - The 12-ray firework is star-shaped; replace it with a symbol-agnostic light-up effect.
  - Acceptance criteria:
    - `_StarFireworkPainter` removed; lighting a day shows a radial bloom + 6–8 soft particles in the accent color, keeping the existing scale pulse.
    - `HapticFeedback.lightImpact()` on light.
    - Un-lighting fades the cell, no celebration.
    - Animation respects reduced-motion (`MediaQuery.disableAnimations`).
- [ ] **STX-R009**: Make the check-in action explicit (Light today / Lit)
  - _Must-have · kind:feature · depends on: STX-R007, STX-R012_
  - Today the user must guess that tapping the date bar toggles completion.
  - Acceptance criteria:
    - `SelectedDateBar` shows a clear action with the habit symbol: unlit → "Light today" / "Thắp hôm nay"; lit → "Lit" / "Đã thắp" (still tappable to undo).
    - Disabled state (future, before start, outside 7-day window) is visually distinct and explains why via semantics/tooltip.
    - Separate snackbar messages for light vs unlight (currently both say "Check-in saved").
- [ ] **STX-R010**: Show symbol in header plus longest streak and yearly rate
  - _Should-have · kind:feature · depends on: STX-R007_
  - Give each habit a visible identity and surface stats that are already computed but hidden.
  - Acceptance criteria:
    - Habit symbol (~40px, accent color) above the title in `HomeShellView`.
    - `longestStreak` and `completionRateForYear` from `StarNyxProgressStats` are displayed alongside lit days and current streak.
    - Layout holds at 320px width and large text scale.
- [ ] **STX-R011**: Show habit symbol in the switcher sheet rows
  - _Should-have · kind:feature · depends on: STX-R001, STX-R004_
  - Habits are currently distinguished only by color in the switcher.
  - Acceptance criteria:
    - Each row in `ConstellationSwitcherSheet` shows the habit's symbol in its color.
    - Active habit highlight still works; reorder still works.

## Epic R-E - Copy & Visuals

- [ ] **STX-R012**: Rewrite vi/en/ja copy for the Night Lights voice
  - _Must-have · kind:polish · depends on: —_
  - All copy assumes stars/constellations ("chòm sao" appears 23× in vi.json, 19× in en.json). Rewrite in all three locales.
  - Acceptance criteria:
    - Plain nouns: "constellation / chòm sao" → "habit / thói quen"; metaphor lives in verbs ("light / thắp") and empty states only.
    - Tone: calm, warm, short, adult; no exclamation marks; no guilt on missed days.
    - Error messages are literal (e.g. "Quan sát bị gián đoạn" → "Không tải được nhật ký").
    - New keys: symbol label/helper, light/unlight messages, new-run streak message.
    - `pubspec.yaml` description no longer says "constellation-inspired".
    - vi, en, ja have identical key sets (test or script check).
  - Notes:
    - Examples (vi / en):
    - New habit: "Thói quen mới" / "New habit"
    - Empty: "Đêm còn tối. Chọn một việc nhỏ để thắp mỗi ngày." / "The night is still dark. Pick one small thing to light each day."
    - Lit: "Đã thắp hôm nay." / "Lit for today."
    - Stats: "{} ngày đã thắp · {} ngày liền" / "{} days lit · {} in a row"
    - Symbol helper: "Thứ sẽ sáng lên mỗi ngày bạn làm được." / "What lights up each day you show up."
- [ ] **STX-R013**: Localize the reminder notification body
  - _Must-have · kind:notification,bug · depends on: STX-R012_
  - `local_notification_service.dart:129` hardcodes `'Time to check in on your StarNyx.'`, so vi and ja users get English reminders.
  - Acceptance criteria:
    - Body comes from translations in the user's locale, e.g. "{title}: hôm nay bạn đã thắp chưa?" / "{title}: ready to light today?".
    - Scheduled reminders are re-synced after a language change.
    - Test covers body text for at least two locales.
- [ ] **STX-R014**: Replace star-specific decorative visuals
  - _Should-have · kind:polish · depends on: STX-R002_
  - Remove remaining fixed-star imagery outside the grid.
  - Acceptance criteria:
    - `welcome_hero_icon.dart`, `app_empty_state.dart`, `about_starnyx_sheet.dart` no longer use star assets; `ic_star.png` removed if unused.
    - `CosmicBackground` / `AnimatedCosmicStarfield` are kept (the night is the canvas in the new concept).

## Epic R-F - Quality

- [ ] **STX-R015**: Tests for migration, backups, grid states and symbol picker
  - _Must-have · kind:test · depends on: STX-R004 → STX-R009_
  - Cover the risky parts of the redesign.
  - Acceptance criteria:
    - Drift migration v3 → v4 test: existing rows get `star`.
    - Backup: old file without `icon` imports; new file round-trips.
    - Widget tests for each grid day state (dot / missed / lit / today).
    - Bloc + widget tests for the symbol picker.
    - `flutter test` passes.

## Epic R-G - Post-MVP

- [ ] **STX-R016**: Per-symbol light-up animations
  - _Nice-to-have · kind:polish,status:backlog · depends on: STX-R008_
  - Optional flavor per symbol (flame flicker, heart beat, clover spin) on top of the shared bloom.
  - Acceptance criteria:
    - Falls back to the shared bloom for symbols without a custom animation.
    - Respects reduced motion.
- [ ] **STX-R017**: Quiet milestones at 7 / 30 / 100 days
  - _Nice-to-have · kind:feature,status:backlog · depends on: STX-R008_
  - Mark streak and total milestones without gamified noise.
  - Acceptance criteria:
    - Derived from existing completion data; no new table.
    - One calm message + slightly stronger glow when a milestone is reached; never shown for losses.
- [ ] **STX-R018**: Shareable 'Your year' image
  - _Nice-to-have · kind:feature,status:backlog · depends on: STX-R007_
  - Render the year grid with the habit symbol as an image and share it via `share_plus` (already a dependency).
  - Acceptance criteria:
    - Image contains no journal text; user previews before sharing.
- [ ] **STX-R019**: Spec: weekly targets (e.g. 3× per week)
  - _Nice-to-have · kind:architecture,status:backlog · depends on: —_
  - Weekly goals change streak semantics; write a spec before any code.
  - Acceptance criteria:
    - Spec defines streak, completion rate and grid rendering under weekly targets, plus data/backup changes.
