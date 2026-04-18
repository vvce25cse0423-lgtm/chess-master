// lib/models/chess_piece.dart
enum PieceType { king, queen, rook, bishop, knight, pawn }
enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  ChessPiece copyWith({PieceType? type, PieceColor? color, bool? hasMoved}) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  String get symbol {
    if (color == PieceColor.white) {
      switch (type) {
        case PieceType.king: return '♔';
        case PieceType.queen: return '♕';
        case PieceType.rook: return '♖';
        case PieceType.bishop: return '♗';
        case PieceType.knight: return '♘';
        case PieceType.pawn: return '♙';
      }
    } else {
      switch (type) {
        case PieceType.king: return '♚';
        case PieceType.queen: return '♛';
        case PieceType.rook: return '♜';
        case PieceType.bishop: return '♝';
        case PieceType.knight: return '♞';
        case PieceType.pawn: return '♟';
      }
    }
  }

  String get unicode {
    const map = {
      PieceColor.white: {
        PieceType.king: '♔', PieceType.queen: '♕', PieceType.rook: '♖',
        PieceType.bishop: '♗', PieceType.knight: '♘', PieceType.pawn: '♙',
      },
      PieceColor.black: {
        PieceType.king: '♚', PieceType.queen: '♛', PieceType.rook: '♜',
        PieceType.bishop: '♝', PieceType.knight: '♞', PieceType.pawn: '♟',
      },
    };
    return map[color]![type]!;
  }

  int get value {
    switch (type) {
      case PieceType.pawn: return 1;
      case PieceType.knight: return 3;
      case PieceType.bishop: return 3;
      case PieceType.rook: return 5;
      case PieceType.queen: return 9;
      case PieceType.king: return 100;
    }
  }

  @override
  String toString() => '${color.name} ${type.name}';
}
