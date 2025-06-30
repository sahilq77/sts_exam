// To parse this JSON data, do
//
//     final getPaymentReciptListResponse = getPaymentReciptListResponseFromJson(jsonString);

import 'dart:convert';

List<GetPaymentReciptListResponse> getPaymentReciptListResponseFromJson(String str) => List<GetPaymentReciptListResponse>.from(json.decode(str).map((x) => GetPaymentReciptListResponse.fromJson(x)));

String getPaymentReciptListResponseToJson(List<GetPaymentReciptListResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPaymentReciptListResponse {
    bool status;
    String message;
    List<Datum> data;

    GetPaymentReciptListResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetPaymentReciptListResponse.fromJson(Map<String, dynamic> json) => GetPaymentReciptListResponse(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int id;
    int refNumber;
    String studentName;
    String date;
    String paymentStatus;
    int amount;

    Datum({
        required this.id,
        required this.refNumber,
        required this.studentName,
        required this.date,
        required this.paymentStatus,
        required this.amount,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        refNumber: json["ref number"],
        studentName: json["student_name"],
        date: json["date"],
        paymentStatus: json["payment_status"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "ref number": refNumber,
        "student_name": studentName,
        "date": date,
        "payment_status": paymentStatus,
        "amount": amount,
    };
}
