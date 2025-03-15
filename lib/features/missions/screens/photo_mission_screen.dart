// lib/features/missions/screens/photo_mission_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

class PhotoMissionScreen extends StatefulWidget {
  final Map<String, dynamic> missionSettings;
  final VoidCallback onMissionComplete;

  const PhotoMissionScreen({
    Key? key,
    required this.missionSettings,
    required this.onMissionComplete,
  }) : super(key: key);

  @override
  _PhotoMissionScreenState createState() => _PhotoMissionScreenState();
}

class _PhotoMissionScreenState extends State<PhotoMissionScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  String? _photoPath;
  String? _referencePhotoPath;
  bool _hasReference;
  String _targetDescription = '';

  @override
  void initState() {
    super.initState();
    _hasReference = widget.missionSettings['hasReference'] ?? false;
    _targetDescription =
        widget.missionSettings['description'] ?? 'bathroom sink';
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

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _photoPath = photo.path;
      });

      // Simulate photo analysis
      await Future.delayed(Duration(seconds: 2));

      // In a real app, you would compare the photo with the reference
      // or use ML to identify the target object
      final bool isMatch = true; // Simulated match

      if (isMatch) {
        widget.onMissionComplete();
      } else {
        setState(() {
          _isAnalyzing = false;
          _photoPath = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo does not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Mission'),
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
                        _photoPath == null
                            ? CameraPreview(_cameraController!)
                            : Image.file(File(_photoPath!)),

                        // Target overlay
                        if (_photoPath == null)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            width: 250,
                            height: 250,
                          ),

                        // Loading indicator
                        if (_isAnalyzing)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Analyzing photo...',
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
                          _hasReference
                              ? 'Take a photo that matches your reference'
                              : 'Take a photo of: $_targetDescription',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isAnalyzing ? null : _takePhoto,
                          child: Text('Take Photo'),
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
