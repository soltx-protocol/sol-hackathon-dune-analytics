-- https://dune.com/queries/632565

with orca_swaps as (
  with selected_and_transformed as (
    select
      id,
      signer,
      block_date,
      block_time,
      fee,
      'Orca Token Swap V2' as program,
      '{{account}}' as account,
      transform(pre_token_balances, x -> x.account) as token_balances_account,
      transform(pre_token_balances, x -> x.mint) as token_balances_mint,
      transform(pre_token_balances, x -> x.amount) as pre_token_balances_amount,
      transform(post_token_balances, x -> x.amount) as post_token_balances_amount
    from
      solana.transactions
    where
      array_contains(instructions.executing_account, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') -- Orca Token Swap V2
    and
      if('{{account}}' = 'default', true, array_contains(account_keys, '{{account}}'))  -- pool account
    and
      success is true
    and
      cast(log_messages as string) like '%Instruction: Swap%'
  ), append_balances_change as (
    select
      *,
      transform(arrays_zip(pre_token_balances_amount, post_token_balances_amount), x -> x.post_token_balances_amount - x.pre_token_balances_amount) as token_balances_change
    from
      selected_and_transformed
  ), append_volume_in_btoken (
    select
      *,
    --   abs(token_balances_change[array_position(token_balances_account, '9r39vqrJuubgafaJ5aQyDWYAUQVJeyZyveBXeRqp7xev')]) as volume_atoken,
      if('{{tokenAccountB}}' = 'default', 0, abs(token_balances_change[array_position(token_balances_account, '{{tokenAccountB}}')-1])) as volume_btoken,
      if('{{feeAccount}}' = 'default', 0, abs(token_balances_change[array_position(token_balances_account, '{{feeAccount}}')-1])) as fee_lps,
      if('{{tokenAccountB}}' = 'default', 0, abs(token_balances_change[array_position(token_balances_account, '{{tokenAccountB}}')-1])) * 0.003 as fee_btoken_approx
    from
      append_balances_change
  )
  select * from append_volume_in_btoken
)
select
  block_date,
  '{{account}}' as poolAccount,
  count(distinct signer) as unique_address_count,
  count(*) as swap_count,
  sum(volume_btoken) as volume_btoken,
  sum(fee_lps) as fee_lps,
  sum(fee_btoken_approx) as fee_btoken_approx
from
  orca_swaps
where
  block_date between (current_date - interval {{dateRange}} day) and (current_date - interval 1 day)
and
  if('{{walletAddress}}' = 'default', true, signer = '{{walletAddress}}')
group by
  block_date, poolAccount
