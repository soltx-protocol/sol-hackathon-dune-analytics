-- https://dune.com/queries/630617/1176454
with daily_user_swap_count as (
  select
    block_date,
    case when array_contains(instructions.executing_account, 'DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1') then 'Orca Token Swap V1'
    when array_contains(instructions.executing_account, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') then 'Orca Token Swap V2'
    when array_contains(instructions.executing_account, 'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc') then 'Orca Whirlpools'
    else null end as program,
    signer,
    count(*) as cnt
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
    success is true
  and
    block_date between (current_date - interval 180 day) and (current_date - interval 1 day)
  group by
    block_date, program, signer
  
)
select
  signer, sum(cnt) as total_cnt
from
  daily_user_swap_count
group by
  signer
order by
  total_cnt desc
limit 5
