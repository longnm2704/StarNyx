# Spec: STX-R019 — Weekly targets (e.g. 3× per week)

**Status:** Backlog · kind:architecture · depends on: —

## Goal
Define how weekly targets change streak semantics, completion rate, and grid rendering. Write this spec before implementing any code.

## Problem
Current model assumes daily completion (every day counts). Weekly targets allow users to set a goal like "3 times per week" instead of "every day". This changes:
- What counts as a "streak" (consecutive weeks meeting target vs consecutive days)
- Completion rate (days lit / target days, not days lit / total days)
- Grid rendering (which days are "expected" vs "optional")

## Data model changes

### StarNyx entity additions
```dart
class StarNyx {
  /// Weekly target: number of completions expected per week (1-7).
  /// Null means daily target (every day expected).
  final int? weeklyTarget;

  /// Week anchor: which day of the week starts the user's week (1=Mon, 7=Sun).
  /// Null means week starts on Monday.
  final int? weekStartDay;
}
```

### Completion model
- No changes to `Completion` entity (still tracks individual dates)
- Weekly target is interpreted at read/aggregation time

## Streak semantics (weekly)

### Definition
A "week" is a 7-day period starting on `weekStartDay`. A week is "met" if the number of completions in that week >= `weeklyTarget`.

### Current streak
Count of consecutive weeks (ending with the most recent week) that are met, including the current week if it's already met.

### Example
- weeklyTarget = 3, weekStartDay = 1 (Monday)
- Week 1 (Mar 30–Apr 5): 3 completions → met
- Week 2 (Apr 6–12): 2 completions → not met
- Week 3 (Apr 13–19): 4 completions → met
- Current streak = 1 (only week 3 is met, week 2 broke the streak)

## Completion rate (weekly)

### Definition
`completionRate = weeksMet / totalWeeksSinceStart`

### Example
- Start date: Mar 30, weeklyTarget = 3
- By Apr 19: 3 weeks, 2 met → rate = 67%

## Grid rendering (weekly)

### Expected days
In weekly mode, not every day is "expected". The grid shows:
- Days before start date: dot (future)
- Days in weeks that are already "met": lit if completed, otherwise normal
- Days in the current week that haven't happened yet: dot
- Days in past unmet weeks: missed (low opacity)

### Visual distinction
- "Expected today" vs "optional today" — today is only expected if the current week hasn't met its target yet
- Weekly target indicator in the summary stats: "3×/week" instead of daily rate

### Example render
| Day | State | Reason |
|-----|-------|--------|
| Mon (week 3, already met) | lit if done | Week target already reached |
| Tue (week 3, not yet met) | lit if done, dot if not | Still working toward weekly target |
| Wed (future week) | dot | Week hasn't started |

## Backup / migration implications

### Backup format
Add optional `weeklyTarget` and `weekStartDay` fields to StarNyx JSON. Missing fields = daily target (backward compatible).

### Migration
No data migration needed (new fields are optional, null = daily).

## Acceptance criteria
- Spec defines streak semantics under weekly targets
- Spec defines completion rate calculation under weekly targets
- Spec defines grid rendering under weekly targets
- Spec defines data/backup changes for weekly target fields

## Out of scope
- Implementation code (this is a spec only)
- Weekly target UI in the create/edit form
- Weekly target persistence in Drift (schema changes)
