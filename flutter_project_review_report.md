# Flutter Project Review Report

## Table of Contents
- Executive Summary
- Critical Issues
- Bugs / Logic Problems
- Architecture Review
- Performance Review
- Security Review
- UI/UX Review
- Missing Features
- Testing Recommendations
- Action Checklist
- Refactor Roadmap
- Final Score

## Executive Summary
StarNyx là app habit tracker offline-first, privacy-first, với trải nghiệm check-in theo ngày, lưới sao theo năm, journal và local reminder. Kiến trúc hiện tại đi đúng hướng production với phân tách `UI -> Bloc -> UseCase -> Repository -> Local DB`, dùng `flutter_bloc`, `get_it`, `drift`, `easy_localization`, `shared_preferences`, và `flutter_local_notifications`.

Điểm mạnh:
- Layering nhìn chung rõ ràng giữa `features`, `domain`, `data`, `core`, `app`.
- Domain/use case có test tương đối tốt, nhiều widget test đã có.
- `flutter analyze` sạch sau khi chạy codegen Drift.
- App bám đúng hướng offline-first, local DB và local notification.

Rủi ro lớn nhất:
- Backup plaintext vẫn chứa journal/habit data nhạy cảm; chưa có encrypted export hoặc cảnh báo đủ rõ khi share file.
- Một số flow chưa production-complete về mặt UX như reorder constellation chưa persist và General settings còn placeholder.
- Android release hiện vẫn **ký bằng debug key**, nhưng đây là hạng mục đang được defer do chưa có kế hoạch release.

Việc nên làm ngay:
1. Bổ sung encrypted backup hoặc ít nhất warning rõ ràng trước khi export/share backup.
2. Persist reorder hoặc ẩn flow reorder để tránh UX misleading.
3. Hoàn thiện release signing / flavor / CI khi bắt đầu chuẩn bị phát hành.

## Critical Issues

| Severity | File | Issue | Impact | Suggested Fix |
|---|---|---|---|---|
| Critical | `lib/domain/usecases/export_data_use_case.dart:103` | Export journal không lưu `createdAt`/`id` **(Đã fix trong branch hiện tại)** | Import backup làm mất timestamp và thứ tự nhiều note cùng ngày | Export `id` + `createdAt`, import restore metadata tương thích ngược |
| High | `lib/domain/usecases/import_data_use_case.dart:86` | Import/rollback không chạy trong transaction DB **(Đã fix trong branch hiện tại)** | Crash giữa chừng có thể để lại local DB ở trạng thái nửa chừng | Bọc toàn bộ snapshot-clear-save-restore trong `AppDatabase.transaction` |
| High | `lib/core/services/local_notification_service.dart:47` | Không request notification permission **(Đã fix trong branch hiện tại)** | Reminder có thể không bao giờ xuất hiện trên Android 13+ / iOS | Thêm permission request flow, handle denied, thêm `POST_NOTIFICATIONS` |
| High | `android/app/build.gradle.kts:33` | Release đang dùng debug signing **(Deferred theo phạm vi hiện tại)** | Không thể release an toàn lên Play Store / dễ nhầm build debug thành production | Cấu hình keystore release riêng khi bắt đầu release |
| Medium | `lib/features/settings/presentation/pages/settings_bottom_sheet.dart:175` | Settings main và backup cùng listen một `SettingsBloc` **(Đã fix trong branch hiện tại)** | SnackBar thành công/thất bại có thể bị duplicate hoặc trigger sai màn | Chỉ giữ listener ở route hiện hành |
| Medium | `lib/core/widgets/animated_cosmic_starfield.dart:30` | Animation vô hạn ở sheet/background làm `pumpAndSettle` timeout **(Đã fix trong branch hiện tại)** | Widget test fail và tăng GPU/battery cost trên nhiều màn | Cho phép tắt animation trong modal sheet |
| Medium | `lib/domain/usecases/save_journal_entry_use_case.dart:16` | Journal save không validate độ dài content **(Đã fix trong branch hiện tại)** | Input dài > giới hạn DB có thể throw runtime từ Drift/SQLite | Validate ở use case và giới hạn input ở UI |
| Medium | `lib/features/home/presentation/widgets/constellation_switcher_sheet.dart:69` | Reorder chỉ đổi local list, không persist | UX đánh lừa: user reorder xong nhưng mở lại mất thứ tự | Nếu giữ feature này thì thêm `displayOrder` + use case lưu thứ tự |

