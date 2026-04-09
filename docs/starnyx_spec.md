# StarNyx — Product Requirements Document (PRD)

## 1. Tổng quan sản phẩm

### 1.1 Tên sản phẩm

**StarNyx**

### 1.2 Product vision

StarNyx là ứng dụng mobile theo dõi thói quen theo hướng tối giản, riêng tư và giàu tính thẩm mỹ.  
Mỗi thói quen được biểu diễn như một **constellation** (chòm sao), và tiến trình mỗi ngày được hiển thị bằng **star grid** theo thời gian.

### 1.3 Mục tiêu sản phẩm

Xây dựng một ứng dụng habit tracking có các đặc điểm sau:

- Hoạt động **offline-first**, không phụ thuộc internet
- **Không yêu cầu tài khoản**
- **Không tracking / analytics**
- Tập trung vào trải nghiệm đơn giản, nhanh, dễ dùng
- Có ngôn ngữ hình ảnh riêng: theo dõi thói quen như quan sát bầu trời sao

### 1.4 Đối tượng người dùng

Người dùng cá nhân muốn:

- Theo dõi thói quen hằng ngày
- Có trải nghiệm riêng tư, không bị phân tán
- Sử dụng app nhẹ, nhanh, không cần đăng nhập
- Nhìn thấy tiến trình dưới dạng trực quan thay vì dạng checklist khô cứng

---

## 2. Phạm vi sản phẩm

### 2.1 Phạm vi MVP

MVP bao gồm:

1. Tạo, sửa, lưu trữ và xoá một StarNyx
2. Check-in hằng ngày cho từng StarNyx
3. Hiển thị star grid theo ngày trong năm
4. Tính toán:
   - Current streak
   - Best streak
   - Completion count
   - Completion rate
5. Local notification theo giờ người dùng chọn
6. Journal theo ngày cho từng StarNyx
7. Archive / restore StarNyx
8. Export / import dữ liệu bằng file JSON

### 2.2 Ngoài phạm vi MVP

Các tính năng sau **không bắt buộc** trong phiên bản đầu:

- Chia sẻ dữ liệu đa thiết bị
- Gamification phức tạp
- Widget
- Đa ngôn ngữ

### 2.3 Hướng phát triển sau MVP

Các tính năng có thể bổ sung sau:

- Đa ngôn ngữ (VI / EN)
- Home widget
- Tuỳ biến theme / visual style
- Backup thủ công sang file / thư mục ngoài
- Insight nâng cao theo tuần / tháng / năm

---

## 3. Nguyên tắc thiết kế sản phẩm

### 3.1 Design principles

1. **Private by default**  
   Mọi dữ liệu chỉ lưu cục bộ trên thiết bị.

2. **Fast by default**  
   Các thao tác quan trọng phải phản hồi gần như tức thì.

3. **Calm UI**  
   Giao diện tối giản, ít nhiễu, ưu tiên tập trung vào một StarNyx tại một thời điểm.

4. **Progress as a sky map**  
   Dữ liệu tiến trình không hiển thị như checklist truyền thống mà như bầu trời sao theo thời gian.

---

## 4. Thuật ngữ

- **StarNyx / Constellation**: một habit hoặc mục tiêu theo dõi
- **Active StarNyx**: StarNyx đang được chọn để hiển thị chính trên màn hình
- **Check-in / Completion**: trạng thái hoàn thành của một ngày
- **Star Grid**: lưới ngôi sao đại diện cho các ngày trong năm
- **Journal Entry**: ghi chú của một ngày thuộc một StarNyx
- **Archive**: trạng thái ẩn khỏi Home nhưng vẫn giữ dữ liệu
- **Reminder**: local notification hằng ngày cho một StarNyx

---

## 5. Kiến trúc thông tin

### 5.1 Màn hình / khu vực chính

Ứng dụng gồm các khu vực sau:

1. Welcome state
2. Home / StarNyx detail
3. Observation Deck (bottom sheet danh sách StarNyx)
4. Create / Edit StarNyx (bottom sheet)
5. Settings
6. Journal (bottom sheet)
7. Archive management
8. Export / Import

---

## 6. User flows

### 6.1 First-time user flow

**Điều kiện:** người dùng chưa có StarNyx nào

**Luồng:**

