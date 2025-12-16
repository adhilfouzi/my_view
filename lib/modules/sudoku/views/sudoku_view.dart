import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sudoku_controller.dart';
import '../../../../theme/app_theme.dart';

class SudokuView extends StatelessWidget {
  const SudokuView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SudokuController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Sudoku Master"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInformation(controller),
          const SizedBox(height: 10),
          Expanded(child: _buildBoard(controller)),
          _buildNumberPad(controller),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInformation(SudokuController controller) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mistakes: ${controller.mistakes}/3",
              style: TextStyle(
                color: controller.mistakes > 2 ? Colors.red : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Difficulty: Master",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(SudokuController controller) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(
              9,
              (row) => Expanded(
                child: Row(
                  children: List.generate(
                    9,
                    (col) => Expanded(child: _buildCell(controller, row, col)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(SudokuController controller, int row, int col) {
    return Obx(() {
      int val = controller.board[row][col];
      bool isSelected =
          controller.selectedRow.value == row &&
          controller.selectedCol.value == col;
      bool isInitial =
          controller.initialMask.isNotEmpty &&
          controller.initialMask[row][col]; // Fixed check

      // Border Logic for 3x3 blocks
      BorderSide thin = const BorderSide(color: Colors.white12, width: 0.5);
      BorderSide thick = const BorderSide(color: Colors.white54, width: 2.0);

      return GestureDetector(
        onTap: () => controller.selectCell(row, col),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : const Color(0xFF1E1E1E),
            border: Border(
              right: (col % 3 == 2 && col != 8) ? thick : thin,
              bottom: (row % 3 == 2 && row != 8) ? thick : thin,
            ),
          ),
          child: Center(
            child: val == 0
                ? const SizedBox.shrink()
                : Text(
                    val.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: isInitial ? FontWeight.bold : FontWeight.w400,
                      color: isInitial
                          ? Colors.white
                          : AppColors.secondary, // User input color
                    ),
                  ),
          ),
        ),
      );
    });
  }

  Widget _buildNumberPad(SudokuController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (index) {
              int num = index + 1;
              return _buildNumButton(controller, num);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNumButton(SudokuController controller, int num) {
    return InkWell(
      onTap: () => controller.inputNumber(num),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          "$num",
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
