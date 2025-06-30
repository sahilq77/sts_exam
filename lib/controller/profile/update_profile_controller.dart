import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stsexam/controller/profile/profile_controller.dart';


import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/profile/get_profile_response.dart';
import '../../model/signUp/signUp_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class UpdateProfileController extends GetxController {
  Rx<String?> imagePath = Rx<String?>(null); // Nullable String, initially null
  RxBool isLoading = false.obs;
  var base64Image = ''.obs; // Store base64 image
  final profileController = Get.put(ProfileController());

  final ImagePicker _picker = ImagePicker();
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      final bytes = await File(pickedFile.path).readAsBytes();
      base64Image.value = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      print('Bs64====>$base64Image');
    }
  }

  RxBool isLoadingu = true.obs;
  Future<void> updateProfile({
    BuildContext? context,

    ///  required String? image,
    required String? fullName,
  }) async {
    try {
      final jsonBody = {
        "user_type": AppUtility.userType,
        "user_id": AppUtility.userID,
        "full_name": fullName,
        "profile_image": base64Image.value,
      };

      isLoadingu.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.signUpApi,
        Networkutility.upadetprofile,
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

          Get.snackbar('Success', 'Profile updated successfully!',
              backgroundColor: AppColors.successColor, colorText: Colors.white);
          await profileController.fetchUserProfile(
              context: Get.context!, isRefresh: true);
          Get.offNamed(AppRoutes.myprofile);
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
      isLoadingu.value = false;
    }
  }
}
