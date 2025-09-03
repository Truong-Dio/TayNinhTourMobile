import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/auth_state_notifier.dart';
import '../../../core/utils/auth_test_utils.dart';
import '../../providers/auth_provider.dart';

class AuthDebugPage extends StatefulWidget {
  const AuthDebugPage({super.key});

  @override
  State<AuthDebugPage> createState() => _AuthDebugPageState();
}

class _AuthDebugPageState extends State<AuthDebugPage> {
  String _status = 'Ready';
  bool _hasTokens = false;
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final hasTokens = await AuthTestUtils.hasValidTokens();
    final token = await AuthTestUtils.getCurrentToken();
    
    setState(() {
      _hasTokens = hasTokens;
      _currentToken = token;
      _status = hasTokens ? 'Has valid tokens' : 'No tokens found';
    });
  }

  Future<void> _clearTokens() async {
    setState(() {
      _status = 'Clearing tokens...';
    });

    await AuthTestUtils.clearAllTokens();
    
    setState(() {
      _status = 'Tokens cleared';
      _hasTokens = false;
      _currentToken = null;
    });

    // Notify auth state change
    AuthStateNotifier().notifyTokenExpired();
  }

  Future<void> _simulateTokenExpiry() async {
    setState(() {
      _status = 'Simulating token expiry...';
    });

    // Clear tokens and notify
    await AuthTestUtils.clearAllTokens();
    AuthStateNotifier().notifyTokenExpired();
    
    setState(() {
      _status = 'Token expiry simulated';
      _hasTokens = false;
      _currentToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_status'),
                    Text('Has Tokens: $_hasTokens'),
                    if (_currentToken != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Token: ${_currentToken!.substring(0, 50)}...',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provider Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Is Authenticated: ${authProvider.isAuthenticated}'),
                            Text('User: ${authProvider.user?.name ?? 'None'}'),
                            Text('Role: ${authProvider.user?.role ?? 'None'}'),
                            if (authProvider.errorMessage != null)
                              Text(
                                'Error: ${authProvider.errorMessage}',
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkAuthStatus,
                        child: const Text('Refresh Status'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _clearTokens,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear Tokens'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _simulateTokenExpiry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Simulate Token Expiry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
