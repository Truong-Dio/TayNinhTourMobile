import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/checkin/tour_selection_widget.dart';
import '../../widgets/checkin/guest_list_widget.dart';
import '../timeline/timeline_page.dart';
import '../../../domain/entities/active_tour.dart';
import '../../../data/models/tour_guide_slot_models.dart';
import '../../../data/models/tour_booking_model.dart';

class CheckInPage extends StatefulWidget {
  final String? tourId; // [LEGACY] For backward compatibility
  final String? tourSlotId; // [NEW] For direct slot selection

  const CheckInPage({super.key, this.tourId, this.tourSlotId});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> with TickerProviderStateMixin {
  late TabController _tabController;
  ActiveTour? _selectedTour;
  TourGuideSlotModel? _selectedTourSlot;
  bool _isLoadingBookings = false;
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTourSlots();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// [NEW] Load tour slots for current tour guide
  Future<void> _loadTourSlots() async {
    setState(() {
      _isLoadingSlots = true;
    });

    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getMyTourSlots();

    // ✅ NEW: Select specific slot if tourSlotId provided
    if (widget.tourSlotId != null && tourGuideProvider.tourSlots.isNotEmpty) {
      final targetSlot = tourGuideProvider.tourSlots
          .where((slot) => slot.id == widget.tourSlotId)
          .firstOrNull;

      if (targetSlot != null) {
        _selectTourSlot(targetSlot);
      } else {
        // Fallback if specific slot not found
        _selectFirstAvailableSlot(tourGuideProvider);
      }
    } else if (tourGuideProvider.tourSlots.isNotEmpty) {
      // Auto-select logic when no specific slot requested
      _selectFirstAvailableSlot(tourGuideProvider);
    }

    setState(() {
      _isLoadingSlots = false;
    });
  }

  /// Helper method to select first available slot
  void _selectFirstAvailableSlot(TourGuideProvider tourGuideProvider) {
    // ✅ UPDATED: Don't auto-select, let user choose manually
    // This prevents confusion when user wants to check a specific slot

    // Only auto-select if there's exactly one slot
    if (tourGuideProvider.tourSlots.length == 1) {
      _selectTourSlot(tourGuideProvider.tourSlots.first);
    }
    // For multiple slots, let user choose manually from the list
  }

  /// [LEGACY] Load active tours - kept for backward compatibility
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

  /// [NEW] Select tour slot and load its bookings
  Future<void> _selectTourSlot(TourGuideSlotModel tourSlot) async {
    setState(() {
      _selectedTourSlot = tourSlot;
      _isLoadingBookings = true;
    });

    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getTourSlotBookings(tourSlot.id);

    setState(() {
      _isLoadingBookings = false;
    });
  }

  /// [LEGACY] Select tour - kept for backward compatibility
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

  /// [UPDATED] Handle QR code scanning with TourSlot validation
  Future<void> _handleQRScanned(String qrData) async {
    if (_selectedTourSlot == null) {
      _showMessage('Vui lòng chọn tour slot trước khi quét QR', isError: true);
      return;
    }

    final tourGuideProvider = context.read<TourGuideProvider>();

    // ✅ NEW: Find booking by QR code in current slot
    final booking = tourGuideProvider.findBookingByQRCode(qrData);

    if (booking == null) {
      _showMessage('Không tìm thấy booking với QR code này trong slot hiện tại', isError: true);
      return;
    }

    if (booking.isCheckedIn) {
      _showMessage('Khách hàng đã được check-in trước đó', isError: true);
      return;
    }

    // Show check-in dialog with QR data
    _showQRCheckInDialog(booking, qrData);
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
            isLoading: tourGuideProvider.isLoading || _isLoadingBookings || _isLoadingSlots,
            child: Column(
              children: [
                // Tour Slot Header
                if (_selectedTourSlot != null) _buildTourSlotHeader(_selectedTourSlot!),

                // Search Bar
                if (_selectedTourSlot != null) _buildSearchBar(),

                // Guest List
                Expanded(
                  child: _selectedTourSlot == null
                      ? _buildTourSlotSelectionView(tourGuideProvider)
                      : _buildGuestListView(tourGuideProvider),
                ),

                // Bottom Action Bar
                if (_selectedTourSlot != null) _buildBottomActionBar(tourGuideProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// [NEW] Build tour slot header
  Widget _buildTourSlotHeader(TourGuideSlotModel tourSlot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tourSlot.tourDetails.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày: ${tourSlot.tourDate}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Trạng thái: ${tourSlot.status}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showTourSlotSelectionDialog(),
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Chọn slot khác',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard(
                'Tổng booking',
                '${tourSlot.bookingStats.totalBookings}',
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                'Đã check-in',
                '${tourSlot.bookingStats.checkedInCount}',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                'Tổng khách',
                '${tourSlot.bookingStats.totalGuests}',
                Icons.person,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// [LEGACY] Build tour header - kept for backward compatibility
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

  /// [NEW] Build tour slot selection view
  Widget _buildTourSlotSelectionView(TourGuideProvider tourGuideProvider) {
    if (tourGuideProvider.tourSlots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có tour slot nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Bạn chưa được phân công tour slot nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn Tour Slot để Check-in',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chọn tour slot bạn muốn check-in khách hàng',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Tour Slots List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tourGuideProvider.tourSlots.length,
            itemBuilder: (context, index) {
              final slot = tourGuideProvider.tourSlots[index];
              final hasBookings = slot.bookingStats.totalBookings > 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: hasBookings ? 3 : 1,
                child: ListTile(
                  leading: hasBookings
                    ? Icon(Icons.people, color: Colors.green[600], size: 28)
                    : Icon(Icons.people_outline, color: Colors.grey[400], size: 28),
                  title: Text(
                    slot.tourDetails.title,
                    style: TextStyle(
                      fontWeight: hasBookings ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày: ${slot.tourDate}'),
                      Text('Trạng thái: ${slot.status}'),
                      Row(
                        children: [
                          Text('${slot.bookingStats.totalBookings} booking'),
                          const SizedBox(width: 8),
                          Text('•'),
                          const SizedBox(width: 8),
                          Text('${slot.bookingStats.totalGuests} khách'),
                          if (hasBookings) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.fiber_manual_record,
                              color: Colors.green[600], size: 8),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectTourSlot(slot),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// [LEGACY] Build tour selection view - kept for backward compatibility
  Widget _buildTourSelectionView(TourGuideProvider tourGuideProvider) {
    return TourSelectionWidget(
      tours: tourGuideProvider.activeTours,
      selectedTour: _selectedTour,
      onTourSelected: _selectTour,
    );
  }

  Widget _buildGuestListView(TourGuideProvider tourGuideProvider) {
    // ✅ NEW: Use TourSlot bookings instead of TourOperation bookings
    final bookings = tourGuideProvider.currentSlotBookingsList;

    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có booking nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tour slot này chưa có khách hàng đặt tour',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: booking.isCheckedIn ? Colors.green : Colors.orange,
              child: Icon(
                booking.isCheckedIn ? Icons.check : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(booking.contactName ?? booking.customerName ?? 'Khách hàng'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã booking: ${booking.bookingCode}'),
                Text('Số khách: ${booking.numberOfGuests}'),
                if (booking.isCheckedIn && booking.checkInTime != null)
                  Text('Check-in: ${booking.checkInTime}'),
              ],
            ),
            trailing: booking.isCheckedIn
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Manual check-in button (emergency)
                      TextButton.icon(
                        onPressed: () => _handleManualCheckIn(booking),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Thủ công'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // QR check-in button (primary)
                      ElevatedButton.icon(
                        onPressed: () => _startQRCheckInProcess(booking),
                        icon: const Icon(Icons.qr_code_scanner, size: 16),
                        label: const Text('Quét QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Start QR check-in process - opens QR scanner first
  Future<void> _startQRCheckInProcess(TourBookingModel booking) async {
    try {
      // Show QR scanner dialog
      final qrData = await _showQRScannerDialog(booking);

      if (qrData != null && qrData.isNotEmpty) {
        // Validate QR code matches this booking
        if (_validateQRCode(qrData, booking)) {
          // Show check-in confirmation dialog with override option
          _showQRCheckInDialog(booking, qrData);
        } else {
          _showMessage('Mã QR không khớp với booking này', isError: true);
        }
      }
    } catch (e) {
      _showMessage('Lỗi khi quét QR: $e', isError: true);
    }
  }

  /// Validate QR code matches booking
  bool _validateQRCode(String qrData, TourBookingModel booking) {
    // Simple validation - check if QR contains booking code or booking ID
    final qrLower = qrData.toLowerCase();
    final bookingCodeLower = booking.bookingCode.toLowerCase();
    final bookingIdLower = booking.id.toLowerCase();

    return qrLower.contains(bookingCodeLower) ||
           qrLower.contains(bookingIdLower) ||
           qrData == booking.bookingCode ||
           qrData == booking.id;
  }

  /// Show QR scanner dialog
  Future<String?> _showQRScannerDialog(TourBookingModel booking) async {
    String qrInput = '';

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.blue),
            SizedBox(width: 8),
            Text('Quét mã QR'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khách hàng: ${booking.customerName ?? booking.contactName}'),
            Text('Mã booking: ${booking.bookingCode}'),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng quét mã QR của khách hàng hoặc nhập thủ công:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Mã QR',
                hintText: 'Nhập mã QR hoặc mã booking...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              onChanged: (value) {
                qrInput = value;
              },
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Mã QR phải chứa mã booking hoặc ID booking để xác thực',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (qrInput.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập mã QR'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(qrInput.trim());
            },
            icon: const Icon(Icons.check),
            label: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  /// Handle manual check-in (legacy - for backward compatibility)
  Future<void> _handleManualCheckIn(TourBookingModel booking) async {
    _showCheckInDialog(booking);
  }

  /// Show QR check-in dialog with override option
  void _showQRCheckInDialog(TourBookingModel booking, String qrData) {
    bool overrideTime = false;
    String overrideReason = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xác nhận Check-in QR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Khách hàng: ${booking.customerName ?? booking.contactName}'),
              Text('Mã booking: ${booking.bookingCode}'),
              Text('QR Code: $qrData'),
              Text('Số khách: ${booking.numberOfGuests}'),
              const SizedBox(height: 16),

              // Override time option
              Row(
                children: [
                  Checkbox(
                    value: overrideTime,
                    onChanged: (value) {
                      setState(() {
                        overrideTime = value ?? false;
                        if (!overrideTime) {
                          overrideReason = '';
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Check-in sớm (bỏ qua kiểm tra thời gian)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              // Override reason input
              if (overrideTime) ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Lý do check-in sớm *',
                    hintText: 'Nhập lý do tại sao cần check-in sớm...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    overrideReason = value;
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Check-in sớm sẽ được ghi log đặc biệt',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text('Bạn có chắc chắn muốn check-in cho khách hàng này?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate override reason if override is enabled
                if (overrideTime && overrideReason.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập lý do check-in sớm'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                _performQRCheckIn(booking, qrData, overrideTime: overrideTime, overrideReason: overrideReason);
              },
              child: Text(overrideTime ? 'Check-in sớm' : 'Check-in'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show check-in dialog with override option
  void _showCheckInDialog(TourBookingModel booking) {
    bool overrideTime = false;
    String overrideReason = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Xác nhận Check-in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Khách hàng: ${booking.customerName ?? booking.contactName}'),
              Text('Mã booking: ${booking.bookingCode}'),
              Text('Số khách: ${booking.numberOfGuests}'),
              const SizedBox(height: 16),

              // Override time option
              Row(
                children: [
                  Checkbox(
                    value: overrideTime,
                    onChanged: (value) {
                      setState(() {
                        overrideTime = value ?? false;
                        if (!overrideTime) {
                          overrideReason = '';
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Check-in sớm (bỏ qua kiểm tra thời gian)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              // Override reason input
              if (overrideTime) ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Lý do check-in sớm *',
                    hintText: 'Nhập lý do tại sao cần check-in sớm...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    overrideReason = value;
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Check-in sớm sẽ được ghi log đặc biệt',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text('Bạn có chắc chắn muốn check-in cho khách hàng này?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate override reason if override is enabled
                if (overrideTime && overrideReason.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập lý do check-in sớm'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                _performCheckIn(booking, overrideTime: overrideTime, overrideReason: overrideReason);
              },
              child: Text(overrideTime ? 'Check-in sớm' : 'Check-in'),
            ),
          ],
        ),
      ),
    );
  }

  /// Perform QR check-in
  Future<void> _performQRCheckIn(TourBookingModel booking, String qrData, {bool overrideTime = false, String overrideReason = ''}) async {
    final tourGuideProvider = context.read<TourGuideProvider>();

    bool success;
    if (overrideTime) {
      success = await tourGuideProvider.checkInGuestWithOverride(
        booking.id,
        qrCodeData: qrData,
        notes: 'Check-in bằng QR code',
        overrideTimeRestriction: true,
        overrideReason: overrideReason,
      );
    } else {
      success = await tourGuideProvider.checkInGuest(
        booking.id,
        qrCodeData: qrData,
        notes: 'Check-in bằng QR code',
      );
    }

    if (success) {
      final message = overrideTime
          ? 'Check-in sớm thành công cho ${booking.customerName ?? booking.contactName}'
          : 'Check-in thành công cho ${booking.customerName ?? booking.contactName}';
      _showMessage(message);
      // Reload slot bookings to update UI
      if (_selectedTourSlot != null) {
        await tourGuideProvider.getTourSlotBookings(_selectedTourSlot!.id);
      }
    } else {
      _showMessage(tourGuideProvider.errorMessage ?? 'Check-in thất bại', isError: true);
    }
  }

  /// Perform actual check-in
  Future<void> _performCheckIn(TourBookingModel booking, {bool overrideTime = false, String overrideReason = ''}) async {
    final tourGuideProvider = context.read<TourGuideProvider>();

    bool success;
    if (overrideTime) {
      success = await tourGuideProvider.checkInGuestWithOverride(
        booking.id,
        notes: 'Check-in thủ công',
        overrideTimeRestriction: true,
        overrideReason: overrideReason,
      );
    } else {
      success = await tourGuideProvider.checkInGuest(
        booking.id,
        notes: 'Check-in thủ công',
      );
    }

    if (success) {
      final message = overrideTime
          ? 'Check-in sớm thành công cho ${booking.customerName ?? booking.contactName}'
          : 'Check-in thành công cho ${booking.customerName ?? booking.contactName}';
      _showMessage(message);
      // Reload slot bookings to update UI
      if (_selectedTourSlot != null) {
        await tourGuideProvider.getTourSlotBookings(_selectedTourSlot!.id);
      }
    } else {
      _showMessage(tourGuideProvider.errorMessage ?? 'Check-in thất bại', isError: true);
    }
  }

  Widget _buildBottomActionBar(TourGuideProvider tourGuideProvider) {
    // ✅ NEW: Use TourSlot bookings statistics
    final bookings = tourGuideProvider.currentSlotBookingsList;
    final totalGuests = bookings.length;
    final checkedInGuests = bookings.where((b) => b.isCheckedIn).length;
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
                // ✅ NEW: Use TourSlot ID for timeline
                if (_selectedTourSlot != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TimelinePage(tourId: _selectedTourSlot!.id),
                    ),
                  );
                }
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

  /// Show tour slot selection dialog
  void _showTourSlotSelectionDialog() {
    final tourGuideProvider = context.read<TourGuideProvider>();

    // ✅ Sort slots: slots with bookings first, then by date
    final sortedSlots = List<TourGuideSlotModel>.from(tourGuideProvider.tourSlots)
      ..sort((a, b) {
        // First priority: slots with bookings
        if (a.bookingStats.totalBookings > 0 && b.bookingStats.totalBookings == 0) return -1;
        if (a.bookingStats.totalBookings == 0 && b.bookingStats.totalBookings > 0) return 1;

        // Second priority: by date (ascending)
        return a.tourDate.compareTo(b.tourDate);
      });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn Tour Slot'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: sortedSlots.length,
            itemBuilder: (context, index) {
              final slot = sortedSlots[index];
              final isSelected = _selectedTourSlot?.id == slot.id;
              final hasBookings = slot.bookingStats.totalBookings > 0;

              return ListTile(
                title: Text(slot.tourDetails.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${slot.tourDate} - ${slot.status}'),
                    if (hasBookings)
                      Text(
                        '${slot.bookingStats.totalBookings} booking(s), ${slot.bookingStats.totalGuests} khách',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                leading: hasBookings
                  ? Icon(Icons.people, color: Colors.green[600])
                  : Icon(Icons.people_outline, color: Colors.grey[400]),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();
                  _selectTourSlot(slot);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  /// Build stat card widget
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
