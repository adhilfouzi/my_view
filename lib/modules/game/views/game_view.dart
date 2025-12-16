import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/game_model.dart';
import '../../../../theme/app_theme.dart';

class GameView extends StatelessWidget {
  final AgeGroup ageGroup;
  final Subject subject;

  const GameView({super.key, required this.ageGroup, required this.subject});

  @override
  Widget build(BuildContext context) {
    // Unique ID for controller to allow multiple instances (e.g. diff subjects)
    final controller = Get.put(
      GameController(currentAgeGroup: ageGroup, currentSubject: subject),
      tag: "${ageGroup.name}_${subject.name}",
    );

    return Scaffold(
      backgroundColor: _getBackgroundColor(ageGroup),
      appBar: AppBar(
        title: Text(
          "${subject.name.capitalizeFirst} (${ageGroup.name.capitalizeFirst})",
          style: TextStyle(color: _getTextColor(ageGroup)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _getTextColor(ageGroup)),
      ),
      body: Obx(() {
        if (controller.questions.isEmpty) {
          return const Center(child: Text("No questions loaded."));
        }

        final question =
            controller.questions[controller.currentQuestionIndex.value];

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value:
                    (controller.currentQuestionIndex.value + 1) /
                    controller.questions.length,
                color: _getAccentColor(ageGroup),
                backgroundColor: Colors.grey.withOpacity(0.2),
              ),
              const SizedBox(height: 20),

              // Score
              Text(
                "Score: ${controller.score}",
                style: TextStyle(
                  color: _getTextColor(ageGroup),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Question
              Text(
                question.question,
                style: TextStyle(
                  fontSize: _getFontSize(ageGroup),
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(ageGroup),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Options
              ...question.options.map((option) {
                return _buildOptionButton(controller, option, ageGroup);
              }),

              const SizedBox(height: 20),

              // Feedback / Next
              if (controller.isAnswered.value)
                Column(
                  children: [
                    Text(
                      controller.isCorrect.value
                          ? "Correct!"
                          : "Wrong! ${question.explanation}",
                      style: TextStyle(
                        color: controller.isCorrect.value
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getAccentColor(ageGroup),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      onPressed: controller.nextQuestion,
                      child: const Text("Next"),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOptionButton(
    GameController controller,
    String text,
    AgeGroup age,
  ) {
    return Obx(() {
      final isSelected = controller.selectedOption.value == text;
      final isAnswered = controller.isAnswered.value;

      Color btnColor = _getSurfaceColor(age);
      if (isAnswered) {
        if (isSelected) {
          btnColor = controller.isCorrect.value
              ? Colors.greenAccent
              : Colors.redAccent;
        } else if (text ==
            controller
                .questions[controller.currentQuestionIndex.value]
                .correctAnswer) {
          btnColor = Colors.green.withOpacity(0.8);
        }
      } else if (isSelected) {
        btnColor = _getAccentColor(age);
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: isAnswered ? null : () => controller.submitAnswer(text),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(age == AgeGroup.kids ? 24 : 16),
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: age == AgeGroup.kids ? Colors.black87 : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    });
  }

  // --- AGE BASED STYLING HELPERS ---

  Color _getBackgroundColor(AgeGroup age) {
    switch (age) {
      case AgeGroup.kids:
        return const Color(0xFFFFF9C4); // Light Yellow
      case AgeGroup.teens:
        return const Color(0xFFE0F2F1); // Teal Light
      case AgeGroup.students:
        return const Color(0xFF1A1A2E); // Dark Navy
      case AgeGroup.adults:
        return const Color(0xFFEEEEEE); // Minimal Grey
    }
  }

  Color _getSurfaceColor(AgeGroup age) {
    switch (age) {
      case AgeGroup.kids:
        return Colors.white;
      case AgeGroup.teens:
        return Colors.white;
      case AgeGroup.students:
        return const Color(0xFF16213E);
      case AgeGroup.adults:
        return Colors.white;
    }
  }

  Color _getTextColor(AgeGroup age) {
    switch (age) {
      case AgeGroup.kids:
      case AgeGroup.teens:
      case AgeGroup.adults:
        return Colors.black87;
      case AgeGroup.students:
        return Colors.white;
    }
  }

  Color _getAccentColor(AgeGroup age) {
    switch (age) {
      case AgeGroup.kids:
        return Colors.orangeAccent;
      case AgeGroup.teens:
        return Colors.tealAccent;
      case AgeGroup.students:
        return AppColors.primary;
      case AgeGroup.adults:
        return Colors.black87;
    }
  }

  double _getFontSize(AgeGroup age) {
    switch (age) {
      case AgeGroup.kids:
        return 28;
      case AgeGroup.teens:
        return 24;
      default:
        return 20;
    }
  }
}
