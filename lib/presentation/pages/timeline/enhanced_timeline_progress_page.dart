import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/enhanced_tour_guide_provider.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../../widgets/timeline/timeline_progress_card.dart';
import '../../widgets/timeline/timeline_completion_dialog.dart';
import '../../widgets/timeline/timeline_statistics_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/timeline_progress_models.dart';
import '../../../data/models/timeline_request_models.dart';

/// Enhanced timeline progress page with new timeline progress APIs
class EnhancedTimelineProgressPage extends StatefulWidget {
  final String tourSlotId;
  final String tourTitle;
  
  const EnhancedTimelineProgressPage({
    super.key,
    required this.tourSlotId,
    required this.tourTitle,
  });

  @override
  State<EnhancedTimelineProgressPage> createState() => _EnhancedTimelineProgressPageState();
}

class _EnhancedTimelineProgressPageState extends State<EnhancedTimelineProgressPage> {
  bool _showStatistics = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimelineProgress();
    });
  }

  Future<void> _loadTimelineProgress() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final provider = context.read<EnhancedTourGuideProvider>();
      await provider.getTourSlotTimeline(widget.tourSlotId);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _completeTimelineItem(TimelineWithProgressDto item) async {
    // Check if timeline can be modified
    final provider = context.read<EnhancedTourGuideProvider>();
    final timelineProgress = provider.timelineProgress;

    if (timelineProgress != null && !timelineProgress.canModifyProgress) {
      _showErrorSnackBar('Chỉ có thể cập nhật timeline khi tour slot đang trong trạng thái "Đang thực hiện". Hiện tại chỉ có thể xem timeline.');
      return;
    }

    if (!item.canComplete) {
      _showErrorSnackBar('Timeline item này chưa thể hoàn thành');
      return;
    }

    final result = await showDialog<CompleteTimelineRequest>(
      context: context,
      builder: (context) => TimelineCompletionDialog(
        timelineItem: item,
      ),
    );

    if (result != null) {
      try {
        final provider = context.read<EnhancedTourGuideProvider>();
        final response = await provider.completeTimelineItem(
          widget.tourSlotId,
          item.id,
          result,
        );

        if (response.success) {
          _showSuccessSnackBar(response.message);
          await _loadTimelineProgress();
          
          // Show warnings if any
          if (response.warnings.isNotEmpty) {
            for (final warning in response.warnings) {
              _showInfoSnackBar(warning);
            }
          }
        } else {
          _showErrorSnackBar(response.message);
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi hoàn thành timeline item: $e');
      }
    }
  }

  Future<void> _resetTimelineItem(TimelineWithProgressDto item) async {
    // Check if timeline can be modified
    final provider = context.read<EnhancedTourGuideProvider>();
    final timelineProgress = provider.timelineProgress;

    if (timelineProgress != null && !timelineProgress.canModifyProgress) {
      _showErrorSnackBar('Chỉ có thể cập nhật timeline khi tour slot đang trong trạng thái "Đang thực hiện". Hiện tại chỉ có thể xem timeline.');
      return;
    }

    if (!item.isCompleted) {
      _showErrorSnackBar('Timeline item này chưa được hoàn thành');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận reset'),
        content: Text('Bạn có chắc muốn reset timeline item "${item.activity}"?\n\nTất cả timeline items sau đó cũng sẽ bị reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = context.read<EnhancedTourGuideProvider>();
        final request = ResetTimelineRequest(
          reason: 'Reset từ mobile app',
          resetSubsequentItems: true,
        );

        final response = await provider.resetTimelineItem(
          widget.tourSlotId,
          item.id,
          request,
        );

        if (response.success) {
          _showSuccessSnackBar(response.message);
          await _loadTimelineProgress();
        } else {
          _showErrorSnackBar(response.message);
        }
      } catch (e) {
        _showErrorSnackBar('Lỗi khi reset timeline item: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tourTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showStatistics ? Icons.timeline : Icons.analytics),
            onPressed: () {
              setState(() {
                _showStatistics = !_showStatistics;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _loadTimelineProgress,
          ),
        ],
      ),
      body: Consumer<EnhancedTourGuideProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.timelineProgress == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải timeline',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTimelineProgress,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final timelineProgress = provider.timelineProgress;
          if (timelineProgress == null) {
            return const Center(
              child: Text('Không có dữ liệu timeline'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTimelineProgress,
            child: _showStatistics 
              ? _buildStatisticsView(timelineProgress)
              : _buildTimelineView(timelineProgress),
          );
        },
      ),
    );
  }

  Widget _buildTimelineView(TimelineProgressResponse timelineProgress) {
    return Column(
      children: [
        // Progress Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiến độ tour',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timelineProgress.summary.progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timelineProgress.summary.isFullyCompleted 
                        ? Colors.green 
                        : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(timelineProgress.summary.statusText),
                      Text('${timelineProgress.summary.progressPercentage}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Timeline Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: timelineProgress.timeline.length,
            itemBuilder: (context, index) {
              final item = timelineProgress.timeline[index];
              return TimelineProgressCard(
                timelineItem: item,
                onComplete: () => _completeTimelineItem(item),
                onReset: () => _resetTimelineItem(item),
                canModifyProgress: timelineProgress.canModifyProgress,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsView(TimelineProgressResponse timelineProgress) {
    return FutureBuilder<TimelineStatisticsResponse>(
      future: context.read<EnhancedTourGuideProvider>().getTimelineStatistics(widget.tourSlotId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải thống kê: ${snapshot.error}'),
          );
        }

        final statistics = snapshot.data;
        if (statistics == null) {
          return const Center(
            child: Text('Không có dữ liệu thống kê'),
          );
        }

        return TimelineStatisticsWidget(statistics: statistics);
      },
    );
  }
}
