import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/route_paths.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../../shared/models/app_models.dart';
import '../application/project_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final controller = ref.read(projectControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 540,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start a new execution',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter one project goal. The orchestrator will fan out work across the agent pipeline.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _goalController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Example: Build an MVP that generates PRD, schema, UI, and QA artifacts for a new product idea.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          final result = controller.createProject(
                            _goalController.text,
                          );
                          if (result == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Project goal cannot be empty.'),
                              ),
                            );
                            return;
                          }

                          if (result.reusedExisting) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'A matching workflow is already running. Reopening it.',
                                ),
                              ),
                            );
                          }

                          _goalController.clear();
                          context.go(RoutePaths.project(result.projectId));
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Generate execution plan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workspace',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: state.selectedWorkspaceId,
                        items: [
                          for (final workspace in state.workspaces)
                            DropdownMenuItem(
                              value: workspace.id,
                              child: Text(workspace.name),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectWorkspace(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _MetricRow(
                        label: 'Members',
                        value: '${state.selectedWorkspace.membersCount}',
                      ),
                      const SizedBox(height: 8),
                      _MetricRow(
                        label: 'Active projects',
                        value: '${state.selectedWorkspace.activeProjects}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Recent workflow runs',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (state.projects.isEmpty)
          const EmptyStateCard(
            title: 'No workflow runs yet',
            message:
                'Start with a project goal and the orchestrator will create the first execution pipeline.',
          )
        else
          ...state.projects
              .take(3)
              .map(
                (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProjectPreviewCard(project: project),
                ),
              ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ProjectPreviewCard extends StatelessWidget {
  const _ProjectPreviewCard({required this.project});

  final ProjectSummary project;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(RoutePaths.project(project.id)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Chip(
                    label: Text(project.status.label),
                    backgroundColor: project.status
                        .color(scheme)
                        .withValues(alpha: 0.14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(project.goal),
              const SizedBox(height: 12),
              Text(
                '${project.steps.length} steps • ${project.artifacts.length} artifacts',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
