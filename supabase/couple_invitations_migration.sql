-- Migration khusus fitur undangan pasangan.
-- Jalankan file ini di Supabase SQL Editor untuk project yang schema awalnya sudah dibuat.

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
