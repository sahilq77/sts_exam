// To parse this JSON data, do
//
//     final getPaymentUrlResponse = getPaymentUrlResponseFromJson(jsonString);

import 'dart:convert';

List<GetPaymentUrlResponse> getPaymentUrlResponseFromJson(String str) => List<GetPaymentUrlResponse>.from(json.decode(str).map((x) => GetPaymentUrlResponse.fromJson(x)));

String getPaymentUrlResponseToJson(List<GetPaymentUrlResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPaymentUrlResponse {
    String status;
    String message;
    String paymentUrl;

    GetPaymentUrlResponse({
        required this.status,
        required this.message,
        required this.paymentUrl,
    });

    factory GetPaymentUrlResponse.fromJson(Map<String, dynamic> json) => GetPaymentUrlResponse(
        status: json["status"],
        message: json["message"],
        paymentUrl: json["payment_url"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "payment_url": paymentUrl,
    };
}
