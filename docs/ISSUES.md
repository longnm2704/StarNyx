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
- [x] **STX-R003**: Curate the habit symbol catalog (habit_symbols.dart)
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

- [x] **STX-R004**: Add icon column to starnyxs (schema v3 → v4)
  - _Must-have · kind:architecture · depends on: STX-R003_
  - Persist the chosen symbol per habit.
  - Acceptance criteria:
    - `starnyxs.icon TEXT NOT NULL DEFAULT 'star'`; `schemaVersion` bumped to 4 with a migration from v3.
    - `StarNyx` entity, `copyWith`, `props`, mappers, DAO, create/update use cases carry `icon`.
    - Existing habits read back as `star` after migration.
    - Unknown keys render as `star` (via R003 fallback), no crash.
- [x] **STX-R005**: Support optional icon field in backup export/import
  - _Must-have · kind:backup · depends on: STX-R004_
  - Include `icon` in backups without breaking existing backup files.
  - Acceptance criteria:
    - Export writes `icon` for each StarNyx.
    - Import treats `icon` as optional; missing → `star`; unknown key is kept/falls back without failing validation.
    - `backupFileVersion` is NOT bumped (the codec checks version equality, so a bump would reject every existing backup).
    - Tests: import an old backup without `icon`; round-trip a new backup with `icon`.

## Epic R-C - Form

- [x] **STX-R006**: Symbol picker and 7-day preview in create/edit form
  - _Must-have · kind:feature · depends on: STX-R003, STX-R004_
  - Let users choose the symbol that lights up for each habit.
  - Acceptance criteria:
    - `StarnyxFormBloc` holds `icon` state with a change event; create defaults to `star`, edit loads the saved key.
    - Symbol grid (6 columns, grouped) sits above the color selector; selected item is clearly marked and has a semantics label.
    - Live preview row of 7 days (mix of lit / missed / future) using the selected symbol + color.
    - Saving persists the key; bloc and widget tests cover selection and save.

## Epic R-D - Home

- [x] **STX-R007**: Render habit symbol and new day states in the year grid
  - _Must-have · kind:feature · depends on: STX-R001, STX-R004_
  - Replace fixed star assets in `HomeStarGrid` with the habit's symbol and make day states readable at ~10px.
  - Acceptance criteria:
    - Future / before-start: small dot.
    - Missed: symbol stroke at ~0.15 opacity, no glow.
    - Lit: filled accent-colored disc with soft glow, symbol drawn dark inside (state must read even if the glyph does not).
    - Today: ring outline when not lit; keeps current size emphasis.
    - Existing test keys `home-*-star-cell-*` are preserved.
- [x] **STX-R008**: Replace firework with bloom animation and add haptics
  - _Must-have · kind:polish · depends on: STX-R007_
  - The 12-ray firework is star-shaped; replace it with a symbol-agnostic light-up effect.
  - Acceptance criteria:
    - `_StarFireworkPainter` removed; lighting a day shows a radial bloom + 6–8 soft particles in the accent color, keeping the existing scale pulse.
    - `HapticFeedback.lightImpact()` on light.
    - Un-lighting fades the cell, no celebration.
    - Animation respects reduced-motion (`MediaQuery.disableAnimations`).
- [x] **STX-R009**: Make the check-in action explicit (Light today / Lit)
  - _Must-have · kind:feature · depends on: STX-R007, STX-R012_
  - Today the user must guess that tapping the date bar toggles completion.
  - Acceptance criteria:
    - `SelectedDateBar` shows a clear action with the habit symbol: unlit → "Light today" / "Thắp hôm nay"; lit → "Lit" / "Đã thắp" (still tappable to undo).
    - Disabled state (future, before start, outside 7-day window) is visually distinct and explains why via semantics/tooltip.
    - Separate snackbar messages for light vs unlight (currently both say "Check-in saved").
- [x] **STX-R010**: Show symbol in header plus longest streak and yearly rate
  - _Should-have · kind:feature · depends on: STX-R007_
  - Give each habit a visible identity and surface stats that are already computed but hidden.
  - Acceptance criteria:
    - Habit symbol (~40px, accent color) above the title in `HomeShellView`.
    - `longestStreak` and `completionRateForYear` from `StarNyxProgressStats` are displayed alongside lit days and current streak.
    - Layout holds at 320px width and large text scale.
- [x] **STX-R011**: Show habit symbol in the switcher sheet rows
  - _Should-have · kind:feature · depends on: STX-R001, STX-R004_
  - Habits are currently distinguished only by color in the switcher.
  - Acceptance criteria:
    - Each row in `ConstellationSwitcherSheet` shows the habit's symbol in its color.
    - Active habit highlight still works; reorder still works.

## Epic R-E - Copy & Visuals

- [x] **STX-R012**: Rewrite vi/en/ja copy for the Night Lights voice
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
- [x] **STX-R013**: Localize the reminder notification body
  - _Must-have · kind:notification,bug · depends on: STX-R012_
  - `local_notification_service.dart:129` hardcodes `'Time to check in on your StarNyx.'`, so vi and ja users get English reminders.
  - Acceptance criteria:
    - Body comes from translations in the user's locale, e.g. "{title}: hôm nay bạn đã thắp chưa?" / "{title}: ready to light today?".
    - Scheduled reminders are re-synced after a language change.
    - Test covers body text for at least two locales.
- [x] **STX-R014**: Replace star-specific decorative visuals
  - _Should-have · kind:polish · depends on: STX-R002_
  - Remove remaining fixed-star imagery outside the grid.
  - Acceptance criteria:
    - `welcome_hero_icon.dart`, `app_empty_state.dart`, `about_starnyx_sheet.dart` no longer use star assets; `ic_star.png` removed if unused.
    - `CosmicBackground` / `AnimatedCosmicStarfield` are kept (the night is the canvas in the new concept).

## Epic R-F - Quality

- [x] **STX-R015**: Tests for migration, backups, grid states and symbol picker
  - _Must-have · kind:test · depends on: STX-R004 → STX-R009_
  - Cover the risky parts of the redesign.
  - Acceptance criteria:
    - Drift migration v3 → v4 test: existing rows get `star`.
    - Backup: old file without `icon` imports; new file round-trips.
    - Widget tests for each grid day state (dot / missed / lit / today).
    - Bloc + widget tests for the symbol picker.
    - `flutter test` passes.

## Epic R-G - Post-MVP

- [x] **STX-R016**: Per-symbol light-up animations
  - _Nice-to-have · kind:polish,status:backlog · depends on: STX-R008_
  - Optional flavor per symbol (flame flicker, heart beat, clover spin) on top of the shared bloom.
  - Acceptance criteria:
    - Falls back to the shared bloom for symbols without a custom animation.
    - Respects reduced motion.