1. Mở app
2. Hiển thị màn hình chào mừng
3. Người dùng nhấn **New constellation**
4. Mở bottom sheet tạo StarNyx
5. Điền thông tin và lưu
6. App chuyển sang Home với StarNyx vừa tạo là active StarNyx

### 6.2 Returning user flow

**Điều kiện:** đã có ít nhất một StarNyx

**Luồng:**

1. Mở app
2. App hiển thị StarNyx được active gần nhất
3. Người dùng có thể:
   - Check-in cho ngày hiện tại
   - Chuyển ngày đang xem
   - Mở Observation Deck để đổi StarNyx
   - Mở Journal
   - Tạo StarNyx mới
   - Mở Settings

### 6.3 Create StarNyx flow

1. Người dùng nhấn **New constellation** hoặc nút **Plus**
2. Hiển thị bottom sheet tạo mới
3. Người dùng nhập dữ liệu bắt buộc
4. Nhấn **Save constellation**
5. Hệ thống:
   - Lưu dữ liệu StarNyx
   - Thiết lập active StarNyx
   - Schedule local notification nếu reminder bật

### 6.4 Edit StarNyx flow

1. Người dùng mở Observation Deck
2. Long press vào một StarNyx
3. Chọn **Edit**
4. Sửa thông tin
5. Lưu thay đổi
6. Hệ thống cập nhật dữ liệu và reschedule notification nếu cần

### 6.5 Archive flow

1. Người dùng long press vào StarNyx
2. Chọn **Archive**
3. Hệ thống:
   - Đánh dấu StarNyx là archived
   - Ẩn khỏi danh sách Home
   - Huỷ notification đang có của StarNyx đó

### 6.6 Restore flow

1. Người dùng vào khu vực Archive
2. Chọn một StarNyx đã archive
3. Chọn **Restore**
4. Hệ thống:
   - Khôi phục StarNyx về danh sách active
   - Reschedule reminder nếu StarNyx có reminder bật

### 6.7 Export flow

1. Người dùng vào Settings
2. Chọn **Export data**
3. App sinh file JSON
4. Người dùng chọn nơi lưu / chia sẻ file

### 6.8 Import flow

1. Người dùng vào Settings
2. Chọn **Import data**
3. Chọn file JSON
4. Hệ thống validate dữ liệu
5. Nếu hợp lệ:
   - Backup dữ liệu hiện tại tạm thời
   - Overwrite toàn bộ dữ liệu
   - Reschedule toàn bộ notification
6. Nếu không hợp lệ:
   - Không thay đổi dữ liệu hiện tại
   - Hiển thị lỗi import

---

## 7. Yêu cầu chức năng chi tiết

### 7.1 Welcome state

#### Mục tiêu

Giúp người dùng mới bắt đầu nhanh khi chưa có dữ liệu.

#### Hiển thị

- Tiêu đề chào mừng
- Mô tả ngắn
- Nút chính: **New constellation**
- Icon Settings ở góc trên bên phải

#### Hành vi

- Nhấn **New constellation** → mở Create StarNyx bottom sheet
- Nhấn icon **Settings** → mở Settings bottom sheet

#### Gợi ý copy

- Title: **Welcome back**
- Subtitle: **Need to create a new constellation? You're in the right place.**

---

### 7.2 Settings

#### Cấu trúc

Settings mở dưới dạng bottom sheet từ dưới lên.

#### Nhóm nội dung

**General**

- Mở sang màn hình con bằng animation từ phải sang trái
- Tạm thời có thể dùng một số setting UI mẫu để hoàn thiện layout, ví dụ:
  - Enable haptics
  - Confirm before delete
  - Show archived items count
  - Use system theme

**Legal**

- Terms
- Privacy

#### Hành vi

- Terms / Privacy mở link ngoài ứng dụng
- Các setting mẫu ở General có thể chưa cần business logic đầy đủ trong MVP, nhưng cần chuẩn bị UI structure

---

### 7.3 Create / Edit StarNyx

#### Trường dữ liệu

**Bắt buộc**

- Title
- Color

**Tuỳ chọn**

- Description
- Reminder
- Start On

#### Định nghĩa trường

**Title**

- Kiểu dữ liệu: string
- Bắt buộc
- Không được để trống sau khi trim
- Giới hạn đề xuất: 1–60 ký tự

