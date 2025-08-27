import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/timeline/tour_selection_timeline_widget.dart';
import '../../widgets/timeline/timeline_progress_widget.dart';
import '../../../domain/entities/active_tour.dart';
import '../../../domain/entities/timeline_item.dart';
import '../notification/guest_notification_page.dart';

class TimelinePage extends StatefulWidget {
  final String? tourId;

  const TimelinePage({super.key, this.tourId});

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

    // Auto-select tour based on provided tourId or first available
    if (widget.tourId != null && tourGuideProvider.activeTours.isNotEmpty) {
      try {
        final tour = tourGuideProvider.activeTours.firstWhere(
          (t) => t.id == widget.tourId,
        );
        _selectTour(tour);
      } catch (e) {
        // If tour with specific ID not found, select first available
        _selectTour(tourGuideProvider.activeTours.first);
      }
    } else if (tourGuideProvider.activeTours.isNotEmpty) {
      _selectTour(tourGuideProvider.activeTours.first);
    }
  }

  Future<void> _refreshData() async {
    await _loadActiveTours();
    if (_selectedTour != null) {
      await _selectTour(_selectedTour!);
    }
  }

  Future<void> _selectTour(ActiveTour tour) async {
    setState(() {
      _selectedTour = tour;
      _isLoadingTimeline = true;
    });

    final tourGuideProvider = context.read<TourGuideProvider>();

    try {
      // Use new API with TourSlot ID if available, otherwise fallback to old API
      if (tour.currentSlot != null) {
        print('🔍 Loading timeline for TourSlot: ${tour.currentSlot!.id}');
        // Use new API for per-slot timeline with progress
        await tourGuideProvider.getTourSlotTimelineWithProgress(tour.currentSlot!.id);
      } else {
        print('🔍 No current slot, loading timeline for TourOperation: ${tour.id}');
        // Fallback to old API for backward compatibility
        await tourGuideProvider.getTourTimeline(tour.id);
      }
    } catch (e) {
      print('❌ Error loading timeline: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải timeline: $e'),
            backgroundColor: Colors.orange,
          ),
        );

        // Try fallback to old API if new API fails
        if (tour.currentSlot != null) {
          print('🔄 Trying fallback to old API...');
          try {
            await tourGuideProvider.getTourTimeline(tour.id);
          } catch (fallbackError) {
            print('❌ Fallback also failed: $fallbackError');
          }
        }
      }
    }

    setState(() {
      _isLoadingTimeline = false;
    });
  }

  Future<void> _completeTimelineItem(TimelineItem item) async {
    final result = await _showCompleteDialog(item);
    if (result == null || !mounted) return;

    final tourGuideProvider = context.read<TourGuideProvider>();
    final success = await tourGuideProvider.completeTimelineItem(
      item.id,
      notes: result['notes'],
    );

    if (mounted) {
      if (success) {
        _showMessage('Đã hoàn thành: ${item.activity}');
      } else {
        _showMessage(
          tourGuideProvider.errorMessage ?? 'Không thể hoàn thành mục lịch trình',
          isError: true,
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _showCompleteDialog(TimelineItem item) async {
    if (!mounted) return null;

    final notesController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
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
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Nhập ghi chú về việc hoàn thành...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({
              'confirmed': true,
              'notes': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );

    notesController.dispose();
    return result;
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
        title: const Text('Timeline Tour'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedTour != null) {
                _selectTour(_selectedTour!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: _selectedTour != null ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GuestNotificationPage(tourId: _selectedTour!.id),
                ),
              );
            } : null,
          ),
        ],
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isLoadingTimeline,
            child: Column(
              children: [
                // Tour Header
                if (_selectedTour != null) _buildTourHeader(_selectedTour!),

                // Timeline Progress
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: _selectedTour == null
                        ? _buildTourSelectionView(tourGuideProvider)
                        : _buildTimelineView(tourGuideProvider),
                  ),
                ),

                // Bottom Action Bar
                if (_selectedTour != null) _buildBottomActionBar(tourGuideProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourHeader(dynamic tour) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tour,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tour.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${tour.checkedInCount}/${tour.bookingsCount} khách',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${tour.tourTemplate.startLocation} → ${tour.tourTemplate.endLocation}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTourSelectionView(TourGuideProvider tourGuideProvider) {
    if (tourGuideProvider.activeTours.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có tour nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return TourSelectionTimelineWidget(
      tours: tourGuideProvider.activeTours,
      selectedTour: _selectedTour,
      onTourSelected: _selectTour,
    );
  }

  Widget _buildTimelineView(TourGuideProvider tourGuideProvider) {
    return TimelineProgressWidget(
      timelineItems: tourGuideProvider.timelineItems,
      selectedTour: _selectedTour,
      onCompleteItem: _completeTimelineItem,
    );
  }

  Widget _buildBottomActionBar(TourGuideProvider tourGuideProvider) {
    final completedItems = tourGuideProvider.timelineItems.where((item) => item.isCompleted).length;
    final totalItems = tourGuideProvider.timelineItems.length;
    final progressPercent = totalItems > 0 ? (completedItems / totalItems * 100).round() : 0;
    final isCompleted = completedItems == totalItems && totalItems > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ: $completedItems/$totalItems hoàn thành',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progressPercent / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isCompleted ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GuestNotificationPage(tourId: _selectedTour!.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('Thông báo khách'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCompleted ? () {
                    _showCompleteTourDialog();
                  } : null,
                  icon: Icon(isCompleted ? Icons.flag : Icons.hourglass_empty, size: 18),
                  label: Text(isCompleted ? 'Hoàn thành tour' : 'Chưa hoàn thành'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompleteTourDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành tour'),
        content: const Text('Bạn có chắc chắn muốn hoàn thành tour này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMessage('Tour đã được hoàn thành thành công!');
              // TODO: Call API to complete tour
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }
}
