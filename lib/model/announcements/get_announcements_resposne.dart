// To parse this JSON data, do
//
//     final getAnnouncementsResponse = getAnnouncementsResponseFromJson(jsonString);

import 'dart:convert';

List<GetAnnouncementsResponse> getAnnouncementsResponseFromJson(String str) =>
    List<GetAnnouncementsResponse>.from(
      json.decode(str).map((x) => GetAnnouncementsResponse.fromJson(x)),
    );

String getAnnouncementsResponseToJson(List<GetAnnouncementsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAnnouncementsResponse {
  String status;
  String message;
  List<AnnouncementData> data;

  GetAnnouncementsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAnnouncementsResponse.fromJson(Map<String, dynamic> json) =>
      GetAnnouncementsResponse(
        status: json["status"],
        message: json["message"],
        data: List<AnnouncementData>.from(json["data"].map((x) => AnnouncementData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AnnouncementData {
  String title;

  AnnouncementData({required this.title});

  factory AnnouncementData.fromJson(Map<String, dynamic> json) =>
      AnnouncementData(title: json["title"] ?? "");

  Map<String, dynamic> toJson() => {"title": title};
}
