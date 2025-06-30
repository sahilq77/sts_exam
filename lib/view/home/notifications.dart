import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';


import '../../app_colors.dart';
import '../../controller/home/home_controller.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final controller = Get.put(HomeController());
  // Sample notification data
  final List<Map<String, String>> notifications = List.generate(
    30,
    (index) => {
      'message':
          'Lorem ipsum is simply dummy text of the printing and typesetting industry.',
      'time': '3 min ago',
    },
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchNotification(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: AppColors.Appbar,
        elevation: 0,
      ),
      body: Obx(
        () => controller.isLoadingNoti.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: controller.notificationsList.length,
                itemBuilder: (context, index) {
                  var noti = controller.notificationsList[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFD9D9D9),
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bell icon in a circle
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle, // Circular shape
                              ),
                              child: Image.asset(
                                'assets/bell.png', // Path to your asset image
                                width: 24.0, // Adjust size as needed
                                height: 24.0,
                                color: AppColors
                                    .primaryColor, // Optional: Tint the image
                              ),
                            ),
                            SizedBox(width: 16.0),
                            // Notification message and time
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      noti.notificationDesc.toString(),
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textColor),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    "${noti.time.toString()}min ago",
                                    style: TextStyle(
                                      fontSize: 8.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      backgroundColor: AppColors.backgroundColor,
    );
  }
}
