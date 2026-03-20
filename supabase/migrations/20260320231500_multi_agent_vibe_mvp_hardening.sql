-- Hardening pass for the multi-agent MVP schema.
-- This migration is additive so it can follow the base schema safely.

create or replace function public.is_service_role()
returns boolean
language sql
stable
as $$
  select auth.role() = 'service_role';
$$;

comment on function public.is_service_role()
is 'Returns true when the request is executed with the Supabase service role.';

create or replace function public.ensure_workspace_owner_membership()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.workspace_members (
    workspace_id,
    user_id,
    role,
    status,
    invited_by_user_id,
    joined_at
  )
  values (
    new.id,
    new.owner_user_id,
    'owner',
    'active',
    new.owner_user_id,
    coalesce(new.created_at, timezone('utc', now()))
  )
  on conflict (workspace_id, user_id) do update
  set
    role = 'owner',
    status = 'active',
    joined_at = coalesce(workspace_members.joined_at, excluded.joined_at);

  return new;
end;
$$;

comment on function public.ensure_workspace_owner_membership()
is 'Keeps the canonical owner membership row aligned with workspaces.owner_user_id.';

insert into public.workspace_members (
  workspace_id,
  user_id,
  role,
  status,
  invited_by_user_id,
  joined_at
)
select
  w.id,
  w.owner_user_id,
  'owner',
  'active',
  w.owner_user_id,
  coalesce(w.created_at, timezone('utc', now()))
from public.workspaces w
on conflict (workspace_id, user_id) do update
set
  role = 'owner',
  status = 'active',
  joined_at = coalesce(workspace_members.joined_at, excluded.joined_at);

drop trigger if exists ensure_workspace_owner_membership_after_insert on public.workspaces;
create trigger ensure_workspace_owner_membership_after_insert
after insert on public.workspaces
for each row execute function public.ensure_workspace_owner_membership();

create or replace function public.sync_latest_artifact_state()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.is_latest then
    update public.artifacts
    set
      is_latest = false,
      status = case
        when status = 'ready' then 'superseded'
        else status
      end,
      updated_at = timezone('utc', now())
    where task_id = new.task_id
      and artifact_type = new.artifact_type
      and id <> new.id
      and is_latest = true;
  end if;

  return new;
end;
$$;

comment on function public.sync_latest_artifact_state()
is 'Ensures only one latest artifact exists per task and artifact_type.';

drop trigger if exists sync_latest_artifact_state_before_write on public.artifacts;
create trigger sync_latest_artifact_state_before_write
before insert or update of is_latest on public.artifacts
for each row execute function public.sync_latest_artifact_state();

create unique index if not exists projects_workspace_pair_uidx
on public.projects (workspace_id, id);

create unique index if not exists agents_workspace_pair_uidx
on public.agents (workspace_id, id);

create unique index if not exists conversations_workspace_pair_uidx
on public.conversations (workspace_id, id);

create unique index if not exists tasks_workspace_pair_uidx
on public.tasks (workspace_id, id);

create unique index if not exists tasks_workspace_project_pair_uidx
on public.tasks (workspace_id, project_id, id);

create unique index if not exists artifacts_workspace_pair_uidx
on public.artifacts (workspace_id, id);

