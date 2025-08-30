class TourInvitation {
  final String id;
  final String status;
  final DateTime invitedAt;
  final DateTime? respondedAt;
  final bool canAccept;
  final bool canReject;
  final String? tourTitle;
  final String? tourDescription;

  const TourInvitation({
    required this.id,
    required this.status,
    required this.invitedAt,
    this.respondedAt,
    required this.canAccept,
    required this.canReject,
    this.tourTitle,
    this.tourDescription,
  });

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ phản hồi';
      case 'accepted':
        return 'Đã chấp nhận';
      case 'rejected':
        return 'Đã từ chối';
      case 'expired':
        return 'Đã hết hạn';
      default:
        return status;
    }
  }
}



class InvitationStatistics {
  final int totalInvitations;
  final int pendingCount;
  final int acceptedCount;
  final int rejectedCount;

  const InvitationStatistics({
    required this.totalInvitations,
    required this.pendingCount,
    required this.acceptedCount,
    required this.rejectedCount,
  });

  double get acceptanceRate {
    if (totalInvitations == 0) return 0.0;
    return (acceptedCount / totalInvitations) * 100;
  }
}
