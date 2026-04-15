# StarNyx - Implementation Plan

## 1. Context

Plan này được tổng hợp từ các nguồn hiện có:

- `docs/starnyx_spec.md`
- `docs/flutter_bloc_structure_starnyx.md`
- nhóm file UI trong `docs/ui/`

Trạng thái hiện tại của project:

- App mới ở mức Flutter scaffold cơ bản
- Chưa có folder structure theo BLoC
- Chưa có local database
- Chưa có domain layer, repository, use case
- Chưa có UI MVP

Mục tiêu của plan:

- Chia việc theo phase dễ triển khai
- Có issue rõ ràng để làm tuần tự
- Có checklist để tick sau khi hoàn thành
- Giữ đúng phạm vi MVP đã chốt trong spec

---

## 2. Guiding Principles

- Offline first
- Không dùng tài khoản
- Không tracking dữ liệu người dùng
- Ưu tiên chạy ổn trước, tránh over-engineer
- UI đơn giản nhưng có cảm giác "bầu trời sao"
- Tuân theo flow: UI -> Bloc -> UseCase -> Repository -> Local DB

---

## 3. Proposed Tech Baseline

Đề xuất stack để implement MVP:

- State management: `flutter_bloc`
- Local database: `drift` + `sqlite3_flutter_libs`
- DI: `get_it`
- Value equality: `equatable`
- Date formatting: `intl`
- Local notification: `flutter_local_notifications` + `timezone`
- Export / import file: `file_picker`, `path_provider`, `share_plus`
- UUID: `uuid`

Ghi chú:

- Nếu muốn tối giản hơn, có thể giữ DI ở mức manual registration, chưa cần codegen.
- Notification nên được bọc qua service riêng để sau này dễ thay đổi.

---

## 4. Finalized Product Decisions

Các quyết định dưới đây đã được chốt để tránh mơ hồ khi implement:

- Nhiều StarNyx được hỗ trợ ngay trong MVP; app luôn có 1 StarNyx đang chọn.
- StarNyx đang chọn được đổi từ màn chính hoặc quick actions, và được lưu lại để restore ở lần mở app sau.
- Reminder giữ nguyên đúng thời gian người dùng chọn, không tự làm tròn phút.
- Completion rate theo năm dùng mẫu số là số ngày hợp lệ trong đoạn:
  `max(startDate, Jan 1 của năm đang xem)` đến `min(today, Dec 31 của năm đang xem)`.
- File import/export JSON bắt buộc có `appSettings`, trong đó MVP hiện lưu `lastSelectedStarnyxId`.
- Reminder phải được resync toàn bộ khi app khởi động, sau import thành công, và sau các thay đổi dữ liệu có liên quan.

---

## 5. Target Folder Structure

```txt
lib/
├─ app/
│  ├─ app.dart
│  ├─ di/
│  ├─ router/
│  └─ theme/
├─ core/
│  ├─ constants/
│  ├─ services/
│  ├─ utils/
│  └─ widgets/
├─ data/
│  ├─ db/
│  ├─ models/
│  └─ repositories/
├─ domain/
│  ├─ entities/
│  ├─ repositories/
│  └─ usecases/
├─ features/
│  ├─ backup/
│  ├─ home/
│  ├─ journal/
│  ├─ settings/
│  └─ starnyx_form/
└─ main.dart
```

---

## 6. Delivery Strategy

Thứ tự nên làm:

1. Dựng nền project + kiến trúc + theme
2. Hoàn thành data layer và domain layer
3. Làm flow tạo / sửa / xoá StarNyx
4. Làm màn home + grid + check-in
5. Làm journal + settings + notification
6. Làm import / export + test + hardening

Lý do:

- Home screen phụ thuộc nhiều vào data model, stats, completion rule.
- Notification và backup nên làm sau khi data flow đã ổn định.
- Journal và settings có thể phát triển sau core flow mà không chặn MVP chính.

---

## 7. Phase Plan

## Phase 0 - Foundation

Mục tiêu:

- Biến project scaffold thành cấu trúc có thể phát triển dài hạn
- Chốt nền tảng kỹ thuật cho MVP

Issue checklist:

- [x] `STX-001` Cập nhật `pubspec.yaml` với các package cần cho BLoC, Drift, notification, import/export
- [x] `STX-002` Tạo lại folder structure theo tài liệu `flutter_bloc_structure_starnyx.md`
- [x] `STX-003` Tạo `app.dart`, app router cơ bản, app theme cơ bản, entry point sạch
- [x] `STX-004` Tạo `core/utils` cho date, streak, JSON validation, và reminder time parsing/formatting
- [x] `STX-005` Tạo `core/constants` và `core/widgets` dùng chung
- [x] `STX-006` Setup `get_it` để đăng ký database, repository, service, use case, bloc factory

Definition of done:

- App chạy được với cấu trúc mới
- Không còn `Hello World`
- Có smoke flow mở app vào shell UI mới
- `flutter analyze` pass

---

## Phase 1 - Data Layer and Domain

Mục tiêu:

- Định nghĩa dữ liệu local rõ ràng
- Cố định business model trước khi làm UI

Issue checklist:

