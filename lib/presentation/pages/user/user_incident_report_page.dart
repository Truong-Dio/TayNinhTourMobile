import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../core/theme/app_theme.dart';

class UserIncidentReportPage extends StatefulWidget {
  final String tourOperationId;
  final String tourTitle;

  const UserIncidentReportPage({
    super.key,
    required this.tourOperationId,
    required this.tourTitle,
  });

  @override
  State<UserIncidentReportPage> createState() => _UserIncidentReportPageState();
}

class _UserIncidentReportPageState extends State<UserIncidentReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'TourIssue';
  bool _isSubmitting = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _categories = [
    'TourIssue',
    'SafetyIssue', 
    'GuideIssue',
    'TransportIssue',
    'AccommodationIssue',
    'Other'
  ];

  final Map<String, String> _categoryNames = {
    'TourIssue': 'Vấn đề tour',
    'SafetyIssue': 'Vấn đề an toàn',
    'GuideIssue': 'Vấn đề hướng dẫn viên',
    'TransportIssue': 'Vấn đề di chuyển',
    'AccommodationIssue': 'Vấn đề lưu trú',
    'Other': 'Khác'
  };

  final Map<String, String> _priorityNames = {
    'Low': 'Thấp',
    'Medium': 'Trung bình',
    'High': 'Cao',
    'Critical': 'Khẩn cấp'
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      
      final success = await userProvider.reportIncident(
        tourOperationId: widget.tourOperationId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategory,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Báo cáo sự cố đã được gửi thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi gửi báo cáo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Báo cáo sự cố',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.red.withOpacity(0.3),
      ),
      body: _isSubmitting
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTourInfoCard(),
                    const SizedBox(height: 20),
                    _buildReportForm(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTourInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tour,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin tour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.tourTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${widget.tourOperationId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: Colors.red.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Chi tiết sự cố',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: 'Tiêu đề sự cố',
              hint: 'Mô tả ngắn gọn về sự cố',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề sự cố';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Loại sự cố',
              value: _selectedCategory,
              items: _categories,
              itemNames: _categoryNames,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Mức độ ưu tiên',
              value: _selectedPriority,
              items: _priorities,
              itemNames: _priorityNames,
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Địa điểm xảy ra sự cố',
              hint: 'Vị trí cụ thể nơi xảy ra sự cố',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Mô tả chi tiết',
              hint: 'Mô tả chi tiết về sự cố, nguyên nhân, tác động...',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng mô tả chi tiết về sự cố';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Map<String, String> itemNames,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(itemNames[item] ?? item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
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
            : const Text(
                'Gửi báo cáo sự cố',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
