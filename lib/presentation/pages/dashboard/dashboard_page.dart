import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/simple_modern_widgets.dart';
import '../../widgets/common/modern_skeleton_loader.dart';
import '../checkin/checkin_page.dart';
import '../timeline/timeline_page.dart';
import '../incident/incident_report_page.dart';
import '../notification/guest_notification_page.dart';
import '../invitations/tour_invitations_page.dart';
import '../../../core/theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getMyActiveTours();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard HDV'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mail_outline),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TourInvitationsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh),
            ),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert),
            ),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: Consumer2<AuthProvider, TourGuideProvider>(
          builder: (context, authProvider, tourGuideProvider, child) {
            // Show skeleton loading on initial load
            if (tourGuideProvider.isLoading && tourGuideProvider.activeTours.isEmpty) {
              return const DashboardSkeletonLoader();
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 100),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        // Welcome Section
                        _buildModernWelcomeSection(authProvider),

                        const SizedBox(height: 32),

                        // Quick Actions
                        _buildModernQuickActions(),

                        const SizedBox(height: 32),

                        // Active Tours
                        _buildModernActiveToursSection(tourGuideProvider),

                        const SizedBox(height: 32),

                        // Statistics
                        _buildModernStatisticsSection(tourGuideProvider),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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

  Widget _buildModernWelcomeSection(AuthProvider authProvider) {
    return SimpleGlassmorphicCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.user?.name ?? 'Hướng dẫn viên',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chúc bạn có một ngày làm việc hiệu quả',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    authProvider.user?.name ?? 'Hướng dẫn viên',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Chúc bạn có một ngày làm việc hiệu quả',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernQuickActions() {
    return Consumer<TourGuideProvider>(
      builder: (context, tourGuideProvider, child) {
        final hasActiveTours = tourGuideProvider.activeTours.isNotEmpty;
        final firstTour = hasActiveTours ? tourGuideProvider.activeTours.first : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return SimpleActionCard(
                      icon: MdiIcons.qrcodeScan,
                      title: 'Check-in',
                      subtitle: hasActiveTours ? 'Quét QR khách hàng' : 'Không có tour',
                      color: hasActiveTours ? AppTheme.primaryColor : Colors.grey,
                      isEnabled: hasActiveTours,
                      onTap: hasActiveTours ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CheckInPage(tourId: firstTour!.id),
                          ),
                        );
                      } : null,
                    );
                  case 1:
                    return SimpleActionCard(
                      icon: MdiIcons.timelineOutline,
                      title: 'Timeline',
                      subtitle: hasActiveTours ? 'Theo dõi lịch trình' : 'Không có tour',
                      color: hasActiveTours ? AppTheme.successColor : Colors.grey,
                      isEnabled: hasActiveTours,
                      onTap: hasActiveTours ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TimelinePage(tourId: firstTour!.id),
                          ),
                        );
                      } : null,
                    );
                  case 2:
                    return SimpleActionCard(
                      icon: Icons.mail_outline,
                      title: 'Lời mời tour',
                      subtitle: 'Xem lời mời',
                      color: AppTheme.secondaryColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TourInvitationsPage(),
                          ),
                        );
                      },
                    );
                  case 3:
                    return SimpleActionCard(
                      icon: MdiIcons.messageTextOutline,
                      title: 'Thông báo',
                      subtitle: hasActiveTours ? 'Gửi tin nhắn' : 'Không có tour',
                      color: hasActiveTours ? AppTheme.warningColor : Colors.grey,
                      isEnabled: hasActiveTours,
                      onTap: hasActiveTours ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GuestNotificationPage(tourId: firstTour!.id),
                          ),
                        );
                      } : null,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Consumer<TourGuideProvider>(
      builder: (context, tourGuideProvider, child) {
        final hasActiveTours = tourGuideProvider.activeTours.isNotEmpty;
        final firstTour = hasActiveTours ? tourGuideProvider.activeTours.first : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: MdiIcons.qrcodeScan,
                    title: 'Check-in',
                    subtitle: hasActiveTours ? 'Quét QR khách hàng' : 'Không có tour',
                    color: hasActiveTours ? Colors.blue : Colors.grey,
                    onTap: hasActiveTours ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckInPage(tourId: firstTour!.id),
                        ),
                      );
                    } : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: MdiIcons.timelineOutline,
                    title: 'Timeline',
                    subtitle: hasActiveTours ? 'Theo dõi lịch trình' : 'Không có tour',
                    color: hasActiveTours ? Colors.green : Colors.grey,
                    onTap: hasActiveTours ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TimelinePage(tourId: firstTour!.id),
                        ),
                      );
                    } : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.mail_outline,
                    title: 'Lời mời tour',
                    subtitle: 'Xem lời mời',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TourInvitationsPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: MdiIcons.alertCircleOutline,
                    title: 'Báo cáo sự cố',
                    subtitle: 'Thông báo vấn đề',
                    color: Colors.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const IncidentReportPage(),
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
                  child: _buildActionCard(
                    icon: MdiIcons.messageTextOutline,
                    title: 'Thông báo',
                    subtitle: hasActiveTours ? 'Gửi tin nhắn' : 'Không có tour',
                    color: hasActiveTours ? Colors.orange : Colors.grey,
                    onTap: hasActiveTours ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GuestNotificationPage(tourId: firstTour!.id),
                        ),
                      );
                    } : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(), // Empty space for symmetry
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isEnabled ? null : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernActiveToursSection(TourGuideProvider tourGuideProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tours hôm nay',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (tourGuideProvider.activeTours.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tourGuideProvider.activeTours.length} tour',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (tourGuideProvider.activeTours.isEmpty)
          _buildEmptyToursCard()
        else
          ...tourGuideProvider.activeTours.map((tour) => SimpleTourCard(
            tour: tour,
            onCheckIn: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CheckInPage(tourId: tour.id),
                ),
              );
            },
            onTimeline: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TimelinePage(tourId: tour.id),
                ),
              );
            },
            onNotification: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GuestNotificationPage(tourId: tour.id),
                ),
              );
            },
          )),
      ],
    );
  }

  Widget _buildEmptyToursCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có tour nào hôm nay',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy nghỉ ngơi và chuẩn bị cho những tour sắp tới!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToursSection(TourGuideProvider tourGuideProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tours hôm nay',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (tourGuideProvider.activeTours.isNotEmpty)
              Text(
                '${tourGuideProvider.activeTours.length} tour',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (tourGuideProvider.activeTours.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Không có tour nào hôm nay',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy nghỉ ngơi và chuẩn bị cho những tour sắp tới!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...tourGuideProvider.activeTours.map((tour) => _buildTourCard(tour)),
      ],
    );
  }

  Widget _buildTourCard(dynamic tour) {
    final checkedInPercent = tour.bookingsCount > 0
        ? (tour.checkedInCount / tour.bookingsCount * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tour,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${tour.tourTemplate.startLocation} → ${tour.tourTemplate.endLocation}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tour Stats
            Row(
              children: [
                Expanded(
                  child: _buildTourStat(
                    icon: Icons.people_outline,
                    label: 'Khách hàng',
                    value: '${tour.currentBookings}/${tour.maxGuests}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTourStat(
                    icon: Icons.check_circle_outline,
                    label: 'Check-in',
                    value: '${tour.checkedInCount}/${tour.bookingsCount}',
                    color: checkedInPercent >= 70 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckInPage(tourId: tour.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Check-in'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TimelinePage(tourId: tour.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.timeline, size: 18),
                    label: const Text('Timeline'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GuestNotificationPage(tourId: tour.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Thông báo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatisticsSection(TourGuideProvider tourGuideProvider) {
    final totalTours = tourGuideProvider.activeTours.length;
    final totalGuests = tourGuideProvider.activeTours
        .fold<int>(0, (sum, tour) => sum + tour.currentBookings);
    final totalCheckedIn = tourGuideProvider.activeTours
        .fold<int>(0, (sum, tour) => sum + tour.checkedInCount);
    final completionRate = totalGuests > 0 ? ((totalCheckedIn / totalGuests) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê hôm nay',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return SimpleStatCard(
                  title: 'Tours hôm nay',
                  value: totalTours,
                  icon: Icons.tour,
                  gradient: AppTheme.primaryGradient,
                );
              case 1:
                return SimpleStatCard(
                  title: 'Khách hàng',
                  value: totalGuests,
                  icon: Icons.people,
                  gradient: AppTheme.successGradient,
                );
              case 2:
                return SimpleStatCard(
                  title: 'Đã check-in',
                  value: totalCheckedIn,
                  icon: Icons.check_circle,
                  gradient: AppTheme.secondaryGradient,
                );
              case 3:
                return SimpleStatCard(
                  title: 'Tỷ lệ hoàn thành',
                  value: completionRate,
                  icon: Icons.analytics,
                  gradient: AppTheme.warningGradient,
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(TourGuideProvider tourGuideProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Tours hôm nay',
                value: tourGuideProvider.activeTours.length.toString(),
                icon: Icons.today,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Khách hàng',
                value: tourGuideProvider.activeTours
                    .fold<int>(0, (sum, tour) => sum + tour.currentBookings)
                    .toString(),
                icon: Icons.people,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
