# Flutter Web-First Project Structure

```text
lib/
  core/
    config/
      app_router.dart
      route_paths.dart
      supabase_client.dart
    layout/
      app_shell.dart
      responsive_scaffold.dart
    theme/
      app_theme.dart
    widgets/
      app_error_view.dart
      app_loading_view.dart

  features/
    auth/
      data/
      domain/
      presentation/
        auth_controller.dart
        auth_guard.dart
        login_screen.dart
    workspace/
      data/
      domain/
      presentation/
        workspace_controller.dart
        workspace_list_screen.dart
    projects/
      data/
      domain/
      presentation/
        project_controller.dart
        project_list_screen.dart
        project_detail_screen.dart
    agents/
      data/
      domain/
      presentation/
        agent_controller.dart
        agent_pipeline_view.dart
        agent_timeline_view.dart
    artifacts/
      data/
      domain/
      presentation/
        artifact_controller.dart
        artifact_viewer_screen.dart
    settings/
      presentation/
        settings_screen.dart

  shared/
    constants/
    models/
    utils/

  main.dart
```

## Routes

- `/login`
- `/dashboard`
- `/workspaces`
- `/projects`
- `/projects/:id`
- `/projects/:id/artifacts/:artifactId`
- `/settings`

## Riverpod Providers

- `supabaseClientProvider`
- `authStateProvider`
- `currentUserProvider`
- `workspaceListProvider`
- `selectedWorkspaceProvider`
- `projectListProvider`
- `selectedProjectProvider`
- `agentPipelineProvider`
- `artifactListProvider`
- `settingsProvider`

## Router Rules

- unauthenticated user -> `/login`
- authenticated user on `/login` -> `/dashboard`
- authenticated user without selected workspace -> `/workspaces`
- inaccessible project route -> `/projects`

## Responsive Layout

- mobile: stacked workflow with bottom navigation or compact shell
- tablet: split view for project list and project detail
- desktop: side rail + main pipeline + artifact panel

## UI Principle

- workflow-first, never chat-first
- goal input starts the run
- project detail is the primary execution workspace
- artifacts render as typed results, not generic messages
