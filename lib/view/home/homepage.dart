import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/exam/available_exam_controller.dart';
import '../../controller/exam/exam_detail_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../controller/result_list/result_overview_contoller.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../payments/payments_list.dart';
import '../profile/update_profile.dart';
import '../results/results_list.dart';
import '../bottomnavigation/custom_bottom_bar.dart';
import '../exam/exam_details.dart';
import '../notification/notifications.dart';
import '../sidebar/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final profileController = Get.put(ProfileController());
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  final controller = Get.put(HomeController());
  final examListController = Get.put(AvilableExamController());

  final List<String> _bannerImages = [
    AppImages.banner, // Replace with varied images
    AppImages.banner,
    AppImages.banner,
  ];

  // Standard padding for consistency
  static const double _standardPadding = 16.0;
  static const double _smallPadding = 8.0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _onRefresh();
        break;
      case 1:
        Get.toNamed(AppRoutes.result);
        break;
      case 2:
        Get.toNamed(AppRoutes.PaymentReceipt);
        break;
      case 3:
        Get.toNamed(AppRoutes.updateprofile);
        break;
    }
  }

  Future<void> _onRefresh() async {
    // await controller.fetchBannerImages(context: context);
    // controller.availableExamList.value.clear();
    // await controller.fetchLatestexam(context: context);
    // await controller.fetchAvailableExam(context: context);
    setState(() {
      _selectedIndex = 0;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _currentBannerIndex = 0;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchUserProfile(context: context);
      controller.fetchLatestexam(context: Get.context!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomController = Get.put(BottomNavigationController());

    // controller.fetchLatestexam(context: context);
    return Scaffold(
      drawer: Sidebar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      appBar: AppBar(
        title: Obx(() {
          if (profileController.isLoading.value &&
              profileController.userProfileList.isEmpty) {
            return Text("");
          }

          if (profileController.userProfileList.isEmpty) {
            return const Center(child: Text(""));
          }

          final user = profileController.userProfileList[0];
          print("Building with cityId: ${user.city}");

          return Text(
            'Hi! ${user.fullName} 😊',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          );
        }),

        // const Text(
        //   'Hi! VAISHNAVI 😊',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.w600,
        //     color: AppColors.textColor,
        //   ),
        // ),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          // Text(
          //   '${AppUtility.userID}',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.w600,
          //     color: AppColors.textColor,
          //   ),
          // ),
          // Text(
          //   '${AppUtility.userType}',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.w600,
          //     color: AppColors.textColor,
          //   ),
          // ),
          IconButton(
            icon: Image.asset(AppImages.bellIcon, width: 24, height: 24),
            tooltip: 'Notifications',
            onPressed: () {
              Get.toNamed(AppRoutes.notification);
              // TODO: Implement notification action
            },
          ),
        ],
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAllData(context: context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(_standardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerCarousel(),
                const SizedBox(height: 10),
                _buildLatestExamResultSection(controller),
                const SizedBox(height: 20),
                _buildAvailableExamsSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        Obx(
          () =>
              controller.isLoading.value && controller.bannerImagesList.isEmpty
                  ? CarouselShimmer(itemCount: 3)
                  : CarouselSlider(
                    options: CarouselOptions(
                      height: 190, // Fixed height for consistency
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      },
                    ),
                    items:
                        controller.bannerImagesList.value.map((imagePath) {
                          return Builder(
                            builder: (BuildContext context) {
                              String imageUrl =
                                  controller.imageLink.value +
                                  imagePath.bannerImage;
                              print(imageUrl);
                              return Container(
                                width: double.infinity,

                                // color: AppColors.primaryColor,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CarouselShimmer(itemCount: 3),
                                        ),
                                    errorWidget:
                                        (context, url, error) => const Center(
                                          child: Icon(
                                            Icons.error,
                                            color: AppColors.errorColor,
                                            size: 50,
                                          ),
                                        ),
                                    // Optional: Configure cache settings
                                    // maxWidthDiskCache: 600,
                                    // maxHeightDiskCache: 400,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
        ),
        const SizedBox(height: _smallPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              controller.bannerImagesList.asMap().entries.map((entry) {
                final int index = entry.key;
                return Container(
                  width: _currentBannerIndex == index ? 10.0 : 8.0,
                  height: _currentBannerIndex == index ? 10.0 : 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentBannerIndex == index
                            ? AppColors.primaryColor
                            : Colors.grey.withOpacity(0.5),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildLatestExamResultSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest exam result',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to results overview
                final ResultOverviewContoller overvewController = Get.put(
                  ResultOverviewContoller(),
                );

                overvewController.setTestid(
                  controller.examList.first.testid,
                  controller.examList.first.attemptid,
                );
                Get.toNamed(AppRoutes.overview);
              },
              style: TextButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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
                  SizedBox(width: 6),
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: AppColors.textColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: _smallPadding),
        Obx(() {
          if (controller.isLoadingl.value) {
            return LatestExamShmimmer();
          }

          if (controller.examList.isEmpty) {
            return Card(
              shape: RoundedRectangleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Test Data Available', // Static test name
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            AppColors.textColor, // Assumes AppColors is defined
                      ),
                    ),
                    SizedBox(height: 8.0), // Static value for _smallPadding
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildResultCard(
                                'Total Questions',
                                '0', // Static total questions
                                AppColors.warningColor,
                                maxWidth: constraints.maxWidth / 3,
                              ),
                            ),
                            SizedBox(
                              width: 8.0,
                            ), // Static value for _smallPadding
                            Expanded(
                              child: _buildResultCard(
                                'Correct',
                                '0', // Static correct answers
                                AppColors.successColor,
                                maxWidth: constraints.maxWidth / 3,
                              ),
                            ),
                            SizedBox(
                              width: 8.0,
                            ), // Static value for _smallPadding
                            Expanded(
                              child: _buildResultCard(
                                'Incorrect',
                                '0', // Static incorrect answers
                                AppColors.errorColor,
                                maxWidth: constraints.maxWidth / 3,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return Card(
            shape: RoundedRectangleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.examList.first.testName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: _smallPadding),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final exam = controller.examList.value.first;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'Total Questions',
                              exam.totalQuestion.toString(),
                              AppColors.warningColor,
                              maxWidth: constraints.maxWidth / 3,
                            ),
                          ),
                          SizedBox(width: _smallPadding),
                          Expanded(
                            child: _buildResultCard(
                              'Correct',
                              exam.correct.toString(),
                              AppColors.successColor,
                              maxWidth: constraints.maxWidth / 3,
                            ),
                          ),
                          SizedBox(width: _smallPadding),
                          Expanded(
                            child: _buildResultCard(
                              'Incorrect',
                              exam.incorrect.toString(),
                              AppColors.errorColor,
                              maxWidth: constraints.maxWidth / 3,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAvailableExamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available exam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.examlist);
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _smallPadding),
        Obx(
          () =>
              examListController.isLoading.value
                  ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ExamCardShimmer(),
                        SizedBox(width: 10),
                        ExamCardShimmer(),
                        SizedBox(width: 10),
                      ],
                    ),
                  )
                  : examListController.examDetailList.isEmpty
                  ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ExamCardShimmer(),
                        SizedBox(width: 10),
                        ExamCardShimmer(),
                        SizedBox(width: 10),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        examListController.examDetailList.length,
                        (index) {
                          var exam =
                              examListController.examDetailList.value[index];
                          String image =
                              examListController.imageLink.value +
                              exam.testImage;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _smallPadding,
                            ),
                            child: _buildExamCard(
                              press: () async {
                                await profileController.fetchUserProfile(
                                  context: Get.context!,
                                  isRefresh: true,
                                );
                                if (profileController
                                    .userProfileList
                                    .isNotEmpty) {
                                  print("id ${exam.id}");
                                  final ExamDetailController
                                  examDetailController = Get.put(
                                    ExamDetailController(),
                                  );
                                  //navigate to detail screen
                                  Get.toNamed(AppRoutes.examdetail);
                                  // Store the selected maintenance order in the controller
                                  examDetailController.setSelectedExamid(
                                    exam.id,
                                  );
                                }
                              },
                              image,
                              exam.examName,
                              exam.testName.toString(),
                              exam.duration.toString(),
                              exam.questionCount.toString(),
                              exam.testType == "1" ? "Buy Now" : "Free",
                            ),
                          );
                        },
                      ),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    Color color, {
    required double maxWidth,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Column(
        children: [
          Align(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(
    String image,
    String title,
    String subtitle,
    String time,
    String questionsCount,
    String buttonText, {
    required VoidCallback press,
  }) {
    return Container(
      width: 180, // Fixed width for consistency
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDFE6F8), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: AppColors.primaryColor.withOpacity(0.2),
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.grey[300], height: 100),
                      ),
                  errorWidget:
                      (context, url, error) => Icon(Icons.error, size: 50),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.lightText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
            child: Text(
              '$time min | $questionsCount Questions',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF5C5F6D),
              ),
            ),
          ),
          const SizedBox(height: _smallPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
            child: Obx(() {
              // Check if userProfileList is empty to determine button state
              final isDisabled = profileController.userProfileList.isEmpty;
              return ElevatedButton(
                onPressed: isDisabled ? null : press, // Disable button if empty
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryColor, // Normal color for enabled state
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class LatestExamShmimmer extends StatelessWidget {
  const LatestExamShmimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final constraints = BoxConstraints(maxWidth: screenWidth);
    final _smallPadding = 8.0;
    return Card(
      shape: RoundedRectangleBorder(),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for test name
              Container(width: 200, height: 16, color: Colors.white),
              SizedBox(height: _smallPadding),
              // Shimmer for result cards
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth / 3,
                          ),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      SizedBox(width: _smallPadding),
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth / 3,
                          ),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(width: _smallPadding),
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth / 3,
                          ),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}

class ExamCardShimmer extends StatelessWidget {
  // Assuming _smallPadding and AppColors are defined elsewhere
  static const double _smallPadding =
      8.0; // Adjust to match your original value

  const ExamCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Matches original card width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDFE6F8), width: 0.5),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: Colors.grey[300], // Placeholder for image
                  height: 100,
                ),
              ),
            ),
            // Title placeholder
            Padding(
              padding: const EdgeInsets.all(_smallPadding),
              child: Container(
                height: 14, // Matches fontSize: 14
                width: double.infinity,
                color: Colors.grey[300], // Placeholder for title text
              ),
            ),
            // Time and questions placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
              child: Container(
                height: 12, // Matches fontSize: 12
                width: 100, // Partial width to mimic "time min | questions"
                color: Colors.grey[300], // Placeholder for time/questions text
              ),
            ),
            const SizedBox(height: _smallPadding),
            // Button placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
              child: Container(
                height: 36, // Matches button height
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Placeholder for button
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarouselShimmer extends StatelessWidget {
  // Assuming _smallPadding is defined elsewhere
  static const double _smallPadding =
      8.0; // Adjust to match your original value
  final int itemCount; // Number of shimmer placeholders

  const CarouselShimmer({Key? key, this.itemCount = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 190, // Matches original height
          autoPlay: false, // No autoplay for shimmer
          enlargeCenterPage: true,
          viewportFraction: 1.0,
        ),
        items: List.generate(itemCount, (index) {
          return Builder(
            builder: (BuildContext context) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300], // Placeholder for image
                  ),

                  // margin: const EdgeInsets.symmetric(horizontal: _smallPadding),
                  height: 180, // Matches carousel height
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
