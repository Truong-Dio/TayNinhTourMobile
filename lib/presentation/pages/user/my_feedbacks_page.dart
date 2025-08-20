import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/tour_feedback.dart';
import '../../../data/models/tour_feedback_model.dart';

class MyFeedbacksPage extends StatefulWidget {
  const MyFeedbacksPage({super.key});

  @override
  State<MyFeedbacksPage> createState() => _MyFeedbacksPageState();
}

class _MyFeedbacksPageState extends State<MyFeedbacksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedbacks();
    });
  }

  Future<void> _loadFeedbacks() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.getMyFeedbacks(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Đánh giá của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedbacks,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.myFeedbacks.isEmpty) {
            return const LoadingWidget();
          }

          if (userProvider.errorMessage != null && userProvider.myFeedbacks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(userProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFeedbacks,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final feedbacks = userProvider.myFeedbacks;

          if (feedbacks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có đánh giá nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hãy hoàn thành tour và để lại đánh giá!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFeedbacks,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];
                return _buildFeedbackCard(feedback);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackCard(TourFeedback feedback) {
    final canEdit = _canEditFeedback(feedback.createdAt);
    final canDelete = _canDeleteFeedback(feedback.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đánh giá tour',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit' && canEdit) {
                      _editFeedback(feedback);
                    } else if (value == 'delete' && canDelete) {
                      _deleteFeedback(feedback);
                    }
                  },
                  itemBuilder: (context) => [
                    if (canEdit)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tour Rating
            Row(
              children: [
                const Text('Đánh giá tour: '),
                _buildStarRating(feedback.tourRating),
                const SizedBox(width: 8),
                Text('(${feedback.tourRating}/5)'),
              ],
            ),
            
            if (feedback.tourComment != null && feedback.tourComment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  feedback.tourComment!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            
            // Guide Rating
            if (feedback.guideRating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Đánh giá HDV: '),
                  _buildStarRating(feedback.guideRating!),
                  const SizedBox(width: 8),
                  Text('(${feedback.guideRating}/5)'),
                ],
              ),
              
              if (feedback.guideComment != null && feedback.guideComment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feedback.guideComment!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
            
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày đánh giá: ${_formatDate(feedback.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (!canEdit && !canDelete)
                  const Text(
                    'Không thể chỉnh sửa',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  bool _canEditFeedback(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7; // Can edit within 7 days
  }

  bool _canDeleteFeedback(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24; // Can delete within 24 hours
  }

  void _editFeedback(TourFeedback feedback) {
    showDialog(
      context: context,
      builder: (context) => _EditFeedbackDialog(
        feedback: feedback,
        onSave: (request) async {
          final userProvider = context.read<UserProvider>();
          final success = await userProvider.updateFeedback(feedback.id, request);
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật đánh giá thành công')),
            );
          }
        },
      ),
    );
  }

  void _deleteFeedback(TourFeedback feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = context.read<UserProvider>();
              final success = await userProvider.deleteFeedback(feedback.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa đánh giá thành công')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EditFeedbackDialog extends StatefulWidget {
  final TourFeedback feedback;
  final Function(UpdateTourFeedbackRequest) onSave;

  const _EditFeedbackDialog({
    required this.feedback,
    required this.onSave,
  });

  @override
  State<_EditFeedbackDialog> createState() => _EditFeedbackDialogState();
}

class _EditFeedbackDialogState extends State<_EditFeedbackDialog> {
  late int _tourRating;
  late int? _guideRating;
  late TextEditingController _tourCommentController;
  late TextEditingController _guideCommentController;

  @override
  void initState() {
    super.initState();
    _tourRating = widget.feedback.tourRating;
    _guideRating = widget.feedback.guideRating;
    _tourCommentController = TextEditingController(text: widget.feedback.tourComment ?? '');
    _guideCommentController = TextEditingController(text: widget.feedback.guideComment ?? '');
  }

  @override
  void dispose() {
    _tourCommentController.dispose();
    _guideCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa đánh giá'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đánh giá tour:'),
            const SizedBox(height: 8),
            _buildRatingSelector(_tourRating, (rating) => setState(() => _tourRating = rating)),
            const SizedBox(height: 16),
            
            const Text('Nhận xét về tour:'),
            const SizedBox(height: 8),
            TextField(
              controller: _tourCommentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Chia sẻ trải nghiệm của bạn...',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Đánh giá hướng dẫn viên:'),
            const SizedBox(height: 8),
            _buildRatingSelector(_guideRating ?? 0, (rating) => setState(() => _guideRating = rating)),
            const SizedBox(height: 16),
            
            const Text('Nhận xét về hướng dẫn viên:'),
            const SizedBox(height: 8),
            TextField(
              controller: _guideCommentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Đánh giá về hướng dẫn viên...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final request = UpdateTourFeedbackRequest(
              tourRating: _tourRating,
              tourComment: _tourCommentController.text.trim().isEmpty ? null : _tourCommentController.text.trim(),
              guideRating: _guideRating,
              guideComment: _guideCommentController.text.trim().isEmpty ? null : _guideCommentController.text.trim(),
            );
            widget.onSave(request);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  Widget _buildRatingSelector(int currentRating, Function(int) onRatingChanged) {
    return Row(
      children: List.generate(5, (index) {
        final rating = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(rating),
          child: Icon(
            rating <= currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }
}
