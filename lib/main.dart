import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stsexam/app_colors.dart';
import 'package:stsexam/controller/bottomnavigation/bottom_navigation_controller.dart';
import 'package:stsexam/firebase_options.dart';
import 'package:stsexam/notification_services%20.dart';
import 'package:stsexam/utility/network_connectivity/connectivityservice.dart';
import 'utility/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final NotificationServices notificationServices = NotificationServices();
  // notificationServices.requestNotificationPermission();
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
    return GetMaterialApp(
      title: 'STS Exam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(scrolledUnderElevation: 0.0),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Color(0xFFF5F5F5), // Example background color
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
          color: AppColors.backgroundColor, // Matches AppBar background color
          top: true,
          bottom: true, // Only apply SafeArea to top for AppBar
          left: false,
          right: false,
          child: child ?? Container(),
        );
      },
      // home: CustomFormWidgets(),
    );
  }
}