- [x] `STX-007` Thiết kế Drift schema cho `starnyxs`, `completions`, `journal_entries`, `app_settings`
- [x] `STX-008` Tạo database class, table, DAO và migration strategy version 1
- [x] `STX-009` Tạo domain entities cho StarNyx, Completion, JournalEntry, AppSettings
- [x] `STX-010` Tạo abstract repositories trong `domain/repositories`
- [x] `STX-011` Implement repositories trong `data/repositories`
- [x] `STX-012` Tạo use case cho create, update, delete, load, select active StarNyx, toggle completion, save note, export, import
- [x] `STX-013` Implement rule tính streak hiện tại, streak dài nhất, completion rate theo năm
- [x] `STX-014` Implement rule validate start date, future date, 7-day edit lock, one-note-per-day

Definition of done:

- Có thể thao tác dữ liệu hoàn toàn local
- Use case bao phủ rule chính của spec
- Unit test cho logic date, completion rate, streak chạy pass

---

## Phase 2 - StarNyx Management Flow

Mục tiêu:

- Hoàn thành flow tạo / sửa / xoá thói quen
- Có first-run experience rõ ràng

Issue checklist:

- [x] `STX-015` Tạo màn welcome / empty state cho lần mở app đầu tiên
- [x] `STX-016` Tạo `StarnyxFormBloc` với state cho create và edit
- [x] `STX-017` Tạo màn create StarNyx bám theo UI `docs/ui/starnyx_new_constellation.PNG`
- [x] `STX-018` Validate title bắt buộc, start date chỉ được chọn trong 7 ngày gần nhất đến hôm nay, reminder chỉ lưu giờ khi bật
- [x] `STX-019` Cập nhật rule reminder time để giữ nguyên giờ người dùng chọn
- [x] `STX-020` Implement edit StarNyx và prefill dữ liệu
- [x] `STX-021` Implement delete StarNyx với confirm dialog
- [x] `STX-022` Tạo UI để list / switch StarNyx đang chọn từ màn chính hoặc quick actions
- [x] `STX-023` Lưu và restore StarNyx được chọn gần nhất khi mở app lại

Definition of done:

- User có thể tạo ít nhất 1 StarNyx
- User có thể chuyển giữa nhiều StarNyx
- Có thể sửa và xoá an toàn
- First launch và returning user có luồng khác nhau đúng spec
- Bloc hoặc widget test bao phủ validation chính của form và restore selected StarNyx

---

## Phase 3 - Home Screen and Check-in

Mục tiêu:

- Hoàn thành màn hình quan trọng nhất của app
- Hiển thị tiến trình theo mô hình "bầu trời sao"

Issue checklist:

- [x] `STX-024` Tạo `HomeBloc` với event load data, select day, move previous/next day, jump today, change year, change active StarNyx, toggle completion
- [x] `STX-025` Tạo home page bám theo UI `docs/ui/starnyx_home.PNG`
- [x] `STX-026` Build star grid 365/366 ngày với 18 cột
- [ ] `STX-027` Render đầy đủ các trạng thái: before start, completed, missed, future, selected, today
- [ ] `STX-028` Chặn check-in cho ngày tương lai và ngày trước start date
- [ ] `STX-029` Cho phép sửa completion chỉ trong 7 ngày gần nhất
- [ ] `STX-030` Tạo cụm action bên dưới cho ngày đang chọn, previous / next / today
- [ ] `STX-031` Hiển thị thống kê: current streak, longest streak, total completed, completion rate
- [ ] `STX-032` Hỗ trợ đổi năm đang xem và tính lại completion rate đúng theo năm đó
- [ ] `STX-033` Tạo bottom sheet hoặc quick actions bám theo UI `docs/ui/starnyx_bottom_sheet.PNG`

Definition of done:

- User hoàn thành được check-in flow đầy đủ
- Rule completion hoạt động đúng
- Grid phản hồi nhanh, không lag trên dữ liệu 1 năm
- Bloc test hoặc widget test bao phủ select day, toggle completion, 7-day lock

---

## Phase 4 - Journal, Settings, Notification

Mục tiêu:

- Bổ sung các tính năng phụ nhưng quan trọng với MVP
- Hoàn thiện trải nghiệm sử dụng hằng ngày

Issue checklist:

- [ ] `STX-034` Tạo `JournalBloc` hoặc state flow tương đương cho journal
- [ ] `STX-035` Tạo màn journal bám theo UI `docs/ui/starnyx_journal.PNG`
- [ ] `STX-036` Chỉ cho tạo 1 note mỗi ngày cho ngày hiện tại
- [ ] `STX-037` Không cho sửa note đã tạo; chỉ hỗ trợ xoá rồi tạo lại
- [ ] `STX-038` Hiển thị danh sách journal entries theo thứ tự mới nhất trước
- [ ] `STX-039` Tạo `SettingsBloc` và màn settings bám theo `docs/ui/starnyx_settings.PNG`
- [ ] `STX-040` Tạo màn general settings bám theo `docs/ui/starnyx_settings_general.PNG`
- [ ] `STX-041` Implement notification service: create, update, cancel theo rule trong spec
- [ ] `STX-042` Đồng bộ notification khi tạo, sửa, xoá, import dữ liệu

