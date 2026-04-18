// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/chess_game.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(context),
                    const SizedBox(height: 60),
                    _buildButtons(context),
                    const SizedBox(height: 40),
                    _buildStats(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Text(
          '♟',
          style: const TextStyle(fontSize: 80),
        ).animate()
          .scale(duration: 800.ms, curve: Curves.elasticOut)
          .then()
          .shimmer(duration: 3.seconds, color: AppTheme.gold),
        const SizedBox(height: 12),
        Text(
          'CHESS MASTER',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            letterSpacing: 6,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppTheme.gold, Colors.white, AppTheme.gold],
              ).createShader(const Rect.fromLTWH(0, 0, 300, 60)),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          'THE ROYAL GAME',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 4,
            color: AppTheme.textSecondary,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        _MenuButton(
          icon: Icons.people,
          label: 'PLAYER VS PLAYER',
          subtitle: 'Local multiplayer',
          color: AppTheme.gold,
          onTap: () => _startGame(context, GameMode.pvp),
          delay: 200,
        ),
        const SizedBox(height: 16),
        _MenuButton(
          icon: Icons.computer,
          label: 'PLAY VS AI',
          subtitle: 'Challenge the computer',
          color: AppTheme.accent,
          onTap: () => _showAIDialog(context),
          delay: 300,
        ),
        const SizedBox(height: 16),
        _MenuButton(
          icon: Icons.timer,
          label: 'TIMED GAME',
          subtitle: 'Race against the clock',
          color: const Color(0xFF00BCD4),
          onTap: () => _showTimedDialog(context),
          delay: 400,
        ),
        const SizedBox(height: 16),
        _MenuButton(
          icon: Icons.settings,
          label: 'SETTINGS',
          subtitle: 'Customize your experience',
          color: AppTheme.silver,
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => const SettingsScreen(),
          )),
          delay: 500,
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'WHITE WINS', value: '${provider.whiteWins}', color: Colors.white),
              Container(width: 1, height: 40, color: Colors.white12),
              _StatItem(label: 'DRAWS', value: '${provider.draws}', color: AppTheme.silver),
              Container(width: 1, height: 40, color: Colors.white12),
              _StatItem(label: 'BLACK WINS', value: '${provider.blackWins}', color: const Color(0xFF4A4A4A)),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms);
      },
    );
  }

  void _startGame(BuildContext context, GameMode mode, {AIDifficulty? difficulty, int? timeSeconds}) {
    context.read<GameProvider>().startNewGame(
      mode: mode,
      difficulty: difficulty,
      timeSeconds: timeSeconds,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  void _showAIDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _DifficultyDialog(
        onSelect: (difficulty) {
          Navigator.pop(ctx);
          _startGame(context, GameMode.vsAI, difficulty: difficulty);
        },
      ),
    );
  }

  void _showTimedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _TimedDialog(
        onSelect: (seconds) {
          Navigator.pop(ctx);
          _startGame(context, GameMode.pvp, timeSeconds: seconds);
        },
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.3, end: 0);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: color,
            fontSize: 28,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _DifficultyDialog extends StatelessWidget {
  final Function(AIDifficulty) onSelect;
  const _DifficultyDialog({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.gold, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SELECT DIFFICULTY', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.gold)),
            const SizedBox(height: 24),
            ...AIDifficulty.values.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onSelect(d),
                  child: Text(d.name.toUpperCase()),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TimedDialog extends StatelessWidget {
  final Function(int) onSelect;
  const _TimedDialog({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('1 min', 60), ('3 min', 180), ('5 min', 300),
      ('10 min', 600), ('15 min', 900), ('30 min', 1800),
    ];
    return Dialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.gold, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SELECT TIME CONTROL', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.gold)),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
              children: options.map((o) => OutlinedButton(
                onPressed: () => onSelect(o.$2),
                child: Text(o.$1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
