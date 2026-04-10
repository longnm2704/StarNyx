# StarNyx — Tài liệu đặc tả sản phẩm (Final)

## 1. Tổng quan

### 1.1 Tên

**StarNyx**

### 1.2 Mô tả

StarNyx là ứng dụng mobile giúp theo dõi thói quen theo hướng tối giản và riêng tư.  
Mỗi thói quen được biểu diễn như một chòm sao, và tiến trình mỗi ngày được hiển thị dưới dạng lưới ngôi sao theo thời gian.

### 1.3 Mục tiêu

- Hoạt động offline hoàn toàn
- Không tài khoản
- Không theo dõi dữ liệu người dùng
- Nhanh, đơn giản, dễ dùng
- Trực quan bằng hình ảnh “bầu trời sao”

---

## 2. Phạm vi MVP

- Tạo / sửa / xoá StarNyx
- Chuyển StarNyx đang chọn khi có nhiều StarNyx
- Check-in theo ngày
- Hiển thị lưới sao theo năm
- Thống kê:
  - Chuỗi hiện tại
  - Chuỗi dài nhất
  - Số lần hoàn thành
  - Tỉ lệ hoàn thành (theo năm đang xem)
- Thông báo nhắc hằng ngày
- Ghi chú theo ngày
- Xuất / nhập dữ liệu JSON

---

## 3. Nguyên tắc thiết kế

- Riêng tư mặc định
- Phản hồi nhanh
- Giao diện nhẹ, ít nhiễu
- Tiến trình = bầu trời sao

---

## 4. Thuật ngữ

- StarNyx: một thói quen
- StarNyx đang chọn: đang hiển thị chính
- Hoàn thành: check-in của ngày
- Lưới sao: toàn bộ ngày trong năm
- Ghi chú: nội dung theo ngày

---

## 5. Luồng sử dụng

### Lần đầu

Mở app → tạo mới → vào màn chính

### Người dùng cũ

Mở app → hiển thị StarNyx gần nhất → thao tác

### Nhiều StarNyx

- Có thể tạo nhiều StarNyx
- App luôn có 1 StarNyx đang chọn để hiển thị chính
- Có thể đổi StarNyx đang chọn từ màn chính
- Lần mở app tiếp theo khôi phục StarNyx được chọn gần nhất

---

## 6. Chức năng chi tiết

## 6.1 Tạo / sửa

### Trường dữ liệu

- Tiêu đề (bắt buộc)
- Màu (bắt buộc)
- Mô tả (tuỳ chọn)
- Nhắc nhở (tuỳ chọn)
- Ngày bắt đầu (tuỳ chọn, mặc định hôm nay)

### Quy tắc

- Tiêu đề không được rỗng
- Ngày bắt đầu không lớn hơn hôm nay
- Chỉ lưu giờ nhắc khi bật

### Giờ nhắc mặc định

- Làm tròn về mốc 30 phút gần nhất:
  - phút 00-14 → `HH:00`
  - phút 15-44 → `HH:30`
  - phút 45-59 → giờ kế tiếp `HH+1:00`
  - Ví dụ: `10:12 → 10:00`, `10:20 → 10:30`, `10:50 → 11:00`

---

## 6.2 Màn chính + lưới sao

### Lưới sao

- 365 hoặc 366 ô
- 18 cột
- Trạng thái:
  - trước ngày bắt đầu → không cho chọn
  - đã hoàn thành → sáng
  - bỏ lỡ → mờ
  - tương lai → không hoạt động
  - đang chọn → nổi bật
  - hôm nay → có dấu riêng

### Tương tác

- Nhấn sao → chọn ngày
- Nút ngày bên dưới:
  → dùng để đánh dấu hoàn thành
- Nút trái / phải → chuyển ngày
- Nút “Today” → về hôm nay
- Có lối vào để đổi StarNyx đang chọn ngay từ màn chính

---

## 6.3 Check-in

### Quy tắc

- Mỗi ngày chỉ 1 lần
- Không cho ngày tương lai
- Không cho trước ngày bắt đầu

