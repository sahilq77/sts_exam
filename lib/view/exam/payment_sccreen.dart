import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stsexam/controller/exam/payment_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

import '../../utility/app_routes.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({Key? key}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  final controller = Get.put(PaymentController());

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition for Android
  }

  Future<void> _onRefresh() async {
    // Reload the WebView
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('CCAvenue Payment')),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showPaymentSuccessDialog(context, "ORDER7744545448"),
      // ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: WebViewWidget(
                    controller:
                        _controller =
                            WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..setNavigationDelegate(
                                NavigationDelegate(
                                  onPageStarted: (String url) {
                                    print('Page started loading: $url');
                                  },
                                  onPageFinished: (String url) {
                                    print('Page finished loading: $url');
                                  },

                                  onWebResourceError: (WebResourceError error) {
                                    print(
                                      'WebView error: ${error.description}',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error loading payment page: ${error.description}',
                                        ),
                                      ),
                                    );
                                  },

                                  onNavigationRequest: (
                                    NavigationRequest request,
                                  ) {
                                    if (request.url.contains('Success')) {
                                      final uri = Uri.parse(request.url);
                                      String? txn = uri.queryParameters['txn'];

                                      // If txn is not null, show the payment success dialog
                                      if (txn != null) {
                                        _showPaymentSuccessDialog(context, txn);
                                      } else {
                                        // Handle case where txn is not found in the URL
                                        _showPaymentSuccessDialog(
                                          context,
                                          "Unknown Transaction",
                                        );
                                      }
                                      return NavigationDecision.prevent;
                                    } else if (request.url.contains(
                                      'Failure',
                                    )) {
                                      final uri = Uri.parse(request.url);
                                      String? txn = uri.queryParameters['txn'];

                                      // If txn is not null, show the payment success dialog
                                      if (txn != null) {
                                        _showPaymentFailedDialog(context, txn);
                                        // Navigator.pop(
                                        //   context,
                                        //   'Payment Failed or Cancelled',
                                        // );
                                      } else {
                                        // Handle case where txn is not found in the URL
                                        _showPaymentFailedDialog(
                                          context,
                                          "Unknown Transaction",
                                        );
                                      }
                                      // Navigator.pop(
                                      //   context,
                                      //   'Payment Failed or Cancelled',
                                      // );
                                      return NavigationDecision.prevent;
                                    } else if (request.url.contains(
                                          'cancelTransaction',
                                        ) ||
                                        request.url.contains('cancel')) {}
                                    print("cn========>");

                                    return NavigationDecision.navigate;
                                  },
                                ),
                              )
                              ..loadRequest(
                                Uri.parse(controller.paymentUrl.value),
                              ),
                  ),
                ),
      ),
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, String txn) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Start a timer to redirect after 3 seconds
        Timer(Duration(seconds: 3), () {
          Get.offNamed(AppRoutes.examInstruction);
        });

        return PopScope(
          canPop:
              false, // Prevents the dialog from being dismissed by back button
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
                  'Payment Successful !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4D4D4D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'TXN ID: ${txn}',
                  style: TextStyle(
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
                // const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(dialogContext); // Close the dialog
                //     Navigator.pushNamed(
                //       dialogContext,
                //       '/exam',
                //     ); // Navigate to exam
                //   },
                //   child: const Text('Start Exam Now'),
                // ),
                const SizedBox(height: 10),
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
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Start a timer to redirect after 3 seconds
        Timer(Duration(seconds: 3), () {
          Get.offAllNamed(AppRoutes.home); // Adjust route as needed
        });

        return PopScope(
          canPop:
              false, // Prevents the dialog from being dismissed by back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/failed.png', // Ensure you have a failure image asset
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
                  'TXN ID: ${txn}',
                  style: TextStyle(
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
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
