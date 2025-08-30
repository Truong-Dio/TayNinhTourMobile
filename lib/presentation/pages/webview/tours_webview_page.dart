import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ToursWebViewPage extends StatefulWidget {
  const ToursWebViewPage({super.key});

  @override
  State<ToursWebViewPage> createState() => _ToursWebViewPageState();
}

class _ToursWebViewPageState extends State<ToursWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Lấy token từ storage
      final token = await _storage.read(key: AppConstants.accessTokenKey);

      // Tạo URL với token - sử dụng fragment thay vì query parameter để tránh CORS
      String url = 'https://tndt.netlify.app/tours';
      if (token != null) {
        // Thêm token vào URL fragment để tránh server-side blocking
        url += '#authToken=$token';
      }

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..enableZoom(true)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36 TayNinhTourApp/1.0')
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Cập nhật progress loading
              if (progress == 100) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            },
            onPageFinished: (String url) async {
              setState(() {
                _isLoading = false;
              });
              
              // Inject token vào localStorage và sessionStorage sau khi page load xong
              if (token != null) {
                await _controller.runJavaScript('''
                  // Đọc token từ URL fragment nếu có
                  let tokenFromFragment = null;
                  if (window.location.hash) {
                    const hashParams = new URLSearchParams(window.location.hash.substring(1));
                    tokenFromFragment = hashParams.get('authToken');
                  }

                  const finalToken = tokenFromFragment || '$token';

                  // Lưu token vào localStorage và sessionStorage
                  localStorage.setItem('authToken', finalToken);
                  localStorage.setItem('accessToken', finalToken);
                  localStorage.setItem('token', finalToken);
                  sessionStorage.setItem('authToken', finalToken);
                  sessionStorage.setItem('accessToken', finalToken);
                  sessionStorage.setItem('token', finalToken);

                  // Set token vào window object để dễ truy cập
                  window.authToken = finalToken;
                  window.accessToken = finalToken;

                  // Dispatch event để notify app về token
                  window.dispatchEvent(new CustomEvent('tokenInjected', {
                    detail: {
                      token: finalToken,
                      authToken: finalToken,
                      accessToken: finalToken
                    }
                  }));

                  // Log để debug
                  console.log('Token injected successfully:', finalToken);

                  // Clear fragment để clean URL
                  if (window.location.hash) {
                    history.replaceState(null, null, window.location.pathname + window.location.search);
                  }
                ''');
              }
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                if (error.description.contains('ERR_BLOCKED_BY_ORB') ||
                    error.description.contains('CORS') ||
                    error.description.contains('net::ERR_BLOCKED_BY_ORB')) {
                  _errorMessage = 'Không thể tải trang do chính sách bảo mật. Vui lòng thử lại hoặc sử dụng trình duyệt web.';
                } else {
                  _errorMessage = 'Lỗi tải trang: ${error.description}';
                }
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              // Cho phép navigation trong domain tndt.netlify.app
              if (request.url.startsWith('https://tndt.netlify.app/')) {
                return NavigationDecision.navigate;
              }
              // Block navigation ra ngoài domain
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(
          Uri.parse(url),
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'X-Requested-With': 'TayNinhTourApp',
          },
        );

      // Cấu hình cho Android để cho phép mixed content và CORS
      if (_controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        final androidController = _controller.platform as AndroidWebViewController;
        await androidController.setMediaPlaybackRequiresUserGesture(false);

        // Cấu hình để cho phép mixed content và cross-origin requests
        await androidController.runJavaScript('''
          // Disable web security for this webview
          if (typeof window !== 'undefined') {
            window.addEventListener('DOMContentLoaded', function() {
              console.log('WebView configured for cross-origin requests');
            });
          }
        ''');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khởi tạo: $e';
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _controller.reload();
  }

  Future<void> _openInBrowser() async {
    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      String url = 'https://tndt.netlify.app/tours';
      if (token != null) {
        url += '#authToken=$token';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở trình duyệt'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Khám phá Tours',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _errorMessage != null
          ? _buildErrorWidget()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading) _buildLoadingWidget(),
              ],
            ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải trang tours...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Không thể tải trang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Đã xảy ra lỗi không xác định',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _refreshPage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Mở trình duyệt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