Definition of done:

- Journal hoạt động đúng rule
- Settings có thể điều khiển reminder và app preferences cơ bản
- Notification được schedule lại đúng khi dữ liệu thay đổi
- Có test cho journal rule và notification service bằng fake/mock service

---

## Phase 5 - Backup, Import/Export, Hardening

Mục tiêu:

- Hoàn thành phần backup local
- Ổn định app trước khi dùng thật

Issue checklist:

- [ ] `STX-043` Tạo màn backup hoặc section backup trong settings
- [ ] `STX-044` Export toàn bộ dữ liệu ra file JSON theo schema trong spec
- [ ] `STX-045` Import JSON với validate schema version và dữ liệu bắt buộc
- [ ] `STX-046` Khi import: ghi đè toàn bộ dữ liệu hiện tại
- [ ] `STX-047` Có rollback nếu import lỗi giữa chừng
- [ ] `STX-048` Rebuild reminder schedule sau import thành công
- [ ] `STX-049` Viết unit test cho JSON parser, import validator, rollback path
- [ ] `STX-050` Viết bloc test hoặc widget test cho form, home, journal
- [ ] `STX-051` Tạo manual QA checklist cho toàn bộ MVP

Definition of done:

- Export ra file hợp lệ
- Import dữ liệu hợp lệ hoạt động ổn định
- Import lỗi không làm hỏng dữ liệu cũ
- Test bao phủ parser, validator, rollback, rebuild reminder sau import

---

## Phase 6 - Polish and Release Candidate

Mục tiêu:

- Chuyển từ "đã có tính năng" sang "đủ ổn để sử dụng"

Issue checklist:

- [ ] `STX-052` Rà soát toàn bộ copy text và empty states
- [ ] `STX-053` Tối ưu spacing, color, typography cho đúng tinh thần StarNyx
- [ ] `STX-054` Kiểm tra UX mobile nhỏ, dark/light nếu có, safe area, keyboard overlap
- [ ] `STX-055` Thêm loading, error state, retry state cho các màn cần thiết
- [ ] `STX-056` Kiểm tra icon, haptic, animation nhẹ cho check-in
- [ ] `STX-057` Chuẩn bị app icon, splash, release config cơ bản

Definition of done:

- Không còn lỗi chặn luồng chính
- UI đủ đồng nhất để demo hoặc dùng nội bộ
- Build debug và release local đều chạy được

---

## 8. Screen Checklist

Checklist theo các file UI hiện có trong `docs/ui/`:

- [ ] Welcome screen
- [ ] Home screen
- [ ] StarNyx switcher / picker
- [ ] New constellation screen
- [ ] Journal screen
- [ ] Bottom sheet actions
- [ ] Settings screen
- [ ] General settings screen

---

## 9. Suggested Execution Order by Week

Nếu làm theo nhịp ngắn gọn:

### Week 1

- Phase 0
- Phase 1

### Week 2

- Phase 2
- Bắt đầu Phase 3

### Week 3

- Hoàn thành Phase 3
- Phase 4

### Week 4

- Phase 5
- Phase 6

---

## 10. High-Risk Areas

Các phần cần cẩn thận ngay từ đầu:

- Rule check-in trong 7 ngày gần nhất
- Tính streak và completion rate đúng theo năm đang xem
- Quản lý nhiều StarNyx và restore đúng StarNyx gần nhất
- Import ghi đè toàn bộ nhưng vẫn rollback an toàn
- Đồng bộ notification khi edit, delete, import
- JSON contract phải giữ ổn định giữa DB model và file backup
- Hiệu năng grid 365/366 ô khi rebuild

---

## 11. MVP Exit Checklist

- [ ] Tạo / sửa / xoá StarNyx hoạt động ổn
- [ ] Chuyển được giữa nhiều StarNyx và restore đúng StarNyx gần nhất
- [ ] Check-in theo ngày hoạt động đúng rule
- [ ] Grid sao hiển thị đúng trạng thái ngày
- [ ] Thống kê hiển thị đúng
- [ ] Journal hoạt động đúng rule
- [ ] Reminder hoạt động đúng
- [ ] Export JSON hoạt động
- [ ] Import JSON có validate và rollback
- [ ] App chạy offline hoàn toàn
- [ ] Không có luồng nào yêu cầu tài khoản hoặc network
- [ ] Analyze và test cơ bản pass

---

## 12. Recommended First Slice

Nếu bắt đầu ngay, nên làm theo lát cắt nhỏ này trước:

1. Setup structure + dependencies
2. Tạo database + StarNyx entity + repository
3. Làm create StarNyx
4. Lưu và restore selected StarNyx
5. Làm home screen tối giản chỉ với selected day
6. Bật toggle completion cho hôm nay
7. Sau đó mới mở rộng ra grid full year, stats, journal, settings

Lý do:

- Có một vertical slice chạy được rất sớm
- Giảm rủi ro thiết kế sai data model
- Chốt được luồng nhiều StarNyx trước khi UI phình ra
- Dễ demo tiến độ ngay từ tuần đầu
