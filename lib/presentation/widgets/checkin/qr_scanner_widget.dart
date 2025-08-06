import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../domain/entities/active_tour.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final ActiveTour? selectedTour;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
    required this.selectedTour,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _hasPermission = false;
  bool _isScanning = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isScanning && scanData.code != null && scanData.code != _lastScannedCode) {
        _handleQRScanned(scanData.code!);
      }
    });
  }

  Future<void> _handleQRScanned(String code) async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _lastScannedCode = code;
    });

    // Pause scanning temporarily
    await controller?.pauseCamera();

    try {
      await widget.onQRScanned(code);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Resume scanning after delay
    await Future.delayed(const Duration(seconds: 2));
    await controller?.resumeCamera();
    
    setState(() {
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedTour == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tour,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Vui lòng chọn tour trước',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cần quyền truy cập camera',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Để quét QR code, ứng dụng cần quyền sử dụng camera',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkCameraPermission,
              child: const Text('Cấp quyền'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hướng camera về phía QR code của khách hàng để check-in',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // QR Scanner
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              overflow: Overflow.hidden,
            ),
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Theme.of(context).primaryColor,
                    borderRadius: 12,
                    borderLength: 30,
                    borderWidth: 8,
                    cutOutSize: 250,
                  ),
                ),
                
                // Scanning indicator
                if (_isScanning)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang xử lý...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await controller?.toggleFlash();
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Flash'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await controller?.flipCamera();
                },
                icon: const Icon(Icons.flip_camera_ios),
                label: const Text('Lật camera'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
