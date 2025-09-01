import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../../../data/datasources/tour_guide_api_service.dart';
import '../../../data/models/tour_slot_model.dart';
import '../../../data/models/timeline_progress_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/timeline_item.dart';

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
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final details = await provider.getTourSlotDetails(widget.slotId);

      if (mounted) {
        setState(() {
          slotDetails = details;
          isLoading = false;
        });

        // Load timeline with progress for this specific tour slot
        await _loadTourSlotTimeline(widget.slotId);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Không thể tải chi tiết lịch trình: $e';
          isLoading = false;
        });
      }
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
    if (!mounted) return;
    
    setState(() {
      isLoadingTimeline = true;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final timelineItems = await provider.getTimeline(tourDetailsId);

      if (mounted) {
        setState(() {
          timeline = timelineItems;
          isLoadingTimeline = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
  }

  /// [NEW] Load timeline with progress for specific tour slot (independent per slot)
  Future<void> _loadTourSlotTimeline(String tourSlotId) async {
    if (!mounted) return;
    
    setState(() {
      isLoadingTimeline = true;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final response = await provider.getTourSlotTimelineWithProgress(tourSlotId);

      if (mounted) {
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
            shopName: item.specialtyShop!.shopName ?? 'Unnamed Shop',
            shopType: item.specialtyShop!.shopType ?? 'Unknown',
            location: item.specialtyShop!.address ?? '', // Use address as location
            description: item.specialtyShop!.description,
            isShopActive: item.specialtyShop!.isActive,
          ) : null,
          createdAt: DateTime.now().toIso8601String(), // Add required field
          updatedAt: item.completedAt?.toIso8601String(),
        )).toList();
        isLoadingTimeline = false;
      });
      }
    } catch (e) {
      if (mounted) {
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
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCompleteTourButton(),
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
                  value: _getGuestCountDisplay(),
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
          else if (timelineProgress == null || timelineProgress!.timeline.isEmpty)
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
            _buildTimelineProgressContent(),
        ],
      ),
    );
  }

  Widget _buildTimelineProgressContent() {
    final items = timelineProgress!.timeline;
    final completedCount = items.where((item) => item.isCompleted).length;
    final totalCount = items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      children: [
        // Progress header
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiến độ Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                progress == 1.0
                    ? 'Tất cả điểm đã hoàn thành!'
                    : 'Còn ${totalCount - completedCount} điểm chưa hoàn thành',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        // Timeline items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isNext = _getNextIncompleteIndex(items) == index;
            final isLast = index == items.length - 1;
            return _buildTimelineProgressItem(item, isNext, isLast);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  int _getNextIncompleteIndex(List<TimelineWithProgressDto> items) {
    for (int i = 0; i < items.length; i++) {
      if (!items[i].isCompleted) {
        return i;
      }
    }
    return -1;
  }

  Widget _buildTimelineProgressItem(TimelineWithProgressDto item, bool isNext, bool isLast) {
    final canComplete = !item.isCompleted && (_canCompleteProgressItem(item, timelineProgress!.timeline) || isNext);
    final canModifyProgress = timelineProgress?.canModifyProgress ?? true;

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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
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
                          ],
                        ),
                      ),
                      if (item.isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.successColor.withOpacity(0.3),
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
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.warningColor.withOpacity(0.3),
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
                            style: TextStyle(
                              fontSize: 12,
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
                          'Hoàn thành lúc: ${_formatProgressDateTime(item.completedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  if (canComplete && canModifyProgress) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _completeTimelineProgressItem(item),
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
                          onPressed: () => _addProgressNotes(item),
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
                  ] else if (canComplete && !canModifyProgress) ...[
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

  bool _canCompleteProgressItem(TimelineWithProgressDto item, List<TimelineWithProgressDto> allItems) {
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

  Future<void> _completeTimelineProgressItem(TimelineWithProgressDto item) async {
    // Check if timeline can be modified when using tour slot
    if (timelineProgress != null && !timelineProgress!.canModifyProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ có thể cập nhật timeline khi tour slot đang trong trạng thái "Đang thực hiện". Hiện tại chỉ có thể xem timeline.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final provider = context.read<TourGuideProvider>();
      final success = await provider.completeTimelineItemForSlot(widget.slotId, item.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hoàn thành: ${item.activity}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Reload timeline to get updated data
        await _loadTourSlotTimeline(widget.slotId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi cập nhật timeline'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addProgressNotes(TimelineWithProgressDto item) async {
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
      // Check if timeline can be modified when using tour slot
      if (timelineProgress != null && !timelineProgress!.canModifyProgress) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chỉ có thể cập nhật timeline khi tour slot đang trong trạng thái "Đang thực hiện". Hiện tại chỉ có thể xem timeline.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final provider = context.read<TourGuideProvider>();
        final success = await provider.completeTimelineItemForSlot(widget.slotId, item.id, notes: notes);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã hoàn thành: ${item.activity}'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // Reload timeline to get updated data
          await _loadTourSlotTimeline(widget.slotId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật timeline'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatProgressDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
  }

  Widget _buildBottomCompleteTourButton() {
    // Check if all timeline items are completed
    final allCompleted = timelineProgress != null &&
        timelineProgress!.timeline.isNotEmpty &&
        timelineProgress!.timeline.every((item) => item.isCompleted);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: allCompleted ? _showCompleteTourDialog : null,
            icon: const Icon(Icons.flag, size: 24),
            label: const Text(
              'Hoàn thành tour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: allCompleted ? AppTheme.successColor : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: allCompleted ? 4 : 0,
            ),
          ),
        ),
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

  String _getGuestCountDisplay() {
    // First try to get from slot data
    int currentBookings = slotDetails!.data.slot.currentBookings;
    int maxGuests = slotDetails!.data.slot.maxGuests;
    
    // If slot data is 0, try to get from statistics
    if (currentBookings == 0 && maxGuests == 0) {
      // Use statistics data as fallback
      currentBookings = slotDetails!.data.statistics.totalGuests;
      maxGuests = slotDetails!.data.slot.maxGuests;
      
      // If maxGuests is still 0, calculate from bookedUsers
      if (maxGuests == 0) {
        // Calculate total capacity from booked users
        int totalCapacity = 0;
        for (var user in slotDetails!.data.bookedUsers) {
          totalCapacity += user.numberOfGuests;
        }
        // Set a reasonable max if we have bookings
        if (totalCapacity > 0) {
          maxGuests = totalCapacity + 10; // Add some buffer
        }
      }
    }
    
    // If we still don't have data, use bookedUsers count
    if (currentBookings == 0 && slotDetails!.data.bookedUsers.isNotEmpty) {
      // Count total guests from bookedUsers
      int totalGuests = 0;
      for (var user in slotDetails!.data.bookedUsers) {
        totalGuests += user.numberOfGuests;
      }
      currentBookings = totalGuests;
    }
    
    // Return formatted string
    if (maxGuests > 0) {
      return '$currentBookings/$maxGuests';
    } else {
      return '$currentBookings';
    }
  }
}
