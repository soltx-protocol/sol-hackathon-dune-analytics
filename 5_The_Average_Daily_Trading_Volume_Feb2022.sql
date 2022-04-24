-- https://dune.com/queries/631445
with daily_swap_count as (
  select
   /* case when array_contains(instructions.executing_account, 'DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1') then 'Swap V1'
    when array_contains(instructions.executing_account, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') then 'Swap V2'
    when array_contains(instructions.executing_account, 'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc') then 'Whirlpools'
    else null end as pool_type,*/
    block_date, count(*) as cnt
  from
    solana.transactions
  where
    (
      array_contains(instructions.executing_account, 'DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1') -- Orca Token Swap V1
      OR
      array_contains(instructions.executing_account, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') -- Orca Token Swap V2
      OR
      array_contains(instructions.executing_account, 'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc') -- Orca Whirlpools
    )
  and
    cast(log_messages as string) like '%Instruction: Swap%'
  and
    block_date >= date('2022-02-01') and block_date < date('2022-03-01')
  and
    success is true
  group by
    block_date
)
select
  avg(cnt) as average_count
from
  daily_swap_count
