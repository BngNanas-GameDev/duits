-- Duits Supabase schema
-- Jalankan seluruh file ini di Supabase Dashboard -> SQL Editor.

create extension if not exists pgcrypto;

do $$
begin
  create type public.transaction_type as enum ('income', 'expense');
exception
  when duplicate_object then null;
end;
$$;

do $$
begin
  create type public.couple_member_role as enum ('owner', 'partner');
exception
  when duplicate_object then null;
end;
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  email text,
  avatar_url text,
  membership text not null default 'free',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', ''),
    new.email
  )
  on conflict (id) do update
  set
    name = excluded.name,
    email = excluded.email,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  type public.transaction_type not null,
  name text not null,
  icon_key text not null default 'inventory',
  color_hex text not null default '#94A3B8',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, type, name),
  constraint categories_color_hex_check check (color_hex ~ '^#[0-9A-Fa-f]{6}$')
);

create trigger categories_set_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

insert into public.categories (user_id, type, name, icon_key, color_hex, sort_order)
select *
from (
  values
    (null::uuid, 'income'::public.transaction_type, 'Gaji Masuk', 'work', '#00C48C', 10),
    (null::uuid, 'income'::public.transaction_type, 'Tabungan', 'savings', '#6C63FF', 20),
    (null::uuid, 'income'::public.transaction_type, 'Lainnya', 'inventory', '#94A3B8', 30),
    (null::uuid, 'expense'::public.transaction_type, 'Belanja', 'shopping_bag', '#FF6B6B', 10),
    (null::uuid, 'expense'::public.transaction_type, 'Tagihan', 'receipt', '#FFB347', 20),
    (null::uuid, 'expense'::public.transaction_type, 'Makanan', 'restaurant', '#FF8C94', 30),
    (null::uuid, 'expense'::public.transaction_type, 'Transportasi', 'car', '#4ECDC4', 40),
    (null::uuid, 'expense'::public.transaction_type, 'Hiburan', 'movie', '#A78BFA', 50),
    (null::uuid, 'expense'::public.transaction_type, 'Tabungan', 'savings', '#6C63FF', 60),
    (null::uuid, 'expense'::public.transaction_type, 'Lainnya', 'inventory', '#94A3B8', 70)
) as seed(user_id, type, name, icon_key, color_hex, sort_order)
where not exists (
  select 1
  from public.categories c
  where c.user_id is null
    and c.type = seed.type
    and c.name = seed.name
);

create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null default 'cash',
  opening_balance numeric(14, 2) not null default 0,
  currency text not null default 'IDR',
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger accounts_set_updated_at
before update on public.accounts
for each row execute function public.set_updated_at();

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid references public.accounts(id) on delete set null,
  category_id uuid references public.categories(id) on delete set null,
  type public.transaction_type not null,
  category_name text not null,
  amount numeric(14, 2) not null,
  title text not null,
  detail text not null default '',
  transaction_date date not null default current_date,
  transaction_time time not null default localtime(0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint transactions_amount_positive check (amount > 0)
);

create index transactions_user_date_idx
on public.transactions (user_id, transaction_date desc, transaction_time desc);

create index transactions_user_type_idx
on public.transactions (user_id, type);

create trigger transactions_set_updated_at
before update on public.transactions
for each row execute function public.set_updated_at();

create table public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  category_name text not null,
  month date not null,
  limit_amount numeric(14, 2) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, category_name, month),
  constraint budgets_month_first_day check (month = date_trunc('month', month)::date),
  constraint budgets_limit_positive check (limit_amount > 0)
);

create trigger budgets_set_updated_at
before update on public.budgets
for each row execute function public.set_updated_at();

create table public.couple_spaces (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references auth.users(id) on delete cascade,
  invite_code text not null unique default upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8)),
  partner_a_name text not null default 'Partner A',
  partner_b_name text not null default 'Partner B',
  is_setup boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger couple_spaces_set_updated_at
before update on public.couple_spaces
for each row execute function public.set_updated_at();

create table public.couple_members (
  id uuid primary key default gen_random_uuid(),
  couple_space_id uuid not null references public.couple_spaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.couple_member_role not null default 'partner',
  display_name text not null default '',
  local_partner_key text not null default 'A',
  created_at timestamptz not null default now(),
  unique (couple_space_id, user_id),
  constraint couple_members_local_key_check check (local_partner_key in ('A', 'B'))
);

create index couple_members_user_idx
on public.couple_members (user_id, couple_space_id);

create or replace function public.is_couple_member(space_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.couple_members cm
    where cm.couple_space_id = space_id
      and cm.user_id = auth.uid()
  );
$$;

create or replace function public.join_couple_by_invite(invite text, display_name text default 'Partner')
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  target_space_id uuid;
begin
  select id
  into target_space_id
  from public.couple_spaces
  where invite_code = upper(trim(invite))
  limit 1;

  if target_space_id is null then
    raise exception 'Kode undangan tidak ditemukan.';
  end if;

  insert into public.couple_members (
    couple_space_id,
    user_id,
    role,
    display_name,
    local_partner_key
  )
  values (
    target_space_id,
    auth.uid(),
    'partner',
    coalesce(nullif(trim(display_name), ''), 'Partner'),
    'B'
  )
  on conflict (couple_space_id, user_id) do update
  set
    display_name = excluded.display_name,
    local_partner_key = excluded.local_partner_key;

  return target_space_id;
