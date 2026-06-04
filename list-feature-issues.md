# StarNyx Feature Expansion Issue List

Sources:
- `flutter_project_review_report.md`
- `list-issues.md`

Purpose:
- Capture the production-readiness features that should be created as GitHub issues
- Organize the backlog by epic so planning and implementation can happen incrementally
- Keep a stable format based on `epic / priority / title / description`

## Epic A - Data Safety and Privacy

Goal: reduce the risk of data loss and sensitive data exposure in backup, import, and delete flows.

| Code | Epic | Priority | Title | Description |
| --- | --- | --- | --- | --- |
| STX-F001 | Epic A - Data Safety and Privacy | Must-have | Add encrypted backup export flow | Protect exported backup files with passphrase-based encryption so journal and habit data are not stored as plaintext when shared or archived. |
| STX-F002 | Epic A - Data Safety and Privacy | Must-have | Add backup privacy warning and confirmation UX | Show a clear warning before export or share that backup files contain sensitive journal and habit data, even when encryption is disabled or not yet configured. |
| STX-F003 | Epic A - Data Safety and Privacy | Should-have | Add undo or soft-delete flow for journal deletion | Prevent accidental permanent data loss by allowing users to undo a journal delete action or recover recently deleted notes. |
| STX-F004 | Epic A - Data Safety and Privacy | Should-have | Replace raw exception strings with user-safe error messages | Map internal import, export, and storage errors to stable user-friendly messages instead of exposing `error.toString()` directly in the UI. |

## Epic B - Habit Management UX

Goal: complete StarNyx management flows so the UX is reliable and does not mislead users.

| Code | Epic | Priority | Title | Description |
| --- | --- | --- | --- | --- |
| STX-F005 | Epic B - Habit Management UX | Must-have | Persist constellation reorder across app restarts | Save the user-defined StarNyx ordering so the switcher and reorder flow remains stable after reopening the app. |
| STX-F006 | Epic B - Habit Management UX | Must-have | Add `displayOrder` migration and repository support | Extend the local schema and repository layer to persist StarNyx order explicitly instead of relying on incidental list order. |
| STX-F007 | Epic B - Habit Management UX | Should-have | Sync reorder with active selection and settings state | Ensure reordering does not break the active StarNyx, last-selected restore logic, or any downstream UI assumptions. |

## Epic C - Settings Completion

Goal: turn Settings into a complete user-facing area instead of leaving placeholder entries visible.

| Code | Epic | Priority | Title | Description |
| --- | --- | --- | --- | --- |
| STX-F008 | Epic C - Settings Completion | Must-have | Complete General Settings screen or hide unfinished entry points | Either ship working General Settings content or remove the placeholder route so the app does not expose incomplete functionality. |
| STX-F009 | Epic C - Settings Completion | Should-have | Add language and date-format preferences | Expose real app preferences for language or regional display format if the menu remains visible to users. |
| STX-F010 | Epic C - Settings Completion | Should-have | Add notification permission diagnostics in settings | Show the current reminder permission state and a retry or open-settings action when notifications are denied. |

## Epic D - Resilience and Feedback States

Goal: make loading, empty, error, and retry states consistent across important user flows.

| Code | Epic | Priority | Title | Description |
| --- | --- | --- | --- | --- |
| STX-F011 | Epic D - Resilience and Feedback States | Must-have | Add consistent import and export loading, success, and failure states | Standardize async UX in settings and backup flows so users always understand what is happening and what succeeded or failed. |
| STX-F012 | Epic D - Resilience and Feedback States | Must-have | Add empty and retry states for settings-related flows | Support file-picker cancel, malformed import, missing permission, and no-backup scenarios with explicit retry actions. |
| STX-F013 | Epic D - Resilience and Feedback States | Should-have | Add a recoverable error model for blocs | Introduce a UI-facing error model that blocs can emit consistently instead of mixing raw strings and ad hoc snackbars. |

## Epic E - Accessibility and Product Polish

Goal: improve production readiness on real devices and for a wider range of users.

| Code | Epic | Priority | Title | Description |
| --- | --- | --- | --- | --- |
| STX-F014 | Epic E - Accessibility and Product Polish | Should-have | Improve accessibility semantics and text scaling support | Verify that key widgets work with larger text scales, semantics labels, and better contrast across core screens. |
| STX-F015 | Epic E - Accessibility and Product Polish | Should-have | Add additional localization support beyond the current default locale | Expand localization coverage if the product is expected to support non-English users. |
| STX-F016 | Epic E - Accessibility and Product Polish | Nice-to-have | Refine destructive action UX with confirmations and recovery cues | Review journal delete, import overwrite, and other destructive actions to make consequences clearer before the user commits. |

## Suggested GitHub Issue Creation Order

1. `STX-F001` - Add encrypted backup export flow
2. `STX-F002` - Add backup privacy warning and confirmation UX
3. `STX-F005` - Persist constellation reorder across app restarts
4. `STX-F006` - Add `displayOrder` migration and repository support
5. `STX-F008` - Complete General Settings screen or hide unfinished entry points
6. `STX-F011` - Add consistent import and export loading, success, and failure states
7. `STX-F012` - Add empty and retry states for settings-related flows
8. `STX-F004` - Replace raw exception strings with user-safe error messages
9. `STX-F010` - Add notification permission diagnostics in settings
10. `STX-F003` - Add undo or soft-delete flow for journal deletion
11. `STX-F013` - Add a recoverable error model for blocs
12. `STX-F014` - Improve accessibility semantics and text scaling support
13. `STX-F015` - Add additional localization support beyond the current default locale
14. `STX-F016` - Refine destructive action UX with confirmations and recovery cues

## Notes for GitHub Issues

- Each issue should have labels for `epic`, `priority`, `area`, and `platform`.
- Recommended milestones:
  - `Production Readiness`
  - `Privacy and Safety`
  - `UX Hardening`
- Any issue involving migrations or schema changes should explicitly include rollback and test strategy notes in the issue body.
