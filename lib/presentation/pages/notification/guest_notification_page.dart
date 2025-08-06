import 'package:flutter/material.dart';

class GuestNotificationPage extends StatefulWidget {
  const GuestNotificationPage({super.key});

  @override
  State<GuestNotificationPage> createState() => _GuestNotificationPageState();
}

class _GuestNotificationPageState extends State<GuestNotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo Khách hàng'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Guest Notification Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Form gửi thông báo cho khách hàng\nsẽ được implement ở đây',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
