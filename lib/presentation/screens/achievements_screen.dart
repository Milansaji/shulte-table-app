import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/achievement_definitions.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, foregroundColor: fg,
        surfaceTintColor: Colors.transparent, elevation: 0,
        title: Text('Achievements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
        centerTitle: true,
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, _) {
          final unlocked = provider.unlocked;
          final defs = AchievementCatalog.all;
          final count = defs.where((d) => unlocked.containsKey(d.id)).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: Text('$count / ${defs.length} Unlocked', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.6)))),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: defs.isEmpty ? 0 : count / defs.length, minHeight: 6, backgroundColor: isDark ? Colors.white12 : Colors.black12, valueColor: AlwaysStoppedAnimation(fg)),
              ),
              const SizedBox(height: 24),
              ...defs.map((def) {
                final a = unlocked[def.id];
                final u = a != null;
                final subtle = isDark ? Colors.white38 : Colors.black38;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: u ? fg.withValues(alpha: 0.06) : fg.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: u ? fg.withValues(alpha: 0.2) : fg.withValues(alpha: 0.06)),
                  ),
                  child: Row(children: [
                    Text(u ? def.emoji : '🔒', style: TextStyle(fontSize: 28, color: u ? null : subtle)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(def.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: u ? fg : subtle)),
                      const SizedBox(height: 3),
                      Text(def.description, style: TextStyle(fontSize: 13, color: u ? fg.withValues(alpha: 0.6) : subtle)),
                      if (u && a.unlockedAt != null) ...[
                        const SizedBox(height: 4),
                        Text('Unlocked ${_fmt(a.unlockedAt!)}', style: TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.4))),
                      ],
                    ])),
                    if (u) Icon(Icons.check_circle_rounded, color: fg.withValues(alpha: 0.4), size: 20),
                  ]),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month-1]} ${d.day}, ${d.year}';
  }
}
