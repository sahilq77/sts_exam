// To parse this JSON data, do
//
//     final getBannerImagesResponse = getBannerImagesResponseFromJson(jsonString);

import 'dart:convert';

List<GetBannerImagesResponse> getBannerImagesResponseFromJson(String str) =>
    List<GetBannerImagesResponse>.from(
        json.decode(str).map((x) => GetBannerImagesResponse.fromJson(x)));

String getBannerImagesResponseToJson(List<GetBannerImagesResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetBannerImagesResponse {
  String status;
  String message;
  List<BannerImages> data;
  String imageLink;

  GetBannerImagesResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.imageLink,
  });

  factory GetBannerImagesResponse.fromJson(Map<String, dynamic> json) =>
      GetBannerImagesResponse(
        status: json["status"],
        message: json["message"],
        data: List<BannerImages>.from(
            json["data"].map((x) => BannerImages.fromJson(x))),
        imageLink: json["image_link"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "image_link": imageLink,
      };
}

class BannerImages {
  String bannerName;
  String bannerImage;
  String id;

  BannerImages({
    required this.bannerName,
    required this.bannerImage,
    required this.id,
  });

  factory BannerImages.fromJson(Map<String, dynamic> json) => BannerImages(
        bannerName: json["banner_name"] ?? "",
        bannerImage: json["banner_image"] ?? "",
        id: json["id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "banner_name": bannerName,
        "banner_image": bannerImage,
        "id": id,
      };
}
