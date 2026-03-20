# Multi-Agent Vibe Coding MVP Blueprint

This blueprint configures a reusable five-agent pack for a Flutter + Supabase MVP that turns a single `project_goal` into structured artifacts.

## Included

- `agent_definitions.json`
  - canonical agent registry, dependencies, input keys, output keys, and boundaries
- `workflow_contract.json`
  - shared execution stages, status model, and artifact handoff contract
- `artifact_schemas.json`
  - structured output shapes for PRD, schema, Flutter, and QA artifacts
- `prompts/`
  - role-specific prompts for orchestrator, PM, system designer, Flutter, and QA
- `flutter_project_structure.md`
  - recommended Flutter web-first folder structure, routes, and state layout
- `example_workflow.json`
  - example execution from goal input to artifact generation
- [`supabase/migrations/20260320224500_multi_agent_vibe_mvp.sql`](/Users/mj/Documents/bible-pray-note/supabase/migrations/20260320224500_multi_agent_vibe_mvp.sql)
  - production-oriented MVP schema and RLS foundation

## Agent Set

1. `orchestrator`
2. `pm`
3. `system_designer`
4. `flutter`
5. `qa`

## Design Principles

- Workflow-first, not chat-first
- Clear ownership boundaries between agents
- Structured outputs only
- One repair loop per failed artifact owner
- Default-deny data access with workspace-scoped RLS

## Expected Top-Level Output Order

The orchestrator prompt enforces this exact final order:

1. Project structure (folders/files)
2. Supabase schema (SQL)
3. Flutter app skeleton code
4. Agent definitions (JSON or config)
5. Example workflow execution
6. RLS policies
7. Minimal working UI (Flutter code)

## Usage

- Treat this folder as the prompt pack for a future orchestrator or manual multi-step execution.
- Keep the current app code separate; this blueprint is a new product direction, not a mutation of the existing Bible note app.
- Use `workflow_contract.json` as the shared source of truth for agent handoffs and failure handling.
- Use `artifact_schemas.json` to keep outputs machine-readable and stable across runs.
