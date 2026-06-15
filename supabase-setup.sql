-- HighPro Estoque - Supabase setup
-- Run this once in Supabase > SQL Editor > New query.
-- After running it, create the allowed login in Authentication > Users.
-- Keep public signups disabled if this system should be private.

create table if not exists public.stock_data (
  stock_id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

alter table public.stock_data enable row level security;

drop policy if exists "stock_data_select_authenticated" on public.stock_data;
drop policy if exists "stock_data_insert_authenticated" on public.stock_data;
drop policy if exists "stock_data_update_authenticated" on public.stock_data;
drop policy if exists "stock_data_delete_authenticated" on public.stock_data;

create policy "stock_data_select_authenticated"
on public.stock_data
for select
to authenticated
using (true);

create policy "stock_data_insert_authenticated"
on public.stock_data
for insert
to authenticated
with check (true);

create policy "stock_data_update_authenticated"
on public.stock_data
for update
to authenticated
using (true)
with check (true);

create policy "stock_data_delete_authenticated"
on public.stock_data
for delete
to authenticated
using (true);

create or replace function public.set_stock_data_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at = now();
  if new.updated_by is null then
    new.updated_by = auth.uid();
  end if;
  return new;
end;
$$;

drop trigger if exists set_stock_data_updated_at on public.stock_data;

create trigger set_stock_data_updated_at
before insert or update on public.stock_data
for each row
execute function public.set_stock_data_updated_at();
