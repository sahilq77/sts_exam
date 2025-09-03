import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:stsexam/controller/result_list/download_result_controller.dart';
import '../../app_colors.dart';
import '../../core/network/urls.dart';

class ViewResultScreen extends StatefulWidget {
  ViewResultScreen({super.key});

  @override
  _ViewResultScreenState createState() => _ViewResultScreenState();
}

class _ViewResultScreenState extends State<ViewResultScreen> {
  final controller = Get.put(DownloadResultController());
  String productID = '';
  String? receiptUrl; // To store the receipt URL
  bool isLoading = true; // To manage API loading state

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final testId = args['test_id'] as String?;
    print("test id $testId");
    setState(() {
      controller.fetchResult(context: context, testID: testId.toString());
    });
  }

  void shareReceiptUrl() {
    if (controller.resultLink != null) {
      final String customMessage =
          'Here is your result:\n${controller.resultLink}';

      Share.share(customMessage, subject: 'Result');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Result URL available to share.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("url: ${controller.resultLink.value}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        automaticallyImplyLeading: true,
        title: const Text('Result View'),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,

      body: Obx(
        () =>
            controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : PDF(fitEachPage: true).fromUrl(
                  controller.resultLink.value,
                  placeholder:
                      (progress) => Center(
                        child: CircularProgressIndicator(value: progress),
                      ),
                  errorWidget: (error) => Center(child: Text(error.toString())),
                ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   onPressed: fetchReportPdf,
          //   heroTag: 'refresh', // Trigger refresh action
          //   child: const Icon(Icons.refresh),
          // ),
          //  const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: shareReceiptUrl,
            heroTag: 'share', // Trigger share action
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}
