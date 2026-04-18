// lib/widgets/promotion_dialog.dart
import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../theme/app_theme.dart';
import 'chess_piece_svg.dart';

class PromotionDialog extends StatelessWidget {
  final PieceColor color;
  final Function(PieceType) onSelect;

  const PromotionDialog({
    super.key,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final pieces = [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight];

    return Dialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.gold, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PROMOTE PAWN',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.gold,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a piece to promote to',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pieces.map((type) {
                final piece = ChessPiece(type: type, color: color);
                return GestureDetector(
                  onTap: () => onSelect(type),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: ChessPieceSvg(piece: piece, size: 48),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
