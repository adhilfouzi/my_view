import 'package:get/get.dart';
import 'package:chess/chess.dart' as c;

class ChessController extends GetxController {
  final c.Chess chess = c.Chess();

  // Board state represented as simple list of lists or just use chess library to query
  // For UI, we need reactive state
  var fen = "".obs; // FEN string to drive UI
  var selectedSquare = (-1).obs; // Index 0-63
  var validMoves = <int>[].obs; // Indices of valid moves for selected square
  var isCheckmate = false.obs;
  var isDraw = false.obs;
  var turnColor = c.Color.WHITE.obs; // To show whose turn

  @override
  void onInit() {
    super.onInit();
    startNewGame();
  }

  void startNewGame() {
    chess.reset();
    _updateState();
  }

  void selectSquare(int index) {
    // If selecting same square, deselect
    if (selectedSquare.value == index) {
      selectedSquare.value = -1;
      validMoves.clear();
      return;
    }

    // Check if we are selecting a piece to move (must be current turn color)
    final piece = chess.get(
      c.Chess.SQUARES.keys.firstWhere((k) => c.Chess.SQUARES[k] == index),
    );

    // If we have a selected square and we tap another square, try to move
    if (selectedSquare.value != -1) {
      // Logic: if second tap is a valid move, do it.
      // If second tap is own piece, switch selection.

      bool isMove = _tryMove(selectedSquare.value, index);
      if (isMove) {
        selectedSquare.value = -1;
        validMoves.clear();
        return;
      }
    }

    // Selection Logic
    if (piece != null && piece.color == chess.turn) {
      selectedSquare.value = index;
      // Get valid moves
      // Chess library uses 'a1', 'h8' strings. Convert index to algebraic.
      String squareName = _indexToAlgebraic(index);
      final moves = chess.moves({'square': squareName, 'verbose': true});
      validMoves.value = moves
          .map((m) => _algebraicToIndex(m['to']))
          .toList()
          .cast<int>();
    } else {
      selectedSquare.value = -1;
      validMoves.clear();
    }
  }

  bool _tryMove(int fromIndex, int toIndex) {
    String from = _indexToAlgebraic(fromIndex);
    String to = _indexToAlgebraic(toIndex);

    // Check for promotion (simple auto-queen for now)
    // Actually chess library handles promotion. default is 'q'.
    // We should check if move is promotion.

    // Analyzer implies move is non-nullable bool.
    var success = chess.move({'from': from, 'to': to, 'promotion': 'q'});

    // Check if success is true (if it returns bool)
    if (success == true) {
      _updateState();
      return true;
    }
    return false;
  }

  void _updateState() {
    fen.value = chess.fen;
    turnColor.value = chess.turn;
    isCheckmate.value = chess.in_checkmate;
    isDraw.value =
        chess.in_draw || chess.in_stalemate || chess.in_threefold_repetition;

    if (isCheckmate.value) {
      Get.defaultDialog(
        title: "Checkmate!",
        middleText: "${chess.turn == c.Color.WHITE ? "Black" : "White"} Wins!",
      );
    } else if (isDraw.value) {
      Get.defaultDialog(title: "Draw", middleText: "Game Over");
    }
  }

  // Helper: 0 -> a8, 7 -> h8, 63 -> h1 (Standard Board Representation?)
  // Wait, standard UI libraries usually do Rank 8 top, Rank 1 bottom.
  // Board index 0 = a8 (top-left), 63 = h1 (bottom-right)?
  // Let's stick to standard array layout: Row 0 is Rank 8.

  String _indexToAlgebraic(int index) {
    int row = index ~/ 8;
    int col = index % 8;
    // Rank 8 is row 0 -> Rank = 8 - row
    // File a is col 0
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    return "${files[col]}${8 - row}";
  }

  int _algebraicToIndex(String alg) {
    final colChar = alg[0];
    final rowChar = alg[1];

    int col = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].indexOf(colChar);
    int row = 8 - int.parse(rowChar);
    return row * 8 + col;
  }

  // Piece Helper
  String getPieceAsset(int index) {
    // We can parse FEN or use chess.get()
    // Using chess.get() is cleaner but slower? No, it's fine.
    // Convert index to algebraic
    final piece = chess.get(_indexToAlgebraic(index));
    if (piece == null) return "";

    String color = piece.color == c.Color.WHITE ? "w" : "b";
    String type = piece.type.toLowerCase(); // p, n, b, r, q, k
    return "$color$type"; // e.g., "wp", "bk"
  }
}
