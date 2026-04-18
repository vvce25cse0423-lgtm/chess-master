// lib/models/chess_ai.dart
import 'chess_game.dart';
import 'chess_piece.dart';
import 'chess_move.dart';

class ChessAI {
  final AIDifficulty difficulty;

  ChessAI(this.difficulty);

  int get maxDepth {
    switch (difficulty) {
      case AIDifficulty.easy: return 1;
      case AIDifficulty.medium: return 3;
      case AIDifficulty.hard: return 4;
    }
  }

  // Piece-square tables for positional evaluation
  static const List<List<int>> _pawnTable = [
    [0,  0,  0,  0,  0,  0,  0,  0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5,  5, 10, 25, 25, 10,  5,  5],
    [0,  0,  0, 20, 20,  0,  0,  0],
    [5, -5,-10,  0,  0,-10, -5,  5],
    [5, 10, 10,-20,-20, 10, 10,  5],
    [0,  0,  0,  0,  0,  0,  0,  0],
  ];

  static const List<List<int>> _knightTable = [
    [-50,-40,-30,-30,-30,-30,-40,-50],
    [-40,-20,  0,  0,  0,  0,-20,-40],
    [-30,  0, 10, 15, 15, 10,  0,-30],
    [-30,  5, 15, 20, 20, 15,  5,-30],
    [-30,  0, 15, 20, 20, 15,  0,-30],
    [-30,  5, 10, 15, 15, 10,  5,-30],
    [-40,-20,  0,  5,  5,  0,-20,-40],
    [-50,-40,-30,-30,-30,-30,-40,-50],
  ];

  static const List<List<int>> _bishopTable = [
    [-20,-10,-10,-10,-10,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5, 10, 10,  5,  0,-10],
    [-10,  5,  5, 10, 10,  5,  5,-10],
    [-10,  0, 10, 10, 10, 10,  0,-10],
    [-10, 10, 10, 10, 10, 10, 10,-10],
    [-10,  5,  0,  0,  0,  0,  5,-10],
    [-20,-10,-10,-10,-10,-10,-10,-20],
  ];

  static const List<List<int>> _rookTable = [
    [0,  0,  0,  0,  0,  0,  0,  0],
    [5, 10, 10, 10, 10, 10, 10,  5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [-5,  0,  0,  0,  0,  0,  0, -5],
    [0,  0,  0,  5,  5,  0,  0,  0],
  ];

  static const List<List<int>> _queenTable = [
    [-20,-10,-10, -5, -5,-10,-10,-20],
    [-10,  0,  0,  0,  0,  0,  0,-10],
    [-10,  0,  5,  5,  5,  5,  0,-10],
    [-5,  0,  5,  5,  5,  5,  0, -5],
    [0,  0,  5,  5,  5,  5,  0, -5],
    [-10,  5,  5,  5,  5,  5,  0,-10],
    [-10,  0,  5,  0,  0,  0,  0,-10],
    [-20,-10,-10, -5, -5,-10,-10,-20],
  ];

  static const List<List<int>> _kingMiddleTable = [
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-30,-40,-40,-50,-50,-40,-40,-30],
    [-20,-30,-30,-40,-40,-30,-30,-20],
    [-10,-20,-20,-20,-20,-20,-20,-10],
    [20, 20,  0,  0,  0,  0, 20, 20],
    [20, 30, 10,  0,  0, 10, 30, 20],
  ];

  int _getPieceSquareValue(ChessPiece piece, int row, int col) {
    final r = piece.color == PieceColor.white ? row : 7 - row;
    final c = col;
    switch (piece.type) {
      case PieceType.pawn: return _pawnTable[r][c];
      case PieceType.knight: return _knightTable[r][c];
      case PieceType.bishop: return _bishopTable[r][c];
      case PieceType.rook: return _rookTable[r][c];
      case PieceType.queen: return _queenTable[r][c];
      case PieceType.king: return _kingMiddleTable[r][c];
    }
  }

  int _evaluateBoard(ChessGame game) {
    if (game.status == GameStatus.checkmate) {
      return game.currentTurn == PieceColor.black ? 100000 : -100000;
    }
    if (game.status == GameStatus.stalemate) return 0;

    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = game.board[r][c];
        if (p != null) {
          final pieceValue = p.value * 100;
          final posValue = _getPieceSquareValue(p, r, c);
          if (p.color == PieceColor.white) {
            score += pieceValue + posValue;
          } else {
            score -= pieceValue + posValue;
          }
        }
      }
    }
    return score;
  }

  List<Map<String, ChessPosition>> _getAllMoves(ChessGame game) {
    final moves = <Map<String, ChessPosition>>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = game.board[r][c];
        if (p != null && p.color == game.currentTurn) {
          final from = ChessPosition(r, c);
          for (final to in game.getLegalMoves(from)) {
            moves.add({'from': from, 'to': to});
          }
        }
      }
    }
    return moves;
  }

  int _minimax(ChessGame game, int depth, int alpha, int beta, bool maximizing) {
    if (depth == 0 || game.isGameOver) {
      return _evaluateBoard(game);
    }

    final moves = _getAllMoves(game);
    if (moves.isEmpty) return _evaluateBoard(game);

    if (maximizing) {
      int maxEval = -999999;
      for (final move in moves) {
        final newGame = game.clone();
        newGame.makeMove(move['from']!, move['to']!);
        final eval = _minimax(newGame, depth - 1, alpha, beta, false);
        maxEval = eval > maxEval ? eval : maxEval;
        alpha = eval > alpha ? eval : alpha;
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in moves) {
        final newGame = game.clone();
        newGame.makeMove(move['from']!, move['to']!);
        final eval = _minimax(newGame, depth - 1, alpha, beta, true);
        minEval = eval < minEval ? eval : minEval;
        beta = eval < beta ? eval : beta;
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  Map<String, ChessPosition>? getBestMove(ChessGame game) {
    final moves = _getAllMoves(game);
    if (moves.isEmpty) return null;

    if (difficulty == AIDifficulty.easy) {
      // Random move with slight bias toward captures
      moves.shuffle();
      final captureMoves = moves.where((m) {
        final to = m['to']!;
        return game.board[to.row][to.col] != null;
      }).toList();
      return captureMoves.isNotEmpty ? captureMoves.first : moves.first;
    }

    Map<String, ChessPosition>? bestMove;
    int bestEval = -999999;
    const alpha = -999999;
    const beta = 999999;

    for (final move in moves) {
      final newGame = game.clone();
      newGame.makeMove(move['from']!, move['to']!);
      final eval = _minimax(newGame, maxDepth - 1, alpha, beta, false);
      if (eval > bestEval) {
        bestEval = eval;
        bestMove = move;
      }
    }
    return bestMove;
  }
}
