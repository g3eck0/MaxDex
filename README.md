# MaxDex 🎮

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A live cloud-synced Pokédex tracker. Mark Pokémon as caught, share progress with friends via collaborative rooms, and sync everything in real-time — powered by Supabase. No build step, no server required.

---

## Features

| | |
|---|---|
| ✅ **Catch tracker** | Mark Pokémon as caught / not caught across all generations |
| 📜 **Caught history** | Opens as a separate page to search, sort, and edit caught dates and times, or remove catches with confirmation |
| 🔄 **Live cloud sync** | Real-time sync via Supabase Realtime |
| 🚪 **Room sharing** | Create a room and invite friends with a code |
| 📤 **Import / Export** | Back up and restore your save data as JSON |
| 📱 **Responsive UI** | Works great on desktop and mobile |

---

## Prerequisites

- A free [Supabase](https://supabase.com) account
- A modern web browser — no build tools needed

---

## Installation

### 1. Clone the repo

```bash
git clone https://github.com/g3eck0/MaxDex.git
cd MaxDex
```

### 2. Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Once created, open **Project Settings → API**
3. Copy your **Project URL** and **anon public key** — you'll need them in step 4

### 3. Set up the database

In the Supabase dashboard open **SQL Editor**, paste the contents of [`supabase/setup.sql`](./supabase/setup.sql), and click **Run**.

This creates the `gigadex_rooms` table with the caught timestamp JSON field, an auto-update trigger, and Row Level Security policies. To enable caught-date synchronization for an existing project, run [`supabase/migrations/20261025_add_caught_at.sql`](./supabase/migrations/20261025_add_caught_at.sql) in the Supabase SQL Editor. Existing caught entries without a recorded timestamp appear as **Unknown**.

For instant shared updates, enable `public.gigadex_rooms` in the `supabase_realtime` publication from **Database → Publications** in the Supabase dashboard. The app listens for room changes and no longer polls the database on a timer.

### 4. Configure the app

Open `index.html` and update the two constants near the top of the `<script>` block:

```js
const SUPABASE_URL   = 'https://<your-project-ref>.supabase.co/rest/v1/';
const SUPABASE_ANON_KEY = '<your-anon-key>';
```

### 5. Deploy the Edge Function (room invites)

```bash
# Install the Supabase CLI
npm install -g supabase

# Authenticate and link to your project
supabase login
supabase link --project-ref <your-project-ref>

# Deploy the invite function
supabase functions deploy send-room-invite
```

### 6. Open the app

```bash
# Windows
start index.html

# macOS / Linux
open index.html
```

That's it — no server needed.

---

## Supabase Schema

The full setup script lives at [`supabase/setup.sql`](./supabase/setup.sql). Here's what it creates:

```sql
-- Rooms table
create table gigadex_rooms (
  id          uuid primary key default gen_random_uuid(),
  room_code   text unique not null,
  owner_id    uuid references auth.users(id) on delete cascade,
  caught_data jsonb not null default '{}',
  caught_at   jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- RLS: owners have full access, anyone can read by room code
alter table gigadex_rooms enable row level security;
```

---

## License

Distributed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0).
