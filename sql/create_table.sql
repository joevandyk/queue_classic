-- If json type is available, use it for the args column.
-- Otherwise, use text
do $$
declare
  args_type text := 'text';
begin
  perform * from pg_type where typname = 'json';
  if found then
    args_type := 'json';
  end if;

  execute '
CREATE TABLE queue_classic_jobs (
  id bigserial PRIMARY KEY,
  q_name text not null,
  method text not null,
  args ' || args_type || ' not null,
  locked_at timestamptz
); ';
end $$ language plpgsql;

CREATE INDEX idx_qc_on_name_only_unlocked ON queue_classic_jobs (q_name, id) WHERE locked_at IS NULL;
