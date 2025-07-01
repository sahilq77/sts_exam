import 'package:get/get.dart';
import 'package:stsexam/controller/exam/start_exam_controller.dart';

class StartExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StartExamController>(() => StartExamController());
  }
}
