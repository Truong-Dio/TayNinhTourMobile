// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTourBookingDetailResponse _$UserTourBookingDetailResponseFromJson(
        Map<String, dynamic> json) =>
    UserTourBookingDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserTourBookingModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserTourBookingDetailResponseToJson(
        UserTourBookingDetailResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

TourTimelineResponse _$TourTimelineResponseFromJson(
        Map<String, dynamic> json) =>
    TourTimelineResponse(
      data: TourTimelineData.fromJson(json['data'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String,
      success: json['success'] as bool,
      validationErrors: (json['validationErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      fieldErrors: (json['fieldErrors'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$TourTimelineResponseToJson(
        TourTimelineResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'success': instance.success,
      'validationErrors': instance.validationErrors,
      'fieldErrors': instance.fieldErrors,
    };

TourTimelineData _$TourTimelineDataFromJson(Map<String, dynamic> json) =>
    TourTimelineData(
      tourTemplateId: json['tourTemplateId'] as String,
      tourTemplateTitle: json['tourTemplateTitle'] as String,
      duration: (json['duration'] as num).toInt(),
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => TourTimelineItemData.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      totalDuration: (json['totalDuration'] as num).toInt(),
      totalStops: (json['totalStops'] as num).toInt(),
      earliestTime: json['earliestTime'] as String,
      latestTime: json['latestTime'] as String,
      shopsCount: (json['shopsCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TourTimelineDataToJson(TourTimelineData instance) =>
    <String, dynamic>{
      'tourTemplateId': instance.tourTemplateId,
      'tourTemplateTitle': instance.tourTemplateTitle,
      'duration': instance.duration,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'items': instance.items,
      'totalItems': instance.totalItems,
      'totalDuration': instance.totalDuration,
      'totalStops': instance.totalStops,
      'earliestTime': instance.earliestTime,
      'latestTime': instance.latestTime,
      'shopsCount': instance.shopsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TourTimelineItemData _$TourTimelineItemDataFromJson(
        Map<String, dynamic> json) =>
    TourTimelineItemData(
      id: json['id'] as String,
      tourDetailsId: json['tourDetailsId'] as String,
      checkInTime: json['checkInTime'] as String,
      activity: json['activity'] as String,
      specialtyShopId: json['specialtyShopId'] as String?,
      sortOrder: (json['sortOrder'] as num).toInt(),
      specialtyShop: json['specialtyShop'] == null
          ? null
          : SpecialtyShopData.fromJson(
              json['specialtyShop'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TourTimelineItemDataToJson(
        TourTimelineItemData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourDetailsId': instance.tourDetailsId,
      'checkInTime': instance.checkInTime,
      'activity': instance.activity,
      'specialtyShopId': instance.specialtyShopId,
      'sortOrder': instance.sortOrder,
      'specialtyShop': instance.specialtyShop,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SpecialtyShopData _$SpecialtyShopDataFromJson(Map<String, dynamic> json) =>
    SpecialtyShopData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$SpecialtyShopDataToJson(SpecialtyShopData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
    };

UserIncidentReportRequest _$UserIncidentReportRequestFromJson(
        Map<String, dynamic> json) =>
    UserIncidentReportRequest(
      tourOperationId: json['tourOperationId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$UserIncidentReportRequestToJson(
        UserIncidentReportRequest instance) =>
    <String, dynamic>{
      'tourOperationId': instance.tourOperationId,
      'title': instance.title,
      'description': instance.description,
      'severity': instance.severity,
      'imageUrls': instance.imageUrls,
      'location': instance.location,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _UserApiService implements UserApiService {
  _UserApiService(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  }) {
    baseUrl ??= 'https://card-diversevercel.io.vn/api';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<UserBookingsResponse> getMyBookings({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'pageIndex': pageIndex,
      r'pageSize': pageSize,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<UserBookingsResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/UserTourBooking/my-bookings',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UserBookingsResponse _value;
    try {
      _value = UserBookingsResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<UserTourBookingDetailResponse> getBookingDetails(
      String bookingId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<UserTourBookingDetailResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/UserTourBooking/booking-details/${bookingId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UserTourBookingDetailResponse _value;
    try {
      _value = UserTourBookingDetailResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<TourTimelineResponse> getTourTimeline(
    String tourDetailsId, {
    bool includeInactive = false,
    bool includeShopInfo = true,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'includeInactive': includeInactive,
      r'includeShopInfo': includeShopInfo,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<TourTimelineResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourDetails/${tourDetailsId}/timeline',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TourTimelineResponse _value;
    try {
      _value = TourTimelineResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CreateTourFeedbackResponse> submitTourFeedback(
      CreateTourFeedbackRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<CreateTourFeedbackResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourBooking/Feedback-Tour',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CreateTourFeedbackResponse _value;
    try {
      _value = CreateTourFeedbackResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<TourFeedbackResponse> getFeedbackBySlot(
    String slotId, {
    int pageIndex = 1,
    int pageSize = 10,
    int? minTourRating,
    int? maxTourRating,
    bool? onlyWithGuideRating,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'pageIndex': pageIndex,
      r'pageSize': pageSize,
      r'minTourRating': minTourRating,
      r'maxTourRating': maxTourRating,
      r'onlyWithGuideRating': onlyWithGuideRating,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<TourFeedbackResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourBooking/Feedback-by-slot/${slotId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late TourFeedbackResponse _value;
    try {
      _value = TourFeedbackResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/UserTourBooking/cancel-booking/${bookingId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<ResendQRTicketResultModel> resendQRTicket(String bookingId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResendQRTicketResultModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/UserTourBooking/resend-qr-ticket/${bookingId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResendQRTicketResultModel _value;
    try {
      _value = ResendQRTicketResultModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<UserDashboardResponse> getDashboardSummary() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<UserDashboardResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/UserTourBooking/dashboard-summary',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UserDashboardResponse _value;
    try {
      _value = UserDashboardResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<MyFeedbacksResponse> getMyFeedbacks({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'pageIndex': pageIndex,
      r'pageSize': pageSize,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<MyFeedbacksResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourBooking/my-feedbacks',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late MyFeedbacksResponse _value;
    try {
      _value = MyFeedbacksResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<void> updateFeedback(
    String feedbackId,
    UpdateTourFeedbackRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<void>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourBooking/feedback/${feedbackId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> deleteFeedback(String feedbackId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<void>(Options(
      method: 'DELETE',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourBooking/feedback/${feedbackId}',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> reportIncident(UserIncidentReportRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<void>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/TourGuide/incident/report',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<dynamic> getUserTourSlotTimelineRaw(String tourSlotId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'No-Auth': 'true'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<dynamic>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/UserTourBooking/tour-slot/${tourSlotId}/timeline',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    return _value;
  }

  @override
  Future<bool> createSupportTicket({
    required String title,
    required String content,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry(
      'Title',
      title,
    ));
    _data.fields.add(MapEntry(
      'Content',
      content,
    ));
    final _options = _setStreamType<bool>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
      contentType: 'multipart/form-data',
    )
        .compose(
          _dio.options,
          '/SupportTickets',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<bool>(_options);
    late bool _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
