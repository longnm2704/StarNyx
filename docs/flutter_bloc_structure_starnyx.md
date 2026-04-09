# StarNyx — Flutter Folder Structure (BLoC)

## 1. Mục tiêu

Cấu trúc này được thiết kế để:
- Học và áp dụng BLoC đúng cách
- Tách rõ UI / logic / dữ liệu
- Dễ mở rộng nhưng không quá phức tạp

---

## 2. Tổng quan cấu trúc

```txt
lib/
├─ app/
├─ core/
├─ data/
├─ domain/
├─ features/
└─ main.dart
```

---

## 3. Chi tiết từng phần

### 3.1 app/
Chứa cấu hình toàn app

- app.dart: khởi tạo MaterialApp
- router/: điều hướng
- theme/: màu sắc, typography
- di/: dependency injection

---

### 3.2 core/
Dùng chung toàn app

- constants/: hằng số
- utils/: xử lý ngày, streak, json
- services/: notification, import/export
- widgets/: widget dùng lại

---

### 3.3 data/
Xử lý dữ liệu (Drift)

- db/: database + table + dao
- models/: model lưu trữ
- repositories/: implement repository

---

### 3.4 domain/
Logic nghiệp vụ (không phụ thuộc Flutter)

- entities/: object chính
- repositories/: abstract class
- usecases/: xử lý từng chức năng

---

### 3.5 features/
Chia theo từng màn hình

Mỗi feature gồm:
```txt
presentation/
├─ bloc/
├─ pages/
└─ widgets/
```

---

## 4. Các feature chính

- home: màn chính + lưới sao
- starnyx_form: tạo / sửa thói quen
- journal: ghi chú
- settings: cài đặt
- backup: import / export

---

## 5. Luồng dữ liệu

```txt
UI (Widget)
  ↓
Bloc
  ↓
UseCase
  ↓
Repository
  ↓
Local DB (Drift)
```

---

## 6. Quy tắc BLoC

- UI không gọi repository trực tiếp
- Bloc nhận event → xử lý → emit state
- Mỗi bloc chỉ xử lý 1 khu vực

---

## 7. Ví dụ HomeBloc

### Event
- Load dữ liệu
- Đổi ngày
- Đổi năm
- Toggle completion

### State
- loading
- loaded
- error

---

## 8. Thứ tự implement đề xuất

1. Setup app + theme
2. Tạo database (Drift)
3. Tạo domain (entity + repository + usecase)
4. Làm StarnyxFormBloc
5. Làm HomeBloc
6. Làm JournalBloc
7. Làm SettingsBloc
8. Làm Backup + Notification

---

## 9. Nguyên tắc quan trọng

- Không over-engineer
- Ưu tiên chạy được trước
- Giữ code đơn giản, rõ ràng

---

**End of document**
