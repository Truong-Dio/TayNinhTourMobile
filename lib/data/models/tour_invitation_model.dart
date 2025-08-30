import 'package:json_annotation/json_annotation.dart';

part 'tour_invitation_model.g.dart';

@JsonSerializable()
class TourInvitationModel {
  final String id;
  final String? status;
  final String invitedAt;
  final String? respondedAt;
  final bool? canAccept;
  final bool? canReject;
  final TourDetailsBasicModel? tourDetails;

  const TourInvitationModel({
    required this.id,
    this.status,
    required this.invitedAt,
    this.respondedAt,
    this.canAccept,
    this.canReject,
    this.tourDetails,
  });

  factory TourInvitationModel.fromJson(Map<String, dynamic> json) =>
      _$TourInvitationModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourInvitationModelToJson(this);

}

@JsonSerializable()
class TourDetailsBasicModel {
  final String id;
  final String? title;
  final String? description;

  const TourDetailsBasicModel({
    required this.id,
    this.title,
    this.description,
  });

  factory TourDetailsBasicModel.fromJson(Map<String, dynamic> json) =>
      _$TourDetailsBasicModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourDetailsBasicModelToJson(this);
}





@JsonSerializable()
class InvitationStatisticsModel {
  final int totalInvitations;
  final int pendingCount;
  final int acceptedCount;
  final int rejectedCount;

  const InvitationStatisticsModel({
    required this.totalInvitations,
    required this.pendingCount,
    required this.acceptedCount,
    required this.rejectedCount,
  });

  factory InvitationStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationStatisticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationStatisticsModelToJson(this);
}

@JsonSerializable()
class MyInvitationsResponseModel {
  final bool? success;
  final bool? isSuccess;
  final List<TourInvitationModel>? invitations;
  final InvitationStatisticsModel? statistics;

  const MyInvitationsResponseModel({
    this.success,
    this.isSuccess,
    this.invitations,
    this.statistics,
  });

  factory MyInvitationsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyInvitationsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyInvitationsResponseModelToJson(this);
}
