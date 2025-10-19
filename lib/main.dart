import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/repositories/bible_repository_impl.dart';
import 'data/repositories/meditation_note_repository_impl.dart';
import 'presentation/viewmodels/bible_viewmodel.dart';
import 'presentation/viewmodels/meditation_note_viewmodel.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

/// 앱 진입점
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection 설정
    return MultiProvider(
      providers: [
        // DatabaseHelper 싱글톤
        Provider<DatabaseHelper>(
          create: (_) => DatabaseHelper.instance,
        ),

        // Repositories
        ProxyProvider<DatabaseHelper, MeditationNoteRepositoryImpl>(
          update: (_, dbHelper, __) => MeditationNoteRepositoryImpl(dbHelper),
        ),
        ProxyProvider<DatabaseHelper, BibleRepositoryImpl>(
          update: (_, dbHelper, __) => BibleRepositoryImpl(dbHelper),
        ),

        // ViewModels
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),
        ChangeNotifierProxyProvider<MeditationNoteRepositoryImpl,
            MeditationNoteViewModel>(
          create: (context) => MeditationNoteViewModel(
            context.read<MeditationNoteRepositoryImpl>(),
          ),
          update: (_, repository, viewModel) =>
              viewModel ?? MeditationNoteViewModel(repository),
        ),
        ChangeNotifierProxyProvider<BibleRepositoryImpl, BibleViewModel>(
          create: (context) => BibleViewModel(
            context.read<BibleRepositoryImpl>(),
          ),
          update: (_, repository, viewModel) =>
              viewModel ?? BibleViewModel(repository),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: '성경묵상노트',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
