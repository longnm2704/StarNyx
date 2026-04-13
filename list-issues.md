# StarNyx Issue List

Nguon: `docs/starnyx_implementation_plan.md`

Muc dich cua file nay:

- Tong hop day du issue backlog theo plan da chot
- Lam nguon tao GitHub issues
- Giu format on dinh theo `phase / title / description`

## Phase 0 - Foundation

Muc tieu: bien project scaffold thanh mot nen tang Flutter/BLoC co the phat trien tiep cho MVP.

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-001 | Phase 0 - Foundation | Update `pubspec.yaml` with MVP dependencies | Add and lock the core dependency baseline for state management, Drift, local notifications, file import/export, date handling, UUIDs, and test support required by the MVP. |
| STX-002 | Phase 0 - Foundation | Create the target folder structure | Reorganize `lib/` to match the approved BLoC-oriented structure in `docs/flutter_bloc_structure_starnyx.md`, including `app`, `core`, `data`, `domain`, and `features`. |
| STX-003 | Phase 0 - Foundation | Create `app.dart`, router, theme, and clean entrypoint | Replace the default scaffold with a minimal app shell that initializes `MaterialApp`, base routing, theme setup, and a clean `main.dart` entry flow. |
| STX-004 | Phase 0 - Foundation | Create shared utils for date, streak, JSON, and reminder time helpers | Add reusable utility helpers for date calculations, streak/completion logic support, import validation helpers, and reminder time parsing/formatting. |
| STX-005 | Phase 0 - Foundation | Create shared constants and widgets | Add common constants and small reusable widgets that will be shared across screens instead of duplicating low-level UI code later. |
| STX-006 | Phase 0 - Foundation | Setup `get_it` dependency registration | Register database, repositories, services, use cases, and bloc factories in one dependency composition root suitable for the MVP scope. |

## Phase 1 - Data Layer and Domain

Muc tieu: chot data model, business rules, va local persistence truoc khi mo rong UI.

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-007 | Phase 1 - Data Layer and Domain | Design Drift schema for all local tables | Define the schema for `starnyxs`, `completions`, `journal_entries`, and `app_settings`, including constraints needed for MVP rules. |
| STX-008 | Phase 1 - Data Layer and Domain | Implement database, DAOs, and migration v1 | Build the Drift database entrypoint, table bindings, DAO access, and a versioned migration strategy starting from schema version 1. |
| STX-009 | Phase 1 - Data Layer and Domain | Create domain entities | Model `StarNyx`, `Completion`, `JournalEntry`, and `AppSettings` as domain objects that do not depend on Flutter widgets or database details. |
| STX-010 | Phase 1 - Data Layer and Domain | Create abstract repositories | Define repository contracts in the domain layer so blocs and use cases depend on abstractions rather than Drift implementation details. |
| STX-011 | Phase 1 - Data Layer and Domain | Implement repository layer | Implement the repository contracts in `data/repositories` and map between database records and domain entities. |
| STX-012 | Phase 1 - Data Layer and Domain | Create core use cases | Add use cases for create, update, delete, load, select active StarNyx, toggle completion, save note, export, and import flows. |
| STX-013 | Phase 1 - Data Layer and Domain | Implement streak and completion-rate rules | Implement current streak, longest streak, and yearly completion rate using the finalized valid-day formula from the spec. |
| STX-014 | Phase 1 - Data Layer and Domain | Implement validation rules | Centralize business validation for start date, future date lock, 7-day completion edit lock, and one-note-per-day behavior. |

## Phase 2 - StarNyx Management Flow

