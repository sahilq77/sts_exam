import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../login/loginPage.dart';
import '../signUp/signUp_page.dart';
import '../general_user_details_page.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final profileController = Get.put(ProfileController());
  String greetings() {
    final hour = TimeOfDay.now().hour;
    if (hour <= 12) {
      return 'Good Morning';
    } else if (hour <= 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Drawer(
      child: Column(
        children: [
          // Custom Header
          Container(
            child: Stack(
              children: [
                Obx(() {
                  if (profileController.isLoading.value &&
                      profileController.userProfileList.isEmpty) {
                    return Text("");
                  }

                  if (profileController.userProfileList.isEmpty) {
                    return const Center(
                      child: Text("No profile data available"),
                    );
                  }

                  final user = profileController.userProfileList[0];
                  print(
                    "Building ${controller.imageLink.value}${user.profileImage}",
                  );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage(AppImages.sideBar),
                            fit: BoxFit.fitWidth,
                            opacity: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar and edit icon
                                Center(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey[200],
                                        child:
                                            user.profileImage == ""
                                                ? ClipOval(
                                                  child: Image.asset(
                                                    AppImages.profile,
                                                    // height: 90,
                                                    // width: 90,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                : ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        "${controller.imageLink.value}${user.profileImage}",
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Icon(
                                                              Icons.error,
                                                              size: 30,
                                                            ),
                                                  ),
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Hi, ${user.fullName}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              greetings(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                ListTile(
                  leading: Icon(
                    Icons.bar_chart,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  title: Text(
                    'Result',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.result);
                    widget.onItemTapped(0);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  title: Text(
                    'Notifications',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.notification);
                    // onItemTapped(2);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.payment,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  title: Text(
                    'Payments',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.PaymentReceipt);
                  },
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.school,
                //     color: Colors.grey[600],
                //     size: 24,
                //   ),
                //   title: Text(
                //     'Student User Details',
                //     style: TextStyle(
                //       fontSize: 16,
                //       color: Colors.grey[800],
                //     ),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const SignupPage(),
                //       ),
                //     );
                //   },
                // ),
                // ListTile(
                //   leading: Icon(
                //     Icons.group,
                //     color: Colors.grey[600],
                //     size: 24,
                //   ),
                //   title: Text(
                //     'General User Details',
                //     style: TextStyle(
                //       fontSize: 16,
                //       color: Colors.grey[800],
                //     ),
                //   ),
                //   onTap: () {
                //     Navigator.pop(context);
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const GeneralUserDetailsPage(),
                //       ),
                //     );
                //   },
                // ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  title: Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  onTap: () {
                    final user = profileController.userProfileList[0];
                    print("Building with cityId: ${user.city}");
                    profileController.setSelectedUser(user);
                    Get.toNamed(AppRoutes.updateprofile);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 24,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _showLogoutBottomSheet(
                      context,
                      controller,
                    ); // Show the bottom sheet
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          AppImages.logo,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'All Right Are Reserved | ©2023',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Log out?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out')),
                      );
                      Navigator.pop(context);
                      controller.logout(); // Use the _logout function
                    },
                    child: const Text('Logout', style: TextStyle(fontSize: 14)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(120, 40),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
