import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:rxdart/rxdart.dart';
import 'package:stsexam/controller/bottomnavigation/bottom_navigation_controller.dart';
import "dart:developer" as lg;

import 'package:stsexam/utility/app_routes.dart';

class NotificationServices {
  String? callId;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterlocalnotificationplugin =
      FlutterLocalNotificationsPlugin();

  static final onNotifications = BehaviorSubject<String?>();

  void requestNotificationPermission() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void initLocalNotifications(
    BuildContext context,
    RemoteMessage message,
  ) async {
    try {
      var androidInitialization = const AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      var iosInitialization = const DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: androidInitialization,
        iOS: iosInitialization,
      );

      // Initialize only with click action handling
      await flutterlocalnotificationplugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          // Check the notification response and handle navigation
          if (response != null && response.payload != null) {
            handleRemoteMessage(context, message);
          }
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void firebaseInit(BuildContext context) {
    try {
      FirebaseMessaging.onMessage.listen((message) {
        if (message.notification != null || message.data.isNotEmpty) {
          initLocalNotifications(context, message);
          showNotification(message);
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    try {
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'text_channel',
        importance: Importance.high,
      );

      AndroidNotificationDetails
      androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'Your channel Description',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        styleInformation: BigTextStyleInformation(''),
        //  sound: RawResourceAndroidNotificationSound('res_custom_message'),
        ticker: 'ticker',
      );

      DarwinNotificationDetails darwinNotificationDetails =
          const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      // Fetch title and body, prioritizing `message.notification` for compatibility
      String? title = message.notification?.title ?? message.data['title'];
      String? body = message.notification?.body ?? message.data['body'];

      // Display the notification only if title or body is not null
      if (title != null || body != null) {
        flutterlocalnotificationplugin.show(
          1,
          title ?? "No Title", // Default to "No Title" if null
          body ?? "No Body", // Default to "No Body" if null
          notificationDetails,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> getDevicetoken() async {
    String? token = await firebaseMessaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    try {
      firebaseMessaging.onTokenRefresh.listen((event) {
        event.toString();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> setInteractMessage(BuildContext context) async {
    //when app is termitted
    try {
      RemoteMessage? initialmessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialmessage != null) {
        handleRemoteMessage(context, initialmessage);
      }
      //when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        handleRemoteMessage(context, event);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void handleRemoteMessage(BuildContext context, RemoteMessage message) async {
    try {
      BottomNavigationController controller1 = Get.put(
        BottomNavigationController(),
      );
      lg.log("Controller1 initialized: ${controller1.selectedIndex}");

      String landingPage =
          message.data['landing_page']?.toString().toLowerCase() ?? 'default';
      String batchId = message.data['batch_id']?.toString() ?? '';
      String body = message.data['body']?.toString() ?? '';
      lg.log("$landingPage");
      RegExp regex = RegExp(r"result for '([^']*)'");
      Match? match = regex.firstMatch(body);
      String examName = match?.group(1) ?? '';

      lg.log("${message.data}");
      lg.log(landingPage);

      lg.log("Current route: ${Get.currentRoute}");
      lg.log("Context available: ${context != null}");
      lg.log(
        "Expected route: ${AppRoutes.home}",
      ); // Updated to homeContainer1Screen

      if (Get.currentRoute != AppRoutes.home) {
        // Updated to homeContainer1Screen
        lg.log("Navigating to HomeContainer1Screen");
        if (context == null) {
          lg.log("Context is null, cannot navigate");
          return;
        }
        try {
          Get.offAllNamed(AppRoutes.home); // Updated to homeContainer1Screen
          lg.log("Navigation to HomeContainer1Screen completed");
        } catch (navError) {
          lg.log("Navigation error: $navError");
          return;
        }
      } else {
        lg.log("Already on HomeContainer1Screen");
      }

      lg.log("Processing landing page: $landingPage");
      switch (landingPage) {
        case "upcoming test":
          controller1.goToHome();
          break;
        case "announcement":
          lg.log("Navigating to AnnouncementForStudent");
          Get.to(() => AppRoutes.home);
          lg.log("Navigation to AnnouncementForStudent completed");
          break;
        case "test_result_page":
          Get.to(() => AppRoutes.result);
          break;
        case "payment page":
          Get.to(() => AppRoutes.home);
          break;
        case "test result":
          Get.to(() => AppRoutes.home);
          break;
        case "my_attendance":
          controller1.goToHome();
          break;
        default:
          controller1.goToHome();
          break;
      }
    } catch (e) {
      lg.log("Error in handleRemoteMessage: $e");
    }
  }
}
