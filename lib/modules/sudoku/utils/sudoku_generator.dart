import 'dart:math';

class SudokuGenerator {
  static const int N = 9;
  static const int SRN = 3; // Square Root of N
  List<List<int>> mat = List.generate(N, (_) => List.filled(N, 0));

  void fillSolved() {
    _fillDiagonal();
    _fillRemaining(0, SRN);
  }

  void removeDigits(int k) {
    _removeKDigits(k);
  }

  void _fillDiagonal() {
    for (int i = 0; i < N; i = i + SRN) {
      _fillBox(i, i);
    }
  }

  bool _unUsedInBox(int rowStart, int colStart, int num) {
    for (int i = 0; i < SRN; i++) {
      for (int j = 0; j < SRN; j++) {
        if (mat[rowStart + i][colStart + j] == num) return false;
      }
    }
    return true;
  }

  void _fillBox(int row, int col) {
    int num;
    for (int i = 0; i < SRN; i++) {
      for (int j = 0; j < SRN; j++) {
        do {
          num = _randomGenerator(N);
        } while (!_unUsedInBox(row, col, num));
        mat[row + i][col + j] = num;
      }
    }
  }

  int _randomGenerator(int num) {
    return Random().nextInt(num) + 1;
  }

  bool _checkIfSafe(int i, int j, int num) {
    return (_unUsedInRow(i, num) &&
        _unUsedInCol(j, num) &&
        _unUsedInBox(i - i % SRN, j - j % SRN, num));
  }

  bool _unUsedInRow(int i, int num) {
    for (int j = 0; j < N; j++) {
      if (mat[i][j] == num) return false;
    }
    return true;
  }

  bool _unUsedInCol(int j, int num) {
    for (int i = 0; i < N; i++) {
      if (mat[i][j] == num) return false;
    }
    return true;
  }

  bool _fillRemaining(int i, int j) {
    if (j >= N && i < N - 1) {
      i = i + 1;
      j = 0;
    }
    if (i >= N && j >= N) return true;

    if (i < SRN) {
      if (j < SRN) j = SRN;
    } else if (i < N - SRN) {
      if (j == (i ~/ SRN) * SRN) j = j + SRN;
    } else {
      if (j == N - SRN) {
        i = i + 1;
        j = 0;
        if (i >= N) return true;
      }
    }

    for (int num = 1; num <= N; num++) {
      if (_checkIfSafe(i, j, num)) {
        mat[i][j] = num;
        if (_fillRemaining(i, j)) return true;
        mat[i][j] = 0;
      }
    }
    return false;
  }

  void _removeKDigits(int k) {
    int count = k;
    while (count != 0) {
      int cellId = _randomGenerator(N * N) - 1;

      int i = (cellId / N).floor();
      int j = cellId % N;
      if (j != 0) j = j - 1;

      if (mat[i][j] != 0) {
        count--;
        mat[i][j] = 0;
      }
    }
  }

  List<List<int>> getBoard() {
    return mat.map((e) => List<int>.from(e)).toList();
  }
}