## Bugs / Logic Problems

### 1. Backup export/import của journal là lossy
- File: `lib/domain/usecases/export_data_use_case.dart:103`
- File: `lib/domain/usecases/import_data_use_case.dart:240`
- Severity: Critical
- Vấn đề:
  Export journal chỉ lưu `starnyxId`, `date`, `content`. Import lại fallback `createdAt` về `date` nếu payload không có `createdAt`. Với thiết kế hiện tại cho phép nhiều note cùng ngày, thứ tự hiển thị đang phụ thuộc `createdAt`, nên backup/restore sẽ làm mất thứ tự thật của note và mất timestamp lịch sử.
- Impact:
  Người dùng restore backup có thể thấy lịch sử journal bị xáo trộn hoặc nhiều note cùng ngày bị “flatten” về cùng mốc thời gian.
- Fix đề xuất:
  Export thêm `createdAt` bắt buộc; nếu cần idempotent import/export tốt hơn thì export cả `id` hoặc chuyển sang UUID cho journal entry.
- Mẫu fix:

```dart
Map<String, dynamic> _journalEntryToJson(JournalEntry entry) {
  return <String, dynamic>{
    'id': entry.id,
    'starnyxId': entry.starnyxId,
    'date': _dateKey(entry.date),
    'content': entry.content,
    'createdAt': entry.createdAt.toIso8601String(),
  };
}

JournalEntry _journalEntryFromJson(Map<String, dynamic> json) {
  return JournalEntry(
    id: (json['id'] as num?)?.toInt() ?? 0,
    starnyxId: json['starnyxId'] as String,
    date: DateTime.parse(json['date'] as String),
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
```

### 2. Import dữ liệu không atomic
- File: `lib/domain/usecases/import_data_use_case.dart:86`
- Severity: High
- Vấn đề:
  Luồng import đang snapshot -> clear -> save -> rollback bằng các call tuần tự qua repository, nhưng không có database transaction. Nếu app/process bị kill ở giữa hoặc có exception sau khi xóa một phần dữ liệu, rollback chưa chắc phục hồi được hoàn toàn.
- Impact:
  Corrupt local state, mất một phần habit/completion/journal sau import lỗi.
- Fix đề xuất:
  Thêm transaction ở `AppDatabase` và expose repository batch import API, hoặc inject `AppDatabase` vào use case import để chạy `transaction(() async { ... })`.

### 3. Reminder local chưa xử lý permission/platform requirement
- File: `lib/core/services/local_notification_service.dart:47`
- File: `android/app/src/main/AndroidManifest.xml:1`
- Severity: High
- Vấn đề:
  Service chỉ `initialize`, `createAndroidChannel`, `zonedSchedule`; không có permission request. Manifest cũng chưa thấy `POST_NOTIFICATIONS`.
- Impact:
  Reminder là feature cốt lõi nhưng có thể fail silently trên Android 13+ và iOS, làm user nghĩ app “không hoạt động”.
- Fix đề xuất:
  Thêm permission flow rõ ràng, lưu trạng thái permission, show CTA/retry trong UI settings/reminder form.

### 4. Release Android chưa production-ready
- File: `android/app/build.gradle.kts:33`
- Severity: High
- Vấn đề:
  `release` đang dùng `signingConfigs.getByName("debug")`.
- Impact:
  Không đạt chuẩn phát hành store, tăng rủi ro release sai cấu hình.
- Fix đề xuất:
  Tách `debug` / `staging` / `release`, dùng keystore thật qua `key.properties` hoặc env secret trong CI.

### 5. Duplicate side-effect listener ở Settings
- File: `lib/features/settings/presentation/pages/backup_settings_sheet.dart:47`
- File: `lib/features/settings/presentation/pages/settings_bottom_sheet.dart:175`
- Severity: Medium
- Vấn đề:
  `SettingsMainView` và `BackupSettingsSheet` cùng lắng nghe `SettingsBloc`. Khi export/import thành công, cả 2 nơi đều có thể hiện Snackbar hoặc side-effect, nhất là do main route vẫn còn trong nested navigator stack.
- Impact:
  Dễ bị double Snackbar, state side-effect khó predict, maintain khó.
