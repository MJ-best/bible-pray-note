import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/datasources/database_helper.dart';
import '../home/home_screen.dart';

/// 초기 로딩 화면
/// 성경 데이터를 로드하고 진행 상황을 표시
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  String _message = '초기화 중...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final dbHelper = context.read<DatabaseHelper>();

      // 성경 데이터 로드
      await dbHelper.loadBibleData(
        onProgress: (progress, message) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _message = message;
            });
          }
        },
      );

      // 로딩 완료 후 홈 화면으로 이동
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 아이콘/로고
              Icon(
                Icons.menu_book,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // 앱 이름
              Text(
                '성경묵상노트',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),

              // 에러가 없을 때만 진행률 표시
              if (!_hasError) ...[
                // 진행률 바
                SizedBox(
                  width: double.infinity,
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),

                // 진행 메시지
                Text(
                  _message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 퍼센트
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],

              // 에러 표시
              if (_hasError) ...[
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  '데이터 로드 중 오류가 발생했습니다',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _progress = 0.0;
                      _message = '다시 시도 중...';
                    });
                    _initializeApp();
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
