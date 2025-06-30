// To parse this JSON data, do
//
//     final getExamResultListResponse = getExamResultListResponseFromJson(jsonString);

import 'dart:convert';

List<GetExamResultListResponse> getExamResultListResponseFromJson(String str) =>
    List<GetExamResultListResponse>.from(
        json.decode(str).map((x) => GetExamResultListResponse.fromJson(x)));

String getExamResultListResponseToJson(List<GetExamResultListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetExamResultListResponse {
  String status;
  String message;
  List<ResultList> data;

  GetExamResultListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetExamResultListResponse.fromJson(Map<String, dynamic> json) =>
      GetExamResultListResponse(
        status: json["status"],
        message: json["message"],
        data: List<ResultList>.from(
            json["data"].map((x) => ResultList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ResultList {
  String testId;
  String testName;
  String attemptedTestId;
  String attemptDate;
  String yourScore;
  String scoreOutoff;
  int rank;
  int rankOutoff;
  int correct;
  int incorrect;
  int unattempted;
  String totalQuestions;
  String examStatus;

  ResultList({
    required this.testId,
    required this.testName,
    required this.attemptedTestId,
    required this.attemptDate,
    required this.yourScore,
    required this.scoreOutoff,
    required this.rank,
    required this.rankOutoff,
    required this.correct,
    required this.incorrect,
    required this.unattempted,
    required this.totalQuestions,
    required this.examStatus,
  });

  factory ResultList.fromJson(Map<String, dynamic> json) => ResultList(
        testId: json["test_id"],
        testName: json["test_name"],
        attemptedTestId: json["attempted_test_id"],
        attemptDate: json["attempt_date"],
        yourScore: json["your_score"],
        scoreOutoff: json["score_outoff"],
        rank: json["rank"],
        rankOutoff: json["rank_outoff"],
        correct: json["correct"],
        incorrect: json["incorrect"],
        unattempted: json["unattempted"],
        totalQuestions: json["total_questions"],
        examStatus: json["exam_status"],
      );

  Map<String, dynamic> toJson() => {
        "test_id": testId,
        "test_name": testName,
        "attempted_test_id": attemptedTestId,
        "attempt_date": attemptDate,
        "your_score": yourScore,
        "score_outoff": scoreOutoff,
        "rank": rank,
        "rank_outoff": rankOutoff,
        "correct": correct,
        "incorrect": incorrect,
        "unattempted": unattempted,
        "total_questions": totalQuestions,
        "exam_status": examStatus,
      };
}
