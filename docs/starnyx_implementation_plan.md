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

## 4. Target Folder Structure

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

## 5. Delivery Strategy

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

## 6. Phase Plan

## Phase 0 - Foundation

Mục tiêu:

- Biến project scaffold thành cấu trúc có thể phát triển dài hạn
- Chốt nền tảng kỹ thuật cho MVP

Issue checklist:

- [ ] `STX-001` Cập nhật `pubspec.yaml` với các package cần cho BLoC, Drift, notification, import/export
- [ ] `STX-002` Tạo lại folder structure theo tài liệu `flutter_bloc_structure_starnyx.md`
- [ ] `STX-003` Tạo `app.dart`, app router cơ bản, app theme cơ bản, entry point sạch
- [ ] `STX-004` Tạo `core/utils` cho date, streak, JSON validation, reminder time rounding
- [ ] `STX-005` Tạo `core/constants` và `core/widgets` dùng chung
- [ ] `STX-006` Setup `get_it` để đăng ký database, repository, service, use case, bloc factory

Definition of done:

- App chạy được với cấu trúc mới
- Không còn `Hello World`
- `flutter analyze` pass

---

## Phase 1 - Data Layer and Domain

Mục tiêu:

- Định nghĩa dữ liệu local rõ ràng
- Cố định business model trước khi làm UI

Issue checklist:

- [ ] `STX-007` Thiết kế Drift schema cho `starnyxs`, `completions`, `journal_entries`, `app_settings`
- [ ] `STX-008` Tạo database class, table, DAO và migration strategy version 1
- [ ] `STX-009` Tạo domain entities cho StarNyx, Completion, JournalEntry, AppSettings
- [ ] `STX-010` Tạo abstract repositories trong `domain/repositories`
- [ ] `STX-011` Implement repositories trong `data/repositories`
- [ ] `STX-012` Tạo use case cho create, update, delete, load, toggle completion, save note, export, import
- [ ] `STX-013` Implement rule tính streak hiện tại, streak dài nhất, completion rate theo năm
- [ ] `STX-014` Implement rule validate start date, future date, 7-day edit lock, one-note-per-day

Definition of done:

- Có thể thao tác dữ liệu hoàn toàn local
- Use case bao phủ rule chính của spec
- Unit test cho logic date và streak chạy pass

---

## Phase 2 - StarNyx Management Flow

Mục tiêu:

- Hoàn thành flow tạo / sửa / xoá thói quen
- Có first-run experience rõ ràng

Issue checklist:

- [ ] `STX-015` Tạo màn welcome / empty state cho lần mở app đầu tiên
- [ ] `STX-016` Tạo `StarnyxFormBloc` với state cho create và edit
- [ ] `STX-017` Tạo màn create StarNyx bám theo UI `docs/ui/starnyx_new_constellation.PNG`
- [ ] `STX-018` Validate title bắt buộc, start date không lớn hơn hôm nay, reminder chỉ lưu giờ khi bật
- [ ] `STX-019` Implement rule làm tròn reminder time theo mốc 15 phút
- [ ] `STX-020` Implement edit StarNyx và prefill dữ liệu
- [ ] `STX-021` Implement delete StarNyx với confirm dialog
- [ ] `STX-022` Lưu và restore StarNyx được chọn gần nhất khi mở app lại

Definition of done:

- User có thể tạo ít nhất 1 StarNyx
- Có thể sửa và xoá an toàn
- First launch và returning user có luồng khác nhau đúng spec

---

## Phase 3 - Home Screen and Check-in

Mục tiêu:

- Hoàn thành màn hình quan trọng nhất của app
- Hiển thị tiến trình theo mô hình "bầu trời sao"

Issue checklist:

- [ ] `STX-023` Tạo `HomeBloc` với event load data, select day, move previous/next day, jump today, change year, toggle completion
- [ ] `STX-024` Tạo home page bám theo UI `docs/ui/starnyx_home.PNG`
- [ ] `STX-025` Build star grid 365/366 ngày với 18 cột
- [ ] `STX-026` Render đầy đủ các trạng thái: before start, completed, missed, future, selected, today
- [ ] `STX-027` Chặn check-in cho ngày tương lai và ngày trước start date
- [ ] `STX-028` Cho phép sửa completion chỉ trong 7 ngày gần nhất
- [ ] `STX-029` Tạo cụm action bên dưới cho ngày đang chọn, previous / next / today
- [ ] `STX-030` Hiển thị thống kê: current streak, longest streak, total completed, completion rate
- [ ] `STX-031` Hỗ trợ đổi năm đang xem và tính lại completion rate đúng theo năm đó
- [ ] `STX-032` Tạo bottom sheet hoặc quick actions bám theo UI `docs/ui/starnyx_bottom_sheet.PNG`

Definition of done:

- User hoàn thành được check-in flow đầy đủ
- Rule completion hoạt động đúng
- Grid phản hồi nhanh, không lag trên dữ liệu 1 năm

