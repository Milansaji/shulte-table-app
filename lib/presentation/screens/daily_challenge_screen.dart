import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/game_constants.dart';
import '../../domain/entities/daily_challenge.dart';
import '../../data/repositories/game_repository.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/schulte_game_cell.dart';
import '../../core/services/audio_service.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});
  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late List<int> _numbers;
  late List<bool> _found;
  int _currentNumber = 1;
  int? _wrongTapIndex;
  Timer? _wrongTapTimer;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _formattedTime = '0.0s';
  bool _started = false;
  bool _completed = false;
  final int _gridSize = GameConstants.dailyChallengeGridSize;
  late int _totalNumbers;

  @override
  void initState() {
    super.initState();
    _totalNumbers = _gridSize * _gridSize;
    final seed = DailyChallenge.seedForDate(DailyChallenge.todayKey());
    _numbers = GameRepository().generateSeededShuffledNumbers(_totalNumbers, seed);
    _found = List<bool>.filled(_totalNumbers, false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wrongTapTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    if (_started) return;
    setState(() { _started = true; });
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() { _formattedTime = _fmt(_stopwatch.elapsedMilliseconds); });
    });
  }

  void _tapNumber(int index) {
    if (!_started || _completed || _found[index]) return;
    final vibOn = context.read<SettingsProvider>().vibrationEnabled;
    if (_numbers[index] != _currentNumber) {
      if (vibOn) HapticFeedback.heavyImpact();
      AudioService.instance.playWrong();
      setState(() { _wrongTapIndex = index; });
      _wrongTapTimer?.cancel();
      _wrongTapTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted) setState(() { _wrongTapIndex = null; });
      });
      return;
    }
    if (vibOn) HapticFeedback.lightImpact();
    AudioService.instance.playCorrect();
    setState(() {
      _found[index] = true;
      _currentNumber++;
      _wrongTapIndex = null;
    });
    if (_currentNumber > _totalNumbers) _onComplete();
  }

  void _onComplete() {
    _stopwatch.stop();
    _timer?.cancel();
    AudioService.instance.playLevelUnlock();
    setState(() { _completed = true; });
    final ms = _stopwatch.elapsedMilliseconds;
    final dc = context.read<DailyChallengeProvider>();
    dc.recordCompletion(ms);
    final sp = context.read<StatsProvider>();
    sp.recordGame(gridSize: _gridSize, timeMs: ms, isDailyChallenge: true);
    context.read<StreakProvider>().recordPlay();
    context.read<AchievementProvider>().checkAndUnlock(
      stats: sp.stats, streak: context.read<StreakProvider>().streak);
  }

  String _fmt(int ms) {
    final s = ms / 1000;
    if (s < 60) return '${s.toStringAsFixed(1)}s';
    return '${s ~/ 60}m ${(s % 60).toStringAsFixed(1)}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final bg = isDark ? Colors.black : Colors.white;
    final progress = _totalNumbers > 0 ? (_currentNumber - 1) / _totalNumbers : 0.0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, foregroundColor: fg,
        surfaceTintColor: Colors.transparent, elevation: 0,
        title: Text('Daily Challenge', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Streak display
          Consumer<StreakProvider>(builder: (_, sp, __) => Text(
            '🔥 ${sp.currentStreak} day streak',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.6)),
          )),
          const SizedBox(height: 16),
          // Timer + progress
          SizedBox(width: 180, height: 180, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 180, height: 180, child: CircularProgressIndicator(value: 1.0, strokeWidth: 7, color: isDark ? Colors.white12 : Colors.black12)),
            SizedBox(width: 180, height: 180, child: CircularProgressIndicator(value: progress.clamp(0.0, 1.0), strokeWidth: 7, strokeCap: StrokeCap.round, color: fg)),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_formattedTime, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: fg, fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 4),
              Text('$_currentNumber / $_totalNumbers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.5))),
            ]),
          ])),
          const SizedBox(height: 20),
          if (!_started && !_completed)
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: fg, foregroundColor: bg, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
              child: const Text('Start Challenge', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          if (_completed)
            Column(children: [
              Text(MessageConstants.gameCompleted, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
              const SizedBox(height: 8),
              Text(_formattedTime, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.7))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: fg, foregroundColor: bg),
                child: const Text('Back to Home'),
              ),
            ]),
          const SizedBox(height: 20),
          // Grid
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fg, width: 2),
            ),
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _gridSize, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: _totalNumbers,
              itemBuilder: (_, i) => SchulteGameCell(
                number: _numbers[i], isFound: _found[i],
                isWrongTap: _wrongTapIndex == i,
                onTap: () => _tapNumber(i), fontSize: 22,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
