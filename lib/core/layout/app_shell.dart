import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/route_paths.dart';
import 'responsive_scaffold.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    final user = authController.state.user;

    final items = const [
      NavigationItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        route: RoutePaths.dashboard,
      ),
      NavigationItem(
        label: 'Workspaces',
        icon: Icons.apartment_outlined,
        route: RoutePaths.workspaces,
      ),
      NavigationItem(
        label: 'Projects',
        icon: Icons.account_tree_outlined,
        route: RoutePaths.projects,
      ),
      NavigationItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        route: RoutePaths.settings,
      ),
    ];

    final selectedIndex = _selectedIndex(items, location);

    return ResponsiveScaffold(
      title: _titleForLocation(location),
      items: items,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => context.go(items[index].route),
      trailing: user == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 12),
              child: Tooltip(
                message: 'Signed in as ${user.name}',
                child: CircleAvatar(radius: 18, child: Text(user.initials)),
              ),
            ),
      child: child,
    );
  }

  int _selectedIndex(List<NavigationItem> items, String currentLocation) {
    for (var index = 0; index < items.length; index += 1) {
      if (currentLocation.startsWith(items[index].route)) {
        return index;
      }
    }
    return 0;
  }

  String _titleForLocation(String currentLocation) {
    if (currentLocation.startsWith(RoutePaths.workspaces)) {
      return 'Workspace overview';
    }
    if (currentLocation.startsWith(RoutePaths.projects)) {
      return 'Project workflow';
    }
    if (currentLocation.startsWith(RoutePaths.settings)) {
      return 'Settings';
    }
    return 'Execution dashboard';
  }
}
