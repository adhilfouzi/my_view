import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_model.dart';

class GameRepository {
  static final List<GameQuestion> _allQuestions = [
    // ... (Keep existing questions to minimal diff if possible, but I'll likely overwrite or just append)
    // Actually, I should just make it a growable list initialized with the consts.
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

  static bool _isLoadedMath = false;
  static bool _isLoadedScience = false;

  static Future<void> loadMathQuestions() async {
    if (_isLoadedMath) return;

    try {
      final files = {
        'assets/jsons/math/math_easy.json': AgeGroup.kids,
        'assets/jsons/math/math_medium.json': AgeGroup.teens,
        'assets/jsons/math/math_hard.json': AgeGroup.adults, // and students
      };

      for (var entry in files.entries) {
        await _loadAndParse(entry.key, entry.value, Subject.math);
      }
      _isLoadedMath = true;
    } catch (e) {
      print("Error loading math questions: $e");
    }
  }

  static Future<void> loadScienceQuestions() async {
    if (_isLoadedScience) return;

    try {
      final files = {
        'assets/jsons/science/science_kids_easy.json': AgeGroup.kids,
        'assets/jsons/science/science_teens_easy.json': AgeGroup.teens,
        'assets/jsons/science/science_students_medium.json': AgeGroup.students,
        'assets/jsons/science/science_adults_hard.json': AgeGroup.adults,
      };

      for (var entry in files.entries) {
        await _loadAndParse(entry.key, entry.value, Subject.science);
      }
      _isLoadedScience = true;
    } catch (e) {
      print("Error loading science questions: $e");
    }
  }

  static Future<void> _loadAndParse(
    String path,
    AgeGroup age,
    Subject subject,
  ) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> questions = data['questions'];

      for (var q in questions) {
        _allQuestions.add(
          GameQuestion(
            id: q['id'],
            question: q['question'],
            options: List<String>.from(q['options']),
            correctAnswer: q['answer'],
            explanation: q['explanation'],
            ageGroup: age,
            subject: subject,
            type: GameType.mcq,
            difficulty: q['difficulty'] ?? 1,
          ),
        );

        // Map hard to other groups if needed
        if (age == AgeGroup.adults && subject == Subject.math) {
          _allQuestions.add(
            GameQuestion(
              id: "${q['id']}_s",
              question: q['question'],
              options: List<String>.from(q['options']),
              correctAnswer: q['answer'],
              explanation: q['explanation'],
              ageGroup: AgeGroup.students,
              subject: Subject.math,
              type: GameType.mcq,
              difficulty: q['difficulty'] ?? 1,
            ),
          );
        }
      }
    } catch (e) {
      print("Error parsing $path: $e");
    }
  }

  static Future<List<GameQuestion>> getQuestions({
    required AgeGroup age,
    required Subject subject,
  }) async {
    if (subject == Subject.math && !_isLoadedMath) {
      await loadMathQuestions();
    }
    if (subject == Subject.science && !_isLoadedScience) {
      await loadScienceQuestions();
    }

    return _allQuestions
        .where((q) => q.ageGroup == age && q.subject == subject)
        .toList();
  }
}
