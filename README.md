# Workly Flutter - Ứng Dụng Quản Lý Ca Làm Việc Cá Nhân

![Workly Logo](assets/images/logo.png)

**Workly Flutter** là một ứng dụng quản lý ca làm việc cá nhân được phát triển bằng Flutter, giúp người lao động theo dõi và quản lý thời gian làm việc một cách hiệu quả và thông minh.

## 🌟 Tính Năng Chính

### 📱 **Giao Diện Trực Quan**
- **Nút Đa Năng**: Thực hiện đầy đủ quy trình chấm công (Đi Làm → Check-in → Check-out → Hoàn Tất)
- **Chế độ Đơn Giản**: Chỉ hiển thị nút "Đi Làm" cho người dùng cơ bản
- **Lưới Trạng Thái Tuần**: Xem tổng quan trạng thái làm việc 7 ngày
- **Theme Sáng/Tối**: Hỗ trợ chuyển đổi giao diện theo sở thích

### ⏰ **Quản Lý Ca Làm Việc**
- Tạo và quản lý nhiều ca làm việc khác nhau
- Hỗ trợ ca qua đêm với logic tính toán chính xác
- Tự động xoay ca theo cấu hình (hàng tuần/2 tuần/tháng)
- Nhắc nhở thông minh cho từng mốc thời gian

### 📊 **Chấm Công & Thống Kê**
- Chấm công tự động với timestamp chính xác
- Tính toán giờ làm việc theo lịch trình
- Phân loại giờ: Giờ HC, OT, Chủ Nhật, Đêm
- Thống kê chi tiết theo ngày/tuần/tháng

### 🔔 **Nhắc Nhở Thông Minh**
- Báo thức đáng tin cậy (vượt qua chế độ im lặng)
- Nhắc nhở đi làm, chấm công vào/ra
- Quản lý ghi chú với nhắc nhở tùy chỉnh
- Logic chống spam thông báo

### 🌤️ **Cảnh Báo Thời Tiết**
- Tự động xác định vị trí nhà và công ty
- Cảnh báo thời tiết cực đoan (mưa, nóng, lạnh, bão)
- Tối ưu hóa API miễn phí với cache thông minh
- Phân tích mức độ nghiêm trọng

### 💾 **Lưu Trữ An Toàn**
- Lưu trữ cục bộ với SharedPreferences
- Hoạt động offline hoàn toàn
- Sao lưu và phục hồi dữ liệu
- Bảo mật thông tin cá nhân

## 🚀 Cài Đặt và Chạy

### Yêu Cầu Hệ Thống
- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio hoặc VS Code
- Android SDK (cho Android) hoặc Xcode (cho iOS)

### Các Bước Cài Đặt

1. **Clone repository**
   ```bash
   git clone https://github.com/your-username/workly-flutter.git
   cd workly-flutter
   ```

2. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng**
   ```bash
   # Chạy trên thiết bị/emulator
   flutter run
   
   # Chạy trên Android
   flutter run -d android
   
   # Chạy trên iOS
   flutter run -d ios
   ```

### Cấu Hình API Thời Tiết (Tùy chọn)

