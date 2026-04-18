// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/chess_game.dart';
import '../models/chess_piece.dart';
import '../theme/app_theme.dart';
import '../widgets/chess_board.dart';
import '../widgets/player_info_bar.dart';
import '../widgets/move_history.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        // Show game over dialog
        if (provider.game.isGameOver && !_dialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _dialogShown = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => GameOverDialog(
                status: provider.game.status,
                winner: provider.game.winner,
                onNewGame: () {
                  Navigator.pop(context);
                  setState(() => _dialogShown = false);
                  provider.startNewGame();
                },
                onMainMenu: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            );
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.primary,
          appBar: _buildAppBar(context, provider),
          body: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return _buildLandscapeLayout(context, provider);
              }
              return _buildPortraitLayout(context, provider);
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, GameProvider provider) {
    return AppBar(
      backgroundColor: AppTheme.secondary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => _showExitDialog(context, provider),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            provider.gameMode == GameMode.pvp ? '⚔ PVP' : '🤖 VS AI',
            style: const TextStyle(fontSize: 14, letterSpacing: 2),
          ),
          if (provider.gameMode == GameMode.vsAI) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
              ),
              child: Text(
                provider.difficulty.name.toUpperCase(),
                style: const TextStyle(color: AppTheme.accent, fontSize: 10, letterSpacing: 1),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.flip, size: 20),
          onPressed: provider.flipBoard,
          tooltip: 'Flip Board',
        ),
        IconButton(
          icon: Icon(provider.soundEnabled ? Icons.volume_up : Icons.volume_off, size: 20),
          onPressed: provider.toggleSound,
          tooltip: 'Sound',
        ),
        IconButton(
          icon: const Icon(Icons.flag_outlined, size: 20, color: AppTheme.accent),
          onPressed: () => _showResignDialog(context, provider),
          tooltip: 'Resign',
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context, GameProvider provider) {
    final isBlackTurn = provider.game.currentTurn == PieceColor.black;
    final isWhiteTurn = provider.game.currentTurn == PieceColor.white;

    return Column(
      children: [
        // Status bar
        _buildStatusBar(context, provider),
        // Black player info
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: PlayerInfoBar(
            playerColor: PieceColor.black,
            name: provider.gameMode == GameMode.vsAI ? 'Computer (${provider.difficulty.name})' : 'Black',
            isCurrentTurn: isBlackTurn && !provider.game.isGameOver,
          ),
        ),
        // Board
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const ChessBoard(),
        ),
        // White player info
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: PlayerInfoBar(
            playerColor: PieceColor.white,
            name: 'White',
            isCurrentTurn: isWhiteTurn && !provider.game.isGameOver,
          ),
        ),
        // Move history
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: const MoveHistory(),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, GameProvider provider) {
    final isBlackTurn = provider.game.currentTurn == PieceColor.black;
    final isWhiteTurn = provider.game.currentTurn == PieceColor.white;

    return Row(
      children: [
        // Board area
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildStatusBar(context, provider),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: PlayerInfoBar(
                  playerColor: PieceColor.black,
                  name: provider.gameMode == GameMode.vsAI ? 'Computer' : 'Black',
                  isCurrentTurn: isBlackTurn && !provider.game.isGameOver,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const ChessBoard(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: PlayerInfoBar(
                  playerColor: PieceColor.white,
                  name: 'White',
                  isCurrentTurn: isWhiteTurn && !provider.game.isGameOver,
                ),
              ),
            ],
          ),
        ),
        // Side panel
        SizedBox(
          width: 180,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: const MoveHistory(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context, GameProvider provider) {
    String message = '';
    Color color = AppTheme.textSecondary;

    switch (provider.game.status) {
      case GameStatus.check:
        message = '⚠ CHECK!';
        color = AppTheme.accent;
        break;
      case GameStatus.checkmate:
        message = '♟ CHECKMATE';
        color = AppTheme.gold;
        break;
      case GameStatus.stalemate:
        message = '⚖ STALEMATE';
        color = AppTheme.silver;
        break;
      case GameStatus.playing:
        message = provider.game.currentTurn == PieceColor.white 
          ? '♔ White to move' 
          : '♚ Black to move';
        color = AppTheme.textSecondary;
        break;
      case GameStatus.resigned:
        message = '🏳 Game Resigned';
        color = AppTheme.accent;
        break;
      default:
        message = '';
    }

    if (provider.isAIThinking) {
      message = '🤖 AI is thinking...';
      color = const Color(0xFF00BCD4);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: AppTheme.secondary,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showResignDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.accent, width: 1),
        ),
        title: Text('RESIGN GAME', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.accent)),
        content: Text(
          'Are you sure you want to resign? Your opponent wins.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.resign();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('RESIGN'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, GameProvider provider) {
    if (provider.game.isGameOver || provider.game.moveHistory.isEmpty) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('LEAVE GAME?', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Current game will be lost.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('STAY')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );
  }
}
