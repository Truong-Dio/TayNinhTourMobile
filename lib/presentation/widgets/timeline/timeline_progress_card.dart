import 'package:flutter/material.dart';
import '../../../data/models/timeline_progress_models.dart';
import '../../../core/theme/app_theme.dart';
import '../common/simple_modern_widgets.dart';

/// Card widget for displaying timeline progress item with action buttons
class TimelineProgressCard extends StatelessWidget {
  final TimelineWithProgressDto timelineItem;
  final VoidCallback? onComplete;
  final VoidCallback? onReset;
  final bool canModifyProgress;

  const TimelineProgressCard({
    super.key,
    required this.timelineItem,
    this.onComplete,
    this.onReset,
    this.canModifyProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getIndicatorColor(),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: _getIndicatorIcon(),
              ),
              if (!_isLastItem()) ...[
                Container(
                  width: 2,
                  height: 40,
                  color: timelineItem.isCompleted 
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
                  // Header with time and status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timelineItem.checkInTime,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timelineItem.activity,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  
                  // Specialty shop info if available
                  if (timelineItem.specialtyShop != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.store,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timelineItem.specialtyShop!.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Completion info if completed
                  if (timelineItem.isCompleted) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hoàn thành lúc ${_formatCompletedTime()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (timelineItem.completionNotes?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              timelineItem.completionNotes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                          if (timelineItem.completedByName?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Bởi: ${timelineItem.completedByName}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  // Action buttons (only show if can modify progress)
                  if (canModifyProgress) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (!timelineItem.isCompleted && timelineItem.canComplete) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onComplete,
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Hoàn thành'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (timelineItem.isCompleted) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onReset,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reset'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange[700],
                                side: BorderSide(color: Colors.orange[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (!timelineItem.canComplete && !timelineItem.isCompleted) ...[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Chờ hoàn thành item trước',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    // Show read-only message when cannot modify
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Chế độ chỉ xem - Cần tour slot ở trạng thái "Đang thực hiện" để cập nhật',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[700],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Color _getIndicatorColor() {
    if (timelineItem.isCompleted) {
      return AppTheme.successColor;
    } else if (timelineItem.canComplete) {
      return AppTheme.primaryColor;
    } else {
      return Colors.grey[400]!;
    }
  }

  Widget? _getIndicatorIcon() {
    if (timelineItem.isCompleted) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 14,
      );
    } else if (timelineItem.isNext) {
      return const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 14,
      );
    }
    return null;
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText = timelineItem.statusText;
    
    if (timelineItem.isCompleted) {
      chipColor = AppTheme.successColor;
    } else if (timelineItem.canComplete) {
      chipColor = AppTheme.primaryColor;
    } else {
      chipColor = Colors.grey[400]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCompletedTime() {
    if (timelineItem.completedAt == null) return '';
    
    final completedAt = timelineItem.completedAt!;
    return '${completedAt.hour.toString().padLeft(2, '0')}:${completedAt.minute.toString().padLeft(2, '0')}';
  }

  bool _isLastItem() {
    return timelineItem.position == timelineItem.totalItems;
  }
}
