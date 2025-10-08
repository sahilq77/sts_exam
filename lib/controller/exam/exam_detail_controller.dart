import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/exam/available_exam_list_response.dart';
import '../../utility/app_utility.dart';

class ExamDetailController extends GetxController {
  RxList<AvailableExam> examDetailList = <AvailableExam>[].obs;
  RxString imageLink = "".obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString slectedexamID = "".obs;

  // void onInit() {
  //   super.onInit();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (Get.context != null && slectedexamID.value != null) {
  //       fetchExamDetail(context: Get.context!, reset: true);
  //     }
  //   });
  // }

  void onClose() {
    // Cleanup only
    slectedexamID.value = "";
    examDetailList.clear();
    isLoading.value = true; // Reset loading state
    super.onClose();
  }

  void setSelectedExamid(String examid) {
    slectedexamID.value = examid;
    log('Exam ID ${slectedexamID.value}');
  }

  // Method to clear the selected maintenance (optional)
  void clearSelectedExamid() {
    slectedexamID.value = "";
  }

  Future<void> fetchExamDetail({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // final jsonBody = Createjson().createJsonForGetProduct(
      //   "10",
      //   offset.value,
      //   "",
      //   filterProductId.value,
      //   filterCompanyId.value,
      //   filterPackagingTypeId.value,
      // );
      final jsonBody = {
        "single_id": slectedexamID.value,
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
      log("examjshhgsyhg=======>$response");
      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          examDetailList.clear();
          final exam = response[0].data;
          imageLink.value = response[0].imageLink
              .replaceAll(r'\/', '/')
              .replaceAll(r'\:', ':');
          log("examjshhgsyhg=======>${response[0].data.first.examName}");
          examDetailList.clear();
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
                // resultDateTime: ex.resultDateTime,
                // resultTime: ex.resultTime,
                status: ex.status,
                isDeleted: ex.isDeleted,
                isAttempted: ex.isAttempted,
                // createdOn: ex.createdOn,
                // updatedOn: ex.updatedOn,
                attemptCount: ex.attemptCount,
                examName: ex.examName,
                questionCount: ex.questionCount,
                questionSCount: ex.questionSCount,
                testType:
                    ex.testType, //test_type '0' for free & test_type '1' for paid
                isPaid: ex.isPaid,
              ),
            );
          }
        }
      } else {
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
    }
  }

  Future<void> refreshResultList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the result list
      examDetailList.clear();
      errorMessage.value = '';

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list
      fetchExamDetail(context: context);
      // Show success message if no errors
      // if (errorMessage.value.isEmpty) {
      //   Get.snackbar(
      //     'Success',
      //     'Results refreshed successfully',
      //     backgroundColor: AppColors.successColor ?? Colors.green,
      //     colorText: Colors.white,
      //     duration: const Duration(seconds: 2),
      //   );
      // }
    } catch (e) {
      errorMessage.value = 'Failed to refresh results: $e';
      // Get.snackbar(
      //   'Error',
      //   errorMessage.value,
      //   backgroundColor: AppColors.errorColor,
      //   colorText: Colors.white,
      // );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
}
