import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/cupertino.dart';

import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/global_controller.dart/city_controller.dart';
import '../../controller/global_controller.dart/state_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../controller/profile/update_profile_controller.dart';
import '../../model/profile/get_profile_response.dart';
import '../../utility/app_images.dart';
import '../bottomnavigation/custom_bottom_bar.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final stateController = Get.put(StateController());
  final cityController = Get.put(CityController());
  final bottomController = Get.put(BottomNavigationController());
  final profileController = Get.put(ProfileController());
  final controller = Get.put(UpdateProfileController());
  final fullNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  UserProfile? profile;
  String fullname = "";
  String profileImage = "";
  // Variables to store dropdown values
  String? selectedGender;
  String? selectedState;
  String? selectedCity;
  String greetings() {
    final hour = TimeOfDay.now().hour;

    if (hour <= 12) {
      return 'Good Morning';
    } else if (hour <= 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  // Validation function for email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validation function for mobile number
  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  // Validation function for full name
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  Future<void> _loadMaintenanceData() async {
    try {
      final ProfileController jobworkController = Get.find<ProfileController>();
      profile = jobworkController.selectedUser.value;

      if (profile != null) {
        print('--- Jobwork Data ---');
        print('ID: ${profile!.id}');
        print('User Type: ${profile!.userType}');
        print('Name: ${profile!.fullName}');
        print('-----------------------');

        setState(() {
          profileImage = fullNameController.text = profile!.profileImage;
          fullNameController.text = profile!.fullName;
          fullname = profile!.fullName;
          selectedGender = profile!.gender == "1" ? "Male" : "Female";
          mobileNumberController.text = profile!.mobileNumber;
          emailController.text = profile!.email;

          //state and city
          final stateId = profile!.state;
          final cityId = profile!.city;
          print("Initializing with stateId: $stateId, cityId: $cityId");
          stateController.fetchStates(context: context).then((_) {
            stateController.getStateNameById(profile!.state);
            print(
              "State name for stateId $stateId: ${stateController.getStateNameById(stateId)}",
            );
          });
          cityController
              .fetchCities(context: context, forceFetch: true, stateID: stateId)
              .then((_) {
                final cityName = cityController.getCityNameById(cityId);
                print("City name for cityId $cityId: $cityName");
                print(
                  "City list: ${cityController.cityList.map((c) => '${c.id}: ${c.name}').toList()}",
                );
              });
        });
      } else {
        print('No Maintenance data found in MaintenanceController');
      }
    } catch (e) {
      print('Error loading Maintenance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading maintenance data: $e')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMaintenanceData();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController jobworkController = Get.find<ProfileController>();
    profile = jobworkController.selectedUser.value;

    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Update Profile",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo in Circular Avatar with Edit Icon
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Obx(
                      () => CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child:
                            controller.imagePath.value != null &&
                                    controller.imagePath.value!.isNotEmpty
                                ? AspectRatio(
                                  aspectRatio:
                                      1, // Ensures a square aspect ratio for the circle
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Image.file(
                                        File(controller.imagePath.value!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                                : (profile == null ||
                                    profile!.profileImage.isEmpty)
                                ? ClipOval(
                                  child: Image.asset(
                                    AppImages.profile,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : AspectRatio(
                                  aspectRatio:
                                      1, // Ensures a square aspect ratio for the circle
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            profileController.imageLink.value +
                                            profile!.profileImage,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        errorWidget:
                                            (context, url, error) => const Icon(
                                              Icons.error,
                                              size: 50,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          () => showEditProfileImageBottomSheet(
                            context,
                            controller,
                          ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/edit-line.png",
                            width: 15,
                            height: 15,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Greeting Text
              Center(
                child: Text(
                  fullname,
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
              const Text(
                "Please Enter Your Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Student Name Text Field
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "User Name*",
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                ],
                validator: _validateFullName,
              ),
              const SizedBox(height: 16),

              DropdownSearch<String>(
                popupProps: const PopupProps.menu(
                  showSearchBox: false, // Disable search since it's read-only
                ),

                // items: stateController.getStateNames(),
                onChanged: null, // Set to null to disable interaction
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Gender *',
                    labelStyle: TextStyle(color: AppColors.textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    // filled: true,
                    // fillColor:
                    //     Colors.grey[200], // Indicate disabled state
                    // errorText: formFieldState.errorText,
                  ),
                  baseStyle: TextStyle(
                    color:
                        Colors.grey, // Set the color for the selected item text
                  ),
                ),

                selectedItem: selectedGender,
                enabled: false, // Explicitly disable the dropdown
              ),
              const SizedBox(height: 16),
              // Mobile Number Text Field (already readOnly)
              TextFormField(
                readOnly: true, // Already disabled
                controller: mobileNumberController,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: "Mobile number*",
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),

                keyboardType: TextInputType.phone,
                validator: _validateMobileNumber,
              ),
              const SizedBox(height: 16),
              // Email Text Field
              TextFormField(
                readOnly: true, // Disable editing
                controller: emailController,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: "Email*",
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  // errorBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(5),
                  //   borderSide: const BorderSide(color: Colors.red),
                  // ),
                  // focusedErrorBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(5),
                  //   borderSide: const BorderSide(color: Colors.red),
                  // ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 16),
              // State Dropdown (Read-Only)
              Obx(() {
                if (stateController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (stateController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          stateController.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => stateController.fetchStates(
                                context: context,
                                forceFetch: true,
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: false, // Disable search since it's read-only
                  ),
                  items: stateController.getStateNames(),

                  onChanged: null, // Set to null to disable interaction
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'State*',
                      labelStyle: TextStyle(color: AppColors.textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.red),
                      ),

                      // filled: true,
                      // fillColor:
                      //     Colors.grey[200], // Indicate disabled state
                      // errorText: formFieldState.errorText,
                    ),
                    baseStyle: TextStyle(color: Colors.grey),
                  ),

                  selectedItem: stateController.getStateNameById(
                    profile!.state,
                  ),
                  enabled: false, // Explicitly disable the dropdown
                );
              }),
              const SizedBox(height: 16),
              // City Dropdown (Read-Only)
              Obx(() {
                if (cityController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (cityController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cityController.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedState != null &&
                                selectedState!.isNotEmpty) {
                              cityController.fetchCities(
                                context: context,
                                forceFetch: true,
                                stateID: selectedState!,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Please select a state first',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return FormField<String>(
                  initialValue: cityController.getCityNameById(profile!.city),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value == 'All' ||
                        cityController.getCityId(value) == '') {
                      return 'Please select a city';
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> formFieldState) {
                    return DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox:
                            false, // Disable search since it's read-only
                      ),

                      items: cityController.getCityNames(),
                      onChanged: null, // Set to null to disable interaction
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'City*',
                          labelStyle: TextStyle(color: AppColors.textColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0D0D0),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          errorText: formFieldState.errorText,
                        ),
                        baseStyle: TextStyle(color: Colors.grey),
                      ),

                      selectedItem: cityController.getCityNameById(
                        profile!.city,
                      ),
                      enabled: false, // Explicitly disable the dropdown
                    );
                  },
                );
              }),

              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: () {
                  // Form is valid, proceed with submission
                  controller.updateProfile(
                    fullName: fullNameController.text.toString(),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //       content: Text('Profile updated successfully!')),
                  // );
                  // Add your logic to save the profile data
                  // For example, call a method in ProfileController
                  // controller.updateProfile(
                  //   fullName: fullNameController.text,
                  //   mobileNumber: mobileNumberController.text,
                  //   email: emailController.text,
                  //   gender: selectedGender,
                  //   state: selectedState,
                  //   city: selectedCity,
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void showEditProfileImageBottomSheet(
    BuildContext context,
    UpdateProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 16,
                  ),
                  child: Wrap(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.photo,
                              size: 40,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Edit Profile Photo',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF36322E),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Choose a method to update your photo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.pickImage(
                                          ImageSource.camera,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.orange.shade100,
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 28,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.pickImage(
                                          ImageSource.gallery,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.orange.shade100,
                                        child: Icon(
                                          Icons.photo_library,
                                          size: 28,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // if (isUploading)
                //   Container(
                //     color: Colors.black.withOpacity(0.3),
                //     child: const Center(child: CircularProgressIndicator()),
                //   ),
              ],
            );
          },
        );
      },
    );
  }
}
