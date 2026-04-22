# STX-051 Manual QA Checklist

Mục tiêu: checklist manual QA cho toàn bộ MVP StarNyx trước demo nội bộ hoặc release candidate.

## 1. Phạm vi

- Build hoạt động offline, không cần đăng nhập.
- Bao phủ các flow chính của MVP: welcome, create/edit/delete StarNyx, home/check-in, journal, settings, reminder, backup import/export.
- Dùng cho smoke test nhanh hoặc full regression thủ công.

## 2. Chuẩn bị

- [ ] Cài mới app hoặc xoá toàn bộ dữ liệu app trước khi bắt đầu vòng test full.
- [ ] Chuẩn bị ít nhất 2 StarNyx test:
  - StarNyx A: có mô tả, có reminder, start date = hôm nay hoặc trong 7 ngày gần nhất.
  - StarNyx B: không reminder, không mô tả.
- [ ] Chuẩn bị 1 file export JSON hợp lệ từ app để test import.
- [ ] Chuẩn bị 1 file JSON không hợp lệ để test nhánh validate import.
- [ ] Nếu test notification, bật quyền notification trên thiết bị.

## 3. Smoke Test

- [ ] Mở app lần đầu không crash, vào đúng welcome state khi chưa có dữ liệu.
- [ ] Tạo mới StarNyx đầu tiên thành công và đi vào home screen.
- [ ] Check-in cho ngày hợp lệ hoạt động.
- [ ] Mở bottom sheet từ home và chuyển sang StarNyx khác được.
- [ ] Tạo journal entry cho ngày hiện tại được.
- [ ] Export JSON thành công.
- [ ] Import lại từ file hợp lệ thành công.
- [ ] Đóng app và mở lại, dữ liệu vẫn còn.

## 4. Welcome Và Empty State

- [ ] Lần mở đầu hiển thị đúng empty state, CTA tạo StarNyx rõ ràng.
- [ ] Không còn welcome state sau khi đã tạo ít nhất 1 StarNyx.
- [ ] Khi xoá StarNyx cuối cùng, app quay lại trạng thái không có dữ liệu phù hợp.

## 5. Create StarNyx

- [ ] Mở flow create từ CTA đầu tiên hoặc từ bottom sheet.
- [ ] Trường title là bắt buộc, không cho lưu khi rỗng.
- [ ] Có thể nhập mô tả tuỳ chọn.
- [ ] Có thể chọn màu và màu được phản ánh ở home sau khi lưu.
- [ ] Start date mặc định là hôm nay.
- [ ] Cho chọn start date trong khoảng từ 7 ngày trước đến hôm nay.
- [ ] Không cho chọn start date ở tương lai.
- [ ] Không cho chọn start date cũ hơn 7 ngày.
- [ ] Khi bật reminder, có thể chọn giờ và app lưu đúng `HH:mm` người dùng đã chọn.
- [ ] Khi tắt reminder, reminder time không còn được lưu.
- [ ] Lưu thành công tạo đúng 1 StarNyx mới.

## 6. Edit Và Delete StarNyx

- [ ] Mở flow edit từ bottom sheet hoặc danh sách StarNyx.
- [ ] Form edit được prefill đúng title, description, color, reminder, start date hiện tại.
- [ ] Sửa title/description/color rồi lưu, home cập nhật đúng dữ liệu mới.
- [ ] Đổi giờ reminder rồi lưu, reminder cũ được thay bằng giờ mới.
- [ ] Tắt reminder ở StarNyx đang có reminder rồi lưu, reminder bị huỷ.
- [ ] Xoá StarNyx yêu cầu xác nhận trước khi xoá thật.
- [ ] Xoá StarNyx đang được chọn thì app chọn fallback hợp lệ hoặc về empty state nếu không còn item nào.
- [ ] Xoá StarNyx đồng thời xoá completions và journal entries liên quan.

## 7. Home Screen Và Star Grid

- [ ] Home hiển thị đúng StarNyx đang chọn.
- [ ] Grid năm có 365 ô với năm thường và 366 ô với năm nhuận.
- [ ] Grid giữ layout 18 cột ổn định.
- [ ] Các trạng thái `before start`, `completed`, `missed`, `future`, `selected`, `today` hiển thị đúng.
- [ ] Chạm vào một ngày hợp lệ làm thay đổi selected date.
- [ ] Nút previous day chuyển đúng sang ngày trước.
- [ ] Nút next day chuyển đúng sang ngày sau.
- [ ] Nút `Today` quay về ngày hiện tại.
- [ ] Đổi năm đang xem hoạt động đúng.
- [ ] Không cho đổi sang năm lớn hơn năm hiện tại.
- [ ] Nếu app build hiện tại có thống kê, các số liệu current streak, longest streak, total completed, completion rate hiển thị nhất quán với dữ liệu mẫu.