- [x] **STX-R017**: Quiet milestones at 7 / 30 / 100 days
  - _Nice-to-have · kind:feature,status:backlog · depends on: STX-R008_
  - Mark streak and total milestones without gamified noise.
  - Acceptance criteria:
    - Derived from existing completion data; no new table.
    - One calm message + slightly stronger glow when a milestone is reached; never shown for losses.
- [x] **STX-R018**: Shareable 'Your year' image
  - _Nice-to-have · kind:feature,status:backlog · depends on: STX-R007_
  - Render the year grid with the habit symbol as an image and share it via `share_plus` (already a dependency).
  - Acceptance criteria:
    - Image contains no journal text; user previews before sharing.
- [x] **STX-R019**: Spec: weekly targets (e.g. 3× per week)
  - _Nice-to-have · kind:architecture,status:backlog · depends on: —_
  - Weekly goals change streak semantics; write a spec before any code.
  - Acceptance criteria:
    - Spec defines streak, completion rate and grid rendering under weekly targets, plus data/backup changes.

---

# StarNyx UI Redesign: Issues (Obsidian Lumina)

Redesign the whole app to the **Obsidian Lumina** design system
(`docs/app_ui_redesign/obsidian_lumina/DESIGN.md`) with a 4-tab bottom navigation
(Habits / Overview / Journal / Settings).

Mockups live in `docs/app_ui_redesign/<screen>/{code.html,screen.png}`. Each issue
names the mockup it implements. Screens that were authored against Luminescent
Precision (`chao_mung`, `chon_thoi_quen_mau`, `thiet_lap_nhac_nho`,
`hoan_tat_onboarding`, `them_thoi_quen`, `tong_quan_thong_ke`,
`sao_luu_xuat_du_lieu`, `chi_tiet_nhat_ky`) must be **ported to Obsidian Lumina**
(Space Grotesk / Plus Jakarta Sans / JetBrains Mono, cyan secondary `#4cd7f6`,
true-black surface tiers), not copied verbatim.

Tick `[x]` when an issue is done.

**Rule:** when an issue is done, tick its `[x]` in this file and commit the change (issue work + this file) before moving on to the next issue.

**Suggested order:** U001 → U002 → U003 → U004 → U005 → U006 → U007 → U008 → U009 → U010 → U011 → U012 → U013 → U015 → U016 → U017 → U018 → U019 → U021 → U020 → U022 → U023 → U024. U014 is optional and can be done last.

**Non-goals / mockup fidelity rules (apply to every issue):**
- StarNyx is offline-first with no account and no cloud. Do **not** build: iCloud Sync, Cloud Sync, "OLED Sync", "AI SMART", "Cảm biến tự động", "PRO" badges, "Phiên bản gốc kế thừa", "Xuất báo cáo định kỳ", "Đánh giá ứng dụng", "Tự động sao lưu hàng ngày", "TẦN SUẤT ÁP DỤNG" (weekly targets — see STX-R019 spec, not implemented).
- Replace mockup-only metrics with real data or drop them: "Kỷ luật tự thân PRO" → active habit + real streak; "NHỊP SINH HỌC TỐI ƯU" → drop; "+12%" → drop or compute a real delta; "Cảm xúc hiện tại" / mood / energy / sleep / tags → drop unless U014 is done.
- Replace mockup branding ("Home Habits", "Journal Notes", "Overview List", "New Habit", "Habit Tracker", "LUMINESCENT TRACKER") with localized StarNyx strings.
- "Xóa toàn bộ dữ liệu ứng dụng" (VÙNG NGUY HIỂM) is a real, useful feature for a privacy-first app → keep (U018).
- "Chỉnh sửa ghi chép" (journal detail) requires journal edit support → U015.
- "Chấm sáng #N" = completion count for that habit; "Mục tiêu 22:30" = `reminderTime`; "Đã lưu lúc 22:45" = `createdAt`.

## Epic U-A - Design System Foundation

- [x] **STX-U001**: Bundle Space Grotesk, Plus Jakarta Sans and JetBrains Mono
  - _Must-have · kind:setup · depends on: —_
  - Design: `obsidian_lumina/DESIGN.md` (Typography)
  - The app currently uses the platform default font; Obsidian Lumina needs three families.
  - Acceptance criteria:
    - `google_fonts` is added to `pubspec.yaml` (or the three families are bundled as assets under `assets/fonts/` with `fonts:` declared — pick one and document it in the PR).
    - `AppFonts` (or equivalent) exposes `headline` (Space Grotesk), `body` (Plus Jakarta Sans), `mono` (JetBrains Mono).
    - All numeric/metric styles enable tabular figures (`FontFeature.tabularFigures()`).
    - No runtime network fetch in release builds if `google_fonts` is used (bundle the fonts or use `GoogleFonts.config.allowRuntimeFetching = false`).
    - `flutter test` passes.

- [x] **STX-U002**: Replace AppColors with the Obsidian Lumina palette
  - _Must-have · kind:architecture · depends on: —_
  - Design: `obsidian_lumina/DESIGN.md` (Colors, Elevation & Depth)
  - Acceptance criteria:
    - `AppColors` exposes the Obsidian Lumina tokens: `background #000000`, `surfaceLevel1 #0A0A0C`, `surfaceLevel2 #121215`, `surfaceLevel3 #1A1A1F`, `sheet #16161A`, `borderSubtle rgba(255,255,255,0.08)`, `borderFocus rgba(255,255,255,0.18)`, `textPrimary #F9FAFB`, `textSecondary #9CA3AF`, `textTertiary #4B5563`, `primary #10B981`, `secondary #06B6D4`, `tertiary #F59E0B`, `error #F43F5E` (destructive) / `#FFB4AB` (on-dark error text).
    - Material 3 `ColorScheme` in `AppTheme` is built from these tokens (primary emerald, secondary cyan, tertiary amber, error coral), not `fromSeed`.
    - Legacy cosmic tokens (`backgroundMid`, `backgroundBottom`, `accentViolet`, `accentPink`, `accentLavender`, `accentBlue`, `accentOrange`, `star`, `starMuted`, `sheetTop`, `sheetMid`, `sheetBg`, `pickerBg`, `formCard*`, `previewOuter/Inner`, `lockIcon`, `iconMuted`, `switchTrack`, `sysGreen/Blue/Purple/Orange`, `screenGradient`, `accentGradient`, `accentFillGradient`) are removed or marked `@Deprecated` with a migration note; no new code references them.
    - `starnyxPresetColorHexes` is updated to the mockup palette (violet `#8B5CF6`-ish, blue `#2563EB`-ish, amber `#F59E0B`-ish, emerald `#10B981`-ish) — confirm exact hexes from `them_thoi_quen/code.html` / `chinh_sua_thoi_quen/code.html`.
    - `AppRadius` gains `card = 16`, `sheet = 32` (top), keeps `pill = 9999`; `AppSpacing` gains `pageHorizontal = 16` (mockup uses 1rem margins); `AppLayout.contentMaxWidth = 680`.
    - `AppSize.ctaHeight = 52`, `AppSize.iconButton = 44`, `AppSize.inputMinHeight = 50`.

