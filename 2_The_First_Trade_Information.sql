-- https://dune.com/queries/630624
select
  id
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
  date(block_date) <= date('2021-05-01')
order by
  block_time asc, index  asc limit 1
-- id ntohuJ8rrget8gSmDaYtbzj9zyGjddxR5W31gJUPPDAfUVqGobEYeWVm6HseyouyagQncBkmwCGi6DkCe4B35kk
