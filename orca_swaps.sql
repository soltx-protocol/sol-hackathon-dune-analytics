with orca_swaps as (
  with selected_and_transformed as (
    select
      id,
      signer,
      block_date,
      block_time,
      fee,
      'Orca Token Swap V2' as program,
      '87E4KtN7F4LivKhjqXaoQAvS3a8HnM4DnMUrbMrkVvXY' as account,
      transform(pre_token_balances, x -> x.account) as token_balances_account,
      transform(pre_token_balances, x -> x.mint) as token_balances_mint,
      transform(pre_token_balances, x -> x.amount) as pre_token_balances_amount,
      transform(post_token_balances, x -> x.amount) as post_token_balances_amount
    from
      solana.transactions
    where
      array_contains(instructions.executing_account, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') -- Orca Token Swap V2
    and
      array_contains(account_keys, '{{account}}')  -- pool account
    and
      success is true
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
      abs(token_balances_change[array_position(token_balances_account, '{{tokenAccountB}}')]) as volume_btoken
    from
      append_balances_change
  )
  select * from append_volume_in_btoken
)
select
  count(1)
from
  orca_swaps
where
  block_time between (current_date - interval 30 day) and (current_date - interval 1 day)