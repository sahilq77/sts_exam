// To parse this JSON data, do
//
//     final getRegisterResponse = getRegisterResponseFromJson(jsonString);

import 'dart:convert';

List<GetRegisterResponse> getRegisterResponseFromJson(String str) => List<GetRegisterResponse>.from(json.decode(str).map((x) => GetRegisterResponse.fromJson(x)));

String getRegisterResponseToJson(List<GetRegisterResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetRegisterResponse {
    String status;
    String message;
    Data data;

    GetRegisterResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetRegisterResponse.fromJson(Map<String, dynamic> json) => GetRegisterResponse(
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
    String id;
    String userType;
    String fullName;
    

    Data({
        required this.id,
        required this.userType,
        required this.fullName,
       
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        userType: json["user_type"],
        fullName: json["full_name"],
        
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "full_name": fullName,
       
    };
}
