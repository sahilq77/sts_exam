import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../utility/app_images.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'About Us',
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  AppImages.logo,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Business Name
            const Text(
              'About REWOLT 2.0',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'Vidya Saarthi is an educational app developed by REWOLT 2.0, a partnership based in Sawantwadi, Sindhudurg, Maharashtra, India. Our mission is to empower students to excel in competitive exams through interactive mock tests, a user-friendly interface, real-time evaluation, and instant results. We aim to build confidence and track performance, making Vidya Saarthi a smart companion for exam readiness.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            // Business Details
            const Text(
              'Our Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Legal Entity: REWOLT 2.0\n'
              'Category: Education\n'
              'Location: Vanashree Apartment, Bhatwadi, Near Datta Mandir, Sawantwadi, Sindhudurg, Maharashtra, India - 416510\n'
              'Contact: rewolt2020@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
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
