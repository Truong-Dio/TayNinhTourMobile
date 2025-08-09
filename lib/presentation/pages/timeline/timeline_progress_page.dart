import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/timeline_item.dart';

class TimelineProgressPage extends StatefulWidget {
  final String tourId;
  
  const TimelineProgressPage({
    super.key,
    required this.tourId,
  });

  @override
  State<TimelineProgressPage> createState() => _TimelineProgressPageState();
}

class _TimelineProgressPageState extends State<TimelineProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeline();
    });
  }

  Future<void> _loadTimeline() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getTourTimeline(widget.tourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Tour'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimeline,
          ),
        ],
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          if (tourGuideProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final timelineItems = tourGuideProvider.timelineItems;
          
          if (timelineItems.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadTimeline,
            child: Column(
              children: [
                _buildProgressHeader(timelineItems),
                Expanded(
                  child: _buildTimelineList(timelineItems, tourGuideProvider),
                ),
                _buildBottomActions(timelineItems),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có timeline nào',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Timeline sẽ hiển thị khi tour được tạo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(List<TimelineItem> items) {
    final completedCount = items.where((item) => item.isCompleted).length;
    final totalCount = items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            progress == 1.0 
                ? 'Tất cả điểm đã hoàn thành!'
                : 'Còn ${totalCount - completedCount} điểm chưa hoàn thành',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(List<TimelineItem> items, TourGuideProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isNext = _getNextIncompleteIndex(items) == index;
        return _buildTimelineCard(item, provider, isNext, index == items.length - 1);
      },
    );
  }

  int _getNextIncompleteIndex(List<TimelineItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (!items[i].isCompleted) {
        return i;
      }
    }
    return -1;
  }

  Widget _buildTimelineCard(TimelineItem item, TourGuideProvider provider, bool isNext, bool isLast) {
    final canComplete = !item.isCompleted && (_canCompleteItem(item, provider.timelineItems) || isNext);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.isCompleted 
                      ? AppTheme.successColor 
                      : isNext 
                          ? AppTheme.warningColor 
                          : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isCompleted 
                        ? AppTheme.successColor 
                        : isNext 
                            ? AppTheme.warningColor 
                            : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  item.isCompleted 
                      ? Icons.check 
                      : isNext 
                          ? Icons.radio_button_unchecked 
                          : Icons.circle,
                  color: item.isCompleted 
                      ? Colors.white 
                      : isNext 
                          ? Colors.white 
                          : Colors.grey[600],
                  size: 16,
                ),
              ),
              if (!isLast) ...[
                Container(
                  width: 2,
                  height: 40,
                  color: item.isCompleted 
                      ? AppTheme.successColor 
                      : Colors.grey[300],
                ),
              ],
            ],
          ),
          const SizedBox(width: 16),
          // Timeline content
          Expanded(
            child: SimpleGlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.checkInTime,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.activity,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.successColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Hoàn thành',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ] else if (isNext) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.warningColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Tiếp theo',
                            style: TextStyle(
                              color: AppTheme.warningColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.specialtyShop != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.specialtyShop?.shopName ?? 'Không có cửa hàng',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.isCompleted && item.completedAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hoàn thành lúc: ${_formatDateTime(item.completedAt!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.completionNotes != null && item.completionNotes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.completionNotes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  if (canComplete) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _completeTimelineItem(item, provider),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Đã tới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _addNotes(item, provider),
                          icon: const Icon(Icons.note_add, size: 16),
                          label: const Text('Ghi chú'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCompleteItem(TimelineItem item, List<TimelineItem> allItems) {
    // Check if all previous items are completed
    final currentIndex = allItems.indexOf(item);
    if (currentIndex == 0) return true;
    
    for (int i = 0; i < currentIndex; i++) {
      if (!allItems[i].isCompleted) {
        return false;
      }
    }
    return true;
  }

  Widget _buildBottomActions(List<TimelineItem> items) {
    final allCompleted = items.isNotEmpty && items.every((item) => item.isCompleted);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: allCompleted ? _completeTour : null,
              icon: const Icon(Icons.flag),
              label: const Text('Hoàn thành tour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: allCompleted ? AppTheme.primaryColor : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeTimelineItem(TimelineItem item, TourGuideProvider provider) async {
    final success = await provider.completeTimelineItem(item.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã hoàn thành: ${item.activity}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật timeline'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addNotes(TimelineItem item, TourGuideProvider provider) async {
    final controller = TextEditingController();
    
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm ghi chú'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (notes != null && notes.isNotEmpty) {
      final success = await provider.completeTimelineItem(item.id, notes: notes);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hoàn thành: ${item.activity}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  void _completeTour() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành tour'),
        content: const Text('Bạn có chắc chắn muốn hoàn thành tour? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final tourGuideProvider = context.read<TourGuideProvider>();
              final success = await tourGuideProvider.completeTour(widget.tourId);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tour đã hoàn thành thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(); // Go back to previous screen
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tourGuideProvider.errorMessage ?? 'Không thể hoàn thành tour'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
  }
}
