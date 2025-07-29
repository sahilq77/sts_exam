import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stsexam/core/network/exceptions.dart';
import '../../model/exam/available_exam_list_response.dart';
import '../../model/exam/get_all_questions_response.dart';
import '../../model/exam/get_buy_response.dart';
import '../../model/exam/get_exam_detail_response.dart';
import '../../model/exam/get_exam_instruction_response.dart';
import '../../model/exam/test_submit_response.dart';
import '../../model/globoal_model/get_city_response.dart';
import '../../model/globoal_model/get_state_response.dart';
import '../../model/home/banner_images_response.dart';
import '../../model/home/get_available_exam_response.dart';
import '../../model/home/get_notifications_response.dart';
import '../../model/home/latest_exam_response.dart';
import '../../model/login/get_login_response.dart';
import '../../model/payments/get_payments_receipt_response.dart';
import '../../model/payments/payment_receipt_link_response.dart';
import '../../model/profile/get_delete_user_response.dart';
import '../../model/profile/get_profile_response.dart';
import '../../model/result_list/get_downloadresult_response.dart';
import '../../model/result_list/get_result_list_response.dart';
import '../../model/result_list/get_result_overview_response.dart';
import '../../model/signUp/signUp_response.dart';
import '../../utility/app_routes.dart';
import '../../utility/network_connectivity/connectivityservice.dart';

class Networkcall {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  static GetSnackBar? _slowInternetSnackBar;
  static const int _minResponseTimeMs =
      3000; // Threshold for slow internet (3s)
  static bool _isNavigatingToNoInternet = false; // Prevent multiple navigations

  Future<List<Object?>?> postMethod(
    int requestCode,
    String url,
    String body,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _navigateToNoInternet();
        return null;
      }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make POST request with timeout
      var response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body.isEmpty ? null : body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;
      if (response.statusCode == 200) {
        log("url : $url \n Request body : $body \n Response : $data");

        // Wrap response in [] for consistency
        String str = "[${response.body}]";

        switch (requestCode) {
          case 1:
            final signUpResponse = getRegisterResponseFromJson(str);
            return signUpResponse;
          case 2:
            final login = getLoginResponseFromJson(str);
            return login;
          //     case 3:
          //     final bannerImages = getBannerImagesResponseFromJson (str);
          //     return [bannerImages];
          case 4:
            final bannerResponse = getBannerImagesResponseFromJson(str);
            return bannerResponse;
          case 5:
            final latestExamResult = getExamResultListResponseFromJson(str);
            return latestExamResult;
          case 6:
            final getallExamList = availableExamListResponseFromJson(str);
            return getallExamList;
          case 7:
            final notifcation = getAllNotificationsResponseFromJson(str);
            return notifcation;
          case 8:
            final resulList = getExamResultListResponseFromJson(str);
            return resulList;
          case 9:
            final paymentReciptList = getPaymentListResponseFromJson(str);
            return paymentReciptList;
          case 10:
            final examDetail = getExamDetailResponseFromJson(str);
            return examDetail;
          case 11:
            final examInstruction = getExamInstructionResponseFromJson(str);
            return examInstruction;
          case 13:
            final getCity = getCityResponseFromJson(str);
            return getCity;
          case 14:
            final getProfile = getUserProfileResponseFromJson(str);
            return getProfile;
          case 16:
            final getAllquestions = getAllQuestionsResponseFromJson(str);
            return getAllquestions;
          case 17:
            final testSubmit = testSubmitResponseFromJson(str);
            return testSubmit;
          case 18:
            final testoverview = getOverviewResponseFromJson(str);
            return testoverview;
          case 19:
            final buyexam = getBuyResponseFromJson(str);
            return buyexam;
          case 20:
            final downloadResult = getDownloadResultResoponseFromJson(str);
            return downloadResult;
          case 21:
            final downloadResult = getPaymentReceiptLinkResponseFromJson(str);
            return downloadResult;
          case 22:
            final downloadResult = getDeleteUserResponseFromJson(str);
            return downloadResult;

          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Request body : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      Get.snackbar(
        'Request Timed Out',
        'The server took too long to respond. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    }
  }

  Future<List<Object?>?> getMethod(
    int requestCode,
    String url,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await _navigateToNoInternet();
        return null;
      }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make GET request with timeout
      var response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;
      log(url);
      if (response.statusCode == 200) {
        log("url : $url \n Response : $data");
        String str = "[${response.body}]";
        switch (requestCode) {
          case 12:
            final getCities = getStateResponseFromJson(str);
            return getCities;
          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Response : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Response : $e");
      Get.snackbar(
        'Request Timed Out',
        'The server took too long to respond. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Response : $e");
      return null;
    }
  }

  Future<void> _navigateToNoInternet() async {
    if (!_isNavigatingToNoInternet &&
        Get.currentRoute != AppRoutes.noInternet) {
      _isNavigatingToNoInternet = true;
      // Double-check connectivity before navigating
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await Get.offNamed(AppRoutes.noInternet);
      }
      // Reset flag after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      _isNavigatingToNoInternet = false;
    }
  }

  void _handleSlowInternet(int responseTimeMs) {
    if (responseTimeMs > _minResponseTimeMs) {
      // Show slow internet snackbar if not already shown
      if (_slowInternetSnackBar == null || !Get.isSnackbarOpen) {
        _slowInternetSnackBar = const GetSnackBar(
          message:
              'Slow internet connection detected. Please check your network.',
          duration: Duration(days: 1), // Persistent until closed
          backgroundColor: Colors.orange,
          snackPosition: SnackPosition.TOP,
          isDismissible: false,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
        );
        Get.showSnackbar(_slowInternetSnackBar!);
      }
    } else {
      // Close slow internet snackbar if connection improves
      if (_slowInternetSnackBar != null && Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        _slowInternetSnackBar = null;
      }
    }
  }
}
