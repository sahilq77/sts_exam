import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/exam/exam_detail_controller.dart';
import '../../controller/exam/exam_list_controller.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../../utility/widgets/custom_shimmer.dart';
import '../bottomnavigation/custom_bottom_bar.dart';

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomController = Get.put(BottomNavigationController());
    final controller = Get.put(ExamListController());
    final ScrollController scrollController = ScrollController();

    // Add listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreExams(context: context);
      }
    });

    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          automaticallyImplyLeading: true,
          title: const Text('Exam List'),
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
            if (controller.isLoading.value &&
                controller.examDetailList.isEmpty) {
              return const CutsomShimmer();
            }

            return Stack(
              children: [
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount:
                      controller.examDetailList.isEmpty
                          ? 1
                          : controller.examDetailList.length +
                              (controller.hasMoreData.value ||
                                      controller.isLoadingMore.value
                                  ? 1
                                  : 0),
                  itemBuilder: (context, int index) {
                    if (controller.examDetailList.isEmpty) {
                      return Center(child: Image.asset(AppImages.empty));
                    }

                    if (index == controller.examDetailList.length) {
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

                    var exam = controller.examDetailList[index];
                    String imageUrl =
                        controller.imageLink.value + exam.testImage;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 150,
                                height: 110,
                                fit: BoxFit.cover,
                                errorWidget:
                                    (context, url, error) =>
                                        Icon(Icons.error, size: 50),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exam.examName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.lightText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    exam.testName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lightText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exam.shortDescription,
                                    maxLines: 2,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exam.duration} min | ${exam.questionCount} Questions',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF5C5F6D),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: SizedBox(
                                      width: 150,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final ExamDetailController
                                          examDetailController = Get.put(
                                            ExamDetailController(),
                                          );
                                          examDetailController
                                              .setSelectedExamid(exam.id);
                                          Get.toNamed(AppRoutes.examdetail);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          minimumSize: const Size(
                                            double.infinity,
                                            36,
                                          ),
                                        ),
                                        child: Text(
                                          exam.testType == "1"
                                              ? "Buy Now"
                                              : "Free",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (controller.errorMessage.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }
}
