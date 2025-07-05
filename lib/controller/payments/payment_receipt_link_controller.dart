import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:stsexam/model/payments/payment_receipt_link_response.dart';
import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../utility/app_utility.dart';

class PaymentReceiptController extends GetxController {
  var currentDate = DateTime.now().obs;
  var reminders = <DateTime, int>{}.obs;
  RxString url = "".obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    //fetchReciptUrl();
  }

  Future<void> fetchReciptUrl({
    BuildContext? context,
    required String id,
  }) async {
    try {
      final jsonBody = {
        "payment_id": id,
        "user_id": AppUtility.userID,
        "test_id": "",
        "user_type": AppUtility.userType,
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
        Networkutility.paymentReceiptDownloadApi,
        Networkutility.paymentReceiptDownload,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetPaymentReceiptLinkResponse> response = List.from(list);
        if (response[0].status == "true") {
          final cal = response[0].paymentReceiptPdf;
          // log("userid${user.userid}");
          url.value = cal.replaceAll(r'\/', '/').replaceAll(r'\:', ':');
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
