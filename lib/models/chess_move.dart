// lib/models/chess_move.dart
import 'chess_piece.dart';

class ChessPosition {
  final int row;
  final int col;

  const ChessPosition(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  @override
  bool operator ==(Object other) =>
      other is ChessPosition && row == other.row && col == other.col;

  @override
  int get hashCode => row * 8 + col;

  @override
  String toString() {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }

  String toAlgebraic() => toString();
}

enum MoveType { normal, capture, castleKingside, castleQueenside, enPassant, promotion }

class ChessMove {
  final ChessPosition from;
  final ChessPosition to;
  final ChessPiece piece;
  final ChessPiece? capturedPiece;
  final MoveType type;
  final PieceType? promotionPiece;
  final bool isCheck;
  final bool isCheckmate;

  ChessMove({
    required this.from,
    required this.to,
    required this.piece,
    this.capturedPiece,
    this.type = MoveType.normal,
    this.promotionPiece,
    this.isCheck = false,
    this.isCheckmate = false,
  });

  String toAlgebraic() {
    if (type == MoveType.castleKingside) return 'O-O${isCheckmate ? '#' : isCheck ? '+' : ''}';
    if (type == MoveType.castleQueenside) return 'O-O-O${isCheckmate ? '#' : isCheck ? '+' : ''}';
    
    String notation = '';
    if (piece.type != PieceType.pawn) {
      notation += piece.type.name[0].toUpperCase();
    }
    if (capturedPiece != null || type == MoveType.enPassant) {
      if (piece.type == PieceType.pawn) notation += from.toString()[0];
      notation += 'x';
    }
    notation += to.toString();
    if (type == MoveType.promotion && promotionPiece != null) {
      notation += '=${promotionPiece!.name[0].toUpperCase()}';
    }
    if (isCheckmate) {
      notation += '#';
    } else if (isCheck) {
      notation += '+';
    }
    return notation;
  }
}
