import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/exam/get_all_questions_response.dart';
import '../../model/exam/test_submit_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';
import '../../view/filters/exam_filter.dart';

class StartExamController extends GetxController {
  var selectedOption = RxnString(); // Stores answerId (option key)
  var currentQuestionIndex = 0.obs;
  var remainingSeconds = 0.obs;
  var selectedFilter = RxnString();
  var selectedAnswers =
      <String, String?>{}.obs; // questionId -> answerId (option key)
  RxList<QuestionDetail> questionDetail = <QuestionDetail>[].obs;
  RxString imageLink = "".obs;
  var errorMessage = ''.obs;
  var errorMessages = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadings = true.obs;
  Timer? timer;
  String testID = '';
  RxString attempt = "".obs;
  RxString switchAttemptCount = ''.obs;

  void setTestid(String testid) {
    testID = testid;
    log("set id $testid");
    update();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchallQestions({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String userId = "1",
    required String testId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      log("Test ID $testId");
      final jsonBody = {
        "user_id": AppUtility.userID,
        "user_type": AppUtility.userType,
        "test_id": testId,
        "limit": "",
        "offset": "",
      };
      List<GetAllQuestionsResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getAllexamquestionsListApi,
                Networkutility.getAllexamquestionsList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetAllQuestionsResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        questionDetail.clear();
        selectedAnswers.clear();
        timer?.cancel();
        for (var que in response[0].data) {
          questionDetail.add(
            QuestionDetail(
              testId: que.testId,
              examId: que.examId,
              examName: que.examName,
              testName: que.testName,
              shortNote: que.shortNote,
              shortDescription: que.shortDescription,
              duration: que.duration,
              totalQuestions: que.totalQuestions,
              isShowResult: que.isShowResult,
              questions: que.questions,
            ),
          );
        }
        if (questionDetail.isNotEmpty) {
          for (var question in questionDetail.first.questions) {
            selectedAnswers[question.questionId] = null;
          }
          remainingSeconds.value =
              (int.tryParse(response[0].data.first.duration) ?? 60) * 60;
          startTimer();
        } else {
          errorMessage.value = 'No questions available';
          Get.snackbar(
            'Error',
            errorMessage.value,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        Get.snackbar(
          'Error',
          errorMessage.value,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startTimer() {
    timer?.cancel();
    if (remainingSeconds.value <= 0) {
      remainingSeconds.value = 60 * 60;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        showTimeoutDialog();
      }
    });
  }

  Future<void> submitTest({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      isLoadings.value = true;
      errorMessages.value = '';
      log("ATTP ${attempt.value}");
      final jsonBody = {
        "user_id": AppUtility.userID,
        "user_type": AppUtility.userType,
        "test_id": questionDetail.isNotEmpty ? questionDetail.first.testId : "",
        "attempted_test_id": attempt.value,
        "submitted_on": DateTime.now().toString(),
        "answer_list": getAnswerList(),
        "switch_attempt_count": switchAttemptCount.value,
        "duration": formatTime(remainingSeconds.value),
        "face_detection_warnings":""
      };
      List<TestSubmitResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.testSubmitApi,
                Networkutility.testSubmit,
                jsonEncode(jsonBody),
                context,
              ))
              as List<TestSubmitResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        Get.snackbar(
          'Success',
          'Test Submitted successfully!',
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
        );

        print("is shwow ${questionDetail.first.isShowResult}");
        if (questionDetail.first.isShowResult == "0") {
          showThankyouDialog(context);
          selectedAnswers.clear();
          selectedOption.value = null;
          currentQuestionIndex.value = 0;
          testID = '';
          switchAttemptCount.value = '';
        } else if (questionDetail.first.isShowResult == "1") {
          Get.offAllNamed(
            AppRoutes.testresult,
            arguments: {
              "test_id": questionDetail.first.testId,
              "attempted_test_id": response[0].data.attemptedId.toString(),
            },
          );
          selectedAnswers.clear();
          selectedOption.value = null;
          currentQuestionIndex.value = 0;
          testID = '';
          switchAttemptCount.value = '';
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        errorMessages.value = 'No response from server';
        Get.snackbar(
          'Error',
          errorMessages.value,
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessages.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        errorMessages.value,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoadings.value = false;
    }
  }

  Future<void> refreshResultList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      questionDetail.clear();
      selectedAnswers.clear();
      selectedFilter.value = null;
      errorMessage.value = '';
      if (showLoading) isLoading.value = true;

      await fetchallQestions(
        context: context,
        reset: true,
        forceFetch: true,
        testId: testID,
      );

      if (errorMessage.value.isEmpty) {
        Get.snackbar(
          'Success',
          'Questions refreshed successfully',
          backgroundColor: AppColors.successColor ?? Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh questions: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  List<Question> get filteredQuestions {
    if (questionDetail.isEmpty || questionDetail.first.questions.isEmpty) {
      return [];
    }
    if (selectedFilter.value == null ||
        selectedFilter.value!.startsWith('Questions:')) {
      return questionDetail.first.questions;
    }
    switch (selectedFilter.value) {
      case 'Attempted':
        return questionDetail.first.questions
            .where(
              (q) =>
                  selectedAnswers.containsKey(q.questionId) &&
                  selectedAnswers[q.questionId] != null,
            )
            .toList();
      case 'Unattempted':
        return questionDetail.first.questions
            .where(
              (q) =>
                  selectedAnswers.containsKey(q.questionId) &&
                  selectedAnswers[q.questionId] == null,
            )
            .toList();
      default:
        return questionDetail.first.questions;
    }
  }

  List<int> get attemptedQuestionNumbers {
    if (questionDetail.isEmpty || questionDetail.first.questions.isEmpty) {
      return [];
    }
    return questionDetail.first.questions
        .asMap()
        .entries
        .where((entry) => selectedAnswers[entry.value.questionId] != null)
        .map((entry) => entry.key + 1)
        .toList();
  }

  void showThankyouDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(dialogContext).pop();
          Get.offNamed(AppRoutes.home);
        });

        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/all_the_best.png',
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                'Thank You For \nSubmitting Exam',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'All the best.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF353B43),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void showTimeoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Time’s Up!'),
        content: const Text(
          'The exam duration has ended. Your answers have been submitted.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              submitTest(context: Get.context!);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  List<Map<String, dynamic>> getAnswerList() {
    return questionDetail.first.questions.map((question) {
      return {
        "question_id": int.tryParse(question.questionId) ?? 0,
        "student_answer": selectedAnswers[question.questionId] ?? "",
      };
    }).toList();
  }

  void showSubmitDialog() {
    int attemptedQuestions =
        selectedAnswers.values.where((answer) => answer != null).length;
    int unattemptedQuestions =
        questionDetail.isEmpty
            ? 0
            : questionDetail.first.questions.length - attemptedQuestions;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEA),
                borderRadius: BorderRadius.circular(4),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor,
                  ),
                  children: [
                    const TextSpan(text: 'Once you click "'),
                    TextSpan(
                      text: 'Submit',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          '", you can\'t change your answers. Review carefully before final submission.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
                ),
                const Text(
                  'Attempted',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const Spacer(),
                Text(
                  attemptedQuestions.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
                ),
                const Text(
                  'Unattempted',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const Spacer(),
                Text(
                  unattemptedQuestions.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Resume',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      submitTest(context: Get.context!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Final Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return FilterBottomSheet(
          initialFilter: selectedFilter.value,
          onFilterApplied: (String? filter) {
            selectedFilter.value = filter;
            if (questionDetail.isEmpty ||
                questionDetail.first.questions.isEmpty) {
              currentQuestionIndex.value = -1;
              selectedOption.value = null;
              Get.snackbar(
                'Error',
                'No questions available',
                backgroundColor: AppColors.errorColor,
                colorText: Colors.white,
              );
              return;
            }
            if (filter == null) {
              currentQuestionIndex.value = 0;
              selectedOption.value =
                  selectedAnswers[questionDetail.first.questions[0].questionId];
            } else if (filter.startsWith('Questions:')) {
              final questionNumbers =
                  filter
                      .substring('Questions:'.length)
                      .split(',')
                      .map((num) => int.tryParse(num.trim()) ?? 0)
                      .where(
                        (num) =>
                            num > 0 &&
                            num <= questionDetail.first.questions.length,
                      )
                      .toList();
              if (questionNumbers.isNotEmpty) {
                currentQuestionIndex.value = questionNumbers.first - 1;
                selectedOption.value =
                    selectedAnswers[questionDetail
                        .first
                        .questions[currentQuestionIndex.value]
                        .questionId];
              } else {
                currentQuestionIndex.value = -1;
                selectedOption.value = null;
                Get.snackbar(
                  'Error',
                  'Selected question does not exist',
                  backgroundColor: AppColors.errorColor,
                  colorText: Colors.white,
                );
              }
            } else {
              if (filteredQuestions.isNotEmpty) {
                currentQuestionIndex.value = 0;
                selectedOption.value =
                    selectedAnswers[filteredQuestions[0].questionId];
                Get.snackbar(
                  'Filter Applied',
                  'Filter: $filter',
                  backgroundColor: AppColors.successColor,
                  colorText: Colors.white,
                );
              } else {
                currentQuestionIndex.value = -1;
                selectedOption.value = null;
                Get.snackbar(
                  'Error',
                  'No questions match the selected filter',
                  backgroundColor: AppColors.errorColor,
                  colorText: Colors.white,
                );
              }
            }
          },
          totalQuestions:
              questionDetail.isEmpty
                  ? 0
                  : questionDetail.first.questions.length,
          attemptedQuestions: attemptedQuestionNumbers,
        );
      },
    );
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void nextQuestion() {
    if (filteredQuestions.isEmpty || currentQuestionIndex.value == -1) return;
    selectedAnswers[filteredQuestions[currentQuestionIndex.value].questionId] =
        selectedOption.value;
    if (currentQuestionIndex.value < filteredQuestions.length - 1) {
      currentQuestionIndex.value++;
      selectedOption.value =
          selectedAnswers[filteredQuestions[currentQuestionIndex.value]
              .questionId];
    } else {
      showSubmitDialog();
    }
  }

  void previousQuestion() {
    if (filteredQuestions.isEmpty ||
        currentQuestionIndex.value <= 0 ||
        currentQuestionIndex.value == -1)
      return;
    selectedAnswers[filteredQuestions[currentQuestionIndex.value].questionId] =
        selectedOption.value;
    currentQuestionIndex.value--;
    selectedOption.value =
        selectedAnswers[filteredQuestions[currentQuestionIndex.value]
            .questionId];
  }
}
