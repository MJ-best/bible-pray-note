import '../models/app_models.dart';

List<WorkspaceSummary> seedWorkspaces() {
  return const <WorkspaceSummary>[
    WorkspaceSummary(
      id: 'workspace-core',
      name: 'Core Studio',
      membersCount: 4,
      activeProjects: 2,
    ),
    WorkspaceSummary(
      id: 'workspace-labs',
      name: 'Labs',
      membersCount: 2,
      activeProjects: 1,
    ),
  ];
}

List<ProjectSummary> seedProjects() {
  return <ProjectSummary>[
    ProjectSummary(
      id: 'project-alpha',
      workspaceId: 'workspace-core',
      name: 'Agent Workspace MVP',
      goal:
          'Create a workflow-first platform that coordinates orchestrator, PM, system designer, Flutter, and QA agents.',
      status: ProjectStatus.running,
      createdAt: DateTime(2026, 3, 20, 9, 0),
      executionPlan: const [
        'Validate project goal and workspace context.',
        'Generate PRD, schema, UI, and QA artifacts in sequence.',
        'Surface gaps before packaging outputs for review.',
      ],
      steps: const [
        WorkflowStep(
          id: 'step-1',
          title: 'Plan workflow',
          agentName: 'Orchestrator Agent',
          summary: 'Break the goal into sequenced execution stages.',
          status: StepStatus.completed,
          outputs: ['Execution plan', 'Task queue'],
        ),
        WorkflowStep(
          id: 'step-2',
          title: 'Define product scope',
          agentName: 'PM Agent',
          summary: 'Draft MVP scope, actors, user flow, and feature list.',
          status: StepStatus.completed,
          outputs: ['PRD', 'Feature list', 'User flow'],
        ),
        WorkflowStep(
          id: 'step-3',
          title: 'Design backend model',
          agentName: 'System Designer Agent',
          summary: 'Create Supabase schema, relationships, and RLS.',
          status: StepStatus.running,
          outputs: ['Schema draft', 'RLS checklist'],
        ),
        WorkflowStep(
          id: 'step-4',
          title: 'Build Flutter shell',
          agentName: 'Flutter Agent',
          summary: 'Prepare route map, screens, and responsive layout.',
          status: StepStatus.pending,
          outputs: ['UI map', 'Code skeleton'],
        ),
        WorkflowStep(
          id: 'step-5',
          title: 'Validate edge cases',
          agentName: 'QA Agent',
          summary: 'Review gaps, duplicate runs, and partial artifacts.',
          status: StepStatus.pending,
          outputs: ['QA matrix'],
        ),
      ],
      artifacts: [
        ArtifactRecord(
          id: 'artifact-prd',
          title: 'PRD',
          type: 'document',
          status: ArtifactStatus.ready,
          summary: 'Goal, personas, scope, and workflow expectations.',
          content: '''
## Product Requirement Document

- Goal: multi-agent artifact generation for product teams
- Primary flow: goal input -> orchestrator plan -> agent execution -> artifacts
- Success metrics: time to first artifact, workflow clarity, review completeness
''',
          updatedAt: DateTime(2026, 3, 20, 9, 25),
        ),
        ArtifactRecord(
          id: 'artifact-flow',
          title: 'Execution Plan',
          type: 'document',
          status: ArtifactStatus.ready,
          summary: 'Output order, execution stages, and repair loop policy.',
          content: '''
## Workflow execution

1. Project structure
2. Supabase schema
3. Flutter skeleton
4. Agent definitions
5. Example workflow
6. RLS policies
7. Minimal working UI
''',
          updatedAt: DateTime(2026, 3, 20, 9, 12),
        ),
        ArtifactRecord(
          id: 'artifact-schema',
          title: 'Supabase Schema',
          type: 'sql',
          status: ArtifactStatus.partial,
          summary: 'Draft schema exists; RLS still under review.',
          content: '''
create table projects (...);
create table tasks (...);
create table artifacts (...);

-- TODO: tighten workspace membership checks in RLS
''',
          updatedAt: DateTime(2026, 3, 20, 9, 40),
        ),
        ArtifactRecord(
          id: 'artifact-ui',
          title: 'Flutter Skeleton',
          type: 'code',
          status: ArtifactStatus.partial,
          summary:
              'Routes, dashboard shell, workflow view, and artifact viewer.',
          content: '''
lib/
  core/
  features/auth
  features/workspace
  features/projects
  features/artifacts
  features/settings
''',
          updatedAt: DateTime(2026, 3, 20, 9, 46),
        ),
        ArtifactRecord(
          id: 'artifact-qa',
          title: 'QA Report',
          type: 'report',
          status: ArtifactStatus.partial,
          summary:
              'Empty goal, OAuth failure, duplicate execution, and partial artifact cases remain visible.',
          content: '''
## QA checklist

- empty project_goal
- user not logged in
- duplicate running task
- partial artifact preservation
- RLS permission denial
''',
          updatedAt: DateTime(2026, 3, 20, 9, 51),
        ),
      ],
      executionLog: const [
        '09:01 Orchestrator accepted the project goal.',
        '09:07 PM Agent completed PRD and feature list.',
        '09:18 System Designer Agent started schema and policy draft.',
        '09:27 Flutter Agent prepared the shell and artifact viewer.',
        '09:31 Artifact generation is partial; QA gate is still pending.',
      ],
    ),
  ];
}
