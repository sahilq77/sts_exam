import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stsexam/controller/payments/payment_receipt_link_controller.dart';
import '../../app_colors.dart';
import '../../model/payments/get_payments_receipt_response.dart';
import '../../utility/app_images.dart';
import 'dotted_divider.dart';

// Displays payment receipt details with status, student info, and download option
class PaymentReceiptDetailsScreen extends StatefulWidget {
  // Required fields for receipt details

  const PaymentReceiptDetailsScreen({super.key});

  @override
  State<PaymentReceiptDetailsScreen> createState() =>
      _PaymentReceiptDetailsScreenState();
}

class _PaymentReceiptDetailsScreenState
    extends State<PaymentReceiptDetailsScreen> {
  PaymentReciptList? receipt;
  final controller = Get.put(PaymentReceiptController());
  // Helper method to check Android version (API 33+ for READ_MEDIA_IMAGES)
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 33;
      } catch (e) {
        if (kDebugMode) {
          print('Error checking Android version: $e');
        }
        return false;
      }
    }
    return false;
  }

  // Request storage-related permissions based on Android version
  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      bool isAndroid13OrAbove = await _isAndroid13OrAbove();
      PermissionStatus status;

      if (isAndroid13OrAbove) {
        // For Android 13+ (API 33+), request READ_MEDIA_IMAGES
        status = await Permission.photos.request();
      } else {
        // For older Android versions, request storage permission
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        Fluttertoast.showToast(
          msg: "Please enable storage permission in settings",
          toastLength: Toast.LENGTH_LONG,
        );
        await openAppSettings();
        return false;
      } else {
        Fluttertoast.showToast(
          msg: "Storage permission denied",
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }
    }
    return true; // No permission needed for iOS or other platforms
  }

  // Validate if the URL points to a PDF
  Future<bool> _isValidPdfUrl(String url) async {
    try {
      final response = await Dio().head(url);
      final contentType = response.headers.value('content-type');
      if (kDebugMode) {
        print('Content-Type: $contentType');
      }
      return contentType?.contains('application/pdf') ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating URL: $e');
      }
      return false;
    }
  }

  Future<void> _downloadReceipt(String url) async {
    try {
      // Validate URL
      bool isValidPdf = await _isValidPdfUrl(url);
      if (!isValidPdf) {
        Fluttertoast.showToast(
          msg: "Invalid PDF URL or file type",
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      // Request storage permissions
      if (!await _requestStoragePermissions()) {
        return;
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create a unique filename
      String fileName =
          'receipt_${receipt!.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath = '${directory!.path}/$fileName';

      // Download the file with binary response
      final dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 30);
      await dio.download(
        url,
        filePath,
        options: Options(
          responseType: ResponseType.bytes, // Ensure binary response
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            Fluttertoast.showToast(
              msg: "Downloading: ${progress.toStringAsFixed(0)}%",
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
      );

      // Verify file integrity
      File file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        if (kDebugMode) {
          print('Downloaded file size: ${await file.length()} bytes');
        }
        Fluttertoast.showToast(
          msg: "Receipt downloaded to Downloads folder",
          toastLength: Toast.LENGTH_LONG,
        );

        // Open the downloaded file
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          Fluttertoast.showToast(
            msg: "Error opening file: ${result.message}",
            toastLength: Toast.LENGTH_LONG,
          );
        }

        // Share option
        await Share.shareXFiles([XFile(filePath)], text: 'Payment Receipt');
      } else {
        Fluttertoast.showToast(
          msg: "Downloaded file is empty or corrupted",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error downloading receipt: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      if (kDebugMode) {
        print('Download error: $e');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final payment = Get.arguments as PaymentReciptList;
    setState(() {
      receipt = payment;
    });
    if (receipt != null) {
      controller.fetchReciptUrl(id: receipt!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Receipt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: const Color(0xFFE6DFDC), width: 1.0),
                color: AppColors.Appbar,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0x1FAA_AAAA,
                    ), // #AAAAAA1F in Flutter ARGB hex
                    offset: const Offset(0, 8), // x=0, y=8
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: ClipOval(
                        child: Image.asset(
                          AppImages.success, // your asset image path here
                          width: 200,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Payment status icon
                    const SizedBox(height: 20),

                    const SizedBox(height: 16),
                    const Text(
                      'Payment Success!!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF474747),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receipt!.paymentAmount,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFEDEDED),
                      thickness: 1,
                      height: 20,
                    ),
                    // const SizedBox(height: 20),
                    _buildDetailRow('Ref Number', receipt!.receiptNo),
                    const SizedBox(height: 12),
                    _buildDetailRow('Txn Number', receipt!.transactionNo),
                    const SizedBox(height: 12),
                    _buildDetailRow('Student Name', receipt!.userName),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date', receipt!.paymentDate.toString()),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Pay Status',
                      receipt!.paymentStatus == "1" ? "Completed" : "Pending",
                      isStatus: true,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: DottedDivider(
                        color: Color(0xFFEDEDED),
                        height: 1,
                        dotWidth: 3,
                        spacing: 5,
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        receipt!.testName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF707070),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            receipt!.paymentAmount,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Color(0xFFEDEDED),
                      thickness: 1,
                      height: 20,
                    ),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              controller.url.value.isEmpty
                                  ? null
                                  : () =>
                                      _downloadReceipt(controller.url.value),
                          icon: Image.asset(
                            'assets/download.png',
                            width: 20,
                            height: 20,
                          ),
                          label: const Text('Download Payment Receipt'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Back to home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5733),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isExam = false,
  }) {
    Color getStatusColor(String status) {
      if (status.toLowerCase() == 'completed') {
        return Colors.green;
      } else if (status.toLowerCase() == 'pending') {
        return Colors.red;
      } else {
        return AppColors.textColor;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isExam ? 14 : 13,
            fontWeight: isExam ? FontWeight.bold : FontWeight.w400,
            color: isExam ? Colors.black87 : const Color(0xFF707070),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isExam ? 14 : 13,
            fontWeight: isExam ? FontWeight.bold : FontWeight.w500,
            color: isStatus ? getStatusColor(value) : AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
