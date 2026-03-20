create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    email,
    display_name,
    avatar_url
  )
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.email),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update
  set
    email = excluded.email,
    display_name = excluded.display_name,
    avatar_url = excluded.avatar_url,
    updated_at = timezone('utc', now());

  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  avatar_url text,
  role text not null default 'member' check (role in ('member', 'admin')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  slug text not null,
  plan text not null default 'free',
  settings_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (slug),
  unique (id, owner_user_id)
);

create table if not exists public.workspace_members (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'admin', 'member')),
  status text not null default 'active' check (status in ('invited', 'active', 'suspended')),
  invited_by_user_id uuid references public.profiles(id) on delete set null,
  joined_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  unique (workspace_id, user_id)
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  created_by_user_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  slug text not null,
  project_goal text not null,
  status text not null default 'draft' check (status in ('draft', 'planned', 'running', 'completed', 'failed', 'archived')),
  execution_plan_json jsonb not null default '{}'::jsonb,
  meta_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (workspace_id, slug)
);

create table if not exists public.agents (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  created_by_user_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  agent_key text not null,
  role text not null check (role in ('orchestrator', 'pm', 'system_designer', 'flutter', 'qa')),
  model text not null,
  system_prompt text not null,
  status text not null default 'active' check (status in ('active', 'inactive', 'archived')),
  settings_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (workspace_id, agent_key)
);

create table if not exists public.agent_skills (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  agent_id uuid not null references public.agents(id) on delete cascade,
  skill_key text not null,
  skill_name text not null,
  description text not null default '',
  input_schema_json jsonb not null default '{}'::jsonb,
  output_schema_json jsonb not null default '{}'::jsonb,
  enabled boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (agent_id, skill_key)
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  started_by_user_id uuid not null references public.profiles(id) on delete restrict,
  orchestrator_agent_id uuid references public.agents(id) on delete set null,
  title text not null,
  goal_snapshot text not null,
  status text not null default 'running' check (status in ('running', 'blocked', 'completed', 'failed', 'closed')),
  context_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  closed_at timestamptz
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_type text not null check (sender_type in ('user', 'agent', 'system')),
  sender_user_id uuid references public.profiles(id) on delete set null,
  sender_agent_id uuid references public.agents(id) on delete set null,
  role text not null check (role in ('input', 'plan', 'artifact', 'review', 'system')),
  sequence_no integer not null,
  parent_message_id uuid references public.messages(id) on delete set null,
  content_text text not null default '',
  content_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  unique (conversation_id, sequence_no),
  constraint messages_sender_owner_check check (
    (sender_type = 'user' and sender_user_id is not null) or
    (sender_type = 'agent' and sender_agent_id is not null) or
    (sender_type = 'system')
  )
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  created_by_user_id uuid not null references public.profiles(id) on delete restrict,
  assigned_agent_id uuid references public.agents(id) on delete set null,
  parent_task_id uuid references public.tasks(id) on delete set null,
  task_type text not null,
  title text not null,
  status text not null default 'pending' check (status in ('pending', 'running', 'succeeded', 'failed', 'blocked', 'canceled')),
  priority integer not null default 0,
  input_json jsonb not null default '{}'::jsonb,
  output_json jsonb not null default '{}'::jsonb,
  idempotency_key text not null,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (project_id, idempotency_key)
);

