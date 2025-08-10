import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/active_tour.dart';
import '../tour_details/tour_details_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';

/// Helper function to fix image URLs from localhost to actual IP
String _fixImageUrl(String url) {
  if (url.contains('localhost:5267')) {
    // Extract base URL without /api suffix
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    return url.replaceAll('http://localhost:5267', baseUrl);
  }
  return url;
}

/// Trang hiển thị danh sách các tour đã nhận
class AcceptedToursPage extends StatefulWidget {
  const AcceptedToursPage({Key? key}) : super(key: key);

  @override
  State<AcceptedToursPage> createState() => _AcceptedToursPageState();
}

class _AcceptedToursPageState extends State<AcceptedToursPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TourGuideProvider>().getMyActiveTours();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Các Tour đã nhận',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.getMyActiveTours(),
            );
          }

          if (provider.activeTours.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.getMyActiveTours(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.activeTours.length,
              itemBuilder: (context, index) {
                final tour = provider.activeTours[index];
                return _buildTourCard(tour);
              },
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
            Icons.tour_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tour nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa nhận tour nào.\nHãy kiểm tra lời mời tour.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(ActiveTour tour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TourDetailsPage(tourId: tour.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildTourImage(tour),

              // Content section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tour.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(tour.status),
                      ],
                    ),

                    if (tour.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        tour.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Tour stats
                    _buildTourStats(tour),

                    const SizedBox(height: 16),

                    // Location and date info
                    _buildTourInfo(tour),

                    // Current slot info if available
                    if (tour.currentSlot != null) ...[
                      const SizedBox(height: 16),
                      _buildCurrentSlotInfo(tour.currentSlot!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourImage(ActiveTour tour) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Background image if available
          if (tour.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                _fixImageUrl(tour.imageUrls.first),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
              ),
            )
          else
            _buildDefaultImage(),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),

          // Status badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(tour.status).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(tour.status),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 60,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              'Tour Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color == Colors.white ? AppTheme.primaryColor : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color == Colors.white ? AppTheme.primaryColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildTourStats(ActiveTour tour) {
    return Row(
      children: [
        // Ẩn phần khách và check-in theo yêu cầu
        // Expanded(
        //   child: _buildStatCard(
        //     icon: Icons.people,
        //     label: 'Khách',
        //     value: '${tour.currentBookings}/${tour.maxGuests}',
        //     color: Colors.blue,
        //   ),
        // ),
        // const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            label: 'Giá',
            value: '${NumberFormat('#,###').format(tour.price)}đ',
            color: Colors.green,
          ),
        ),
        // const SizedBox(width: 12),
        // Expanded(
        //   child: _buildStatCard(
        //     icon: Icons.check_circle,
        //     label: 'Check-in',
        //     value: '${tour.checkedInCount}',
        //     color: Colors.orange,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourInfo(ActiveTour tour) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${tour.tourTemplate.startLocation} → ${tour.tourTemplate.endLocation}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy - HH:mm').format(tour.startDate),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),

          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Đã lên lịch';
      case 'inprogress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Widget _buildCurrentSlotInfo(TourSlot slot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Slot hiện tại',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày: ${slot.tourDate}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Khách: ${slot.currentBookings}/${slot.maxGuests}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getSlotStatusColor(slot.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSlotStatusText(slot.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getSlotStatusColor(slot.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSlotStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'fullybooked':
        return Colors.orange;
      case 'inprogress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSlotStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Có sẵn';
      case 'fullybooked':
        return 'Đã đầy';
      case 'inprogress':
        return 'Đang diễn ra';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
