import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../utility/app_images.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 20.0),
            //     child: Image.asset(
            //       AppImages.logo,
            //       height: 100,
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            // ),
            // // Title
            // const Text(
            //   'Terms and Conditions',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black87,
            //   ),
            // ),
            const SizedBox(height: 16),
            // Terms Content
            Text(
              'Welcome to Vidya Saarthi, operated by REWOLT 2.0. By using our app, you agree to the following terms and conditions:\n\n'
              '1. **Usage**: The Vidya Saarthi app is provided for educational purposes to help users prepare for competitive exams. Users must not misuse the app for any unlawful activities.\n\n'
              '2. **Content**: All mock tests, questions, and results are proprietary to REWOLT 2.0 and may not be reproduced or distributed without permission.\n\n'
              '3. **Payments**: Any transactions made through the app are subject to our payment policies. Ticket amounts range from INR 5 to INR 500, as per our business model.\n\n'
              '4. **User Responsibility**: Users are responsible for maintaining the confidentiality of their account details and for all activities under their account.\n\n'
              '5. **Liability**: REWOLT 2.0 is not liable for any damages arising from the use of the app, including inaccuracies in content or interruptions in service.\n\n'
              '6. **Changes to Terms**: We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of the updated terms.\n\n'
              'For any questions, contact us at rewolt2020@gmail.com.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            // Footer
            Center(
              child: Text(
                'All Rights Are Reserved | ©2023',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
