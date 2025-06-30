import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';
import '../../model/profile/get_profile_response.dart';
import '../../utility/app_utility.dart';

class ProfileController extends GetxController {
  var selectedUser = Rxn<UserProfile>();
  var userProfileList = <UserProfile>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString imageLink = "".obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserProfile(
          context: Get.context!); // Fetch user profile on initialization
    });
  }

  // Method to set the selected user
  void setSelectedUser(UserProfile user) {
    selectedUser.value = user;
  }

  // Method to clear the selected user
  void clearSelectedUser() {
    selectedUser.value = null;
  }

  // Method to fetch user profile
  Future<void> fetchUserProfile({
    required BuildContext context,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        userProfileList.clear(); // Clear existing data on refresh
      }

      final jsonBody = {
        "user_id": AppUtility.userID,
        "user_type": AppUtility.userType,
      };

      List<GetUserProfileResponse>? response = (await Networkcall().postMethod(
        Networkutility.getuserprofileApi,
        Networkutility.getuserprofile,
        jsonEncode(jsonBody),
        context,
      )) as List<GetUserProfileResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final users = response[0].data;
          imageLink.value = response[0]
              .imageLink
              .replaceAll(r'\/', '/')
              .replaceAll(r'\:', ':');
          userProfileList.add(UserProfile(
            id: users.id,
            userType: users.userType,
            fullName: users.fullName,
            profileImage: users.profileImage,
            gender: users.gender,
            email: users.email,
            mobileNumber: users.mobileNumber,
            udisNumber: users.udisNumber,
            schoolName: users.schoolName,
            state: users.state,
            city: users.city,
          ));
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

  // Method to handle pull-to-refresh
  Future<void> onRefresh(BuildContext context) async {
    userProfileList.clear();
    await fetchUserProfile(context: context, isRefresh: true);
  }
}
