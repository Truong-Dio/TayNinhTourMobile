import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user_tour_booking.dart';
import '../../../domain/entities/create_tour_feedback_data.dart';

class TourRatingPage extends StatefulWidget {
  final UserTourBooking booking;

  const TourRatingPage({
    super.key,
    required this.booking,
  });

  @override
  State<TourRatingPage> createState() => _TourRatingPageState();
}

class _TourRatingPageState extends State<TourRatingPage> {
  final _formKey = GlobalKey<FormState>();
  final _tourCommentController = TextEditingController();
  final _guideCommentController = TextEditingController();
  
  int _tourRating = 0;
  int _guideRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tourCommentController.dispose();
    _guideCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Đánh giá tour'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _isSubmitting) {
            return const Center(child: LoadingWidget());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTourInfoCard(),
                  const SizedBox(height: 24),
                  _buildTourRatingSection(),
                  const SizedBox(height: 24),
                  _buildGuideRatingSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.booking.tourOperation.tourTitle ?? 'Tour không xác định',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatDate(widget.booking.tourOperation.tourStartDate),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${widget.booking.numberOfGuests} người',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourRatingSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá tour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildStarRating(
              rating: _tourRating,
              onRatingChanged: (rating) {
                setState(() {
                  _tourRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tourCommentController,
              decoration: const InputDecoration(
                labelText: 'Nhận xét về tour (tùy chọn)',
                hintText: 'Chia sẻ trải nghiệm của bạn về tour này...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideRatingSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá hướng dẫn viên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tùy chọn - chỉ đánh giá nếu tour có hướng dẫn viên',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildStarRating(
              rating: _guideRating,
              onRatingChanged: (rating) {
                setState(() {
                  _guideRating = rating;
                });
              },
              allowZero: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _guideCommentController,
              decoration: const InputDecoration(
                labelText: 'Nhận xét về hướng dẫn viên (tùy chọn)',
                hintText: 'Chia sẻ về dịch vụ của hướng dẫn viên...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating({
    required int rating,
    required Function(int) onRatingChanged,
    bool allowZero = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isSelected = starIndex <= rating;
        
        return GestureDetector(
          onTap: () {
            if (allowZero && rating == starIndex) {
              // Allow deselecting if allowZero is true
              onRatingChanged(0);
            } else {
              onRatingChanged(starIndex);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 40,
              color: isSelected ? Colors.amber : Colors.grey,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton(UserProvider provider) {
    final canSubmit = _tourRating > 0 && !_isSubmitting;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitFeedback(provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: canSubmit ? 4 : 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Gửi đánh giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _submitFeedback(UserProvider provider) async {
    if (!_formKey.currentState!.validate() || _tourRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá tour trước khi gửi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final feedbackData = CreateTourFeedbackData(
      bookingId: widget.booking.id,
      tourRating: _tourRating,
      tourComment: _tourCommentController.text.trim().isEmpty 
          ? null 
          : _tourCommentController.text.trim(),
      guideRating: _guideRating == 0 ? null : _guideRating,
      guideComment: _guideCommentController.text.trim().isEmpty 
          ? null 
          : _guideCommentController.text.trim(),
    );

    final success = await provider.submitTourFeedback(feedbackData);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá đã được gửi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Có lỗi xảy ra khi gửi đánh giá'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không xác định';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
