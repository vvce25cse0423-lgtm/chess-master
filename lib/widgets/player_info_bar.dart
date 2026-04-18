// lib/widgets/player_info_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/chess_piece.dart';
import '../theme/app_theme.dart';
import 'captured_pieces.dart';

class PlayerInfoBar extends StatelessWidget {
  final PieceColor playerColor;
  final String name;
  final bool isCurrentTurn;

  const PlayerInfoBar({
    super.key,
    required this.playerColor,
    required this.name,
    required this.isCurrentTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final captured = provider.game.capturedPieces[
          playerColor == PieceColor.white ? PieceColor.black : PieceColor.white
        ] ?? [];
        final advantage = provider.game.getMaterialAdvantage(playerColor);
        final timeLeft = provider.timeLeft[playerColor] ?? 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentTurn 
              ? AppTheme.surface.withOpacity(0.8) 
              : AppTheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentTurn ? AppTheme.gold.withOpacity(0.6) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: playerColor == PieceColor.white 
                    ? Colors.white.withOpacity(0.9)
                    : Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrentTurn ? AppTheme.gold : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    playerColor == PieceColor.white ? '♔' : '♚',
                    style: TextStyle(
                      fontSize: 20,
                      color: playerColor == PieceColor.white ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrentTurn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YOUR TURN',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    CapturedPiecesWidget(
                      pieces: captured,
                      color: playerColor,
                      materialAdvantage: advantage > 0 ? advantage : 0,
                    ),
                  ],
                ),
              ),
              // Timer
              if (provider.timerEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrentTurn && timeLeft < 30 
                      ? AppTheme.accent.withOpacity(0.3)
                      : AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCurrentTurn && timeLeft < 30 
                        ? AppTheme.accent 
                        : Colors.white24,
                    ),
                  ),
                  child: Text(
                    provider.formatTime(timeLeft),
                    style: TextStyle(
                      color: isCurrentTurn && timeLeft < 30 
                        ? AppTheme.accent 
                        : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
