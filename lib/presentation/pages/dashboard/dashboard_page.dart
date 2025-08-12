import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tour_guide_provider.dart';

import '../../widgets/common/simple_modern_widgets.dart';
import '../../widgets/common/modern_skeleton_loader.dart';
import '../checkin/checkin_page.dart';
import '../timeline/timeline_page.dart';
import '../timeline/timeline_progress_page.dart';
import '../tour_progress/tour_progress_page.dart';
import '../incident/incident_report_page.dart';
import '../notification/guest_notification_page.dart';
import '../invitations/tour_invitations_page.dart';
import '../accepted_tours/accepted_tours_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/tour_invitation.dart';

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
    await Future.wait([
      tourGuideProvider.getMyActiveTours(),
      tourGuideProvider.getMyInvitations(),
    ]);
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Dashboard HDV',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<TourGuideProvider>(
            builder: (context, tgp, _) {
              final pending = tgp.invitationStatistics?.pendingCount ?? 0;
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mail_outline, color: Colors.white),
                    ),
                    if (pending > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '$pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TourInvitationsPage(),
                    ),
                  );
                },
                tooltip: 'Lời mời tour',
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: Colors.white),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667EEA).withOpacity(0.1),
              Colors.white,
              Colors.grey[50]!,
            ],
            stops: [0.0, 0.3, 1.0],
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
              color: Color(0xFF667EEA),
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
                        _buildModernWelcomeSection(authProvider, tourGuideProvider),

                        const SizedBox(height: 32),

                        // Quick Actions - COMMENTED OUT
                        // _buildModernQuickActions(),

                        // const SizedBox(height: 32),

                        // Pending Invitations
                        _buildPendingInvitationsSection(tourGuideProvider),

                        const SizedBox(height: 32),

                        // Active Tours
                        _buildModernActiveToursSection(tourGuideProvider),

                        const SizedBox(height: 32),

                        // Statistics - COMMENTED OUT
                        // _buildModernStatisticsSection(tourGuideProvider),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red[600]!,
              Colors.red[400]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const IncidentReportPage(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Báo cáo sự cố',
          child: Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ).animate()
        .scale(delay: 1000.ms, duration: 400.ms),
    );
  }

  Widget _buildModernWelcomeSection(
    AuthProvider authProvider,
    TourGuideProvider tourGuideProvider,
  ) {
    final userName = authProvider.user?.name ?? 'Hướng dẫn viên';
    final activeTours = tourGuideProvider.activeTours.length;
    final pendingInvites = tourGuideProvider.invitationStatistics?.pendingCount ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(delay: 200.ms),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingForNow(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ).animate()
                  .fadeIn(delay: 300.ms)
                  .slideX(begin: 0.2, end: 0),
                
                const SizedBox(height: 6),
                
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms)
                  .slideX(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.tour,
                      label: '$activeTours tour',
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.mail_outline,
                      label: '$pendingInvites lời mời',
                      isHighlight: pendingInvites > 0,
                    ),
                  ],
                ).animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight 
          ? Colors.orange.withOpacity(0.3)
          : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight
            ? Colors.orange.withOpacity(0.5)
            : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Chào buổi sáng ☀️';
    if (hour >= 11 && hour < 14) return 'Chào buổi trưa 🍽️';
    if (hour >= 14 && hour < 18) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }



  // COMMENTED OUT - Quick Actions section
  /*
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
                    final pendingCount = tourGuideProvider.invitationStatistics?.pendingCount ?? 0;
                    return SimpleActionCard(
                      icon: Icons.mail_outline,
                      title: 'Lời mời tour',
                      subtitle: pendingCount > 0 ? '$pendingCount lời mời mới' : 'Xem lời mời',
                      color: pendingCount > 0 ? AppTheme.errorColor : AppTheme.secondaryColor,
                      badgeCount: pendingCount > 0 ? pendingCount : null,
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
  */





  Widget _buildModernActiveToursSection(TourGuideProvider tourGuideProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tour,
                    size: 20,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tours được phân công',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (tourGuideProvider.activeTours.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tourGuideProvider.activeTours.length} tour',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.1, end: 0),
        
        const SizedBox(height: 20),

        // Always show quick actions
        _buildQuickActionsSection(),
        const SizedBox(height: 24),

        // Tour cards are hidden as requested
        // if (tourGuideProvider.activeTours.isEmpty)
        //   _buildEmptyToursCard()
        // else
        //   ...tourGuideProvider.activeTours.map((tour) => SimpleTourCard(
        //     tour: tour,
        //     onCheckIn: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => CheckInPage(tourId: tour.id),
        //         ),
        //       );
        //     },
        //     onTimeline: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => TimelineProgressPage(tourId: tour.id),
        //         ),
        //       );
        //     },
        //     onProgress: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => TourProgressPage(tourId: tour.id),
        //         ),
        //       );
        //     },
        //     onNotification: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => GuestNotificationPage(tourId: tour.id),
        //         ),
        //       );
        //     },
        //   )),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flash_on,
                  size: 20,
                  color: Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thao tác nhanh',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.1, end: 0),
          
          const SizedBox(height: 20),

          // Main action - Các Tour đã nhận
          _buildMainActionButton(
            icon: Icons.tour,
            label: 'Các Tour đã nhận',
            subtitle: 'Xem và quản lý tour đã được phân công',
            color: Color(0xFF667EEA),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AcceptedToursPage(),
                ),
              );
            },
          ).animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .scale(),

          // COMMENTED OUT - 4 action buttons (Check-in, Timeline, Lời mời tour, Thông báo)
          /*
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Check-in',
                  subtitle: 'Quét QR khách',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckInPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.timeline,
                  label: 'Timeline',
                  subtitle: 'Tiến độ tour',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TourProgressPage(tourId: ''),
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
                child: _buildActionButton(
                  icon: Icons.email,
                  label: 'Lời mời tour',
                  subtitle: 'Xem lời mời',
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
                child: _buildActionButton(
                  icon: Icons.notifications,
                  label: 'Thông báo',
                  subtitle: 'Gửi cho khách',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GuestNotificationPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          */
        ],
      ),
    );
  }

  Widget _buildMainActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
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
              'Chưa có tour được phân công',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kiểm tra lời mời tour để nhận thêm công việc!',
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







  // COMMENTED OUT - Statistics section
  /*
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
          'Thống kê công việc',
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
                  title: 'Tours được phân công',
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
  */



  Widget _buildPendingInvitationsSection(TourGuideProvider tourGuideProvider) {
    final pendingCount = tourGuideProvider.invitationStatistics?.pendingCount ?? 0;
    final pendingInvitations = tourGuideProvider.tourInvitations
        .where((invitation) => invitation.status == 'pending')
        .take(1) // Chỉ lấy 1 lời mời gần nhất để hiển thị preview
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pendingCount > 0 
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.mail_outline,
                size: 20,
                color: pendingCount > 0 ? Colors.orange : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lời mời đang chờ',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$pendingCount mới',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ],
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.1, end: 0),
        
        const SizedBox(height: 16),
        
        _buildInvitationSummaryCard(
          pendingCount, 
          pendingInvitations.isNotEmpty ? pendingInvitations.first : null
        ).animate()
          .fadeIn(delay: 200.ms, duration: 600.ms)
          .slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildInvitationSummaryCard(int pendingCount, TourInvitation? latestInvitation) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TourInvitationsPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: pendingCount > 0 ? Colors.orange.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: pendingCount > 0
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: pendingCount > 0
                  ? Colors.orange.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: pendingCount > 0 
            ? _buildInvitationContent(pendingCount, latestInvitation) 
            : _buildEmptyInvitationContent(),
        ),
      ),
    );
  }

  Widget _buildInvitationContent(int pendingCount, TourInvitation? latestInvitation) {
    return Row(
      children: [
        // Icon và badge
        Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.indigoGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mail_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            if (pendingCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),

          // Nội dung
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pendingCount == 1 ? '1 lời mời mới' : '$pendingCount lời mời mới',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                        color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 4),
              if (latestInvitation != null) ...[
                Text(
                  latestInvitation.tourTitle ?? 'Tour không có tên',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Nhận ${_formatDateTime(latestInvitation.invitedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ] else ...[
                Text(
                  'Nhấn để xem chi tiết',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ],
          ),
        ),

        // Arrow
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyInvitationContent() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.mail_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Không có lời mời nào',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bạn sẽ nhận được thông báo khi có lời mời mới',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }


}
