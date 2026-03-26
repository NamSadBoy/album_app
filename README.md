# 📸 Ứng Dụng Quản Lý Album Ảnh (Flutter + Supabase)

**BTL cuối kỳ môn Lập trình Mobile - Trường Đại học Đại Nam**

Đây là ứng dụng quản lý album ảnh đa nền tảng được phát triển bằng framework Flutter, tích hợp hệ quản trị cơ sở dữ liệu đám mây Supabase. Ứng dụng không chỉ cung cấp các tính năng quản lý tệp tin cơ bản mà còn tập trung vào trải nghiệm người dùng (UX) và bảo mật dữ liệu cá nhân.

## 🚀 Các tính năng nổi bật (Features)

* **☁️ Lưu trữ đám mây (Cloud Storage):** Đồng bộ hóa toàn bộ hình ảnh và dữ liệu với máy chủ Supabase, đảm bảo dữ liệu không bị mất khi đổi thiết bị.
* **🔒 Bảo mật Album Ẩn (Hidden Albums):** Tính năng thư mục bảo mật. Người dùng có thể ẩn các album riêng tư và chỉ xem được khi nhập đúng mã PIN (Lưu trữ an toàn cục bộ qua `shared_preferences`).
* **⭐ Thư mục Yêu thích (Favorites):** Ghim các album quan trọng lên đầu danh sách để truy cập nhanh.
* **📷 Tích hợp Camera & Thư viện:** Cho phép tải ảnh lên trực tiếp từ bộ nhớ thiết bị hoặc chụp ảnh mới ngay trong ứng dụng.
* **🔍 Tìm kiếm & Sắp xếp (Search & Sort):** Lọc album/ảnh theo tên và sắp xếp linh hoạt (Mới nhất, Cũ nhất, A-Z, Z-A).
* **🌗 Chế độ Sáng/Tối (Dark/Light Mode):** Thay đổi giao diện linh hoạt theo sở thích người dùng.
* **⚡ Quản lý trạng thái (State Management):** Sử dụng `Provider` để cập nhật UI mượt mà, không giật lag.

## 🛠️ Công nghệ sử dụng (Tech Stack)

* **Frontend:** Flutter, Dart
* **Backend as a Service (BaaS):** Supabase (PostgreSQL Database & Object Storage)
* **State Management:** Provider
* **Local Storage:** Shared Preferences (Lưu mã PIN)
* **Hardware API:** Image Picker (Truy cập Camera và Thư viện ảnh)

