import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/tour_booking.dart';
import '../../../domain/entities/active_tour.dart';

class GuestListWidget extends StatefulWidget {
  final List<TourBooking> bookings;
  final ActiveTour? selectedTour;
  final Function(TourBooking) onCheckIn;

  const GuestListWidget({
    super.key,
    required this.bookings,
    required this.selectedTour,
    required this.onCheckIn,
  });

  @override
  State<GuestListWidget> createState() => _GuestListWidgetState();
}

class _GuestListWidgetState extends State<GuestListWidget> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, checked_in, not_checked_in

  List<TourBooking> get _filteredBookings {
    var filtered = widget.bookings.where((booking) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (booking.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (booking.contactName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          booking.bookingCode.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _filterStatus == 'all' ||
          (_filterStatus == 'checked_in' && booking.isCheckedIn) ||
          (_filterStatus == 'not_checked_in' && !booking.isCheckedIn);

      return matchesSearch && matchesStatus;
    }).toList();

    // Sort: not checked in first, then by booking date
    filtered.sort((a, b) {
      if (a.isCheckedIn != b.isCheckedIn) {
        return a.isCheckedIn ? 1 : -1;
      }
      return a.bookingDate.compareTo(b.bookingDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedTour == null) {
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
              'Vui lòng chọn tour trước',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có khách hàng nào đăng ký',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search and Filter
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tìm kiếm khách hàng',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Filter chips
              Row(
                children: [
                  const Text('Lọc: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Tất cả'),
                          selected: _filterStatus == 'all',
                          onSelected: (selected) {
                            setState(() {
                              _filterStatus = 'all';
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Đã check-in'),
                          selected: _filterStatus == 'checked_in',
                          onSelected: (selected) {
                            setState(() {
                              _filterStatus = 'checked_in';
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('Chưa check-in'),
                          selected: _filterStatus == 'not_checked_in',
                          onSelected: (selected) {
                            setState(() {
                              _filterStatus = 'not_checked_in';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Statistics
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Tổng cộng',
                    widget.bookings.length.toString(),
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Đã check-in',
                    widget.bookings.where((b) => b.isCheckedIn).length.toString(),
                    Colors.green,
                  ),
                  _buildStatItem(
                    'Chưa check-in',
                    widget.bookings.where((b) => !b.isCheckedIn).length.toString(),
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Guest list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredBookings.length,
            itemBuilder: (context, index) {
              final booking = _filteredBookings[index];
              return _buildBookingCard(booking);
            },
          ),
        ),
      ],
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(TourBooking booking) {
    final isCheckedIn = booking.isCheckedIn;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCheckedIn ? Colors.green : Colors.orange,
          child: Icon(
            isCheckedIn ? Icons.check : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          booking.customerName ?? booking.contactName ?? 'Khách hàng',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: isCheckedIn ? TextDecoration.lineThrough : null,
            color: isCheckedIn ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã booking: ${booking.bookingCode}'),
            Text('Số khách: ${booking.numberOfGuests} (${booking.adultCount} NL, ${booking.childCount} TE)'),
            if (booking.contactPhone != null)
              Text('SĐT: ${booking.contactPhone}'),
            if (isCheckedIn && booking.checkInTime != null)
              Text(
                'Check-in: ${DateFormat('HH:mm dd/MM/yyyy').format(booking.checkInTime!)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: isCheckedIn
            ? Icon(
                Icons.check_circle,
                color: Colors.green[700],
              )
            : ElevatedButton(
                onPressed: () => _showCheckInDialog(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Check-in'),
              ),
        isThreeLine: true,
      ),
    );
  }

  void _showCheckInDialog(TourBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Check-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khách hàng: ${booking.customerName ?? booking.contactName}'),
            Text('Mã booking: ${booking.bookingCode}'),
            Text('Số khách: ${booking.numberOfGuests}'),
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
              Navigator.of(context).pop();
              widget.onCheckIn(booking);
            },
            child: const Text('Check-in'),
          ),
        ],
      ),
    );
  }
}
