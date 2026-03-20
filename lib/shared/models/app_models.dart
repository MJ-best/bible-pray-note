import 'package:flutter/material.dart';

class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class WorkspaceSummary {
  const WorkspaceSummary({
    required this.id,
    required this.name,
    required this.membersCount,
    required this.activeProjects,
  });

  final String id;
  final String name;
  final int membersCount;
  final int activeProjects;
}

class AgentDefinition {
  const AgentDefinition({
    required this.id,
    required this.name,
    required this.role,
    required this.deliverables,
  });

  final String id;
  final String name;
  final String role;
  final List<String> deliverables;
}

enum ProjectStatus { draft, running, completed, failed }

extension ProjectStatusX on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.running:
        return 'Running';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.failed:
        return 'Failed';
    }
  }

  Color color(ColorScheme scheme) {
    switch (this) {
      case ProjectStatus.draft:
        return scheme.outline;
      case ProjectStatus.running:
        return scheme.tertiary;
      case ProjectStatus.completed:
        return scheme.primary;
      case ProjectStatus.failed:
        return scheme.error;
    }
  }
}

enum StepStatus { pending, running, completed, failed }

extension StepStatusX on StepStatus {
  String get label {
    switch (this) {
      case StepStatus.pending:
        return 'Pending';
      case StepStatus.running:
        return 'Running';
      case StepStatus.completed:
        return 'Completed';
      case StepStatus.failed:
        return 'Failed';
    }
  }

  IconData get icon {
    switch (this) {
      case StepStatus.pending:
        return Icons.schedule;
      case StepStatus.running:
        return Icons.autorenew;
      case StepStatus.completed:
        return Icons.check_circle;
      case StepStatus.failed:
        return Icons.error;
    }
  }
}

class WorkflowStep {
  const WorkflowStep({
    required this.id,
    required this.title,
    required this.agentName,
    required this.summary,
    required this.status,
    required this.outputs,
  });

  final String id;
  final String title;
  final String agentName;
  final String summary;
  final StepStatus status;
  final List<String> outputs;
}

enum ArtifactStatus { ready, partial, failed }

extension ArtifactStatusX on ArtifactStatus {
  String get label {
    switch (this) {
      case ArtifactStatus.ready:
        return 'Ready';
      case ArtifactStatus.partial:
        return 'Partial';
      case ArtifactStatus.failed:
        return 'Failed';
    }
  }
}

class ArtifactRecord {
  const ArtifactRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.summary,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String type;
  final ArtifactStatus status;
  final String summary;
  final String content;
  final DateTime updatedAt;
}

class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.goal,
    required this.status,
    required this.createdAt,
    required this.executionPlan,
    required this.steps,
    required this.artifacts,
    required this.executionLog,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String goal;
  final ProjectStatus status;
  final DateTime createdAt;
  final List<String> executionPlan;
  final List<WorkflowStep> steps;
  final List<ArtifactRecord> artifacts;
  final List<String> executionLog;
}
