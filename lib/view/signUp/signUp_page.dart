import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:stsexam/utility/secure_input_formater.dart';
import '../../app_colors.dart';
import '../../controller/global_controller.dart/city_controller.dart';
import '../../controller/global_controller.dart/state_controller.dart';
import '../../controller/signUp/signUp_controller.dart';
import '../../utility/app_images.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final controller = Get.put(SignupController());
  final stateController = Get.put(StateController());
  final CityController cityController = Get.put(CityController());
  final _formKey = GlobalKey<FormState>();
  String? selectedUserType;
  String? selectedGender;
  String? selectedState;
  String? selectedCity;
  bool obscurePassword = true;
  final fullNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final udiseNumberController = TextEditingController();
  final schoolNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SignUp",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUnfocus,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(AppImages.logo, height: 206, width: 244),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please Enter Your Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // User Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select Your User Type",
                  labelStyle: TextStyle(
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
                ),
                icon: const Icon(CupertinoIcons.chevron_down, size: 20),
                items: const [
                  DropdownMenuItem(value: "Student", child: Text("Student")),
                  DropdownMenuItem(value: "Open", child: Text("Open")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedUserType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a user type";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Student Name Text Field
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText:
                      selectedUserType == "Student" ? "Student Name*" : "Name*",
                  labelStyle: TextStyle(
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
                ),
                inputFormatters: [
                  SecureTextInputFormatter.deny(),
                  FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  if (value.length < 2) {
                    return "Name must be at least 2 characters long";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Gender Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Gender*",
                  labelStyle: TextStyle(
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
                ),
                icon: const Icon(CupertinoIcons.chevron_down, size: 20),
                items: const [
                  DropdownMenuItem(value: "0", child: Text("Male")),
                  DropdownMenuItem(value: "1", child: Text("Female")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                    print(selectedGender);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a gender";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Mobile Number Text Field
              TextFormField(
                controller: mobileNumberController,
                decoration: InputDecoration(
                  labelText: "Mobile number*",
                  labelStyle: TextStyle(
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
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  SecureTextInputFormatter.deny(),
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    10,
                  ), // Restrict input to 10 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is required";
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Text Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email*",
                  labelStyle: TextStyle(
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
                ),
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  SecureTextInputFormatter.deny(),
                  FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
              // Student-specific fields
              if (selectedUserType == "Student") ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: udiseNumberController,
                  decoration: InputDecoration(
                    labelText: "UDISE Number*",
                    labelStyle: TextStyle(
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
                  ),
                  inputFormatters: [
                    SecureTextInputFormatter.deny(),
                    FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your UDISE number";
                    }
                    if (value.length < 11 || value.length > 15) {
                      return "UDISE number must be between 11 and 15 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: schoolNameController,
                  decoration: InputDecoration(
                    labelText: "School name*",
                    labelStyle: TextStyle(
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
                  ),
                  inputFormatters: [
                    SecureTextInputFormatter.deny(),
                    FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your school name";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              // State Dropdown with Validation
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
                return FormField<String>(
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        stateController.getStateId(value) == '') {
                      return 'Please select a state';
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> formFieldState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Search State',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          items: stateController.getStateNames(),
                          onChanged: (String? newValue) async {
                            formFieldState.didChange(newValue);
                            if (newValue != null) {
                              final stateId = stateController.getStateId(
                                newValue,
                              );
                              print("state id $stateId");
                              setState(() {
                                selectedState = stateId;
                                // Reset city when state changes
                                selectedCity = null;
                                cityController.cityList.clear();
                              });
                              if (stateId != null && stateId.isNotEmpty) {
                                await cityController.fetchCities(
                                  context: context,
                                  forceFetch: true,
                                  stateID: stateId,
                                );
                              }
                            }
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select a State*',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor,
                              ),
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
                              filled: true,
                              errorText: formFieldState.errorText,
                            ),
                          ),
                          selectedItem: formFieldState.value,
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              // City Dropdown with Validation
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
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        cityController.getCityId(value) == '') {
                      return 'Please select a city';
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> formFieldState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownSearch<String>(
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Search City',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: Color(0xFFD0D0D0),
                                  ),
                                ),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          items: cityController.getCityNames(),
                          onChanged: (String? newValue) {
                            formFieldState.didChange(newValue);
                            if (newValue != null) {
                              final cityId = cityController.getCityId(newValue);
                              setState(() {
                                selectedCity = cityId;
                              });
                            }
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select a City*',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColor,
                              ),
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
                              filled: true,
                              errorText: formFieldState.errorText,
                            ),
                          ),
                          selectedItem: formFieldState.value,
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              // Password Text Field
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Enter Password*",
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    child: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textColor,
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                ),
                inputFormatters: [
                  SecureTextInputFormatter.deny(),
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters long";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Confirm Password Text Field
              TextFormField(
                controller: confirmController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password*",
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColor,
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    child: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textColor,
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                ),
                inputFormatters: [
                  SecureTextInputFormatter.deny(),
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // SignUp Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.signUp(
                      userType: selectedUserType,
                      fullName: fullNameController.text,
                      email: emailController.text,
                      mobileNumber: mobileNumberController.text,
                      gender: selectedGender,
                      profileImg: "",
                      state: selectedState,
                      city: selectedCity,
                      udiseNumber: udiseNumberController.text,
                      schoolName: schoolNameController.text,
                      password: passwordController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "SignUp",
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
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    udiseNumberController.dispose();
    schoolNameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}
