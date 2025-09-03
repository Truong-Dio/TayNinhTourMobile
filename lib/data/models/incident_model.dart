/// Model for tour incident data
class TourIncident {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String severityDisplay;
  final String status;
  final String statusDisplay;
  final DateTime reportedAt;
  final DateTime incidentDate;
  final String? adminNotes;
  final DateTime? processedAt;
  final DateTime? resolvedAt;
  final String reporterName;
  final String? tourName;
  final bool hasImages;

  const TourIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.severityDisplay,
    required this.status,
    required this.statusDisplay,
    required this.reportedAt,
    required this.incidentDate,
    this.adminNotes,
    this.processedAt,
    this.resolvedAt,
    required this.reporterName,
    this.tourName,
    required this.hasImages,
  });

  factory TourIncident.fromJson(Map<String, dynamic> json) {
    return TourIncident(
      id: json['Id'] as String? ?? '',
      title: json['Title'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      severity: json['Severity'] as String? ?? '',
      severityDisplay: json['SeverityDisplay'] as String? ?? '',
      status: json['Status'] as String? ?? '',
      statusDisplay: json['StatusDisplay'] as String? ?? '',
      reportedAt: DateTime.tryParse(json['ReportedAt'] as String? ?? '') ?? DateTime.now(),
      incidentDate: DateTime.tryParse(json['IncidentDate'] as String? ?? '') ?? DateTime.now(),
      adminNotes: json['AdminNotes'] as String?,
      processedAt: json['ProcessedAt'] != null ? DateTime.tryParse(json['ProcessedAt'] as String) : null,
      resolvedAt: json['ResolvedAt'] != null ? DateTime.tryParse(json['ResolvedAt'] as String) : null,
      reporterName: json['ReporterName'] as String? ?? '',
      tourName: json['TourName'] as String?,
      hasImages: json['HasImages'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Description': description,
      'Severity': severity,
      'SeverityDisplay': severityDisplay,
      'Status': status,
      'StatusDisplay': statusDisplay,
      'ReportedAt': reportedAt.toIso8601String(),
      'IncidentDate': incidentDate.toIso8601String(),
      'AdminNotes': adminNotes,
      'ProcessedAt': processedAt?.toIso8601String(),
      'ResolvedAt': resolvedAt?.toIso8601String(),
      'ReporterName': reporterName,
      'TourName': tourName,
      'HasImages': hasImages,
    };
  }

  /// Get severity color based on severity level
  String get severityColor {
    switch (severity.toLowerCase()) {
      case 'low':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'high':
        return '#F44336'; // Red
      case 'critical':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  /// Get status color based on status
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'reported':
        return '#2196F3'; // Blue
      case 'inprogress':
        return '#FF9800'; // Orange
      case 'resolved':
        return '#4CAF50'; // Green
      case 'closed':
        return '#757575'; // Grey
      default:
        return '#757575'; // Grey
    }
  }

  /// Check if incident is resolved
  bool get isResolved => status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed';

  /// Check if incident is in progress
  bool get isInProgress => status.toLowerCase() == 'inprogress';

  /// Check if incident is critical
  bool get isCritical => severity.toLowerCase() == 'critical';

  /// Get formatted reported date
  String get formattedReportedDate {
    return '${reportedAt.day.toString().padLeft(2, '0')}/${reportedAt.month.toString().padLeft(2, '0')}/${reportedAt.year} ${reportedAt.hour.toString().padLeft(2, '0')}:${reportedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted incident date
  String get formattedIncidentDate {
    return '${incidentDate.day.toString().padLeft(2, '0')}/${incidentDate.month.toString().padLeft(2, '0')}/${incidentDate.year}';
  }
}

/// Response model for incidents list
class IncidentsResponse {
  final List<TourIncident> incidents;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final int totalPages;

  const IncidentsResponse({
    required this.incidents,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
    required this.totalPages,
  });

  factory IncidentsResponse.fromJson(Map<String, dynamic> json) {
    return IncidentsResponse(
      incidents: (json['Incidents'] as List<dynamic>?)
          ?.map((e) => TourIncident.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalCount: json['TotalCount'] as int? ?? 0,
      pageIndex: json['PageIndex'] as int? ?? 0,
      pageSize: json['PageSize'] as int? ?? 0,
      totalPages: json['TotalPages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Incidents': incidents.map((e) => e.toJson()).toList(),
      'TotalCount': totalCount,
      'PageIndex': pageIndex,
      'PageSize': pageSize,
      'TotalPages': totalPages,
    };
  }

  /// Check if there are more pages
  bool get hasMorePages => pageIndex < totalPages - 1;

  /// Check if this is the first page
  bool get isFirstPage => pageIndex == 0;

  /// Check if this is the last page
  bool get isLastPage => pageIndex >= totalPages - 1;
}

/// Request model for reporting an incident (TourGuide)
class ReportIncidentRequest {
  final String tourSlotId;
  final String title;
  final String description;
  final String severity;
  final List<String>? imageUrls;

  const ReportIncidentRequest({
    required this.tourSlotId,
    required this.title,
    required this.description,
    required this.severity,
    this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'tourSlotId': tourSlotId,
      'title': title,
      'description': description,
      'severity': severity,
      'imageUrls': imageUrls,
    };
  }

  factory ReportIncidentRequest.fromJson(Map<String, dynamic> json) {
    return ReportIncidentRequest(
      tourSlotId: json['tourSlotId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

/// Response model for reporting an incident
class ReportIncidentResponse {
  final String id;
  final String title;
  final String severity;
  final String status;
  final DateTime reportedAt;

  const ReportIncidentResponse({
    required this.id,
    required this.title,
    required this.severity,
    required this.status,
    required this.reportedAt,
  });

  factory ReportIncidentResponse.fromJson(Map<String, dynamic> json) {
    return ReportIncidentResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'severity': severity,
      'status': status,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }
}

/// Enhanced incident model for TourGuide with additional fields
class TourGuideIncident extends TourIncident {
  final String? tourOperationId;
  final String? tourSlotId;
  final List<String>? imageUrls;
  final String? tourDate;
  final String reportedByGuideId;

  const TourGuideIncident({
    required super.id,
    required super.title,
    required super.description,
    required super.severity,
    required super.severityDisplay,
    required super.status,
    required super.statusDisplay,
    required super.reportedAt,
    required super.incidentDate,
    super.adminNotes,
    super.processedAt,
    super.resolvedAt,
    required super.reporterName,
    super.tourName,
    required super.hasImages,
    this.tourOperationId,
    this.tourSlotId,
    this.imageUrls,
    this.tourDate,
    required this.reportedByGuideId,
  });

  factory TourGuideIncident.fromJson(Map<String, dynamic> json) {
    return TourGuideIncident(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? '',
      severityDisplay: json['severityDisplay'] as String? ?? json['severity'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusDisplay: json['statusDisplay'] as String? ?? json['status'] as String? ?? '',
      reportedAt: DateTime.tryParse(json['reportedAt'] as String? ?? '') ?? DateTime.now(),
      incidentDate: DateTime.tryParse(json['incidentDate'] as String? ?? json['reportedAt'] as String? ?? '') ?? DateTime.now(),
      adminNotes: json['adminNotes'] as String?,
      processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt'] as String) : null,
      resolvedAt: json['resolvedAt'] != null ? DateTime.tryParse(json['resolvedAt'] as String) : null,
      reporterName: json['reporterName'] as String? ?? '',
      tourName: json['tourName'] as String?,
      hasImages: json['hasImages'] as bool? ?? (json['imageUrls'] as List?)?.isNotEmpty == true,
      tourOperationId: json['tourOperationId'] as String?,
      tourSlotId: json['tourSlotId'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tourDate: json['tourDate'] as String?,
      reportedByGuideId: json['reportedByGuideId'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'tourOperationId': tourOperationId,
      'tourSlotId': tourSlotId,
      'imageUrls': imageUrls,
      'tourDate': tourDate,
      'reportedByGuideId': reportedByGuideId,
    });
    return json;
  }
}

/// Response model for TourGuide incidents list
class TourGuideIncidentsResponse {
  final List<TourGuideIncident> incidents;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final int totalPages;

  const TourGuideIncidentsResponse({
    required this.incidents,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
    required this.totalPages,
  });

  factory TourGuideIncidentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return TourGuideIncidentsResponse(
      incidents: (data['incidents'] as List<dynamic>?)
          ?.map((e) => TourGuideIncident.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalCount: data['totalCount'] as int? ?? 0,
      pageIndex: data['pageIndex'] as int? ?? data['currentPage'] as int? ?? 0,
      pageSize: data['pageSize'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incidents': incidents.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'pageIndex': pageIndex,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }

  /// Check if there are more pages
  bool get hasMorePages => pageIndex < totalPages - 1;

  /// Check if this is the first page
  bool get isFirstPage => pageIndex == 0;

  /// Check if this is the last page
  bool get isLastPage => pageIndex >= totalPages - 1;
}