Muc tieu: hoan thanh luong tao, sua, xoa, chon habit va first-run experience.

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-015 | Phase 2 - StarNyx Management Flow | Create welcome and empty state screen | Build the first-launch experience shown before the user has any StarNyx, with a clear CTA to create the first one. |
| STX-016 | Phase 2 - StarNyx Management Flow | Create `StarnyxFormBloc` | Implement form state management for both create and edit modes, including validation, field state, submission, and error handling. |
| STX-017 | Phase 2 - StarNyx Management Flow | Build create StarNyx screen | Implement the create form UI based on `docs/ui/starnyx_new_constellation.PNG`, wired to the form bloc and domain use cases. |
| STX-018 | Phase 2 - StarNyx Management Flow | Enforce core form validation | Enforce required title, restrict start dates to the range from 7 days ago through today, and only persist reminder time when reminder is enabled. |
| STX-019 | Phase 2 - StarNyx Management Flow | Preserve exact reminder time selected by the user | Ensure reminder times are stored exactly as the user picks them, without automatic minute rounding. |
| STX-020 | Phase 2 - StarNyx Management Flow | Implement edit StarNyx flow | Add edit mode with field prefill, update handling, and proper persistence through the form bloc and update use case. |
| STX-021 | Phase 2 - StarNyx Management Flow | Implement delete StarNyx with confirmation | Allow deleting a StarNyx safely with a confirm dialog and correct cleanup of related local data. |
| STX-022 | Phase 2 - StarNyx Management Flow | Create StarNyx switcher UI | Provide a UI entry point on the main flow to list available StarNyx items and switch the active selection quickly. |
| STX-023 | Phase 2 - StarNyx Management Flow | Persist and restore last selected StarNyx | Save the active StarNyx to app settings and restore it automatically on later app launches for returning users. |

## Phase 3 - Home Screen and Check-in

Muc tieu: hoan thanh man hinh home, luoi sao, va toan bo rule check-in trung tam cua app.

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-024 | Phase 3 - Home Screen and Check-in | Create `HomeBloc` | Implement the main screen state flow for loading data, selecting days, navigating dates, changing year, switching StarNyx, and toggling completion. |
| STX-025 | Phase 3 - Home Screen and Check-in | Build the home screen UI | Implement the main home screen based on `docs/ui/starnyx_home.PNG` and connect it to the active StarNyx and selected day state. |
| STX-026 | Phase 3 - Home Screen and Check-in | Build the yearly star grid | Render a 365/366-day grid with 18 columns and data-driven cell generation for the viewed year. |
| STX-027 | Phase 3 - Home Screen and Check-in | Render all star-day states | Visually represent `before start`, `completed`, `missed`, `future`, `selected`, and `today` states exactly as the spec requires. |
| STX-028 | Phase 3 - Home Screen and Check-in | Block invalid check-ins | Prevent check-in actions for future dates and any dates earlier than the StarNyx start date. |
| STX-029 | Phase 3 - Home Screen and Check-in | Enforce 7-day completion edit window | Allow editing completion only inside the last 7 days and lock older entries from modification. |
| STX-030 | Phase 3 - Home Screen and Check-in | Create selected-day action controls | Build the selected-day action area beneath the grid, including previous day, next day, and `Today` navigation. |
| STX-031 | Phase 3 - Home Screen and Check-in | Show home statistics | Display current streak, longest streak, total completions, and completion rate for the active StarNyx. |
| STX-032 | Phase 3 - Home Screen and Check-in | Support year switching and recompute stats | Let users change the viewed year and recompute the completion rate against the valid-day range for that year. |
| STX-033 | Phase 3 - Home Screen and Check-in | Build quick actions or bottom sheet | Implement the supporting bottom sheet or quick actions flow based on `docs/ui/starnyx_bottom_sheet.PNG`. |

## Phase 4 - Journal, Settings, Notification

