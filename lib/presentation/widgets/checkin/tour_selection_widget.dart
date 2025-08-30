import 'package:flutter/material.dart';
import '../../../domain/entities/active_tour.dart';

class TourSelectionWidget extends StatelessWidget {
  final List<ActiveTour> tours;
  final ActiveTour? selectedTour;
  final Function(ActiveTour) onTourSelected;

  const TourSelectionWidget({
    super.key,
    required this.tours,
    required this.selectedTour,
    required this.onTourSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (tours.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Không có tour nào đang hoạt động',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tour,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chọn Tour',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActiveTour>(
                value: selectedTour,
                decoration: const InputDecoration(
                  labelText: 'Tour hiện tại',
                  border: OutlineInputBorder(),
                ),
                items: tours.map((tour) {
                  return DropdownMenuItem<ActiveTour>(
                    value: tour,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tour.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${tour.tourTemplate.startLocation} → ${tour.tourTemplate.endLocation}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (tour) {
                  if (tour != null) {
                    onTourSelected(tour);
                  }
                },
              ),
              if (selectedTour != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        'Đã check-in',
                        '${selectedTour!.checkedInCount}',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        'Tổng khách',
                        '${selectedTour!.currentBookings}',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        'Còn lại',
                        '${selectedTour!.currentBookings - selectedTour!.checkedInCount}',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
      ),
    );
  }
}
