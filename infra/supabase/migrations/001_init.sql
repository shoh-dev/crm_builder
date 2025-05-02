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

-- Form test data table
create table public.form_test_data (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references public.projects(id) on delete cascade,
  text_field text,
  long_text text,
  number_field integer,
  decimal_field decimal(10,2),
  boolean_field boolean default false,
  date_field date,
  time_field time,
  timestamp_field timestamp with time zone,
  email_field text check (email_field ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  phone_field text,
  select_field text check (select_field in ('OPTION1', 'OPTION2', 'OPTION3')),
  json_field jsonb,
  array_field text[],
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- RLS
alter table public.workspaces      enable row level security;
alter table public.workspace_members enable row level security;
alter table public.projects        enable row level security;
alter table public.export_tickets  enable row level security;
alter table public.form_test_data  enable row level security;

create policy "workspace owner can CRUD" on public.workspaces
  using ( auth.uid() = owner_id );

create policy "members can read" on public.workspace_members
  for select using ( auth.uid() = user_id );

create policy "workspace members can CRUD projects" on public.projects
  using ( auth.uid() in (select user_id from public.workspace_members where workspace_id = projects.workspace_id) );

create policy "members can CRUD their export tickets" on public.export_tickets
  using ( auth.uid() in (select user_id from public.workspace_members where workspace_id =
    (select workspace_id from public.projects where id = export_tickets.project_id)) );

create policy "members can CRUD their form test data" on public.form_test_data
  using ( auth.uid() in (select user_id from public.workspace_members where workspace_id =
    (select workspace_id from public.projects where id = form_test_data.project_id)) );
