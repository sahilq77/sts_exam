// To parse this JSON data, do
//
//     final getAllNotificationsResponse = getAllNotificationsResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllNotificationsResponse> getAllNotificationsResponseFromJson(
  String str,
) => List<GetAllNotificationsResponse>.from(
  json.decode(str).map((x) => GetAllNotificationsResponse.fromJson(x)),
);

String getAllNotificationsResponseToJson(
  List<GetAllNotificationsResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllNotificationsResponse {
  String status;
  String message;
  List<AppNotification> data;

  GetAllNotificationsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      GetAllNotificationsResponse(
        status: json["status"],
        message: json["message"],
        data: List<AppNotification>.from(
          json["data"].map((x) => AppNotification.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AppNotification {
  String id;
  String userId;
  String attemptedTestId;
  String notificationTitle;
  String notification;

  DateTime createdOn;


  AppNotification({
    required this.id,
    required this.userId,
    required this.attemptedTestId,
    required this.notificationTitle,
    required this.notification,
  
    required this.createdOn,
   
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json["id"],
        userId: json["user_id"],
        attemptedTestId: json["attempted_test_id"],
        notificationTitle: json["notification_title"],
        notification: json["notification"],
      
        createdOn: DateTime.parse(json["created_on"]),
      
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "attempted_test_id": attemptedTestId,
    "notification_title": notificationTitle,
    "notification": notification,
    "created_on": createdOn.toIso8601String(),
    
  };
}
