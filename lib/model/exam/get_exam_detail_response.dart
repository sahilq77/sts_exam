// To parse this JSON data, do
//
//     final getExamDetailResponse = getExamDetailResponseFromJson(jsonString);

import 'dart:convert';

List<GetExamDetailResponse> getExamDetailResponseFromJson(String str) => List<GetExamDetailResponse>.from(json.decode(str).map((x) => GetExamDetailResponse.fromJson(x)));

String getExamDetailResponseToJson(List<GetExamDetailResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetExamDetailResponse {
    bool status;
    String message;
    List<Datum> data;

    GetExamDetailResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetExamDetailResponse.fromJson(Map<String, dynamic> json) => GetExamDetailResponse(
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
    String image;
    String examName;
    int duration;
    int totalQuestions;
    String desciption;

    Datum({
        required this.id,
        required this.image,
        required this.examName,
        required this.duration,
        required this.totalQuestions,
        required this.desciption,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        image: json["image"],
        examName: json["exam_name"],
        duration: json["duration"],
        totalQuestions: json["total_questions"],
        desciption: json["desciption"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "exam_name": examName,
        "duration": duration,
        "total_questions": totalQuestions,
        "desciption": desciption,
    };
}
