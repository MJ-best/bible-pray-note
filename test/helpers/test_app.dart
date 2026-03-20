import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artifact_flow/core/config/app_router.dart';
import 'package:artifact_flow/features/auth/application/auth_controller.dart';
import 'package:artifact_flow/main.dart';

Widget buildTestApp({String? initialLocation, AuthController? authController}) {
  return ProviderScope(
    overrides: [
      if (initialLocation != null)
        initialLocationProvider.overrideWith((ref) => initialLocation),
      if (authController != null)
        authControllerProvider.overrideWith((ref) => authController),
    ],
    child: const MultiAgentVibeApp(),
  );
}
