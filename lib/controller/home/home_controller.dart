import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/urls.dart' show Networkutility;
import '../../model/home/banner_images_response.dart';
import 'package:http/http.dart' as http;

import '../../model/home/get_available_exam_response.dart';
import '../../model/home/get_notifications_response.dart';
import '../../model/home/latest_exam_model.dart';
import '../../model/home/latest_exam_response.dart';

import '../../model/result_list/get_result_list_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';
import '../exam/available_exam_controller.dart';
import '../exam/exam_list_controller.dart';

class HomeController extends GetxController {
  var examList = <LatestExam>[].obs;
  var bannerImagesList = <BannerImages>[].obs;
  //var availableExamList = <AvailableExam>[].obs;
  var notificationsList = <AppNotification>[].obs;
  var errorMessage = ''.obs;
  var errorMessageNoti = ''.obs;
  var errorMessagel = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingl = true.obs;
  RxBool isLoadingNoti = true.obs;
  RxString imageLink = "".obs;
  final examListController = Get.put(AvilableExamController());

  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBannerImages(context: Get.context!);
      fetchNotification(context: Get.context!);
    });

    //  // fetchAvailableExam(context: Get.context!);
    //   fetchNotification(context: Get.context!);
  }

  Future<void> fetchLatestexam({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      isLoadingl.value = true;
      errorMessagel.value = '';

      // final jsonBody = Createjson().createJsonForGetProduct(
      //   "10",
      //   offset.value,
      //   "",
      //   filterProductId.value,
      //   filterCompanyId.value,
      //   filterPackagingTypeId.value,
      // );
      final jsonBody = {
        "user_type": AppUtility.userType,
        "user_id": AppUtility.userID,
        "test_id": "",
        "attempted_test_id": "",
        "limit": "",
        "offset": "",
      };
      List<GetExamResultListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.latestexamApi,
                Networkutility.latestexam,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetExamResultListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final exam = response[0].data;
          print("exam");
          for (var ex in exam) {
            examList.add(
              LatestExam(
                testName: ex.testName,
                totalQuestion: int.parse(ex.totalQuestions),
                correct: ex.correct,
                incorrect: ex.incorrect,
                testid: ex.testId,
                attemptid: ex.attemptedTestId,
              ),
            );
          }
        }
      } else {
        errorMessagel.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      errorMessagel.value = e.message;
    } on TimeoutException catch (e) {
      errorMessagel.value = e.message;
    } on HttpException catch (e) {
      errorMessagel.value = '${e.message} (Code: ${e.statusCode})';
    } on ParseException catch (e) {
      errorMessagel.value = e.message;
    } catch (e) {
      errorMessagel.value = 'Unexpected error: $e';
    } finally {
      isLoadingl.value = false;
    }
  }

  Future<void> fetchBannerImages({
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
      List<GetBannerImagesResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.bannerImagesApi,
                Networkutility.bannerImages,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetBannerImagesResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final images = response[0].data;
          log("Dtaa=============>${images.first.bannerImage}");
          imageLink.value = response[0].imageLink
              .replaceAll(r'\/', '/')
              .replaceAll(r'\:', ':');
          for (var img in images) {
            bannerImagesList.add(
              BannerImages(
                bannerName: img.bannerName,
                bannerImage: img.bannerImage,
                id: img.id,
              ),
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

  // Future<void> fetchAvailableExam({
  //   required BuildContext context,
  //   bool reset = false,
  //   bool isPagination = false,
  //   bool forceFetch = false,
  // }) async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';

  //     // final jsonBody = Createjson().createJsonForGetProduct(
  //     //   "10",
  //     //   offset.value,
  //     //   "",
  //     //   filterProductId.value,
  //     //   filterCompanyId.value,
  //       Networkutility.availbleExamApi,
  //       Networkutility.availbleExam,
  //       jsonEncode(jsonBody),
  //       context,
  //     )) as List<GetAvailableExamResponse>?;

  //     if (response != null && response.isNotEmpty) {
  //       if (response[0].status == true || response[0].status == false) {
  //         final exams = response[0].data;
  //         for (var ex in exams) {
  //           availableExamList.add(AvailableExam(
  //               examId: ex.examId,
  //               image: ex.image,
  //               examName: ex.examName,
  //               examTime: ex.examTime,
  //               totalQuestions: ex.totalQuestions,
  //               description: ex.description));
  //         }
  //       }
  //     } else {
  //       errorMessage.value = 'No response from server';
  //     }
  //   } on NoInternetException catch (e) {
  //     errorMessage.value = e.message;
  //   } on TimeoutException catch (e) {
  //     errorMessage.value = e.message;
  //   } on HttpException catch (e) {
  //     errorMessage.value = '${e.message} (Code: ${e.statusCode})';
  //   } on ParseException catch (e) {
  //     errorMessage.value = e.message;
  //   } catch (e) {
  //     errorMessage.value = 'Unexpected error: $e';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchNotification({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      isLoadingNoti.value = true;
      errorMessageNoti.value = '';

      // final jsonBody = Createjson().createJsonForGetProduct(
      //   "10",
      //   offset.value,
      //   "",
      //   filterProductId.value,
      //   filterCompanyId.value,
      //   filterPackagingTypeId.value,
      // );
      final jsonBody = {
        {
          "user_id": AppUtility.userID,
          "user_type": AppUtility.userType,
          "test_id": "",
          "single_id": "",
          "limit": "",
          "offset": "",
        },
      };
      List<GetAllNotificationsResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.notificationsApi,
                Networkutility.notifications,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetAllNotificationsResponse>?;
      log("call");
      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final notification = response[0].data;
          for (var noti in notification) {
            notificationsList.add(
              AppNotification(
                id: noti.id,
                userId: noti.userId,
                attemptedTestId: noti.attemptedTestId,
                notificationTitle: noti.notificationTitle,
                notification: noti.notification,
                landingPage: noti.landingPage,
                createdOn: noti.createdOn,
              ),
            );
          }
        }
      } else {
        errorMessageNoti.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      errorMessageNoti.value = e.message;
    } on TimeoutException catch (e) {
      errorMessageNoti.value = e.message;
    } on HttpException catch (e) {
      errorMessageNoti.value = '${e.message} (Code: ${e.statusCode})';
    } on ParseException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessageNoti.value = 'Unexpected error: $e';
    } finally {
      isLoadingNoti.value = false;
    }
  }

  Future<void> refreshAllData({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset all lists
      examList.clear();
      bannerImagesList.clear();
      examListController.examDetailList.clear();
      notificationsList.clear();
      errorMessage.value = '';

      // Set loading states
      if (showLoading) {
        isLoading.value = true;
        isLoadingNoti.value = true;
      }

      // Create a list of all fetch operations
      final fetchOperations = <Future<void>>[
        fetchLatestexam(context: context, reset: true, forceFetch: true),
        fetchBannerImages(context: context, reset: true, forceFetch: true),
        examListController.fetchallExam(
          context: context,
          reset: true,
          forceFetch: true,
        ),
        // fetchNotification(context: context, reset: true, forceFetch: true),
      ];

      // Execute all fetch operations concurrently
      await Future.wait(fetchOperations);

      // Optional: Show success message
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Data refreshed successfully',
        //   backgroundColor: AppColors.successColor ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh data: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
        isLoadingNoti.value = false;
      }
    }
  }

  void logout() {
    AppUtility.clearUserInfo().then((_) {
      Get.offAllNamed(AppRoutes.login); // Navigate to login screen after logout
    });
  }

  // RxBool isLoading = true.obs;
  // Future<void> fetchBannerImages({
  //   BuildContext? context,
  // }) async {
  //   try {

  //     final apiUrl="https://run.mocky.io/v3/32ddd598-2768-4345-aa5b-be6faec79689";
  //     final jsonBody = {
  //       "user_type": "Student",
  //     };

  //     isLoading.value = true;
  //     // ProgressDialog.showProgressDialog(context);
  //     // final jsonBody = Createjson().createJsonForLogin(
  //     //   mobileNumber.value,
  //     //   'dummy_push_token', // Replace with actual push token
  //     //   'dummy_device_id', // Replace with actual device ID
  //     //   password.value,
  //     // );
  //     List<Object?>? list = await Networkcall().postMethod(
  //       Networkutility.bannerImagesApi,
  //       Networkutility.bannerImages,
  //       jsonEncode(jsonBody),
  //       Get.context!,
  //     );

  //     if (list != null && list.isNotEmpty) {
  //       List<GetBannerImagesResponse> response = List.from(list);
  //       if (response[0].status == true) {
  //         // final user = response[0].data;
  //         // await AppUtility.setUserInfo(
  //         //  user.
  //         // );

  //         // Get.offNamed('/dashboard');
  //       } else {
  //         Get.snackbar('Error', response[0].message,
  //             backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //       }
  //     } else {
  //       Get.back();
  //       Get.snackbar('Error', 'No response from server',
  //           backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //     }
  //   } on NoInternetException catch (e) {
  //     Get.back();
  //     Get.snackbar('Error', e.message,
  //         backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //   } on TimeoutException catch (e) {
  //     Get.back();
  //     Get.snackbar('Error', e.message,
  //         backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //   } on HttpException catch (e) {
  //     Get.back();
  //     Get.snackbar('Error', '${e.message} (Code: ${e.statusCode})',
  //         backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //   } on ParseException catch (e) {
  //     Get.back();
  //     Get.snackbar('Error', e.message,
  //         backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //   } catch (e) {
  //     Get.back();
  //     Get.snackbar('Error', 'Unexpected errorColor: $e',
  //         backgroundColor: AppColors.errorColor, colorText: Colors.white);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
