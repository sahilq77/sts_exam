// To parse this JSON data, do
//
//     final getDownloadResultResoponse = getDownloadResultResoponseFromJson(jsonString);

import 'dart:convert';

List<GetDownloadResultResoponse> getDownloadResultResoponseFromJson(String str) => List<GetDownloadResultResoponse>.from(json.decode(str).map((x) => GetDownloadResultResoponse.fromJson(x)));

String getDownloadResultResoponseToJson(List<GetDownloadResultResoponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDownloadResultResoponse {
    String status;
    String message;
    String resultPdf;

    GetDownloadResultResoponse({
        required this.status,
        required this.message,
        required this.resultPdf,
    });

    factory GetDownloadResultResoponse.fromJson(Map<String, dynamic> json) => GetDownloadResultResoponse(
        status: json["status"],
        message: json["message"],
        resultPdf: json["result_pdf"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result_pdf": resultPdf,
    };
}
