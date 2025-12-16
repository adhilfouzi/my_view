import 'package:get/get.dart';
import '../utils/sudoku_generator.dart';

class SudokuController extends GetxController {
  // Board State
  // 0 means empty
  var board = <List<int>>[].obs;
  var solution = <List<int>>[]
      .obs; // For checking answers (not strictly needed perfectly if we just validate rules, but good for hints)
  var initialMask =
      <List<bool>>[].obs; // True if cell was pre-filled (cannot be changed)

  // Selection
  var selectedRow = (-1).obs;
  var selectedCol = (-1).obs;

  // Game State
  var mistakes = 0.obs;
  var isGameOver = false.obs;

  // Settings
  final int difficulty; // K (missing digits)

  SudokuController({this.difficulty = 40});

  @override
  void onInit() {
    super.onInit();
    startNewGame();
  }

  void startNewGame() {
    final generator = SudokuGenerator();
    // We need a solved board first to verify validity or hints?
    // The current generator fills and removes.
    // Ideally we should keep the full solution before removing.
    // Let's modify usage:
    // Actually our generator modifies in place.
    // To get solution, we'd need to change generator to "solve" it first.
    // Allow me to cheat slightly: I will generate a board, *copy it as solution*, then remove digits.
    // Wait, the generator `fillValues` does both.
    // I should refactor generator or just run it:
    // 1. `fillDiagonal` + `fillRemaining` -> Full Board.
    // 2. Copy to `solution`.
    // 3. `removeKDigits` -> Game Board.

    // Custom logic to fix generator usage for solution tracking:
    generator.mat = List.generate(9, (_) => List.filled(9, 0));
    generator.fillSolved();

    // Save solution
    solution.value = generator.getBoard();

    // Create Puzzle
    generator.removeDigits(difficulty);
    board.value = generator.getBoard();

    // Create Mask
    initialMask.value = List.generate(
      9,
      (r) => List.generate(9, (c) => board[r][c] != 0),
    );

    mistakes.value = 0;
    isGameOver.value = false;
    selectedRow.value = -1;
    selectedCol.value = -1;
  }

  void selectCell(int row, int col) {
    selectedRow.value = row;
    selectedCol.value = col;
  }

  void inputNumber(int num) {
    if (isGameOver.value) return;
    if (selectedRow.value == -1 || selectedCol.value == -1) return;
    if (initialMask[selectedRow.value][selectedCol.value])
      return; // Cannot edit initial cells

    // Updating the observable list properly requires triggering update
    var newBoard = board.map((e) => List<int>.from(e)).toList();

    // Check correctness immediately? Or allow wrong input?
    // "Master" usually highlights errors immediately.
    if (num == solution[selectedRow.value][selectedCol.value]) {
      newBoard[selectedRow.value][selectedCol.value] = num;
      board.value = newBoard;
      _checkWin();
    } else {
      mistakes.value++;
      Get.snackbar(
        "Mistake",
        "Incorrect number!",
        duration: const Duration(seconds: 1),
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.error,
      );
      if (mistakes.value >= 3) {
        isGameOver.value = true;
        Get.defaultDialog(
          title: "Game Over",
          middleText: "Too many mistakes!",
          textConfirm: "Retry",
          onConfirm: () {
            Get.back();
            startNewGame();
          },
        );
      }
    }
  }

  void _checkWin() {
    bool won = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == 0) {
          won = false;
          break;
        }
      }
    }
    if (won) {
      Get.defaultDialog(
        title: "You Won!",
        middleText: "Great job master.",
        textConfirm: "New Game",
        onConfirm: () {
          Get.back();
          startNewGame();
        },
      );
    }
  }
}

// Extension to access private methods of generator if needed, 
// OR I will simply copy the generator class content to a better structure in next step if this fails access.
// Actually Dart privacy is library level. `SudokuGenerator` is in another file. 
// I need to update `SudokuGenerator` to expose the steps if I want to use it like this.
// Alternative: Modify `SudokuGenerator` in file to have `generateSolved()` and `removeDigits()`.
