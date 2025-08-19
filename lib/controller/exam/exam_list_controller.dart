import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/exam/available_exam_list_response.dart';
import '../../utility/app_utility.dart';

class ExamListController extends GetxController {
  RxList<AvailableExam> examDetailList = <AvailableExam>[].obs;
  RxString imageLink = "".obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page

  @override
  void onInit() {
    super.onInit();
    fetchallExam(context: Get.context!);
  }

  Future<void> fetchallExam({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        examDetailList.clear();
        hasMoreData.value = true;
      }

      if (!hasMoreData.value && !reset) return; // No more data to fetch

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "user_type": AppUtility.userType,
        "user_id": AppUtility.userID,
      };

      List<AvailableExamListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getallExamsListApi,
                Networkutility.getallExamsList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<AvailableExamListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final exam = response[0].data;
          imageLink.value = response[0].imageLink
              .replaceAll(r'\/', '/')
              .replaceAll(r'\:', ':');

          if (exam.isEmpty || exam.length < limit) {
            hasMoreData.value = false;
          }

          for (var ex in exam) {
            examDetailList.add(
              AvailableExam(
                id: ex.id,
                examId: ex.examId,
                testName: ex.testName,
                shortNote: ex.shortNote,
                shortDescription: ex.shortDescription,
                duration: ex.duration,
                questionsFile: ex.questionsFile,
                questionsFileName: ex.questionsFileName,
                questionsShuffle: ex.questionsShuffle,
                showResult: ex.showResult,
                testImage: ex.testImage,
                amount: ex.amount,
                instructionDescription: ex.instructionDescription,
                status: ex.status,
                isDeleted: ex.isDeleted,
                examName: ex.examName,
                questionCount: ex.questionCount,
                questionSCount: ex.questionSCount,
                attemptCount: ex.attemptCount,
                isAttempted: ex.isAttempted,
                testType: ex.testType,
              ),
            );
          }
          offset.value += limit; // Increment offset for next page
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No exams available';
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
    } on ParseException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreExams({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchallExam(context: context, isPagination: true);
    }
  }

  Future<void> refreshResultList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the exam list
      examDetailList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the exam list
      await fetchallExam(context: context, reset: true, forceFetch: true);

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        Get.snackbar(
          'Success',
          'Exams refreshed successfully',
          backgroundColor: AppColors.successColor ?? Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh exams: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
}
