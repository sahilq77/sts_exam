import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stsexam/utility/app_utility.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/payments/get_payments_receipt_response.dart';

class PaymentsListController extends GetxController {
  var paymentList = <PaymentReciptList>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxInt offset = 0.obs;
  final int limit = 10; // Number of items per page
  RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentList(context: Get.context!);
  }

  Future<void> fetchPaymentList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    if (!hasMoreData.value && isPagination) return;

    try {
      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        if (reset) {
          offset.value = 0;
          paymentList.clear();
          hasMoreData.value = true;
        }
      }
      errorMessage.value = '';

      final jsonBody = {
        "single_id": "",
        "user_id": AppUtility.userID,
        "test_id": "",
        "user_type": AppUtility.userType,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetPaymentListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.paymentReciptlistApi,
                Networkutility.paymentReciptlist,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetPaymentListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final payments = response[0].data;
          if (payments.isEmpty) {
            hasMoreData.value = false;
          } else {
            for (var pay in payments) {
              paymentList.add(
                PaymentReciptList(
                  id: pay.id,
                  userId: pay.userId,
                  userType: pay.userType,
                  userName: pay.userName,
                  email: pay.email,
                  paymentStatus: pay.paymentStatus,
                  testName: pay.testName,
                  paymentAmount: pay.paymentAmount,
                  transactionNo: pay.transactionNo,
                  paymentDate: pay.paymentDate,
                  testId: pay.testId,
                  receiptNo: pay.receiptNo,
                  isDeleted: pay.isDeleted,
                  status: pay.status,
                ),
              );
            }
            offset.value += limit; // Increment offset for next page
          }
        } else {
          errorMessage.value = 'No data available';
        }
      } else {
        errorMessage.value = 'No response from server';
        hasMoreData.value = false;
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

  Future<void> refreshPaymentList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      paymentList.clear();
      errorMessage.value = '';
      if (showLoading) {
        isLoading.value = true;
      }
      await fetchPaymentList(context: context, reset: true);
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
}
