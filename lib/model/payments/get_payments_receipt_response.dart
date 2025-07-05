// To parse this JSON data, do
//
//     final getPaymentListResponse = getPaymentListResponseFromJson(jsonString);

import 'dart:convert';

List<GetPaymentListResponse> getPaymentListResponseFromJson(String str) =>
    List<GetPaymentListResponse>.from(
      json.decode(str).map((x) => GetPaymentListResponse.fromJson(x)),
    );

String getPaymentListResponseToJson(List<GetPaymentListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPaymentListResponse {
  String status;
  String message;
  List<PaymentReciptList> data;

  GetPaymentListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetPaymentListResponse.fromJson(Map<String, dynamic> json) =>
      GetPaymentListResponse(
        status: json["status"],
        message: json["message"],
        data: List<PaymentReciptList>.from(
          json["data"].map((x) => PaymentReciptList.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PaymentReciptList {
  String id;
  String userId;
  String userType;
  String userName;
  String email;
  String paymentStatus;
  String testName;
  String paymentAmount;
  String transactionNo;
  DateTime paymentDate;
  String testId;
  String receiptNo;
  String isDeleted;
  String status;


  PaymentReciptList({
    required this.id,
    required this.userId,
    required this.userType,
    required this.userName,
    required this.email,
    required this.paymentStatus,
    required this.testName,
    required this.paymentAmount,
    required this.transactionNo,
    required this.paymentDate,
    required this.testId,
    required this.receiptNo,
    required this.isDeleted,
    required this.status,
  });

  factory PaymentReciptList.fromJson(Map<String, dynamic> json) =>
      PaymentReciptList(
        id: json["id"] ?? "",
        userId: json["user_id"] ?? "",
        userType: json["user_type"] ?? "",
        userName: json["user_name"] ?? "",
        email: json["email"] ?? "",
        paymentStatus: json["payment_status"] ?? "",
        testName: json["test_name"] ?? "",
        paymentAmount: json["payment_amount"] ?? "",
        transactionNo: json["transaction_no"] ?? "",
        paymentDate: DateTime.parse(json["payment_date"]),
        testId: json["test_id"] ?? "",
        receiptNo: json["receipt_no"] ?? "",
        isDeleted: json["is_deleted"] ?? "",
        status: json["status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "user_type": userType,
    "user_name": userName,
    "email": email,
    "payment_status": paymentStatus,
    "test_name": testName,
    "payment_amount": paymentAmount,
    "transaction_no": transactionNo,
    "payment_date":
        "${paymentDate.year.toString().padLeft(4, '0')}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}",
    "test_id": testId,
    "receipt_no": receiptNo,
    "is_deleted": isDeleted,
    "status": status,
  
  };
}