create unique index if not exists tool_runs_workspace_pair_uidx
on public.tool_runs (workspace_id, id);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'agent_skills_workspace_agent_fk'
  ) then
    alter table public.agent_skills
      add constraint agent_skills_workspace_agent_fk
      foreign key (workspace_id, agent_id)
      references public.agents (workspace_id, id)
      on delete cascade;
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'conversations_workspace_project_fk'
  ) then
    alter table public.conversations
      add constraint conversations_workspace_project_fk
      foreign key (workspace_id, project_id)
      references public.projects (workspace_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'conversations_workspace_orchestrator_agent_fk'
  ) then
    alter table public.conversations
      add constraint conversations_workspace_orchestrator_agent_fk
      foreign key (workspace_id, orchestrator_agent_id)
      references public.agents (workspace_id, id)
      on delete set null;
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'messages_workspace_conversation_fk'
  ) then
    alter table public.messages
      add constraint messages_workspace_conversation_fk
      foreign key (workspace_id, conversation_id)
      references public.conversations (workspace_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'messages_workspace_sender_agent_fk'
  ) then
    alter table public.messages
      add constraint messages_workspace_sender_agent_fk
      foreign key (workspace_id, sender_agent_id)
      references public.agents (workspace_id, id)
      on delete set null;
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'tasks_workspace_project_fk'
  ) then
    alter table public.tasks
      add constraint tasks_workspace_project_fk
      foreign key (workspace_id, project_id)
      references public.projects (workspace_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tasks_workspace_conversation_fk'
  ) then
    alter table public.tasks
      add constraint tasks_workspace_conversation_fk
      foreign key (workspace_id, conversation_id)
      references public.conversations (workspace_id, id)
      on delete set null;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tasks_workspace_assigned_agent_fk'
  ) then
    alter table public.tasks
      add constraint tasks_workspace_assigned_agent_fk
      foreign key (workspace_id, assigned_agent_id)
      references public.agents (workspace_id, id)
      on delete set null;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tasks_workspace_parent_task_fk'
  ) then
    alter table public.tasks
      add constraint tasks_workspace_parent_task_fk
      foreign key (workspace_id, parent_task_id)
      references public.tasks (workspace_id, id)
      on delete set null;
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'artifacts_workspace_project_fk'
  ) then
    alter table public.artifacts
      add constraint artifacts_workspace_project_fk
      foreign key (workspace_id, project_id)
      references public.projects (workspace_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'artifacts_workspace_project_task_fk'
  ) then
    alter table public.artifacts
      add constraint artifacts_workspace_project_task_fk
      foreign key (workspace_id, project_id, task_id)
      references public.tasks (workspace_id, project_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'artifacts_workspace_conversation_fk'
  ) then
    alter table public.artifacts
      add constraint artifacts_workspace_conversation_fk
      foreign key (workspace_id, conversation_id)
      references public.conversations (workspace_id, id)
      on delete set null;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'artifacts_workspace_created_by_agent_fk'
  ) then
    alter table public.artifacts
      add constraint artifacts_workspace_created_by_agent_fk
      foreign key (workspace_id, created_by_agent_id)
      references public.agents (workspace_id, id)
      on delete set null;
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'tool_runs_workspace_project_fk'
  ) then
    alter table public.tool_runs
      add constraint tool_runs_workspace_project_fk
      foreign key (workspace_id, project_id)
      references public.projects (workspace_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tool_runs_workspace_project_task_fk'
  ) then
    alter table public.tool_runs
      add constraint tool_runs_workspace_project_task_fk
      foreign key (workspace_id, project_id, task_id)
      references public.tasks (workspace_id, project_id, id)
      on delete cascade;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tool_runs_workspace_conversation_fk'
  ) then
    alter table public.tool_runs
      add constraint tool_runs_workspace_conversation_fk
      foreign key (workspace_id, conversation_id)
      references public.conversations (workspace_id, id)
      on delete set null;
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tool_runs_workspace_agent_fk'
  ) then
    alter table public.tool_runs
      add constraint tool_runs_workspace_agent_fk
      foreign key (workspace_id, agent_id)
      references public.agents (workspace_id, id)
      on delete restrict;
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'workspaces_slug_format_check'
  ) then
    alter table public.workspaces
      add constraint workspaces_slug_format_check
      check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$');
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'projects_slug_format_check'
  ) then
    alter table public.projects
      add constraint projects_slug_format_check
      check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$');
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'projects_goal_not_blank_check'
  ) then
    alter table public.projects
      add constraint projects_goal_not_blank_check
      check (length(btrim(project_goal)) > 0);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'messages_sequence_positive_check'
  ) then
    alter table public.messages
      add constraint messages_sequence_positive_check
      check (sequence_no > 0);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'artifacts_version_positive_check'
  ) then
    alter table public.artifacts
      add constraint artifacts_version_positive_check
      check (version > 0);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'tool_runs_attempt_positive_check'
  ) then
    alter table public.tool_runs
      add constraint tool_runs_attempt_positive_check
      check (attempt_no > 0);
  end if;
end
$$;

comment on table public.workspace_members
is 'Workspace membership roster used for authorization and auditability.';

comment on table public.projects
is 'Goal-scoped execution containers owned by a workspace.';

comment on table public.tasks
is 'Discrete agent jobs within a project pipeline. idempotency_key prevents duplicate execution.';

comment on table public.artifacts
is 'Versioned outputs generated by agents such as PRD, schema, UI, code, or QA reports.';

comment on table public.tool_runs
is 'Low-level execution log for tools invoked by agents while completing a task.';

comment on column public.tasks.idempotency_key
is 'Caller-provided key used to collapse duplicate task submissions within a project.';

comment on column public.tool_runs.idempotency_key
is 'Caller-provided key used to collapse duplicate tool runs within a task and tool namespace.';

comment on column public.artifacts.storage_path
is 'Supabase Storage object path inside bucket artifacts. Convention: <workspace_id>/<project_id>/<artifact_id>/<filename>.';

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'artifacts',
  'artifacts',
  false,
  10485760,
  array[
    'application/json',
    'application/pdf',
    'image/jpeg',
    'image/png',
    'text/markdown',
    'text/plain'
  ]::text[]
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create or replace function public.storage_workspace_id(object_name text)
returns uuid
language sql
immutable
as $$
  select case
    when coalesce((storage.foldername(object_name))[1], '') ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      then ((storage.foldername(object_name))[1])::uuid
    else null
  end;
$$;

comment on function public.storage_workspace_id(text)
is 'Parses the leading workspace UUID from a storage object path.';

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'artifact_objects_select_members'
  ) then
    create policy "artifact_objects_select_members"
    on storage.objects
    for select
    to authenticated
    using (
      bucket_id = 'artifacts'
      and public.is_workspace_member(public.storage_workspace_id(name))
    );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'artifact_objects_insert_admins'
  ) then
    create policy "artifact_objects_insert_admins"
    on storage.objects
    for insert
    to authenticated
    with check (
      bucket_id = 'artifacts'
      and public.is_workspace_admin(public.storage_workspace_id(name))
    );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'artifact_objects_update_admins'
  ) then
    create policy "artifact_objects_update_admins"
    on storage.objects
    for update
    to authenticated
    using (
      bucket_id = 'artifacts'
      and public.is_workspace_admin(public.storage_workspace_id(name))
    )
    with check (
      bucket_id = 'artifacts'
      and public.is_workspace_admin(public.storage_workspace_id(name))
    );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'artifact_objects_delete_admins'
  ) then
    create policy "artifact_objects_delete_admins"
    on storage.objects
    for delete
    to authenticated
    using (
      bucket_id = 'artifacts'
      and public.is_workspace_admin(public.storage_workspace_id(name))
    );
  end if;
end
$$;
