select * from pg_stat_activity;

select pg_terminate_backend(pid)
from pg_stat_activity
  where datname = 'airflow'
  and pid <> pg_backend_pid()
  and state in (
    'idle',
    'idle in transaction',
    'idle in transaction (aborted)',
    'disabled'
    )
  and state_change < current_timestamp - INTERVAL '480' MINUTE;