### Chỉnh sửa

- Chỉ được sửa trong **7 ngày gần nhất**
- Quá 7 ngày → khoá

---

## 6.4 Ghi chú

- 1 ghi chú / ngày
- Hiển thị dạng danh sách
- Luôn ghi cho **ngày hiện tại**
- Không cho sửa:
  → muốn thay đổi thì xoá và tạo lại

---

## 6.5 Xoá

- Xoá toàn bộ dữ liệu StarNyx
- Có xác nhận trước khi xoá

---

## 6.6 Xuất / nhập dữ liệu

### Xuất

- File JSON
- Bao gồm:
  - StarNyx
  - lịch sử hoàn thành
  - ghi chú
  - cài đặt

### Nhập

- Ghi đè toàn bộ dữ liệu
- Kiểm tra hợp lệ trước
- Có rollback nếu lỗi

---

## 7. Logic xử lý

### Chuỗi hiện tại

- Hôm nay hoàn thành → tính từ hôm nay
- Nếu chưa nhưng hôm qua có → tính từ hôm qua
- Không có → = 0

### Chuỗi dài nhất

- Tìm chuỗi liên tiếp dài nhất

### Tỉ lệ hoàn thành

- Tính theo năm đang xem
- = số ngày hoàn thành / số ngày hợp lệ
- Số ngày hợp lệ được tính từ `max(startDate, 01-01 của năm đang xem)`
  đến `min(hôm nay, 31-12 của năm đang xem)`
- Nếu số ngày hợp lệ = 0 thì tỉ lệ = 0

---

## 8. Thông báo

### Khi tạo / bật

- Tạo mới
- Sửa và bật
- Nhập dữ liệu

### Khi huỷ

- Xoá
- Tắt nhắc

### Khi cập nhật

- Đổi giờ
- Nhập dữ liệu

### Khi đồng bộ lại

- Khi app khởi động
- Khi mở app lại sau khi timezone thay đổi
- Thực hiện bằng cách huỷ toàn bộ lịch cũ và schedule lại từ local data hiện tại

---

## 9. Dữ liệu

### StarNyx

```json
{
  "id": "string",
  "title": "string",
  "description": "string | null",
  "color": "string",
  "startDate": "YYYY-MM-DD",
  "reminderEnabled": true,
  "reminderTime": "HH:mm | null",
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601"
}
```

### Hoàn thành

```json
{
  "starnyxId": "string",
  "date": "YYYY-MM-DD",
  "completed": true
}
```

### Ghi chú

```json
{
  "starnyxId": "string",
  "date": "YYYY-MM-DD",
  "content": "string"
}
```

---

### Cài đặt ứng dụng

```json
{
  "lastSelectedStarnyxId": "string | null",
  "updatedAt": "ISO-8601"
}
```

---

## 10. Định dạng import

```json
{
  "schemaVersion": 1,
  "starnyxs": [],
  "completions": [],
  "journalEntries": [],
  "appSettings": {
    "lastSelectedStarnyxId": null,
    "updatedAt": "ISO-8601"
  }
}
```

---

## 11. Yêu cầu kỹ thuật

- Mở app < 2 giây
- Mượt 60fps
- Hoạt động offline
- Không mất dữ liệu

---

## 12. Quyết định kỹ thuật

- Database: Drift
- Có migration từ phiên bản đầu
- Lưới cố định 18 cột
- Không cần tối ưu cho landscape

---

## 13. Điều kiện hoàn thành

- Mở app → đúng StarNyx gần nhất
- Có thể đổi giữa nhiều StarNyx
- Sao hôm nay chính xác
- Thao tác phản hồi ngay
- Import lỗi → không ghi đè
- Import đúng → khôi phục hoàn chỉnh

---

## 14. Ghi chú cuối

- Sửa check-in trong 7 ngày
- Ghi chú không chỉnh sửa
- Tỉ lệ theo năm
- Giờ nhắc làm tròn

---

**End**
