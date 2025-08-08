import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../checkin/checkin_page.dart';
import '../timeline/timeline_page.dart';
import '../incident/incident_report_page.dart';
import '../notification/guest_notification_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/active_tour.dart';

class TourProgressPage extends StatefulWidget {
  final String tourId;
  
  const TourProgressPage({
    super.key,
    required this.tourId,
  });

  @override
  State<TourProgressPage> createState() => _TourProgressPageState();
}

class _TourProgressPageState extends State<TourProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTourData();
    });
  }

  Future<void> _loadTourData() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await Future.wait([
      tourGuideProvider.getTourBookings(widget.tourId),
      tourGuideProvider.getTourTimeline(widget.tourId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ Tour'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTourData,
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

          final tour = _findTourById(tourGuideProvider.activeTours);
          if (tour == null) {
            return _buildTourNotFound();
          }

          return RefreshIndicator(
            onRefresh: _loadTourData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTourHeader(tour),
                  const SizedBox(height: 24),
                  _buildQuickStats(tourGuideProvider),
                  const SizedBox(height: 24),
                  _buildActionButtons(tour),
                  const SizedBox(height: 24),
                  _buildProgressOverview(tourGuideProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const IncidentReportPage(),
            ),
          );
        },
        backgroundColor: AppTheme.errorColor,
        child: const Icon(Icons.warning, color: Colors.white),
      ),
    );
  }

  ActiveTour? _findTourById(List<ActiveTour> tours) {
    try {
      return tours.firstWhere((tour) => tour.id == widget.tourId);
    } catch (e) {
      return null;
    }
  }

  Widget _buildTourNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tour_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy tour',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tour này có thể đã kết thúc hoặc không tồn tại',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTourHeader(ActiveTour tour) {
    return SimpleGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tour,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(tour.startDate)} - ${_formatDate(tour.endDate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(tour.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(tour.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(tour.status),
                  style: TextStyle(
                    color: _getStatusColor(tour.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (tour.description != null) ...[
            const SizedBox(height: 16),
            Text(
              tour.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(TourGuideProvider tourGuideProvider) {
    final totalBookings = tourGuideProvider.tourBookings.length;
    final checkedInCount = tourGuideProvider.tourBookings
        .where((booking) => booking.isCheckedIn)
        .length;
    final completedTimeline = tourGuideProvider.timelineItems
        .where((item) => item.isCompleted)
        .length;
    final totalTimeline = tourGuideProvider.timelineItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê nhanh',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SimpleStatCard(
                title: 'Khách hàng ($checkedInCount/$totalBookings)',
                value: checkedInCount,
                icon: Icons.people,
                gradient: AppTheme.primaryGradient,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SimpleStatCard(
                title: 'Timeline ($completedTimeline/$totalTimeline)',
                value: completedTimeline,
                icon: Icons.timeline,
                gradient: AppTheme.successGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ActiveTour tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            SimpleActionCard(
              icon: MdiIcons.qrcodeScan,
              title: 'Check-in',
              subtitle: 'Quét QR khách hàng',
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CheckInPage(tourId: tour.id),
                  ),
                );
              },
            ),
            SimpleActionCard(
              icon: MdiIcons.timelineOutline,
              title: 'Timeline',
              subtitle: 'Theo dõi lịch trình',
              color: AppTheme.successColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TimelinePage(tourId: tour.id),
                  ),
                );
              },
            ),
            SimpleActionCard(
              icon: MdiIcons.messageTextOutline,
              title: 'Thông báo',
              subtitle: 'Gửi tin nhắn',
              color: AppTheme.warningColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GuestNotificationPage(tourId: tour.id),
                  ),
                );
              },
            ),
            SimpleActionCard(
              icon: Icons.warning_outlined,
              title: 'Sự cố',
              subtitle: 'Báo cáo vấn đề',
              color: AppTheme.errorColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IncidentReportPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressOverview(TourGuideProvider tourGuideProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan tiến độ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SimpleGlassmorphicCard(
          child: Column(
            children: [
              _buildProgressItem(
                'Check-in khách hàng',
                tourGuideProvider.tourBookings.where((b) => b.isCheckedIn).length,
                tourGuideProvider.tourBookings.length,
                Icons.people,
                AppTheme.primaryColor,
              ),
              const Divider(),
              _buildProgressItem(
                'Hoàn thành timeline',
                tourGuideProvider.timelineItems.where((t) => t.isCompleted).length,
                tourGuideProvider.timelineItems.length,
                Icons.timeline,
                AppTheme.successColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(
    String title,
    int completed,
    int total,
    IconData icon,
    Color color,
  ) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completed/$total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in_progress':
        return AppTheme.successColor;
      case 'scheduled':
        return AppTheme.warningColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Đang hoạt động';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'scheduled':
        return 'Đã lên lịch';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
