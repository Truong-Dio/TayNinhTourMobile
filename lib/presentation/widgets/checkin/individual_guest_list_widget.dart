import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/individual_qr_models.dart';
import '../../providers/tour_guide_provider.dart';

class IndividualGuestListWidget extends StatefulWidget {
  final String tourSlotId;
  final Function(TourBookingGuestModel) onGuestTap;

  const IndividualGuestListWidget({
    super.key,
    required this.tourSlotId,
    required this.onGuestTap,
  });

  @override
  State<IndividualGuestListWidget> createState() => _IndividualGuestListWidgetState();
}

class _IndividualGuestListWidgetState extends State<IndividualGuestListWidget> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, checked-in, not-checked-in

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    final provider = context.read<TourGuideProvider>();
    await provider.getTourSlotGuests(widget.tourSlotId);
  }

  List<TourBookingGuestModel> _getFilteredGuests(List<TourBookingGuestModel> guests) {
    var filtered = guests;

    // ✅ NEW: Only show INDIVIDUAL guests (not group representatives and from single-guest bookings)
    // Tab "Khách lẻ" chỉ show khách lẻ không thuộc booking đại diện
    filtered = filtered.where((guest) {
      // Logic: Show guests from bookings with only 1 guest (individual bookings)
      // OR guests who are not group representatives in multi-guest bookings
      final isFromSingleGuestBooking = (guest.totalGuests ?? 1) == 1;
      final isNotGroupRepresentative = !(guest.isGroupRepresentative ?? false);

      // Show if: single guest booking OR not a group representative
      return isFromSingleGuestBooking || isNotGroupRepresentative;
    }).toList();

    // Apply status filter
    if (_filterStatus == 'checked-in') {
      filtered = filtered.where((g) => g.isCheckedIn).toList();
    } else if (_filterStatus == 'not-checked-in') {
      filtered = filtered.where((g) => !g.isCheckedIn).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((g) =>
        g.guestName.toLowerCase().contains(query) ||
        g.guestEmail.toLowerCase().contains(query) ||
        (g.guestPhone?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Sort: not checked-in first, then by name
    filtered.sort((a, b) {
      if (a.isCheckedIn != b.isCheckedIn) {
        return a.isCheckedIn ? 1 : -1;
      }
      return a.guestName.compareTo(b.guestName);
    });

    return filtered;
  }

  /// Check if guest can check-in individually (not part of group booking)
  bool _canGuestCheckIn(TourBookingGuestModel guest) {
    // Allow check-in if:
    // 1. Guest is from single-guest booking (totalGuests == 1)
    // 2. Guest is not a group representative
    final isFromSingleGuestBooking = (guest.totalGuests ?? 1) == 1;
    final isNotGroupRepresentative = !(guest.isGroupRepresentative ?? false);

    return isFromSingleGuestBooking || isNotGroupRepresentative;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TourGuideProvider>(
      builder: (context, provider, child) {
        final guests = provider.currentSlotGuests;
        final filteredGuests = _getFilteredGuests(guests);

        return Column(
          children: [
            // Compact Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Compact search field
                  Container(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm khách...',
                        hintStyle: TextStyle(fontSize: 14),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Filter chips in single row
                  Container(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(
                          'Tất cả',
                          'all',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Đã check-in',
                          'checked-in',
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Chưa check-in',
                          'not-checked-in',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Guest List
            Expanded(
              child: filteredGuests.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadGuests,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: filteredGuests.length,
                        itemBuilder: (context, index) {
                          final guest = filteredGuests[index];
                          return _buildGuestCard(guest);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? value : 'all';
        });
      },
      selectedColor: color.withOpacity(0.2),
      backgroundColor: Colors.white,
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildGuestCard(TourBookingGuestModel guest) {
    final isCheckedIn = guest.isCheckedIn;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCheckedIn ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => widget.onGuestTap(guest),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Compact avatar with status
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCheckedIn 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    guest.guestName.isNotEmpty 
                        ? guest.guestName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: isCheckedIn ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Guest info - compressed
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name only
                    Text(
                      guest.guestName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCheckedIn 
                            ? Colors.grey[600]
                            : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Email in smaller text
                    Text(
                      guest.guestEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Phone if available
                    if (guest.guestPhone != null)
                      Text(
                        guest.guestPhone!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Action or status
              if (isCheckedIn)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                )
              else if (_canGuestCheckIn(guest))
                IconButton(
                  onPressed: () => widget.onGuestTap(guest),
                  icon: const Icon(Icons.qr_code_scanner),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Check-in',
                )
              else
                Icon(
                  Icons.group,
                  color: Colors.grey[400],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty 
                ? Icons.search_off
                : Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Không tìm thấy khách hàng'
                : 'Chưa có danh sách khách',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Danh sách khách sẽ hiển thị ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}