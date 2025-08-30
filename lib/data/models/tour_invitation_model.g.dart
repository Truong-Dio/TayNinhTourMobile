// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourInvitationModel _$TourInvitationModelFromJson(Map<String, dynamic> json) =>
    TourInvitationModel(
      id: json['id'] as String,
      status: json['status'] as String?,
      invitedAt: json['invitedAt'] as String,
      respondedAt: json['respondedAt'] as String?,
      canAccept: json['canAccept'] as bool?,
      canReject: json['canReject'] as bool?,
      tourDetails: json['tourDetails'] == null
          ? null
          : TourDetailsBasicModel.fromJson(
              json['tourDetails'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TourInvitationModelToJson(
        TourInvitationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'invitedAt': instance.invitedAt,
      'respondedAt': instance.respondedAt,
      'canAccept': instance.canAccept,
      'canReject': instance.canReject,
      'tourDetails': instance.tourDetails,
    };

TourDetailsBasicModel _$TourDetailsBasicModelFromJson(
        Map<String, dynamic> json) =>
    TourDetailsBasicModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TourDetailsBasicModelToJson(
        TourDetailsBasicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };

InvitationStatisticsModel _$InvitationStatisticsModelFromJson(
        Map<String, dynamic> json) =>
    InvitationStatisticsModel(
      totalInvitations: (json['totalInvitations'] as num).toInt(),
      pendingCount: (json['pendingCount'] as num).toInt(),
      acceptedCount: (json['acceptedCount'] as num).toInt(),
      rejectedCount: (json['rejectedCount'] as num).toInt(),
    );

Map<String, dynamic> _$InvitationStatisticsModelToJson(
        InvitationStatisticsModel instance) =>
    <String, dynamic>{
      'totalInvitations': instance.totalInvitations,
      'pendingCount': instance.pendingCount,
      'acceptedCount': instance.acceptedCount,
      'rejectedCount': instance.rejectedCount,
    };

MyInvitationsResponseModel _$MyInvitationsResponseModelFromJson(
        Map<String, dynamic> json) =>
    MyInvitationsResponseModel(
      success: json['success'] as bool?,
      isSuccess: json['isSuccess'] as bool?,
      invitations: (json['invitations'] as List<dynamic>?)
          ?.map((e) => TourInvitationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      statistics: json['statistics'] == null
          ? null
          : InvitationStatisticsModel.fromJson(
              json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MyInvitationsResponseModelToJson(
        MyInvitationsResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'isSuccess': instance.isSuccess,
      'invitations': instance.invitations,
      'statistics': instance.statistics,
    };
