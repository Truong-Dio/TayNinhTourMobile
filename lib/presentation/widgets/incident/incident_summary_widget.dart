import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/incident/incident_bloc.dart';
import '../../screens/incidents/tour_incidents_screen.dart';
import '../../../data/models/incident_model.dart';
import 'incident_list_item.dart';

/// Widget that shows a summary of incidents for a tour slot
/// Can be embedded in tour booking details or tour information screens
class IncidentSummaryWidget extends StatefulWidget {
  final String tourSlotId;
  final String? tourName;
  final bool showFullList;
  final int maxItemsToShow;

  const IncidentSummaryWidget({
    Key? key,
    required this.tourSlotId,
    this.tourName,
    this.showFullList = false,
    this.maxItemsToShow = 3,
  }) : super(key: key);

  @override
  State<IncidentSummaryWidget> createState() => _IncidentSummaryWidgetState();
}

class _IncidentSummaryWidgetState extends State<IncidentSummaryWidget> {
  late IncidentBloc _incidentBloc;

  @override
  void initState() {
    super.initState();
    _incidentBloc = context.read<IncidentBloc>();
    _loadIncidents();
  }

  void _loadIncidents() {
    _incidentBloc.add(LoadTourIncidents(
      tourSlotId: widget.tourSlotId,
      refresh: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentBloc, IncidentState>(
      builder: (context, state) {
        if (state is IncidentLoading && state.incidents.isEmpty) {
          return _buildLoadingWidget();
        }

        if (state is IncidentError && state.incidents.isEmpty) {
          // Nếu lỗi 404 (không tìm thấy sự cố), ẩn hoàn toàn widget
          if (state.message.contains('404') ||
              state.message.contains('Không tìm thấy') ||
              state.message.contains('không có quyền')) {
            return const SizedBox.shrink();
          }
          return _buildErrorWidget(state.message);
        }

        if (state.incidents.isEmpty) {
          // Ẩn hoàn toàn nếu không có sự cố thay vì hiển thị "Không có sự cố"
          return const SizedBox.shrink();
        }

        return _buildIncidentsList(state.incidents);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Đang kiểm tra thông tin sự cố...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Lỗi tải thông tin sự cố',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadIncidents,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoIncidentsWidget() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Không có sự cố',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Tour này hiện tại không có sự cố nào được báo cáo.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentsList(List<TourIncident> incidents) {
    final unresolvedIncidents = incidents.where((i) => !i.isResolved).toList();
    final criticalIncidents = incidents.where((i) => i.isCritical).toList();
    final displayIncidents = widget.showFullList 
        ? incidents 
        : incidents.take(widget.maxItemsToShow).toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with statistics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      unresolvedIncidents.isNotEmpty 
                          ? Icons.warning_amber 
                          : Icons.info_outline,
                      color: unresolvedIncidents.isNotEmpty 
                          ? Colors.orange.shade600 
                          : Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin sự cố',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStatisticsRow(incidents, unresolvedIncidents, criticalIncidents),
              ],
            ),
          ),

          const Divider(height: 1),

          // Incidents list
          ...displayIncidents.map((incident) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CompactIncidentListItem(
              incident: incident,
              onTap: () => _showIncidentDetails(incident),
            ),
          )),

          // View all button
          if (!widget.showFullList && incidents.length > widget.maxItemsToShow)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _navigateToFullList,
                  icon: const Icon(Icons.list),
                  label: Text('Xem tất cả (${incidents.length} sự cố)'),
                ),
              ),
            ),

          // Refresh button
          if (widget.showFullList)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _loadIncidents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(
    List<TourIncident> allIncidents,
    List<TourIncident> unresolvedIncidents,
    List<TourIncident> criticalIncidents,
  ) {
    return Row(
      children: [
        _buildStatChip(
          label: 'Tổng số',
          value: allIncidents.length.toString(),
          color: Colors.blue,
          icon: Icons.list_alt,
        ),
        const SizedBox(width: 8),
        if (unresolvedIncidents.isNotEmpty)
          _buildStatChip(
            label: 'Chưa giải quyết',
            value: unresolvedIncidents.length.toString(),
            color: Colors.orange,
            icon: Icons.pending,
          ),
        const SizedBox(width: 8),
        if (criticalIncidents.isNotEmpty)
          _buildStatChip(
            label: 'Nghiêm trọng',
            value: criticalIncidents.length.toString(),
            color: Colors.red,
            icon: Icons.priority_high,
          ),
      ],
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showIncidentDetails(TourIncident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildIncidentDetailsModal(incident),
    );
  }

  Widget _buildIncidentDetailsModal(TourIncident incident) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and status
                      Text(
                        incident.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status and severity
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(incident.statusColor.substring(1), radix: 16) + 0xFF000000),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              incident.statusDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              incident.severityDisplay,
                              style: TextStyle(
                                color: Color(int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        incident.description,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Details
                      _buildDetailRow('Ngày xảy ra:', incident.formattedIncidentDate),
                      _buildDetailRow('Người báo cáo:', incident.reporterName),
                      
                      if (incident.adminNotes != null && incident.adminNotes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Ghi chú từ quản trị viên:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            incident.adminNotes!,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFullList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TourIncidentsScreen(
          tourSlotId: widget.tourSlotId,
          tourName: widget.tourName,
        ),
      ),
    );
  }
}
