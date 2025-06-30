// To parse this JSON data, do
//
//     final getNotificationsResponse = getNotificationsResponseFromJson(jsonString);

import 'dart:convert';

List<GetNotificationsResponse> getNotificationsResponseFromJson(String str) => List<GetNotificationsResponse>.from(json.decode(str).map((x) => GetNotificationsResponse.fromJson(x)));

String getNotificationsResponseToJson(List<GetNotificationsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetNotificationsResponse {
    bool status;
    String message;
    List<Datum> data;

    GetNotificationsResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) => GetNotificationsResponse(
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
    int time;
    String notificationDesc;

    Datum({
        required this.id,
        required this.time,
        required this.notificationDesc,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        time: json["time"],
        notificationDesc: json["notification_desc"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "time": time,
        "notification_desc": notificationDesc,
    };
}
