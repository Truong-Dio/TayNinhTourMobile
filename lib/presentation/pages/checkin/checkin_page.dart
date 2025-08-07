import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/checkin/tour_selection_widget.dart';
import '../../widgets/checkin/guest_list_widget.dart';
import '../timeline/timeline_page.dart';
import '../../../domain/entities/active_tour.dart';

class CheckInPage extends StatefulWidget {
  final String? tourId;

  const CheckInPage({super.key, this.tourId});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> with TickerProviderStateMixin {
  late TabController _tabController;
  ActiveTour? _selectedTour;
  bool _isLoadingBookings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveTours();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveTours() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getMyActiveTours();

    // Auto-select tour based on provided tourId or first available
    if (widget.tourId != null && tourGuideProvider.activeTours.isNotEmpty) {
      try {
        final tour = tourGuideProvider.activeTours.firstWhere(
          (t) => t.id == widget.tourId,
        );
        _selectTour(tour);
      } catch (e) {
        // If tour with specific ID not found, select first available
        _selectTour(tourGuideProvider.activeTours.first);
      }
    } else if (tourGuideProvider.activeTours.isNotEmpty) {
      _selectTour(tourGuideProvider.activeTours.first);
    }
  }

  Future<void> _selectTour(ActiveTour tour) async {
    setState(() {
      _selectedTour = tour;
      _isLoadingBookings = true;
    });

    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getTourBookings(tour.id);

    setState(() {
      _isLoadingBookings = false;
    });
  }

  Future<void> _handleQRScanned(String qrData) async {
    if (_selectedTour == null) {
      _showMessage('Vui lòng chọn tour trước khi quét QR', isError: true);
      return;
    }

    final tourGuideProvider = context.read<TourGuideProvider>();

    // Find booking by QR code
    final booking = tourGuideProvider.tourBookings.firstWhere(
      (b) => b.qrCodeData == qrData,
      orElse: () => throw Exception('Booking not found'),
    );

    if (booking.isCheckedIn) {
      _showMessage('Khách hàng đã được check-in trước đó', isError: true);
      return;
    }

    // Perform check-in
    final success = await tourGuideProvider.checkInGuest(
      booking.id,
      qrCodeData: qrData,
      notes: 'Check-in bằng QR code',
    );

    if (success) {
      _showMessage('Check-in thành công cho ${booking.customerName ?? booking.contactName}');
    } else {
      _showMessage(tourGuideProvider.errorMessage ?? 'Check-in thất bại', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Khách Hàng'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isLoadingBookings,
            child: Column(
              children: [
                // Tour Header
                if (_selectedTour != null) _buildTourHeader(_selectedTour!),

                // Search Bar
                if (_selectedTour != null) _buildSearchBar(),

                // Guest List
                Expanded(
                  child: _selectedTour == null
                      ? _buildTourSelectionView(tourGuideProvider)
                      : _buildGuestListView(tourGuideProvider),
                ),

                // Bottom Action Bar
                if (_selectedTour != null) _buildBottomActionBar(tourGuideProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourHeader(dynamic tour) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tour,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tour.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${tour.tourTemplate.startLocation} → ${tour.tourTemplate.endLocation}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khách hàng...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          // TODO: Implement search functionality
        },
      ),
    );
  }

  Widget _buildTourSelectionView(TourGuideProvider tourGuideProvider) {
    return TourSelectionWidget(
      tours: tourGuideProvider.activeTours,
      selectedTour: _selectedTour,
      onTourSelected: _selectTour,
    );
  }

  Widget _buildGuestListView(TourGuideProvider tourGuideProvider) {
    return GuestListWidget(
      bookings: tourGuideProvider.tourBookings,
      selectedTour: _selectedTour,
      onCheckIn: (booking) async {
        final success = await tourGuideProvider.checkInGuest(
          booking.id,
          notes: 'Check-in thủ công',
        );

        if (success) {
          _showMessage('Check-in thành công cho ${booking.customerName ?? booking.contactName}');
        } else {
          _showMessage(tourGuideProvider.errorMessage ?? 'Check-in thất bại', isError: true);
        }
      },
    );
  }

  Widget _buildBottomActionBar(TourGuideProvider tourGuideProvider) {
    final totalGuests = tourGuideProvider.tourBookings.length;
    final checkedInGuests = tourGuideProvider.tourBookings.where((b) => b.isCheckedIn).length;
    final progressPercent = totalGuests > 0 ? (checkedInGuests / totalGuests * 100).round() : 0;
    final canStartTour = progressPercent >= 70; // 70% check-in required

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$checkedInGuests/$totalGuests đã check-in',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progressPercent / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        canStartTour ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: canStartTour ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canStartTour ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TimelinePage(tourId: _selectedTour!.id),
                  ),
                );
              } : null,
              icon: Icon(canStartTour ? Icons.play_arrow : Icons.hourglass_empty),
              label: Text(canStartTour ? 'Bắt đầu tour' : 'Cần ít nhất 70% check-in'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: canStartTour ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
