import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stsexam/notification_services%20.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stsexam/app_colors.dart';
import 'package:stsexam/controller/bottomnavigation/bottom_navigation_controller.dart';

import 'package:stsexam/utility/network_connectivity/connectivityservice.dart';
import 'package:stsexam/firebase_options.dart';
import 'package:stsexam/utility/app_routes.dart';
import 'package:stsexam/core/network/networkcall.dart';
import 'package:stsexam/utility/app_utility.dart';

// WorkManager callback dispatcher
const String examTaskKey = "com.stsexam.examTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == examTaskKey) {
      print("WorkManager: Running exam task with input data: $inputData");
      try {
        // Load exam state from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final testId = inputData?['testId'] ?? prefs.getString('testId') ?? '';
        final switchAttemptCount = int.parse(
          inputData?['switchAttemptCount'] ??
              prefs.getString('switchAttemptCount') ??
              '0',
        );
        final maxAttempts =
            inputData?['maxAttempts'] ?? prefs.getInt('maxAttempts') ?? 3;

        if (switchAttemptCount >= maxAttempts) {
          print("WorkManager: Auto-submitting exam for testId: $testId");
          // Perform API call to submit exam
          final jsonBody = {
            "user_id": AppUtility.userID,
            "user_type": AppUtility.userType,
            "test_id": testId,
            "attempted_test_id":
                inputData?['attempt'] ?? prefs.getString('attempt') ?? '0',
            "submitted_on": DateTime.now().toString(),
            "answer_list": [], // Fetch from storage if needed
            "switch_attempt_count": switchAttemptCount.toString(),
            "duration": "00:00:00",
            "face_detection_warnings":
                prefs.getString('faceDetectionWarningCount') ?? '0',
          };
          // Uncomment and implement the actual network call
          // await Networkcall().postMethod(
          //   Networkutility.testSubmitApi,
          //   Networkutility.testSubmit,
          //   jsonEncode(jsonBody),
          //   null, // Context is not available in background
          // );
        } else {
          print(
            "WorkManager: Exam still active, switch attempts: $switchAttemptCount",
          );
        }
      } catch (e) {
        print("WorkManager: Error in task: $e");
      }
    }
    return Future.value(true); // Indicate task success
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize WorkManager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set to false in production
  );

  final NotificationServices notificationServices = NotificationServices();
  notificationServices.isTokenRefresh();
  Get.lazyPut<BottomNavigationController>(
    () => BottomNavigationController(),
    fenix: true,
  );
  Get.put(ConnectivityService(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BottomNavigationController bottomController =
        Get.find<BottomNavigationController>();
    return GetMaterialApp(
      title: 'Vidya Sarthi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(scrolledUnderElevation: 0.0),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primaryColor,
          secondary: AppColors.primaryColor,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      builder: (context, child) {
        return ColorfulSafeArea(
          color: AppColors.backgroundColor,
          top: true,
          bottom: true,
          left: false,
          right: false,
          child: child ?? Container(),
        );
      },
    );
  }
}
