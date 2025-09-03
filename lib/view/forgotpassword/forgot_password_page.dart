import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors.dart';
import '../../controller/forgot_password/forgot_password_controller.dart';
import '../home/homepage.dart'; // Import the HomePage

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  //final controller = Get.put(LoginController()); // Ensure LoginController is properly defined
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true; // To toggle password visibility
  bool _obscureConfirmPassword = true; // To toggle confirm password visibility
  bool _isTermsAccepted = false; // To track checkbox state
  String? _phoneError; // To store phone number error message
  String? _passwordError; // To store password error message
  String? _confirmPasswordError; // To store confirm password error message
  String? _termsError; // To store terms checkbox error message

  // Validate inputs and set error messages
  void _validateInputs() {
    setState(() {
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;

      // Phone number validation: must be exactly 10 digits
      if (_phoneController.text.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (!RegExp(r'^\d{10}$').hasMatch(_phoneController.text)) {
        _phoneError = 'Enter a valid 10-digit phone number';
      }

      // Password validation: must be at least 8 characters, include a number and a special character
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      } else if (_passwordController.text.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (!RegExp(
        r'^(?=.*[0-9])(?=.*[!@#$%^&*])',
      ).hasMatch(_passwordController.text)) {
        _passwordError =
            'Password must contain a number and a special character';
      }

      // Confirm Password validation: must match password and not be empty
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Confirm password is required';
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      }

      // Terms and Conditions validation
      if (!_isTermsAccepted) {
        _termsError = 'You must accept the terms and conditions';
      }
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final controller = Get.put(ForgotPasswordController());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight), // Height of the AppBar
        child: AppBar(
          title: Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 18, // Font size
              fontWeight: FontWeight.w600, // Font weight
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back), // Back icon
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              1.0,
            ), // Set height for the bottom border
            child: Container(
              color: Color(0xFFE5E7EB), // Light grey color for the border
              height: 1.0, // Thickness of the border
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundColor, // Use custom background color
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start, // Align children to the start (left)
              children: [
                // App logo (centered)
                Center(
                  child: Image.asset(
                    'assets/logo.png', // Ensure the image exists in your assets folder
                    width: 263,
                    height: 260,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Title (left-aligned)
                Text(
                  'Forgot Your Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor, // Custom text color
                  ),
                  textAlign: TextAlign.left, // Align text to the start (left)
                ),
                SizedBox(height: screenHeight * 0.04),
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
                SizedBox(height: screenHeight * 0.01),
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
                      color:
                          _phoneError != null
                              ? AppColors.errorColor
                              : const Color(0xFFD0D0D0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/Call.png', // Replace with AppImages.call or appropriate icon
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFD0D0D0),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: TextStyle(fontSize: 17),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Phone Error Message
                SizedBox(height: screenHeight * 0.02),
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
                SizedBox(height: screenHeight * 0.01),
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
                      color:
                          _confirmPasswordError != null
                              ? AppColors.errorColor
                              : const Color(0xFFD0D0D0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(fontSize: 17),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 3) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
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
                SizedBox(height: screenHeight * 0.02),
                // Confirm Password Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm password*',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF595959),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // Custom Confirm Password Field
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
                      color:
                          _confirmPasswordError != null
                              ? AppColors.errorColor
                              : const Color(0xFFD0D0D0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(fontSize: 17),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password is required';
                            } else if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textColor,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Confirm Password Error Message

                // SizedBox(height: screenHeight * 0.02),
                // // Terms and Conditions Checkbox
                // Row(
                //   children: [
                //     Checkbox(
                //       value: _isTermsAccepted,
                //       onChanged: (value) {
                //         setState(() {
                //           _isTermsAccepted = value ?? false;
                //           if (_isTermsAccepted) {
                //             _termsError = null; // Clear error when checked
                //           }
                //         });
                //       },
                //     ),
                //     Expanded(
                //       child: Text(
                //         'I accept the terms and conditions',
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: AppColors.textColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // // Terms Error Message
                // if (_termsError != null)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 5, left: 12),
                //     child: Text(
                //       _termsError!,
                //       style: TextStyle(
                //         color: AppColors.errorColor,
                //         fontSize: 12,
                //       ),
                //     ),
                //   ),
                SizedBox(height: screenHeight * 0.04),
                // Submit Button (centered and full-width)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // If the form is valid, proceed with password reset
                        controller.changePassword(
                          mobile: _phoneController.text,
                          password: _passwordController.text,
                          context: context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryColor, // Use custom color for button
                      minimumSize: Size(
                        double.infinity,
                        50,
                      ), // Full width, fixed height
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                      ), // Vertical padding only
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment:
                          Alignment.center, // Center the button's content
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
