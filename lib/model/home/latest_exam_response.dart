// To parse this JSON data, do
//
//     final getLatestExamResponse = getLatestExamResponseFromJson(jsonString);

import 'dart:convert';

List<GetLatestExamResponse> getLatestExamResponseFromJson(String str) => List<GetLatestExamResponse>.from(json.decode(str).map((x) => GetLatestExamResponse.fromJson(x)));

String getLatestExamResponseToJson(List<GetLatestExamResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLatestExamResponse {
    bool status;
    String message;
    List<Datum> data;

    GetLatestExamResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetLatestExamResponse.fromJson(Map<String, dynamic> json) => GetLatestExamResponse(
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
    int totalQuestion;
    int correct;
    int incorrect;

    Datum({
        required this.totalQuestion,
        required this.correct,
        required this.incorrect,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        totalQuestion: json["total_question"],
        correct: json["correct"],
        incorrect: json["incorrect"],
    );

    Map<String, dynamic> toJson() => {
        "total_question": totalQuestion,
        "correct": correct,
        "incorrect": incorrect,
    };
}
