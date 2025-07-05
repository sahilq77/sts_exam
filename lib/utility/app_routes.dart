import 'package:get/get.dart';
import 'package:stsexam/utility/customdesign/nointernetconnectionpage.dart';
import 'package:stsexam/view/results/view_result_screen.dart';
import '../binding/start_exam_binding.dart';
import '../view/exam/exam_details.dart';
import '../view/exam/exam_instruction.dart';
import '../view/exam/exam_list_screen.dart';
import '../view/exam/startexam.dart';
import '../view/forgotpassword/forgot_password_page.dart';
import '../view/home/homepage.dart';
import '../view/notification/notifications.dart';
import '../view/login/loginPage.dart';
import '../view/payments/payment_receipt_details_screen.dart';
import '../view/payments/payments_list.dart';
import '../view/profile/profile_screen.dart';
import '../view/profile/update_profile.dart';
import '../view/results/overview.dart';
import '../view/results/results.dart';
import '../view/results/results_list.dart';
import '../view/signUp/signUp_page.dart';
import '../view/splash/splash.dart';

//created by sahil
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotpassword = '/forgot_password';
  static const String signUp = '/signUp';
  static const String home = '/home';
  static const String result = '/result';
  static const String PaymentReceipt = '/payment_recipt';
  static const String myprofile = '/my_profile';
  static const String updateprofile = '/update_profile';
  static const String notification = '/notification';
  static const String examdetail = '/exam_detail';
  static const String examInstruction = '/exam_instruction';
  static const String examlist = '/exam_list';
  static const String startexam = '/start_exam';
  static const String overview = '/overview';
  static const String testresult = '/testresult';
  static const String noInternet = '/nointernet';
  static const String viewResult = '/view_result';
  static const String paymentReceiptdetail = '/payment_receipt_detail';

  static final routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotpassword,
      page: () => ForgotPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signUp,
      page: () => SignupPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: result,
      page: () => ResultListPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PaymentReceipt,
      page: () => PaymentReceiptScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: myprofile,
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: updateprofile,
      page: () => UpdateProfile(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notification,
      page: () => NotificationPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: examdetail,
      page: () => ExamDetailPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: examInstruction,
      page: () => ExamInstruction(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: examlist,
      page: () => ExamListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: startexam,
      page: () => StartExamPage(),
      transition: Transition.fadeIn,
      binding: StartExamBinding(),
    ),
    GetPage(
      name: overview,
      page: () => OverviewPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: testresult,
      page: () => ResultScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: testresult,
      page: () => NoInternetPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: viewResult,
      page: () => ViewResultScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: paymentReceiptdetail,
      page: () => PaymentReceiptDetailsScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