---

## Phase 4 - Journal, Settings, Notification

Mục tiêu:

- Bổ sung các tính năng phụ nhưng quan trọng với MVP
- Hoàn thiện trải nghiệm sử dụng hằng ngày

Issue checklist:

- [ ] `STX-033` Tạo `JournalBloc` hoặc state flow tương đương cho journal
- [ ] `STX-034` Tạo màn journal bám theo UI `docs/ui/starnyx_journal.PNG`
- [ ] `STX-035` Chỉ cho tạo 1 note mỗi ngày cho ngày hiện tại
- [ ] `STX-036` Không cho sửa note đã tạo; chỉ hỗ trợ xoá rồi tạo lại
- [ ] `STX-037` Hiển thị danh sách journal entries theo thứ tự mới nhất trước
- [ ] `STX-038` Tạo `SettingsBloc` và màn settings bám theo `docs/ui/starnyx_settings.PNG`
- [ ] `STX-039` Tạo màn general settings bám theo `docs/ui/starnyx_settings_general.PNG`
- [ ] `STX-040` Implement notification service: create, update, cancel theo rule trong spec
- [ ] `STX-041` Đồng bộ notification khi tạo, sửa, xoá, import dữ liệu

Definition of done:

- Journal hoạt động đúng rule
- Settings có thể điều khiển reminder và app preferences cơ bản
- Notification được schedule lại đúng khi dữ liệu thay đổi

---

## Phase 5 - Backup, Import/Export, Hardening

Mục tiêu:

- Hoàn thành phần backup local
- Ổn định app trước khi dùng thật

Issue checklist:

- [ ] `STX-042` Tạo màn backup hoặc section backup trong settings
- [ ] `STX-043` Export toàn bộ dữ liệu ra file JSON theo schema trong spec
- [ ] `STX-044` Import JSON với validate schema version và dữ liệu bắt buộc
- [ ] `STX-045` Khi import: ghi đè toàn bộ dữ liệu hiện tại
- [ ] `STX-046` Có rollback nếu import lỗi giữa chừng
- [ ] `STX-047` Rebuild reminder schedule sau import thành công
- [ ] `STX-048` Viết unit test cho JSON parser, import validator, rollback path
- [ ] `STX-049` Viết bloc test hoặc widget test cho form, home, journal
- [ ] `STX-050` Tạo manual QA checklist cho toàn bộ MVP

Definition of done:

- Export ra file hợp lệ
- Import dữ liệu hợp lệ hoạt động ổn định
- Import lỗi không làm hỏng dữ liệu cũ

---

## Phase 6 - Polish and Release Candidate

Mục tiêu:

- Chuyển từ "đã có tính năng" sang "đủ ổn để sử dụng"

Issue checklist:

- [ ] `STX-051` Rà soát toàn bộ copy text và empty states
- [ ] `STX-052` Tối ưu spacing, color, typography cho đúng tinh thần StarNyx
- [ ] `STX-053` Kiểm tra UX mobile nhỏ, dark/light nếu có, safe area, keyboard overlap
- [ ] `STX-054` Thêm loading, error state, retry state cho các màn cần thiết
- [ ] `STX-055` Kiểm tra icon, haptic, animation nhẹ cho check-in
- [ ] `STX-056` Chuẩn bị app icon, splash, release config cơ bản

Definition of done:

- Không còn lỗi chặn luồng chính
- UI đủ đồng nhất để demo hoặc dùng nội bộ
- Build debug và release local đều chạy được

---

## 7. Screen Checklist

Checklist theo các file UI hiện có trong `docs/ui/`:

- [ ] Welcome screen
- [ ] Home screen
- [ ] New constellation screen
- [ ] Journal screen
- [ ] Bottom sheet actions
- [ ] Settings screen
- [ ] General settings screen

---

## 8. Suggested Execution Order by Week

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

## 9. High-Risk Areas

Các phần cần cẩn thận ngay từ đầu:

- Rule check-in trong 7 ngày gần nhất
- Tính streak và completion rate đúng theo năm đang xem
- Import ghi đè toàn bộ nhưng vẫn rollback an toàn
- Đồng bộ notification khi edit, delete, import
- Hiệu năng grid 365/366 ô khi rebuild

---

## 10. MVP Exit Checklist

- [ ] Tạo / sửa / xoá StarNyx hoạt động ổn
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

## 11. Recommended First Slice

Nếu bắt đầu ngay, nên làm theo lát cắt nhỏ này trước:

1. Setup structure + dependencies
2. Tạo database + StarNyx entity + repository
3. Làm create StarNyx
4. Làm home screen tối giản chỉ với selected day
5. Bật toggle completion cho hôm nay
6. Sau đó mới mở rộng ra grid full year, stats, journal, settings

Lý do:

- Có một vertical slice chạy được rất sớm
- Giảm rủi ro thiết kế sai data model
- Dễ demo tiến độ ngay từ tuần đầu
