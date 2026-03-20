# Supabase MVP Notes

This directory contains the database and storage setup for the multi-agent vibe coding MVP.

## Migrations

- `migrations/20260320224500_multi_agent_vibe_mvp.sql`
  - Base schema for auth-linked profiles, workspaces, projects, agents, execution logs, artifacts, and RLS.
- `migrations/20260320231500_multi_agent_vibe_mvp_hardening.sql`
  - Additive hardening pass for workspace consistency, artifact version management, storage bucket policies, and operational comments.

## Data Model Boundaries

- `profiles`, `workspaces`, `workspace_members`
  - Identity and workspace authorization boundary.
- `projects`, `conversations`, `messages`
  - Goal intake plus execution context and audit trail.
- `agents`, `agent_skills`
  - Workspace-scoped agent registry and skill declarations.
- `tasks`, `artifacts`, `tool_runs`
  - Pipeline execution records, generated outputs, and tool telemetry.

## Authorization Model

- RLS is enabled on all application tables in the base migration.
- Default behavior is deny-by-default unless a policy exists.
- Authenticated users operate within workspace membership boundaries.
- Workspace owners/admins can manage shared configuration such as agents and membership.
- Service-role requests are expected for backend orchestration and can bypass RLS when needed.

## Storage Convention

- Bucket: `artifacts`
- Recommended object path:
  - `<workspace_id>/<project_id>/<artifact_id>/<filename>`
- `storage_workspace_id(name)` extracts the first folder segment and maps storage access back to workspace membership.

## Operational Assumptions

- Google OAuth and Supabase Auth provider setup happen outside these SQL files.
- Agent runners and workflow executors use the Supabase service role for task progression, tool logging, and artifact generation.
- Client apps use authenticated user context for reading workspace-scoped data and creating user-originated projects/conversations/tasks.
- Existing development data, if any, is assumed to be compatible with the added composite foreign keys.
