-- Workspaces (one per team / company)
create table public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid references auth.users(id) default auth.uid(),
  created_at timestamp without time zone default now()
);

-- Members (many‑to‑many)
create table public.workspace_members (
  user_id uuid references auth.users(id) on delete cascade,
  workspace_id uuid references public.workspaces(id) on delete cascade,
  role text default 'admin',
  primary key (user_id, workspace_id)
);

-- Projects
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid references public.workspaces(id) on delete cascade,
  name text not null,
  description text,
  created_at timestamp default now()
);

-- Export tickets (code‑gen jobs)
create table public.export_tickets (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references public.projects(id) on delete cascade,
  type text check (type in ('WEB','FLUTTER')) not null,
  status text check (status in ('PENDING','COMPLETE','ERROR')) default 'PENDING',
  bundle_path text,
  created_at timestamp default now()
);

-- RLS
alter table public.workspaces      enable row level security;
alter table public.workspace_members enable row level security;
alter table public.projects        enable row level security;
alter table public.export_tickets  enable row level security;

create policy "workspace owner can CRUD" on public.workspaces
  using ( auth.uid() = owner_id );

create policy "members can read" on public.workspace_members
  for select using ( auth.uid() = user_id );

create policy "workspace members can CRUD projects" on public.projects
  using ( auth.uid() in (select user_id from public.workspace_members where workspace_id = projects.workspace_id) );

create policy "members can CRUD their export tickets" on public.export_tickets
  using ( auth.uid() in (select user_id from public.workspace_members where workspace_id =
    (select workspace_id from public.projects where id = export_tickets.project_id)) );
