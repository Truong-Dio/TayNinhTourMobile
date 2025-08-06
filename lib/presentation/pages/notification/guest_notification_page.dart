import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../domain/entities/active_tour.dart';

class GuestNotificationPage extends StatefulWidget {
  const GuestNotificationPage({super.key});

  @override
  State<GuestNotificationPage> createState() => _GuestNotificationPageState();
}

class _GuestNotificationPageState extends State<GuestNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  ActiveTour? _selectedTour;
  bool _isUrgent = false;
  bool _isSending = false;
  String? _selectedTemplate;

  final List<Map<String, String>> _messageTemplates = [
    {
      'title': 'Bắt đầu tour',
      'message': 'Chào mừng quý khách! Tour đã chính thức bắt đầu. Chúc quý khách có những trải nghiệm tuyệt vời!',
    },
    {
      'title': 'Đến điểm tham quan',
      'message': 'Chúng ta đã đến [Tên địa điểm]. Quý khách vui lòng tập trung và làm theo hướng dẫn của HDV.',
    },
    {
      'title': 'Nghỉ giải lao',
      'message': 'Chúng ta sẽ nghỉ giải lao 15 phút tại đây. Quý khách vui lòng có mặt đúng giờ để tiếp tục hành trình.',
    },
    {
      'title': 'Thay đổi lịch trình',
      'message': 'Có thay đổi nhỏ trong lịch trình. HDV sẽ thông báo chi tiết. Cảm ơn quý khách đã thông cảm.',
    },
    {
      'title': 'Kết thúc tour',
      'message': 'Tour đã kết thúc. Cảm ơn quý khách đã tham gia. Chúc quý khách về nhà an toàn!',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveTours();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  void _selectTemplate(String template) {
    setState(() {
      _selectedTemplate = template;
      _messageController.text = template;
    });
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTour == null) {
      _showMessage('Vui lòng chọn tour', isError: true);
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final tourGuideProvider = context.read<TourGuideProvider>();
      final success = await tourGuideProvider.notifyGuests(
        _selectedTour!.id,
        _messageController.text.trim(),
        isUrgent: _isUrgent,
      );

      if (success) {
        _showMessage('Gửi thông báo thành công');
        _resetForm();
      } else {
        _showMessage(
          tourGuideProvider.errorMessage ?? 'Không thể gửi thông báo',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage('Có lỗi xảy ra: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _resetForm() {
    _messageController.clear();
    setState(() {
      _isUrgent = false;
      _selectedTemplate = null;
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
        title: const Text('Thông báo Khách hàng'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isSending,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Thông báo sẽ được gửi đến tất cả khách hàng trong tour',
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

                    // Message templates
                    _buildMessageTemplates(),

                    const SizedBox(height: 16),

                    // Message field
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Nội dung thông báo *',
                        hintText: 'Nhập nội dung thông báo cho khách hàng...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập nội dung thông báo';
                        }
                        if (value.trim().length < 5) {
                          return 'Nội dung phải có ít nhất 5 ký tự';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Urgent checkbox
                    CheckboxListTile(
                      title: const Text('Thông báo khẩn cấp'),
                      subtitle: const Text('Thông báo sẽ được ưu tiên hiển thị'),
                      value: _isUrgent,
                      onChanged: (value) {
                        setState(() {
                          _isUrgent = value ?? false;
                        });
                      },
                      activeColor: Colors.red,
                    ),

                    const SizedBox(height: 24),

                    // Send button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendNotification,
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isSending ? 'Đang gửi...' : 'Gửi thông báo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isUrgent ? Colors.red : Colors.orange,
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
                    Text(
                      'Khách hàng: ${tour.currentBookings}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
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

  Widget _buildMessageTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mẫu thông báo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _messageTemplates.length,
            itemBuilder: (context, index) {
              final template = _messageTemplates[index];
              final isSelected = _selectedTemplate == template['message'];

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? Colors.orange[50] : Colors.white,
                  child: InkWell(
                    onTap: () => _selectTemplate(template['message']!),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.orange[700] : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              template['message']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.orange[600] : Colors.grey[600],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.orange[700],
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
