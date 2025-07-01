import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/result_list/get_result_overview_response.dart';
import '../../utility/app_utility.dart';

class ResultOverviewContoller extends GetxController {
  RxList<Overview> overviewList = <Overview>[].obs;
  RxString imageLink = "".obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool hasMore = true.obs;
  RxInt currentPage = 1.obs;
  final int pageSize = 10; // Number of items per page
  String testID = '';
  String attpID = '';

  void onInit() {
    super.onInit();
    fetchOverview(context: Get.context!);
  }

  void setTestid(String testid, String attempid) {
    testID = testid;
    attpID = attempid;
    log("set id $testid");
    log("attp id $attempid");
    update();
  }

  Future<void> fetchOverview({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        currentPage.value = 1;
        overviewList.clear();
        hasMore.value = true;
      }

      if (!hasMore.value && isPagination) {
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "user_type": AppUtility.userType,
        "test_id": testID,
        "attempted_test_id": attpID,
        "limit": pageSize.toString(),
        "offset": ((currentPage.value - 1) * pageSize).toString(),
      };

      List<GetOverviewResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getTestoverviewApi,
                Networkutility.getTestoverview,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetOverviewResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final overview = response[0].questions;

          if (overview.isEmpty || overview.length < pageSize) {
            hasMore.value = false;
          }

          for (var ov in overview) {
            overviewList.add(
              Overview(
                questionNumber: ov.questionNumber,
                question: ov.question,
                questionImage: ov.questionImage,
                options: ov.options,
                selectedAnswer: ov.selectedAnswer,
                isCorrect: ov.isCorrect,
                correctAnswer: ov.correctAnswer,
              ),
            );
          }

          if (isPagination) {
            currentPage.value++;
          }
        } else {
          hasMore.value = false;
          errorMessage.value = 'No exams available';
        }
      } else {
        hasMore.value = false;
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

  Future<void> refreshOverview({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      errorMessage.value = '';

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchOverview(context: context, reset: true, forceFetch: true);

      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Results refreshed successfully',
        //   backgroundColor: AppColors.successColor ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh results: $e';
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

  Future<void> loadMoreExams({required BuildContext context}) async {
    if (!isLoading.value && hasMore.value) {
      await fetchOverview(context: context, isPagination: true);
    }
  }
}
