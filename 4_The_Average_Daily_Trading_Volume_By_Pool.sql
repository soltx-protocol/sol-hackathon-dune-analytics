-- https://dune.com/queries/631945
with daily_swap_count as (
  select
    block_date,
    count(*) as cnt
  from
    solana.transactions
  where
    block_date between (current_date - interval {{dateRange}} day) and (current_date - interval 1 days)
  and
    (
      array_contains(instructions.executing_account, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') -- Orca Token Swap V2
    )
  and
    cast(log_messages as string) like '%Instruction: Swap%'
  and
    array_contains(account_keys, '{{account}}') -- GST / USDC account
  and
    success is true
  group by
    block_date
)
select
  avg(cnt) as average_count
from
  daily_swap_count
