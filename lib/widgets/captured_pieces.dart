// lib/widgets/captured_pieces.dart
import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../theme/app_theme.dart';

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
    // Sort by value
    final sorted = List<ChessPiece>.from(pieces)
      ..sort((a, b) => a.value.compareTo(b.value));

    return Row(
      children: [
        Wrap(
          spacing: 0,
          children: sorted.map((p) => Text(
            p.unicode,
            style: const TextStyle(fontSize: 16),
          )).toList(),
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
