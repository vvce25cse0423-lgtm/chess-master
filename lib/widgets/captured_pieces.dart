// lib/widgets/captured_pieces.dart
import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../theme/app_theme.dart';
import 'chess_piece_svg.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<ChessPiece> pieces;
  final PieceColor color;
  final int materialAdvantage;

  const CapturedPiecesWidget({
    super.key,
    required this.pieces,
    required this.color,
    required this.materialAdvantage,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<ChessPiece>.from(pieces)
      ..sort((a, b) => a.value.compareTo(b.value));

    return Row(
      children: [
        Wrap(
          spacing: -6,
          children: sorted.map((p) => ChessPieceSvg(piece: p, size: 18)).toList(),
        ),
        if (materialAdvantage > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+$materialAdvantage',
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
