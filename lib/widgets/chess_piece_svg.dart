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
      scale: isSelected ? 1.13 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
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

  // White piece colors
  static const Color wFill    = Color(0xFFFAF8EF);
  static const Color wMid     = Color(0xFFECE9DA);
  static const Color wDark    = Color(0xFFCCC9A8);
  static const Color wOutline = Color(0xFF1A1A1A);

  // Black piece colors
  static const Color bFill    = Color(0xFF3D3D3D);
  static const Color bMid     = Color(0xFF2A2A2A);
  static const Color bDark    = Color(0xFF181818);
  static const Color bOutline = Color(0xFF000000);
  static const Color bSheen   = Color(0xFF555555);

  Color get fill    => isWhite ? wFill    : bFill;
  Color get mid     => isWhite ? wMid     : bMid;
  Color get dark    => isWhite ? wDark    : bDark;
  Color get outline => isWhite ? wOutline : bOutline;
  Color get sheen   => isWhite ? wMid     : bSheen;

  Paint fillP(Color c) => Paint()..color = c..style = PaintingStyle.fill;

  Paint strokeP({double w = 1.4, Color? color}) => Paint()
    ..color = color ?? outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Uniform 45x45 coordinate space
    final s = size.width / 45.0;
    canvas.scale(s, s);
    _drawDropShadow(canvas);
    switch (piece.type) {
      case PieceType.pawn:   _pawn(canvas);   break;
      case PieceType.rook:   _rook(canvas);   break;
      case PieceType.knight: _knight(canvas); break;
      case PieceType.bishop: _bishop(canvas); break;
      case PieceType.queen:  _queen(canvas);  break;
      case PieceType.king:   _king(canvas);   break;
    }
    canvas.restore();
  }

  void _drawDropShadow(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawOval(
      const Rect.fromLTWH(6, 41, 33, 5),
      shadowPaint,
    );
  }

  // ── Shared base platform ──────────────────────────────────────────────────
  void _base(Canvas canvas, {double w = 14.0}) {
    final cx = 22.5;
    final left  = cx - w;
    final right = cx + w;
    // Shadow layer
    final shadowPath = Path()
      ..moveTo(left - 1, 40.5)
      ..lineTo(right + 1, 40.5)
      ..arcToPoint(Offset(right - 1, 43.5), radius: const Radius.circular(3))
      ..lineTo(left + 1, 43.5)
      ..arcToPoint(Offset(left - 1, 40.5), radius: const Radius.circular(3))
      ..close();
    canvas.drawPath(shadowPath, fillP(dark));

    // Main base
    final basePath = Path()
      ..moveTo(left, 38.5)
      ..lineTo(right, 38.5)
      ..arcToPoint(Offset(right + 1, 41.5), radius: const Radius.circular(2.5))
      ..lineTo(left - 1, 41.5)
      ..arcToPoint(Offset(left, 38.5), radius: const Radius.circular(2.5))
      ..close();
    canvas.drawPath(basePath, fillP(fill));
    canvas.drawPath(basePath, strokeP());

    // Sheen line on base
    canvas.drawLine(
      Offset(left + 2, 39.8),
      Offset(right - 2, 39.8),
      strokeP(w: 0.8, color: sheen),
    );
  }

  // ── PAWN ─────────────────────────────────────────────────────────────────
  void _pawn(Canvas canvas) {
    _base(canvas, w: 11.0);

    // Neck / stem with gradient feel
    final neck = Path()
      ..moveTo(19.5, 38.5)
      ..lineTo(18.5, 32.0)
      ..quadraticBezierTo(18.0, 29.5, 19.5, 28.0)
      ..lineTo(25.5, 28.0)
      ..quadraticBezierTo(27.0, 29.5, 26.5, 32.0)
      ..lineTo(25.5, 38.5)
      ..close();
    canvas.drawPath(neck, fillP(mid));
    canvas.drawPath(neck, fillP(fill));
    canvas.drawPath(neck, strokeP());

    // Collar ring
    final collar = Path()
      ..moveTo(18.0, 30.5)
      ..lineTo(27.0, 30.5)
      ..lineTo(27.5, 32.5)
      ..lineTo(17.5, 32.5)
      ..close();
    canvas.drawPath(collar, fillP(dark));
    canvas.drawPath(collar, strokeP(w: 0.8));

    // Head — large smooth circle
    final headRect = const Rect.fromLTWH(14.5, 12.5, 16.0, 16.0);
    // Outer glow / border fill
    canvas.drawOval(headRect.inflate(0.8), fillP(dark));
    // Main head
    canvas.drawOval(headRect, fillP(fill));
    // Sheen highlight
    canvas.drawArc(
      headRect.deflate(2),
      -2.4, 1.2, false,
      Paint()
        ..color = isWhite ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(headRect, strokeP(w: 1.4));
  }

  // ── ROOK ─────────────────────────────────────────────────────────────────
  void _rook(Canvas canvas) {
    _base(canvas, w: 13.0);

    // Body
    final body = Path()
      ..moveTo(11.0, 38.5)
      ..lineTo(11.0, 24.0)
      ..lineTo(34.0, 24.0)
      ..lineTo(34.0, 38.5)
      ..close();
    canvas.drawPath(body, fillP(fill));

    // Waist groove
    final waist = Path()
      ..moveTo(12.5, 30.5)
      ..lineTo(32.5, 30.5)
      ..lineTo(32.5, 33.0)
      ..lineTo(12.5, 33.0)
      ..close();
    canvas.drawPath(waist, fillP(dark));
    canvas.drawPath(waist, strokeP(w: 0.7));

    // Three battlements
    for (final x in [11.0, 19.5, 27.0]) {
      final bt = Path()
        ..moveTo(x, 24.0)
        ..lineTo(x, 16.0)
        ..lineTo(x + 6.5, 16.0)
        ..lineTo(x + 6.5, 24.0)
        ..close();
      canvas.drawPath(bt, fillP(fill));
      canvas.drawPath(bt, strokeP());
      // battlement inner sheen
      canvas.drawLine(
        Offset(x + 1.5, 17.5), Offset(x + 1.5, 23.0),
        strokeP(w: 0.7, color: sheen),
      );
    }

    // Body outline
    canvas.drawPath(body, strokeP(w: 1.4));

    // Interior horizontal line
    canvas.drawLine(const Offset(12.5, 27.0), const Offset(32.5, 27.0),
        strokeP(w: 0.9, color: dark));
  }

  // ── KNIGHT ────────────────────────────────────────────────────────────────
  void _knight(Canvas canvas) {
    _base(canvas, w: 13.0);

    // Full horse-head silhouette
    final body = Path()
      ..moveTo(11.0, 38.5)
      ..lineTo(11.0, 31.0)
      ..cubicTo(11.0, 29.0, 13.0, 27.5, 14.5, 26.0)
      ..cubicTo(15.5, 22.0, 15.0, 18.0, 17.5, 14.5)
      ..cubicTo(19.5, 11.5, 24.0, 9.5, 27.5, 11.0)
      ..cubicTo(31.5, 12.5, 32.5, 17.5, 30.5, 21.5)
      ..cubicTo(29.0, 24.5, 27.5, 25.5, 26.0, 26.5)
      ..lineTo(33.0, 26.5)
      ..lineTo(34.0, 31.0)
      ..lineTo(34.0, 38.5)
      ..close();

    // Drop shadow behind horse
    canvas.drawPath(body, fillP(dark));
    canvas.save();
    canvas.translate(-0.5, -0.5);
    canvas.drawPath(body, fillP(fill));
    canvas.restore();
    canvas.drawPath(body, fillP(fill));

    // Mane stripe
    final mane = Path()
      ..moveTo(17.5, 14.5)
      ..cubicTo(16.5, 18.0, 16.0, 22.0, 17.0, 26.0)
      ..lineTo(19.5, 26.0)
      ..cubicTo(18.5, 22.0, 19.0, 18.0, 20.5, 14.5)
      ..close();
    canvas.drawPath(mane, fillP(dark));

    // Eye
    canvas.drawCircle(
      const Offset(26.5, 15.5), 2.2,
      fillP(isWhite ? bFill : wFill),
    );
    canvas.drawCircle(const Offset(26.5, 15.5), 2.2, strokeP(w: 0.8));
    canvas.drawCircle(const Offset(26.5, 15.5), 1.0,
        fillP(isWhite ? bDark : Colors.white));

    // Nostril
    canvas.drawCircle(
      const Offset(22.0, 22.5), 1.5,
      fillP(isWhite ? bFill.withOpacity(0.5) : wFill.withOpacity(0.3)),
    );

    // Outline
    canvas.drawPath(body, strokeP(w: 1.4));

    // Neck groove
    canvas.drawLine(const Offset(11.5, 35.0), const Offset(33.5, 35.0),
        strokeP(w: 0.8, color: dark));
  }

  // ── BISHOP ────────────────────────────────────────────────────────────────
  void _bishop(Canvas canvas) {
    _base(canvas, w: 12.0);

    // Body / robe
    final robe = Path()
      ..moveTo(14.5, 38.5)
      ..cubicTo(12.5, 32.0, 13.0, 28.0, 16.0, 24.0)
      ..lineTo(17.5, 22.5)
      ..lineTo(27.5, 22.5)
      ..lineTo(29.0, 24.0)
      ..cubicTo(32.0, 28.0, 32.5, 32.0, 30.5, 38.5)
      ..close();
    canvas.drawPath(robe, fillP(fill));

    // Band across waist
    canvas.drawLine(const Offset(15.5, 31.5), const Offset(29.5, 31.5),
        strokeP(w: 1.8, color: dark));
    canvas.drawLine(const Offset(16.0, 33.5), const Offset(29.0, 33.5),
        strokeP(w: 0.8, color: sheen));

    // Neck
    final neck = Path()
      ..moveTo(19.5, 22.5)
      ..lineTo(20.5, 18.5)
      ..lineTo(24.5, 18.5)
      ..lineTo(25.5, 22.5)
      ..close();
    canvas.drawPath(neck, fillP(fill));
    canvas.drawPath(neck, strokeP(w: 0.9));

    // Head orb
    const headC = Offset(22.5, 15.0);
    canvas.drawCircle(headC, 6.8, fillP(dark));
    canvas.drawCircle(headC, 6.5, fillP(fill));
    canvas.drawArc(
      const Rect.fromLTWH(16.8, 9.3, 11.4, 11.4),
      -2.2, 1.2, false,
      Paint()
        ..color = isWhite ? Colors.white.withOpacity(0.55) : Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(headC, 6.5, strokeP(w: 1.3));

    // Cross on tip
    final crossC = const Offset(22.5, 7.5);
    canvas.drawLine(
      crossC.translate(0, -3), crossC.translate(0, 3),
      strokeP(w: 2.0, color: isWhite ? wOutline : const Color(0xFFDDDDDD)),
    );
    canvas.drawLine(
      crossC.translate(-2.5, 0), crossC.translate(2.5, 0),
      strokeP(w: 2.0, color: isWhite ? wOutline : const Color(0xFFDDDDDD)),
    );

    canvas.drawPath(robe, strokeP(w: 1.4));
  }

  // ── QUEEN ─────────────────────────────────────────────────────────────────
  void _queen(Canvas canvas) {
    _base(canvas, w: 14.0);

    // Skirt / body
    final skirt = Path()
      ..moveTo(10.0, 38.5)
      ..lineTo(12.0, 28.0)
      ..lineTo(15.0, 24.5)
      ..lineTo(22.5, 29.0)
      ..lineTo(30.0, 24.5)
      ..lineTo(33.0, 28.0)
      ..lineTo(35.0, 38.5)
      ..close();
    canvas.drawPath(skirt, fillP(fill));

    // Waist band
    canvas.drawLine(const Offset(12.5, 33.5), const Offset(32.5, 33.5),
        strokeP(w: 1.8, color: dark));
    canvas.drawLine(const Offset(13.0, 35.5), const Offset(32.0, 35.5),
        strokeP(w: 0.8, color: sheen));

    // 5 crown balls
    final ballPositions = [
      const Offset(10.5, 22.0),
      const Offset(15.5, 18.0),
      const Offset(22.5, 16.5),
      const Offset(29.5, 18.0),
      const Offset(34.5, 22.0),
    ];
    for (final pos in ballPositions) {
      canvas.drawCircle(pos, 3.8, fillP(dark));
      canvas.drawCircle(pos, 3.5, fillP(fill));
      canvas.drawCircle(pos, 3.5, strokeP(w: 1.1));
      // sheen dot
      canvas.drawCircle(
        pos.translate(-1.0, -1.0), 1.0,
        fillP(isWhite ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.15)),
      );
    }

    canvas.drawPath(skirt, strokeP(w: 1.4));
  }

  // ── KING ──────────────────────────────────────────────────────────────────
  void _king(Canvas canvas) {
    _base(canvas, w: 14.0);

    // Body
    final body = Path()
      ..moveTo(11.0, 38.5)
      ..lineTo(12.5, 29.0)
      ..lineTo(15.0, 25.0)
      ..lineTo(30.0, 25.0)
      ..lineTo(32.5, 29.0)
      ..lineTo(34.0, 38.5)
      ..close();
    canvas.drawPath(body, fillP(fill));

    // Waist band
    canvas.drawLine(const Offset(13.0, 34.0), const Offset(32.0, 34.0),
        strokeP(w: 1.8, color: dark));
    canvas.drawLine(const Offset(13.5, 36.0), const Offset(31.5, 36.0),
        strokeP(w: 0.8, color: sheen));

    // Crown battlements
    final crown = Path()
      ..moveTo(13.0, 29.0)
      ..lineTo(13.0, 21.0)
      ..lineTo(17.5, 21.0)
      ..lineTo(17.5, 25.0)
      ..lineTo(21.0, 25.0)
      ..lineTo(21.0, 18.5)
      ..lineTo(24.0, 18.5)
      ..lineTo(24.0, 25.0)
      ..lineTo(27.5, 25.0)
      ..lineTo(27.5, 21.0)
      ..lineTo(32.0, 21.0)
      ..lineTo(32.0, 29.0)
      ..close();
    canvas.drawPath(crown, fillP(fill));
    canvas.drawPath(crown, strokeP(w: 1.4));

    // Cross on very top
    final gold = isWhite ? wOutline : const Color(0xFFFFCC44);
    canvas.drawLine(
      const Offset(22.5, 11.0), const Offset(22.5, 18.5),
      strokeP(w: 2.5, color: gold),
    );
    canvas.drawLine(
      const Offset(18.5, 14.0), const Offset(26.5, 14.0),
      strokeP(w: 2.5, color: gold),
    );

    canvas.drawPath(body, strokeP(w: 1.4));
  }

  @override
  bool shouldRepaint(_PiecePainter old) =>
      old.piece.type != piece.type || old.piece.color != piece.color;
}
