import 'package:flutter/material.dart';
import '../../../domain/entities/active_tour.dart';

class TourSelectionTimelineWidget extends StatelessWidget {
  final List<ActiveTour> tours;
  final ActiveTour? selectedTour;
  final Function(ActiveTour) onTourSelected;

  const TourSelectionTimelineWidget({
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
                    Icons.timeline,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch trình Tour',
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
                  labelText: 'Chọn tour',
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
            ],
          ),
        ),
      ),
    );
  }
}
