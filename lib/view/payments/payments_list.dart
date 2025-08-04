import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stsexam/utility/app_routes.dart';
import '../../app_colors.dart';
import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/payments/payments_list_controller.dart';
import '../../utility/app_images.dart';
import '../../utility/dateformater.dart';
import '../../utility/widgets/custom_shimmer.dart';
import '../bottomnavigation/custom_bottom_bar.dart';
import 'payment_receipt_details_screen.dart';

class PaymentReceiptScreen extends StatefulWidget {
  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Get.put(PaymentsListController());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.fetchPaymentList(context: context, isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomController = Get.find<BottomNavigationController>();
    final controller = Get.put(PaymentsListController());
    return WillPopScope(
      onWillPop: () => bottomController.onWillPop(),
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
                    : controller.paymentList.isEmpty
                    ? Center(child: Image.asset(AppImages.empty))
                    : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount:
                          controller.paymentList.length +
                          (controller.hasMoreData.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.paymentList.length) {
                          return controller.isLoadingMore.value
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No more data',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                        }
                        var payment = controller.paymentList[index];
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.paymentReceiptdetail,
                              arguments: payment,
                            );
                          },
                          child: PaymentReceiptCard(
                            txnNumber: payment.transactionNo,
                            testname: payment.testName,
                            status:
                                payment.paymentStatus == "1"
                                    ? 'Completed'
                                    : 'Pending',
                            isPending:
                                payment.paymentStatus == "1" ? false : true,
                            refNumber: payment.receiptNo,
                            studentName: payment.userName,
                            date: DateFormater.formatDate(
                              payment.paymentDate.toString(),
                            ),
                            amount: payment.paymentAmount,
                            paymentStatus:
                                payment.paymentStatus == "1"
                                    ? 'Completed'
                                    : 'Pending',
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
  final String testname;
  final String status;
  final bool isPending;
  final String refNumber;
  final String txnNumber;
  final String studentName;
  final String date;
  final String paymentStatus;
  final String amount;

  const PaymentReceiptCard({
    required this.txnNumber,
    required this.testname,
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
                  Expanded(
                    child: Text(
                      testname,
                      style: const TextStyle(
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
                const Text(
                  'Ref Number',
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
                const Text(
                  'Txn Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF707070),
                  ),
                ),
                Text(
                  txnNumber.toString(),
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
                const Text(
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
                const Text(
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
                const Text(
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
