import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/result_list/result_overview_contoller.dart';
import '../../controller/result_list/test_result_controller.dart';
import '../../utility/app_routes.dart';

class ResultScreen extends StatefulWidget {
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final controller = Get.put(TestResult());
  DateTime? _lastPressedAt; // For double-back-press-to-exit

  @override
  void initState() {
    super.initState();
    controller.isLoading.value = true;
    final args = Get.arguments;
    print('ResultScreen: Arguments received: $args');
    if (args != null &&
        args is Map &&
        args.containsKey('test_id') &&
        args.containsKey('attempted_test_id')) {
      final testId = args['test_id'] as String?;
      final attemptCount = args['attempted_test_id'] as String?;
      if (testId != null && attemptCount != null) {
        controller.fetchResult(
          context: context,
          testID: testId,
          attemptid: attemptCount,
        );
      } else {
        controller.errorMessage.value = 'Invalid test or attempt ID';
        controller.isLoading.value = false;
      }
    } else {
      controller.errorMessage.value = 'No test or attempt ID provided';
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double fontScale = screenWidth / 375;
    final double horizontalPadding = screenWidth * 0.05;
    final double verticalPadding = screenHeight * 0.02;
    final bottomController = Get.put(BottomNavigationController());
    return WillPopScope(
      onWillPop: () async {
        // print(
        //   'Main: WillPopScope triggered, current route: ${Get.currentRoute}, nav stack: ${Get.nestedKey(Get.currentRoute)?.navigator?.widget.pages}',
        // );
        if (Get.currentRoute != AppRoutes.home &&
            Get.currentRoute != AppRoutes.splash) {
          print('Main: Navigating to home');
          bottomController.selectedIndex.value = 0;
          Get.offAllNamed(AppRoutes.home);
          return false;
        }
        if (Get.currentRoute == AppRoutes.home) {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt!) >
                  Duration(seconds: 2)) {
            _lastPressedAt = DateTime.now();
            Get.snackbar(
              'Exit',
              'Press back again to exit',
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 2),
            );
            return false;
          }
          print('Main: On home, allowing app exit');
          return true;
        }
        print('Main: On splash, navigating to home');
        bottomController.selectedIndex.value = 0;
        Get.offAllNamed(AppRoutes.home);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              bottomController.selectedIndex.value = 0;
              Get.offAllNamed(AppRoutes.home);
            },
          ),
          title: Text(
            'Result',
            style: TextStyle(color: Colors.black, fontSize: 20 * fontScale),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: screenHeight * 0.06,
          shape: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: horizontalPadding),
              child: GestureDetector(
                onTap: () {
                  if (controller.resultList.isNotEmpty) {
                    final ResultOverviewContoller overvewController = Get.put(
                      ResultOverviewContoller(),
                    );
                    overvewController.setTestid(
                      controller.resultList.first.testId,
                      controller.resultList.first.attemptedTestId,
                    );
                    Get.toNamed(AppRoutes.overview);
                  } else {
                    Get.snackbar(
                      'Error',
                      'No result data available to view overview',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPadding * 0.5,
                    horizontal: horizontalPadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    border: Border.all(color: Color(0xFFE5E7EB), width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Icon(
                        Icons.visibility,
                        color: Colors.black,
                        size: 20 * fontScale,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Obx(
          () => Padding(
            padding: EdgeInsets.only(top: verticalPadding),
            child:
                controller.isLoading.value
                    ? _buildShimmerEffect(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      fontScale: fontScale,
                      horizontalPadding: horizontalPadding,
                      verticalPadding: verticalPadding,
                    )
                    : controller.errorMessage.value.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16 * fontScale,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: verticalPadding),
                          ElevatedButton(
                            onPressed: () {
                              final args = Get.arguments;
                              final testId = args['test_id'] as String?;
                              final attemptCount =
                                  args['attempted_test_id'] as String?;
                              if (testId != null && attemptCount != null) {
                                controller.fetchResult(
                                  context: context,
                                  testID: testId,
                                  attemptid: attemptCount,
                                );
                              }
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : controller.resultList.isEmpty
                    ? Center(
                      child: Text(
                        'No result data available',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16 * fontScale,
                        ),
                      ),
                    )
                    : controller.resultList.isNotEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          controller.resultList.first.examStatus == "Passed"
                              ? 'assets/smily.png'
                              : 'assets/sad.png',

                          width: screenWidth * 0.3,
                          height: screenHeight * 0.13,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: verticalPadding,
                              horizontal: horizontalPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              border: Border.all(
                                color: Color(0xFFE5E7EB),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Score  |  ${controller.resultList.first.yourScore}/${controller.resultList.first.scoreOutoff}',
                              style: TextStyle(
                                fontSize: 18 * fontScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.018),
                        Container(
                          padding: EdgeInsets.all(horizontalPadding),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFF3F3F4),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.resultList.first.testName,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF353B43),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildResultCard(
                                    'TOTAL QUESTION',
                                    controller.resultList.first.totalQuestions
                                        .toString(),
                                    Colors.yellow[100]!,
                                    Color(0xFFCA8A04),
                                    Color(0xFFF4C542),
                                    fontScale,
                                    screenWidth,
                                    screenHeight,
                                  ),
                                  SizedBox(width: screenWidth * 0.025),
                                  _buildResultCard(
                                    'CORRECT',
                                    controller.resultList.first.correct
                                        .toString(),
                                    Colors.green[100]!,
                                    Color(0xFF3A954E),
                                    Color(0xFF6BC082),
                                    fontScale,
                                    screenWidth,
                                    screenHeight,
                                  ),
                                  SizedBox(width: screenWidth * 0.025),
                                  _buildResultCard(
                                    'INCORRECT',
                                    controller.resultList.first.incorrect
                                        .toString(),
                                    Colors.red[100]!,
                                    Color(0xFFDC2626),
                                    Color(0xFFF46666),
                                    fontScale,
                                    screenWidth,
                                    screenHeight,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    controller.resultList.first.examStatus ==
                                            "Passed"
                                        ? Colors.green[600]
                                        : Colors.red,
                                padding: EdgeInsets.symmetric(
                                  vertical: verticalPadding * 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                controller.resultList.first.examStatus,
                                style: TextStyle(
                                  fontSize: 16 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect({
    required double screenWidth,
    required double screenHeight,
    required double fontScale,
    required double horizontalPadding,
    required double verticalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: verticalPadding),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.3,
              height: screenHeight * 0.13,
              color: Colors.white,
            ),
            SizedBox(height: screenHeight * 0.025),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Container(
                width: double.infinity,
                height: 40 * fontScale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFE5E7EB), width: 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.018),
            Container(
              padding: EdgeInsets.all(horizontalPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFF3F3F4), width: 1.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200 * fontScale,
                    height: 16 * fontScale,
                    color: Colors.white,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: screenWidth * 0.25,
                        height: 60 * fontScale,
                        color: Colors.white,
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      Container(
                        width: screenWidth * 0.25,
                        height: 60 * fontScale,
                        color: Colors.white,
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      Container(
                        width: screenWidth * 0.25,
                        height: 60 * fontScale,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Container(
                width: double.infinity,
                height: 50 * fontScale,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    Color backgroundColor,
    Color valueColor,
    Color borderColor,
    double fontScale,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.025,
        horizontal: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: screenWidth * 0.2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12 * fontScale,
                color: AppColors.textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(height: screenHeight * 0.006),
          Text(
            value,
            style: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
