import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../utility/app_images.dart';
import 'dotted_divider.dart';

// Displays payment receipt details with status, student info, and download option
class PaymentReceiptDetailsScreen extends StatelessWidget {
  // Required fields for receipt details
  final String status;
  final bool isPending;
  final String refNumber;
  final String studentName;
  final String date;
  final String amount;
  final String examName;

  const PaymentReceiptDetailsScreen({
    super.key,
    required this.status,
    required this.isPending,
    required this.refNumber,
    required this.studentName,
    required this.date,
    required this.amount,
    required this.examName,
  });

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
                border: Border.all(
                  color: const Color(0xFFE6DFDC),
                  width: 1.0,
                ),
                color: AppColors.Appbar,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                        0x1FAA_AAAA), // #AAAAAA1F in Flutter ARGB hex
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
                      amount,
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
                    _buildDetailRow('Ref Number', refNumber),
                    const SizedBox(height: 12),
                    _buildDetailRow('Student Name', studentName),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date', date),
                    const SizedBox(height: 12),
                    _buildDetailRow('Pay Status', status, isStatus: true),

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
                        examName,
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
                            amount,
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
                    const SizedBox(height: 20),
                    // Download receipt button
                    const Divider(
                      color: Color(0xFFEDEDED),
                      thickness: 1,
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Downloading receipt...'),
                            ),
                          );
                        },
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
