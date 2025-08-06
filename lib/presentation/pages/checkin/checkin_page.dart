import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/checkin/tour_selection_widget.dart';
import '../../widgets/checkin/guest_list_widget.dart';
import '../../widgets/checkin/qr_scanner_widget.dart';
import '../../../domain/entities/active_tour.dart';
import '../../../domain/entities/tour_booking.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

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

    // Auto-select first tour if available
    if (tourGuideProvider.activeTours.isNotEmpty) {
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'QR Scanner'),
            Tab(icon: Icon(Icons.list), text: 'Danh sách'),
          ],
        ),
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isLoadingBookings,
            child: Column(
              children: [
                // Tour Selection
                TourSelectionWidget(
                  tours: tourGuideProvider.activeTours,
                  selectedTour: _selectedTour,
                  onTourSelected: _selectTour,
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // QR Scanner Tab
                      QRScannerWidget(
                        onQRScanned: _handleQRScanned,
                        selectedTour: _selectedTour,
                      ),

                      // Guest List Tab
                      GuestListWidget(
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
                      ),
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
}
