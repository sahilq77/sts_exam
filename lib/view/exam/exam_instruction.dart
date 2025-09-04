import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:stsexam/view/exam/exam_details.dart';
import '../../app_colors.dart';
import '../../controller/exam/exam_detail_controller.dart';
import '../../controller/exam/start_exam_controller.dart';
import '../../utility/app_routes.dart';
import '../../utility/widgets/html_text_design.dart';
import 'startexam.dart';

class ExamInstruction extends StatefulWidget {
  const ExamInstruction({super.key});

  @override
  State<ExamInstruction> createState() => _ExamInstructionState();
}

class _ExamInstructionState extends State<ExamInstruction> {
  final controller =
      Get.find<ExamDetailController>(); // Use Get.find instead of Get.put

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.fetchExamDetail(context: context); // Fetch exam details
      }
    });
  }

  Future<void> _refresh() async {
    await controller.refreshResultList(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
            controller.clearSelectedExamid();
            controller.examDetailList.clear();
          },
        ),
        title: const Text(
          'Exam Instruction',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(() {
            if (controller.isLoading.value ||
                controller.examDetailList.isEmpty) {
              return const ExamDetailShimmer();
            }
            final ins = controller.examDetailList;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl:
                          "${controller.imageLink.value}${ins[0].testImage.toString()}",
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  ins[0].testName ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${ins[0].duration ?? 'N/A'} min | ${ins[0].questionCount ?? 'N/A'} Questions',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Please read the text below carefully so you can understand it',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                Html(
                  data: ins[0].instructionDescription.replaceAll(
                    r'\r\n',
                    '<br>',
                  ),
                  style: TextDesign.commonStyles,
                ),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.examDetailList.isEmpty) {
          return const SizedBox.shrink();
        }
        final ins = controller.examDetailList;
        return SizedBox(
          height: 79,
          child: ElevatedButton(
            onPressed: () {
              final startExamController = Get.put(StartExamController());
              startExamController.setTestid(ins[0].id);
              Get.toNamed(
                AppRoutes.startexam,
                arguments: {
                  "test_id": ins[0].id,
                  "attempted_count": ins[0].attemptCount,
                },
              ); // Use Get.toNamed instead of Get.offNamed to preserve back navigation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
            child: const Text(
              'Start Your Exam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }
}
