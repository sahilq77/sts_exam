import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../app_colors.dart';
import '../../controller/login/login_controller.dart';
import '../../notification_services .dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';
import '../home/homepage.dart'; // Import the HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.put(LoginController());
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // To toggle password visibility
  bool _isTermsAccepted = false; // To track checkbox state
  String? _phoneError; // To store phone number error message
  String? _passwordError; // To store password error message

  // Validate inputs and set error messages
  void _validateInputs() {
    setState(() {
      _phoneError = null;
      _passwordError = null;

      // Phone number validation: must be exactly 10 digits
      if (_phoneController.text.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (!RegExp(r'^\d{10}$').hasMatch(_phoneController.text)) {
        _phoneError = 'Enter a valid 10-digit phone number';
      }

      // Password validation: must not be empty
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      }
    });
  }

  String? pushtoken;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    notificationServices.firebaseInit(context);
    notificationServices.setInteractMessage(context);
    notificationServices.getDevicetoken().then((value) {
      log('Device Token ${value}');
      pushtoken = value;
      setState(() {});
    });

    // Future.delayed(Duration(seconds: 3), () {
    //   Get.offNamed(AppRoutes.welcome);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight), // Height of the AppBar
        child: AppBar(
          title: Text(
            'Sign In with Mobile',
            style: TextStyle(
              fontSize: 18, // Font size
              fontWeight: FontWeight.w600, // Font weight
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back), // Back icon
          //   onPressed: () {
          //     Navigator.pop(context); // Navigate back to the previous screen
          //   },
          // ),
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(1.0), // Set height for the bottom border
            child: Container(
              color: Color(0xFFE5E7EB), // Light grey color for the border
              height: 1.0, // Thickness of the border
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundColor, // Use custom background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start, // Align children to the start (left) by default
            children: [
              // App logo (centered)
              Center(
                child: Image.asset(
                  AppImages
                      .logo, // Make sure the image exists in your assets folder
                  width: 263,
                  height: 260,
                ),
              ),
              SizedBox(height: 20),
              // Title (left-aligned)
              Text(
                'Start Your Safe Hassle Free Journey!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor, // Custom text color
                ),
                textAlign: TextAlign.left, // Align text to the start (left)
              ),
              SizedBox(height: 40),
              // Phone Number Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your mobile number',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF595959),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Custom Phone Number Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _phoneError != null
                        ? AppColors.errorColor
                        : const Color(0xFFD0D0D0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages
                          .callIcon, // Replace with AppImages.call or appropriate icon
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFD0D0D0),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: TextStyle(
                            fontSize:
                                17), // Replace with AppFontStyle2.blinker if available
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (value) {
                          // Clear error when user starts typing
                          if (_phoneError != null) {
                            setState(() {
                              _phoneError = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Phone Error Message
              if (_phoneError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 12),
                  child: Text(
                    _phoneError!,
                    style: TextStyle(
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // Password Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your password*',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF595959),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Custom Password Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _passwordError != null
                        ? AppColors.errorColor
                        : const Color(0xFFD0D0D0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                            fontSize:
                                17), // Replace with AppFontStyle2.blinker if available
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (value) {
                          // Clear error when user starts typing
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Password Error Message
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 12),
                  child: Text(
                    _passwordError!,
                    style: TextStyle(
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.forgotpassword);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppColors.textColor))),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13, // Increased for readability
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              // SizedBox(height: 30),
              // // Terms and Conditions Checkbox
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Checkbox(
              //       value: _isTermsAccepted,
              //       activeColor: AppColors.primaryColor ?? Colors.orange,
              //       onChanged: (bool? value) {
              //         setState(() {
              //           _isTermsAccepted = value ?? false;
              //         });
              //       },
              //     ),

              //     SizedBox(width: 8), // Add spacing
              //     Flexible(
              //       child: Text(
              //         'By signing up, you are accepting our Terms of Use, Privacy Policy and End User License Agreement.',
              //         style: TextStyle(
              //           fontSize: 12, // Increased for readability
              //           color: AppColors.textColor,
              //         ),
              //         textAlign: TextAlign.left,
              //       ),
              //     ),
              //   ],
              // ),

              SizedBox(height: 30),
              // Login Button (centered and full-width)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _validateInputs();
                    if (_phoneError == null && _passwordError == null) {
                      controller.login(
                          mobileNumber: _phoneController.text.toString(),
                          password: _passwordController.text.toString(),
                          token: pushtoken);
                      // Navigate to HomePage
                      // Get.toNamed(AppRoutes.home);
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => HomePage()),
                      // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryColor, // Use custom color for button
                    minimumSize:
                        Size(double.infinity, 50), // Full width, fixed height
                    padding: EdgeInsets.symmetric(
                        vertical: 15), // Vertical padding only
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center, // Center the button's content
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Dont have an account? "),
        TextButton(
            onPressed: () {
              Get.toNamed(AppRoutes.signUp);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => SignupPage()));
              // controller.lo
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(
                  color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            ))
      ],
    );
  }
}
