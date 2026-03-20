import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/agents/domain/agent_catalog.dart';
import '../../../shared/data/mock_seed.dart';
import '../../../shared/models/app_models.dart';

class CreateProjectResult {
  const CreateProjectResult({
    required this.projectId,
    required this.reusedExisting,
  });

  final String projectId;
  final bool reusedExisting;
}

class ProjectState {
  const ProjectState({
    required this.workspaces,
    required this.projects,
    required this.selectedWorkspaceId,
  });

  final List<WorkspaceSummary> workspaces;
  final List<ProjectSummary> projects;
  final String selectedWorkspaceId;

  WorkspaceSummary get selectedWorkspace => workspaces.firstWhere(
    (workspace) => workspace.id == selectedWorkspaceId,
    orElse: () => workspaces.first,
  );

  ProjectState copyWith({
    List<WorkspaceSummary>? workspaces,
    List<ProjectSummary>? projects,
    String? selectedWorkspaceId,
  }) {
    return ProjectState(
      workspaces: workspaces ?? this.workspaces,
      projects: projects ?? this.projects,
      selectedWorkspaceId: selectedWorkspaceId ?? this.selectedWorkspaceId,
    );
  }
}

class ProjectController extends StateNotifier<ProjectState> {
  ProjectController()
    : super(
        ProjectState(
          workspaces: seedWorkspaces(),
          projects: seedProjects(),
          selectedWorkspaceId: seedWorkspaces().first.id,
        ),
      );

  void selectWorkspace(String workspaceId) {
    state = state.copyWith(selectedWorkspaceId: workspaceId);
  }

  CreateProjectResult? createProject(String goal) {
    final normalizedGoal = goal.trim();
    if (normalizedGoal.isEmpty) {
      return null;
    }

    final existing = state.projects
        .where((project) {
          return project.workspaceId == state.selectedWorkspaceId &&
              project.goal.toLowerCase() == normalizedGoal.toLowerCase() &&
              project.status == ProjectStatus.running;
        })
        .cast<ProjectSummary?>()
        .fold<ProjectSummary?>(
          null,
          (previous, project) => previous ?? project,
        );

    if (existing != null) {
      return CreateProjectResult(projectId: existing.id, reusedExisting: true);
    }

    final timestamp = DateTime.now();
    final projectId = 'project-${timestamp.microsecondsSinceEpoch}';
    final name = _deriveProjectName(normalizedGoal);
    final steps = [
      for (var index = 0; index < agentCatalog.length; index += 1)
        WorkflowStep(
          id: '$projectId-step-$index',
          title: _stepTitle(agentCatalog[index].id),
          agentName: agentCatalog[index].name,
          summary: agentCatalog[index].role,
          status: index == 0
              ? StepStatus.completed
              : index == 1
              ? StepStatus.running
              : StepStatus.pending,
          outputs: agentCatalog[index].deliverables,
        ),
    ];

    final artifacts = [
      ArtifactRecord(
        id: '$projectId-prd',
        title: 'PRD draft',
        type: 'document',
        status: ArtifactStatus.partial,
        summary: 'Initial scope generated from the submitted goal.',
        content:
            '''
## Draft PRD

Goal: $normalizedGoal

- Scope is in progress
- User flow is being expanded
- Downstream schema and UI tasks are queued
''',
        updatedAt: timestamp,
      ),
    ];

    final nextProject = ProjectSummary(
      id: projectId,
      workspaceId: state.selectedWorkspaceId,
      name: name,
      goal: normalizedGoal,
      status: ProjectStatus.running,
      createdAt: timestamp,
      executionPlan: const [
        'Validate goal input and workspace context.',
        'Generate PM, schema, UI, and QA artifacts.',
        'Package artifacts for review once QA completes.',
      ],
      steps: steps,
      artifacts: artifacts,
      executionLog: [
        '${_formatTime(timestamp)} Orchestrator accepted the goal.',
        '${_formatTime(timestamp)} PM Agent started the PRD draft.',
      ],
    );

    state = state.copyWith(projects: [nextProject, ...state.projects]);

    return CreateProjectResult(projectId: projectId, reusedExisting: false);
  }

  ProjectSummary? projectById(String projectId) {
    for (final project in state.projects) {
      if (project.id == projectId) {
        return project;
      }
    }
    return null;
  }

  ArtifactRecord? artifactById(String projectId, String artifactId) {
    final project = projectById(projectId);
    if (project == null) {
      return null;
    }

    for (final artifact in project.artifacts) {
      if (artifact.id == artifactId) {
        return artifact;
      }
    }
    return null;
  }

  static String _deriveProjectName(String goal) {
    final trimmed = goal.trim();
    if (trimmed.length <= 32) {
      return trimmed;
    }
    return '${trimmed.substring(0, 29)}...';
  }

  static String _stepTitle(String agentId) {
    switch (agentId) {
      case 'orchestrator':
        return 'Plan workflow';
      case 'pm':
        return 'Define product scope';
      case 'system':
        return 'Design backend model';
      case 'flutter':
        return 'Build Flutter shell';
      case 'qa':
        return 'Validate edge cases';
      default:
        return 'Execute task';
    }
  }

  static String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

final projectControllerProvider =
    StateNotifierProvider<ProjectController, ProjectState>(
      (ref) => ProjectController(),
    );

final projectByIdProvider = Provider.family<ProjectSummary?, String>(
  (ref, projectId) =>
      ref.watch(projectControllerProvider.notifier).projectById(projectId),
);

final artifactByIdProvider =
    Provider.family<ArtifactRecord?, ({String projectId, String artifactId})>(
      (ref, params) => ref
          .watch(projectControllerProvider.notifier)
          .artifactById(params.projectId, params.artifactId),
    );
