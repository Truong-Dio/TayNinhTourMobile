import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tour_guide_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../domain/entities/active_tour.dart';

class GuestNotificationPage extends StatefulWidget {
  final String? tourId;
  
  const GuestNotificationPage({super.key, this.tourId});

  @override
  State<GuestNotificationPage> createState() => _GuestNotificationPageState();
}

class _GuestNotificationPageState extends State<GuestNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  ActiveTour? _selectedTour;
  bool _isUrgent = false;
  bool _isSending = false;

  final List<Map<String, String>> _messageTemplates = [
    {
      'title': '🚌 Bắt đầu tour',
      'message': 'Chào mừng quý khách! Tour đã chính thức bắt đầu. Chúc quý khách có những trải nghiệm tuyệt vời!',
    },
    {
      'title': '📍 Đến điểm tham quan',
      'message': 'Chúng ta đã đến [Tên địa điểm]. Quý khách vui lòng tập trung và làm theo hướng dẫn của HDV.',
    },
    {
      'title': '☕ Nghỉ giải lao',
      'message': 'Chúng ta sẽ nghỉ giải lao 15 phút tại đây. Quý khách vui lòng có mặt đúng giờ để tiếp tục hành trình.',
    },
    {
      'title': '🍽️ Thời gian ăn uống',
      'message': 'Đã đến giờ ăn [bữa sáng/trưa/tối]. Quý khách vui lòng tập trung tại nhà hàng để cùng dùng bữa.',
    },
    {
      'title': '⚠️ Thay đổi lịch trình',
      'message': 'Có thay đổi nhỏ trong lịch trình. HDV sẽ thông báo chi tiết. Cảm ơn quý khách đã thông cảm.',
    },
    {
      'title': '🚨 Thông báo khẩn cấp',
      'message': 'Thông báo quan trọng: [Nội dung khẩn cấp]. Quý khách vui lòng làm theo hướng dẫn của HDV.',
    },
    {
      'title': '📸 Chụp ảnh lưu niệm',
      'message': 'Đây là địa điểm chụp ảnh đẹp! Quý khách có thể chụp ảnh lưu niệm tại đây trong 10 phút.',
    },
    {
      'title': '🏁 Kết thúc tour',
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

    // Auto-select tour based on provided tourId or first available
    if (widget.tourId != null && tourGuideProvider.activeTours.isNotEmpty) {
      try {
        final tour = tourGuideProvider.activeTours.firstWhere(
          (t) => t.id == widget.tourId,
        );
        setState(() {
          _selectedTour = tour;
        });
      } catch (e) {
        // If tour with specific ID not found, select first available
        setState(() {
          _selectedTour = tourGuideProvider.activeTours.first;
        });
      }
    } else if (tourGuideProvider.activeTours.isNotEmpty) {
      setState(() {
        _selectedTour = tourGuideProvider.activeTours.first;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadActiveTours();
  }



  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate() || _selectedTour == null) {
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
        _showMessage('Thông báo đã được gửi thành công!');
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

  Widget _buildMessageTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mẫu tin nhắn',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _messageTemplates.length,
            itemBuilder: (context, index) {
              final template = _messageTemplates[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      _messageController.text = template['message']!;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template['title']!,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              template['message']!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Chạm để sử dụng',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
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
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo khách hàng'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TourGuideProvider>(
        builder: (context, tourGuideProvider, child) {
          return LoadingOverlay(
            isLoading: tourGuideProvider.isLoading || _isSending,
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Urgent checkbox
                    CheckboxListTile(
                      value: _isUrgent,
                      onChanged: (value) {
                        setState(() {
                          _isUrgent = value ?? false;
                        });
                      },
                      title: const Text('Thông báo khẩn cấp'),
                      subtitle: const Text('Gửi ngay lập tức và hiển thị nổi bật'),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
