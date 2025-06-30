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
  // Function to handle the refresh logic
  Future<void> _refresh() async {
    // Simulate a network call or data refresh (e.g., fetching updated instructions)
    await Future.delayed(const Duration(seconds: 2));
    // Optionally update state if needed
    setState(() {
      // Update any state variables if necessary
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamDetailController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchExamDetail(context: context);
    });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.back();
              controller.clearSelectedExamid();
              controller.examDetailList.clear();
            }),
        title: const Text(
          'Exam Instruction',
          style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshResultList(
            context: context), // Called when the user pulls down to refresh
        color: AppColors.primaryColor, // Color of the refresh indicator
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensures scrollability
          child: Obx(() {
            final ins = controller.examDetailList;
            if (ins.isEmpty) {
              return const ExamDetailShimmer();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                // Image Section
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl:
                          "${controller.imageLink.value}${controller.examDetailList[0].testImage.toString()}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, size: 50),
                    ),
                  ),
                ),

                ///const SizedBox(height: 10),
                const SizedBox(height: 15),
                // Title

                Text(
                  ins[0].testName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 5),
                // Duration and Questions
                Text(
                  '${ins[0].duration} min | ${ins[0].questionCount} Question',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryColor),
                ),
                const SizedBox(height: 15),
                // Description
                const Text(
                  'Please read the text below carefully so you can understand it',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor),
                ),
                // const SizedBox(height: 20),
                Html(
                  data: (ins[0]
                      .instructionDescription
                      .replaceAll(r'\r\n', '<br>')),
                  style: TextDesign.commonStyles,
                ),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     // Bullet with precise indent
                //     const Text(
                //       '•  ',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w400,
                //         color: Colors.black54,
                //       ),
                //     ),
                //     // Instruction Text
                //     Expanded(
                //       child: Text(
                //         ins[0].instructionDescription,
                //         style: const TextStyle(
                //           fontSize: 13,
                //           fontWeight: FontWeight.w400,
                //           color: Colors.black54,
                //           height: 1.2, // Tighter spacing to match the image
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // Instruction Bullet Points
                // ...ins[0]..map((instruction) => Padding(
                //       padding: const EdgeInsets.only(bottom: 10, left: 5),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           // Bullet with precise indent
                //           const Text(
                //             '•  ',
                //             style: TextStyle(
                //               fontSize: 14,
                //               fontWeight: FontWeight.w400,
                //               color: Colors.black54,
                //             ),
                //           ),
                //           // Instruction Text
                //           Expanded(
                //             child: Text(
                //               instruction,
                //               style: const TextStyle(
                //                 fontSize: 13,
                //                 fontWeight: FontWeight.w400,
                //                 color: Colors.black54,
                //                 height:
                //                     1.2, // Tighter spacing to match the image
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     )),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 79,
        child: ElevatedButton(
          onPressed: () {
            final StartExamController starttestController = Get.put(
              StartExamController(),
            );

            final ins = controller.examDetailList;
            print("EX ID ${ins[0].id}");
            starttestController.setTestid(ins[0].id);
            Get.offNamed(AppRoutes.startexam, arguments: {
              "test_id": ins[0].id,
              "attempted_count": ins[0].attemptCount
            });
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
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
