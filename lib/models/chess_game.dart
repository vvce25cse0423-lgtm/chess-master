// lib/models/chess_game.dart
import 'chess_piece.dart';
import 'chess_move.dart';

enum GameStatus { playing, check, checkmate, stalemate, draw, resigned }
enum GameMode { pvp, vsAI }
enum AIDifficulty { easy, medium, hard }

class ChessGame {
  List<List<ChessPiece?>> board;
  PieceColor currentTurn;
  GameStatus status;
  List<ChessMove> moveHistory;
  ChessPosition? enPassantTarget;
  Map<PieceColor, bool> canCastleKingside;
  Map<PieceColor, bool> canCastleQueenside;
  Map<PieceColor, List<ChessPiece>> capturedPieces;
  int halfMoveClock;
  int fullMoveNumber;

  ChessGame()
      : board = List.generate(8, (_) => List.filled(8, null)),
        currentTurn = PieceColor.white,
        status = GameStatus.playing,
        moveHistory = [],
        enPassantTarget = null,
        canCastleKingside = {PieceColor.white: true, PieceColor.black: true},
        canCastleQueenside = {PieceColor.white: true, PieceColor.black: true},
        capturedPieces = {PieceColor.white: [], PieceColor.black: []},
        halfMoveClock = 0,
        fullMoveNumber = 1 {
    _setupBoard();
  }

  ChessGame._clone(ChessGame other)
      : board = List.generate(8, (r) => List.generate(8, (c) {
          final p = other.board[r][c];
          return p != null ? ChessPiece(type: p.type, color: p.color, hasMoved: p.hasMoved) : null;
        })),
        currentTurn = other.currentTurn,
        status = other.status,
        moveHistory = List.from(other.moveHistory),
        enPassantTarget = other.enPassantTarget,
        canCastleKingside = Map.from(other.canCastleKingside),
        canCastleQueenside = Map.from(other.canCastleQueenside),
        capturedPieces = {
          PieceColor.white: List.from(other.capturedPieces[PieceColor.white]!),
          PieceColor.black: List.from(other.capturedPieces[PieceColor.black]!),
        },
        halfMoveClock = other.halfMoveClock,
        fullMoveNumber = other.fullMoveNumber;

  ChessGame clone() => ChessGame._clone(this);

  void _setupBoard() {
    // Black pieces
    final backRank = [PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen,
                      PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook];
    for (int c = 0; c < 8; c++) {
      board[0][c] = ChessPiece(type: backRank[c], color: PieceColor.black);
      board[1][c] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      board[6][c] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
      board[7][c] = ChessPiece(type: backRank[c], color: PieceColor.white);
    }
  }

  List<ChessPosition> getLegalMoves(ChessPosition pos) {
    final piece = board[pos.row][pos.col];
    if (piece == null || piece.color != currentTurn) return [];
    
    final pseudoMoves = _getPseudoLegalMoves(pos, piece);
    return pseudoMoves.where((to) {
      final testGame = clone();
      testGame._applyMoveInternal(ChessMove(from: pos, to: to, piece: piece));
      return !testGame._isInCheck(piece.color);
    }).toList();
  }

