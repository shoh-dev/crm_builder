-- Adds a jsonb column to store the canvas layout / props
alter table public.projects
  add column if not exists layout jsonb default '{}'::jsonb;
