enum AgeGroup {
  kids, // 6-9
  teens, // 10-13
  students, // 14-17
  adults, // 18+
}

enum Subject { math, science }

enum GameType {
  mcq,
  input,
  boolean, // True/False
}

class GameQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final AgeGroup ageGroup;
  final Subject subject;
  final GameType type;
  final int difficulty; // 1-3

  const GameQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.ageGroup,
    required this.subject,
    required this.type,
    this.difficulty = 1,
  });
}
