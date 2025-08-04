import 'package:get/get.dart';

import '../../utility/app_routes.dart';

class BottomNavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<String> routes = [
    AppRoutes.home,
    AppRoutes.result,
    AppRoutes.PaymentReceipt,
    AppRoutes.myprofile,
  ];

  @override
  void onInit() {
    super.onInit();
    syncIndexWithRoute(Get.currentRoute);
    ever(Rx<String?>(Get.routing.current), (route) {
      if (route != null) {
        syncIndexWithRoute(route);
      }
    });
  }

  void syncIndexWithRoute(String? route) {
    if (route == null) {
      print('Route is null, keeping current index: ${selectedIndex.value}');
      return;
    }
    final index = routes.indexOf(route);
    if (index != -1) {
      selectedIndex.value = index;
    }
  }

  void changeTab(int index) {
    if (index < 0 || index >= routes.length) {
      print('Invalid index: $index');
      return;
    }
    if (index == 0) {
      selectedIndex.value = 0;
      Get.offAllNamed(routes[0]);
    } else if (selectedIndex.value != index) {
      selectedIndex.value = index;
      Get.offAllNamed(routes[index]);
    }
  }

  void goToHome() {
    selectedIndex.value = 0;
    Get.offAllNamed(AppRoutes.home);
  }

   Future<bool> onWillPop() async {
    if (Get.nestedKey(1)?.currentState?.canPop() ?? false) {
      Get.back(id: 1); // Pop within the current tab's stack
      return false; // Prevent app exit
    }
    if (selectedIndex.value != 0) {
      goToHome(); // Go to Home tab if not already there
      return false; // Prevent app exit
    }
    return true; // Allow app exit if on Home tab with no stack
  }
}
