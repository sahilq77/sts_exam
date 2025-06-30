import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';

import '../../model/exam/get_buy_response.dart';

import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class BuyExamController extends GetxController {
  RxBool isLoading = true.obs;
  String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(90000) + 10000; // 5-digit random
    return 'TXN$timestamp$random'; // e.g., TXN168744937734560123
  }

  void onInit() {
    super.onInit();
    generateTransactionId();
  }

  Future<void> buyExam({
    BuildContext? context,
    // required String? subscriptionid,
    // required String? stateID,
    // required dynamic cityID,
    // required String? transactionID,
    required String? testid,
  }) async {
    try {
      final jsonBody = {
        "user_type": AppUtility.userType,
        "user_id": AppUtility.userID,
        "payment_status": "1",
        "test_id": testid,
        "transaction_no": generateTransactionId()
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
        Networkutility.buyExamApi,
        Networkutility.buyExam,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetBuyResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;
          // log("userid${user.userid}");

          Get.snackbar(
            'Success',
            'Buy successfully',
            backgroundColor: AppColors.successColor,
            colorText: Colors.white,
          );
          _showPaymentSuccessDialog(context!);
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

void _showPaymentSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(dialogContext).pop();
        Get.toNamed(AppRoutes.examInstruction);
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/success.png',
              width: 122,
              height: 135,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4D4D4D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your payment for the exam has been received, You can start your exam now.',
              style: TextStyle(
                fontSize: 12,
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
