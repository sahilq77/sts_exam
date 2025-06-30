import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/payments/payments_list_controller.dart';
import '../../utility/app_images.dart';
import '../../utility/widgets/custom_shimmer.dart';
import '../bottomnavigation/custom_bottom_bar.dart';
import 'payment_receipt_details_screen.dart';

class PaymentReceiptScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomController = Get.put(BottomNavigationController());
    final controller = Get.put(PaymentsListController());
    return WillPopScope(
      onWillPop: () {
        return bottomController.onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text(
            'Payment Receipt',
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

        body: RefreshIndicator(
          onRefresh: () => controller.refreshPaymentList(context: context),
          child: Obx(
            () =>
                controller.isLoading.value
                    ? CutsomShimmer()
                    : controller.paymentList.value.isEmpty
                    ? Center(child: Image.asset(AppImages.empty))
                    : ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: controller.paymentList.value.length,
                      itemBuilder: (context, index) {
                        print(controller.paymentList.toString());
                        var payment = controller.paymentList.value[index];
                        bool isPending = index % 2 == 0;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PaymentReceiptDetailsScreen(
                                      status: payment.paymentStatus,
                                      isPending: isPending,
                                      refNumber: payment.refNumber.toString(),
                                      studentName: payment.studentName,
                                      date: payment.date,
                                      amount: '₹${payment.amount.toString()}',
                                      examName:
                                          'Special Class Railway Apprentice Examination',
                                    ),
                              ),
                            );
                          },
                          child: PaymentReceiptCard(
                            status: isPending ? 'Pending' : 'Completed',
                            isPending: isPending,
                            refNumber: payment.refNumber,
                            studentName: payment.studentName,
                            date: payment.date,
                            amount: payment.amount,
                            paymentStatus: payment.paymentStatus,
                          ),
                        );
                      },
                    ),
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }
}

class PaymentReceiptCard extends StatelessWidget {
  final String status;
  final bool isPending;
  final int refNumber;
  final String studentName;
  final String date;
  final String paymentStatus;
  final int amount;
  PaymentReceiptCard({
    required this.status,
    required this.isPending,
    required this.refNumber,
    required this.studentName,
    required this.date,
    required this.paymentStatus,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Special Class Railway Apprentice Examination',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          paymentStatus == "Pending"
                              ? Colors.red
                              : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      paymentStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ref number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF707070),
                  ),
                ),
                Text(
                  refNumber.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF707070),
                  ),
                ),
                Text(
                  studentName.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF707070),
                  ),
                ),
                Text(
                  date.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF707070),
                  ),
                ),
                Text(
                  '₹${amount.toString()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
