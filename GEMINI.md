# StarNyx Project Context

StarNyx is a privacy-first, offline-only habit tracker built with Flutter. Each habit is represented as a "constellation" (StarNyx), and daily progress is visualized as stars on a grid (constellation map).

## Project Overview

- **Core Mission:** Absolute privacy, no accounts, no tracking, offline-first.
- **Key Features:**
  - Create/Manage multiple StarNyxs (habits).
  - Annual star grid (18 columns, 365/366 days).
  - Check-in with 7-day retrospective edit window.
  - Daily journal (one note per day, no edits, only delete/re-create).
  - Streak and completion rate statistics (annual-based).
  - Local notifications for daily reminders.
  - JSON-based backup (import/export with validation and rollback).

## Tech Stack

- **Framework:** Flutter (SDK ^3.10.7)
- **Environment Management:** [FVM](https://fvm.app/)
- **State Management:** [BLoC](https://pub.dev/packages/flutter_bloc)
- **Database:** [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
- **I18n:** [Easy Localization](https://pub.dev/packages/easy_localization)
- **Icons:** SVG via `flutter_svg`
- **Testing:** `flutter_test`, `mocktail`

## Architecture: Clean Architecture + BLoC

The project follows a layered architecture to separate concerns:

1. **`lib/app/`**: Global configurations (App widget, DI, Router, Theme).
2. **`lib/core/`**: Shared utilities, constants, common widgets, and services (Notifications).
3. **`lib/domain/`**: Pure business logic (Entities, Use Cases, Repository interfaces).
4. **`lib/data/`**: Data access (Drift DB, Model mappings, Repository implementations).
5. **`lib/features/`**: Feature-specific presentation layers (BLoC, Pages, Widgets).

**Data Flow:** `UI (Widget) -> Bloc -> Use Case -> Repository -> Data Source (Drift DB)`

## Key Commands

Always prefix with `fvm` if using FVM.

| Command | Description |
| :--- | :--- |
| `fvm flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Run code generation (Drift, etc.) |
| `fvm flutter analyze` | Run static analysis (lints) |
| `fvm flutter test` | Run unit and widget tests |
| `fvm flutter run` | Build and run the app |

## Development Conventions

- **Offline-First:** No network dependencies allowed.
- **Privacy:** Never log user data or sensitive information.
- **BLoC Pattern:** Keep UI logic inside BLoCs. Use Events to trigger actions and States to render UI.
- **Clean Architecture:** Domain should remain pure Dart. Repositories must be injected via interfaces.
- **Dependency Injection:** Registered manually in `lib/app/di/service_locator.dart`.
- **Code Generation:** Avoid committing `*.g.dart` files. Run `build_runner` after changes to schemas or annotations.
- **Documentation:**
  - `docs/starnyx_spec.md`: Product rules and logic (Source of Truth).
  - `docs/starnyx_implementation_plan.md`: Current progress and roadmap.
  - `docs/flutter_bloc_structure_starnyx.md`: Architectural guidelines.

## Current Project Status

The project is in the middle of **Phase 2** of the [Implementation Plan](docs/starnyx_implementation_plan.md). Core infrastructure, data layer, and StarNyx management (Create/Edit/Delete) are partially implemented. The next focus is restoring the last selected StarNyx and moving to the Home Screen (Phase 3).

## Implementation Rules (Source: `starnyx_spec.md`)

- **Title:** Required, non-empty.
- **Start Date:** Allowed window: [7 days ago, today].
- **Check-in Logic:** Only for the last 7 days. Future dates or dates before Start Date are blocked.
- **Journal Logic:** Max 1 entry per day, only for the current day. No edits (delete and re-create only).
- **Completion Rate:** `total_completed / valid_days_in_year`.
- **Streak:** Current streak breaks if today is missed AND yesterday was missed.
