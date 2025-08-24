import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user_tour_booking.dart';
import '../../../data/models/user_tour_booking_model.dart';

import '../../../data/models/timeline_progress_models.dart';
/// Màn hình chi tiết tour chỉ đọc cho người dùng
class UserTourDetailsPage extends StatefulWidget {
  final String bookingId;

  const UserTourDetailsPage({super.key, required this.bookingId});

  @override
  State<UserTourDetailsPage> createState() => _UserTourDetailsPageState();
}

class _UserTourDetailsPageState extends State<UserTourDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadTourDetails();
  }

  Future<void> _loadTourDetails() async {
    final provider = context.read<UserProvider>();

    // Load booking details first
    await provider.getBookingDetails(widget.bookingId);

    // Then load tour progress if booking is loaded successfully
    if (provider.selectedBooking?.tourSlotId != null) {
      print('Fetching timeline for tourSlotId: ${provider.selectedBooking!.tourSlotId!}');
      await provider.getTourSlotTimeline(provider.selectedBooking!.tourSlotId!);
    } else {
      print('tourSlotId is null, cannot fetch timeline.');
    }
  }

  Future<void> _refreshData() async {
    await _loadTourDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chi tiết Tour',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final timelineResponse = provider.timelineProgressResponse;

          if (provider.isLoading && timelineResponse == null) {
            return const Center(child: LoadingWidget());
          }

          if (provider.errorMessage != null && timelineResponse == null) {
            return CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: _refreshData,
            );
          }

          if (provider.selectedBooking == null) {
            return const CustomErrorWidget(
              message: 'Không tìm thấy thông tin booking',
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildBookingInfoCard(provider.selectedBooking!),
                  _buildTourTimelineSection(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingInfoCard(UserTourBooking booking) {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Title
            Text(
              booking.tourOperation.tourTitle ?? 'Tour không có tên',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            // Booking Status
            _buildStatusChip(booking.statusName),
            const SizedBox(height: 16),

            // Booking Information
            _buildInfoRow(
              Icons.confirmation_number,
              'Mã booking',
              booking.bookingCode,
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày tour',
              booking.tourOperation.tourStartDate != null
                  ? DateFormat('dd/MM/yyyy').format(booking.tourOperation.tourStartDate!)
                  : 'Chưa xác định',
            ),
            _buildInfoRow(
              Icons.people,
              'Số khách',
              '${booking.numberOfGuests} người',
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Tổng tiền',
              '${NumberFormat('#,###').format(booking.totalPrice)} VNĐ',
            ),
            if (booking.tourOperation.guideName != null) ...[
              _buildInfoRow(
                Icons.person,
                'Hướng dẫn viên',
                booking.tourOperation.guideName!,
              ),
            ],
            if (booking.tourOperation.guidePhone != null) ...[
              _buildInfoRow(
                Icons.phone,
                'SĐT HDV',
                booking.tourOperation.guidePhone!,
              ),
            ],

            // Contact Information
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Thông tin liên hệ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person_outline,
              'Tên liên hệ',
              booking.contactName,
            ),
            _buildInfoRow(
              Icons.phone_outlined,
              'Số điện thoại',
              booking.contactPhone,
            ),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              booking.contactEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'đã xác nhận':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'pending':
      case 'chờ xác nhận':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'cancelled':
      case 'đã hủy':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'completed':
      case 'hoàn thành':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.indigo.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourTimelineSection(UserProvider provider) {
    final timelineResponse = provider.timelineProgressResponse;

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
            const Text(
              'Lịch trình Tour',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            if (timelineResponse != null) ...[
              // _buildProgressStats(timelineResponse.summary),
              const SizedBox(height: 20),
              _buildTimelineList(timelineResponse.timeline),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Chưa có thông tin lịch trình',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats(UserTourProgressModel progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Tiến độ',
                  '${progress.stats.progressPercentage.toStringAsFixed(1)}%',
                  Icons.timeline,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Hoàn thành',
                  '${progress.stats.completedItems}/${progress.stats.totalItems}',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.stats.progressPercentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.indigo,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(List<TimelineWithProgressDto> timeline) {
    if (timeline.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Chưa có lịch trình chi tiết',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeline.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = timeline[index];
        return _buildTimelineItem(item, index == timeline.length - 1, timeline);
      },
    );
  }

  Widget _buildTimelineItem(TimelineWithProgressDto item, bool isLast, List<TimelineWithProgressDto> timeline) {
    final bool isActive = !item.isCompleted && (timeline.where((i) => i.sortOrder < item.sortOrder).every((i) => i.isCompleted));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? AppTheme.successColor
                    : isActive
                        ? Colors.orange
                        : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted
                      ? AppTheme.successColor
                      : isActive
                          ? Colors.orange.shade700
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Icon(
                item.isCompleted
                    ? Icons.check
                    : isActive
                        ? Icons.access_time
                        : Icons.circle,
                color: item.isCompleted
                    ? Colors.white
                    : isActive
                        ? Colors.white
                        : Colors.grey.shade600,
                size: 14,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: item.isCompleted
                    ? AppTheme.successColor
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Timeline content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.orange.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? Colors.orange.shade200
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.checkInTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (item.isCompleted)
                      const Chip(
                        label: Text('Hoàn thành'),
                        backgroundColor: AppTheme.successColor,
                        labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.activity,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                if (item.specialtyShop?.shopName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.store, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.specialtyShop!.shopName!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.completedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Hoàn thành lúc: ${DateFormat('HH:mm dd/MM').format(item.completedAt!)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
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
    );
  }
}