## 8. Check-In Rules

- [ ] Có thể check-in cho ngày hôm nay nếu ngày đó hợp lệ.
- [ ] Có thể bỏ check-in trong cửa sổ cho phép chỉnh sửa.
- [ ] Không cho check-in ngày tương lai.
- [ ] Không cho check-in ngày trước start date.
- [ ] Chỉ cho sửa completion trong 7 ngày gần nhất.
- [ ] Các ngày quá 7 ngày bị khoá và không toggle được.
- [ ] Sau mỗi lần toggle, trạng thái ngôi sao và thống kê liên quan được cập nhật ngay.

## 9. Multiple StarNyx Và Bottom Sheet

- [ ] Vuốt lên hoặc chạm đúng entry point để mở bottom sheet.
- [ ] Bottom sheet hiển thị danh sách StarNyx đã lưu.
- [ ] Chọn một StarNyx khác làm đổi active StarNyx trên home.
- [ ] Có thể vào create từ bottom sheet.
- [ ] Có thể vào edit từ card của từng StarNyx.
- [ ] Chế độ reorder nếu đang bật phải đổi được UI sang trạng thái reorder và thoát lại bình thường.
- [ ] StarNyx đang active được hiển thị khác biệt rõ với item còn lại.

## 10. Journal

- [ ] Mở journal từ home/bottom sheet thành công.
- [ ] Có thể tạo ghi chú cho ngày hiện tại.
- [ ] Nếu spec/build hiện tại giới hạn số lượng note theo ngày, xác nhận rule đó hoạt động đúng.
- [ ] Ghi chú mới hiển thị đúng nội dung vừa nhập.
- [ ] Danh sách journal hiển thị đúng thứ tự theo thiết kế hiện tại của app.
- [ ] Không có flow edit in-place cho journal entry.
- [ ] Có thể xoá journal entry.
- [ ] Sau khi xoá, entry biến mất và không còn sau khi mở lại app.

## 11. Notifications

- [ ] Tạo StarNyx với reminder bật sẽ tạo reminder tương ứng.
- [ ] Sửa giờ reminder sẽ cập nhật reminder.
- [ ] Tắt reminder sẽ huỷ reminder hiện có.
- [ ] Xoá StarNyx có reminder sẽ huỷ reminder liên quan.
- [ ] Import dữ liệu có reminder sẽ rebuild reminder schedules.
- [ ] Không tạo reminder khi reminderEnabled = false.

## 12. Settings, Backup, Import, Export

- [ ] Mở settings screen thành công.
- [ ] Vào khu vực backup/import/export thành công.
- [ ] Export tạo ra file JSON hợp lệ.
- [ ] JSON export chứa StarNyx, completions, journal entries, app settings.
- [ ] Import file JSON hợp lệ ghi đè dữ liệu hiện tại thành công.
- [ ] Sau import thành công, UI hiển thị dữ liệu mới thay vì dữ liệu cũ.
- [ ] Import file JSON không hợp lệ bị chặn và hiển thị lỗi phù hợp.
- [ ] Nếu import lỗi giữa chừng, dữ liệu cũ được rollback.
- [ ] Sau import thành công, app vẫn mở lại bình thường và dữ liệu tồn tại.

## 13. Persistence Và Offline

- [ ] Tắt hẳn app và mở lại, StarNyx đang chọn gần nhất được restore đúng.
- [ ] Completions vẫn tồn tại sau relaunch.
- [ ] Journal entries vẫn tồn tại sau relaunch.
- [ ] Settings vẫn tồn tại sau relaunch.
- [ ] Bật airplane mode hoặc không có mạng, các flow chính vẫn hoạt động bình thường.

## 14. UX Và Regression Notes

- [ ] Không có crash khi mở/đóng bottom sheet, journal, settings, import/export.
- [ ] Không có layout vỡ nghiêm trọng ở màn hình nhỏ.
- [ ] Không bị che nội dung quan trọng bởi safe area hoặc keyboard.
- [ ] Không có text sai chính tả rõ ràng hoặc key localization bị lộ ra UI.
- [ ] Icon, màu và trạng thái tương tác nhất quán giữa create/edit/home/journal/settings.

## 15. Kết Quả Vòng QA

- Build tested:
- Thiết bị / OS:
- Người test:
- Ngày test:
- Kết quả chung: Pass / Pass with notes / Fail
- Bug hoặc ghi chú follow-up:
