import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/route_paths.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../shared/models/app_models.dart';
import '../application/project_controller.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectControllerProvider);
    final projects = state.projects;

    if (projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: EmptyStateCard(
          title: 'No projects yet',
          message: 'Create the first execution run from the dashboard.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final project = projects[index];
        return _ProjectListTile(project: project);
      },
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  const _ProjectListTile({required this.project});

  final ProjectSummary project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(project.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(project.goal),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(RoutePaths.project(project.id)),
      ),
    );
  }
}
