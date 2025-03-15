// lib/features/missions/screens/barcode_mission_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class BarcodeMissionScreen extends StatefulWidget {
  final Map<String, dynamic> missionSettings;
  final VoidCallback onMissionComplete;

  const BarcodeMissionScreen({
    Key? key,
    required this.missionSettings,
    required this.onMissionComplete,
  }) : super(key: key);

  @override
  _BarcodeMissionScreenState createState() => _BarcodeMissionScreenState();
}

class _BarcodeMissionScreenState extends State<BarcodeMissionScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  String _targetDescription = '';
  String? _targetBarcode;

  @override
  void initState() {
    super.initState();
    _targetDescription = widget.missionSettings['description'] ?? 'toothpaste';
    _targetBarcode = widget.missionSettings['barcode'];
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    if (!_isCameraInitialized || _isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // In a real app, you would use a barcode scanning library
      // For this example, we'll simulate a successful scan after a delay
      await Future.delayed(Duration(seconds: 2));

      // Simulate barcode detection
      final detectedBarcode = _targetBarcode ?? 'SIMULATED_BARCODE_123';

      // Check if barcode matches
      final bool isMatch =
          _targetBarcode == null || detectedBarcode == _targetBarcode;

      if (isMatch) {
        widget.onMissionComplete();
      } else {
        setState(() {
          _isScanning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode does not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning barcode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Mission'),
        automaticallyImplyLeading: false,
      ),
      body:
          _isCameraInitialized
              ? Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Camera preview
                        CameraPreview(_cameraController!),

                        // Scan area overlay
                        Container(
                          width: 250,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Scanning indicator
                        if (_isScanning)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Scanning barcode...',
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
                  // Instructions
                  Container(
                    padding: EdgeInsets.all(24),
                    color: Colors.black87,
                    child: Column(
                      children: [
                        Text(
                          _targetBarcode != null && _targetBarcode!.isNotEmpty
                              ? 'Scan the registered barcode'
                              : 'Scan the barcode of: $_targetDescription',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isScanning ? null : _scanBarcode,
                          child: Text('Scan Barcode'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }
}
