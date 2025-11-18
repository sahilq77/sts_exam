import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors.dart';
import '../../utility/app_images.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Contact Us',
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
            // Business Name
            const Text(
              'REWOLT 2.0',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Contact Person
            Text(
              'Contact Person: Suvarna Tukaram Patil',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            // Address Section
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vanashree Apartment, Bhatwadi, Near Datta Mandir, Sawantwadi, Sindhudurg, Maharashtra, India - 416510',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Contact Details Section
            const Text(
              'Contact Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Email
            ListTile(
              leading: Icon(Icons.email, color: Colors.grey[600], size: 24),
              title: Text(
                'rewolt2020@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'rewolt2020@gmail.com',
                );
                try {
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not launch email client'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error launching email client: $e')),
                  );
                }
              },
            ),
            // Phone
            ListTile(
              leading: Icon(Icons.phone, color: Colors.grey[600], size: 24),
              title: Text(
                '+91 9763938234',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                _makingPhoneCall('+919763938234');
              },
            ),
            // Mobile
            ListTile(
              leading: Icon(
                Icons.phone_android,
                color: Colors.grey[600],
                size: 24,
              ),
              title: Text(
                '+91 8484003399',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () {
                _makingPhoneCall('+918484003399');
              },
            ),
            // Website
            ListTile(
              leading: Icon(Icons.web, color: Colors.grey[600], size: 24),
              title: Text(
                'Visit our Play Store page',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              onTap: () async {
                const url =
                    'https://play.google.com/store/apps/details?id=com.quick.vidyasarthi';
                final Uri websiteUri = Uri.parse(url);
                if (await canLaunchUrl(websiteUri)) {
                  await launchUrl(
                    websiteUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch website')),
                  );
                }
              },
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

  Future<void> _makingPhoneCall(String num) async {
    var _url = Uri.parse("tel:$num");
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }
}
