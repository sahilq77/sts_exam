import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stsexam/utility/customdesign/connctivityservice.dart';
import '../../app_colors.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  StreamSubscription<bool>? _connectivitySubscription;
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    // Start listening to connectivity changes
    _connectivitySubscription = _connectivityService.connectionStatus.listen((
      isConnected,
    ) {
      if (isConnected && mounted) {
        _handleReconnect();
      }
    });

    // Initial connectivity check on page load
    _checkInitialConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected && mounted) {
      await _handleReconnect();
    }
  }

  Future<void> _handleReconnect() async {
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!mounted) {
        debugPrint(
          'NoInternetScreen: Widget is not mounted, skipping reconnect',
        );
        return;
      }
      if (isConnected) {
        debugPrint('NoInternetScreen: Connection restored, navigating back');
        Get.offAllNamed('/home'); // Replace '/home' with your home route name
        Get.snackbar(
          'Connection Restored',
          'Internet connection is back online.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        debugPrint('NoInternetScreen: Still no internet connection');
      }
    } catch (e) {
      debugPrint('NoInternetScreen: Error during reconnect - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Exit App',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'No internet connection. Are you sure you want to exit the app?',
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: AppColors.primaryColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Exit',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: Container(
          color: AppColors.primaryColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(AppImages.logoP, height: 280, width: 280),
                const SizedBox(height: 20),
                Text(
                  'No Internet Connection',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please check your internet connection\nand try again',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed:
                        _isRetrying
                            ? null
                            : () async {
                              setState(() => _isRetrying = true);
                              try {
                                final isConnected =
                                    await _connectivityService
                                        .checkConnectivity();
                                if (isConnected && mounted) {
                                  await _handleReconnect();
                                } else {
                                  Get.snackbar(
                                    'No Connection',
                                    'Still no internet. Please try again.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                }
                              } catch (e) {
                                debugPrint(
                                  'NoInternetScreen: Error during retry - $e',
                                );
                                Get.snackbar(
                                  'Error',
                                  'An error occurred while checking connectivity.',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isRetrying = false);
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isRetrying
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
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
}