- [x] **STX-U003**: Rebuild AppTheme typography and component themes
  - _Must-have · kind:architecture · depends on: STX-U001, STX-U002_
  - Design: `obsidian_lumina/DESIGN.md` (Typography, Components)
  - Acceptance criteria:
    - `TextTheme` maps: `headlineLarge/Medium/Small` → Space Grotesk 28/24/20 w700/600/600 with negative tracking; `titleLarge/Medium` → Plus Jakarta Sans 18/16 w600; `bodyLarge/Medium/Small` → Plus Jakarta Sans 16/14/12 w400 h 1.5/1.43/1.5; `labelLarge/Medium/Small` → JetBrains Mono 12/12/10 w500 with 0.04–0.06em tracking.
    - `AppBarTheme`, `CardThemeData`, `DividerThemeData`, `SnackBarThemeData`, `InputDecorationTheme`, `BottomSheetThemeData`, `NavigationBarThemeData` (new, for U006) use the new tokens; no cosmic gradients remain.
    - `AppTheme.dark()` is the only theme; light theme is out of scope.
    - Widgetbook/golden or at least a `flutter test` smoke test renders `AppTheme.dark()` without overflow at 320px and at 2.0 text scale.

- [x] **STX-U004**: Restyle shared widgets to Obsidian Lumina
  - _Must-have · kind:polish · depends on: STX-U002, STX-U003_
  - Design: `obsidian_lumina/DESIGN.md` (Components: Buttons, Habit Cards, Checkboxes, Chips, Journal Entry Card)
  - Acceptance criteria:
    - `GradientOutlineButton` → `AppPrimaryButton` (pill, `#10B981` fill, black w700 label, 52px height, pressed scale 0.98 + `glow-emerald` `0 0 24px rgba(16,185,129,0.15)`); a ghost/secondary variant (`#0A0A0C` fill, hairline border, `#F9FAFB` label) is added.
    - `AppEmptyState`, `AppErrorState`, `AppLoadingIndicator`, `AppSectionTitle`, `AppConfirmDialog`, `AppSheetBackground` use surface tiers + hairlines, no gradients, no starfield.
    - `AppConfirmDialog` destructive action uses `#F43F5E` fill with black label (matches `xac_nhan_xoa_thoi_quen`); neutral action uses white fill with black label.
    - `AppIcon` unchanged (already Hugeicons stroke-rounded).
    - `CosmicBackground` / `AnimatedCosmicStarfield` are deleted; screens use a plain `#000000` scaffold (or a very subtle radial emerald glow only on the home header, per `trang_chu`).
    - `AppSheetBackground` is deleted once no caller remains (sheets are replaced by full-screen routes in U006+).

- [x] **STX-U005**: Remove cosmic/starfield remnants and dead assets
  - _Should-have · kind:polish · depends on: STX-U004_
  - Acceptance criteria:
    - No references to `CosmicBackground`, `AnimatedCosmicStarfield`, `AppColors.screenGradient`, `accentGradient`, `accentFillGradient`, `sheetTop/Mid`, `backgroundMid/Bottom` remain in `lib/`.
    - `assets/icons/ic_star.png` removed if unused; `assets/logo.png`, `splash.png`, `splash_background.png` are regenerated or replaced with the Obsidian Lumina mark (or removed if the splash is reconfigured) — document in the PR.
    - `flutter_native_splash.yaml` and `flutter_launcher_icons.yaml` updated to the new background (`#000000`) and icon if assets change.
    - `flutter analyze` clean.

## Epic U-B - Navigation Shell

- [x] **STX-U006**: Introduce 4-tab bottom navigation (Habits / Overview / Journal / Settings)
  - _Must-have · kind:architecture · depends on: STX-U003, STX-U004_
  - Design: `trang_chu/code.html`, `tong_quan_thong_ke/code.html`, `nhat_ky/code.html`, `cai_dat/code.html` (bottom `<nav>`)
  - Acceptance criteria:
    - New `AppShell` (or `MainShell`) widget hosts an `IndexedStack` of 4 tabs with a `NavigationBar` styled per mockup: `#000000`/85% + `backdrop-blur`, hairline top border, 20px Hugeicons stroke-rounded icons, `label-sm` JetBrains Mono labels, active tab tinted emerald with a small indicator dot.
    - Tabs: Habits (`strokeRoundedCheckmarkCircle02` or equivalent), Overview (`strokeRoundedChartBarLine` / `strokeRoundedAnalytics01`), Journal (`strokeRoundedNote01` / `strokeRoundedEdit02`), Settings (`strokeRoundedSettings01`). Exact Hugeicons names to be confirmed against `hugeicons` 4.4.0.
    - `AppRoutes` gains `/habits`, `/overview`, `/journal`, `/settings`; `AppRouter.onGenerateRoute` builds the shell; deep links / initial route default to `/habits`.
    - `HomePage` no longer owns the settings/journal/create entry points via bottom sheets; those move to their tabs / full-screen routes.
    - `HomeSwipeUpHint` and the swipe-up gesture are removed; `ConstellationSwitcherSheet` is removed (replaced by U009 habit list screen).
    - State (scroll position, selected tab) is preserved across tab switches (`IndexedStack`).
    - Widget test: tapping each tab shows the right screen; back button on a non-Habits tab returns to Habits (or exits, per platform convention — document choice).

## Epic U-C - Habits Tab (Home)

- [x] **STX-U007**: Restyle the Habits (home) screen to `trang_chu`
  - _Must-have · kind:feature · depends on: STX-U004, STX-U006_
  - Design: `docs/app_ui_redesign/trang_chu/{code.html,screen.png}`
  - Acceptance criteria:
    - Top app bar: emerald dot + localized StarNyx wordmark (Space Grotesk w700) on the left; search icon and circular avatar/profile button on the right. Search opens a habit filter/jump sheet (or is removed if not scoped — document choice; do not ship a dead button).
    - Header: habit symbol in a large amber-tinted circle with soft glow (per mockup), habit title in Space Grotesk w700 28px, description in amber `#F59E0B` (or accent) below.
    - Year grid: 18×N dot matrix on a `#0A0A0C` rounded-2xl card with hairline border; lit cells are amber/accent filled discs with glow; missed cells are dim dots; today has a ring; future cells are faint dots. Cell size and gap match mockup (~12px cells, 3px gap).
    - Below grid: year stepper row (`‹ 2026 ›` + "Hôm nay" pill + "N ngày còn lại" in amber mono).
    - Selected-date bar: large pill with chevrons, date in Space Grotesk, and the light/unlight action with the habit symbol (reuse `SelectedDateBar` logic, restyle).
    - Stats row: `{} ngày đã thắp · {} ngày liền · {} tốt nhất · {}% tỉ lệ` in JetBrains Mono, amber for the rate.
    - Bottom nav is provided by U006; the mockup's in-screen nav is not duplicated.
    - Layout holds at 320px width and 2.0 text scale; grid remains square cells.
    - Existing test keys `home-*-star-cell-*` are preserved.
    - `HomeLoadingView` and `HomeErrorView` are restyled to match (skeleton on `#0A0A0C`, no starfield).