end;
$$;

create table public.couple_debts (
  id uuid primary key default gen_random_uuid(),
  couple_space_id uuid not null references public.couple_spaces(id) on delete cascade,
  created_by uuid not null references auth.users(id) on delete cascade,
  owner_key text not null,
  description text not null,
  amount numeric(14, 2) not null,
  debt_date date not null default current_date,
  note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint couple_debts_owner_key_check check (owner_key in ('A', 'B')),
  constraint couple_debts_amount_positive check (amount > 0)
);

create table if not exists public.couple_invitations (
  id uuid primary key default gen_random_uuid(),
  couple_space_id uuid not null references public.couple_spaces(id) on delete cascade,
  inviter_user_id uuid not null references auth.users(id) on delete cascade,
  inviter_name text not null default '',
  invitee_user_id uuid not null references auth.users(id) on delete cascade,
  invitee_email text not null,
  status text not null default 'pending',
  message text not null default '',
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  constraint couple_invitations_status_check check (
    status in ('pending', 'accepted', 'rejected', 'canceled')
  ),
  constraint couple_invitations_not_self check (inviter_user_id <> invitee_user_id)
);

alter table public.couple_invitations
add column if not exists inviter_name text not null default '';

create index if not exists couple_invitations_invitee_idx
on public.couple_invitations (invitee_user_id, status, created_at desc);

create index if not exists couple_invitations_inviter_idx
on public.couple_invitations (inviter_user_id, status, created_at desc);

alter table public.couple_invitations enable row level security;

drop policy if exists "couple_invitations_select_related" on public.couple_invitations;
create policy "couple_invitations_select_related"
on public.couple_invitations for select
using (inviter_user_id = auth.uid() or invitee_user_id = auth.uid());

create or replace function public.user_display_name(user_id uuid)
returns text
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(nullif(p.name, ''), u.email, 'Pengguna')
  from auth.users u
  left join public.profiles p on p.id = u.id
  where u.id = user_id
  limit 1;
$$;

create or replace function public.send_couple_invitation(invitee_email text, message text default '')
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_email text;
  target_user_id uuid;
  existing_space_id uuid;
  invitation_id uuid;
begin
  normalized_email := lower(trim(invitee_email));

  if normalized_email = '' then
    raise exception 'Email pasangan wajib diisi.';
  end if;

  select id
  into target_user_id
  from auth.users
  where lower(email) = normalized_email
  limit 1;

  if target_user_id is null then
    raise exception 'Akun dengan email % belum terdaftar.', normalized_email;
  end if;

  if target_user_id = auth.uid() then
    raise exception 'Tidak bisa mengundang akun sendiri.';
  end if;

  if exists (
    select 1 from public.couple_members where user_id = target_user_id
  ) then
    raise exception 'Akun tersebut sudah terhubung dengan pasangan lain.';
  end if;

  select cm.couple_space_id
  into existing_space_id
  from public.couple_members cm
  where cm.user_id = auth.uid()
  limit 1;

  if existing_space_id is null then
    insert into public.couple_spaces (
      owner_user_id,
      partner_a_name,
      partner_b_name,
      is_setup
    )
    values (
      auth.uid(),
      public.user_display_name(auth.uid()),
      public.user_display_name(target_user_id),
      false
    )
    returning id into existing_space_id;

    insert into public.couple_members (
      couple_space_id,
      user_id,
      role,
      display_name,
      local_partner_key
    )
    values (
      existing_space_id,
      auth.uid(),
      'owner',
      public.user_display_name(auth.uid()),
      'A'
    );
  else
    update public.couple_spaces
    set partner_b_name = public.user_display_name(target_user_id)
    where id = existing_space_id;
  end if;

  update public.couple_invitations
  set status = 'canceled', responded_at = now()
  where couple_space_id = existing_space_id
    and status = 'pending';

  insert into public.couple_invitations (
    couple_space_id,
    inviter_user_id,
    inviter_name,
    invitee_user_id,
    invitee_email,
    message
  )
  values (
    existing_space_id,
    auth.uid(),
    public.user_display_name(auth.uid()),
    target_user_id,
    normalized_email,
    coalesce(message, '')
  )
  returning id into invitation_id;

  return invitation_id;
end;
$$;

