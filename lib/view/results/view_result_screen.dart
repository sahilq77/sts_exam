import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
          'result_${"767565"}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
    super.initState();
    final args = Get.arguments;
    final testId = args['test_id'] as String?;
    final atemptId = args['attempt_id'] as String?;
    print("test id $testId");
    setState(() {
      controller.fetchResult(
        context: context,
        testID: testId.toString(),
        attemptID: atemptId.toString(),
      );
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
            onPressed:
                controller.resultLink.value.isEmpty
                    ? null
                    : () async {
                      print("Url ${controller.resultLink.value}");
                      await _downloadReceipt(controller.resultLink.value);
                    },
            heroTag: 'share', // Trigger share action
            child: const Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
