import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/login/get_login_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class LoginController extends GetxController {
  RxBool isLoading = true.obs;
  Future<void> login({
    BuildContext? context,
    required String? mobileNumber,
    required String? password,
        required String? token,
  }) async {
    try {
      // final jsonBody = {
      //   "user_type": selechtedUserType!.value,
      //   "full_name": fullNameControler.value.text,
      //   "email": emailControler.value.text,
      //   "mobile_number": emailControler.value.text,
      //   "gender": selechtedGender!.value,
      //   "profile_image": "",
      //   "state": selechtedState!.value,
      //   "city": selechtedCity!.value,
      //   "udise_number": uidControler.value.text,
      //   "school_name": schoolNameControler.value.text,
      //   "password": passwordControler.value.text,
      // };
      final jsonBody = {"mobile_number": mobileNumber, "password": password,"device_token":token};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.login,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;
          log("userid${user.userid}");
          await AppUtility.setUserInfo(
            user.userType,
            user.userid,
          );

          Get.snackbar('Success', 'Login Success',
              backgroundColor: AppColors.successColor, colorText: Colors.white);
          Get.offNamed(AppRoutes.home);
          // Get.offNamed('/dashboard');
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
