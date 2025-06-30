class ExamInstruction {
    int id;
    String image;
    String examName;
    int duration;
    int totalQuestions;
    List<String> instructions;

    ExamInstruction({
        required this.id,
        required this.image,
        required this.examName,
        required this.duration,
        required this.totalQuestions,
        required this.instructions,
    });

}
