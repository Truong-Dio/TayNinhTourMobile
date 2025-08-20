import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/modern_skeleton_loader.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../../widgets/user/user_modern_tour_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user_tour_booking.dart';

class MyToursPage extends StatefulWidget {
  const MyToursPage({super.key});

  @override
  State<MyToursPage> createState() => _MyToursPageState();
}

class _MyToursPageState extends State<MyToursPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.getMyBookings(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Tours của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          tabs: const [
            Tab(
              text: 'Tất cả',
              icon: Icon(Icons.list, size: 18),
            ),
            Tab(
              text: 'Sắp tới',
              icon: Icon(Icons.schedule, size: 18),
            ),
            Tab(
              text: 'Đang diễn ra',
              icon: Icon(Icons.play_arrow, size: 18),
            ),
            Tab(
              text: 'Hoàn thành',
              icon: Icon(Icons.check_circle, size: 18),
            ),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.bookings.isEmpty) {
            return const ModernSkeletonLoader();
          }

          if (userProvider.errorMessage != null && userProvider.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(userProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildToursList(userProvider.bookings),
              _buildToursList(userProvider.upcomingBookings),
              _buildToursList(userProvider.ongoingBookings),
              _buildToursList(userProvider.completedBookings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToursList(List<UserTourBooking> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tour,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không có tour nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return UserModernTourCard(
            booking: booking,
            onTap: () => _viewTourDetails(booking),
            onViewDetails: () => _viewTourDetails(booking),
            onCancel: () => _cancelTour(booking),
          );
        },
      ),
    );
  }

  Widget _buildTourCard(UserTourBooking booking) {
    final statusColor = _getStatusColor(booking.userTourStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shadowColor: statusColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showTourDetails(booking),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.05),
                statusColor.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.tourOperation.tourTitle ?? 'Tour không có tên',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(booking.userTourStatus),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.statusName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Ngày tour',
                      booking.formattedTourDate,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.people,
                      'Số khách',
                      '${booking.numberOfGuests} người',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Tổng tiền',
                      booking.formattedTotalPrice,
                      Colors.green,
                      isPrice: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (booking.canCancel)
                    TextButton.icon(
                      onPressed: () => _cancelBooking(booking),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Hủy tour'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  if (booking.canResendQR)
                    TextButton.icon(
                      onPressed: () => _resendQRTicket(booking),
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('Gửi lại QR'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => _showTourDetails(booking),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Chi tiết'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.tourStatusUpcoming:
        return Colors.orange;
      case AppConstants.tourStatusOngoing:
        return AppTheme.primaryColor;
      case AppConstants.tourStatusCompleted:
        return Colors.green;
      case AppConstants.tourStatusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTourDetails(UserTourBooking booking) {
    // TODO: Navigate to tour details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chi tiết tour: ${booking.tourOperation.tourTitle}')),
    );
  }

  void _cancelBooking(UserTourBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy tour'),
        content: Text('Bạn có chắc chắn muốn hủy tour "${booking.tourOperation.tourTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = context.read<UserProvider>();
              final success = await userProvider.cancelBooking(booking.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy tour thành công')),
                );
              }
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  void _resendQRTicket(UserTourBooking booking) async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.resendQRTicket(booking.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại QR ticket thành công')),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color, {bool isPrice = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.w600,
                  color: isPrice ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.tourStatusUpcoming:
        return Icons.schedule;
      case AppConstants.tourStatusOngoing:
        return Icons.play_arrow;
      case AppConstants.tourStatusCompleted:
        return Icons.check_circle;
      case AppConstants.tourStatusCancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Modern UI Action Handlers
  void _viewTourDetails(UserTourBooking booking) {
    // Navigate to tour details page
    Navigator.pushNamed(
      context,
      '/tour-details',
      arguments: booking.tourOperationId,
    );
  }

  void _cancelTour(UserTourBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy tour'),
        content: Text('Bạn có chắc chắn muốn hủy tour "${booking.tourOperation.tourTitle ?? 'này'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performCancelTour(booking);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy tour'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancelTour(UserTourBooking booking) async {
    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.cancelBooking(booking.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy tour thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi hủy tour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
