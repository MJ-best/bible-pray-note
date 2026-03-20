import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/artifacts/presentation/artifact_viewer_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/projects/presentation/dashboard_screen.dart';
import '../../features/projects/presentation/project_detail_screen.dart';
import '../../features/projects/presentation/project_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/workspace/presentation/workspace_screen.dart';
import '../layout/app_shell.dart';
import 'route_paths.dart';

final initialLocationProvider = Provider<String?>((ref) => null);

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);
  final initialLocation = ref.watch(initialLocationProvider) ?? RoutePaths.root;

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authController,
    redirect: (context, state) {
      final isAuthenticated = authController.isAuthenticated;
      final isLoginRoute = state.matchedLocation == RoutePaths.login;

      if (!isAuthenticated && !isLoginRoute) {
        return RoutePaths.login;
      }

      if (isAuthenticated &&
          (isLoginRoute || state.matchedLocation == RoutePaths.root)) {
        return RoutePaths.dashboard;
      }

      if (!isAuthenticated && state.matchedLocation == RoutePaths.root) {
        return RoutePaths.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.root,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.workspaces,
            builder: (context, state) => const WorkspaceScreen(),
          ),
          GoRoute(
            path: RoutePaths.projects,
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: ':projectId',
                builder: (context, state) {
                  final projectId = state.pathParameters['projectId']!;
                  return ProjectDetailScreen(projectId: projectId);
                },
                routes: [
                  GoRoute(
                    path: 'artifacts/:artifactId',
                    builder: (context, state) {
                      final projectId = state.pathParameters['projectId']!;
                      final artifactId = state.pathParameters['artifactId']!;
                      return ArtifactViewerScreen(
                        projectId: projectId,
                        artifactId: artifactId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
