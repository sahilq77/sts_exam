// To parse this JSON data, do
//
//     final getExamInstructionResponse = getExamInstructionResponseFromJson(jsonString);

import 'dart:convert';

List<GetExamInstructionResponse> getExamInstructionResponseFromJson(String str) => List<GetExamInstructionResponse>.from(json.decode(str).map((x) => GetExamInstructionResponse.fromJson(x)));

String getExamInstructionResponseToJson(List<GetExamInstructionResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetExamInstructionResponse {
    bool status;
    String message;
    List<Datum> data;

    GetExamInstructionResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetExamInstructionResponse.fromJson(Map<String, dynamic> json) => GetExamInstructionResponse(
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
    List<String> instructions;

    Datum({
        required this.id,
        required this.image,
        required this.examName,
        required this.duration,
        required this.totalQuestions,
        required this.instructions,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        image: json["image"],
        examName: json["exam_name"],
        duration: json["duration"],
        totalQuestions: json["total_questions"],
        instructions: List<String>.from(json["instructions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "exam_name": examName,
        "duration": duration,
        "total_questions": totalQuestions,
        "instructions": List<dynamic>.from(instructions.map((x) => x)),
    };
}
