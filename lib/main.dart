import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/audio_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/stats_provider.dart';
import 'presentation/providers/streak_provider.dart';
import 'presentation/providers/achievement_provider.dart';
import 'presentation/providers/daily_challenge_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/schulte_table_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/stats_screen.dart';
import 'presentation/screens/achievements_screen.dart';
import 'presentation/screens/daily_challenge_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  await AudioService.instance.initialize();
  runApp(const SchulteTableApp());
}

class SchulteTableApp extends StatefulWidget {
  const SchulteTableApp({super.key});
  @override
  State<SchulteTableApp> createState() => _SchulteTableAppState();
}

class _SchulteTableAppState extends State<SchulteTableApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final SettingsProvider _settingsProvider = SettingsProvider();
  final StatsProvider _statsProvider = StatsProvider();
  final StreakProvider _streakProvider = StreakProvider();
  final AchievementProvider _achievementProvider = AchievementProvider();
  final DailyChallengeProvider _dailyChallengeProvider = DailyChallengeProvider();

  @override
  void initState() {
    super.initState();
    _initProviders();
  }

  Future<void> _initProviders() async {
    await _themeProvider.initialize();
    await _settingsProvider.initialize();
    await _statsProvider.initialize();
    await _streakProvider.initialize();
    await _achievementProvider.initialize();
    await _dailyChallengeProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: _settingsProvider),
        ChangeNotifierProvider<StatsProvider>.value(value: _statsProvider),
        ChangeNotifierProvider<StreakProvider>.value(value: _streakProvider),
        ChangeNotifierProvider<AchievementProvider>.value(value: _achievementProvider),
        ChangeNotifierProvider<DailyChallengeProvider>.value(value: _dailyChallengeProvider),
        ChangeNotifierProxyProvider<SettingsProvider, GameProvider>(
          create: (_) => GameProvider(),
          update: (_, settings, game) {
            game!.vibrationEnabled = settings.vibrationEnabled;
            game.soundEnabled = settings.soundEnabled;
            AudioService.instance.soundEnabled = settings.soundEnabled;
            return game;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Schulte Master',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const SchulteTableScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/stats': (context) => const StatsScreen(),
              '/achievements': (context) => const AchievementsScreen(),
              '/daily': (context) => const DailyChallengeScreen(),
            },
          );
        },
      ),
    );
  }
}
