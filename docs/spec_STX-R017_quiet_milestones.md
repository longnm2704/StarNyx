# Spec: STX-R017 — Quiet milestones at 7 / 30 / 100 days

**Status:** Backlog / Nice-to-have · kind:feature · depends on: STX-R008

## Goal
Derive streak and total completion milestones from existing completion data and surface them with a calm, non-gamified message + slightly stronger glow. Never shown for losses (streaks breaking).

## Design

### Milestone thresholds
| Milestone | Trigger | Message tone |
|-----------|---------|--------------|
| 7 days | currentStreak == 7 | "One week lit." |
| 30 days | currentStreak == 30 | "A month of showing up." |
| 100 days | currentStreak == 100 | "One hundred days." |
| 7 total | totalCompletedCount == 7 | "Seven days lit." |
| 30 total | totalCompletedCount == 30 | "Thirty days lit." |
| 100 total | totalCompletedCount == 100 | "One hundred days lit." |

### Display
- Shown briefly in the home shell header area (below summary stats)
- One calm message at a time (no stacking)
- Slightly stronger glow on the active symbol when a milestone is active
- Dismissed on next day change or new milestone
- Never shown for streak losses or decreasing totals

### Data source
- Reuses existing `StarNyxProgressStats` (`currentStreak`, `totalCompletedCount`)
- No new table, no new persistence

### Files
- `lib/domain/entities/starnyx_progress_stats.dart` — milestone helper (optional)
- `lib/features/home/presentation/widgets/home_shell_view.dart` — milestone message + glow
- `lib/features/home/presentation/bloc/home_bloc.dart` — milestone computation

### Acceptance
- Derived from existing completion data; no new table
- One calm message + slightly stronger glow at milestones
- Never shown for losses

## Out of scope
- Badges, trophies, or gamified celebrations
- Push notifications for milestones
- Shareable milestone cards
