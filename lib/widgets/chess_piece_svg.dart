// lib/widgets/chess_piece_svg.dart
import 'package:flutter/material.dart';
import '../models/chess_piece.dart';

class ChessPieceSvg extends StatelessWidget {
  final ChessPiece piece;
  final double size;
  final bool isSelected;

  const ChessPieceSvg({
    super.key,
    required this.piece,
    required this.size,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _PiecePainter(piece),
        ),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final ChessPiece piece;
  _PiecePainter(this.piece);

  bool get isWhite => piece.color == PieceColor.white;

  // Colors matching the image style
  static const Color _whiteBody   = Color(0xFFF5F5F0);
  static const Color _whiteStroke = Color(0xFF2C2C2C);
  static const Color _blackBody   = Color(0xFF2C2C2C);
  static const Color _blackStroke = Color(0xFF111111);
  static const Color _whiteInner  = Color(0xFFE8E8E0);
  static const Color _blackInner  = Color(0xFF444444);
  static const Color _whiteShadow = Color(0xFFCCCCBB);
  static const Color _blackShadow = Color(0xFF1A1A1A);

  Paint get bodyPaint => Paint()
    ..color = isWhite ? _whiteBody : _blackBody
    ..style = PaintingStyle.fill;

  Paint get strokePaint => Paint()
    ..color = isWhite ? _whiteStroke : _blackStroke
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get innerPaint => Paint()
    ..color = isWhite ? _whiteInner : _blackInner
    ..style = PaintingStyle.fill;

  Paint get shadowPaint => Paint()
    ..color = isWhite ? _whiteShadow : _blackShadow
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = size.width / 45.0;
    canvas.scale(scale, scale);

    switch (piece.type) {
      case PieceType.pawn:   _drawPawn(canvas);   break;
      case PieceType.rook:   _drawRook(canvas);   break;
      case PieceType.knight: _drawKnight(canvas); break;
      case PieceType.bishop: _drawBishop(canvas); break;
      case PieceType.queen:  _drawQueen(canvas);  break;
      case PieceType.king:   _drawKing(canvas);   break;
    }

    canvas.restore();
  }

  void _drawPawn(Canvas canvas) {
    // Base
    _drawBase(canvas, 8, 39, 29, 39, 31, 42, 6, 42);
    // Stem
    final stem = Path()
      ..moveTo(17, 38) ..lineTo(15, 30) ..lineTo(14, 26) ..lineTo(31, 26) ..lineTo(30, 30) ..lineTo(28, 38) ..close();
    canvas.drawPath(stem, bodyPaint);
    canvas.drawPath(stem, strokePaint);
    // Head circle
    canvas.drawCircle(const Offset(22.5, 19), 8, bodyPaint);
    canvas.drawCircle(const Offset(22.5, 19), 8, strokePaint);
    canvas.drawCircle(const Offset(22.5, 19), 5, innerPaint);
    // Base fill
    final base = Path()
      ..moveTo(8, 39) ..lineTo(37, 39) ..lineTo(31, 42) ..lineTo(14, 42) ..close();
    canvas.drawPath(base, bodyPaint);
    canvas.drawPath(base, strokePaint);
  }

