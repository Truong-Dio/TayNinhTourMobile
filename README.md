# TayNinh Tour HDV Mobile App

Ứng dụng mobile quản lý tour cho Hướng dẫn viên (HDV) của TayNinh Travel.

## 🎯 Tính năng chính

### 1. **Pre-Tour Check-in**
- Quét QR code để check-in khách hàng
- Danh sách khách hàng với tìm kiếm và lọc
- Thống kê tiến độ check-in real-time
- Check-in thủ công khi cần thiết

### 2. **Timeline Progress Tracking**
- Theo dõi lịch trình tour theo thời gian thực
- Hoàn thành từng mục lịch trình theo thứ tự
- Tự động gửi thông báo cho khách khi hoàn thành mục
- Hiển thị thông tin địa điểm và cửa hàng đặc sản

### 3. **Incident Reporting**
- Báo cáo sự cố với nhiều mức độ nghiêm trọng
- Upload hình ảnh minh họa
- Tự động thông báo cho quản lý
- Form báo cáo chi tiết và dễ sử dụng

### 4. **Guest Communication**
- Gửi thông báo cho tất cả khách trong tour
- Mẫu thông báo có sẵn
- Thông báo khẩn cấp với ưu tiên cao
- Giao diện thân thiện và nhanh chóng

## 🏗️ Kiến trúc ứng dụng

### **Clean Architecture**
```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── errors/             # Error handling
│   ├── network/            # Network layer
│   ├── theme/              # App theming
│   └── utils/              # Utilities
├── data/                   # Data layer
│   ├── datasources/        # API services
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic
│   ├── entities/           # Domain entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business use cases
└── presentation/           # UI layer
    ├── pages/              # App screens
    ├── widgets/            # Reusable widgets
    └── providers/          # State management
```

### **State Management**
- **Provider**: Quản lý state đơn giản và hiệu quả
- **AuthProvider**: Xử lý authentication và user session
- **TourGuideProvider**: Quản lý dữ liệu tour và operations

### **Network Layer**
- **Dio**: HTTP client với interceptors
- **Retrofit**: Type-safe API calls
- **JWT Authentication**: Tự động thêm token vào requests
- **Error Handling**: Xử lý lỗi network và server

## 🚀 Setup và Installation

### **Prerequisites**
- Flutter SDK >= 3.8.1
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Android device/emulator hoặc iOS device/simulator

### **Installation Steps**

1. **Install dependencies**
```bash
flutter pub get
```

2. **Generate code**
```bash
flutter packages pub run build_runner build
```

3. **API Configuration**
App đã được cấu hình để sử dụng production server:
```dart
static const String baseUrl = 'https://tayninhtour.card-diversevercel.io.vn/api';
```

**Test Credentials:**
- Email: `tourguide@example.com`
- Password: `password123`
- Role: Tour Guide

4. **Run app**
```bash
flutter run
```

## 🧪 Testing với Production Server

### **Server Information**
- **Base URL**: `https://tayninhtour.card-diversevercel.io.vn/api`
- **Environment**: Production
- **HTTPS**: Enabled
- **CORS**: Configured for mobile access

### **Test Account**
Sử dụng tài khoản test sau để đăng nhập:
```
Email: tourguide@example.com
Password: password123
Role: Tour Guide
```

### **API Endpoints Available**
- `POST /Auth/login` - Authentication
- `GET /TourGuide/my-active-tours` - Get active tours
- `GET /TourGuide/tour/{operationId}/bookings` - Get tour bookings
- `GET /TourGuide/tour/{tourDetailsId}/timeline` - Get tour timeline
- `POST /TourGuide/checkin/{bookingId}` - Check-in guest
- `POST /TourGuide/timeline/{timelineId}/complete` - Complete timeline item
- `POST /TourGuide/incident/report` - Report incident
- `POST /TourGuide/tour/{operationId}/notify-guests` - Notify guests

### **Network Requirements**
- **Internet connection** required
- **HTTPS support** enabled
- **Certificate validation** enabled
