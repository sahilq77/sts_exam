import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/signUp/signUp_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class SignupController extends GetxController {
  RxBool isLoading = true.obs;
  Future<void> signUp({
    BuildContext? context,
    required String? userType,
    required String? fullName,
    required String? email,
    required String? mobileNumber,
    required String? gender,
    required String? profileImg,
    required String? state,
    required String? city,
    required String? udiseNumber,
    required String? schoolName,
    required String? password,
  }) async {
    try {
      final jsonBody = {
        "user_type": userType == "Student" ? "0" : "1",
        "full_name": fullName,
        "email": email,
        "mobile_number": mobileNumber,
        "gender": gender,
        "udis_number": udiseNumber ?? "",
        "school_name": schoolName ?? "",
        "state": state,
        "city": city,
        "password": password,
        "confirm_password": password
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
        Networkutility.signUpApi,
        Networkutility.signUp,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetRegisterResponse> response = List.from(list);
        if (response[0].status == "true") {
          // final user = response[0].data;
          // await AppUtility.setUserInfo(
          //  user.
          // );

          Get.snackbar('Success', '${response[0].status}',
              backgroundColor: AppColors.successColor, colorText: Colors.white);

          Get.offNamed(AppRoutes.login);
        } else {
          Get.snackbar('Error', response[0].message,
              backgroundColor: AppColors.errorColor, colorText: Colors.white);
        }
      } else {
        Get.back();
        Get.snackbar('Error', 'No response from server',
            backgroundColor: AppColors.errorColor, colorText: Colors.white);
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar('Error', '${e.message} (Code: ${e.statusCode})',
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Unexpected errorColor: $e',
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