- [x] **STX-U008**: Habit list / switcher screen (`quan_ly_thoi_quen`)
  - _Must-have · kind:feature · depends on: STX-U006, STX-U007_
  - Design: `docs/app_ui_redesign/quan_ly_thoi_quen/{code.html,screen.png}`
  - Replaces `ConstellationSwitcherSheet` with a full-screen route (pushed from the Habits tab app bar or a "switch habit" affordance).
  - Acceptance criteria:
    - Header: back chevron, title "Bảng thói quen" (localized), subtitle "Chuyển, viết hoặc điều chỉnh".
    - "Đang tập trung" pill (cyan outline, cyan dot + label) showing the active habit.
    - Three action tiles: Settings (→ Settings tab), Journal (→ Journal tab), Add (→ create form).
    - "Các thói quen của bạn" section with a "Sửa" toggle that enables reorder mode (drag handles), reusing `SaveStarNyxOrderUseCase`.
    - Each habit row: tinted rounded card (accent at ~12% opacity), leading squircle with the habit symbol in the accent color, title in accent, subtitle `HH:mm · <description or reminder>`, trailing edit pencil.
    - Tapping a row selects it as active and pops back to Habits; tapping the pencil opens the edit form.
    - Footer: `CHUỖI {}/{} HOÀN THÀNH` (mono, emerald dot) — real data: habits with a completion today / total habits. Drop "Đồng bộ đám mây".
    - Empty state when there are no habits (reuse `AppEmptyState`).
    - Widget tests: select, reorder, edit, empty state.

## Epic U-D - Overview Tab

- [ ] **STX-U009**: Aggregate stats use case for Overview
  - _Must-have · kind:architecture · depends on: —_
  - Design: `tong_quan_thong_ke/code.html` (data requirements)
  - Acceptance criteria:
    - New `LoadOverviewStatsUseCase` returns, for a given year (and optionally a week/month range): total lit days across all habits, best current streak across habits, per-habit `{ id, title, icon, color, currentStreak, longestStreak, completedCountForYear, validDayCountForYear, completionRateForYear }`, and an overall completion rate (sum of completed / sum of valid days).
    - Reuses `StreakUtils` and `LoadStarNyxProgressStatsUseCase` logic; no duplicated streak math.
    - New `OverviewBloc` (or extend `HomeBloc` — prefer a dedicated bloc) exposes `OverviewState` with `status`, `year`, `range` (week/month/year), `stats`.
    - Unit tests cover: empty DB, one habit, multiple habits with different start dates, year boundary.
    - No schema change.

- [ ] **STX-U010**: Overview screen (`tong_quan_thong_ke`)
  - _Must-have · kind:feature · depends on: STX-U006, STX-U009_
  - Design: `docs/app_ui_redesign/tong_quan_thong_ke/{code.html,screen.png}`
  - Acceptance criteria:
    - Header: small mono overline "TỔNG QUAN" (localized, not "LUMINESCENT TRACKER") + title "Tổng quan" (Space Grotesk w700) + avatar button.
    - Range selector: three pills — "Tuần này" / "Tháng này" / "Năm {year}" — active pill is emerald-tinted with emerald border and text.
    - Hero card: "TỶ LỆ HOÀN THÀNH" mono label, big percentage (Space Grotesk w700 40px, tabular), a circular progress ring in emerald with glow, and a sub-line "Đã thắp {n} / {total} ngày" (drop the fake "+12%" and "Vượt mục tiêu 80%" unless a real target is added — document choice).
    - Two stat tiles: "ĐÃ THẮP SÁNG" (flame icon, `{n} / 365`, `{pct}% chặng đường`) and "CHUỖI DÀI NHẤT" (trophy icon, `{n} ngày`, "Kỷ lục cá nhân").
    - "Ma Trận Kỷ Luật" heatmap card: 7×N grid of rounded squares colored by completion density for the selected range (emerald scale; amber for the current week if desired). Legend "Ít → Nhiều".
    - "Theo Từng Thói Quen" list: per-habit row with symbol in accent-tinted circle, title, "Chuỗi {n} ngày liền", trailing percentage (accent) and a thin progress bar. "Chi tiết" link is optional — if present it navigates to the habit's edit screen or is removed.
    - Drop "NHỊP SINH HỌC TỐI ƯU" / "Thời Gian Tập Trung Cao Nhất" entirely (not derivable).
    - Empty state when no habits exist.
    - Layout holds at 320px and 2.0 text scale; heatmap scrolls horizontally if needed.
    - Widget tests: renders with mocked bloc for empty / one habit / many habits; range switching dispatches the right event.

## Epic U-E - Journal Tab

