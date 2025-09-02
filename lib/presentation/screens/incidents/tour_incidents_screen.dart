import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/incident/incident_bloc.dart';
import '../../widgets/incident/incident_list_item.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../../data/models/incident_model.dart';

/// Screen for displaying tour incidents
class TourIncidentsScreen extends StatefulWidget {
  final String tourSlotId;
  final String? tourName;

  const TourIncidentsScreen({
    Key? key,
    required this.tourSlotId,
    this.tourName,
  }) : super(key: key);

  @override
  State<TourIncidentsScreen> createState() => _TourIncidentsScreenState();
}

class _TourIncidentsScreenState extends State<TourIncidentsScreen> {
  final ScrollController _scrollController = ScrollController();
  late IncidentBloc _incidentBloc;

  @override
  void initState() {
    super.initState();
    _incidentBloc = context.read<IncidentBloc>();
    _scrollController.addListener(_onScroll);
    
    // Load initial incidents
    _incidentBloc.add(LoadTourIncidents(
      tourSlotId: widget.tourSlotId,
      refresh: true,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when scrolled to 80% of the list
      _incidentBloc.add(LoadMoreIncidents(tourSlotId: widget.tourSlotId));
    }
  }

  void _onRefresh() {
    _incidentBloc.add(LoadTourIncidents(
      tourSlotId: widget.tourSlotId,
      refresh: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sự cố tour',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.tourName != null)
              Text(
                widget.tourName!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: BlocBuilder<IncidentBloc, IncidentState>(
        builder: (context, state) {
          if (state is IncidentLoading && state.incidents.isEmpty) {
            return const LoadingWidget(message: 'Đang tải danh sách sự cố...');
          }

          if (state is IncidentError && state.incidents.isEmpty) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: _onRefresh,
            );
          }

          if (state is IncidentLoaded && state.incidents.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: 'Không có sự cố nào',
              message: 'Tour này chưa có sự cố nào được báo cáo.',
              iconColor: Colors.green,
            );
          }

          final incidents = state.incidents;
          final isLoading = state is IncidentLoading;
          final hasError = state is IncidentError;

          return RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: Column(
              children: [
                // Statistics header
                if (incidents.isNotEmpty) _buildStatsHeader(incidents),
                
                // Incidents list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: incidents.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= incidents.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final incident = incidents[index];
                      return IncidentListItem(
                        incident: incident,
                        onTap: () => _showIncidentDetails(incident),
                      );
                    },
                  ),
                ),

                // Error message at bottom
                if (hasError && incidents.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.shade50,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (state as IncidentError).message,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _incidentBloc.add(
                            LoadMoreIncidents(tourSlotId: widget.tourSlotId),
                          ),
                          child: const Text('Thử lại'),
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

  Widget _buildStatsHeader(List<TourIncident> incidents) {
    final total = incidents.length;
    final unresolved = incidents.where((i) => !i.isResolved).length;
    final critical = incidents.where((i) => i.isCritical).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.list_alt,
            label: 'Tổng số',
            value: total.toString(),
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.warning_amber,
            label: 'Chưa giải quyết',
            value: unresolved.toString(),
            color: Colors.orange,
          ),
          const SizedBox(width: 16),
          _buildStatItem(
            icon: Icons.priority_high,
            label: 'Nghiêm trọng',
            value: critical.toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
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
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              incident.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Severity
                      Row(
                        children: [
                          Icon(
                            incident.isCritical ? Icons.priority_high : Icons.warning_amber,
                            color: Color(int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mức độ: ${incident.severityDisplay}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      const Text(
                        'Mô tả:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        incident.description,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Dates and reporter
                      _buildDetailRow('Ngày xảy ra:', incident.formattedIncidentDate),
                      _buildDetailRow('Ngày báo cáo:', incident.formattedReportedDate),
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
                      
                      if (incident.resolvedAt != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Ngày giải quyết:',
                          '${incident.resolvedAt!.day.toString().padLeft(2, '0')}/${incident.resolvedAt!.month.toString().padLeft(2, '0')}/${incident.resolvedAt!.year} ${incident.resolvedAt!.hour.toString().padLeft(2, '0')}:${incident.resolvedAt!.minute.toString().padLeft(2, '0')}',
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
}
