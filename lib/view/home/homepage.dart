import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:shimmer/shimmer.dart';
import 'package:readmore/readmore.dart';

import '../../app_colors.dart';
import '../../controller/announcements/announcements_controller.dart';
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
  final announcementsController = Get.put(AnnouncementsController());
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  final controller = Get.put(HomeController());
  final examListController = Get.put(AvilableExamController());

  final List<String> _bannerImages = [
    AppImages.banner,
    AppImages.banner,
    AppImages.banner,
  ];

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
    setState(() {
      _selectedIndex = 0;
    });
    await Future.wait([
      controller.refreshAllData(context: context),
      announcementsController.refreshAnnouncementsList(
        context: context,
        showLoading: false,
      ),
    ]);
    setState(() {
      _currentBannerIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchUserProfile(context: context);
      controller.fetchLatestexam(context: Get.context!);
      announcementsController.fetchAnnouncementsList(context: Get.context!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomController = Get.put(BottomNavigationController());

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
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            icon: Image.asset(AppImages.bellIcon, width: 24, height: 24),
            tooltip: 'Notifications',
            onPressed: () {
              Get.toNamed(AppRoutes.notification);
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
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(_standardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerCarousel(),
                const SizedBox(height: 10),
                _buildAnnouncementsSection(),
                const SizedBox(height: 20),
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
                      height: 190,
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

  String _getTimeAgo(DateTime createdOn) {
    final now = DateTime.now();
    final difference = now.difference(createdOn);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes == 1) {
      return "1 min ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours == 1) {
      return "1 hr ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else if (difference.inDays == 1) {
      return "1 day ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Announcements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.announcements);
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
        Obx(() {
          if (announcementsController.isLoading.value) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Column(children: [AnnouncementCardShimmer()]);
              },
            );
          }

          if (announcementsController.announcementsList.isEmpty) {
            return const Text(
              'No announcements available',
              style: TextStyle(fontSize: 14, color: AppColors.textColor),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                announcementsController.announcementsList.length > 3
                    ? 3
                    : announcementsController.announcementsList.length,
            itemBuilder: (context, index) {
              final announcement =
                  announcementsController.announcementsList[index];
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(
                            0.1,
                          ), // AppColors.primaryTeal
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.campaign,
                            color: AppColors.primaryColor,
                            size: 15,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ReadMoreText(
                          announcement.title,
                          trimMode: TrimMode.Line,
                          style: GoogleFonts.poppins(fontSize: 12),
                          trimLines: 2,
                          colorClickableText: Colors.pink,
                          trimCollapsedText: 'Read more',
                          trimExpandedText: 'Show less',
                          moreStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey, thickness: 0.2),
                ],
              );
            },
          );
        }),
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
                      'No Test Data Available',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildResultCard(
                                'Total Questions',
                                '0',
                                AppColors.warningColor,
                                maxWidth: constraints.maxWidth / 3,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: _buildResultCard(
                                'Correct',
                                '0',
                                AppColors.successColor,
                                maxWidth: constraints.maxWidth / 3,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Expanded(
                              child: _buildResultCard(
                                'Incorrect',
                                '0',
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
                                  Get.toNamed(AppRoutes.examdetail);
                                  examDetailController.setSelectedExamid(
                                    exam.id,
                                  );
                                }
                              },
                              image,
                              exam.examName,
                              exam.testName.toString(),
                              exam.duration.toString(),
                              "${exam.questionSCount.isEmpty ? exam.questionCount ?? "N/A" : exam.questionSCount}",
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
      width: 180,
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
              final isDisabled = profileController.userProfileList.isEmpty;
              return ElevatedButton(
                onPressed: isDisabled ? null : press,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
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
              Container(width: 200, height: 16, color: Colors.white),
              SizedBox(height: _smallPadding),
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
  }
}

class ExamCardShimmer extends StatelessWidget {
  static const double _smallPadding = 8.0;

  const ExamCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(color: Colors.grey[300], height: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(_smallPadding),
              child: Container(
                height: 14,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
              child: Container(height: 12, width: 100, color: Colors.grey[300]),
            ),
            const SizedBox(height: _smallPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _smallPadding),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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

class AnnouncementCardShimmer extends StatelessWidget {
  static const double _smallPadding = 8.0;

  const AnnouncementCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: Container(
            height: 20,
            width: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            height: 16,
            width: double.infinity,
            color: Colors.white,
          ),
          subtitle: Container(
            height: 12,
            width: 100,
            color: Colors.white,
            margin: const EdgeInsets.only(top: 8),
          ),
        ),
      ),
    );
  }
}

class CarouselShimmer extends StatelessWidget {
  static const double _smallPadding = 8.0;
  final int itemCount;

  const CarouselShimmer({Key? key, this.itemCount = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 190,
          autoPlay: false,
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
                    color: Colors.grey[300],
                  ),
                  height: 180,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
