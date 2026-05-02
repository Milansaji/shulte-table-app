import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/schulte_table_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SchulteTableApp());
}

class SchulteTableApp extends StatefulWidget {
  const SchulteTableApp({super.key});

  @override
  State<SchulteTableApp> createState() => _SchulteTableAppState();
}

class _SchulteTableAppState extends State<SchulteTableApp> {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _themeProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Schulte Master',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const SchulteTableScreen(),
            },
          );
        },
      ),
    );
  }
}