create table if not exists public.artifacts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  task_id uuid not null references public.tasks(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  created_by_user_id uuid not null references public.profiles(id) on delete restrict,
  created_by_agent_id uuid references public.agents(id) on delete set null,
  artifact_type text not null,
  title text not null,
  version integer not null default 1,
  format text not null,
  content_text text not null default '',
  content_json jsonb not null default '{}'::jsonb,
  storage_path text,
  checksum text not null default '',
  is_latest boolean not null default true,
  status text not null default 'ready' check (status in ('ready', 'partial', 'failed', 'superseded')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (task_id, artifact_type, version)
);

create unique index if not exists artifacts_latest_per_type_idx
on public.artifacts (task_id, artifact_type)
where is_latest = true;

create table if not exists public.tool_runs (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  task_id uuid not null references public.tasks(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  agent_id uuid not null references public.agents(id) on delete restrict,
  tool_name text not null,
  status text not null default 'pending' check (status in ('pending', 'running', 'succeeded', 'failed', 'canceled')),
  input_json jsonb not null default '{}'::jsonb,
  output_json jsonb not null default '{}'::jsonb,
  error_text text,
  attempt_no integer not null default 1,
  idempotency_key text not null,
  started_at timestamptz,
  finished_at timestamptz,
  duration_ms integer,
  created_at timestamptz not null default timezone('utc', now()),
  unique (task_id, tool_name, idempotency_key)
);

create index if not exists projects_workspace_id_idx
on public.projects (workspace_id);

create index if not exists conversations_project_id_idx
on public.conversations (project_id);

create index if not exists tasks_project_status_idx
on public.tasks (project_id, status);

create index if not exists artifacts_project_type_idx
on public.artifacts (project_id, artifact_type, is_latest);

create index if not exists tool_runs_task_idx
on public.tool_runs (task_id, status);

create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger set_workspaces_updated_at
before update on public.workspaces
for each row execute function public.set_updated_at();

create trigger set_projects_updated_at
before update on public.projects
for each row execute function public.set_updated_at();

create trigger set_agents_updated_at
before update on public.agents
for each row execute function public.set_updated_at();

create trigger set_agent_skills_updated_at
before update on public.agent_skills
for each row execute function public.set_updated_at();

create trigger set_conversations_updated_at
before update on public.conversations
for each row execute function public.set_updated_at();

create trigger set_tasks_updated_at
before update on public.tasks
for each row execute function public.set_updated_at();

create trigger set_artifacts_updated_at
before update on public.artifacts
for each row execute function public.set_updated_at();

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_workspace_member(target_workspace_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspaces w
    where w.id = target_workspace_id
      and w.owner_user_id = auth.uid()
  )
  or exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = target_workspace_id
      and wm.user_id = auth.uid()
      and wm.status = 'active'
  );
$$;

create or replace function public.is_workspace_admin(target_workspace_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspaces w
    where w.id = target_workspace_id
      and w.owner_user_id = auth.uid()
  )
  or exists (
    select 1
    from public.workspace_members wm
    where wm.workspace_id = target_workspace_id
      and wm.user_id = auth.uid()
      and wm.status = 'active'
      and wm.role in ('owner', 'admin')
  );
$$;

alter table public.profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.projects enable row level security;
alter table public.agents enable row level security;
alter table public.agent_skills enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.tasks enable row level security;
alter table public.artifacts enable row level security;
alter table public.tool_runs enable row level security;

create policy "profiles_select_self"
on public.profiles
for select
using (id = auth.uid());

create policy "profiles_insert_self"
on public.profiles
for insert
with check (id = auth.uid());

create policy "profiles_update_self"
on public.profiles
for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "workspaces_select_members"
on public.workspaces
for select
using (public.is_workspace_member(id));

create policy "workspaces_insert_owner"
on public.workspaces
for insert
with check (owner_user_id = auth.uid());

create policy "workspaces_update_owner"
on public.workspaces
for update
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

create policy "workspaces_delete_owner"
on public.workspaces
for delete
using (owner_user_id = auth.uid());

create policy "workspace_members_select_members"
on public.workspace_members
for select
using (
  user_id = auth.uid()
  or public.is_workspace_member(workspace_id)
);

create policy "workspace_members_manage_admins"
on public.workspace_members
for all
using (public.is_workspace_admin(workspace_id))
with check (public.is_workspace_admin(workspace_id));

create policy "projects_select_members"
on public.projects
for select
using (public.is_workspace_member(workspace_id));

create policy "projects_insert_members"
on public.projects
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "projects_update_owner_or_admin"
on public.projects
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_admin(workspace_id)
)
with check (public.is_workspace_member(workspace_id));

create policy "projects_delete_owner_or_admin"
on public.projects
for delete
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_admin(workspace_id)
);

create policy "agents_select_members"
on public.agents
for select
using (public.is_workspace_member(workspace_id));

create policy "agents_insert_admins"
on public.agents
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_admin(workspace_id)
);

create policy "agents_update_admins"
on public.agents
for update
using (public.is_workspace_admin(workspace_id))
with check (public.is_workspace_admin(workspace_id));

create policy "agents_delete_admins"
on public.agents
for delete
using (public.is_workspace_admin(workspace_id));

create policy "agent_skills_select_members"
on public.agent_skills
for select
using (public.is_workspace_member(workspace_id));

create policy "agent_skills_manage_admins"
on public.agent_skills
for all
using (public.is_workspace_admin(workspace_id))
with check (public.is_workspace_admin(workspace_id));

create policy "conversations_select_members"
on public.conversations
for select
using (public.is_workspace_member(workspace_id));

create policy "conversations_insert_members"
on public.conversations
for insert
with check (
  started_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "conversations_update_owner_or_admin"
on public.conversations
for update
using (
  started_by_user_id = auth.uid()
  or public.is_workspace_admin(workspace_id)
)
with check (public.is_workspace_member(workspace_id));

create policy "messages_select_members"
on public.messages
for select
using (public.is_workspace_member(workspace_id));

create policy "messages_insert_user_messages"
on public.messages
for insert
with check (
  public.is_workspace_member(workspace_id)
  and sender_type = 'user'
  and sender_user_id = auth.uid()
);

create policy "messages_update_admins_only"
on public.messages
for update
using (public.is_workspace_admin(workspace_id))
with check (public.is_workspace_admin(workspace_id));

create policy "tasks_select_members"
on public.tasks
for select
using (public.is_workspace_member(workspace_id));

create policy "tasks_insert_members"
on public.tasks
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "tasks_update_owner_or_admin"
on public.tasks
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_admin(workspace_id)
)
with check (public.is_workspace_member(workspace_id));

create policy "artifacts_select_members"
on public.artifacts
for select
using (public.is_workspace_member(workspace_id));

create policy "artifacts_insert_members"
on public.artifacts
for insert
with check (
  created_by_user_id = auth.uid()
  and public.is_workspace_member(workspace_id)
);

create policy "artifacts_update_owner_or_admin"
on public.artifacts
for update
using (
  created_by_user_id = auth.uid()
  or public.is_workspace_admin(workspace_id)
)
with check (public.is_workspace_member(workspace_id));

create policy "tool_runs_select_members"
on public.tool_runs
for select
using (public.is_workspace_member(workspace_id));
