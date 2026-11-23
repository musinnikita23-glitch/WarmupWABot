-- Выполни этот SQL в Supabase → SQL Editor → New query → Run
create table if not exists public.phone_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  phone text not null,
  is_banned boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.phone_records enable row level security;

drop policy if exists "Users can read own phone records" on public.phone_records;
create policy "Users can read own phone records"
on public.phone_records for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can add own phone records" on public.phone_records;
create policy "Users can add own phone records"
on public.phone_records for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own phone records" on public.phone_records;
create policy "Users can update own phone records"
on public.phone_records for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete own phone records" on public.phone_records;
create policy "Users can delete own phone records"
on public.phone_records for delete
to authenticated
using (auth.uid() = user_id);

-- Включить realtime-обновления для таблицы (если ещё не включены)
do $$
begin
  alter publication supabase_realtime add table public.phone_records;
exception when duplicate_object then
  null;
when undefined_object then
  raise notice 'Publication supabase_realtime не найдена — включи Realtime для phone_records в Dashboard → Database → Publications.';
end $$;
