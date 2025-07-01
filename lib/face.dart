import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


class QuizScreen extends StatefulWidget {
  final CameraDescription frontCamera;

  const QuizScreen({super.key, required this.frontCamera});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizSample {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  _QuizSample({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}

class _QuizScreenState extends State<QuizScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isCameraInitialized = false;
  bool _isFaceDetected = false;
  int _currentQuestionIndex = 0;
  int _score = 0;

  final List<_QuizSample> _quizSamples = [
    _QuizSample(
      question: 'What is the capital of France?',
      options: ['Berlin', 'Paris', 'Madrid', 'Rome'],
      correctOptionIndex: 1,
    ),
    _QuizSample(
      question: 'Which planet is known as the Red Planet?',
      options: ['Jupiter', 'Mars', 'Venus', 'Mercury'],
      correctOptionIndex: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.frontCamera,
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
    _cameraController.startImageStream(_processCameraImage);
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableContours: false,
      enableClassification: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage = _convertCameraImage(image, widget.frontCamera);
    final faces = await _faceDetector.processImage(inputImage);

    setState(() {
      _isFaceDetected = faces.isNotEmpty;
    });
  }

  // Move _rotationIntToImageRotation before _convertCameraImage
  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg; // Fallback
    }
  }

  InputImage _convertCameraImage(CameraImage image, CameraDescription camera) {
    final WriteBuffer buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    final bytes = buffer.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: _rotationIntToImageRotation(camera.sensorOrientation),
        format:
            Platform.isAndroid
                ? InputImageFormat.nv21
                : InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    return inputImage;
  }

  // ... Rest of the class code (e.g., _selectOption, _showQuizResult, build, dispose) remains unchanged ...

  void _selectOption(int index) {
    if (!_isFaceDetected) return; // Prevent answering if face not detected
    if (index == _quizSamples[_currentQuestionIndex].correctOptionIndex) {
      setState(() {
        _score++;
      });
    }
    setState(() {
      if (_currentQuestionIndex < _quizSamples.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Quiz finished
        _cameraController.stopImageStream();
        _showQuizResult();
      }
    });
  }

  void _showQuizResult() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiz Completed'),
            content: Text('Your score: $_score/${_quizSamples.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentQuestionIndex = 0;
                    _score = 0;
                  });
                  _cameraController.startImageStream(_processCameraImage);
                },
                child: const Text('Restart'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: Stack(
        children: [
          // Camera preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_cameraController),
          ),
          // Warning overlay
          if (!_isFaceDetected)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Text(
                  'Please keep your face in the camera frame',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Quiz UI
          if (_isFaceDetected)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _quizSamples[_currentQuestionIndex].question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._quizSamples[_currentQuestionIndex].options
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () => _selectOption(entry.key),
                                child: Text(entry.value),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
