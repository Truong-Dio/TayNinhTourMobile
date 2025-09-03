import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/services/incident_service.dart';
import '../../blocs/incident/incident_bloc.dart';

/// Form widget for reporting incidents (TourGuide only)
class IncidentReportForm extends StatefulWidget {
  final String tourSlotId;
  final String? tourName;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const IncidentReportForm({
    Key? key,
    required this.tourSlotId,
    this.tourName,
    this.onSuccess,
    this.onCancel,
  }) : super(key: key);

  @override
  State<IncidentReportForm> createState() => _IncidentReportFormState();
}

class _IncidentReportFormState extends State<IncidentReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedSeverity = 'Medium';
  final List<String> _severityOptions = ['Low', 'Medium', 'High', 'Critical'];
  final Map<String, String> _severityDisplayNames = {
    'Low': 'Thấp',
    'Medium': 'Trung bình',
    'High': 'Cao',
    'Critical': 'Nghiêm trọng',
  };

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IncidentBloc, IncidentState>(
      listener: (context, state) {
        if (state is IncidentReportSuccess) {
          setState(() {
            _isSubmitting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Báo cáo sự cố thành công'),
              backgroundColor: Colors.green,
            ),
          );
          
          widget.onSuccess?.call();
        } else if (state is IncidentError) {
          setState(() {
            _isSubmitting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.report_problem, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Báo cáo sự cố',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.onCancel != null)
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
                
                if (widget.tourName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tour: ${widget.tourName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                      maxLines: 1,                // chỉ hiển thị 1 dòng
                      overflow: TextOverflow.ellipsis
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề sự cố *',
                    hintText: 'Nhập tiêu đề ngắn gọn về sự cố',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tiêu đề sự cố';
                    }
                    if (value.trim().length < 5) {
                      return 'Tiêu đề phải có ít nhất 5 ký tự';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),
                
                const SizedBox(height: 16),
                
                // Severity dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Mức độ nghiêm trọng *',
                    border: OutlineInputBorder(),
                  ),
                  items: _severityOptions.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Row(
                        children: [
                          _getSeverityIcon(severity),
                          const SizedBox(width: 8),
                          Text(_severityDisplayNames[severity] ?? severity),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSeverity = value;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả chi tiết *',
                    hintText: 'Mô tả chi tiết về sự cố, nguyên nhân và tác động',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng mô tả chi tiết về sự cố';
                    }
                    if (value.trim().length < 10) {
                      return 'Mô tả phải có ít nhất 10 ký tự';
                    }
                    return null;
                  },
                  maxLength: 500,
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    if (widget.onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : widget.onCancel,
                          child: const Text('Hủy'),
                        ),
                      ),
                    if (widget.onCancel != null) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Báo cáo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSeverityIcon(String severity) {
    switch (severity) {
      case 'Low':
        return const Icon(Icons.info, color: Colors.blue, size: 20);
      case 'Medium':
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
      case 'High':
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case 'Critical':
        return const Icon(Icons.dangerous, color: Colors.red, size: 20);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 20);
    }
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final request = ReportIncidentRequest(
      tourSlotId: widget.tourSlotId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      severity: _selectedSeverity,
    );

    context.read<IncidentBloc>().add(ReportIncidentEvent(request));
  }
}