  void _drawRook(Canvas canvas) {
    // Base
    _drawBase(canvas, 7, 39, 38, 39, 35, 42, 10, 42);
    // Body
    final body = Path()
      ..moveTo(9, 39) ..lineTo(9, 26) ..lineTo(36, 26) ..lineTo(36, 39) ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, strokePaint);
    // Battlements
    for (final x in [9.0, 19.0, 27.0]) {
      final battlement = Path()
        ..moveTo(x, 26) ..lineTo(x, 18) ..lineTo(x + 7, 18) ..lineTo(x + 7, 26) ..close();
      canvas.drawPath(battlement, bodyPaint);
      canvas.drawPath(battlement, strokePaint);
    }
    // Inner line
    canvas.drawLine(const Offset(12, 30), const Offset(33, 30), strokePaint);
    // Base shadow
    final base = Path()
      ..moveTo(7, 39) ..lineTo(38, 39) ..lineTo(35, 42) ..lineTo(10, 42) ..close();
    canvas.drawPath(base, shadowPaint);
    canvas.drawPath(base, strokePaint);
  }

  void _drawKnight(Canvas canvas) {
    // Base
    _drawBase(canvas, 7, 39, 38, 39, 35, 42, 10, 42);
    // Body - horse head shape
    final body = Path()
      ..moveTo(22, 39)
      ..lineTo(10, 39)
      ..lineTo(10, 32)
      ..lineTo(14, 27)
      ..lineTo(14, 20)
      ..lineTo(18, 14)
      ..cubicTo(20, 10, 28, 9, 30, 13)
      ..cubicTo(33, 17, 31, 22, 28, 25)
      ..lineTo(35, 25)
      ..lineTo(35, 30)
      ..lineTo(30, 35)
      ..lineTo(30, 39)
      ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, strokePaint);
    // Eye
    final eyeColor = isWhite ? _blackBody : _whiteBody;
    canvas.drawCircle(const Offset(25, 16), 2, Paint()..color = eyeColor);
    // Nostril
    canvas.drawCircle(const Offset(20, 22), 1.5, Paint()..color = eyeColor..style = PaintingStyle.fill);
    // Mane detail
    final mane = Paint()
      ..color = isWhite ? const Color(0xFFDDDDD0) : const Color(0xFF383838)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      const Rect.fromLTWH(14, 12, 12, 14),
      0.5, 1.5, false, mane,
    );
    // Base
    final base = Path()
      ..moveTo(7, 39) ..lineTo(38, 39) ..lineTo(35, 42) ..lineTo(10, 42) ..close();
    canvas.drawPath(base, shadowPaint);
    canvas.drawPath(base, strokePaint);
  }

  void _drawBishop(Canvas canvas) {
    // Base
    _drawBase(canvas, 8, 39, 37, 39, 34, 42, 11, 42);
    // Body stem
    final stem = Path()
      ..moveTo(15, 39) ..lineTo(13, 30) ..lineTo(14, 20) ..lineTo(31, 20) ..lineTo(32, 30) ..lineTo(30, 39) ..close();
    canvas.drawPath(stem, bodyPaint);
    canvas.drawPath(stem, strokePaint);
    // Head circle
    canvas.drawCircle(const Offset(22.5, 16), 7, bodyPaint);
    canvas.drawCircle(const Offset(22.5, 16), 7, strokePaint);
    canvas.drawCircle(const Offset(22.5, 16), 4, innerPaint);
    // Cross on top
    final crossPaint = Paint()
      ..color = isWhite ? _whiteStroke : _whiteBody
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(22.5, 6), const Offset(22.5, 13), crossPaint);
    canvas.drawLine(const Offset(19, 9), const Offset(26, 9), crossPaint);
    // Diagonal band
    canvas.drawLine(const Offset(14, 28), const Offset(31, 28), strokePaint..strokeWidth = 1);
    // Base fill
    final base = Path()
      ..moveTo(8, 39) ..lineTo(37, 39) ..lineTo(34, 42) ..lineTo(11, 42) ..close();
    canvas.drawPath(base, bodyPaint);
    canvas.drawPath(base, strokePaint);
  }

  void _drawQueen(Canvas canvas) {
    // Base
    _drawBase(canvas, 6, 39, 39, 39, 36, 42, 9, 42);
    // Body
    final body = Path()
      ..moveTo(13, 39) ..lineTo(10, 26) ..lineTo(16, 22) ..lineTo(22.5, 28)
      ..lineTo(29, 22) ..lineTo(35, 26) ..lineTo(32, 39) ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, strokePaint);
    // Crown points (5 balls)
    for (final pos in [
      const Offset(10, 21), const Offset(16, 17), const Offset(22.5, 15),
      const Offset(29, 17), const Offset(35, 21),
    ]) {
      canvas.drawCircle(pos, 3.5, bodyPaint);
      canvas.drawCircle(pos, 3.5, strokePaint);
      canvas.drawCircle(pos, 1.5, innerPaint);
    }
    // Collar line
    canvas.drawLine(const Offset(13, 34), const Offset(32, 34),
        strokePaint..strokeWidth = 1.2);
    // Cross decoration
    canvas.drawLine(const Offset(22.5, 10), const Offset(22.5, 16),
        strokePaint..strokeWidth = 1.5);
    // Base
    final base = Path()
      ..moveTo(6, 39) ..lineTo(39, 39) ..lineTo(36, 42) ..lineTo(9, 42) ..close();
    canvas.drawPath(base, bodyPaint);
    canvas.drawPath(base, strokePaint);
  }

  void _drawKing(Canvas canvas) {
    // Base
    _drawBase(canvas, 6, 39, 39, 39, 36, 42, 9, 42);
    // Body
    final body = Path()
      ..moveTo(13, 39) ..lineTo(11, 26) ..lineTo(16, 22) ..lineTo(29, 22)
      ..lineTo(34, 26) ..lineTo(32, 39) ..close();
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, strokePaint);
    // Crown with battlements
    final crown = Path()
      ..moveTo(11, 26) ..lineTo(11, 18) ..lineTo(16, 18) ..lineTo(16, 22)
      ..lineTo(20, 22) ..lineTo(20, 16) ..lineTo(25, 16) ..lineTo(25, 22)
      ..lineTo(29, 22) ..lineTo(29, 18) ..lineTo(34, 18) ..lineTo(34, 26) ..close();
    canvas.drawPath(crown, bodyPaint);
    canvas.drawPath(crown, strokePaint);
    // Cross on top
    final crossFill = Paint()
      ..color = isWhite ? _whiteStroke : const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(22.5, 7), const Offset(22.5, 15), crossFill);
    canvas.drawLine(const Offset(19, 10), const Offset(26, 10), crossFill);
    // Inner crown detail
    canvas.drawLine(const Offset(14, 30), const Offset(31, 30),
        strokePaint..strokeWidth = 1);
    // Base
    final base = Path()
      ..moveTo(6, 39) ..lineTo(39, 39) ..lineTo(36, 42) ..lineTo(9, 42) ..close();
    canvas.drawPath(base, bodyPaint);
    canvas.drawPath(base, strokePaint);
  }

  void _drawBase(Canvas canvas, double x1, double y1, double x2, double y2,
      double x3, double y4, double x4, double y5) {
    final shadow = Path()
      ..moveTo(x1, y1) ..lineTo(x2, y2) ..lineTo(x3, y4) ..lineTo(x4, y5) ..close();
    canvas.drawPath(shadow, shadowPaint);
    canvas.drawPath(shadow, strokePaint);
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.piece.type != piece.type || old.piece.color != piece.color;
}
