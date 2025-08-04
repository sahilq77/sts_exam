// To parse this JSON data, do
//
//     final getOverviewResponse = getOverviewResponseFromJson(jsonString);

import 'dart:convert';

List<GetOverviewResponse> getOverviewResponseFromJson(String str) =>
    List<GetOverviewResponse>.from(
      json.decode(str).map((x) => GetOverviewResponse.fromJson(x)),
    );

String getOverviewResponseToJson(List<GetOverviewResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetOverviewResponse {
  String status;
  String message;
  List<Overview> questions;
  String imageBaseUrl;

  GetOverviewResponse({
    required this.status,
    required this.message,
    required this.questions,
    required this.imageBaseUrl,
  });

  factory GetOverviewResponse.fromJson(Map<String, dynamic> json) =>
      GetOverviewResponse(
        status: json["status"],
        message: json["message"],
        questions: List<Overview>.from(
          json["questions"].map((x) => Overview.fromJson(x)),
        ),
        imageBaseUrl: json["image_base_url"],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
    "image_base_url": imageBaseUrl,
  };
}

class Overview {
  String questionNumber;
  QuestionQuestion question;

  dynamic questionImage;
  List<Option> options;
  String selectedAnswer;
  bool isCorrect;
  String correctAnswer;

  Overview({
    required this.questionNumber,
    required this.question,
    required this.questionImage,
    required this.options,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.correctAnswer,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => Overview(
    questionNumber: json["questionNumber"] ?? "",
    question: QuestionQuestion.fromJson(json["question"]),
    questionImage: json["questionImage"] ?? "",
    options: List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
    selectedAnswer: json["selectedAnswer"] ?? "",
    isCorrect: json["isCorrect"] ?? "",
    correctAnswer: json["correct_answer"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "questionNumber": questionNumber,
    "question": question,
    "questionImage": questionImage,
    "options": List<dynamic>.from(options.map((x) => x.toJson())),
    "selectedAnswer": selectedAnswer,
    "isCorrect": isCorrect,
    "correct_answer": correctAnswer,
  };
}

class QuestionQuestion {
  String image;
  String text;

  QuestionQuestion({required this.image, required this.text});

  factory QuestionQuestion.fromJson(Map<String, dynamic> json) =>
      QuestionQuestion(image: json["image"] ?? "", text: json["text"] ?? "");

  Map<String, dynamic> toJson() => {"image": image, "text": text};
}

class Option {
  String text;
  dynamic image;

  Option({required this.text, required this.image});

  factory Option.fromJson(Map<String, dynamic> json) =>
      Option(text: json["text"] ?? "", image: json["image"] ?? "");

  Map<String, dynamic> toJson() => {"text": text, "image": image};
}
