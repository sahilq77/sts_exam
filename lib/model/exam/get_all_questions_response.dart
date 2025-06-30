// To parse this JSON data, do
//
//     final getAllQuestionsResponse = getAllQuestionsResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllQuestionsResponse> getAllQuestionsResponseFromJson(String str) =>
    List<GetAllQuestionsResponse>.from(
        json.decode(str).map((x) => GetAllQuestionsResponse.fromJson(x)));

String getAllQuestionsResponseToJson(List<GetAllQuestionsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllQuestionsResponse {
  String status;
  String message;
  List<QuestionDetail> data;

  GetAllQuestionsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      GetAllQuestionsResponse(
        status: json["status"],
        message: json["message"],
        data: List<QuestionDetail>.from(
            json["data"].map((x) => QuestionDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class QuestionDetail {
  String testId;
  String examId;
  String examName;
  String testName;
  String shortNote;
  String shortDescription;
  String duration;
  String totalQuestions;
  String isShowResult;
  List<Question> questions;

  QuestionDetail({
    required this.testId,
    required this.examId,
    required this.examName,
    required this.testName,
    required this.shortNote,
    required this.shortDescription,
    required this.duration,
    required this.totalQuestions,
    required this.isShowResult,
    required this.questions,
  });

  factory QuestionDetail.fromJson(Map<String, dynamic> json) => QuestionDetail(
        testId: json["test_id"] ?? "",
        examId: json["exam_id"] ?? "",
        examName: json["exam_name"] ?? "",
        testName: json["test_name"] ?? "",
        shortNote: json["short_note"] ?? "",
        shortDescription: json["short_description"] ?? "",
        duration: json["duration"] ?? "",
        totalQuestions: json["total_questions"] ?? "",
        isShowResult: json["is_show_result"] ?? "",
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "test_id": testId,
        "exam_id": examId,
        "exam_name": examName,
        "test_name": testName,
        "short_note": shortNote,
        "short_description": shortDescription,
        "duration": duration,
        "total_questions": totalQuestions,
        "is_show_result": isShowResult,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
      };
}

class Question {
  String questionId;
  String? question;
  dynamic answerOption;
  String positiveMark;
  String negativeMark;
  Map<String, String> options;

  Question({
    required this.questionId,
    required this.question,
    required this.answerOption,
    required this.positiveMark,
    required this.negativeMark,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        questionId: json["question_id"] ?? "",
        question: json["question"] ?? "",
        answerOption: json["answer_option"] ?? "",
        positiveMark: json["positive_mark"] ?? "",
        negativeMark: json["negative_mark"] ?? "",
        options: Map.from(json["options"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "question": question,
        "answer_option": answerOption,
        "positive_mark": positiveMark,
        "negative_mark": negativeMark,
        "options":
            Map.from(options).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}


class OptionModel {
  final String id;
  final String text;
  OptionModel({required this.id, required this.text});
}
