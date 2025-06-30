import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/result_list/get_result_list_response.dart';
import '../../utility/app_utility.dart';

class TestResult extends GetxController {
  var resultList = <ResultList>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page

  @override
  void onInit() {
    super.onInit();
    // fetchResultList(context: Get.context!);
  }

  Future<void> fetchResult({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String testID,
    required String attemptid,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        resultList.clear();
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
        "user_id": AppUtility.userID,
        "user_type": AppUtility.userType,
        "test_id": testID,
        "attempted_test_id": attemptid,
        "limit": "",
        "offset": "",
      };

      List<GetExamResultListResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.resultlistApi,
        Networkutility.resultlist,
        jsonEncode(jsonBody),
        context,
      )) as List<GetExamResultListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final results = response[0].data;
          if (results.isEmpty || results.length < limit) {
            hasMoreData.value =
                false; // No more data if fewer results than limit
          }
          for (var result in results) {
            resultList.add(ResultList(
                testId: result.testId,
                testName: result.testName,
                attemptedTestId: result.attemptedTestId,
                attemptDate: result.attemptDate,
                yourScore: result.yourScore,
                scoreOutoff: result.scoreOutoff,
                rank: result.rank,
                rankOutoff: result.rankOutoff,
                correct: result.correct,
                incorrect: result.incorrect,
                unattempted: result.unattempted,
                totalQuestions: result.totalQuestions,
                examStatus: result.examStatus));
          }
          offset.value += limit; // Increment offset for next page
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No results found';
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

  Future<void> loadMoreResults(
      {required BuildContext context, required testid}) async {
    if (!isLoadingMore.value && hasMoreData.value) {
      //  await fetchResult(context: context, isPagination: true, testID: testid);
    }
  }

  Future<void> refreshResultList(
      {required BuildContext context,
      bool showLoading = true,
      required testid}) async {
    try {
      // Reset the result list
      resultList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list
      // await fetchResult(
      //     context: context, reset: true, forceFetch: true, testID: testid);

      // Show success message if no errors
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
