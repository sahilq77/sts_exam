// To parse this JSON data, do
//
//     final getDeleteUserResponse = getDeleteUserResponseFromJson(jsonString);

import 'dart:convert';

List<GetDeleteUserResponse> getDeleteUserResponseFromJson(String str) => List<GetDeleteUserResponse>.from(json.decode(str).map((x) => GetDeleteUserResponse.fromJson(x)));

String getDeleteUserResponseToJson(List<GetDeleteUserResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDeleteUserResponse {
    String status;
    String message;

    GetDeleteUserResponse({
        required this.status,
        required this.message,
    });

    factory GetDeleteUserResponse.fromJson(Map<String, dynamic> json) => GetDeleteUserResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