  List<ChessPosition> _getPseudoLegalMoves(ChessPosition pos, ChessPiece piece) {
    final moves = <ChessPosition>[];
    
    switch (piece.type) {
      case PieceType.pawn:
        _getPawnMoves(pos, piece, moves);
        break;
      case PieceType.rook:
        _getSlidingMoves(pos, piece, [[1,0],[-1,0],[0,1],[0,-1]], moves);
        break;
      case PieceType.bishop:
        _getSlidingMoves(pos, piece, [[1,1],[1,-1],[-1,1],[-1,-1]], moves);
        break;
      case PieceType.queen:
        _getSlidingMoves(pos, piece, [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]], moves);
        break;
      case PieceType.knight:
        for (final d in [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]]) {
          final np = ChessPosition(pos.row + d[0], pos.col + d[1]);
          if (np.isValid && board[np.row][np.col]?.color != piece.color) moves.add(np);
        }
        break;
      case PieceType.king:
        for (final d in [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]) {
          final np = ChessPosition(pos.row + d[0], pos.col + d[1]);
          if (np.isValid && board[np.row][np.col]?.color != piece.color) moves.add(np);
        }
        _getCastlingMoves(pos, piece, moves);
        break;
    }
    return moves;
  }

  void _getPawnMoves(ChessPosition pos, ChessPiece piece, List<ChessPosition> moves) {
    final dir = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // Forward
    final fwd = ChessPosition(pos.row + dir, pos.col);
    if (fwd.isValid && board[fwd.row][fwd.col] == null) {
      moves.add(fwd);
      if (pos.row == startRow) {
        final fwd2 = ChessPosition(pos.row + 2 * dir, pos.col);
        if (board[fwd2.row][fwd2.col] == null) moves.add(fwd2);
      }
    }

    // Captures
    for (final dc in [-1, 1]) {
      final cap = ChessPosition(pos.row + dir, pos.col + dc);
      if (cap.isValid) {
        final target = board[cap.row][cap.col];
        if (target != null && target.color != piece.color) moves.add(cap);
        if (cap == enPassantTarget) moves.add(cap);
      }
    }
  }

  void _getSlidingMoves(ChessPosition pos, ChessPiece piece, List<List<int>> directions, List<ChessPosition> moves) {
    for (final d in directions) {
      var cur = ChessPosition(pos.row + d[0], pos.col + d[1]);
      while (cur.isValid) {
        final target = board[cur.row][cur.col];
        if (target == null) {
          moves.add(cur);
        } else {
          if (target.color != piece.color) moves.add(cur);
          break;
        }
        cur = ChessPosition(cur.row + d[0], cur.col + d[1]);
      }
    }
  }

  void _getCastlingMoves(ChessPosition pos, ChessPiece piece, List<ChessPosition> moves) {
    if (_isInCheck(piece.color)) return;
    final row = piece.color == PieceColor.white ? 7 : 0;
    if (pos.row != row || pos.col != 4) return;

    // Kingside
    if (canCastleKingside[piece.color]! &&
        board[row][5] == null && board[row][6] == null &&
        !_isSquareAttacked(ChessPosition(row, 5), piece.color) &&
        !_isSquareAttacked(ChessPosition(row, 6), piece.color)) {
      moves.add(ChessPosition(row, 6));
    }

    // Queenside
    if (canCastleQueenside[piece.color]! &&
        board[row][3] == null && board[row][2] == null && board[row][1] == null &&
        !_isSquareAttacked(ChessPosition(row, 3), piece.color) &&
        !_isSquareAttacked(ChessPosition(row, 2), piece.color)) {
      moves.add(ChessPosition(row, 2));
    }
  }

  bool _isInCheck(PieceColor color) {
    ChessPosition? kingPos;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          kingPos = ChessPosition(r, c);
        }
      }
    }
    if (kingPos == null) return false;
    return _isSquareAttacked(kingPos, color);
  }

  bool _isSquareAttacked(ChessPosition pos, PieceColor byOpponent) {
    final opponentColor = byOpponent == PieceColor.white ? PieceColor.black : PieceColor.white;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == opponentColor) {
          final attacks = _getAttackSquares(ChessPosition(r, c), p);
          if (attacks.contains(pos)) return true;
        }
      }
    }
    return false;
  }

  List<ChessPosition> _getAttackSquares(ChessPosition pos, ChessPiece piece) {
    final squares = <ChessPosition>[];
    switch (piece.type) {
      case PieceType.pawn:
        final dir = piece.color == PieceColor.white ? -1 : 1;
        for (final dc in [-1, 1]) {
          final sq = ChessPosition(pos.row + dir, pos.col + dc);
          if (sq.isValid) squares.add(sq);
        }
        break;
      case PieceType.knight:
        for (final d in [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]]) {
          final sq = ChessPosition(pos.row + d[0], pos.col + d[1]);
          if (sq.isValid) squares.add(sq);
        }
        break;
      case PieceType.king:
        for (final d in [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]) {
          final sq = ChessPosition(pos.row + d[0], pos.col + d[1]);
          if (sq.isValid) squares.add(sq);
        }
        break;
      case PieceType.rook:
        _getSlidingAttacks(pos, [[1,0],[-1,0],[0,1],[0,-1]], squares);
        break;
      case PieceType.bishop:
        _getSlidingAttacks(pos, [[1,1],[1,-1],[-1,1],[-1,-1]], squares);
        break;
      case PieceType.queen:
        _getSlidingAttacks(pos, [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]], squares);
        break;
    }
    return squares;
  }

  void _getSlidingAttacks(ChessPosition pos, List<List<int>> directions, List<ChessPosition> squares) {
    for (final d in directions) {
      var cur = ChessPosition(pos.row + d[0], pos.col + d[1]);
      while (cur.isValid) {
        squares.add(cur);
        if (board[cur.row][cur.col] != null) break;
        cur = ChessPosition(cur.row + d[0], cur.col + d[1]);
      }
    }
  }

  bool makeMove(ChessPosition from, ChessPosition to, {PieceType? promotionPiece}) {
    final piece = board[from.row][from.col];
    if (piece == null || piece.color != currentTurn) return false;

    final legalMoves = getLegalMoves(from);
    if (!legalMoves.contains(to)) return false;

    MoveType moveType = MoveType.normal;
    ChessPiece? captured = board[to.row][to.col];

    // Detect move type
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      moveType = to.col > from.col ? MoveType.castleKingside : MoveType.castleQueenside;
    } else if (piece.type == PieceType.pawn && to == enPassantTarget) {
      moveType = MoveType.enPassant;
    } else if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      moveType = MoveType.promotion;
    } else if (captured != null) {
      moveType = MoveType.capture;
    }

    final move = ChessMove(
      from: from, to: to, piece: piece,
      capturedPiece: captured,
      type: moveType,
      promotionPiece: promotionPiece ?? (moveType == MoveType.promotion ? PieceType.queen : null),
    );

    _applyMoveInternal(move);

    // Update status
    final opponent = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    final inCheck = _isInCheck(currentTurn);
    final hasLegalMoves = _hasAnyLegalMoves(currentTurn);

    ChessMove finalMove;
    if (!hasLegalMoves) {
      status = inCheck ? GameStatus.checkmate : GameStatus.stalemate;
      finalMove = ChessMove(
        from: from, to: to, piece: piece, capturedPiece: captured,
        type: moveType, promotionPiece: move.promotionPiece,
        isCheck: inCheck, isCheckmate: inCheck,
      );
    } else if (inCheck) {
      status = GameStatus.check;
      finalMove = ChessMove(
        from: from, to: to, piece: piece, capturedPiece: captured,
        type: moveType, promotionPiece: move.promotionPiece,
        isCheck: true, isCheckmate: false,
      );
    } else {
      status = GameStatus.playing;
      finalMove = move;
    }

    moveHistory.add(finalMove);

    if (captured != null) {
      capturedPieces[opponent]!.add(captured);
    }

    return true;
  }

  void _applyMoveInternal(ChessMove move) {
    final piece = board[move.from.row][move.from.col]!;
    board[move.from.row][move.from.col] = null;

    // En passant capture
    if (move.type == MoveType.enPassant) {
      final captureRow = piece.color == PieceColor.white ? move.to.row + 1 : move.to.row - 1;
      board[captureRow][move.to.col] = null;
    }

    // Castling
    if (move.type == MoveType.castleKingside) {
      final row = piece.color == PieceColor.white ? 7 : 0;
      board[row][5] = board[row][7];
      board[row][7] = null;
      board[row][5]?.hasMoved = true;
    } else if (move.type == MoveType.castleQueenside) {
      final row = piece.color == PieceColor.white ? 7 : 0;
      board[row][3] = board[row][0];
      board[row][0] = null;
      board[row][3]?.hasMoved = true;
    }

    // Promotion
    ChessPiece movedPiece;
    if (move.type == MoveType.promotion && move.promotionPiece != null) {
      movedPiece = ChessPiece(type: move.promotionPiece!, color: piece.color, hasMoved: true);
    } else {
      movedPiece = ChessPiece(type: piece.type, color: piece.color, hasMoved: true);
    }
    board[move.to.row][move.to.col] = movedPiece;

    // Update en passant
    if (piece.type == PieceType.pawn && (move.to.row - move.from.row).abs() == 2) {
      enPassantTarget = ChessPosition(
        (move.from.row + move.to.row) ~/ 2,
        move.from.col,
      );
    } else {
      enPassantTarget = null;
    }

    // Update castling rights
    if (piece.type == PieceType.king) {
      canCastleKingside[piece.color] = false;
      canCastleQueenside[piece.color] = false;
    }
    if (piece.type == PieceType.rook) {
      final row = piece.color == PieceColor.white ? 7 : 0;
      if (move.from.row == row && move.from.col == 7) canCastleKingside[piece.color] = false;
      if (move.from.row == row && move.from.col == 0) canCastleQueenside[piece.color] = false;
    }

    currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    if (currentTurn == PieceColor.white) fullMoveNumber++;
  }

  bool _hasAnyLegalMoves(PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == color) {
          if (getLegalMoves(ChessPosition(r, c)).isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  int getMaterialScore(PieceColor color) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == color && p.type != PieceType.king) {
          score += p.value;
        }
      }
    }
    return score;
  }

  int getMaterialAdvantage(PieceColor color) {
    return getMaterialScore(color) - getMaterialScore(
      color == PieceColor.white ? PieceColor.black : PieceColor.white
    );
  }

  void resign(PieceColor color) {
    status = GameStatus.resigned;
  }

  bool get isGameOver => status == GameStatus.checkmate ||
      status == GameStatus.stalemate ||
      status == GameStatus.resigned ||
      status == GameStatus.draw;

  PieceColor? get winner {
    if (status == GameStatus.checkmate) {
      return currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }
    if (status == GameStatus.resigned) {
      return currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }
    return null;
  }
}
