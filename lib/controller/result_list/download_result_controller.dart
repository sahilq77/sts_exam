import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stsexam/model/result_list/get_downloadresult_response.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/profile/get_profile_response.dart';
import '../../utility/app_utility.dart';

class DownloadResultController extends GetxController {
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString resultLink = "".obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     fetchUserProfile(
  //       context: Get.context!,
  //     ); // Fetch user profile on initialization
  //   });
  // }

  // Method to fetch user profile
  Future<void> fetchResult({
    required BuildContext context,
    bool isRefresh = false,
    required String testID,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "user_type": AppUtility.userType,
        "test_id": testID,
      };

      List<GetDownloadResultResoponse>? response =
          (await Networkcall().postMethod(
                Networkutility.downloadResultApi,
                Networkutility.downloadResult,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetDownloadResultResoponse>?;

      if (response != null && response.isNotEmpty) {
        resultLink.value = response[0].resultPdf
            .replaceAll(r'\/', '/')
            .replaceAll(r'\:', ':');
        if (response[0].status == "true") {
          resultLink.value = response[0].resultPdf
              .replaceAll(r'\/', '/')
              .replaceAll(r'\:', ':');
          log(
            "link ${response[0].resultPdf.replaceAll(r'\/', '/').replaceAll(r'\:', ':')}",
          );
          update();
        } else {
          errorMessage.value =
              'Failed to load profile: ${response[0].message ?? 'Unknown error'}';
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
}
