import 'package:flutter/material.dart';

class NavigationItem {
  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.trailing,
  });

  final String title;
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  minWidth: 88,
                  minExtendedWidth: 220,
                  selectedIndex: selectedIndex,
                  useIndicator: true,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                  onDestinationSelected: onDestinationSelected,
                  trailing: trailing,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(title: Text(title)),
                    body: SafeArea(child: child),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [if (trailing != null) trailing!],
          ),
          body: SafeArea(child: child),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              for (final item in items)
                NavigationDestination(icon: Icon(item.icon), label: item.label),
            ],
          ),
        );
      },
    );
  }
}
