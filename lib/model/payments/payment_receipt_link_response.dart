// To parse this JSON data, do
//
//     final getPaymentReceiptLinkResponse = getPaymentReceiptLinkResponseFromJson(jsonString);

import 'dart:convert';

List<GetPaymentReceiptLinkResponse> getPaymentReceiptLinkResponseFromJson(
  String str,
) => List<GetPaymentReceiptLinkResponse>.from(
  json.decode(str).map((x) => GetPaymentReceiptLinkResponse.fromJson(x)),
);

String getPaymentReceiptLinkResponseToJson(
  List<GetPaymentReceiptLinkResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPaymentReceiptLinkResponse {
  String status;
  String message;
  String paymentReceiptPdf;

  GetPaymentReceiptLinkResponse({
    required this.status,
    required this.message,
    required this.paymentReceiptPdf,
  });

  factory GetPaymentReceiptLinkResponse.fromJson(Map<String, dynamic> json) =>
      GetPaymentReceiptLinkResponse(
        status: json["status"],
        message: json["message"],
        paymentReceiptPdf: json["payment_receipt_pdf"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "payment_receipt_pdf": paymentReceiptPdf,
  };
}
