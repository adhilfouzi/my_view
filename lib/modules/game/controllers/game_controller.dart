import 'package:get/get.dart';
import '../models/game_model.dart';
import '../data/game_repository.dart';

class GameController extends GetxController {
  final AgeGroup currentAgeGroup;
  final Subject currentSubject;

  // State
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxList<GameQuestion> questions = <GameQuestion>[].obs;
  final RxBool isAnswered = false.obs;
  final RxString selectedOption = ''.obs;
  final RxBool isCorrect = false.obs;

  GameController({
    this.currentAgeGroup = AgeGroup.teens,
    this.currentSubject = Subject.math,
  });

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
  }

  void loadQuestions() {
    questions.value = GameRepository.getQuestions(
      age: currentAgeGroup,
      subject: currentSubject,
    );
    questions.shuffle();
  }

  void submitAnswer(String answer) {
    if (isAnswered.value) return;

    isAnswered.value = true;
    selectedOption.value = answer;

    final correct = questions[currentQuestionIndex.value].correctAnswer;
    if (answer == correct) {
      isCorrect.value = true;
      score.value++;
    } else {
      isCorrect.value = false;
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      isAnswered.value = false;
      selectedOption.value = '';
      isCorrect.value = false;
    } else {
      // Game Over Logic
      Get.defaultDialog(
        title: "Game Over",
        middleText: "Score: ${score.value} / ${questions.length}",
        textConfirm: "Play Again",
        textCancel: "Back",
        onConfirm: () {
          Get.back(); // close dialog
          currentQuestionIndex.value = 0;
          score.value = 0;
          isAnswered.value = false;
          selectedOption.value = '';
          loadQuestions();
        },
        onCancel: () {
          Get.back(); // Close dialog logic is automatic usually, but let's ensure navigation or reset
        },
      );
    }
  }
}
