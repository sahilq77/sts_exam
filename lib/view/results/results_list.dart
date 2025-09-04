import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/result_list/result_list_controller.dart';
import '../../controller/result_list/result_overview_contoller.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../../utility/widgets/custom_shimmer.dart';
import '../bottomnavigation/custom_bottom_bar.dart';
import 'overview.dart';

class ResultListPage extends StatelessWidget {
  const ResultListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomController = Get.put(BottomNavigationController());
    final controller = Get.put(ResultListController());
    final ScrollController scrollController = ScrollController();

    // Add listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        print(
          'Main: WillPopScope triggered, current route: ${Get.currentRoute}, selectedIndex: ${bottomController.selectedIndex.value}',
        );
        if (Get.currentRoute != AppRoutes.home &&
            Get.currentRoute != AppRoutes.splash) {
          print('Main: Navigating to home');
          bottomController.selectedIndex.value = 0;
          Get.offAllNamed(AppRoutes.home);
          return false; // Prevent app exit
        }
        print('Main: On home or splash, allowing app exit');
        return true; // Allow app exit
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          automaticallyImplyLeading: true,
          title: const Text('Result List'),
          elevation: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,

        body: RefreshIndicator(
          onRefresh: () => controller.refreshResultList(context: context),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const CutsomShimmer();
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              itemCount:
                  controller.resultList.isEmpty
                      ? 1
                      : controller.resultList.length +
                          (controller.hasMoreData.value ||
                                  controller.isLoadingMore.value
                              ? 1
                              : 0),
              itemBuilder: (context, int index) {
                if (controller.resultList.isEmpty) {
                  return Center(child: Image.asset(AppImages.empty));
                }

                if (index == controller.resultList.length) {
                  return controller.isLoadingMore.value
                      ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No more data',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      );
                }

                var result = controller.resultList[index];
                return ResultCard(
                  resultView: () {
                    Get.toNamed(
                      AppRoutes.viewResult,
                      arguments: {"test_id": result.testId},
                    );
                  },
                  totalMarks: result.scoreOutoff,
                  resultDate: result.resultDate,
                  examName: result.testName,
                  totalScore: result.yourScore,
                  totalQuestions: result.totalQuestions,
                  correct: result.correct.toString(),
                  incorrect: result.incorrect.toString(),
                  status: result.examStatus,
                  statusColor:
                      result.examStatus == "Passed"
                          ? AppColors.successColor
                          : AppColors.errorColor,
                  onOverviewPressed: () {
                    final ResultOverviewContoller overvewController = Get.put(
                      ResultOverviewContoller(),
                    );

                    overvewController.setTestid(
                      result.testId,
                      result.attemptedTestId,
                    );
                    Get.toNamed(AppRoutes.overview);
                  },
                );
              },
            );
          }),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }
}

String formatToIndianDateTime(String dateString) {
  try {
    // Parse the string to DateTime (adjust format based on your resultDate)
    DateTime parsedDate = DateTime.parse(
      dateString,
    ); // For ISO 8601 format (e.g., "2025-08-06 17:15:00")

    // Format to Indian date and time (DD/MM/YYYY HH:mm:ss for 24-hour format)
    return DateFormat('dd/MM/yyyy HH:mm a').format(parsedDate);
    // For 12-hour format, use: DateFormat('dd/MM/yyyy hh:mm:ss a').format(parsedDate);
  } catch (e) {
    // Handle invalid date string
    return "Invalid Date";
  }
}

class ResultCard extends StatelessWidget {
  final String examName;
  final String totalMarks;
  final String totalScore;
  final String totalQuestions;
  final String correct;
  final String incorrect;
  final String status;
  final String resultDate;
  final Color statusColor;
  final VoidCallback onOverviewPressed;
  final VoidCallback resultView;
  const ResultCard({
    super.key,
    required this.examName,
    required this.resultDate,
    required this.totalMarks,
    required this.totalScore,
    required this.totalQuestions,
    required this.correct,
    required this.incorrect,
    required this.status,
    required this.statusColor,
    required this.onOverviewPressed,
    required this.resultView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      examName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onOverviewPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Overview',
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 14,
                            color: AppColors.textColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Questions',
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ': ${totalQuestions.toString().padLeft(2, '0')}',
                        style: GoogleFonts.blinker(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Text(
                          //   'Incorrect',
                          //   style: GoogleFonts.blinker(
                          //     fontSize: 15,
                          //     fontWeight: FontWeight.w400,
                          //     color: Colors.black87,
                          //   ),
                          // ),
                        ],
                      ),
                      // Text(
                      //   ': ${incorrect.toString().padLeft(2, '0')}',
                      //   style: GoogleFonts.blinker(
                      //     fontSize: 15,
                      //     fontWeight: FontWeight.w400,
                      //     color: Colors.black87,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),

          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Correct',
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ': ${correct.toString().padLeft(2, '0')}',
                        style: GoogleFonts.blinker(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Incorrect',
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ': ${incorrect.toString().padLeft(2, '0')}',
                        style: GoogleFonts.blinker(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Marks',
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ': ${totalMarks.toString().padLeft(2, '0')}',
                        style: GoogleFonts.blinker(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Score',
                            style: GoogleFonts.blinker(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ': ${totalScore.toString().padLeft(2, '0')}',
                        style: GoogleFonts.blinker(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Row(
              children: [
                Text(
                  'Exam Status',
                  style: GoogleFonts.blinker(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ':',
                  style: GoogleFonts.blinker(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: GoogleFonts.blinker(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: statusColor,
                  ),
                ),
                // const Spacer(),
                // InkWell(
                //   onTap: resultView,
                //   child: Icon(Icons.download, color: Colors.black87, size: 25),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 15),
            child: Row(
              children: [
                Text(
                  'Date',
                  style: GoogleFonts.blinker(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ':',
                  style: GoogleFonts.blinker(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatToIndianDateTime(resultDate),
                  style: GoogleFonts.blinker(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: resultView,
                  child: Icon(Icons.download, color: Colors.black87, size: 25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
