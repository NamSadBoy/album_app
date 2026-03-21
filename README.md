# 📸 Ứng dụng Quản lý Album Ảnh (Photo Album Manager)

Một ứng dụng di động đa nền tảng được phát triển bằng Flutter, cung cấp giải pháp lưu trữ, quản lý và tổ chức hình ảnh cá nhân hoàn toàn ngoại tuyến (offline) với độ bảo mật và an toàn dữ liệu cao.

## ✨ Tính năng nổi bật

* **📂 Quản lý thư mục (Album CRUD):** Tạo, đổi tên và xóa các Album phân loại ảnh. Hệ thống bảo vệ dữ liệu chặt chẽ với hộp thoại xác nhận và cơ chế xóa liên đới (Cascade Delete).
* **🖼️ Quản lý hình ảnh (Photo Management):** * Thêm ảnh trực tiếp từ **Máy ảnh (Camera)** hoặc tải lên từ **Thư viện (Gallery)**.
  * Ghi chú thông tin chi tiết: Tên ảnh, Mô tả và Ngày chụp (Tích hợp thiết lập lịch `DatePicker`).
* **🔍 Tìm kiếm & Sắp xếp:** * Thanh tìm kiếm thông minh (Real-time Search) áp dụng cho cả Album và Hình ảnh.
  * Bộ lọc sắp xếp đa dạng: Mới nhất, Cũ nhất, Theo bảng chữ cái (A-Z, Z-A).
* **🔎 Tương tác nâng cao:** Hỗ trợ cử chỉ chạm bằng hai ngón tay để phóng to/thu nhỏ (Pinch-to-zoom) khi xem chi tiết ảnh.
* **🌙 Giao diện tùy chỉnh:** Hỗ trợ chuyển đổi mượt mà giữa Chế độ Sáng (Light Mode) và Chế độ Tối (Dark Mode).

## 🛠️ Công nghệ sử dụng

* **Nền tảng:** Flutter & Dart.
* **Kiến trúc:** MVVM (Model-View-ViewModel).
* **Quản lý trạng thái (State Management):** `provider`
* **Cơ sở dữ liệu:** `sqflite` (Lưu trữ cục bộ với cấu trúc bảng quan hệ và kiểu dữ liệu BLOB cho hình ảnh).
* **Lưu trữ cấu hình:** `shared_preferences` (Lưu trạng thái Dark/Light Mode).
* **Phần cứng:** `image_picker` (Tương tác với Camera và Thư viện ảnh của thiết bị).

