import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_models.dart';
import '../../projects/application/project_controller.dart';

class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectControllerProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: state.workspaces.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final workspace = state.workspaces[index];
        final isSelected = workspace.id == state.selectedWorkspaceId;
        return _WorkspaceCard(
          workspace: workspace,
          isSelected: isSelected,
          onTap: () {
            ref
                .read(projectControllerProvider.notifier)
                .selectWorkspace(workspace.id);
          },
        );
      },
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.workspace,
    required this.isSelected,
    required this.onTap,
  });

  final WorkspaceSummary workspace;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(workspace.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${workspace.membersCount} members • ${workspace.activeProjects} active projects',
          ),
        ),
        trailing: isSelected
            ? const Chip(label: Text('Active'))
            : OutlinedButton(onPressed: onTap, child: const Text('Switch')),
      ),
    );
  }
}