Muc tieu: hoan thien journal, settings, va notification de app dung duoc hang ngay.

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-034 | Phase 4 - Journal, Settings, Notification | Create `JournalBloc` or equivalent state flow | Implement state management for journal listing, create/delete actions, and enforcement of journal-specific business rules. |
| STX-035 | Phase 4 - Journal, Settings, Notification | Build the journal screen | Implement the journal UI based on `docs/ui/starnyx_journal.PNG` and connect it to the active StarNyx and today's note flow. |
| STX-036 | Phase 4 - Journal, Settings, Notification | Restrict note creation to one note per current day | Enforce the MVP rule that only one note may be created per day, and only for today's date. |
| STX-037 | Phase 4 - Journal, Settings, Notification | Disallow note editing after creation | Prevent in-place editing of journal entries and require delete-then-create if the user wants to change content. |
| STX-038 | Phase 4 - Journal, Settings, Notification | Show journal entries newest first | Sort and render journal history in reverse chronological order so the latest entries appear first. |
| STX-039 | Phase 4 - Journal, Settings, Notification | Build `SettingsBloc` and settings screen | Implement the main settings flow based on `docs/ui/starnyx_settings.PNG`, including state, navigation, and settings actions. |
| STX-040 | Phase 4 - Journal, Settings, Notification | Build general settings screen | Implement the general settings sub-screen based on `docs/ui/starnyx_settings_general.PNG`. |
| STX-041 | Phase 4 - Journal, Settings, Notification | Implement notification service | Create a notification service that can schedule, update, and cancel reminders according to the product spec. |
| STX-042 | Phase 4 - Journal, Settings, Notification | Sync notifications after data changes | Rebuild or update reminders correctly when users create, edit, delete, or import StarNyx data. |

## Phase 5 - Backup, Import/Export, Hardening

Muc tieu: hoan thanh backup JSON local va hardening cac luong du lieu de tranh mat data.

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-043 | Phase 5 - Backup, Import/Export, Hardening | Build backup screen or settings section | Add the UI entry point for exporting and importing local data, either as a dedicated screen or a settings section. |
| STX-044 | Phase 5 - Backup, Import/Export, Hardening | Export all data to JSON | Serialize all MVP data to the finalized JSON schema, including StarNyx items, completions, journal entries, and app settings. |
| STX-045 | Phase 5 - Backup, Import/Export, Hardening | Validate imported JSON before applying changes | Parse and validate schema version, required fields, and structural correctness before touching existing local data. |
| STX-046 | Phase 5 - Backup, Import/Export, Hardening | Overwrite current data on successful import | Replace the current local dataset with the imported one only after validation succeeds. |
| STX-047 | Phase 5 - Backup, Import/Export, Hardening | Add rollback for failed import | Ensure partial import failures do not corrupt existing local data and can roll back safely to the previous state. |
| STX-048 | Phase 5 - Backup, Import/Export, Hardening | Rebuild reminders after import success | Reschedule local reminders from the imported dataset after the new state has been applied successfully. |
| STX-049 | Phase 5 - Backup, Import/Export, Hardening | Add unit tests for JSON and rollback flows | Cover JSON parsing, schema validation, and rollback/error paths with automated tests. |
| STX-050 | Phase 5 - Backup, Import/Export, Hardening | Add bloc or widget tests for core screens | Add focused bloc/widget tests for the form, home, and journal flows to protect the MVP's main interaction paths. |
| STX-051 | Phase 5 - Backup, Import/Export, Hardening | Create manual QA checklist | Write a manual verification checklist that can be used before demos or release candidate builds. |

## Phase 6 - Polish and Release Candidate

Muc tieu: dua app tu muc "chay duoc" sang muc "du on de demo va dung noi bo".

| Code | Phase | Title | Description |
| --- | --- | --- | --- |
| STX-052 | Phase 6 - Polish and Release Candidate | Review product copy and empty states | Refine labels, helper text, and empty-state copy so the app feels coherent and intentional across all MVP screens. |
| STX-053 | Phase 6 - Polish and Release Candidate | Polish spacing, color, and typography | Tune the visual system to match the StarNyx product direction rather than leaving the UI in a raw scaffold state. |
| STX-054 | Phase 6 - Polish and Release Candidate | Validate mobile UX edge cases | Check small-screen behavior, safe areas, keyboard overlap, and any light/dark theme considerations used by the app. |
| STX-055 | Phase 6 - Polish and Release Candidate | Add loading, error, and retry states | Ensure key screens handle async and failure states cleanly instead of assuming all data flows always succeed. |
| STX-056 | Phase 6 - Polish and Release Candidate | Polish icon, haptic, and check-in motion | Add small interaction refinements around check-in and other key actions without overcomplicating the UI. |
| STX-057 | Phase 6 - Polish and Release Candidate | Prepare app icon, splash, and basic release config | Finish the minimum branding and release configuration needed for internal demo builds and local release testing. |
