# StarNyx Visual Baseline

Tài liệu này tổng hợp design direction được rút ra từ toàn bộ mockup trong `docs/ui/` để làm baseline cho các issue UI tiếp theo.

## Mockup Đã Được Đối Chiếu

- `starnyx_welcome.PNG`
- `starnyx_new_constellation.PNG`
- `starnyx_home.PNG`
- `starnyx_bottom_sheet.PNG`
- `starnyx_journal.PNG`
- `starnyx_settings.PNG`
- `starnyx_settings_general.PNG`

## Visual Direction

- Tổng thể: "cosmic minimalism", nền tối, nhiều khoảng thở, ít viền, nhấn bằng gradient accent.
- Không dùng Material mặc định làm giao diện chính; Material chỉ đóng vai trò layout và interaction shell.
- Mỗi màn hình đặt trên nền vũ trụ có gradient màu và lớp "starfield" rất nhẹ.

## Palette Khởi Tạo

- `background`: `#05030A`
- `backgroundMid`: `#1A0D2E`
- `backgroundBottom`: `#6A38A5`
- `surface`: `#26222E`
- `surfaceElevated`: `#332E3D`
- `outline`: `#5E5470`
- `textPrimary`: `#F4ECFF`
- `textSecondary`: `#CDBAE3`
- `textMuted`: `#9988B1`
- `accentBlue`: `#4A86FF`
- `accentViolet`: `#8E5BFF`
- `accentPink`: `#D875FF`
- `accentLavender`: `#E1BCFF`
- `accentOrange`: `#DA7A31`

## Component Language

- CTA chính: pill button cao, border gradient xanh -> tím -> hồng, ruột tối hơn background.
- Card / sheet / settings row: bo góc lớn (`24-30`), màu charcoal, shadow mềm.
- Input: filled surface tối, border rất nhẹ, placeholder muted.
- Nút tròn icon: surface cao hơn nền, border mờ, icon sáng.

## Typography

- Tiêu đề lớn: weight đậm, track chặt, ưu tiên xử lý bằng scale và spacing trước khi đưa custom font vào.
- Tiêu đề phụ và label: màu `textSecondary`, tránh dùng contrast quá yếu.
- CTA label: semi-bold, màu lavender/pink để ăn vào gradient.

## Spacing Và Radius

- Spacing scale: `4 / 8 / 12 / 16 / 24 / 32 / 48`
- Page horizontal padding: `20`
- Page vertical padding: `24`
- Section gap lớn: `24-32`
- Card radius: `24`
- Hero / modal radius: `30`
- Pill radius: `28`

## Ứng Dụng Cho STX-015

- Root app sẽ chuyển sang dark cosmic theme.
- Màn first-run sử dụng:
  - nền gradient + starfield
  - welcome heading 2 dòng
  - subtitle ngắn
  - 1 CTA chính "New Constellation"
  - icon settings tròn ở góc phải trên
- Khi đã có StarNyx, app không hiện welcome nữa mà rơi vào placeholder returning state trong lúc chờ `STX-025`.
