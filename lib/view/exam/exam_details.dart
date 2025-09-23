import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_colors.dart';
import '../../controller/exam/buy_exam_controller.dart';
import '../../controller/exam/exam_detail_controller.dart';
import '../../controller/exam/payment_controller.dart';
import '../../utility/app_routes.dart';
import 'exam_instruction.dart';
import 'startexam.dart';

class ExamDetailPage extends StatefulWidget {
  const ExamDetailPage({super.key});

  @override
  State<ExamDetailPage> createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage> {
  final controller = Get.put(ExamDetailController());
  final buyController = Get.put(PaymentController());

  String? _selectedOption;

  Future<void> _refresh() async {
    await controller.refreshResultList(context: context);
    setState(() {
      _selectedOption = null;
    });
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/success.png',
                width: 122,
                height: 135,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Successful !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your payment for the exam has been received. Proceed to the instructions to start your exam.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF353B43),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  Get.toNamed(
                    AppRoutes.examInstruction,
                  ); // Navigate to instructions
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Proceed to Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showatemptDialog(BuildContext context, int count) {
    // Function to get the correct ordinal suffix
    String getOrdinalSuffix(int number) {
      if (number % 10 == 1 && number % 100 != 11) return 'st';
      if (number % 10 == 2 && number % 100 != 12) return 'nd';
      if (number % 10 == 3 && number % 100 != 13) return 'rd';
      return 'th';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Get.toNamed(
                  AppRoutes.examInstruction,
                ); // Navigate to instructions
              },
              child: const Text(
                'Proceed to Instructions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/all_the_best.png',
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                'Good luck on your ${count + 1}${getOrdinalSuffix(count + 1)} exam attempt! Do your best!',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'All the best.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF353B43),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context != null) {
        controller.examDetailList.clear();
        Get.delete<ExamDetailController>();
      }
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.onClose();
            Get.back();
          },
        ),
        title: const Text(
          'Exam Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        child: Obx(() {
          if (controller.isLoading.value || controller.examDetailList.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: ExamDetailShimmer(),
            );
          }

          if (controller.examDetailList.isEmpty) {
            return const Center(child: Text('No exam details available'));
          }

          final exam = controller.examDetailList[0];
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl:
                            exam.testImage != null
                                ? "${controller.imageLink.value}${exam.testImage}"
                                : '',
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => Image.asset(
                              'assets/placeholder.png',
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exam.testName ?? 'No Title',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '${exam.duration ?? 'N/A'} min | ${exam.questionSCount.isEmpty ? exam.questionCount ?? "N/A" : exam.questionSCount} Question',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    exam.shortDescription ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Blur(
                    blur: 1,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          const Text(
                            'Question 01/50',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Name of the ACID used in lead acid cells?',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          _buildOption('Phosphoric Acid'),
                          _buildOption('Sulphuric Acid'),
                          _buildOption('Nitric Acid'),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.examDetailList.isEmpty) {
          return const SizedBox.shrink();
        }
        final exam = controller.examDetailList[0];
        int? testType;
        if (exam.testType == "0") {
          testType = exam.testType == "0" && exam.isAttempted == true ? 0 : 1;
        }
        if (exam.testType == "1") {
          testType = exam.testType == "1" && exam.isAttempted == true ? 2 : 3;
        }

        Color getColor() {
          switch (testType) {
            case 0:
              return AppColors.primaryColor;

            case 1:
              return AppColors.primaryColor;
            case 2:
              return Colors.grey;

            case 3:
              //  _showPaymentSuccessDialog(context);
              return AppColors.primaryColor;

            default:
              return AppColors.primaryColor;
          }
        }

        String getbuttonTitle() {
          switch (testType) {
            case 0:
              return "START EXAM FOR FREE";

            case 1:
              return "START EXAM FOR FREE";
            case 2:
              return "Already Attempted";

            case 3:
              //  _showPaymentSuccessDialog(context);
              return "START EXAM FOR RS ${exam.amount}";

            default:
              return "START EXAM FOR FREE";
          }
        }

        return SizedBox(
          height: 79,
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                getbuttonTitle() == "Already Attempted"
                    ? null
                    : () {
                      print("Testype ${exam.testType}");
                      print("Attempted ${exam.isAttempted}");
                      int? testType;
                      if (exam.testType == "0") {
                        testType =
                            exam.testType == "0" && exam.isAttempted == true
                                ? 0
                                : 1;
                      }
                      if (exam.testType == "1") {
                        testType =
                            exam.testType == "1" && exam.isAttempted == true
                                ? 2
                                : 3;
                      }

                      switch (testType) {
                        case 0:
                          _showatemptDialog(context, exam.attemptCount);
                          return print("attempted count");

                        case 1:
                          Get.toNamed(AppRoutes.examInstruction);
                          return print("fresher");
                        case 2:
                          return print("button disabled");

                        case 3:
                          buyController.getPaymentUrl(
                            context: context,
                            testid: exam.id,
                            amt: exam.amount,
                          );
                          // _showPaymentSuccessDialog(context);
                          return print("pay");

                        default:
                          print("default");
                      }
                      // if (exam.testType == "0" && exam.isAttempted == true) {
                      //   _showatemptDialog(context, exam.attemptCount);
                      // } else {
                      //   print("fresher");
                      //   // Get.toNamed(AppRoutes.examInstruction);
                      // }

                      // if (exam.testType == "1" && exam.isAttempted == true) {
                      //   print("Already attemted button disabled");
                      // } else {
                      //   _showPaymentSuccessDialog(context);
                      // }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: getColor(),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
            child: Text(
              getbuttonTitle(),
              style: const TextStyle(
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

  Widget _buildOption(String optionText) {
    bool isSelected = _selectedOption == optionText;
    bool isCorrect = optionText == 'Sulphuric Acid';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = optionText;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : const Color(0xFFBCBCBC),
            width: 1,
          ),
        ),
        child: Text(
          optionText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class ExamDetailShimmer extends StatelessWidget {
  static const double _smallPadding = 8.0;

  const ExamDetailShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 15, width: 200, color: Colors.grey[300]),
            const SizedBox(height: 5),
            Container(height: 13, width: 150, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Container(height: 13, width: 100, color: Colors.grey[300]),
            const SizedBox(height: 5),
            Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Container(height: 16, width: 100, color: Colors.grey[300]),
                const SizedBox(height: 5),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