- Fix đề xuất:
  Mỗi flow side-effect nên nằm ở route hiện tại, hoặc chuyển về 1 listener duy nhất ở parent và route con chỉ render UI state.

### 6. Widget test timeout do animation vô hạn
- File: `lib/core/widgets/animated_cosmic_starfield.dart:30`
- File: `test/features/starnyx_form/presentation/pages/starnyx_form_bottom_sheet_test.dart:32`
- Severity: Medium
- Vấn đề:
  `_controller.repeat()` chạy vô hạn làm `pumpAndSettle()` không settle trong test.
- Impact:
  Test suite hiện fail; ngoài runtime, background animation chạy trên mọi sheet cũng tăng battery/GPU usage không cần thiết.
- Fix đề xuất:
  Cho `AppSheetBackground`/`CosmicBackground` nhận flag `animated = false` cho modal/form/test, hoặc respect `TickerMode.of(context)`.

### 7. Journal input chưa enforce giới hạn DB
- File: `lib/domain/usecases/save_journal_entry_use_case.dart:16`
- File: `lib/features/journal/presentation/pages/journal_bottom_sheet.dart:374`
- Severity: Medium
- Vấn đề:
  `journal_entries.content` giới hạn max 4000 ký tự ở DB, nhưng input không có `LengthLimitingTextInputFormatter` và use case cũng không validate/truncate.
- Impact:
  User paste text dài có thể bị exception lúc save.
- Fix đề xuất:
  Validate domain-level và chặn ngay trên UI.
- Mẫu fix:

```dart
if (content.trim().isEmpty) {
  throw const FormatException('Journal content is required.');
}
if (content.characters.length > 4000) {
  throw const FormatException('Journal content exceeds 4000 characters.');
}
```

### 8. Reorder constellation hiện chỉ là local illusion
- File: `lib/features/home/presentation/widgets/constellation_switcher_sheet.dart:69`
- Severity: Medium
- Vấn đề:
  `_onReorder` chỉ reorder `_orderedStarnyxs` trong state của sheet; không có entity field / repository / use case để persist. Nhưng copy lại ghi “Edit to reorder”.
- Impact:
  User thao tác xong đóng sheet sẽ mất thứ tự, gây trust issue với app.
- Fix đề xuất:
  Hoặc bỏ UI reorder khỏi MVP, hoặc thêm `displayOrder` trong entity + DB + use case.

### 9. General settings là placeholder nhưng render như feature thật
- File: `lib/features/settings/presentation/pages/general_settings_sheet.dart:45`
- File: `lib/main.dart:23`
- Severity: Medium
- Vấn đề:
  Tile Language/Time Format có `onTap: () {}` nhưng không làm gì. App cũng chỉ support `Locale('en')`.
- Impact:
  UX gây hiểu nhầm, feature không hoàn tất nhưng đã xuất hiện như production.
- Fix đề xuất:
  Ẩn menu nếu chưa implement hoặc hoàn thiện locale switching + time format preference thật.

### 10. `DateTime.now()` ở UI layer lệch với clock business logic
- File: `lib/features/home/presentation/pages/home_body_builder.dart:97`
- Severity: Low
- Vấn đề:
  `todayDate` của UI dùng `DateTime.now()` trực tiếp, trong khi bloc/use case hỗ trợ inject `nowBuilder`.
- Impact:
  Khó test deterministic, dễ lệch trạng thái UI/business quanh thời điểm qua ngày.
- Fix đề xuất:
  Đưa `todayDate` vào state/bloc thay vì tính lại trong view.

## Architecture Review

### Tổng quan
- Domain chính: offline habit tracking + yearly completion visualization + journaling + reminder + backup/import.
- Kiến trúc: khá gần Clean Architecture đơn giản:
  - `app/`: bootstrap, DI, router, theme
  - `features/`: presentation, bloc, page, widget theo feature
  - `domain/`: entities, repository contracts, use cases
  - `data/`: Drift DB, DAO, repository implementations
  - `core/`: shared widgets, constants, services, utilities
- State management: `flutter_bloc`
- DI: `get_it`

### Nhận xét
- Layer separation nhìn chung ổn, nhất là `bloc -> usecase -> repository`.
- Tuy nhiên vẫn còn một số điểm trộn layer:
  - `BackupSettingsSheet` tự làm file picking, file reading, JSON decode, error presentation trong UI.
  - `SettingsBottomSheet` và `HomePage` tự new bloc/service qua `serviceLocator`, làm presentation phụ thuộc DI global.
  - `ImportDataUseCase`/`ExportDataUseCase` đang mang cả concern serialization format, snapshot/rollback và orchestration DB, hơi phình.

