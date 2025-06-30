// To parse this JSON data, do
//
//     final testSubmitResponse = testSubmitResponseFromJson(jsonString);

import 'dart:convert';
import 'dart:ffi';

List<TestSubmitResponse> testSubmitResponseFromJson(String str) =>
    List<TestSubmitResponse>.from(
        json.decode(str).map((x) => TestSubmitResponse.fromJson(x)));

String testSubmitResponseToJson(List<TestSubmitResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TestSubmitResponse {
  String status;
  String message;
  Data data;

  TestSubmitResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TestSubmitResponse.fromJson(Map<String, dynamic> json) =>
      TestSubmitResponse(
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
  dynamic attemptedId;

  Data({
    required this.attemptedId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        attemptedId: json["attempted_id"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "attempted_id": attemptedId,
      };
}