**Description**

- Kiểu dữ liệu: string
- Tuỳ chọn
- Giới hạn đề xuất: 0–240 ký tự

**Color**

- Kiểu dữ liệu: enum hoặc string token
- Bắt buộc
- Chọn từ palette định nghĩa sẵn trong app

**Reminder**

- Kiểu dữ liệu: boolean + time
- Tuỳ chọn
- Khi bật switch thì hiển thị bộ chọn giờ
- Giá trị mặc định:
  - Switch: off
  - Time: giờ gần nhất hoặc giờ mặc định của hệ thống theo thiết kế cuối cùng

**Start On**

- Kiểu dữ liệu: boolean + date
- Tuỳ chọn
- Khi bật switch thì hiển thị bộ chọn ngày bắt đầu
- Nếu không bật, hệ thống mặc định lấy **ngày hiện tại tại thời điểm tạo**
- Nếu bật nhưng người dùng không đổi, mặc định là ngày hiện tại

#### Quy tắc validate

- Không cho lưu nếu Title rỗng
- Start date không được lớn hơn ngày hiện tại
- Reminder time chỉ lưu khi reminder bật

#### Hành vi khi save

- Create:
  - Tạo StarNyx mới
  - Tự động đặt làm active StarNyx
  - Lưu lastOpenedAt / lastActiveAt
  - Schedule notification nếu reminder bật
- Edit:
  - Cập nhật dữ liệu
  - Nếu reminder thay đổi → cancel / reschedule tương ứng
  - Nếu StarNyx đang active thì Home cập nhật ngay

---

### 7.4 Home / StarNyx detail

#### Mục tiêu

Hiển thị một StarNyx tại một thời điểm với trọng tâm là star grid của năm đang xem.

#### Dữ liệu hiển thị

- StarNyx đang active gần nhất
- Star grid của năm đang xem
- Ngày đang được chọn
- Nút điều hướng ngày
- Điều hướng năm
- Số ngày còn lại của năm hiện tại

#### Observation Deck trigger

Người dùng vuốt từ dưới lên để mở bottom sheet cao khoảng **70% màn hình**.

#### Observation Deck gồm

1. Title: **Observation Deck**
2. Summary metrics:
   - Total completions
   - Current streak hoặc total streak theo quyết định cuối cùng
   - Completion rate
3. Hàng action:
   - Settings
   - Journal
   - Plus
4. Danh sách các StarNyx hiện có

#### Hành vi trong Observation Deck

- Tap vào một StarNyx:
  - đặt StarNyx đó thành active
  - đóng sheet
  - cập nhật Home
- Long press vào một StarNyx:
  - mở action modal
  - các action:
    - Archive
    - Edit
    - Delete

#### Star Grid

**Quy tắc hiển thị**

- Mỗi năm hiển thị toàn bộ số ngày của năm đó:
  - 365 ô với năm thường
  - 366 ô với năm nhuận
- Mỗi ô là một ngôi sao đại diện cho một ngày
- Đề xuất layout ban đầu:
  - 18 cột mỗi hàng
  - Hàng cuối có thể không đủ số ô
- Ô của ngày hiện tại phải được nhận diện rõ
- Ô đã completed hiển thị trạng thái sáng
- Ô missed hiển thị trạng thái mờ
- Ô tương lai hiển thị disabled / inactive
- Ô đang được chọn hiển thị trạng thái selected

**Tương tác**

- Tap vào một ngôi sao:
  - chọn ngày tương ứng
  - cập nhật nhãn ngày bên dưới grid
- Tap vào nút ngày tháng:
  - đưa focus về đúng ngày đang hiển thị trên nút
- Tap icon trái / phải cạnh nút ngày:
  - chuyển sang ngày trước / ngày sau
- Tap nút **Current date**:
  - quay về ngày hiện tại
  - chọn đúng ngôi sao của ngày hiện tại

#### Điều hướng năm

- Hiển thị ở góc dưới bên trái: ví dụ `< 2026 >`
- Tap mũi tên trái / phải để chuyển năm
- Góc dưới bên phải hiển thị: ví dụ `226 days left`

#### Quy tắc khi mở Home