create or replace function public.accept_couple_invitation(invitation_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  invitation record;
begin
  select *
  into invitation
  from public.couple_invitations
  where id = invitation_id
    and invitee_user_id = auth.uid()
    and status = 'pending'
  limit 1;

  if invitation.id is null then
    raise exception 'Undangan tidak ditemukan atau sudah diproses.';
  end if;

  if exists (
    select 1
    from public.couple_members
    where user_id = auth.uid()
      and couple_space_id <> invitation.couple_space_id
  ) then
    raise exception 'Akun kamu sudah terhubung dengan pasangan lain.';
  end if;

  insert into public.couple_members (
    couple_space_id,
    user_id,
    role,
    display_name,
    local_partner_key
  )
  values (
    invitation.couple_space_id,
    auth.uid(),
    'partner',
    public.user_display_name(auth.uid()),
    'B'
  )
  on conflict (couple_space_id, user_id) do update
  set
    display_name = excluded.display_name,
    local_partner_key = excluded.local_partner_key;

  update public.couple_spaces
  set
    partner_b_name = public.user_display_name(auth.uid()),
    is_setup = true,
    updated_at = now()
  where id = invitation.couple_space_id;

  update public.couple_invitations
  set status = 'accepted', responded_at = now()
  where id = invitation.id;

  return invitation.couple_space_id;
end;
$$;

create or replace function public.reject_couple_invitation(invitation_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.couple_invitations
  set status = 'rejected', responded_at = now()
  where id = invitation_id
    and invitee_user_id = auth.uid()
    and status = 'pending';
end;
$$;

create index couple_debts_space_date_idx
on public.couple_debts (couple_space_id, debt_date desc);

create trigger couple_debts_set_updated_at
before update on public.couple_debts
for each row execute function public.set_updated_at();

create table public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance_visible boolean not null default true,
  dark_mode boolean not null default false,
  notifications_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger user_settings_set_updated_at
before update on public.user_settings
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.accounts enable row level security;
alter table public.transactions enable row level security;
alter table public.budgets enable row level security;
alter table public.couple_spaces enable row level security;
alter table public.couple_members enable row level security;
alter table public.couple_debts enable row level security;
alter table public.user_settings enable row level security;

create policy "profiles_select_own"
on public.profiles for select
using (id = auth.uid());

create policy "profiles_update_own"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "categories_select_global_or_own"
on public.categories for select
using (user_id is null or user_id = auth.uid());

create policy "categories_insert_own"
on public.categories for insert
with check (user_id = auth.uid());

create policy "categories_update_own"
on public.categories for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "categories_delete_own"
on public.categories for delete
using (user_id = auth.uid());

create policy "accounts_manage_own"
on public.accounts for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "transactions_manage_own"
on public.transactions for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "budgets_manage_own"
on public.budgets for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "couple_spaces_select_member"
on public.couple_spaces for select
using (owner_user_id = auth.uid() or public.is_couple_member(id));

create policy "couple_spaces_insert_owner"
on public.couple_spaces for insert
with check (owner_user_id = auth.uid());

create policy "couple_spaces_update_member"
on public.couple_spaces for update
using (owner_user_id = auth.uid() or public.is_couple_member(id))
with check (owner_user_id = auth.uid() or public.is_couple_member(id));

create policy "couple_spaces_delete_owner"
on public.couple_spaces for delete
using (owner_user_id = auth.uid());

create policy "couple_members_select_member"
on public.couple_members for select
using (user_id = auth.uid() or public.is_couple_member(couple_space_id));

create policy "couple_members_insert_self_or_owner"
on public.couple_members for insert
with check (
  user_id = auth.uid()
  or exists (
    select 1
    from public.couple_spaces cs
    where cs.id = couple_space_id
      and cs.owner_user_id = auth.uid()
  )
);

create policy "couple_members_update_self_or_owner"
on public.couple_members for update
using (
  user_id = auth.uid()
  or exists (
    select 1
    from public.couple_spaces cs
    where cs.id = couple_space_id
      and cs.owner_user_id = auth.uid()
  )
)
with check (
  user_id = auth.uid()
  or exists (
    select 1
    from public.couple_spaces cs
    where cs.id = couple_space_id
      and cs.owner_user_id = auth.uid()
  )
);

create policy "couple_members_delete_self_or_owner"
on public.couple_members for delete
using (
  user_id = auth.uid()
  or exists (
    select 1
    from public.couple_spaces cs
    where cs.id = couple_space_id
      and cs.owner_user_id = auth.uid()
  )
);

create policy "couple_debts_manage_members"
on public.couple_debts for all
using (public.is_couple_member(couple_space_id))
with check (public.is_couple_member(couple_space_id));

create policy "user_settings_manage_own"
on public.user_settings for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create or replace view public.transaction_monthly_summary
with (security_invoker = true) as
select
  user_id,
  date_trunc('month', transaction_date)::date as month,
  sum(amount) filter (where type = 'income') as total_income,
  sum(amount) filter (where type = 'expense') as total_expense,
  count(*) as transaction_count
from public.transactions
where deleted_at is null
group by user_id, date_trunc('month', transaction_date)::date;

create or replace view public.transaction_category_summary
with (security_invoker = true) as
select
  user_id,
  date_trunc('month', transaction_date)::date as month,
  type,
  category_name,
  sum(amount) as total_amount,
  count(*) as transaction_count
from public.transactions
where deleted_at is null
group by user_id, date_trunc('month', transaction_date)::date, type, category_name;