1. Đăng ký tài khoản miễn phí tại [OpenWeatherMap](https://openweathermap.org/api)
2. Lấy API key
3. Mở ứng dụng → Cài đặt → Thời tiết → Nhập API key

## 🏗️ Kiến Trúc Ứng Dụng

```
lib/
├── constants/              # Constants và themes
│   └── app_theme.dart
├── models/                 # Data models
│   ├── shift.dart
│   ├── attendance_log.dart
│   ├── weather_data.dart
│   ├── user_settings.dart
│   └── note.dart
├── services/               # External services
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── weather_service.dart
│   └── location_service.dart
├── providers/              # State management
│   ├── app_provider.dart
│   ├── shift_provider.dart
│   ├── attendance_provider.dart
│   ├── weather_provider.dart
│   └── notes_provider.dart
├── screens/                # UI screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   └── settings_screen.dart
├── widgets/                # Reusable widgets
│   ├── main_action_button.dart
│   ├── weather_widget.dart
│   ├── weekly_status_grid.dart
│   ├── quick_stats_card.dart
│   └── recent_notes_card.dart
└── main.dart              # Entry point
```

## 🎯 Tính Năng Nổi Bật

### 1. **Logic Tính Công Minh Bạch**
- Phân biệt rõ ràng giữa trạng thái tuân thủ và số giờ công
- Tính toán dựa trên lịch trình ca cố định
- Hỗ trợ ca đêm, OT, Chủ nhật, ngày lễ

### 2. **Hệ Thống Nhắc Nhở "Just-In-Time"**
- Logic chống spam thông báo
- Chỉ lên lịch cho sự kiện tiếp theo gần nhất
- Tự động đồng bộ khi có thay đổi

### 3. **Thời Tiết Theo Ngữ Cảnh**
- Tối ưu hóa API với cache thông minh
- Cảnh báo cho cả chiều đi và về
- Phân tích mức độ nghiêm trọng

### 4. **Xoay Ca Tự Động**
- Hỗ trợ chu kỳ tuần/2 tuần/tháng
- Validation cấu hình
- Thông báo tự động

## 📱 Hướng Dẫn Sử Dụng

### Lần Đầu Sử Dụng

1. **Mở ứng dụng** và cho phép các quyền cần thiết
2. **Tạo ca làm việc** đầu tiên trong Cài đặt → Quản lý ca
3. **Chọn ca làm việc** hiện tại
4. **Bắt đầu sử dụng** nút đa năng để chấm công

### Quy Trình Chấm Công

1. **Đi Làm**: Bấm khi chuẩn bị đi làm (xác định vị trí nhà)
2. **Chấm Công Vào**: Bấm khi đến nơi làm việc (xác định vị trí công ty)
3. **Ký Công**: Bấm nếu ca yêu cầu (tùy chọn)
4. **Chấm Công Ra**: Bấm khi kết thúc giờ làm
5. **Hoàn Tất**: Bấm khi hoàn thành ca làm việc

### Quản Lý Ghi Chú

- Tạo ghi chú với tiêu đề và nội dung
- Đặt mức độ ưu tiên (⭐)
- Thiết lập nhắc nhở theo thời gian cụ thể
- Liên kết với ca làm việc

## 🔧 Công Nghệ Sử Dụng

- **Flutter**: Framework chính
- **Provider**: State management
- **SharedPreferences**: Lưu trữ cục bộ
- **Geolocator**: Dịch vụ vị trí
- **Flutter Local Notifications**: Thông báo và báo thức
- **HTTP**: API calls
- **Intl**: Xử lý thời gian và ngôn ngữ

## 🤝 Đóng Góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 📞 Hỗ Trợ

Nếu bạn gặp vấn đề hoặc có câu hỏi:

- Tạo issue trên GitHub
- Email: support@workly.app
- Telegram: @workly_support

## 🔮 Roadmap

### Phiên Bản Hiện Tại (v1.0.0)
- ✅ Quản lý ca làm việc
- ✅ Chấm công và tính toán
- ✅ Nhắc nhở thông minh
- ✅ Thời tiết và xoay ca

### Phiên Bản Tiếp Theo (v1.1.0)
- 📋 Thống kê và báo cáo chi tiết
- 📊 Export Excel/PDF
- 🏠 Widget màn hình chính
- 📅 Tích hợp lịch hệ thống

### Tính Năng Nâng Cao (v2.0.0)
- ☁️ Đồng bộ đám mây
- 🏢 Tích hợp HR systems
- 🤖 Machine Learning dự đoán
- 🌍 Multi-language support

---

**Workly Flutter - Quản lý ca làm việc thông minh, đơn giản và hiệu quả! 🚀**

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=your-username/workly-flutter&type=Date)](https://star-history.com/#your-username/workly-flutter&Date)

## 📸 Screenshots

| Home Screen | Settings | Weather Widget |
|-------------|----------|----------------|
| ![Home](screenshots/home.png) | ![Settings](screenshots/settings.png) | ![Weather](screenshots/weather.png) |

---

Made with ❤️ by [Your Name](https://github.com/your-username)
# WorklyFL