### Maintainability
- Nhiều file đang quá dài:
  - `lib/features/home/presentation/widgets/constellation_switcher_sheet.dart`
  - `lib/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart`
  - `lib/features/home/presentation/bloc/home_bloc.dart`
  - `lib/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart`
  - `lib/features/journal/presentation/pages/journal_bottom_sheet.dart`
- `service_locator.dart` cũng đang là “composition root” khá to; vẫn chấp nhận được cho MVP nhưng nên chia module registration.

### Đề xuất refactor
- Tách `BackupFileService` hoặc `ImportExportCoordinator` khỏi UI.
- Tách `HomeBloc` thành smaller handlers/use cases cho:
  - loading
  - completion toggle
  - active selection
  - year navigation
- Tách `ConstellationSwitcherSheet` thành:
  - header/actions
  - reorder list
  - normal list
  - card widget
- Thêm `displayOrder` vào `StarNyx` nếu reorder là feature thật.
- Cân nhắc stricter lints trong `analysis_options.yaml` như:
  - `use_build_context_synchronously`
  - `avoid_print`
  - `prefer_const_constructors`
  - `always_use_package_imports`

## Performance Review

### Tốt
- Có khá nhiều `const`.
- `GridView.builder`, `ListView.builder`, `BlocBuilder.buildWhen` đã được dùng ở vài chỗ.
- Home loading / animated components đã tách riêng, không nhồi vào 1 build lớn.

### Vấn đề
- `AnimatedCosmicStarfield` chạy vô hạn trên các sheet/form cũng như màn nền, tăng paint cost và khiến test không settle.
- `BackupSettingsSheet` đọc file JSON và `jsonDecode` ngay trên UI thread; backup lớn có thể gây jank.
- `HomeBodyBuilder` dùng `DateTime.now()` trong build.
- Nhiều screen/sheet dùng `BlocBuilder` bao quanh subtree lớn, còn dư địa tối ưu granular rebuild.

### Đề xuất
- Thêm cờ tắt background animation ở modal form/settings/journal.
- Với import lớn, chuyển parsing sang `compute()` hoặc isolate.
- Dùng `BlocSelector`/split widget nhỏ hơn cho phần đổi ít.
- Kiểm tra image asset `ic_star.png`/SVG cache nếu app scale lên nhiều screen phức tạp.

## Security Review

### Tốt
- Không thấy API key, token, secret hard-code trong source.
- App hiện offline-first, không thấy network stack công khai.
- Logger không log nội dung journal trực tiếp.

### Rủi ro
- Backup JSON hiện là plaintext, chứa habit/journal riêng tư. Với định vị “privacy-first”, đây là gap cần cân nhắc.
- `SettingsBloc` và import flow surface `error.toString()` trực tiếp ra UI; có thể làm lộ internal exception wording.
- Notification permission chưa hoàn thiện làm feature nhạy cảm bị silent failure.
- Android release signing chưa tách khỏi debug.

### Đề xuất
- Cân nhắc passphrase-based encrypted export cho backup.
- Map exception nội bộ sang UI message thân thiện hơn.
- Hoàn thiện release signing, CI secret management.

## UI/UX Review

### Tốt
- Visual direction rõ ràng, nhất quán, có identity riêng.
- Có loading, error, empty state ở nhiều flow chính.
- Home và form có test small screen cơ bản.

### Vấn đề
- General settings hiển thị như thật nhưng chưa hoạt động.
- Reorder constellation hiện misleading.
- Chưa có localization thực tế ngoài English.
- Theme chỉ có dark, không có strategy cho accessibility/theme preference.
- Chưa thấy accessibility review rõ cho semantics, text scaling, screen reader labels ngoài vài icon.
- Reminder flow chưa cho user feedback rõ nếu permission bị từ chối.

### Đề xuất
- Nếu feature chưa xong, ẩn khỏi settings hoặc gắn “Coming soon”.
- Thêm permission education screen cho reminders.
- Thêm localization tối thiểu `en` + `vi` nếu target user có VN.
- Audit text scaling / semantic labels cho primary action buttons và cards.

