import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stsexam/model/payments/get_payment_url_response.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';

import '../../model/exam/get_buy_response.dart';

import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class PaymentController extends GetxController {
  RxBool isLoading = true.obs;
  RxString paymentUrl = "".obs;

  Future<void> getPaymentUrl({
    BuildContext? context,
    // required String? subscriptionid,
    // required String? stateID,
    // required dynamic cityID,
    // required String? transactionID,
    required String? testid,
    required String? amt,
  }) async {
    try {
      final jsonBody = {
        "user_type": AppUtility.userType,
        "user_id": AppUtility.userID,
        "ammount": amt,
        "test_id": testid,
      };

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.paymentApi,
        Networkutility.payment,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetPaymentUrlResponse> response = List.from(list);
        if (response[0].status == "true") {
          final pUrl = response[0].paymentUrl;
          // log("userid${user.userid}");
          log("Payment Url: $pUrl");
          paymentUrl.value = pUrl;
          Get.toNamed(AppRoutes.paymentScreen);
          // Get.snackbar(
          //   'Success',
          //   'Buy successfully',
          //   backgroundColor: AppColors.successColor,
          //   colorText: Colors.white,
          // );
          // _showPaymentSuccessDialog(context!);
          // Get.offNamed(AppRoutes.PaymentReceipt);
        } else {
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
          );
        }
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.errorColor,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
