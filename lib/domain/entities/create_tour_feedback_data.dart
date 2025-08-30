import 'package:equatable/equatable.dart';

/// Data class for creating tour feedback
class CreateTourFeedbackData extends Equatable {
  final String bookingId;
  final int? tourRating;
  final String? tourComment;
  final int? guideRating;
  final String? guideComment;

  const CreateTourFeedbackData({
    required this.bookingId,
    this.tourRating,
    this.tourComment,
    this.guideRating,
    this.guideComment,
  });

  @override
  List<Object?> get props => [
        bookingId,
        tourRating,
        tourComment,
        guideRating,
        guideComment,
      ];

  /// Check if the feedback data is valid for submission
  bool get isValid {
    return bookingId.isNotEmpty && 
           tourRating != null && 
           tourRating! >= 1 && 
           tourRating! <= 5;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (bookingId.isEmpty) {
      errors.add('Booking ID không được để trống');
    }
    
    if (tourRating == null) {
      errors.add('Vui lòng đánh giá tour');
    } else if (tourRating! < 1 || tourRating! > 5) {
      errors.add('Đánh giá tour phải từ 1 đến 5 sao');
    }
    
    if (guideRating != null && (guideRating! < 1 || guideRating! > 5)) {
      errors.add('Đánh giá hướng dẫn viên phải từ 1 đến 5 sao');
    }
    
    return errors;
  }

  /// Copy with method for immutable updates
  CreateTourFeedbackData copyWith({
    String? bookingId,
    int? tourRating,
    String? tourComment,
    int? guideRating,
    String? guideComment,
  }) {
    return CreateTourFeedbackData(
      bookingId: bookingId ?? this.bookingId,
      tourRating: tourRating ?? this.tourRating,
      tourComment: tourComment ?? this.tourComment,
      guideRating: guideRating ?? this.guideRating,
      guideComment: guideComment ?? this.guideComment,
    );
  }
}
