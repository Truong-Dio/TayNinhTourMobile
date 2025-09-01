import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/active_tour.dart';
import '../../../data/models/tour_slot_model.dart';
import '../tour_slot_details/tour_slot_details_page.dart';

/// Trang hiển thị chi tiết tour và danh sách tour slots
class TourDetailsPage extends StatefulWidget {
  final String tourId;

  const TourDetailsPage({
    Key? key,
    required this.tourId,
  }) : super(key: key);

  @override
  State<TourDetailsPage> createState() => _TourDetailsPageState();
}

class _TourDetailsPageState extends State<TourDetailsPage> {
  ActiveTour? tour;
  List<TourSlotData> tourSlots = [];
  bool isExpanded = false;
  bool isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _loadTourDetails();
    _loadTourSlots();
  }

  void _loadTourDetails() {
    final provider = context.read<TourGuideProvider>();
    tour = provider.activeTours.firstWhere(
      (t) => t.id == widget.tourId,
      orElse: () => throw Exception('Tour not found'),
    );
  }

  Future<void> _loadTourSlots() async {
    if (tour == null) return;

    setState(() {
      isLoadingSlots = true;
    });

    try {
      final provider = context.read<TourGuideProvider>();
      final slots = await provider.getTourSlots(tour!.tourDetailsId);

      setState(() {
        tourSlots = slots;
        isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        isLoadingSlots = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách lịch trình: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    try {
      // Reload active tours to get fresh data
      final provider = context.read<TourGuideProvider>();
      await provider.getMyActiveTours();
      _loadTourDetails();
      await _loadTourSlots();
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

  // Calculate total current bookings from all tour slots
  int _getTotalCurrentBookings() {
    if (tourSlots.isEmpty) return 0;
    return tourSlots.fold(0, (sum, slot) => sum + (slot.currentBookings ?? 0));
  }

  // Calculate total max guests from all tour slots
  int _getTotalMaxGuests() {
    if (tourSlots.isEmpty) return 0;
    return tourSlots.fold(0, (sum, slot) => sum + (slot.maxGuests ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    if (tour == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết Tour'),
          backgroundColor: Colors.indigo,
        ),
        body: const CustomErrorWidget(
          message: 'Không tìm thấy thông tin tour',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          tour!.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildTourInfoCard(),
              _buildTourSlotsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTourInfoCard() {
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
      child: Column(
        children: [
          // Header với ảnh và thông tin cơ bản
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigo.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
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
                      child: const Icon(
                        Icons.tour,
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
                            tour!.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(tour!.status),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
                      label: 'Khách',
                      value: '${_getTotalCurrentBookings()}/${_getTotalMaxGuests()}',
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.attach_money,
                      label: 'Giá',
                      value: '${tour!.price.toStringAsFixed(0)}đ',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Mô tả tour (có thể mở rộng)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mô tả tour',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedCrossFade(
                  firstChild: Text(
                    tour!.description ?? 'Không có mô tả',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(
                    tour!.description ?? 'Không có mô tả',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTourSlotsSection() {
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
                Icon(Icons.schedule, color: Colors.indigo, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Danh Sách Tour Slots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Danh sách tour slots (mock data)
          _buildTourSlotsList(),
        ],
      ),
    );
  }

  Widget _buildTourSlotsList() {
    if (isLoadingSlots) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: LoadingWidget(message: 'Đang tải lịch trình...'),
      );
    }

    if (tourSlots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.schedule,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có lịch trình nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadTourSlots,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tourSlots.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[200],
      ),
      itemBuilder: (context, index) {
        final slot = tourSlots[index];
        return _buildTourSlotItem(slot);
      },
    );
  }

  Widget _buildTourSlotItem(TourSlotData slot) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TourSlotDetailsPage(
                tourId: widget.tourId,
                slotId: slot.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSlotStatusColor(slot.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSlotStatusIcon(slot.status),
                  color: _getSlotStatusColor(slot.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatSlotDateTime(slot.tourDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${slot.currentBookings}/${slot.maxGuests} khách',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSlotStatusColor(slot.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getSlotStatusText(slot.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getSlotStatusColor(slot.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSlotDateTime(String tourDate) {
    try {
      final date = DateTime.parse(tourDate);
      return '${date.day}/${date.month}/${date.year} - 07:00';
    } catch (e) {
      return tourDate;
    }
  }

  Color _getSlotStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'FullyBooked':
        return Colors.orange;
      case 'InProgress':
        return Colors.blue;
      case 'Completed':
        return Colors.purple;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSlotStatusIcon(String status) {
    switch (status) {
      case 'Available':
        return Icons.check_circle;
      case 'FullyBooked':
        return Icons.people;
      case 'InProgress':
        return Icons.play_circle;
      case 'Completed':
        return Icons.done_all;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getSlotStatusText(String status) {
    switch (status) {
      case 'Available':
        return 'Có sẵn';
      case 'FullyBooked':
        return 'Đã đầy';
      case 'InProgress':
        return 'Đang thực hiện';
      case 'Completed':
        return 'Hoàn thành';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
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
}
