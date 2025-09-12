import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart';

import '../../model/announcements/get_announcements_resposne.dart';
import '../../utility/app_utility.dart';

class AnnouncementsController extends GetxController {
  var announcementsList = <AnnouncementData>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs; // For pagination loading
  RxBool hasMoreData = true.obs; // To track if more data is available
  RxInt offset = 0.obs; // Pagination offset
  final int limit = 10; // Number of items per page

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncementsList(context: Get.context!);
  }

  Future<void> fetchAnnouncementsList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        announcementsList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) return; // No more data to fetch

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "user_id": AppUtility.userID,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetAnnouncementsResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getAnnouncementsApi,
                Networkutility.getAnnouncements,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetAnnouncementsResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final announcements = response[0].data;
          if (announcements.isEmpty || announcements.length < limit) {
            hasMoreData.value =
                false; // No more data if fewer announcements than limit
          }
          for (var announcement in announcements) {
            announcementsList.add(AnnouncementData(title: announcement.title));
          }
          offset.value += limit; // Increment offset for next page
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No announcements found';
        }
      } else {
        hasMoreData.value = false;
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
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreAnnouncements({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchAnnouncementsList(context: context, isPagination: true);
    }
  }

  Future<void> refreshAnnouncementsList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset the announcements list
      announcementsList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      // Set loading state
      if (showLoading) {
        isLoading.value = true;
      }

      // Fetch the announcements list
      await fetchAnnouncementsList(
        context: context,
        reset: true,
        forceFetch: true,
      );

      // Show success message if no errors
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Announcements refreshed successfully',
        //   backgroundColor: AppColors.successColor ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh announcements: $e';
      // Get.snackbar(
      //   'Error',
      //   errorMessage.value,
      //   backgroundColor: AppColors.errorColor,
      //   colorText: Colors.white,
      // );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }
}
