import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/route_paths.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../shared/models/app_models.dart';
import '../application/project_controller.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectByIdProvider(projectId));
    if (project == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: EmptyStateCard(
          title: 'Project not found',
          message: 'The selected workflow run does not exist.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(project.goal),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Chip(label: Text(project.status.label)),
                    Chip(label: Text('${project.steps.length} steps')),
                    Chip(label: Text('${project.artifacts.length} artifacts')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Execution plan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...project.executionPlan.map(
          (planItem) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.subdirectory_arrow_right, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(planItem)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Workflow pipeline',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...project.steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WorkflowStepCard(step: step),
          ),
        ),
        const SizedBox(height: 24),
        Text('Artifacts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (project.artifacts.isEmpty)
          const EmptyStateCard(
            title: 'No artifacts yet',
            message: 'Artifacts will appear as agents finish each step.',
          )
        else
          ...project.artifacts.map(
            (artifact) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ArtifactCard(projectId: project.id, artifact: artifact),
            ),
          ),
        const SizedBox(height: 24),
        Text('Execution log', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in project.executionLog) ...[
                  Text(entry),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkflowStepCard extends StatelessWidget {
  const _WorkflowStepCard({required this.step});

  final WorkflowStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(step.status.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(step.status.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text(step.agentName),
            const SizedBox(height: 8),
            Text(step.summary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: step.outputs
                  .map((output) => Chip(label: Text(output)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtifactCard extends StatelessWidget {
  const _ArtifactCard({required this.projectId, required this.artifact});

  final String projectId;
  final ArtifactRecord artifact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        title: Text(artifact.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(artifact.summary),
        ),
        trailing: FilledButton.tonal(
          onPressed: () =>
              context.go(RoutePaths.artifact(projectId, artifact.id)),
          child: const Text('Open'),
        ),
      ),
    );
  }
}
