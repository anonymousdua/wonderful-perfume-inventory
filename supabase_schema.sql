-- Run this in the Supabase SQL editor.

create table if not exists perfumes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  brand text not null,
  category text not null,
  size text not null,
  units integer not null default 0 check (units >= 0),
  reorder_level integer not null default 5,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists sellers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  created_at timestamptz not null default now()
);

create table if not exists sales (
  id uuid primary key default gen_random_uuid(),
  sale_no bigint generated always as identity (start with 1001),
  perfume_id uuid not null references perfumes(id),
  seller_id uuid not null references sellers(id),
  quantity integer not null check (quantity > 0),
  payment_method text not null,
  status text not null default 'Completed',
  created_at timestamptz not null default now()
);

-- Atomic sale: decrements stock and records the sale together.
create or replace function sell_perfume(
  p_perfume_id uuid, p_seller_id uuid, p_quantity int, p_payment_method text
) returns void language plpgsql as $$
begin
  update perfumes set units = units - p_quantity
   where id = p_perfume_id and units >= p_quantity;
  if not found then
    raise exception 'Not enough stock available';
  end if;
  insert into sales (perfume_id, seller_id, quantity, payment_method)
  values (p_perfume_id, p_seller_id, p_quantity, p_payment_method);
end $$;

create or replace function add_stock(p_perfume_id uuid, p_quantity int)
returns void language plpgsql as $$
begin
  update perfumes set units = units + p_quantity where id = p_perfume_id;
end $$;

-- The app has no login, so these policies let the anon key read/write.
-- Fine for a private desktop tool; tighten them if you add authentication.
alter table perfumes enable row level security;
alter table sellers  enable row level security;
alter table sales    enable row level security;
create policy "anon all perfumes" on perfumes for all to anon using (true) with check (true);
create policy "anon all sellers"  on sellers  for all to anon using (true) with check (true);
create policy "anon all sales"    on sales    for all to anon using (true) with check (true);
