-- Disables RLS ONLY in local dev; do not push this to prod
alter table public.workspaces       disable row level security;
alter table public.projects         disable row level security;
alter table public.form_test_data   disable row level security;
