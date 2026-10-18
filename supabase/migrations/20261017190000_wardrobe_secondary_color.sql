-- Second fabric color for patterned items (stripes, plaid), written by the AI backend.
alter table public.wardrobe_items
  add column if not exists secondary_color text,
  add column if not exists secondary_hex text;
