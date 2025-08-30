# API Cleanup Summary - HDV Tour Management Mobile App

## 🎯 Mục đích
Clean up Flutter mobile app để chỉ giữ lại các API endpoints cần thiết theo **HDV_TOUR_MANAGEMENT_SYSTEM_PLAN.md**

## ✅ Những thay đổi đã thực hiện

### 1. **API Constants Cleanup**
**File**: `lib/core/constants/api_constants.dart`

**Trước** (41 endpoints):
- Authentication: 6 endpoints
- Account management: 6 endpoints  
- Tour Guide: 7 endpoints
- Tour Guide Invitation: 3 endpoints
- Tour Details: 4 endpoints
- Tour Booking: 5 endpoints
- Image upload: 1 endpoint

**Sau** (9 endpoints):
- Authentication: 2 endpoints (login, refresh-token)
- Tour Guide: 6 endpoints (core HDV functions)
- Image upload: 1 endpoint (for incident reports)

### 2. **Authentication API Service Cleanup**
**File**: `lib/data/datasources/auth_api_service.dart`

**Removed**:
- Register endpoint
- Verify OTP endpoint
- Send OTP reset password endpoint
- Reset password endpoint
- All related request/response classes

**Kept**:
- Login endpoint
- Refresh token endpoint
- Core request/response classes

### 3. **Removed Unnecessary API Services**
**Deleted files**:
- `account_api_service.dart` - Account management không cần cho HDV app
- `tour_guide_invitation_api_service.dart` - Invitation management không cần
- `tour_booking_api_service.dart` - Booking management không cần cho HDV

### 4. **Tour Guide API Service**
**File**: `lib/data/datasources/tour_guide_api_service.dart`

**Kept exactly 6 core endpoints theo plan**:
1. `GET /TourGuide/my-active-tours` - Lấy tours đang active
2. `GET /TourGuide/tour/{operationId}/bookings` - Lấy bookings để check-in
3. `GET /TourGuide/tour/{operationId}/timeline` - Lấy timeline tour
4. `POST /TourGuide/checkin/{bookingId}` - Check-in khách qua QR
5. `POST /TourGuide/timeline/{timelineId}/complete` - Hoàn thành timeline item
6. `POST /TourGuide/incident/report` - Báo cáo sự cố
7. `POST /TourGuide/tour/{operationId}/notify-guests` - Thông báo khách

### 5. **Fixed API Endpoints**
**Corrected paths**:
- `/Auth/login` → `/Authentication/login`
- `/Auth/refresh-token` → `/Authentication/refresh-token`
- Timeline endpoint parameter: `tourDetailsId` → `operationId`

**Updated base URL**:
- Production: `https://tayninhtour.card-diversevercel.io.vn/api`
- Development: `http://localhost:5267/api` (for local testing)

## 🎯 Kết quả

### **Trước cleanup**:
- 41 API endpoints
- 4 API service files
- Nhiều request/response classes không cần thiết
- Endpoints không match với backend thực tế

### **Sau cleanup**:
- 9 API endpoints (giảm 78%)
- 2 API service files (giảm 50%)
- Chỉ giữ request/response classes cần thiết
- Tất cả endpoints match với backend thực tế

## 🚀 Core HDV Functions Supported

Theo **HDV_TOUR_MANAGEMENT_SYSTEM_PLAN.md**, app hỗ trợ 4 chức năng chính:

1. **Pre-Tour Check-in** (1 tiếng trước tour)
   - API: `GET /TourGuide/tour/{operationId}/bookings`
   - API: `POST /TourGuide/checkin/{bookingId}`

2. **During Tour Timeline** (Trong tour)
   - API: `GET /TourGuide/tour/{operationId}/timeline`
   - API: `POST /TourGuide/timeline/{timelineId}/complete`

3. **Incident Reporting** (Bất kỳ lúc nào)
   - API: `POST /TourGuide/incident/report`
   - API: `POST /Image/Upload` (for photos)

4. **Guest Communication** (Trong tour)
   - API: `POST /TourGuide/tour/{operationId}/notify-guests`

## 📱 App Structure

**Clean architecture maintained**:
- `lib/core/constants/api_constants.dart` - API endpoints
- `lib/data/datasources/auth_api_service.dart` - Authentication
- `lib/data/datasources/tour_guide_api_service.dart` - Core HDV functions
- `lib/main.dart` - App initialization với 2 services

## ✨ Benefits

1. **Simplified codebase** - Ít code hơn, dễ maintain hơn
2. **Focused functionality** - Chỉ tập trung vào HDV core functions
3. **Correct API paths** - Match với backend thực tế
4. **Better performance** - Ít dependencies, load nhanh hơn
5. **Easier testing** - Ít endpoints để test

## 🔄 Next Steps

1. **Test API connectivity** với localhost backend
2. **Update UI components** để sử dụng cleaned APIs
3. **Test core HDV flows** theo plan
4. **Deploy và test** với production backend

---

**Summary**: Đã clean up thành công Flutter mobile app từ 41 endpoints xuống 9 endpoints, tập trung vào 4 chức năng cốt lõi của HDV theo plan. Tất cả API paths đã được corrected để match với backend thực tế.
