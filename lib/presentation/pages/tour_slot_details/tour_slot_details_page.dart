import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../data/datasources/tour_guide_api_service.dart';
import '../../../data/models/tour_slot_model.dart';
import '../../../data/models/timeline_progress_models.dart';

import '../checkin/checkin_page.dart';
import '../timeline/timeline_progress_page.dart';
import '../notification/guest_notification_page.dart';
import '../incident/incident_report_page.dart';

/// Trang hiển thị chi tiết tour slot với các chức năng quản lý
class TourSlotDetailsPage extends StatefulWidget {
  final String tourId;
  final String slotId;

  const TourSlotDetailsPage({
    Key? key,
    required this.tourId,
    required this.slotId,
  }) : super(key: key);

  @override
  State<TourSlotDetailsPage> createState() => _TourSlotDetailsPageState();
}

class _TourSlotDetailsPageState extends State<TourSlotDetailsPage> {
  TourSlotDetailsResponse? slotDetails;
  List<TimelineItemData> timeline = [];
  TimelineProgressResponse? timelineProgress; // NEW: Store timeline with progress
  bool isLoading = true;
  bool isLoadingTimeline = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSlotDetails();
  }

  Future<void> _loadSlotDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final details = await provider.getTourSlotDetails(widget.slotId);

      setState(() {
        slotDetails = details;
        isLoading = false;
      });

      // Load timeline with progress for this specific tour slot
      _loadTourSlotTimeline(widget.slotId);
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải chi tiết lịch trình: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      final provider = context.read<TourGuideProvider>();
      final details = await provider.getTourSlotDetails(widget.slotId);

      setState(() {
        slotDetails = details;
      });

      // Reload timeline with progress
      await _loadTourSlotTimeline(widget.slotId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi làm mới dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// [OLD] Load timeline by tour details (shared timeline)
  Future<void> _loadTimeline(String tourDetailsId) async {
    setState(() {
      isLoadingTimeline = true;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final timelineItems = await provider.getTimeline(tourDetailsId);

      setState(() {
        timeline = timelineItems;
        isLoadingTimeline = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTimeline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải lịch trình chi tiết: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// [NEW] Load timeline with progress for specific tour slot (independent per slot)
  Future<void> _loadTourSlotTimeline(String tourSlotId) async {
    setState(() {
      isLoadingTimeline = true;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final response = await provider.getTourSlotTimelineWithProgress(tourSlotId);

      setState(() {
        timelineProgress = response;
        // Convert timeline with progress to old format for backward compatibility
        timeline = response.timeline.map((item) => TimelineItemData(
          id: item.id,
          tourDetailsId: response.tourDetails.id, // Add required field
          activity: item.activity,
          checkInTime: item.checkInTime,
          sortOrder: item.sortOrder,
          specialtyShopId: item.specialtyShop?.id,
          specialtyShop: item.specialtyShop != null ? SpecialtyShopData(
            id: item.specialtyShop!.id,
            shopName: item.specialtyShop!.shopName,
            shopType: item.specialtyShop!.shopType,
            location: item.specialtyShop!.address ?? '', // Use address as location
            description: item.specialtyShop!.description,
            isShopActive: item.specialtyShop!.isActive,
          ) : null,
          createdAt: DateTime.now().toIso8601String(), // Add required field
          updatedAt: item.completedAt?.toIso8601String(),
        )).toList();
        isLoadingTimeline = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTimeline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải lịch trình tour slot: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch trình'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const LoadingWidget(message: 'Đang tải chi tiết lịch trình...'),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch trình'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: CustomErrorWidget(
          message: errorMessage!,
          onRetry: _loadSlotDetails,
        ),
      );
    }

    if (slotDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch trình'),
          backgroundColor: Colors.indigo,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const CustomErrorWidget(
          message: 'Không tìm thấy thông tin lịch trình',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Tour ${_formatDate(slotDetails!.data.slot.tourDate)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Nút báo cáo sự cố - luôn hiển thị
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncidentReportPage(),
                ),
              );
            },
            icon: const Icon(Icons.warning, color: Colors.white),
            tooltip: 'Báo cáo sự cố',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildSlotInfoCard(),
              _buildQuickActionsCard(),
              _buildTimelineCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.indigo.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSlotStatusIcon(slotDetails!.data.slot.status),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slotDetails!.data.tourDetails?.title ?? 'Tour',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(slotDetails!.data.slot.tourDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Khách đã đăng ký',
                  value: '${slotDetails!.data.slot.currentBookings}/${slotDetails!.data.slot.maxGuests}',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: Icons.access_time,
                  label: 'Check-in trước',
                  value: _getCheckInDeadline(slotDetails!.data.slot.tourDate),
                ),
              ],
            ),
            if (_isCheckInTime(slotDetails!.data.slot.tourDate)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Đã đến giờ check-in! Hãy bắt đầu quét QR cho khách.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.indigo, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Thao tác nhanh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Check-in',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckInPage(tourSlotId: widget.slotId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.timeline,
                    label: 'Timeline',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelineProgressPage(
                            tourId: widget.tourId,
                            tourSlotId: widget.slotId, // Pass tour slot ID for per-slot timeline
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.notifications,
                    label: 'Thông báo',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GuestNotificationPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.done_all,
                    label: 'Hoàn thành',
                    color: Colors.orange,
                    onTap: _showCompleteTourDialog,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.route, color: Colors.indigo, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Lịch trình chi tiết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isLoadingTimeline)
            const Padding(
              padding: EdgeInsets.all(20),
              child: LoadingWidget(message: 'Đang tải lịch trình...'),
            )
          else if (timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có lịch trình chi tiết',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final item = timeline[index];
                final isLast = index == timeline.length - 1;
                return _buildTimelineItem(item, isLast);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItemData item, bool isLast) {
    final isCompleted = item.isCompleted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.schedule,
                  color: isCompleted ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.checkInTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Hoàn thành',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.activity,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                if (item.location != null)
                  Text(
                    item.location!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (item.completionNotes != null && item.completionNotes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Ghi chú: ${item.completionNotes}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
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
        content: const Text(
          'Bạn có chắc chắn muốn hoàn thành tour này? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTour();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  void _completeTour() {
    // TODO: Implement complete tour logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tour đã hoàn thành thành công!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  IconData _getSlotStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'fullybooked':
        return Icons.people;
      case 'inprogress':
        return Icons.play_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} - 07:00';
    } catch (e) {
      return dateString;
    }
  }

  String _getCheckInDeadline(String tourDate) {
    try {
      final date = DateTime.parse(tourDate);
      final deadline = date.subtract(const Duration(hours: 1));
      return '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '06:00';
    }
  }

  bool _isCheckInTime(String tourDate) {
    try {
      final date = DateTime.parse(tourDate);
      final now = DateTime.now();
      final deadline = date.subtract(const Duration(hours: 1));
      return now.isAfter(deadline) && now.isBefore(date);
    } catch (e) {
      return false;
    }
  }
}
