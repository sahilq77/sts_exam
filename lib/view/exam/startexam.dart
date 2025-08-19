import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:shimmer/shimmer.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../../app_colors.dart';
import '../../controller/exam/start_exam_controller.dart';
import '../../utility/app_routes.dart';

class StartExamPage extends StatefulWidget {
  const StartExamPage({super.key});

  @override
  State<StartExamPage> createState() => _StartExamPageState();
}

class _StartExamPageState extends State<StartExamPage>
    with WidgetsBindingObserver {
  final controller = Get.put(StartExamController());
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  int _switchAttemptCount = 0;
  final int _maxAllowedAttempts = 3;
  bool _leftApp = false;
  DateTime? _pauseStartTime;
  bool _isCameraActive = false;
  static const platform = MethodChannel('com.quick.stsexam/screenshot');
  FaceDetector? _faceDetector; // Added for face detection
  Timer? _faceDetectionTimer; // Timer for periodic face detection
  final _noScreenshot = NoScreenshot.instance;

  Future<void> initializeCamera() async {
    debugPrint('Initializing camera...');
    if (_cameraController != null && _isCameraInitialized && _isCameraActive) {
      debugPrint('Camera already initialized and active, resuming preview...');
      await _resumeCameraPreview();
      return;
    }

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      debugPrint('Camera controller created, initializing...');
      await _cameraController!.initialize();
      debugPrint('Camera initialized successfully.');

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _isCameraActive = true;
      });

      await _cameraController!.resumePreview();
      debugPrint('Camera preview started.');

      // Initialize face detector and start face detection
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableClassification: false,
          enableLandmarks: false,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      _startFaceDetection();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        _isCameraInitialized = false;
        _isCameraActive = false;
      });
    }
  }

  Future<void> _resumeCameraPreview() async {
    if (_cameraController == null || !_isCameraInitialized) {
      debugPrint('Camera not initialized, reinitializing...');
      await initializeCamera();
      return;
    }

    try {
      if (!_cameraController!.value.isPreviewPaused) {
        debugPrint('Preview already active, skipping resume.');
        return;
      }
      await _cameraController!.resumePreview();
      debugPrint('Camera preview resumed successfully.');
      setState(() {
        _isCameraActive = true;
      });
      // Restart face detection when resuming preview
      _startFaceDetection();
    } catch (e) {
      debugPrint('Error resuming camera preview: $e');
      await _reinitializeCamera();
    }
  }

  Future<void> _reinitializeCamera() async {
    debugPrint('Reinitializing camera...');
    if (_cameraController != null) {
      await _cameraController!.dispose().catchError((e) {
        debugPrint('Error disposing camera: $e');
      });
    }
    _cameraController = null;
    _isCameraInitialized = false;
    _isCameraActive = false;
    // Stop face detection when reinitializing
    _stopFaceDetection();
    await initializeCamera();
  }

  // Start periodic face detection
  void _startFaceDetection() {
    if (_faceDetector == null ||
        _cameraController == null ||
        !_isCameraInitialized ||
        !_isCameraActive) {
      debugPrint('Cannot start face detection: Camera not ready');
      return;
    }
    _faceDetectionTimer?.cancel();
    _faceDetectionTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      if (!mounted || !_isCameraActive || _cameraController == null) {
        debugPrint(
          'Stopping face detection due to inactive camera or unmounted state',
        );
        _stopFaceDetection();
        return;
      }
      try {
        final image = await _cameraController!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final faces = await _faceDetector!.processImage(inputImage);
        debugPrint('Face detection: ${faces.length} face(s) detected');
        if (faces.isEmpty) {
          Get.snackbar(
            'Warning',
            'face not detetcted',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          // _switchAttemptCount++;
          // debugPrint('No face detected, attempt count: $_switchAttemptCount');
          // if (_switchAttemptCount >= _maxAllowedAttempts) {
          //   Get.snackbar(
          //     'Warning',
          //     'fce not detetcted',
          //     snackPosition: SnackPosition.TOP,
          //     backgroundColor: Colors.red,
          //     colorText: Colors.white,
          //     duration: const Duration(seconds: 3),
          //   );
          //   // _autoSubmitExam();
          // } else {
          //    Get.snackbar(
          //     'Warning',
          //     'fce not detetcted',
          //     snackPosition: SnackPosition.TOP,
          //     backgroundColor: Colors.red,
          //     colorText: Colors.white,
          //     duration: const Duration(seconds: 3),
          //   );
          //   // _showWarningDialogWithCount();
          // }
        }
      } catch (e) {
        debugPrint('Error in face detection: $e');
      }
    });
  }

  // Stop face detection
  void _stopFaceDetection() {
    _faceDetectionTimer?.cancel();
    _faceDetectionTimer = null;
  }

  void startScreenshotListener() async {
    if (await Permission.storage.request().isGranted) {
      try {
        await platform.invokeMethod('listenForScreenshots');
        platform.setMethodCallHandler((call) async {
          if (call.method == 'screenshotDetected') {
            _switchAttemptCount++;
            debugPrint(
              'Screenshot detected, attempt count: $_switchAttemptCount',
            );
            if (_switchAttemptCount >= _maxAllowedAttempts) {
              controller.switchAttemptCount.value =
                  _switchAttemptCount.toString();
              controller.update();
              _autoSubmitExam();
            } else {
              _showWarningDialogWithCount();
            }
          }
        });
      } catch (e) {
        debugPrint('Error setting up screenshot listener: $e');
      }
    } else {
      debugPrint('Storage permission denied');
    }
  }

  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Enable Screenshot: $result');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    disableScreenshot();
    initializeCamera();
    startScreenshotListener();
    final args = Get.arguments;
    final testId = args['test_id'];
    final attemptCount = args['attempted_count'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.attempt.value = attemptCount.toString();
      controller.fetchallQestions(context: context, testId: testId);
    });
  }

  @override
  void dispose() {
    debugPrint('Disposing StartExamPage...');
    if (_cameraController != null) {
      _cameraController!
          .dispose()
          .then((_) {
            debugPrint('Camera controller disposed.');
            _cameraController = null;
            _isCameraInitialized = false;
            _isCameraActive = false;
          })
          .catchError((e) {
            debugPrint('Error disposing camera: $e');
          });
    }
    enableScreenshot();
    // Dispose face detector
    _stopFaceDetection();
    _faceDetector?.close();
    _faceDetector = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('Lifecycle state changed: $state');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _leftApp = true;
      _pauseStartTime = DateTime.now();
      if (_isCameraInitialized && _cameraController != null) {
        try {
          await _cameraController!.dispose(); // Dispose camera on pause
          debugPrint('Camera disposed on pause to prevent session issues.');
        } catch (e) {
          debugPrint('Error disposing camera on pause: $e');
        }
        setState(() {
          _isCameraInitialized = false;
          _isCameraActive = false;
          _cameraController = null;
        });
      }
      // Stop face detection when app is paused
      _stopFaceDetection();
      debugPrint('App paused or inactive, pauseStartTime: $_pauseStartTime');
    } else if (state == AppLifecycleState.resumed && _leftApp) {
      _leftApp = false;
      await initializeCamera(); // Reinitialize camera on resume

      if (_pauseStartTime != null) {
        final pauseDuration =
            DateTime.now().difference(_pauseStartTime!).inMilliseconds;
        debugPrint('App resumed, pause duration: $pauseDuration ms');
        if (pauseDuration > 500) {
          _switchAttemptCount++;
          debugPrint('Switch attempt count incremented: $_switchAttemptCount');
          if (_switchAttemptCount >= _maxAllowedAttempts) {
            controller.switchAttemptCount.value =
                _switchAttemptCount.toString();
            controller.update();
            _autoSubmitExam();
          } else {
            _showWarningDialogWithCount();
          }
        } else {
          debugPrint('Pause duration too short, not counting as app switch');
        }
      }
      _pauseStartTime = null;
      if (mounted) {
        setState(() {}); // Refresh UI to ensure camera preview is displayed
      }
    }
  }

  void _showWarningDialogWithCount() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Warning'),
            content: Text(
              'You switched away from the app, attempted an action like a screenshot, or your face was not detected ($_switchAttemptCount/$_maxAllowedAttempts).\n'
              'After 3 attempts, the exam will be auto-submitted.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _autoSubmitExam() {
    if (!mounted) return;
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Exam Auto-Submitted'),
          content: const Text(
            'You left the app, attempted restricted actions, or your face was not detected too many times. The exam has been auto-submitted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.submitTest(context: context);
                controller.selectedOption.value = null;
                controller.currentQuestionIndex.value = 0;
                controller.selectedAnswers.clear();
                Get.offAllNamed(AppRoutes.home);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      useSafeArea: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.dialog(
          AlertDialog(
            title: const Text('Exit Exam'),
            content: const Text('Are you sure you want to exit the exam?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  controller.selectedAnswers.clear();
                  controller.selectedOption.value = null;
                  controller.timer?.cancel();
                  controller.currentQuestionIndex.value = 0;
                  Get.offAllNamed(AppRoutes.home);
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed:
                () => Get.dialog(
                  AlertDialog(
                    title: const Text('Exit Exam'),
                    content: const Text(
                      'Are you sure you want to exit the exam?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.selectedAnswers.clear();
                          controller.selectedOption.value = null;
                          controller.timer?.cancel();
                          controller.currentQuestionIndex.value = 0;
                          Get.offAllNamed(AppRoutes.home);
                        },
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                ),
          ),
          title: Obx(
            () => Text(
              controller.questionDetail.isNotEmpty
                  ? controller.questionDetail.first.testName ?? 'Exam'
                  : 'Exam',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () => controller.showFilterBottomSheet(context),
                style: TextButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDADADA), width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Image.asset('assets/filter.png', width: 24, height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Obx(() {
            if (controller.isLoading.value) {
              return buildShimmerEffect();
            }
            if (controller.errorMessage.isNotEmpty) {
              return Center(child: Text(controller.errorMessage.value));
            }
            if (controller.filteredQuestions.isEmpty ||
                controller.currentQuestionIndex.value == -1) {
              return const Center(
                child: Text(
                  'No questions match the selected filter.',
                  style: TextStyle(fontSize: 16, color: AppColors.textColor),
                ),
              );
            }
            final currentQuestion =
                controller.filteredQuestions[controller
                    .currentQuestionIndex
                    .value];
            final Map<String, String>? options = currentQuestion.options;
            final String questionText =
                currentQuestion.question.text ?? 'Question not available';
            final String questionImage = currentQuestion.question.image ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${controller.currentQuestionIndex.value + 1}/${controller.questionDetail[0].questions.length}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        controller.formatTime(
                          controller.remainingSeconds.value,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _isCameraInitialized &&
                                _cameraController != null &&
                                _isCameraActive
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CameraPreview(_cameraController!),
                            )
                            : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text(
                        '${controller.currentQuestionIndex.value + 1}. $questionText',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (questionImage.isNotEmpty &&
                          questionImage.contains(
                            RegExp(r'\.(jpeg|jpg|png)$', caseSensitive: false),
                          ))
                        SizedBox(
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: questionImage,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error, size: 50),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // questionText.contains(
                  //       RegExp(r'\.(jpeg|jpg|png)$', caseSensitive: false),
                  //     )
                  //     ? Row(
                  //       children: [
                  //         Text(
                  //           '${controller.currentQuestionIndex.value + 1}.',
                  //           style: const TextStyle(
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.w600,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //         const SizedBox(width: 8),
                  //         SizedBox(
                  //           child: SizedBox(
                  //             height: 100,
                  //             width: 100,
                  //             child: ClipRRect(
                  //               borderRadius: BorderRadius.circular(10),
                  //               child: CachedNetworkImage(
                  //                 imageUrl: questionText,
                  //                 fit: BoxFit.cover,
                  //                 placeholder:
                  //                     (context, url) => const Center(
                  //                       child: CircularProgressIndicator(),
                  //                     ),
                  //                 errorWidget:
                  //                     (context, url, error) =>
                  //                         const Icon(Icons.error, size: 50),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     )
                  //     : Text(
                  //       '${controller.currentQuestionIndex.value + 1}. $questionText Replacing 65 out of 65 node(s) with delegate (TfLiteXNNPackDelegate) node, yielding 1 partitions for the whole graph',
                  //       style: const TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                ),
                if (options != null)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final entry = options.entries.toList()[index];
                      return Obx(() => _buildOption(entry, index, controller));
                    },
                  ),
              ],
            );
          }),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10.3,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child:
                          controller.currentQuestionIndex.value > 0 &&
                                  controller.currentQuestionIndex.value != -1
                              ? OutlinedButton(
                                onPressed: controller.previousQuestion,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  'Previous',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.nextQuestion();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.currentQuestionIndex.value <
                                      controller.filteredQuestions.length - 1
                                  ? const Color(0xFF3B4453)
                                  : AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          controller.currentQuestionIndex.value <
                                  controller.filteredQuestions.length - 1
                              ? 'Save & Next'
                              : 'Submit',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    MapEntry<String, String> option,
    int index,
    StartExamController controller,
  ) {
    final String optionKey = option.key;
    final String optionText =
        option.value.isEmpty ? 'Option $optionKey (Image)' : option.value;
    bool isSelected = controller.selectedOption.value == optionKey;

    return GestureDetector(
      onTap: () {
        controller.selectedOption.value = optionKey;
        controller.selectedAnswers[controller
                .filteredQuestions[controller.currentQuestionIndex.value]
                .questionId] =
            optionKey;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE6E6) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.red : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child:
                  optionText.contains(
                        RegExp(r'\.(jpeg|jpg|png)$', caseSensitive: false),
                      )
                      ? Row(
                        children: [
                          Text(
                            '$optionKey).',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: optionText,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error, size: 50),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Text(
                        '$optionKey). $optionText',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
            ),
            if (option.value.isEmpty &&
                controller.imageLink.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Image.network(
                controller.imageLink.value,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image load error: $error');
                  return const Text('Image not available');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildShimmerEffect() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 100, height: 14, color: Colors.grey[300]),
                Container(width: 80, height: 14, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
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
