import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';



import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/payments/get_payments_receipt_response.dart';
import '../../model/payments/payment_receiptlist_model.dart';

class PaymentsListController extends GetxController{
    var paymentList = <PaymentReciptList>[].obs;
 
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;

void onInit(){
  super.onInit();
  fetchPaymentList(context: Get.context!);
}

  Future<void> fetchPaymentList({
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
      final jsonBody = {};
      List<GetPaymentReciptListResponse>? response = (await Networkcall().postMethod(
        Networkutility.paymentReciptlistApi,
        Networkutility.paymentReciptlist,
        jsonEncode(jsonBody),
        context,
      )) as List<GetPaymentReciptListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true||response[0].status == false) {
          final payments = response[0].data;
          for (var pay in payments) {
            paymentList.add(
              PaymentReciptList(
                id: pay.id, 
                refNumber: pay.refNumber, 
                studentName: pay.studentName, 
                date: pay.date, paymentStatus: pay.paymentStatus, 
                amount: pay.amount)
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

   Future<void> refreshPaymentList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the result list
      paymentList.clear();
      errorMessage.value = '';

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the result list
      await fetchPaymentList(context: context, reset: true, forceFetch: true);

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        Get.snackbar(
          'Success',
          'Results refreshed successfully',
          backgroundColor: AppColors.successColor ?? Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
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
