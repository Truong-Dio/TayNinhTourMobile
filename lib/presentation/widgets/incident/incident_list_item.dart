import 'package:flutter/material.dart';
import '../../../data/models/incident_model.dart';

/// Widget for displaying a single incident in a list
class IncidentListItem extends StatelessWidget {
  final TourIncident incident;
  final VoidCallback? onTap;

  const IncidentListItem({
    Key? key,
    required this.incident,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      incident.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                incident.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Severity and dates row
              Row(
                children: [
                  _buildSeverityChip(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          text: incident.formattedIncidentDate,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          icon: Icons.person,
                          text: incident.reporterName,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  if (incident.hasImages)
                    Icon(
                      Icons.image,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                ],
              ),
              
              // Admin notes preview (if available)
              if (incident.adminNotes != null && incident.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          incident.adminNotes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Resolution date (if resolved)
              if (incident.resolvedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.check_circle,
                  text: 'Đã giải quyết: ${_formatDateTime(incident.resolvedAt!)}',
                  color: Colors.green.shade600,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = Color(
      int.parse(incident.statusColor.substring(1), radix: 16) + 0xFF000000,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        incident.statusDisplay,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSeverityChip() {
    final severityColor = Color(
      int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000,
    );

    IconData severityIcon;
    switch (incident.severity.toLowerCase()) {
      case 'critical':
        severityIcon = Icons.priority_high;
        break;
      case 'high':
        severityIcon = Icons.warning;
        break;
      case 'medium':
        severityIcon = Icons.warning_amber;
        break;
      case 'low':
        severityIcon = Icons.info;
        break;
      default:
        severityIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            severityIcon,
            size: 14,
            color: severityColor,
          ),
          const SizedBox(width: 4),
          Text(
            incident.severityDisplay,
            style: TextStyle(
              color: severityColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Compact version of incident list item for use in smaller spaces
class CompactIncidentListItem extends StatelessWidget {
  final TourIncident incident;
  final VoidCallback? onTap;

  const CompactIncidentListItem({
    Key? key,
    required this.incident,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(
      int.parse(incident.statusColor.substring(1), radix: 16) + 0xFF000000,
    );
    final severityColor = Color(
      int.parse(incident.severityColor.substring(1), radix: 16) + 0xFF000000,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Severity indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.formattedIncidentDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  incident.statusDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
