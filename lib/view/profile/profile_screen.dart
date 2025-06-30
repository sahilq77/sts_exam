import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/global_controller.dart/city_controller.dart';
import '../../controller/global_controller.dart/state_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../utility/app_routes.dart';
import '../bottomnavigation/custom_bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final stateController = Get.put(StateController());
  final cityController = Get.put(CityController());
  final bottomController = Get.put(BottomNavigationController());
  final controller = Get.put(ProfileController());

  String greetings() {
    final hour = TimeOfDay.now().hour;
    if (hour <= 12) {
      return 'Good Morning';
    } else if (hour <= 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Future<void> fetchData() async {
    if (controller.userProfileList.isNotEmpty) {
      final stateId = controller.userProfileList[0].state;
      final cityId = controller.userProfileList[0].city;
      print("Initializing with stateId: $stateId, cityId: $cityId");

      // Fetch states and cities concurrently
      await Future.wait([
        stateController.fetchStates(context: context).then((_) {
          stateController.getStateNameById(stateId);
          print(
              "State name for stateId $stateId: ${stateController.getStateNameById(stateId)}");
        }),
        cityController
            .fetchCities(context: context, forceFetch: true, stateID: stateId)
            .then((_) {
          final cityName = cityController.getCityNameById(cityId);
          print("City name for cityId $cityId: $cityName");
          print(
              "City list: ${cityController.cityList.map((c) => '${c.id}: ${c.name}').toList()}");
        }),
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
    // Defer execution to ensure controllers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //fetchData();
      await controller.onRefresh(context);
      if (controller.userProfileList.isNotEmpty) {
        final stateId = controller.userProfileList[0].state;
        final cityId = controller.userProfileList[0].city;
        print("Refreshing with stateId: $stateId, cityId: $cityId");
        await cityController.fetchCities(
            context: context, forceFetch: true, stateID: stateId);
        final cityName = cityController.getCityNameById(cityId);
        print("City name after refresh: $cityName");
        print(
            "City list after refresh: ${cityController.cityList.map((c) => '${c.id}: ${c.name}').toList()}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.onRefresh(context);
            if (controller.userProfileList.isNotEmpty) {
              final stateId = controller.userProfileList[0].state;
              final cityId = controller.userProfileList[0].city;
              print("Refreshing with stateId: $stateId, cityId: $cityId");
              await cityController.fetchCities(
                  context: context, forceFetch: true, stateID: stateId);
              final cityName = cityController.getCityNameById(cityId);
              print("City name after refresh: $cityName");
              print(
                  "City list after refresh: ${cityController.cityList.map((c) => '${c.id}: ${c.name}').toList()}");
            }
          },
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.userProfileList.isEmpty) {
                return _buildShimmerEffect(context);
              }

              if (controller.userProfileList.isEmpty) {
                return const Center(child: Text("No profile data available"));
              }

              final user = controller.userProfileList[0];
              print("Building with cityId: ${user.city}");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and edit icon
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          child: user.profileImage == null
                              ? ClipOval(
                                  child: Image.asset("assets/image.jpg",
                                      height: 90, width: 90, fit: BoxFit.cover),
                                )
                              : ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "${controller.imageLink.value}${user.profileImage}",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, size: 50),
                                  ),
                                ),
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     // controller.pickImage(ImageSource.gallery);
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFFE5E7EB),
                        //       shape: BoxShape.circle,
                        //       border: Border.all(color: Colors.white, width: 2),
                        //     ),
                        //     padding: const EdgeInsets.all(5),
                        //     child: ClipOval(
                        //       child: Image.asset(
                        //         'assets/edit-line.png',
                        //         width: 15,
                        //         height: 15,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      greetings(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  CutsomTile(title: "Student Name", value: user.fullName),
                  CutsomTile(
                      title: "Gender",
                      value: user.gender == "1" ? "Male" : "Female"),
                  CutsomTile(title: "Mobile Number", value: user.mobileNumber),
                  CutsomTile(title: "Email ID", value: user.email),
                  // State Display
                  Obx(() => CutsomTile(
                        title: "State",
                        value: stateController.isLoading.value
                            ? const SizedBox(
                                height: 15,
                                width: 15,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : stateController.getStateNameById(user.state) ??
                                'N/A',
                      )),
                  // City Display
                  Obx(() => CutsomTile(
                      title: "City",
                      value:
                          cityController.getCityNameById(user.city) ?? "N/A")),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.setSelectedUser(user);
                      Get.toNamed(AppRoutes.updateprofile);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Avatar placeholder
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 10),
          // Name placeholder
          Center(
            child: Container(
              width: 150,
              height: 20,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 4),
          // Greeting placeholder
          Center(
            child: Container(
              width: 100,
              height: 16,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(9, (_) => _buildShimmerTile(screenWidth)) +
                [
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTile(width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: width, height: 18, color: Colors.grey[300]),
          const SizedBox(height: 3),
          Container(width: 150, height: 20, color: Colors.grey[300]),
        ],
      ),
    );
  }
}

class CutsomTile extends StatelessWidget {
  final String title;
  final dynamic value; // Allow String or Widget
  const CutsomTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
          const SizedBox(height: 3),
          value is String
              ? Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                )
              : value,
          const Divider(color: Colors.grey, thickness: 0.2),
        ],
      ),
    );
  }
}
