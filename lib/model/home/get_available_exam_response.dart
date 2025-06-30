// To parse this JSON data, do
//
//     final getAvailableExamResponse = getAvailableExamResponseFromJson(jsonString);

import 'dart:convert';

List<GetAvailableExamResponse> getAvailableExamResponseFromJson(String str) => List<GetAvailableExamResponse>.from(json.decode(str).map((x) => GetAvailableExamResponse.fromJson(x)));

String getAvailableExamResponseToJson(List<GetAvailableExamResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAvailableExamResponse {
    bool status;
    String message;
    List<Datum> data;

    GetAvailableExamResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetAvailableExamResponse.fromJson(Map<String, dynamic> json) => GetAvailableExamResponse(
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
    int examId;
    String image;
    String examName;
    int examTime;
    int totalQuestions;
    String description;

    Datum({
        required this.examId,
        required this.image,
        required this.examName,
        required this.examTime,
        required this.totalQuestions,
        required this.description,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        examId: json["exam_id"],
        image: json["image"],
        examName: json["exam_name"],
        examTime: json["exam_time"],
        totalQuestions: json["total_questions"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "exam_id": examId,
        "image": image,
        "exam_name": examName,
        "exam_time": examTime,
        "total_questions": totalQuestions,
        "description": description,
    };
}
