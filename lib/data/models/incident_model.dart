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
