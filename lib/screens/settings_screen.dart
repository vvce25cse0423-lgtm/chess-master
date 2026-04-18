// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(label: 'DISPLAY'),
              _SettingsTile(
                icon: Icons.grid_on,
                title: 'Show Coordinates',
                subtitle: 'Show a-h and 1-8 labels on the board',
                trailing: Switch(
                  value: provider.showCoordinates,
                  onChanged: (_) => provider.toggleCoordinates(),
                  activeColor: AppTheme.gold,
                ),
              ),
              _SettingsTile(
                icon: Icons.flip,
                title: 'Flip Board',
                subtitle: 'Rotate the board 180 degrees',
                trailing: Switch(
                  value: provider.boardFlipped,
                  onChanged: (_) => provider.flipBoard(),
                  activeColor: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(label: 'AUDIO'),
              _SettingsTile(
                icon: Icons.volume_up,
                title: 'Sound Effects',
                subtitle: 'Play sounds on moves and captures',
                trailing: Switch(
                  value: provider.soundEnabled,
                  onChanged: (_) => provider.toggleSound(),
                  activeColor: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(label: 'ABOUT'),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Chess Master',
                subtitle: 'Version 1.0.0 • Built with Flutter',
                trailing: null,
              ),
              _SettingsTile(
                icon: Icons.code,
                title: 'Open Source',
                subtitle: 'Full-featured chess engine with AI',
                trailing: null,
              ),
              const SizedBox(height: 24),
              // Board colors preview
              _SectionHeader(label: 'BOARD PREVIEW'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (_, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final isLight = (row + col) % 2 == 0;
                      return Container(
                        color: isLight ? AppTheme.lightSquare : AppTheme.darkSquare,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.gold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.gold, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}
