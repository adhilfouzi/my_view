import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chess/chess.dart' as c;
import '../controllers/chess_controller.dart';
import '../../../../theme/app_theme.dart';

class ChessView extends StatelessWidget {
  const ChessView({super.key});

  @override
  Widget build(BuildContext context) {
    // Unique tag in case of multiple instances
    final controller = Get.put(ChessController());

    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        title: const Text("Chess Pro"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.startNewGame();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPlayerBadge(
                    "Black",
                    controller.turnColor.value == c.Color.BLACK,
                  ),
                  Text(
                    controller.isCheckmate.value
                        ? "CHECKMATE"
                        : controller.isDraw.value
                        ? "DRAW"
                        : (controller.chess.in_check ? "CHECK!" : "VS"),
                    style: TextStyle(
                      color: controller.chess.in_check
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  _buildPlayerBadge(
                    "White",
                    controller.turnColor.value == c.Color.WHITE,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildBoard(controller),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text("Tap to move", style: TextStyle(color: Colors.white24)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlayerBadge(String name, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: active ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Text(
        name,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBoard(ChessController controller) {
    return Obx(() {
      // Trigger rebuild when FEN changes
      // ignore: unused_local_variable
      final fen = controller.fen.value;

      return Column(
        children: List.generate(
          8,
          (row) => Expanded(
            child: Row(
              children: List.generate(
                8,
                (col) => Expanded(child: _buildSquare(controller, row, col)),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSquare(ChessController controller, int row, int col) {
    final int index = row * 8 + col;
    final bool isDark = (row + col) % 2 != 0;

    // Colors
    final Color colorLight = const Color(0xFFEEEED2);
    final Color colorDark = const Color(0xFF769656);
    final Color colorHighlight = Colors.yellow.withValues(alpha: 0.5);
    final Color colorMove = Colors.blue.withValues(alpha: 0.5);

    return Obx(() {
      bool isSelected = controller.selectedSquare.value == index;
      bool isValidMove = controller.validMoves.contains(index);

      return GestureDetector(
        onTap: () => controller.selectSquare(index),
        child: Container(
          color: isSelected
              ? colorHighlight
              : (isValidMove ? colorMove : (isDark ? colorDark : colorLight)),
          child: Stack(
            children: [
              // Position Label (optional, for "Pro" feel)
              if (col == 0)
                Positioned(
                  top: 2,
                  left: 2,
                  child: Text(
                    "${8 - row}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? colorLight : colorDark,
                    ),
                  ),
                ),
              if (row == 7)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Text(
                    ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'][col],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? colorLight : colorDark,
                    ),
                  ),
                ),

              // Piece
              Center(child: _buildPiece(controller.getPieceAsset(index))),

              // Move Marker
              if (isValidMove)
                Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPiece(String code) {
    if (code.isEmpty) return const SizedBox.shrink();

    // Using Unicode Characters for minimal dependency (Pro feel comes from font/layout)
    // White Pieces
    // "wp": "♙", "wr": "♖", "wn": "♘", "wb": "♗", "wq": "♕", "wk": "♔"
    // Black Pieces
    // "bp": "♟", "br": "♜", "bn": "♞", "bb": "♝", "bq": "♛", "bk": "♚"

    // Actually, simple unicode might look small or inconsistent across fonts.
    // Using simple mapping to Text.

    String symbol = "";
    switch (code) {
      case "wp":
        symbol = "♙";
        break;
      case "wr":
        symbol = "♖";
        break;
      case "wn":
        symbol = "♘";
        break;
      case "wb":
        symbol = "♗";
        break;
      case "wq":
        symbol = "♕";
        break;
      case "wk":
        symbol = "♔";
        break;
      case "bp":
        symbol = "♟";
        break;
      case "br":
        symbol = "♜";
        break;
      case "bn":
        symbol = "♞";
        break;
      case "bb":
        symbol = "♝";
        break;
      case "bq":
        symbol = "♛";
        break;
      case "bk":
        symbol = "♚";
        break;
    }

    return Text(
      symbol,
      style: TextStyle(
        fontSize: 32,
        color: code.startsWith("w") ? Colors.white : Colors.black,
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
