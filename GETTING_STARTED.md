# Hướng Dẫn Bắt Đầu - Workly Flutter

Tài liệu này sẽ hướng dẫn bạn cách thiết lập và chạy ứng dụng Workly Flutter từ đầu.

## 📋 Yêu Cầu Hệ Thống

### Phần Mềm Cần Thiết
- **Flutter SDK**: 3.0.0 trở lên
- **Dart SDK**: 3.0.0 trở lên
- **Android Studio**: 2022.1 trở lên (cho Android)
- **Xcode**: 14.0 trở lên (cho iOS, chỉ trên macOS)
- **VS Code**: Tùy chọn, với Flutter extension

### Hệ Điều Hành Hỗ Trợ
- **Windows**: 10 trở lên
- **macOS**: 10.14 trở lên
- **Linux**: Ubuntu 18.04 trở lên

## 🛠️ Cài Đặt Flutter

### Windows

1. **Tải Flutter SDK**
   ```bash
   # Tải từ https://flutter.dev/docs/get-started/install/windows
   # Giải nén vào C:\flutter
   ```

2. **Cập nhật PATH**
   ```bash
   # Thêm C:\flutter\bin vào PATH environment variable
   ```

3. **Kiểm tra cài đặt**
   ```bash
   flutter doctor
   ```

### macOS

1. **Cài đặt qua Homebrew**
   ```bash
   brew install flutter
   ```

2. **Hoặc tải thủ công**
   ```bash
   # Tải từ https://flutter.dev/docs/get-started/install/macos
   # Giải nén và thêm vào PATH
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

### Linux

1. **Tải và cài đặt**
   ```bash
   # Tải từ https://flutter.dev/docs/get-started/install/linux
   tar xf flutter_linux_*.tar.xz
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

## 📱 Thiết Lập Môi Trường Phát Triển

### Android Development

1. **Cài đặt Android Studio**
   - Tải từ [developer.android.com](https://developer.android.com/studio)
   - Cài đặt Android SDK và Android SDK Command-line Tools

2. **Cấu hình Android SDK**
   ```bash
   flutter config --android-sdk /path/to/android/sdk
   ```

3. **Tạo Android Virtual Device (AVD)**
   - Mở Android Studio → AVD Manager
   - Tạo virtual device với API level 21+

### iOS Development (chỉ trên macOS)

1. **Cài đặt Xcode**
   ```bash
   # Từ Mac App Store hoặc developer.apple.com
   ```

2. **Cài đặt iOS Simulator**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. **Cài đặt CocoaPods**
   ```bash
   sudo gem install cocoapods
   ```

## 🚀 Chạy Dự Án

### 1. Clone Repository

```bash
git clone https://github.com/your-username/workly-flutter.git
cd workly-flutter
```

### 2. Cài Đặt Dependencies

```bash
flutter pub get
```

### 3. Kiểm Tra Thiết Bị

```bash
# Xem danh sách thiết bị có sẵn
flutter devices

# Kết quả mẫu:
# Android SDK built for x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30)
# iPhone 14 Pro Max (mobile) • 12345678-1234-1234-1234-123456789012 • ios • com.apple.CoreSimulator.SimRuntime.iOS-16-0
```

### 4. Chạy Ứng Dụng

```bash
# Chạy trên thiết bị mặc định
flutter run

# Chạy trên thiết bị cụ thể
flutter run -d emulator-5554

# Chạy ở chế độ debug
flutter run --debug

# Chạy ở chế độ release
flutter run --release
```

## 🔧 Cấu Hình Ứng Dụng

### API Key Thời Tiết (Tùy chọn)

1. **Đăng ký OpenWeatherMap**
   - Truy cập [openweathermap.org](https://openweathermap.org/api)
   - Tạo tài khoản miễn phí
   - Lấy API key

2. **Cấu hình trong ứng dụng**
   - Mở ứng dụng
   - Vào Cài đặt → Thời tiết
   - Nhập API key

### Quyền Ứng Dụng

Ứng dụng cần các quyền sau:

- **Location**: Để xác định vị trí khi chấm công
- **Notifications**: Để gửi nhắc nhở
- **Storage**: Để lưu trữ dữ liệu cục bộ

## 🐛 Xử Lý Sự Cố

### Lỗi Thường Gặp

1. **Flutter doctor issues**
   ```bash
   # Chạy để xem các vấn đề
   flutter doctor -v
   
   # Sửa Android licenses
   flutter doctor --android-licenses
   ```

2. **Gradle build failed**
   ```bash
   # Xóa build cache
   flutter clean
   flutter pub get
   
   # Rebuild
   flutter run
   ```

3. **iOS build issues**
   ```bash
   # Xóa iOS build cache
   rm -rf ios/Pods ios/Podfile.lock
   cd ios && pod install
   cd .. && flutter run
   ```

4. **Dependencies conflicts**
   ```bash
   # Cập nhật dependencies
   flutter pub upgrade
   
   # Hoặc reset về phiên bản cũ
   flutter pub downgrade
   ```

### Debug Mode

```bash
# Chạy với verbose logging
flutter run -v

# Chạy với debug console
flutter run --debug

# Hot reload trong quá trình phát triển
# Nhấn 'r' để reload
# Nhấn 'R' để restart
# Nhấn 'q' để quit
```

## 📊 Performance Tips

### Tối Ưu Hiệu Suất

1. **Build Release**
   ```bash
   # Build APK release
   flutter build apk --release
   
   # Build iOS release
   flutter build ios --release
   ```

2. **Analyze Code**
   ```bash
   # Phân tích code
   flutter analyze
   
   # Format code
   flutter format .
   ```

3. **Profile Performance**
   ```bash
   # Chạy ở chế độ profile
   flutter run --profile
   ```

## 🧪 Testing

### Chạy Tests

```bash
# Chạy tất cả tests
flutter test

# Chạy test cụ thể
flutter test test/widget_test.dart

# Chạy integration tests
flutter drive --target=test_driver/app.dart
```

### Test Coverage

```bash
# Tạo coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📦 Build và Deploy

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (khuyến nghị cho Play Store)
flutter build appbundle --release

# File output:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build iOS
flutter build ios --release

# Archive trong Xcode để upload lên App Store
```

## 🔄 Cập Nhật Dự Án

### Cập Nhật Flutter

```bash
# Cập nhật Flutter SDK
flutter upgrade

# Cập nhật dependencies
flutter pub upgrade
```

### Cập Nhật Code

```bash
# Pull latest changes
git pull origin main

# Cài đặt dependencies mới
flutter pub get

# Clean và rebuild
flutter clean
flutter run
```

## 📞 Hỗ Trợ

Nếu gặp vấn đề:

1. **Kiểm tra Flutter Doctor**
   ```bash
   flutter doctor -v
   ```

2. **Xem logs chi tiết**
   ```bash
   flutter logs
   ```

3. **Tạo issue trên GitHub** với thông tin:
   - Flutter version (`flutter --version`)
   - Hệ điều hành
   - Error logs
   - Các bước tái tạo lỗi

## 🎯 Bước Tiếp Theo

Sau khi chạy thành công ứng dụng:

1. **Khám phá tính năng**: Thử tất cả các tính năng của ứng dụng
2. **Tùy chỉnh**: Điều chỉnh cài đặt theo nhu cầu
3. **Phát triển**: Thêm tính năng mới hoặc tùy chỉnh giao diện
4. **Đóng góp**: Tham gia phát triển dự án

---

**Chúc bạn thành công với Workly Flutter! 🚀**