- Nếu có active StarNyx trước đó, mở đúng StarNyx đó
- Nếu active StarNyx đã bị archive / delete, chọn StarNyx hợp lệ gần nhất
- Nếu không còn StarNyx active nào, quay về Welcome state

---

### 7.5 Check-in / Completion

#### Mục tiêu

Cho phép người dùng đánh dấu hoàn thành một ngày cho một StarNyx.

#### Quy tắc

- Mỗi StarNyx có tối đa **1 completion / ngày**
- Không cho tạo completion cho ngày trước startDate
- Không cho completion cho ngày tương lai
- Hành vi check-in có thể là:
  - tap vào sao của ngày hiện tại để toggle, hoặc
  - thông qua CTA riêng trong UI chi tiết

#### Kỳ vọng UX

- Phản hồi gần như tức thì
- Cập nhật trạng thái sao, completion count và streak ngay sau thao tác

---

### 7.6 Journal

#### Mục tiêu

Cho phép ghi lại ghi chú ngắn theo từng ngày của từng StarNyx.

#### Quy tắc

- Mỗi StarNyx có tối đa **1 journal entry / ngày**
- Một ngày đã có entry thì khi submit lần nữa sẽ là update entry hiện có
- Journal entry gắn với:
  - starnyxId
  - date
  - content
  - createdAt
  - updatedAt

#### UI / tương tác

- Journal mở dưới dạng bottom sheet
- Có vùng hiển thị danh sách entry theo kiểu message / chat
- Có ô input để nhập nội dung
- Submit xong thì entry xuất hiện ngay trong danh sách

#### Phạm vi dữ liệu

- Chỉ hiển thị journal của StarNyx đang active
- Có thể mặc định focus vào ngày đang selected trên Home, hoặc hiển thị list toàn bộ theo ngày giảm dần

---

### 7.7 Archive

#### Quy tắc

- StarNyx archived:
  - không hiển thị ở Home / Observation Deck chính
  - không mất lịch sử completion
  - không mất journal
  - có thể restore
- Khi archive:
  - cancel reminder
- Khi restore:
  - nếu reminder bật thì reschedule reminder

---

### 7.8 Delete

#### Quy tắc

- Delete là xoá vĩnh viễn dữ liệu của StarNyx:
  - metadata
  - completions
  - journal entries
  - reminder config
- Cần có confirm trước khi xoá
- Khi delete:
  - cancel notification
  - nếu StarNyx đang active thì chọn active StarNyx khác
  - nếu không còn StarNyx nào thì quay về Welcome state

---

### 7.9 Export / Import

#### Export

**Mục tiêu**
Cho phép người dùng sao lưu thủ công toàn bộ dữ liệu.

**Định dạng**

- File JSON
- UTF-8
- Có version để phục vụ migrate về sau

**Dữ liệu export gồm**

- App metadata / schema version
- Danh sách StarNyx
- Completion records
- Journal entries
- Settings cần thiết cho restore
- Timestamp export

#### Import

**Mục tiêu**
Khôi phục dữ liệu từ file backup.

**Quy tắc**

- Import theo kiểu **overwrite toàn bộ dữ liệu hiện tại**
- Phải validate file trước khi ghi
- Phải có cơ chế rollback nếu import thất bại giữa chừng
- Sau import thành công:
  - reschedule toàn bộ notification
  - cập nhật active StarNyx hợp lệ

---

## 8. Business rules

### 8.1 Current streak

#### Định nghĩa

Current streak là chuỗi ngày hoàn thành liên tiếp gần nhất tính từ hiện tại.

#### Quy tắc

- Nếu hôm nay completed → tính ngược từ hôm nay
- Nếu hôm nay chưa completed nhưng hôm qua completed → tính ngược từ hôm qua
- Nếu cả hôm nay và hôm qua đều không completed → current streak = 0

### 8.2 Best streak

#### Định nghĩa

Best streak là chuỗi completion liên tiếp dài nhất trong toàn bộ lịch sử của một StarNyx.

#### Quy tắc

- Duyệt toàn bộ completion record theo thứ tự ngày tăng dần
- Tính chuỗi ngày liên tiếp dài nhất
- Không phụ thuộc năm hiển thị hiện tại

### 8.3 Completion count

- Tổng số ngày đã completed của một StarNyx

