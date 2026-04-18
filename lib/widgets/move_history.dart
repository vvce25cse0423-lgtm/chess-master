// lib/widgets/move_history.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class MoveHistory extends StatelessWidget {
  const MoveHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final moves = provider.game.moveHistory;
        final pairs = <List<String>>[];
        
        for (int i = 0; i < moves.length; i += 2) {
          final white = moves[i].toAlgebraic();
          final black = i + 1 < moves.length ? moves[i + 1].toAlgebraic() : '';
          pairs.add([white, black]);
        }

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 16, color: AppTheme.gold),
                    const SizedBox(width: 6),
                    Text(
                      'MOVE HISTORY',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.gold,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${moves.length} moves',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),
              Expanded(
                child: moves.isEmpty
                  ? const Center(
                      child: Text(
                        'No moves yet',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: pairs.length,
                      itemBuilder: (context, index) {
                        final pair = pairs[index];
                        final isLast = index == pairs.length - 1;
                        return Container(
                          color: isLast ? AppTheme.surface.withOpacity(0.5) : null,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '${index + 1}.',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  pair[0],
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  pair[1],
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
