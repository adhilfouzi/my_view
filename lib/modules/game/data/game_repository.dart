import '../models/game_model.dart';

class GameRepository {
  static final List<GameQuestion> _allQuestions = [
    // --- KIDS (6-9) ---
    // Math
    const GameQuestion(
      id: 'k_m_1',
      question: "How many apples is 3 + 2?",
      options: ["4", "5", "6", "1"],
      correctAnswer: "5",
      explanation: "3 plus 2 equals 5.",
      ageGroup: AgeGroup.kids,
      subject: Subject.math,
      type: GameType.mcq,
      difficulty: 1,
    ),
    const GameQuestion(
      id: 'k_m_2',
      question: "Which shape has 3 sides?",
      options: ["Square", "Circle", "Triangle", "Star"],
      correctAnswer: "Triangle",
      explanation: "A triangle has three corners and three sides.",
      ageGroup: AgeGroup.kids,
      subject: Subject.math,
      type: GameType.mcq,
      difficulty: 1,
    ),
    // Science
    const GameQuestion(
      id: 'k_s_1',
      question: "What does a plant need to grow?",
      options: ["Candy", "Sunlight & Water", "Toys", "Darkness"],
      correctAnswer: "Sunlight & Water",
      explanation: "Plants need light and water to make food.",
      ageGroup: AgeGroup.kids,
      subject: Subject.science,
      type: GameType.mcq,
      difficulty: 1,
    ),

    // --- TEENS (10-13) ---
    // Math
    const GameQuestion(
      id: 't_m_1',
      question: "What is the next number: 2, 4, 8, ...?",
      options: ["10", "12", "16", "20"],
      correctAnswer: "16",
      explanation: "The pattern doubles each time (x2).",
      ageGroup: AgeGroup.teens,
      subject: Subject.math,
      type: GameType.mcq,
      difficulty: 2,
    ),
    // Science
    const GameQuestion(
      id: 't_s_1',
      question: "Which planet is known as the Red Planet?",
      options: ["Venus", "Mars", "Jupiter", "Saturn"],
      correctAnswer: "Mars",
      explanation: "Mars appears red due to iron oxide on its surface.",
      ageGroup: AgeGroup.teens,
      subject: Subject.science,
      type: GameType.mcq,
      difficulty: 1,
    ),

    // --- STUDENTS (14-17) ---
    // Math
    const GameQuestion(
      id: 's_m_1',
      question: "Solve for x: 2x + 5 = 15",
      options: ["3", "4", "5", "10"],
      correctAnswer: "5",
      explanation: "2x = 10, so x = 5.",
      ageGroup: AgeGroup.students,
      subject: Subject.math,
      type: GameType.mcq,
      difficulty: 2,
    ),
    // Science
    const GameQuestion(
      id: 's_s_1',
      question: "What is Newton's Second Law?",
      options: ["E=mc^2", "F=ma", "a^2+b^2=c^2", "PV=nRT"],
      correctAnswer: "F=ma",
      explanation: "Force equals mass times acceleration.",
      ageGroup: AgeGroup.students,
      subject: Subject.science,
      type: GameType.mcq,
      difficulty: 2,
    ),

    // --- ADULTS (18+) ---
    // Math / Logic
    const GameQuestion(
      id: 'a_m_1',
      question:
          "If an item costs \$100 and inflation is 5%, what is the cost next year?",
      options: ["\$104", "\$110", "\$105", "\$100.5"],
      correctAnswer: "\$105",
      explanation: "100 + (100 * 0.05) = 105.",
      ageGroup: AgeGroup.adults,
      subject: Subject.math,
      type: GameType.mcq,
      difficulty: 2,
    ),
    // Science / Applied
    const GameQuestion(
      id: 'a_s_1',
      question:
          "Which law explains why a spinning skater speeds up when pulling arms in?",
      options: [
        "Conservation of Energy",
        "Conservation of Angular Momentum",
        "Bernoulli's Principle",
        "Relativity",
      ],
      correctAnswer: "Conservation of Angular Momentum",
      explanation:
          "Reducing the radius comes with an increase in angular velocity to conserve momentum.",
      ageGroup: AgeGroup.adults,
      subject: Subject.science,
      type: GameType.mcq,
      difficulty: 3,
    ),
  ];

  static List<GameQuestion> getQuestions({
    required AgeGroup age,
    required Subject subject,
  }) {
    return _allQuestions
        .where((q) => q.ageGroup == age && q.subject == subject)
        .toList();
  }
}
