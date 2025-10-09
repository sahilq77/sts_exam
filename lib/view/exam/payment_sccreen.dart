import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/exam/payment_controller.dart';
import '../../utility/app_routes.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({Key? key}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final controller = Get.put(PaymentController());
  InAppWebViewController? _webViewController;
  // bool loading = true;

  @override
  void initState() {
    super.initState();
    // Log the payment URL for debugging
    log('Payment URL from controller: ${controller.paymentUrl.value}');
  }

  Future<void> _onRefresh() async {
    await _webViewController?.reload();
  }

  // Function to launch UPI URL
  Future<void> _launchUpiUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No UPI app found to handle the payment.'),
          ),
        );
      }
    } catch (e) {
      log("Error launching UPI URL: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to launch UPI app: $e')));
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                content: const Text('Do you want to cancel this transaction?'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.offAllNamed(AppRoutes.home);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('CCAvenue Payment')),
        body: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.paymentUrl.value.isEmpty
                  ? const Center(child: Text('Payment URL not available'))
                  : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: Stack(
                      children: [
                        InAppWebView(
                          initialUrlRequest: URLRequest(
                            url: WebUri(controller.paymentUrl.value),
                          ),
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                              useShouldOverrideUrlLoading: true,
                              mediaPlaybackRequiresUserGesture: false,
                              javaScriptEnabled: true,
                              javaScriptCanOpenWindowsAutomatically: true,
                            ),
                            android: AndroidInAppWebViewOptions(
                              useWideViewPort: false,
                              useHybridComposition: true,
                              loadWithOverviewMode: true,
                              domStorageEnabled: true,
                            ),
                            ios: IOSInAppWebViewOptions(
                              allowsInlineMediaPlayback: true,
                              enableViewportScale: true,
                              ignoresViewportScaleLimits: true,
                            ),
                          ),
                          onWebViewCreated: (
                            InAppWebViewController controller,
                          ) {
                            _webViewController = controller;
                          },
                          onLoadStart: (controller, url) {
                            log('Page started loading: $url');
                          },
                          onLoadStop: (controller, url) async {
                            log('Page finished loading: $url');
                            // setState(() {
                            //   loading = false;
                            // });
                          },
                          onLoadError: (controller, url, code, message) {
                            log('WebView error: $message (code: $code)');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error loading payment page: $message',
                                ),
                              ),
                            );
                          },
                          shouldOverrideUrlLoading: (
                            controller,
                            navigationAction,
                          ) async {
                            final uri = navigationAction.request.url!;
                            log("Navigating to URL: $uri");

                            // Check for UPI payment URLs
                            if (uri.toString().contains("phonepe://pay?") ||
                                uri.toString().contains("paytmmp://pay?") ||
                                uri.toString().contains("tez://upi/pay?") ||
                                uri.toString().contains("upi://pay?")) {
                              if (!await launchUrl(uri)) {}
                              return NavigationActionPolicy.CANCEL;
                            }

                            // Check for payment success or failure URLs
                            // Assuming CCAvenue redirects to specific URLs for success/failure
                            // Adjust the URL patterns based on your payment gateway's behavior
                            if (uri.toString().contains("Success")) {
                              // Extract transaction ID from URL or controller
                              // For demo purposes, using a dummy txn ID
                              String txnId =
                                  uri.queryParameters['txn'].toString();
                              _showPaymentSuccessDialog(context, txnId);
                              return NavigationActionPolicy.CANCEL;
                            } else if (uri.toString().contains(
                                  "cancelTransaction",
                                ) ||
                                uri.toString().contains("cancel")) {
                              // Extract transaction ID from URL or controller
                              String txnId =
                                  uri.queryParameters['txn_id'].toString();
                              _showPaymentFailedDialog(context, txnId);
                              return NavigationActionPolicy.CANCEL;
                            }

                            return NavigationActionPolicy.ALLOW;
                          },
                        ),
                        // if (loading) const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, String txn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Timer(const Duration(seconds: 3), () {
          Get.offNamed(AppRoutes.examInstruction);
        });
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/success.png',
                  width: 122,
                  height: 135,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4D4D4D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'TXN ID: $txn',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF353B43),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your payment for the exam has been received. You will be redirected to start your exam in 3 seconds.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF353B43),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentFailedDialog(BuildContext context, String txn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Timer(const Duration(seconds: 3), () {
          Get.offAllNamed(AppRoutes.home);
        });
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/failed.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Failed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4D4D4D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'TXN ID: $txn',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF353B43),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your payment for the exam could not be processed. You will be redirected to retry in 3 seconds.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF353B43),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
