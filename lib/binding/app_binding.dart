import 'package:get/get.dart';

import '../utility/customdesign/connctivityservice.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ConnectivityService>(ConnectivityService());
  }
}
