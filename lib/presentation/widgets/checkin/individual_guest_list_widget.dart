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

  @override
  Widget build(BuildContext context) {
    return Consumer<TourGuideProvider>(
      builder: (context, provider, child) {
        final guests = provider.currentSlotGuests;
        final filteredGuests = _getFilteredGuests(guests);
        
        final totalGuests = guests.length;
        final checkedInCount = guests.where((g) => g.isCheckedIn).length;
        final progressPercent = totalGuests > 0 
            ? (checkedInCount / totalGuests * 100).round() 
            : 0;

        return Column(
          children: [
            // Statistics Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Tổng khách',
                        totalGuests.toString(),
                        Icons.people,
                      ),
                      _buildStatItem(
                        'Đã check-in',
                        checkedInCount.toString(),
                        Icons.check_circle,
                      ),
                      _buildStatItem(
                        'Chưa check-in',
                        (totalGuests - checkedInCount).toString(),
                        Icons.hourglass_empty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ check-in',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progressPercent / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercent >= 70 ? Colors.greenAccent : Colors.orangeAccent,
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Search field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email, SĐT...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                        padding: const EdgeInsets.all(16),
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
      label: Text(label),
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
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildGuestCard(TourBookingGuestModel guest) {
    final isCheckedIn = guest.isCheckedIn;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCheckedIn ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCheckedIn ? Colors.green.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onGuestTap(guest),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isCheckedIn 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    child: Text(
                      guest.guestName.isNotEmpty 
                          ? guest.guestName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isCheckedIn ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (isCheckedIn)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Guest info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            guest.guestName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decoration: isCheckedIn 
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCheckedIn 
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isCheckedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Đã check-in',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            guest.guestEmail,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (guest.guestPhone != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guest.guestPhone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isCheckedIn && guest.checkInTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Check-in: ${guest.checkInTime}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action button
              if (!isCheckedIn)
                IconButton(
                  onPressed: () => widget.onGuestTap(guest),
                  icon: const Icon(Icons.qr_code_scanner),
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Check-in khách',
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