### 8.4 Completion rate

#### Công thức đề xuất

`completionRate = completedDays / eligibleDays`

Trong đó:

- `completedDays`: số ngày đã complete
- `eligibleDays`: số ngày từ `startDate` đến `min(hôm nay, ngày cuối của năm / phạm vi đang xét)`

### 8.5 Star Grid status

Với mỗi ngày trong grid:

- **Before start date** → disabled
- **Completed** → bright
- **Missed** → dim
- **Today** → có chỉ báo riêng
- **Future date** → inactive
- **Selected date** → selected state

---

## 9. Notification rules

### 9.1 Loại notification

- Local notification
- Lặp lại hằng ngày theo giờ đã cấu hình

### 9.2 Khi nào schedule

- Khi tạo StarNyx mới và reminder đang bật
- Khi edit StarNyx và reminder được bật mới
- Khi restore / unarchive
- Sau import thành công đối với các StarNyx có reminder bật

### 9.3 Khi nào cancel

- Khi archive
- Khi delete
- Khi người dùng tắt reminder
- Khi thay đổi giờ reminder trước khi reschedule giờ mới

### 9.4 Khi nào reschedule

- Khi người dùng đổi giờ reminder
- Sau import thành công
- Khi unarchive / restore

---

## 10. Data model đề xuất

### 10.1 StarNyx

```json
{
  "id": "string",
  "title": "string",
  "description": "string | null",
  "color": "string",
  "startDate": "YYYY-MM-DD",
  "reminderEnabled": true,
  "reminderTime": "HH:mm | null",
  "isArchived": false,
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601",
  "lastOpenedAt": "ISO-8601 | null"
}
```

### 10.2 CompletionRecord

```json
{
  "id": "string",
  "starnyxId": "string",
  "date": "YYYY-MM-DD",
  "completed": true,
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601"
}
```

### 10.3 JournalEntry

```json
{
  "id": "string",
  "starnyxId": "string",
  "date": "YYYY-MM-DD",
  "content": "string",
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601"
}
```

### 10.4 AppSettings

```json
{
  "activeStarNyxId": "string | null",
  "enableHaptics": true,
  "confirmBeforeDelete": true,
  "schemaVersion": 1
}
```

---

## 11. Import / Export schema đề xuất

### 11.1 JSON structure

```json
{
  "schemaVersion": 1,
  "exportedAt": "2026-04-09T10:00:00Z",
  "app": {
    "name": "StarNyx",
    "platform": "mobile"
  },
  "settings": {
    "activeStarNyxId": "starnyx_1"
  },
  "starnyxs": [],
  "completions": [],
  "journalEntries": []
}
```

### 11.2 Quy tắc validate import

File import hợp lệ khi:

- Là JSON parse được
- Có `schemaVersion`
- `starnyxs`, `completions`, `journalEntries` là array
- Mọi record có khoá bắt buộc
- Không có completion trỏ tới starnyx không tồn tại
- Không có journal entry trỏ tới starnyx không tồn tại
- Không có dữ liệu ngày sai format
- Không có nhiều record trùng unique key logic

### 11.3 Quy trình import an toàn

1. Parse file
2. Validate schema
3. Validate quan hệ dữ liệu
4. Tạo backup tạm dữ liệu hiện tại
5. Ghi dữ liệu mới trong transaction
6. Nếu lỗi bất kỳ bước nào sau khi bắt đầu ghi → rollback
7. Nếu thành công → commit và reschedule notification

---

## 12. Non-functional requirements

### 12.1 Hiệu năng

- Cold launch dưới **2 giây** trên thiết bị mục tiêu
- Scroll và animation đạt cảm giác mượt, mục tiêu **60fps**
- Mở bottom sheet và chuyển state không bị delay đáng kể

### 12.2 Offline

- Toàn bộ tính năng chính hoạt động không cần internet
- Không phụ thuộc API bên ngoài để chạy app

### 12.3 Độ bền dữ liệu

- Không mất dữ liệu sau khi app bị kill đột ngột trong điều kiện bình thường
- Import phải có rollback nếu thất bại
- Ghi dữ liệu cần đảm bảo tính toàn vẹn

### 12.4 Quyền riêng tư

- Không analytics
- Không account
- Không cloud sync
- Không gửi dữ liệu ra server

