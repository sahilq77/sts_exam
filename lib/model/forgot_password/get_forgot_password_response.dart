import 'dart:convert';

GetForgotPasswordResponse getForgotPasswordResponseFromJson(String str) =>
    GetForgotPasswordResponse.fromJson(json.decode(str));

String getForgotPasswordResponseToJson(GetForgotPasswordResponse data) =>
    json.encode(data.toJson());

class GetForgotPasswordResponse {
  String status;
  String message;
  Data? data; // Made nullable to handle empty array

  GetForgotPasswordResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory GetForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      GetForgotPasswordResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : null, // Set to null if data is not a Map (e.g., empty array)
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
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