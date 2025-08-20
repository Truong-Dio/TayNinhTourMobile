import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'user_dashboard_page.dart';
import 'my_tours_page.dart';
import 'my_feedbacks_page.dart';
import '../profile/profile_page.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const UserDashboardPage(),
    const MyToursPage(),
    const MyFeedbacksPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Trang chủ',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.tour),
      label: 'Tours',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.rate_review),
      label: 'Đánh giá',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Tài khoản',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Ensure user has correct role
        if (authProvider.user?.role != AppConstants.userRole) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn không có quyền truy cập trang này',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authProvider.logout(),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 8,
            items: _bottomNavItems,
          ),
        );
      },
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
