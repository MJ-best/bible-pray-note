import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseBootstrap {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool _initialized = false;
  static String? _errorMessage;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get isInitialized => _initialized;

  static String? get errorMessage => _errorMessage;

  static Future<void> ensureInitialized() async {
    if (_initialized || !isConfigured) {
      return;
    }

    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      _initialized = true;
    } catch (error, stackTrace) {
      _errorMessage = '$error';
      debugPrint('Supabase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
