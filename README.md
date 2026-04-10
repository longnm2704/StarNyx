# StarNyx

StarNyx là ứng dụng mobile theo dõi thói quen theo hướng tối giản và riêng tư.
Mỗi thói quen được biểu diễn như một chòm sao, với tiến trình mỗi ngày hiển thị trên lưới sao theo năm.

## Current Status

- Repo hiện đang ở giai đoạn foundation, mới có Flutter scaffold cơ bản.
- Product spec và implementation plan đã được chốt để bắt đầu implement MVP.
- Trạng thái code hiện tại chưa phản ánh đầy đủ tính năng trong docs.

## Product Goals

- Offline hoàn toàn
- Không tài khoản
- Không tracking dữ liệu người dùng
- Nhanh, đơn giản, dễ dùng
- Giao diện mang cảm giác "bầu trời sao"

## Docs Map

- [Product Spec](docs/starnyx_spec.md): đặc tả sản phẩm cuối cùng cho MVP
- [Implementation Plan](docs/starnyx_implementation_plan.md): phase plan, checklist và definition of done
- [Flutter BLoC Structure](docs/flutter_bloc_structure_starnyx.md): cấu trúc code mục tiêu theo BLoC
- [GitHub MCP Setup](docs/setup_mcp_github.md): tài liệu setup công cụ hỗ trợ làm việc với GitHub MCP
- `docs/ui/`: mockup màn hình tham chiếu cho MVP

## MVP Scope

- Tạo / sửa / xoá StarNyx
- Chuyển giữa nhiều StarNyx và khôi phục StarNyx đã chọn gần nhất
- Check-in theo ngày
- Lưới sao theo năm
- Thống kê streak, tổng hoàn thành, completion rate
- Journal theo ngày
- Reminder local
- Export / import JSON có validate và rollback

## Recommended Reading Order

1. Đọc [Product Spec](docs/starnyx_spec.md)
2. Đọc [Implementation Plan](docs/starnyx_implementation_plan.md)
3. Đọc [Flutter BLoC Structure](docs/flutter_bloc_structure_starnyx.md)
4. Đối chiếu mockup trong `docs/ui/`

## Quickstart

Yêu cầu:

- Flutter SDK phù hợp với `pubspec.yaml`
- Xcode nếu chạy iOS simulator
- Android Studio / Android SDK nếu chạy Android

Lệnh cơ bản:

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run
```

## Working Rules

- Ưu tiên offline-first
- Không thêm dependency hoặc abstraction nếu chưa phục vụ MVP rõ ràng
- UI phải đi theo flow: `UI -> Bloc -> UseCase -> Repository -> Local DB`
- Khi thay đổi product rule, cập nhật `docs/starnyx_spec.md` trước rồi mới sửa plan nếu cần
