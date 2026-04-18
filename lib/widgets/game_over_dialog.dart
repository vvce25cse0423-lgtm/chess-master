// lib/widgets/game_over_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chess_game.dart';
import '../models/chess_piece.dart';
import '../theme/app_theme.dart';

class GameOverDialog extends StatelessWidget {
  final GameStatus status;
  final PieceColor? winner;
  final VoidCallback onNewGame;
  final VoidCallback onMainMenu;

  const GameOverDialog({
    super.key,
    required this.status,
    required this.winner,
    required this.onNewGame,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon, color) = _getContent();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.secondary, AppTheme.primary],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .shimmer(duration: 2.seconds, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMainMenu,
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text('MENU'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNewGame,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('REMATCH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  (String, String, String, Color) _getContent() {
    switch (status) {
      case GameStatus.checkmate:
        final winnerName = winner == PieceColor.white ? 'White' : 'Black';
        return (
          'CHECKMATE',
          '$winnerName wins by checkmate!',
          winner == PieceColor.white ? '♔' : '♚',
          AppTheme.gold,
        );
      case GameStatus.stalemate:
        return ('STALEMATE', 'The game is a draw!', '⚖️', AppTheme.silver);
      case GameStatus.draw:
        return ('DRAW', 'The game is a draw!', '🤝', AppTheme.silver);
      case GameStatus.resigned:
        final winnerName = winner == PieceColor.white ? 'White' : 'Black';
        return (
          'RESIGNED',
          '$winnerName wins by resignation!',
          '🏳️',
          AppTheme.accent,
        );
      default:
        return ('GAME OVER', '', '♟', AppTheme.gold);
    }
  }
}
