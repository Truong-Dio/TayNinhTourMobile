import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../domain/entities/active_tour.dart';
import '../../../core/constants/app_constants.dart';

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ActiveTour? _selectedTour;
  String _selectedSeverity = 'Medium';
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveTours();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveTours() async {
    final tourGuideProvider = context.read<TourGuideProvider>();
    await tourGuideProvider.getMyActiveTours();

    // Auto-select first tour if available
    if (tourGuideProvider.activeTours.isNotEmpty) {
      setState(() {
        _selectedTour = tourGuideProvider.activeTours.first;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize > AppConstants.maxImageSize) {
          _showMessage('Kích thước ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB.', isError: true);
          return;
        }

        setState(() {
          _selectedImages.add(file);
        });
      }
    } catch (e) {
      _showMessage('Không thể chọn ảnh: ${e.toString()}', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTour == null) {
      _showMessage('Vui lòng chọn tour', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Upload images first and get URLs
      List<String>? imageUrls;
      if (_selectedImages.isNotEmpty) {
        // For now, we'll use placeholder URLs
        // In real implementation, upload images to server first
        imageUrls = _selectedImages.map((file) => 'placeholder_url_${file.path}').toList();
      }

      final tourGuideProvider = context.read<TourGuideProvider>();
      final success = await tourGuideProvider.reportIncident(
        tourOperationId: _selectedTour!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        severity: _selectedSeverity,
        imageUrls: imageUrls,
      );

      if (success) {
        _showMessage('Báo cáo sự cố thành công');
        _resetForm();
      } else {
        _showMessage(
          tourGuideProvider.errorMessage ?? 'Không thể gửi báo cáo sự cố',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage('Có lỗi xảy ra: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedSeverity = 'Medium';
      _selectedImages.clear();
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo Sự cố'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isSubmitting,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Báo cáo sự cố khẩn cấp sẽ được gửi ngay đến quản lý',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tour selection
                    _buildTourSelection(tourGuideProvider),

                    const SizedBox(height: 16),

                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề sự cố *',
                        hintText: 'Mô tả ngắn gọn về sự cố',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tiêu đề sự cố';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Severity selection
                    _buildSeveritySelection(),

                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả chi tiết *',
                        hintText: 'Mô tả chi tiết về sự cố, nguyên nhân, tình hình hiện tại...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng mô tả chi tiết sự cố';
                        }
                        if (value.trim().length < 10) {
                          return 'Mô tả phải có ít nhất 10 ký tự';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Image selection
                    _buildImageSelection(),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitReport,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi báo cáo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourSelection(TourGuideProvider tourGuideProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tour hiện tại',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (tourGuideProvider.activeTours.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Không có tour nào đang hoạt động'),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<ActiveTour>(
            value: _selectedTour,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: tourGuideProvider.activeTours.map((tour) {
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
              setState(() {
                _selectedTour = tour;
              });
            },
          ),
      ],
    );
  }

  Widget _buildSeveritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mức độ nghiêm trọng',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AppConstants.incidentSeverityLevels.map((severity) {
            final isSelected = _selectedSeverity == severity;
            Color color;
            switch (severity) {
              case 'Low':
                color = Colors.green;
                break;
              case 'Medium':
                color = Colors.orange;
                break;
              case 'High':
                color = Colors.red;
                break;
              case 'Critical':
                color = Colors.purple;
                break;
              default:
                color = Colors.grey;
            }

            return FilterChip(
              label: Text(severity),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSeverity = severity;
                });
              },
              selectedColor: color.withOpacity(0.2),
              checkmarkColor: color,
              side: BorderSide(color: color),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh minh họa',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Add image buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Thư viện'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Selected images
        if (_selectedImages.isNotEmpty) ...[
          Text(
            'Ảnh đã chọn (${_selectedImages.length})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                final image = _selectedImages[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Thêm hình ảnh để minh họa sự cố (không bắt buộc)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
