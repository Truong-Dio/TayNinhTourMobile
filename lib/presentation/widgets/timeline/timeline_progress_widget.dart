import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/timeline_item.dart';
import '../../../domain/entities/active_tour.dart';

class TimelineProgressWidget extends StatelessWidget {
  final List<TimelineItem> timelineItems;
  final ActiveTour? selectedTour;
  final Function(TimelineItem) onCompleteItem;

  const TimelineProgressWidget({
    super.key,
    required this.timelineItems,
    required this.selectedTour,
    required this.onCompleteItem,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTour == null) {
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

    if (timelineItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có lịch trình nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lịch trình sẽ được hiển thị khi tour bắt đầu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Progress Summary
        _buildProgressSummary(),
        
        // Timeline List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: timelineItems.length,
            itemBuilder: (context, index) {
              final item = timelineItems[index];
              final isLast = index == timelineItems.length - 1;
              return _buildTimelineItem(context, item, index, isLast);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSummary() {
    final completedCount = timelineItems.where((item) => item.isCompleted).length;
    final totalCount = timelineItems.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ lịch trình',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% hoàn thành',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, TimelineItem item, int index, bool isLast) {
    final isCompleted = item.isCompleted;
    final canComplete = _canCompleteItem(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : (canComplete ? Colors.blue : Colors.grey[300]),
                  border: Border.all(
                    color: isCompleted ? Colors.green : (canComplete ? Colors.blue : Colors.grey),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.schedule,
                  color: isCompleted ? Colors.white : (canComplete ? Colors.white : Colors.grey),
                  size: 20,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Timeline content
          Expanded(
            child: Card(
              elevation: isCompleted ? 1 : 2,
              color: isCompleted ? Colors.grey[50] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.checkInTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey[600] : Colors.blue[700],
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Hoàn thành',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Activity
                    Text(
                      item.activity,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    
                    // Specialty shop info
                    if (item.specialtyShop != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.specialtyShop!.shopName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.specialtyShop!.address,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                              ),
                            ),
                            if (item.specialtyShop!.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.specialtyShop!.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    // Completion info
                    if (isCompleted && item.completedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Hoàn thành lúc: ${DateFormat('HH:mm dd/MM/yyyy').format(item.completedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                      if (item.completionNotes != null)
                        Text(
                          'Ghi chú: ${item.completionNotes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                    
                    // Complete button
                    if (!isCompleted && canComplete) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => onCompleteItem(item),
                          icon: const Icon(Icons.check),
                          label: const Text('Hoàn thành'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    
                    // Cannot complete message
                    if (!isCompleted && !canComplete) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cần hoàn thành các mục trước đó',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCompleteItem(int index) {
    // Can complete if all previous items are completed
    for (int i = 0; i < index; i++) {
      if (!timelineItems[i].isCompleted) {
        return false;
      }
    }
    return true;
  }
}
