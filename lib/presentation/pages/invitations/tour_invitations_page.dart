import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../domain/entities/tour_invitation.dart';


class TourInvitationsPage extends StatefulWidget {
  const TourInvitationsPage({super.key});

  @override
  State<TourInvitationsPage> createState() => _TourInvitationsPageState();
}

class _TourInvitationsPageState extends State<TourInvitationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvitations();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final statuses = [null, 'pending', 'accepted', 'rejected', 'expired'];
    _selectedStatus = statuses[_tabController.index];
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getMyInvitations(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời tour'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ phản hồi'),
            Tab(text: 'Đã chấp nhận'),
            Tab(text: 'Đã từ chối'),
            Tab(text: 'Đã hết hạn'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitations,
          ),
        ],
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading,
            child: Column(
              children: [
                // Statistics Header
                if (tourGuideProvider.invitationStatistics != null)
                  _buildStatisticsHeader(tourGuideProvider.invitationStatistics!),
                
                // Invitations List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInvitationsList(tourGuideProvider.tourInvitations),
                      _buildInvitationsList(_filterInvitations(tourGuideProvider.tourInvitations, 'pending')),
                      _buildInvitationsList(_filterInvitations(tourGuideProvider.tourInvitations, 'accepted')),
                      _buildInvitationsList(_filterInvitations(tourGuideProvider.tourInvitations, 'rejected')),
                      _buildInvitationsList(_filterInvitations(tourGuideProvider.tourInvitations, 'expired')),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsHeader(InvitationStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Tổng cộng',
              stats.totalInvitations.toString(),
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Chờ phản hồi',
              stats.pendingCount.toString(),
              Colors.orange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Đã chấp nhận',
              stats.acceptedCount.toString(),
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Tỷ lệ chấp nhận',
              '${stats.acceptanceRate.toStringAsFixed(1)}%',
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInvitationsList(List<TourInvitation> invitations) {
    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có lời mời nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các lời mời tour sẽ hiển thị ở đây',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final invitation = invitations[index];
          return _buildInvitationCard(invitation);
        },
      ),
    );
  }

  Widget _buildInvitationCard(TourInvitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Show simple dialog with invitation details
          _showInvitationDialog(invitation);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invitation.tourTitle ?? 'Tour không có tên',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(invitation.status),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              if (invitation.tourDescription != null)
                Text(
                  invitation.tourDescription!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 8),
              
              // Invited date
              Text(
                'Được mời: ${_formatDate(invitation.invitedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'accepted':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'expired':
        color = Colors.grey;
        icon = Icons.access_time;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<TourInvitation> _filterInvitations(List<TourInvitation> invitations, String status) {
    return invitations.where((invitation) => invitation.status.toLowerCase() == status).toList();
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ phản hồi';
      case 'accepted':
        return 'Đã chấp nhận';
      case 'rejected':
        return 'Đã từ chối';
      case 'expired':
        return 'Đã hết hạn';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showInvitationDialog(TourInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(invitation.tourTitle ?? 'Tour không có tên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trạng thái: ${invitation.statusText}'),
            const SizedBox(height: 8),
            Text('Được mời: ${_formatDate(invitation.invitedAt)}'),
            if (invitation.respondedAt != null)
              Text('Phản hồi: ${_formatDate(invitation.respondedAt!)}'),
            if (invitation.tourDescription != null) ...[
              const SizedBox(height: 8),
              Text('Mô tả: ${invitation.tourDescription!}'),
            ],
          ],
        ),
        actions: [
          if (invitation.canReject)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rejectInvitation(invitation.id);
              },
              child: const Text('Từ chối'),
            ),
          if (invitation.canAccept)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptInvitation(invitation.id);
              },
              child: const Text('Chấp nhận'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    final success = await tourGuideProvider.acceptInvitation(invitationId);

    if (success) {
      _showMessage('Đã chấp nhận lời mời thành công!');
    } else {
      _showMessage(tourGuideProvider.errorMessage ?? 'Không thể chấp nhận lời mời', isError: true);
    }
  }

  Future<void> _rejectInvitation(String invitationId) async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    final success = await tourGuideProvider.rejectInvitation(invitationId);

    if (success) {
      _showMessage('Đã từ chối lời mời');
    } else {
      _showMessage(tourGuideProvider.errorMessage ?? 'Không thể từ chối lời mời', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
