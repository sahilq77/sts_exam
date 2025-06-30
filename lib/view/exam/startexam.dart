import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:shimmer/shimmer.dart';
import 'package:camera/camera.dart';
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
  final _noScreenshot = NoScreenshot.instance;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  Timer? _appSwitchTimer;
  int _switchAttemptCount = 0;
  final int _maxAllowedAttempts = 3;
  bool _leftApp = false;

  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Screenshot On: $result');
  }

  Future<void> initializeCamera() async {
    debugPrint('Initializing camera...');
    if (_cameraController != null) {
      debugPrint('Camera already initialized, skipping.');
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
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //disableScreenshot(); // Disable screenshots when the screen is initialized
    // initializeCamera();
    _appSwitchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_leftApp && _isCameraInitialized) {
        _switchAttemptCount++;
        if (_switchAttemptCount >= _maxAllowedAttempts) {
          _autoSubmitExam();
        } else {
          _showWarningDialogWithCount();
        }
      }
    });
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
    _appSwitchTimer?.cancel();
    _appSwitchTimer = null; // Clear reference to prevent accidental use
    debugPrint('App switch timer disposed.');
    // _cameraController?.dispose().then((_) {
    //   debugPrint('Camera controller disposed.');
    //   _cameraController = null;
    // });
    //enableScreenshot(); // Re-enable screenshots when the screen is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _leftApp = true;
      _cameraController?.pausePreview();
    } else if (state == AppLifecycleState.resumed && _leftApp) {
      _leftApp = false;
      if (_isCameraInitialized) {
        _cameraController?.resumePreview();
      }
      _switchAttemptCount++;
      if (_switchAttemptCount >= _maxAllowedAttempts) {
        _autoSubmitExam();
      } else {
        _showWarningDialogWithCount();
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
            title: const Text("Warning"),
            content: Text(
              "You switched away from the app ($_switchAttemptCount/$_maxAllowedAttempts).\n"
              "After 3 attempts, the exam will be auto-submitted.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _autoSubmitExam() {
    if (!mounted) return;
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dialog dismissal on back button
        child: AlertDialog(
          title: const Text("Exam Auto-Submitted"),
          content: const Text(
            "You left the app too many times. The exam has been auto-submitted.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.submitTest(context: context);
                controller.selectedOption.value = null;
                controller.currentQuestionIndex.value = 0;
                controller.selectedAnswers.clear();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent dismissal by tapping outside
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
        body: Obx(() {
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
              currentQuestion.question ?? 'Question not available';

          return Column(
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
                      controller.formatTime(controller.remainingSeconds.value),
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
                      _isCameraInitialized && _cameraController != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CameraPreview(_cameraController!),
                          )
                          : const Center(child: CircularProgressIndicator()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  '${controller.currentQuestionIndex.value + 1}. $questionText',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              if (options != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final entry = options.entries.toList()[index];
                      return Obx(() => _buildOption(entry, index, controller));
                    },
                  ),
                ),
            ],
          );
        }),
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
            Text(
              '$optionKey. $optionText',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            if (option.value.isEmpty &&
                controller.imageLink.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Image.network(
                controller.imageLink.value,
                height: 100,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Text('Image not available'),
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