### 12.5 Khả năng bảo trì

- Data schema có version để migrate
- Import format có version
- Notification logic tách rõ khỏi UI layer

---

## 13. Error handling

### 13.1 Create / Edit

- Title rỗng → hiển thị lỗi inline
- Start date không hợp lệ → không cho save

### 13.2 Import

- File không đọc được → báo lỗi
- JSON sai format → báo lỗi
- Schema không hợp lệ → báo lỗi
- Import fail giữa chừng → rollback toàn bộ, dữ liệu cũ giữ nguyên

### 13.3 Notification

- Nếu schedule local notification thất bại:
  - vẫn lưu StarNyx
  - hiển thị cảnh báo nhẹ để người dùng biết reminder chưa hoạt động

---

## 14. Acceptance criteria

### 14.1 Welcome

- Khi app chưa có StarNyx nào, hiển thị màn hình Welcome
- Nhấn **New constellation** mở đúng bottom sheet tạo mới

### 14.2 Create StarNyx

- Không thể lưu khi Title rỗng
- Lưu thành công thì StarNyx mới xuất hiện ngay trong app
- Nếu reminder bật, notification được schedule

### 14.3 Home

- Khi mở app, hiển thị đúng StarNyx active gần nhất
- Star của ngày hiện tại được nhận diện chính xác
- Tap vào ngày phản hồi ngay
- Chuyển ngày trái / phải cập nhật đúng selected date

### 14.4 Observation Deck

- Vuốt từ dưới lên mở được sheet
- Tap StarNyx đổi đúng active StarNyx
- Long press hiển thị đúng action modal

### 14.5 Journal

- Có thể tạo / cập nhật tối đa 1 entry cho mỗi ngày của mỗi StarNyx
- Submit xong entry hiển thị ngay

### 14.6 Archive / Restore

- Archive xong StarNyx biến mất khỏi danh sách chính
- Restore xong StarNyx xuất hiện lại
- Reminder được cancel / reschedule đúng lúc

### 14.7 Delete

- Delete yêu cầu confirm
- Delete xong dữ liệu liên quan bị xoá hoàn toàn
- Nếu xoá StarNyx active, app chọn StarNyx active khác hợp lệ hoặc về Welcome state

### 14.8 Import / Export

- Export tạo đúng file JSON hợp lệ
- Import file lỗi → không ghi đè dữ liệu hiện tại
- Import file đúng → khôi phục đầy đủ dữ liệu và reminder
- Sau import thành công, app hoạt động bình thường

---

## 15. Open questions cần chốt thêm

### 15.1 Database

- Dùng Drift hay SQLite wrapper khác? => Dùng Drift
- Có cần migration plan ngay từ v1 không? => Cần

### 15.2 Grid layout

- 18 cột có phải layout cuối cùng không? => là layout cuối cùng
- Có cần tối ưu cho màn hình nhỏ / landscape không? => không

### 15.3 Completion interaction

- Check-in bằng tap trực tiếp vào sao hôm nay hay có CTA riêng? => có button ngày tháng bên dưới bảng grid
- Có cho phép toggle completion của ngày trong quá khứ không? => có nhưng chỉ cho phép sửa đổi trong vòng 7 ngày từ ngày hôm nay

### 15.4 Journal scope

- Journal sheet hiển thị tất cả entry hay chỉ entry của ngày đang chọn? => tất cả
- Input mặc định ghi cho selected date hay current date? > cho current date

### 15.5 Metrics

- Summary hiển thị current streak hay total streak? => total
- Completion rate tính all-time hay theo năm đang xem? => năm đang xem

### 15.6 Reminder default time

- “Giờ gần đây” cần được định nghĩa chính xác:
  - giờ hiện tại làm tròn? => giờ hiện tại làm tròn
  - giờ dùng gần nhất?
  - hay giờ mặc định cố định?

---

## 16. Khuyến nghị cho dev handoff

### Nên chốt ngay trước khi code

1. Data model cuối cùng
2. Grid interaction
3. Journal behavior
4. Completion rate definition
5. Reminder default logic
6. Import schema versioning

### Nên tách implementation thành các module

- Domain model
- Local database
- Notification service
- Import / export service
- Home / Grid UI
- Journal module
- Settings module
