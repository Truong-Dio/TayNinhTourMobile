import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/timeline/tour_selection_timeline_widget.dart';
import '../../widgets/timeline/timeline_progress_widget.dart';
import '../../../domain/entities/active_tour.dart';
import '../../../domain/entities/timeline_item.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  ActiveTour? _selectedTour;
  bool _isLoadingTimeline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveTours();
    });
  }

  Future<void> _loadActiveTours() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getMyActiveTours();

    // Auto-select first tour if available
    if (tourGuideProvider.activeTours.isNotEmpty) {
      _selectTour(tourGuideProvider.activeTours.first);
    }
  }

  Future<void> _selectTour(ActiveTour tour) async {
    setState(() {
      _selectedTour = tour;
      _isLoadingTimeline = true;
    });

    final tourGuideProvider = context.read<TourGuideProvider>();
    // Note: We need tourDetailsId, but we have operationId.
    // For now, we'll use the tour ID assuming it's the same
    await tourGuideProvider.getTourTimeline(tour.id);

    setState(() {
      _isLoadingTimeline = false;
    });
  }

  Future<void> _completeTimelineItem(TimelineItem item) async {
    final confirmed = await _showCompleteDialog(item);
    if (!confirmed) return;

    final tourGuideProvider = context.read<TourGuideProvider>();
    final success = await tourGuideProvider.completeTimelineItem(
      item.id,
      notes: 'Hoàn thành bởi HDV',
    );

    if (success) {
      _showMessage('Đã hoàn thành: ${item.activity}');
    } else {
      _showMessage(
        tourGuideProvider.errorMessage ?? 'Không thể hoàn thành mục lịch trình',
        isError: true,
      );
    }
  }

  Future<bool> _showCompleteDialog(TimelineItem item) async {
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thời gian: ${item.checkInTime}'),
            Text('Hoạt động: ${item.activity}'),
            if (item.specialtyShop != null) ...[
              const SizedBox(height: 8),
              Text('Địa điểm: ${item.specialtyShop!.shopName}'),
              Text('Địa chỉ: ${item.specialtyShop!.address}'),
            ],
            const SizedBox(height: 16),
            const Text(
              'Bạn có chắc chắn đã hoàn thành mục lịch trình này?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch trình Tour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedTour != null) {
                _selectTour(_selectedTour!);
              }
            },
          ),
        ],
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isLoadingTimeline,
            child: Column(
              children: [
                // Tour Selection
                TourSelectionTimelineWidget(
                  tours: tourGuideProvider.activeTours,
                  selectedTour: _selectedTour,
                  onTourSelected: _selectTour,
                ),

                // Timeline Progress
                Expanded(
                  child: TimelineProgressWidget(
                    timelineItems: tourGuideProvider.timelineItems,
                    selectedTour: _selectedTour,
                    onCompleteItem: _completeTimelineItem,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
