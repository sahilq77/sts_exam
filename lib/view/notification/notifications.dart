import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stsexam/controller/notification/notification_controller.dart';
import 'package:stsexam/utility/app_images.dart';
import 'package:stsexam/utility/app_routes.dart';

import '../../app_colors.dart';
import '../../controller/home/home_controller.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final controller = Get.put(NotificationController());
  // Sample notification data
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,

      body: RefreshIndicator(
        onRefresh: () => controller.refreshleadsList(context: context),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: _buildShimmerItem());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount:
                controller.notiList.isEmpty
                    ? 1
                    : controller.notiList.length +
                        (controller.hasMoreData.value ||
                                controller.isLoadingMore.value
                            ? 1
                            : 0),
            itemBuilder: (context, int index) {
              if (controller.notiList.isEmpty) {
                return Image.asset(AppImages.empty);
              }

              if (index == controller.notiList.length) {
                if (controller.isLoadingMore.value) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (!controller.hasMoreData.value) {
                  return const Padding(
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
                return const SizedBox.shrink(); // Fallback for safety
              }

              var noti = controller.notiList[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (noti.landingPage.contains("test_result_page")) {
                        Get.toNamed(AppRoutes.result);
                      } else if (noti.notification.contains("added")) {
                        Get.toNamed(AppRoutes.examlist);
                      } else {
                        print("object");
                      }
                    },
                    child: ListTile(
                      leading: Container(
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(
                            0.1,
                          ), // AppColors.primaryTeal
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/bell.png', // Path to your asset image
                            width: 24.0, // Adjust size as needed
                            height: 24.0,
                            color:
                                AppColors
                                    .primaryColor, // Optional: Tint the image
                          ),
                        ),
                      ),
                      title: ReadMoreText(
                        noti.notification,
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
                      trailing: Text(
                        _getTimeAgo(noti.createdOn),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  const Divider(thickness: 0.5, color: Color(0xFFD9D9D9)),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (ctx, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
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
                trailing: Container(height: 12, width: 50, color: Colors.white),
              ),
              const Divider(thickness: 0.5),
            ],
          ),
        );
      },
    );
  }
}
