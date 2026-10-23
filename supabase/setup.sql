-- MaxDex — Supabase setup script
-- Run this in the Supabase SQL Editor: https://supabase.com/dashboard/project/<your-ref>/sql

-- Create the rooms table
create table if not exists gigadex_rooms (
  id          uuid primary key default gen_random_uuid(),
  room_code   text unique not null,
  owner_id    uuid references auth.users(id) on delete cascade,
  caught_data jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Keep updated_at current automatically
create or replace function update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger gigadex_rooms_updated_at
  before update on gigadex_rooms
  for each row execute procedure update_updated_at();

-- Enable Row Level Security
alter table gigadex_rooms enable row level security;

-- Owners can read and write their own rooms
create policy "Owner full access"
  on gigadex_rooms for all
  using  (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- Anyone with the room code can read (for shared rooms)
create policy "Public read by room code"
  on gigadex_rooms for select
  using (true);