## Missing Features

### Must-have
- Persist reorder nếu đã expose UI reorder.
- Notification permission handling + denied state UX.
- Atomic import/export integrity.
- Proper release signing / release checklist.

### Should-have
- Encrypted backup export hoặc ít nhất warning khi share file backup.
- Real language/time-format settings hoặc ẩn menu placeholder.
- Better import/export progress + detailed validation summary UI.
- Empty/error state cho settings/import-specific flows thống nhất hơn.

### Nice-to-have
- Flavors `dev/staging/prod`
- Soft delete / undo cho journal delete
- Export destination chooser / save-to-files flow tốt hơn
- Accessibility audit và tablet layout pass

## Testing Recommendations

### Hiện trạng
- Có unit test cho entities/use cases/utils.
- Có bloc test cho `home`, `journal`, `settings`, `starnyx_form`.
- Có widget test cho home/journal/form.
- Không thấy `integration_test/`.

### Vấn đề test hiện tại
- `flutter test` đang fail:
  - `test/features/starnyx_form/presentation/pages/starnyx_form_bottom_sheet_test.dart:32`
  - Lỗi: `pumpAndSettle timed out`
- Đây là dấu hiệu test harness chưa tương thích với animation vô hạn ở sheet background.

### Nên test thêm
- Import/export round-trip giữ nguyên nhiều journal entries cùng ngày.
- Import rollback khi fail ở giữa write.
- Reminder permission denied / granted / revoked.
- Reorder persist sau app restart.
- Long journal input > 4000 ký tự.
- Midnight boundary:
  - app mở xuyên ngày
  - selected date vs today state
- Backup file malformed / empty / wrong schema / large file.

## Action Checklist

### Must Fix
- [x] Export/import journal giữ `createdAt` và order metadata
- [x] Bọc import/restore trong transaction thật
- [x] Thêm permission flow cho local notifications
- [ ] Cấu hình release signing thật cho Android
- [x] Sửa widget test timeout bằng cách tắt/điều khiển animation nền

### Should Fix
- [x] Bỏ duplicate listener ở settings flow
- [x] Validate giới hạn journal content ở UI + domain
- [ ] Persist reorder hoặc ẩn feature reorder
- [ ] Ẩn/generalize settings placeholder chưa hoạt động
- [ ] Không expose `error.toString()` trực tiếp ra UI

### Nice to Have
- [ ] Thêm encrypted backup hoặc warning rõ ràng
- [ ] Thêm locale khác ngoài English
- [ ] Tách file IO / JSON parsing khỏi widget layer
- [ ] Tăng độ nghiêm ngặt của lints và thêm CI analyze/test/codegen

## Refactor Roadmap

### Quick Wins
- [x] Thêm `LengthLimitingTextInputFormatter(4000)` cho journal input
- [ ] Xóa `cupertino_icons` nếu không dùng (`pubspec.yaml:24`)
- [x] Hợp nhất `SettingsBloc` side-effect listener về 1 chỗ
- [ ] Ẩn menu General settings chưa làm xong
- [x] Tắt animation nền trong test hoặc modal form

### Within 1 Week
- [x] Sửa schema backup journal để không mất `createdAt`
- [ ] Viết round-trip tests cho export/import
- [x] Viết round-trip tests cho export/import
- [x] Thêm permission handling cho notification
- [ ] Cấu hình release signing + checklist release
- [ ] Tách `BackupSettingsSheet` file IO/import parsing ra service/bloc layer

### Long Term
- [ ] Transactional repository/import API
- [ ] Persistable `displayOrder` cho StarNyx
- [ ] Flavor + CI/CD pipeline
- [ ] Accessibility + localization expansion
- [ ] Giảm kích thước các file presentation/bloc lớn

## Final Score
- Architecture: 7.5/10
- Code Quality: 7.5/10
- Performance: 7.0/10
- Security: 6.5/10
- UI/UX: 7.0/10
- Testing: 7.0/10
- Production Readiness: 6.8/10

## Notes
- `flutter analyze`: pass sau khi chạy `dart run build_runner build --delete-conflicting-outputs`
- `flutter test`: fail tại `test/features/starnyx_form/presentation/pages/starnyx_form_bottom_sheet_test.dart` do `pumpAndSettle timed out`
- Repo yêu cầu codegen Drift trước khi analyze/build theo `README.md:64`
