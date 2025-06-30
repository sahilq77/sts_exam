// To parse this JSON data, do
//
//     final getLoginResponse = getLoginResponseFromJson(jsonString);

import 'dart:convert';

List<GetLoginResponse> getLoginResponseFromJson(String str) =>
    List<GetLoginResponse>.from(
        json.decode(str).map((x) => GetLoginResponse.fromJson(x)));

String getLoginResponseToJson(List<GetLoginResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLoginResponse {
  String status;
  String message;
  Data data;

  GetLoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetLoginResponse.fromJson(Map<String, dynamic> json) =>
      GetLoginResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String userid;
  String userType;
  String fullName;

  Data({
    required this.userid,
    required this.userType,
    required this.fullName,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userid: json["user_id"],
        userType: json["user_type"],
        fullName: json["full_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userid,
        "user_type": userType,
        "full_name": fullName,
      };
}
