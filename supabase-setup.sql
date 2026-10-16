-- ANOMALYS TRADING: ejecutar en Supabase > SQL Editor.
-- Las lecturas son públicas; solo los usuarios incluidos en public.admins pueden escribir.
create extension if not exists pgcrypto;

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 100),
  category text not null default 'Otro' check (category in ('Cuchillo','Asesino','Cabaña','Otro')),
  value numeric(12,2) not null default 0 check (value >= 0),
  rarity text not null default '',
  image_url text,
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.item_history (
  id bigint generated always as identity primary key,
  item_id uuid,
  item_name text not null,
  action text not null check (action in ('INSERT','UPDATE','DELETE')),
  old_value numeric(12,2),
  new_value numeric(12,2),
  changed_at timestamptz not null default now()
);

create or replace function public.is_anomalys_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

create or replace function public.touch_item_updated_at()
returns trigger language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists items_touch_updated_at on public.items;
create trigger items_touch_updated_at before update on public.items
for each row execute function public.touch_item_updated_at();

create or replace function public.record_item_history()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  if TG_OP = 'INSERT' then
    insert into public.item_history(item_id,item_name,action,old_value,new_value)
    values (new.id,new.name,'INSERT',null,new.value);
    return new;
  elsif TG_OP = 'UPDATE' then
    if old.name is distinct from new.name or old.value is distinct from new.value or old.category is distinct from new.category then
      insert into public.item_history(item_id,item_name,action,old_value,new_value)
      values (new.id,new.name,'UPDATE',old.value,new.value);
    end if;
    return new;
  else
    insert into public.item_history(item_id,item_name,action,old_value,new_value)
    values (old.id,old.name,'DELETE',old.value,null);
    return old;
  end if;
end;
$$;

drop trigger if exists items_record_history on public.items;
create trigger items_record_history after insert or update or delete on public.items
for each row execute function public.record_item_history();

alter table public.admins enable row level security;
alter table public.items enable row level security;
alter table public.item_history enable row level security;

drop policy if exists "Public can read items" on public.items;
create policy "Public can read items" on public.items for select using (true);
drop policy if exists "Admins can insert items" on public.items;
create policy "Admins can insert items" on public.items for insert with check (public.is_anomalys_admin());
drop policy if exists "Admins can update items" on public.items;
create policy "Admins can update items" on public.items for update using (public.is_anomalys_admin()) with check (public.is_anomalys_admin());
drop policy if exists "Admins can delete items" on public.items;
create policy "Admins can delete items" on public.items for delete using (public.is_anomalys_admin());

drop policy if exists "Public can read history" on public.item_history;
create policy "Public can read history" on public.item_history for select using (true);
-- No public insert/update/delete policy for history: only the trigger writes history.
-- No policy exposes admin membership for reading/writing from the browser.

grant usage on schema public to anon, authenticated;
grant select on public.items to anon, authenticated;
grant insert, update, delete on public.items to authenticated;
grant select on public.item_history to anon, authenticated;
grant execute on function public.is_anomalys_admin() to anon, authenticated;

-- After creating your administrator account in Supabase Authentication > Users,
-- copy its UUID and run this separately:
-- insert into public.admins (user_id) values ('PASTE-ADMIN-USER-UUID-HERE');
