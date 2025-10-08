// To parse this JSON data, do
//
//     final availableExamListResponse = availableExamListResponseFromJson(jsonString);

import 'dart:convert';

List<AvailableExamListResponse> availableExamListResponseFromJson(String str) =>
    List<AvailableExamListResponse>.from(
      json.decode(str).map((x) => AvailableExamListResponse.fromJson(x)),
    );

String availableExamListResponseToJson(List<AvailableExamListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AvailableExamListResponse {
  String status;
  String message;
  List<AvailableExam> data;
  String imageLink;

  AvailableExamListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.imageLink,
  });

  factory AvailableExamListResponse.fromJson(Map<String, dynamic> json) =>
      AvailableExamListResponse(
        status: json["status"],
        message: json["message"],
        data: List<AvailableExam>.from(
          json["data"].map((x) => AvailableExam.fromJson(x)),
        ),
        imageLink: json["image_link"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "image_link": imageLink,
  };
}

class AvailableExam {
  String id;
  String examId;
  String testName;
  String shortNote;
  String shortDescription;
  String duration;
  String questionsFile;
  String questionsFileName;
  String questionsShuffle;
  String showResult;
  String testImage;
  String amount;
  String instructionDescription;
  // DateTime resultDateTime;
  // dynamic resultTime;
  String status;
  String isDeleted;
  // DateTime createdOn;
  // DateTime updatedOn;
  String examName;
  int questionCount;
  String questionSCount;
  String testType;
  bool isAttempted;
  int attemptCount;
  int isPaid;
  AvailableExam({
    required this.id,
    required this.examId,
    required this.testName,
    required this.shortNote,
    required this.shortDescription,
    required this.duration,
    required this.questionsFile,
    required this.questionsFileName,
    required this.questionsShuffle,
    required this.showResult,
    required this.testImage,
    required this.amount,
    required this.instructionDescription,
    // required this.resultDateTime,
    // required this.resultTime,
    required this.status,
    required this.isDeleted,
    // required this.createdOn,
    // required this.updatedOn,
    required this.examName,
    required this.questionCount,
    required this.questionSCount,
    required this.testType,
    required this.isAttempted,
    required this.attemptCount,
    required this.isPaid,
  });

  factory AvailableExam.fromJson(Map<String, dynamic> json) => AvailableExam(
    id: json["id"] ?? "",
    examId: json["exam_id"] ?? "",
    testName: json["test_name"] ?? "",
    shortNote: json["short_note"] ?? "",
    shortDescription: json["short_description"] ?? "",
    duration: json["duration"] ?? "",
    questionsFile: json["questions_file"] ?? "",
    questionsFileName: json["questions_file_name"] ?? "",
    questionsShuffle: json["questions_shuffle"] ?? "",
    showResult: json["show_result"] ?? "",
    testImage: json["test_image"] ?? "",
    amount: json["amount"] ?? "",
    instructionDescription: json["instruction_description"] ?? "",
    // resultDateTime: DateTime.parse(json["result_date_time"]??""),
    // resultTime: json["result_time"]??"",
    status: json["status"] ?? "",
    isDeleted: json["is_deleted"] ?? "",
    // createdOn: DateTime.parse(json["created_on"]),
    // updatedOn: DateTime.parse(json["updated_on"]),
    examName: json["exam_name"] ?? "",
    questionCount: json["question_count"] ?? "",
    questionSCount: json["questions_count"] ?? "",
    testType: json["test_type"] ?? "",
    isAttempted: json["is_attempted"],
    attemptCount: json["attempted_count"] ?? "",
    isPaid: json["is_paid"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "exam_id": examId,
    "test_name": testName,
    "short_note": shortNote,
    "short_description": shortDescription,
    "duration": duration,
    "questions_file": questionsFile,
    "questions_file_name": questionsFileName,
    "questions_shuffle": questionsShuffle,
    "show_result": showResult,
    "test_image": testImage,
    "amount": amount,
    "instruction_description": instructionDescription,
    // "result_date_time": resultDateTime.toIso8601String(),
    // "result_time": resultTime,
    "status": status,
    "is_deleted": isDeleted,
    // "created_on": createdOn.toIso8601String(),
    // "updated_on": updatedOn.toIso8601String(),
    "exam_name": examName,
    "question_count": questionCount,
    "questions_count": questionSCount,
    "test_type": testType,
    "is_attempted": isAttempted,
    "attempted_count": attemptCount,
  };
}
