import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class TourFeedback extends Equatable {
  final String id;
  final String bookingId;
  final String slotId;
  final String userId;
  final int tourRating;
  final String? tourComment;
  final int? guideRating;
  final String? guideComment;
  final String? tourGuideId;
  final String? tourGuideName;
  final DateTime createdAt;

  const TourFeedback({
    required this.id,
    required this.bookingId,
    required this.slotId,
    required this.userId,
    required this.tourRating,
    this.tourComment,
    this.guideRating,
    this.guideComment,
    this.tourGuideId,
    this.tourGuideName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        slotId,
        userId,
        tourRating,
        tourComment,
        guideRating,
        guideComment,
        tourGuideId,
        tourGuideName,
        createdAt,
      ];

  /// Check if tour rating is valid
  bool get isValidTourRating {
    return tourRating >= AppConstants.minRating && 
           tourRating <= AppConstants.maxRating;
  }

  /// Check if guide rating is valid
  bool get isValidGuideRating {
    return guideRating == null || 
           (guideRating! >= AppConstants.minRating && 
            guideRating! <= AppConstants.maxRating);
  }

  /// Check if feedback has guide rating
  bool get hasGuideRating {
    return guideRating != null;
  }

  /// Check if feedback has comments
  bool get hasTourComment {
    return tourComment != null && tourComment!.isNotEmpty;
  }

  bool get hasGuideComment {
    return guideComment != null && guideComment!.isNotEmpty;
  }

  /// Get star display for tour rating
  String get tourRatingStars {
    return '★' * tourRating + '☆' * (AppConstants.maxRating - tourRating);
  }

  /// Get star display for guide rating
  String get guideRatingStars {
    if (guideRating == null) return 'Chưa đánh giá';
    return '★' * guideRating! + '☆' * (AppConstants.maxRating - guideRating!);
  }

  /// Get formatted creation date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Copy with method for immutable updates
  TourFeedback copyWith({
    String? id,
    String? bookingId,
    String? slotId,
    String? userId,
    int? tourRating,
    String? tourComment,
    int? guideRating,
    String? guideComment,
    String? tourGuideId,
    String? tourGuideName,
    DateTime? createdAt,
  }) {
    return TourFeedback(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      slotId: slotId ?? this.slotId,
      userId: userId ?? this.userId,
      tourRating: tourRating ?? this.tourRating,
      tourComment: tourComment ?? this.tourComment,
      guideRating: guideRating ?? this.guideRating,
      guideComment: guideComment ?? this.guideComment,
      tourGuideId: tourGuideId ?? this.tourGuideId,
      tourGuideName: tourGuideName ?? this.tourGuideName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CreateTourFeedbackData {
  final String bookingId;
  final int tourRating;
  final String? tourComment;
  final int? guideRating;
  final String? guideComment;

  const CreateTourFeedbackData({
    required this.bookingId,
    required this.tourRating,
    this.tourComment,
    this.guideRating,
    this.guideComment,
  });

  /// Validate feedback data
  bool get isValid {
    return tourRating >= AppConstants.minRating && 
           tourRating <= AppConstants.maxRating &&
           (guideRating == null || 
            (guideRating! >= AppConstants.minRating && 
             guideRating! <= AppConstants.maxRating));
  }

  /// Check if has minimum required data
  bool get hasMinimumData {
    return bookingId.isNotEmpty && tourRating > 0;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (bookingId.isEmpty) {
      errors.add('Booking ID không được để trống');
    }
    
    if (tourRating < AppConstants.minRating || tourRating > AppConstants.maxRating) {
      errors.add('Đánh giá tour phải từ ${AppConstants.minRating} đến ${AppConstants.maxRating} sao');
    }
    
    if (guideRating != null && 
        (guideRating! < AppConstants.minRating || guideRating! > AppConstants.maxRating)) {
      errors.add('Đánh giá hướng dẫn viên phải từ ${AppConstants.minRating} đến ${AppConstants.maxRating} sao');
    }
    
    if (tourComment != null && tourComment!.length > 2000) {
      errors.add('Bình luận tour không được vượt quá 2000 ký tự');
    }
    
    if (guideComment != null && guideComment!.length > 2000) {
      errors.add('Bình luận hướng dẫn viên không được vượt quá 2000 ký tự');
    }
    
    return errors;
  }
}
