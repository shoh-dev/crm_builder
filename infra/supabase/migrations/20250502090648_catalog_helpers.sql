-- list_tables(): returns all tables in the public schema
create or replace function public.list_tables()
returns table (table_name text)
language sql
stable
security definer
as $$
  select tablename
  from pg_catalog.pg_tables
  where schemaname = 'public'
  order by tablename;
$$;

-- list_columns(p_table): columns for a given table
create or replace function public.list_columns(p_table text)
returns table (column_name text)
language sql
stable
security definer
as $$
  select column_name
  from information_schema.columns
  where table_schema = 'public'
    and table_name   = p_table
  order by ordinal_position;
$$;