- [ ] **STX-U011**: Journal list screen (`nhat_ky`)
  - _Must-have · kind:feature · depends on: STX-U006_
  - Design: `docs/app_ui_redesign/nhat_ky/{code.html,screen.png}`
  - Replaces `JournalBottomSheet` with a full-screen tab.
  - Acceptance criteria:
    - Header: close/back affordance is removed (it's a tab); title "Nhật ký" (Space Grotesk w700) with a small emerald dot + "Đang đồng bộ" replaced by a real subtitle (e.g. entry count or the active habit name) or dropped.
    - Search icon filters entries by content (local, in-memory); calendar icon jumps to a date (or is removed — document choice; do not ship a dead button).
    - Drop "Cảm xúc hiện tại" mood chips unless U014 is done.
    - Entry list: each card shows a colored dot (habit accent), entry title (first line or "Nhật ký ngày {n}"), timestamp in mono (`dd/MM/yyyy HH:mm`), body text (Plus Jakarta Sans, 1.6 line-height, max 4 lines with "Xem thêm"), and tag chips only if U014 is done.
    - Tapping a card opens the journal detail screen (U012).
    - Bottom input bar: mic icon is removed (no voice feature); text field "Viết vài dòng về hôm nay..." + amber circular send button (disabled state when empty).
    - Entries are shown for the **active habit** by default, with a habit switcher affordance (or an "All habits" filter) — document choice; the mockup implies a single stream.
    - Empty state, loading state, error state all restyled.
    - Widget tests: list renders, search filters, send dispatches save, empty state.

- [ ] **STX-U012**: Journal detail screen (`chi_tiet_nhat_ky`)
  - _Must-have · kind:feature · depends on: STX-U011_
  - Design: `docs/app_ui_redesign/chi_tiet_nhat_ky/{code.html,screen.png}`
  - Acceptance criteria:
    - Header: back chevron, title "Chi tiết nhật ký" (localized), overflow menu (delete entry) and avatar.
    - Meta row: habit chip (symbol + "{habit} · Mục tiêu {reminderTime}") and "Chấm sáng #{n}" chip (n = completion count for that habit up to and including the entry date) in emerald.
    - Date line: calendar icon + "Thứ Hai, 19/11/2026 · Đã lưu lúc 22:45" (mono).
    - "TRẠNG THÁI PHẢN CHIẾU" card: drop mood/energy/sleep unless U014 is done; if U014 is not done, omit the whole card.
    - "GHI NHẬN SÂU" section: entry title (first line, Space Grotesk w600) + full body text.
    - "ĐIỂM CỐT LÕI" pull-quote block: only if the entry has a detectable quote — otherwise omit. Do not fabricate.
    - "Chỉ số ngày ghi nhận" grid: drop "Lên giường / Tắt màn hình / Nhịp tim / Duy trì liên tục" unless U014 is done; "Duy trì liên tục {n} ngày" (current streak) is derivable and may be kept.
    - "TỪ KHÓA LIÊN KẾT" chips: only if U014 is done.
    - Primary CTA: "Chỉnh sửa ghi chép" (emerald pill) → opens the journal editor prefilled with the entry (requires U015).
    - Secondary CTA: "Chia sẻ thói quen" → reuses the share-year-image flow from STX-R018 if available, otherwise removed.
    - Destructive link: "Xóa nhật ký này" → confirm dialog → delete + pop.
    - Widget tests: renders with a mocked entry; delete flow; edit navigation.

- [ ] **STX-U013**: Journal edit support
  - _Must-have · kind:feature · depends on: STX-U011_
  - Acceptance criteria:
    - `JournalBloc` gains `JournalEntryUpdated` event and `updateJournalEntry` path in `SaveJournalEntryUseCase` (or a new `UpdateJournalEntryUseCase`) that preserves `id` and `createdAt`, updates `content` and `date`.
    - `JournalEntryRepository` gains `updateJournalEntry(JournalEntry)`; Drift implementation updates by `id`.
    - Editor screen (reuse the input area from U011 as a full-screen editor) supports create and edit modes.
    - Backup export/import round-trips edited entries unchanged (no schema change; `id` is already exported).
    - Unit + bloc tests for update; widget test for edit flow.

- [ ] **STX-U014**: (Optional) Journal metadata — mood, energy, sleep, tags
  - _Nice-to-have · kind:architecture,status:backlog · depends on: STX-U011_
  - Only do this if the team wants the mockup's "Cảm xúc hiện tại" / "TRẠNG THÁI PHẢN CHIẾU" / "TỪ KHÓA LIÊN KẾT" to be real.
  - Acceptance criteria:
    - Schema v4 → v5: `journal_entries` gains `mood TEXT NULL`, `energy INTEGER NULL` (1–5), `sleep_minutes INTEGER NULL`, `tags TEXT NULL` (JSON array). Migration tested.
    - `JournalEntry` entity, mappers, DAO, backup codec (optional fields, no version bump) carry the new columns.
    - Journal editor exposes mood picker (4 options: Bình an / Đầy năng lượng / Tập trung / Mỏi mệt), energy dots (1–5), sleep duration picker, tag input.
    - Journal detail renders the metadata card and tag chips.
    - All new fields are optional; old backups import cleanly.
    - If this issue is rejected, U011/U012 must ship without those sections.

## Epic U-F - Settings Tab

- [ ] **STX-U015**: Settings screen (`cai_dat`)
  - _Must-have · kind:feature · depends on: STX-U006_
  - Design: `docs/app_ui_redesign/cai_dat/{code.html,screen.png}`
  - Replaces `SettingsBottomSheet` with a full-screen tab.
  - Acceptance criteria:
    - Header: back chevron is removed (tab); title "Cài đặt" (Space Grotesk w700) + subtitle "Tùy biến & Hệ thống" (mono, muted). Drop "OLED Sync" pill.
    - Profile card: squircle with a person icon (or the app logo), title "Kỷ luật tự thân" → replace with the active habit's title or "StarNyx" + real subtitle "Chuỗi thói quen: {n} ngày liên tục" (real streak). Drop "PRO" badge and the green check.
    - Section "TÙY CHỌN CHUNG" (mono overline, right-aligned count "3 mục" → real count or drop):
      - Ngôn ngữ — value = current locale name, chevron → language picker (reuse existing `_showLanguagePicker`, restyled).
      - Thông báo & Nhắc nhở — subtitle = real next reminder time across habits (or "Chưa có nhắc nhở"), trailing switch that toggles all reminders on/off (or navigates to a reminders screen — document choice; do not ship a dead switch).
      - Giao diện — value "Sâu & Tối ưu pin màn hình OLED" → replace with "Obsidian Lumina" (static) or drop the row; do not fake a theme picker.
    - Section "DỮ LIỆU & LƯU TRỮ" (overline + right-aligned "iCloud: Sẵn sàng" → drop or replace with "Trên thiết bị"):
      - Sao lưu & Nhập dữ liệu — subtitle = real last-export time if tracked, else "Xuất hoặc nhập tệp sao lưu"; chevron → backup screen (U016).
      - Đồng bộ Cloud Sync — **drop entirely** (no cloud).
      - Xuất báo cáo định kỳ — **drop entirely** (not implemented).
    - Section "GIỚI THIỆU & HỖ TRỢ":
      - Giới thiệu ứng dụng — chevron → about screen (restyle `AboutStarnyxSheet` as a full-screen route or keep as a sheet; document choice).
      - Đánh giá ứng dụng & Phản hồi — **drop** unless a store link is wired; if kept, it must open the real store listing.
      - Quyền riêng tư & Bảo mật — chevron → a short privacy statement screen (reuse `about_privacy_*` copy) or drop.
      - Phiên bản — value = real `PackageInfo` version + build number.
    - Footer: app logo mark + "StarNyx" (Space Grotesk w700) + tagline "Từng bước nhỏ mỗi ngày — Vun đắp sự bền bỉ" + "Made with discipline for iOS & Android" (mono, muted). Drop "OLED devices".
    - All rows are 44px+ touch targets; section cards use `#0A0A0C` + hairline + 16px radius.
    - Widget tests: renders, language picker opens, version is shown.

- [ ] **STX-U016**: Backup & export screen (`sao_luu_xuat_du_lieu`)
  - _Must-have · kind:feature · depends on: STX-U015_
  - Design: `docs/app_ui_redesign/sao_luu_xuat_du_lieu/{code.html,screen.png}`
  - Replaces `BackupSettingsSheet` with a full-screen route pushed from Settings.
  - Acceptance criteria:
    - Header: back chevron + title "Sao Lưu & Xuất Dữ Liệu" (localized) + avatar.
    - Section "ĐỒNG BỘ ĐÁM MÂY" → **drop entirely** (iCloud Sync, auto-backup toggle). Replace with a single "Sao lưu thủ công" explainer card if desired.
    - Section "TỆP TIN & XUẤT NHẬP":
      - "Xuất bản sao lưu (JSON)" — description, then a full-width black pill button "Xuất tệp JSON an toàn" with download icon → triggers the existing export flow (passphrase dialog → privacy warning → share sheet).
      - "Nhập dữ liệu từ bản sao lưu" — description, then a full-width black pill button "Chọn tệp sao lưu" with folder icon → triggers the existing import flow (file picker → passphrase if encrypted → confirm → import).
    - Section "PHÂN TÍCH DUNG LƯỢNG":
      - "Lưu trữ cục bộ (Offline)" with a real on-disk size of `starnyx.sqlite` (via `path_provider` + `File.length()`), "Bảo mật thiết bị 100%" → replace with "Dữ liệu không rời khỏi thiết bị".
      - A segmented bar showing relative sizes of habits / journal entries / completions (computed from row counts × approximate row size, or just row counts — document method).
      - Three tiles: "Thói quen {n} Đang theo dõi", "Nhật ký {n} Lượt thắp sáng" → rename to "{n} ghi chú", "Ghi chú {n} Dòng suy ngẫm" → drop or merge with the journal tile.
    - Section "VÙNG NGUY HIỂM":
      - "Xóa toàn bộ dữ liệu ứng dụng" — coral title, description, full-width red (`#DC2626` / `#F43F5E`) pill button "Xóa tất cả dữ liệu" with trash icon → requires typing a confirmation phrase or a two-step confirm dialog → calls the new `DeleteAllDataUseCase` (U017) → signs out to onboarding / empty state.
    - Export/import success and error snackbars preserved.
    - Widget tests: export button triggers bloc event; delete-all requires confirmation; size is displayed.

- [ ] **STX-U017**: Delete-all-data use case
  - _Must-have · kind:architecture · depends on: —_
  - Acceptance criteria:
    - New `DeleteAllDataUseCase` wipes `completions`, `journal_entries`, `starnyxs`, and resets `app_settings` to a single empty row, inside one Drift transaction.
    - Repositories gain `deleteAll*()` methods (or a single `AppDatabase.clearAll()` used by the use case via a new `DataResetRepository`).
    - Notifications are cancelled (`SyncNotificationsUseCase` gains `cancelAll()` or is called per deleted habit).
    - `ActiveStarnyxColorCache` is cleared.
    - After deletion, the app returns to the onboarding/first-run state (U020) or an empty Habits tab — document choice.
    - Unit test: seed DB → delete all → all tables empty, settings reset.
    - Backup export before delete is **not** automatic; the UI must warn that this is irreversible.

## Epic U-G - Form (Create / Edit Habit)

- [ ] **STX-U018**: Restyle create/edit habit form (`them_thoi_quen` / `chinh_sua_thoi_quen`)
  - _Must-have · kind:feature · depends on: STX-U004_
  - Design: `docs/app_ui_redesign/them_thoi_quen/{code.html,screen.png}`, `docs/app_ui_redesign/chinh_sua_thoi_quen/{code.html,screen.png}`
  - The form becomes a full-screen route (pushed), not a bottom sheet.
  - Acceptance criteria:
    - Header: back chevron (create) / close X (edit) on the left, centered title "Thói quen mới" / "Sửa thói quen" (Space Grotesk w600), avatar on the right.
    - "Tiêu đề" label + counter `{n}/60` (mono, muted) + pill text field with hint "Bạn muốn duy trì điều gì?".
    - "Mô tả" label + counter `{n}/160` + multi-line pill field.
    - "Biểu tượng" section: title + helper "Thứ sẽ sáng lên mỗi ngày bạn làm được." + category filter chips (TẤT CẢ / NATURE / FEELINGS / ENERGY / SKY / DAILY LIFE) + 6-column symbol grid. Selected symbol is filled with the accent color and a dark glyph; unselected are `#121215` circles with muted glyphs.
    - "Xem trước chuỗi ngày" / "XEM TRƯỚC CHUỖI NGÀY" preview row: 7 cells showing future/missed/lit/today states with the selected symbol + color (reuse `_SevenDayPreview`, restyle).
    - "Màu sắc" section: label + "HỔ PHÁCH" (or the selected color name) chip on the right + row of color dots (violet, blue, amber, emerald) + a custom-color picker dot. Selected dot has a ring.
    - "Nhắc nhở hằng ngày" card: bell icon in emerald-tinted squircle, title, subtitle "Bật để nhận thông báo thúc đẩy", trailing switch (emerald when on). Below: "Giờ nhắc nhở" row with the time in emerald mono + a clock icon → time picker.
    - "Ngày bắt đầu" row: calendar icon, label "Ngày bắt đầu", value "Hôm nay, 19/11/2026" (or the picked date), chevron → date picker.
    - Edit mode only: "Tích tiểu thành đại" / milestone hint card is optional — drop or replace with a real streak hint.
    - Edit mode only: "Xóa thói quen" destructive text button (coral) above the CTA → opens U019 dialog.
    - Primary CTA: full-width pill, gradient violet→emerald (create) or solid emerald (edit), black w700 label "Lưu thói quen" / "Cập nhật thói quen" with a check icon.
    - Validation errors use coral text; disabled CTA when title is empty.
    - Layout holds at 320px and 2.0 text scale; the symbol grid scrolls if needed.
    - Widget tests: create flow, edit flow, symbol selection, color selection, validation.

- [ ] **STX-U019**: Delete-habit confirmation dialog (`xac_nhan_xoa_thoi_quen`)
  - _Must-have · kind:feature · depends on: STX-U004, STX-U018_
  - Design: `docs/app_ui_redesign/xac_nhan_xoa_thoi_quen/{code.html,screen.png}`
  - Acceptance criteria:
    - `AppConfirmDialog` (or a new `AppDestructiveDialog`) matches the mockup: centered card on `#16161A` with hairline border and 32px radius, trash icon in a coral-tinted circle with glow, title "Xóa thói quen này?" (Space Grotesk w700), a chip showing the habit symbol + title + "Bắt đầu {date}", body copy "Thao tác này sẽ xóa vĩnh viễn thói quen và toàn bộ dữ liệu tiến trình liên quan trên máy.", two pill buttons: "Hủy" (ghost, `#1F1E24` fill) and "Xóa" (coral `#F43F5E` fill, black label, glow).
    - Used by the edit form's delete action and by any other delete-habit entry point.
    - Barrier is `#000000` at ~78% with a subtle blur; dialog animates scale 0.94→1 + fade.
    - Respects reduced motion.
    - Widget test: confirm and cancel paths.

## Epic U-H - Onboarding

- [ ] **STX-U020**: Onboarding flow — welcome screen (`chao_mung`)
  - _Must-have · kind:feature · depends on: STX-U004, STX-U006_
  - Design: `docs/app_ui_redesign/chao_mung/{code.html,screen.png}`
  - Acceptance criteria:
    - Shown on first launch (no habits and `onboarding_completed` flag not set) instead of the empty Habits tab.
    - Top: page indicator (3 dots, first is emerald and elongated) + "Bỏ qua →" text button on the right (skips to the last step or to the app with no habits — document choice).
    - Hero: concentric circles with a sprout/leaf glyph in emerald, floating dots (amber, violet, emerald), a "365 ngày" pill with flame icon, and a "Tối giản · Cải tiến từ phiên bản gốc" pill → replace the latter with "Tối giản · Riêng tư · Ngoại tuyến" or drop.
    - Overline "KỶ NGUYÊN TỰ KỶ LUẬT" (emerald, mono) → replace with a StarNyx-appropriate overline, e.g. "KỶ LUẬT MỖI NGÀY".
    - Headline "Chào mừng trở lại." → "Chào mừng." or "Bắt đầu hành trình." (localized); the word "trở lại" is wrong for first-run.
    - Subhead: "Từng bước nhỏ mỗi ngày — Vun đắp sự bền bỉ và làm chủ cuộc sống của chính bạn."
    - Three feature rows (icon in tinted squircle + title + subtitle + trailing accent):
      - "Ma trận điểm 365 ngày" / "Thắp sáng từng ô vuông theo tiến trình kiên định" (grid icon, emerald).
      - "Bảo mật ngoại tuyến" / "Dữ liệu thói quen lưu cục bộ hoàn toàn trên máy" (shield icon, violet) + trailing "100% Riêng tư" pill.
      - "Nhắc nhở tinh tế" / "Thông báo nhẹ nhàng đúng nhịp sinh học" (bell icon, amber).
    - Interactive demo card: "Uống 500ml nước ấm" with a check circle — tapping it toggles a lit state with haptic + bloom (reuse the grid cell animation). This is a self-contained demo, not persisted.
    - Primary CTA: full-width emerald pill "Tạo thói quen đầu tiên →" → goes to U021 (template picker) or directly to the create form — document choice; mockup implies template picker.
    - Secondary link: "Tôi đã có tài khoản / Khôi phục dữ liệu" → opens the backup import flow (U016).
    - Footer: shield icon + "Không yêu cầu đăng ký phức tạp · Mặc định bảo mật" (mono, muted).
    - Widget test: renders, CTA navigates, skip works.

- [ ] **STX-U021**: Onboarding flow — template picker (`chon_thoi_quen_mau`)
  - _Must-have · kind:feature · depends on: STX-U020_
  - Design: `docs/app_ui_redesign/chon_thoi_quen_mau/{code.html,screen.png}`
  - Acceptance criteria:
    - Header: back chevron, "BƯỚC 2/3" (mono), "Bỏ qua" on the right, avatar.
    - Overline "BƯỚC 2 TRÊN 3 · Khởi tạo nền tảng" (emerald dot + mono).
    - Headline "Bắt đầu với sự tinh gọn" (Space Grotesk w700) + subhead "Chọn từ 1 đến 3 thói quen mẫu để kiến tạo chu kỳ tích cực. Mọi mục tiêu đều có thể tinh chỉnh sau này."
    - Category filter chips: Tất cả / Sức khỏe / Tâm trí / Kỷ luật / Năng lượng (horizontal scroll).
    - Template list: each row is a card with a tinted squircle icon, title, subtitle, a tag chip (e.g. "Dễ thực hiện", "Cốt lõi", "Tâm trí", "Thể chất", "Cảm xúc") + duration/frequency in mono, and a trailing check circle (emerald filled when selected, empty otherwise).
    - Templates (at least): Uống 500ml nước ấm (06:30, water, emerald), Ngủ sâu trước 23:00 (22:15, moon, amber), Đọc sách 15 phút (book, violet), Vận động nhẹ 10 phút (run, emerald), Viết 3 điều biết ơn (pencil, amber). Each template maps to a `HabitSymbols` key, a color, a reminder time, and a description.
    - "Tự tạo thói quen theo ý bạn" row with a plus icon → opens the create form (U018) and skips the rest of onboarding.
    - Footer: "ĐÃ CHỌN: {n} / 3 THÓI QUEN" (mono, emerald dot) + "Khuyên dùng 1-3" (muted) + full-width emerald pill "Tiếp tục thiết lập ({n}) →" (disabled when 0 selected) + helper "Bạn hoàn toàn tự do xóa bỏ hoặc bổ sung thói quen trong tương lai."
    - Selecting more than 3 shows a snackbar and does not select.
    - Widget tests: select/deselect, max 3, continue disabled at 0.

- [ ] **STX-U022**: Onboarding flow — reminder setup (`thiet_lap_nhac_nho`)
  - _Must-have · kind:feature · depends on: STX-U021_
  - Design: `docs/app_ui_redesign/thiet_lap_nhac_nho/{code.html,screen.png}`
  - Acceptance criteria:
    - Header: back chevron, "BƯỚC 2/3" → fix to "BƯỚC 3/3" (mono), "Bỏ qua", avatar.
    - Overline "BƯỚC 3 TRÊN 3 · KÍCH HOẠT KỶ LUẬT" (emerald dot + mono).
    - Headline "Nhắc nhở đúng nhịp sinh học" with "nhịp sinh học" in emerald + subhead "Khoảng lặng nhắc nhở nhẹ nhàng vào mỗi ngày giúp bạn không bao giờ bỏ lỡ cam kết với bản thân."
    - "{n} THÓI QUEN ĐÃ CHỌN" overline + "Đã đồng bộ" pill (emerald) → replace with "Đã lưu" or drop.
    - One row per selected template: icon in tinted squircle, title, "Giờ nhắc mặc định: {time} {Sáng|Tối}" with a clock icon, trailing edit pencil → opens a time picker for that template.
    - "Khung giờ nhắc chung" card: title + subtitle "Tổng kết & chuẩn bị nhịp sống hôm sau", a large time display (Space Grotesk w700, emerald, tabular) with up/down chevrons, and "TẦN SUẤT ÁP DỤNG" chips: "Mỗi ngày" (active, emerald) / "T2 – T6" / "Tùy chỉnh". **Drop "Tùy chỉnh"** unless weekday selection is implemented; "T2 – T6" may be kept if it maps to a real per-habit weekday reminder — otherwise drop both and keep only "Mỗi ngày". Document choice.
    - "Âm thanh & Rung Haptic" row: phone-vibrate icon in emerald squircle, title, subtitle "Phản hồi xúc giác tinh tế, êm ái khi đến giờ", trailing switch (emerald). Wires to a real `hapticsEnabled` setting (or is dropped if not wired — do not ship a dead switch).
    - "Thông báo thông minh" row: **drop entirely** ("AI SMART" is not a feature).
    - Primary CTA: full-width emerald pill "Bắt đầu hành trình kỷ luật →" → creates the selected habits (via `CreateStarNyxUseCase` for each template), schedules reminders, sets `onboarding_completed = true`, and navigates to the Habits tab.
    - Footer: sliders icon + "Bạn luôn có thể tùy chỉnh hoặc tắt thông báo bất cứ lúc nào trong Cài đặt." (mono, muted).
    - If habit creation fails midway, roll back created habits and show an error.
    - Widget tests: time edit, continue creates habits, skip path.

- [ ] **STX-U023**: Onboarding flow — completion screen (`hoan_tat_onboarding`)
  - _Must-have · kind:feature · depends on: STX-U022_
  - Design: `docs/app_ui_redesign/hoan_tat_onboarding/{code.html,screen.png}`
  - Acceptance criteria:
    - Overline pill at top: emerald dot + "HOÀN TẤT KHỞI ĐỘNG · BƯỚC VÀO KỶ NGUYÊN MỚI" (mono) → replace with "HOÀN TẤT · SẴN SÀNG BẮT ĐẦU".
    - Back chevron (top-right in mockup — move to top-left for consistency) → returns to U022.
    - Hero: concentric circles with a leaf/sprout glyph in emerald with a gradient ring (emerald→amber) and glow; small floating icons (chevron, badge) — keep subtle.
    - Headline "Sẵn sàng bứt phá!" → drop the exclamation (tone rule) → "Sẵn sàng." or "Bạn đã sẵn sàng." with "bứt phá" in emerald underline if desired.
    - Subhead: "Ngọn lửa thói quen đầu tiên đã được thắp sáng. Hãy kiên trì từng ngày để hoàn thiện bức tranh 365 ngày rực rỡ của chính bạn."
    - "CAM KẾT KHỞI ĐIỂM CỦA BẠN" card: shield-check icon + overline + "Đã sẵn sàng" pill (emerald). One row per created habit: icon in tinted square, title, "{time} Mỗi sáng/tối · {subtitle}", trailing emerald check circle.
    - "Chấm sáng mục tiêu năm" row: label + "1 / 365 Ngày" (emerald, tabular) + a thin progress bar (emerald fill on `#121215` track).
    - Quote block: "Kỷ luật không phải là sự gò bó, mà là cây cầu dẫn tới tự do đích thực." with a large amber quote mark — keep, it's on-brand.
    - Primary CTA: full-width emerald pill "Vào màn hình chính & Thắp sáng ngay →" → navigates to Habits tab and triggers the light-today action for the first habit (or just lands on Habits — document choice).
    - Footer: "Mọi thiết lập luôn có thể điều chỉnh trong Cài đặt" (mono, muted).
    - Widget test: renders with the created habits; CTA navigates.

- [ ] **STX-U024**: Onboarding state, routing and first-run detection
  - _Must-have · kind:architecture · depends on: STX-U020, STX-U021, STX-U022, STX-U023_
  - Acceptance criteria:
    - `AppSettings` (or a new `OnboardingState` in `SharedPreferences`) gains `onboardingCompleted: bool` (default false). If stored in Drift, schema v4 → v5 is required — prefer `SharedPreferences` to avoid a migration; document choice.
    - `AppRouter` / `AppShell` checks the flag on launch: if false and no habits exist → show onboarding; otherwise → Habits tab.
    - Completing or skipping onboarding sets the flag to true.
    - "Khôi phục dữ liệu" from U020 sets the flag to true after a successful import.
    - `DeleteAllDataUseCase` (U017) resets the flag to false so the user sees onboarding again.
    - Unit/widget tests: fresh install → onboarding; after completion → Habits; after delete-all → onboarding.

## Epic U-I - Quality

- [ ] **STX-U025**: Localize all new strings (vi / en / ja)
  - _Must-have · kind:polish · depends on: STX-U007 … STX-U024_
  - Acceptance criteria:
    - New keys added under `overview.*`, `onboarding.*`, `journal.detail.*`, `settings.*` (new rows), `habits.*` (list screen), `common.*` (shared).
    - vi, en, ja have identical key sets (extend the existing key-parity test or script).
    - Tone: calm, warm, short, adult; no exclamation marks; no guilt on missed days; no "PRO", "AI", "cloud", "iCloud", "OLED Sync" strings anywhere.
    - Branding is "StarNyx" everywhere; no "Home Habits", "Journal Notes", "Overview List", "Habit Tracker", "LUMINESCENT TRACKER".
    - `pubspec.yaml` description remains accurate.

- [ ] **STX-U026**: Visual QA pass against mockups
  - _Must-have · kind:test · depends on: STX-U007 … STX-U024_
  - Acceptance criteria:
    - Every screen in `docs/app_ui_redesign/` is compared side-by-side with the running app on a 390×844 (iPhone 14) and 320×568 (iPhone SE) viewport, at 1.0 and 2.0 text scale.
    - Discrepancies are either fixed or documented in the PR with a reason (e.g. dropped fake feature).
    - Screenshots attached to the PR for: Habits, Overview, Journal list, Journal detail, Settings, Backup, Create form, Edit form, Delete dialog, Onboarding ×4, Habit list.
    - No overflow, no clipped text, no dead buttons.

- [ ] **STX-U027**: Tests and dead-code cleanup
  - _Must-have · kind:test · depends on: STX-U007 … STX-U024_
  - Acceptance criteria:
    - `flutter test` passes; new blocs/use cases have unit tests; new screens have widget tests for the happy path and empty/error states.
    - Removed: `ConstellationSwitcherSheet`, `HomeSwipeUpHint`, `CosmicBackground`, `AnimatedCosmicStarfield`, `AppSheetBackground`, `GradientOutlineButton` (if renamed), `ActiveStarnyxSpotlight` (if unused), `FirstRunWelcomeView` (replaced by onboarding), `WelcomeHeroIcon`.
    - `flutter analyze` clean; no unused imports; `dart format` applied.
    - `docs/ISSUES.md` R-section is untouched; U-section is ticked as issues complete.
