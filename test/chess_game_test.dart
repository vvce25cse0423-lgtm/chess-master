import 'package:flutter_test/flutter_test.dart';
import 'package:chess_master/models/chess_game.dart';
import 'package:chess_master/models/chess_piece.dart';
import 'package:chess_master/models/chess_move.dart';

void main() {
  group('Chess Game Logic', () {
    late ChessGame game;

    setUp(() {
      game = ChessGame();
    });

    test('Board initializes with correct pieces', () {
      expect(game.board[0][4]?.type, PieceType.king);
      expect(game.board[0][4]?.color, PieceColor.black);
      expect(game.board[7][4]?.type, PieceType.king);
      expect(game.board[7][4]?.color, PieceColor.white);
      expect(game.board[1][0]?.type, PieceType.pawn);
      expect(game.board[6][0]?.type, PieceType.pawn);
    });

    test('White moves first', () {
      expect(game.currentTurn, PieceColor.white);
    });

    test('Pawn can move forward', () {
      final moves = game.getLegalMoves(ChessPosition(6, 4));
      expect(moves, containsAll([ChessPosition(5, 4), ChessPosition(4, 4)]));
    });

    test('Pawn cannot move backward', () {
      final moves = game.getLegalMoves(ChessPosition(6, 4));
      expect(moves, isNot(contains(ChessPosition(7, 4))));
    });

    test('Making a valid move changes current turn', () {
      game.makeMove(ChessPosition(6, 4), ChessPosition(4, 4));
      expect(game.currentTurn, PieceColor.black);
    });

    test('Knight moves in L-shape', () {
      final moves = game.getLegalMoves(ChessPosition(7, 1));
      expect(moves, containsAll([ChessPosition(5, 0), ChessPosition(5, 2)]));
    });

    test('Game status starts as playing', () {
      expect(game.status, GameStatus.playing);
    });

    test('Move history records moves', () {
      game.makeMove(ChessPosition(6, 4), ChessPosition(4, 4));
      expect(game.moveHistory.length, 1);
    });

    test('Captured pieces tracked', () {
      // Scholar\'s mate setup
      game.makeMove(ChessPosition(6, 4), ChessPosition(4, 4)); // e4
      game.makeMove(ChessPosition(1, 4), ChessPosition(3, 4)); // e5
      expect(game.capturedPieces[PieceColor.white]!.length, 0);
      expect(game.capturedPieces[PieceColor.black]!.length, 0);
    });
  });
}
