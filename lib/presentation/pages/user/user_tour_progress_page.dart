import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_tour_booking_model.dart';

class UserTourProgressPage extends StatefulWidget {
  final String tourOperationId;
  final String tourTitle;

  const UserTourProgressPage({
    super.key,
    required this.tourOperationId,
    required this.tourTitle,
  });

  @override
  State<UserTourProgressPage> createState() => _UserTourProgressPageState();
}

class _UserTourProgressPageState extends State<UserTourProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTourProgress();
    });
  }

  Future<void> _loadTourProgress() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.getTourProgress(widget.tourOperationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.tourTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTourProgress,
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.tourProgress == null) {
            return const LoadingWidget();
          }

          if (userProvider.errorMessage != null && userProvider.tourProgress == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(userProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTourProgress,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final progress = userProvider.tourProgress;
          if (progress == null) {
            return const Center(
              child: Text('Không có dữ liệu tiến độ tour'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTourProgress,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTourInfoCard(progress),
                  const SizedBox(height: 16),
                  _buildProgressStatsCard(progress.stats),
                  const SizedBox(height: 16),
                  _buildGuideInfoCard(progress),
                  const SizedBox(height: 16),
                  _buildTimelineSection(progress.timeline),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourInfoCard(UserTourProgressModel progress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progress.tourTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Ngày: ${_formatDate(progress.tourStartDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Trạng thái: ${progress.currentStatus}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (progress.currentLocation != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vị trí hiện tại: ${progress.currentLocation}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
            if (progress.estimatedCompletion != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Dự kiến hoàn thành: ${_formatTime(progress.estimatedCompletion!)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStatsCard(TourProgressStatsModel stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê tiến độ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tiến độ tour',
                    '${stats.completedItems}/${stats.totalItems}',
                    stats.progressPercentage,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Check-in khách',
                    '${stats.checkedInGuests}/${stats.totalGuests}',
                    stats.checkInPercentage,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideInfoCard(UserTourProgressModel progress) {
    if (progress.guideName == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin hướng dẫn viên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.guideName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (progress.guidePhone != null)
                        Text(
                          progress.guidePhone!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (progress.guidePhone != null)
                  IconButton(
                    onPressed: () => _callGuide(progress.guidePhone!),
                    icon: Icon(Icons.phone, color: AppTheme.primaryColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(List<TourTimelineProgressItemModel> timeline) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch trình tour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...timeline.map((item) => _buildTimelineItem(item, timeline)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TourTimelineProgressItemModel item, List<TourTimelineProgressItemModel> timeline) {
    final isCompleted = item.isCompleted;
    final isActive = item.isActive;
    
    Color statusColor;
    IconData statusIcon;
    
    if (isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isActive) {
      statusColor = AppTheme.primaryColor;
      statusIcon = Icons.radio_button_checked;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              if (item.sortOrder < timeline.length)
                Container(
                  width: 2,
                  height: 40,
                  color: statusColor.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.checkInTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.activity,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.specialtyShopName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tại: ${item.specialtyShopName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
                if (item.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Hoàn thành: ${_formatTime(item.completedAt!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _callGuide(String phoneNumber) {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gọi cho hướng dẫn viên: $phoneNumber')),
    );
  }
}
