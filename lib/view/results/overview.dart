import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_colors.dart';
import '../../controller/result_list/result_list_controller.dart';
import '../../controller/result_list/result_overview_contoller.dart';
import '../../model/result_list/get_result_overview_response.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final controller = Get.put(ResultOverviewContoller());
  String? _groupValue1;
  String? _groupValue2;

  @override
  void initState() {
    super.initState();
    controller.fetchOverview(context: context);
  }

  @override
  void dispose() {
    controller.testID = "";
    controller.overviewList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Appbar,
      appBar: AppBar(
        backgroundColor: AppColors.Appbar,
        elevation: 0,
        title: const Text(
          "Overview",
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(height: 1.0, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () => controller.refreshOverview(context: context),
          child: Obx(
            () =>
                controller.isLoading.value
                    ? CustomShimmerov()
                    : ListView.builder(
                      itemCount: controller.overviewList.length,
                      itemBuilder: (context, int index) {
                        var ov = controller.overviewList[index];
                        return _buildQuestionCard(
                          questionNumber: ov.questionNumber,
                          question: ov.question,
                          options: ov.options.toList(),
                          selectedAnswer: ov.selectedAnswer,
                          correctAnswer: ov.correctAnswer,
                          isCorrect: ov.isCorrect,
                        );
                      },
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String questionNumber,
    required QuestionQuestion question,
    required List<Option> options,
    required String selectedAnswer,
    required bool isCorrect,
    required String correctAnswer,
  }) {
    print("ans ${controller.imageLink + correctAnswer}");
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${questionNumber}. ${question.text} ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            // Text(
            //   '${questionNumber}. ${question.image} ',
            //   style: const TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w600,
            //     color: AppColors.textColor,
            //   ),
            // ),
            const SizedBox(height: 4),
            Column(
              children: [
                SizedBox(
                  child:
                      question.image.isNotEmpty &&
                              question.image.contains(
                                RegExp(
                                  r'\.(jpeg|jpg|png)$',
                                  caseSensitive: false,
                                ),
                              )
                          ? SizedBox(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: "${question.image}",
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error, size: 50),
                                ),
                              ),
                            ),
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
            // Text(
            //   "$questionNumber. $question",
            //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            // ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(options.length, (index) {
                bool isSelected =
                    (index + 1).toString() == selectedAnswer.trim();
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? (isCorrect
                                ? Color(0xFF3A954E).withOpacity(0.2)
                                : const Color(0xFFDC2626).withOpacity(0.2))
                            : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          isSelected
                              ? (isCorrect
                                  ? const Color(0xFF3A954E)
                                  : Color(0xFFDC2626))
                              : const Color(0xFFBCBCBC),
                      width: 1,
                    ),
                  ),
                  child:
                      options[index].image.contains(
                            RegExp(r'\.(jpeg|jpg|png)$', caseSensitive: false),
                          )
                          ? Row(
                            children: [
                              Text(
                                '${index + 1}.',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: "${options[index].image}",
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(Icons.error, size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${index + 1}. ${options[index].text}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isSelected
                                                ? (isCorrect
                                                    ? Colors.green
                                                    : Colors.red)
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  isCorrect ? Icons.check : Icons.close,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                            ],
                          ),
                );
              }),
            ),
            if (!isCorrect) ...[
              // const SizedBox(height: 10),
              Divider(color: Colors.grey, thickness: 0.5),
              Text(
                "Correct Answer: ",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText,
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF3A954E).withOpacity(0.2),

                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(width: 1, color: const Color(0xFF3A954E)),
                ),

                child:
                    options[int.parse(correctAnswer.trim()) - 1].image.contains(
                          RegExp(r'\.(jpeg|jpg|png)$', caseSensitive: false),
                        )
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$correctAnswer. ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              options[int.parse(
                                                        correctAnswer.trim(),
                                                      ) -
                                                      1]
                                                  .image,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  const Icon(
                                                    Icons.error,
                                                    size: 50,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Text(
                                  //   "$correctAnswer. ${options[int.parse(correctAnswer.trim()) - 1].text}",
                                  //   style: TextStyle(
                                  //     fontSize: 15,
                                  //     fontWeight: FontWeight.w500,
                                  //     color: Colors.green,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                            Icon(Icons.check, color: Colors.green),
                          ],
                        )
                        : Text(
                          "$correctAnswer. ${options[int.parse(correctAnswer.trim()) - 1].text}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
              ),
              // Text(
              //   "Correct Answer: $correctAnswer. ${options[int.parse(correctAnswer.trim()) - 1].text}",
              //   style: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w600,
              //     color: Color(0xFF3A954E),
              //   ),
              // ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomShimmerov extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder:
          (context, index) => Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(
                        4,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
