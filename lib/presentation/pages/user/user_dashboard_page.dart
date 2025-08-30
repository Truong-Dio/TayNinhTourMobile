import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/modern_skeleton_loader.dart';
import '../../widgets/user/user_modern_welcome_card.dart';
import '../../widgets/user/user_modern_stat_card.dart';
import '../../widgets/user/user_modern_action_card.dart';
import 'user_tour_details_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'my_tours_page.dart';
import 'my_feedbacks_page.dart';
import '../webview/tours_webview_page.dart';


class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.getDashboardSummary();
      await userProvider.getMyBookings(refresh: true);
    } catch (e) {
      // Handle error if needed
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Trang chủ'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                    onPressed: _loadDashboardData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernWelcomeCard(context, userProvider),
                  const SizedBox(height: 24),
                  _buildModernStatsCards(context, userProvider),
                  const SizedBox(height: 32),
                  _buildModernQuickActions(context),
                  const SizedBox(height: 32),
                  _buildRecentBookings(context, userProvider),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.user?.name ?? 'Khách hàng';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 8,
        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryColor.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng bạn đến với TayNinh Tour',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.waving_hand,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, UserProvider userProvider) {
    final dashboard = userProvider.dashboardSummary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tổng tours',
                (dashboard?.totalBookings ?? userProvider.totalBookings).toString(),
                Icons.tour,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sắp tới',
                (dashboard?.upcomingTours ?? userProvider.upcomingCount).toString(),
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Hoàn thành',
                (dashboard?.completedTours ?? userProvider.completedCount).toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Đang diễn ra',
                (dashboard?.ongoingTours ?? userProvider.ongoingCount).toString(),
                Icons.play_arrow,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Đã hủy',
                (dashboard?.cancelledTours ?? userProvider.cancelledCount).toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Chờ đánh giá',
                (dashboard?.pendingFeedbacks ?? userProvider.pendingFeedbacksCount).toString(),
                Icons.rate_review,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontSize: 20,
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
              child: _buildActionCard(
                'Tours của tôi',
                'Xem tất cả tours đã đặt',
                Icons.list_alt,
                AppTheme.primaryColor,
                () => _navigateToMyTours(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Đánh giá',
                'Quản lý đánh giá của tôi',
                Icons.rate_review,
                Colors.amber,
                () => _navigateToMyFeedbacks(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Tour đang diễn ra',
                'Xem tiến độ tour hiện tại',
                Icons.play_arrow,
                Colors.orange,
                () => _navigateToOngoingTour(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Hỗ trợ',
                'Liên hệ hỗ trợ khách hàng',
                Icons.support_agent,
                Colors.green,
                () => _showSupportDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context, UserProvider userProvider) {
    final recentBookings = userProvider.bookings.take(3).toList();

    if (recentBookings.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tours gần đây',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.05),
                    AppTheme.primaryColor.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.explore,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có tour nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy đặt tour đầu tiên của bạn!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to tours page
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Khám phá tours'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tours gần đây',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _navigateToMyTours(context),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Xem tất cả'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentBookings.map((booking) => _buildBookingCard(booking)),
      ],
    );
  }

  Widget _buildBookingCard(booking) {
    final statusColor = _getStatusColor(booking.userTourStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: statusColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToMyTours(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(booking.userTourStatus),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.tourOperation.tourTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.formattedTourDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.statusName,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
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

  void _navigateToMyTours(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyToursPage()),
    );
  }

  void _navigateToMyFeedbacks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyFeedbacksPage()),
    );
  }

  void _navigateToOngoingTour(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final ongoingTours = userProvider.ongoingBookings;
    if (ongoingTours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có tour nào đang diễn ra')),
      );
      return;
    }

    final tour = ongoingTours.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserTourDetailsPage(
          bookingId: tour.id,
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hỗ trợ khách hàng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Liên hệ với chúng tôi:'),
            SizedBox(height: 8),
            Text('📞 Hotline: 1900-xxxx'),
            Text('📧 Email: support@tayninhtour.com'),
            Text('🕒 Giờ làm việc: 8:00 - 17:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _navigateToExploreTours(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ToursWebViewPage(),
      ),
    );
  }

  // Modern UI Methods
  Widget _buildModernWelcomeCard(BuildContext context, UserProvider userProvider) {
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.user?.name ?? 'Khách hàng';
    final dashboard = userProvider.dashboardSummary;

    return UserModernWelcomeCard(
      userName: userName,
      totalBookings: dashboard?.totalBookings ?? userProvider.totalBookings,
      upcomingTours: dashboard?.upcomingTours ?? userProvider.upcomingCount,
      ongoingTours: dashboard?.ongoingTours ?? userProvider.ongoingCount,
    );
  }

  Widget _buildModernStatsCards(BuildContext context, UserProvider userProvider) {
    final dashboard = userProvider.dashboardSummary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UserModernStatCard(
                title: 'Tổng tours',
                value: (dashboard?.totalBookings ?? userProvider.totalBookings).toString(),
                icon: Icons.tour,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UserModernStatCard(
                title: 'Sắp tới',
                value: (dashboard?.upcomingTours ?? userProvider.upcomingCount).toString(),
                icon: Icons.schedule,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UserModernStatCard(
                title: 'Hoàn thành',
                value: (dashboard?.completedTours ?? userProvider.completedCount).toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: UserModernStatCard(
                title: 'Đang diễn ra',
                value: (dashboard?.ongoingTours ?? userProvider.ongoingCount).toString(),
                icon: Icons.play_arrow,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UserModernStatCard(
                title: 'Đã hủy',
                value: (dashboard?.cancelledTours ?? userProvider.cancelledCount).toString(),
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UserModernStatCard(
                title: 'Chờ đánh giá',
                value: (dashboard?.pendingFeedbacks ?? userProvider.pendingFeedbacksCount).toString(),
                icon: Icons.rate_review,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: UserModernActionCard(
                title: 'Tours của tôi',
                subtitle: 'Xem danh sách tours',
                icon: Icons.tour,
                color: AppTheme.primaryColor,
                onTap: () => _navigateToMyTours(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UserModernActionCard(
                title: 'Đánh giá',
                subtitle: 'Xem đánh giá của tôi',
                icon: Icons.rate_review,
                color: Colors.amber,
                onTap: () => _navigateToMyFeedbacks(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: UserModernActionCard(
                title: 'Tour đang diễn ra',
                subtitle: 'Xem tiến độ tour hiện tại',
                icon: Icons.play_arrow,
                color: Colors.orange,
                onTap: () => _navigateToOngoingTour(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UserModernActionCard(
                title: 'Hỗ trợ',
                subtitle: 'Liên hệ hỗ trợ khách hàng',
                icon: Icons.support_agent,
                color: Colors.green,
                onTap: () => _showSupportDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Nút khám phá nhiều tour hơn
        UserModernActionCard(
          title: 'Khám phá nhiều tour hơn',
          subtitle: 'Xem tất cả tours có sẵn',
          icon: Icons.explore,
          color: Colors.purple,
          onTap: () => _navigateToExploreTours(context),
        ),
      ],
    );
  }
}
