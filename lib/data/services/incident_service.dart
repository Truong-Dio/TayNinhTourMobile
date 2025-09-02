import 'package:dio/dio.dart';
import '../models/base_response_dto.dart';
import '../models/incident_model.dart';
import 'api_service.dart';

/// Service for handling incident-related API calls
class IncidentService {
  final ApiService _apiService;

  IncidentService(this._apiService);

  /// Get incidents for a specific tour slot
  /// 
  /// [tourSlotId] - The ID of the tour slot
  /// [pageIndex] - Page index for pagination (default: 0)
  /// [pageSize] - Number of items per page (default: 10)
  /// 
  /// Returns a [BaseResponseDto] containing [IncidentsResponse]
  Future<BaseResponseDto<IncidentsResponse>> getTourSlotIncidents({
    required String tourSlotId,
    int pageIndex = 0,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/UserTourBooking/tour-slot/$tourSlotId/incidents',
        queryParameters: {
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
      );

      return BaseResponseDto<IncidentsResponse>.fromJson(
        response.data,
        (json) => IncidentsResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return BaseResponseDto<IncidentsResponse>(
          statusCode: 403,
          message: 'Bạn không có quyền xem thông tin sự cố của tour này',
          success: false,
          data: null,
        );
      } else if (e.response?.statusCode == 404) {
        // 404 có nghĩa là không có sự cố nào - trả về thành công với danh sách rỗng
        return BaseResponseDto<IncidentsResponse>(
          statusCode: 200,
          message: 'Không có sự cố nào được báo cáo',
          success: true,
          data: IncidentsResponse(
            incidents: [],
            totalCount: 0,
            pageIndex: 0,
            pageSize: pageSize,
            totalPages: 0,
          ),
        );
      } else if (e.response?.statusCode == 401) {
        return BaseResponseDto<IncidentsResponse>(
          statusCode: 401,
          message: 'Vui lòng đăng nhập để xem thông tin sự cố',
          success: false,
          data: null,
        );
      }

      // Handle other errors
      String errorMessage = 'Có lỗi xảy ra khi tải danh sách sự cố';
      
      if (e.response?.data != null && e.response!.data is Map) {
        final errorData = e.response!.data as Map<String, dynamic>;
        if (errorData.containsKey('Message') && errorData['Message'] != null) {
          errorMessage = errorData['Message'].toString();
        }
      }

      return BaseResponseDto<IncidentsResponse>(
        statusCode: e.response?.statusCode ?? 500,
        message: errorMessage,
        success: false,
        data: null,
      );
    } catch (e) {
      return BaseResponseDto<IncidentsResponse>(
        statusCode: 500,
        message: 'Có lỗi không xác định xảy ra: ${e.toString()}',
        success: false,
        data: null,
      );
    }
  }

  /// Get incidents for a tour slot with automatic retry on failure
  /// 
  /// [tourSlotId] - The ID of the tour slot
  /// [pageIndex] - Page index for pagination (default: 0)
  /// [pageSize] - Number of items per page (default: 10)
  /// [retryCount] - Number of retry attempts (default: 2)
  /// 
  /// Returns a [BaseResponseDto] containing [IncidentsResponse]
  Future<BaseResponseDto<IncidentsResponse>> getTourSlotIncidentsWithRetry({
    required String tourSlotId,
    int pageIndex = 0,
    int pageSize = 10,
    int retryCount = 2,
  }) async {
    BaseResponseDto<IncidentsResponse> response;
    int attempts = 0;

    do {
      response = await getTourSlotIncidents(
        tourSlotId: tourSlotId,
        pageIndex: pageIndex,
        pageSize: pageSize,
      );

      attempts++;

      // If successful or client error (4xx), don't retry
      if (response.success || (response.statusCode >= 400 && response.statusCode < 500)) {
        break;
      }

      // Wait before retry (exponential backoff)
      if (attempts <= retryCount) {
        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    } while (attempts <= retryCount);

    return response;
  }

  /// Check if user has access to view incidents for a tour slot
  /// This is a lightweight check that can be used before showing incident UI
  ///
  /// [tourSlotId] - The ID of the tour slot
  ///
  /// Returns true if user has access AND there are incidents, false otherwise
  Future<bool> canViewIncidents(String tourSlotId) async {
    try {
      final response = await getTourSlotIncidents(
        tourSlotId: tourSlotId,
        pageIndex: 0,
        pageSize: 1, // Minimal request
      );

      // Chỉ trả về true nếu có quyền truy cập VÀ có ít nhất 1 sự cố
      return response.success &&
             response.data != null &&
             response.data!.incidents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get incident statistics for a tour slot
  /// Returns basic stats like total count, unresolved count, etc.
  /// 
  /// [tourSlotId] - The ID of the tour slot
  /// 
  /// Returns a map with incident statistics
  Future<Map<String, int>> getIncidentStats(String tourSlotId) async {
    try {
      final response = await getTourSlotIncidents(
        tourSlotId: tourSlotId,
        pageIndex: 0,
        pageSize: 100, // Get more incidents for stats
      );

      if (!response.success || response.data == null) {
        return {
          'total': 0,
          'unresolved': 0,
          'critical': 0,
          'resolved': 0,
        };
      }

      final incidents = response.data!.incidents;
      final total = incidents.length;
      final unresolved = incidents.where((i) => !i.isResolved).length;
      final critical = incidents.where((i) => i.isCritical).length;
      final resolved = incidents.where((i) => i.isResolved).length;

      return {
        'total': total,
        'unresolved': unresolved,
        'critical': critical,
        'resolved': resolved,
      };
    } catch (e) {
      return {
        'total': 0,
        'unresolved': 0,
        'critical': 0,
        'resolved': 0,
      };
    }
  }
}
