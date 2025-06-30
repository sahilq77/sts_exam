// To parse this JSON data, do
//
//     final getBuyResponse = getBuyResponseFromJson(jsonString);

import 'dart:convert';

List<GetBuyResponse> getBuyResponseFromJson(String str) => List<GetBuyResponse>.from(json.decode(str).map((x) => GetBuyResponse.fromJson(x)));

String getBuyResponseToJson(List<GetBuyResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetBuyResponse {
    String status;
    String message;
    bool data;

    GetBuyResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetBuyResponse.fromJson(Map<String, dynamic> json) => GetBuyResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
    };
}
