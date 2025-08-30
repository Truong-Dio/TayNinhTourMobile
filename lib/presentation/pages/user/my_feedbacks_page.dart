import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/modern_skeleton_loader.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../../widgets/user/user_modern_feedback_card.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Đánh giá của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFeedbacks,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.myFeedbacks.isEmpty) {
            return const ModernSkeletonLoader();
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
                    'Hãy tham gia tour và để lại đánh giá nhé!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
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
                return UserModernFeedbackCard(
                  feedback: feedback,
                  onTap: () => _viewFeedbackDetails(feedback),
                  onEdit: () => _editFeedback(feedback),
                  onDelete: () => _deleteFeedback(feedback),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Modern UI Action Handlers
  void _viewFeedbackDetails(TourFeedback feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết đánh giá'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < feedback.tourRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 16),
            if (feedback.tourComment != null && feedback.tourComment!.isNotEmpty) ...[
              const Text(
                'Nhận xét:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(feedback.tourComment!),
              const SizedBox(height: 16),
            ],
            Text(
              'Ngày đánh giá: ${_formatDate(feedback.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _editFeedback(TourFeedback feedback) {
    // Navigate to edit feedback page or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chỉnh sửa đánh giá đang được phát triển'),
        backgroundColor: Colors.orange,
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
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteFeedback(feedback);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteFeedback(TourFeedback feedback) async {
    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.deleteFeedback(feedback.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa đánh giá thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadFeedbacks(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa xác định';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
