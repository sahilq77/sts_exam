// To parse this JSON data, do
//
//     final getUserProfileResponse = getUserProfileResponseFromJson(jsonString);

import 'dart:convert';

List<GetUserProfileResponse> getUserProfileResponseFromJson(String str) =>
    List<GetUserProfileResponse>.from(
        json.decode(str).map((x) => GetUserProfileResponse.fromJson(x)));

String getUserProfileResponseToJson(List<GetUserProfileResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetUserProfileResponse {
  String status;
  String message;
  UserProfile data;
  String imageLink;

  GetUserProfileResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.imageLink,
  });

  factory GetUserProfileResponse.fromJson(Map<String, dynamic> json) =>
      GetUserProfileResponse(
        status: json["status"],
        message: json["message"],
        data: UserProfile.fromJson(json["data"]),
        imageLink: json["image_link"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
        "image_link": imageLink,
      };
}

class UserProfile {
  String id;
  String userType;
  String fullName;
  dynamic profileImage;

  String gender;
  String email;
  String mobileNumber;
  String udisNumber;
  String schoolName;
  String state;
  String city;

  UserProfile({
    required this.id,
    required this.userType,
    required this.fullName,
    required this.profileImage,
    required this.gender,
    required this.email,
    required this.mobileNumber,
    required this.udisNumber,
    required this.schoolName,
    required this.state,
    required this.city,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"] ?? "",
        userType: json["user_type"] ?? "",
        fullName: json["full_name"] ?? "",
        profileImage: json["profile_image"] ?? "",
        gender: json["gender"] ?? "",
        email: json["email"] ?? "",
        mobileNumber: json["mobile_number"] ?? "",
        udisNumber: json["udis_number"] ?? "",
        schoolName: json["school_name"] ?? "",
        state: json["state"] ?? "",
        city: json["city"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "full_name": fullName,
        "profile_image": profileImage,
        "gender": gender,
        "email": email,
        "mobile_number": mobileNumber,
        "udis_number": udisNumber,
        "school_name": schoolName,
        "state": state,
        "city": city,
      };
}
