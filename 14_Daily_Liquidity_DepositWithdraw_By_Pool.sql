-- https://dune.com/queries/633080
with orca_liquidity_by_pool as (
  with selected_and_transformed as (
    select
      block_date,
      block_time,
      index,
      id,
      transform(pre_token_balances, x -> x.account) as token_balances_account,
      transform(pre_token_balances, x -> x.mint) as token_balances_mint,
      transform(pre_token_balances, x -> x.amount) as pre_token_balances_amount,
      transform(post_token_balances, x -> x.amount) as post_token_balances_amount
    from
      solana.transactions
    where
      array_contains(account_keys, '{{farmTokenMint}}') -- pool farmTokenMint
    and
      array_contains(account_keys, '{{globalFarm}}') -- pool globalFarm
    and
      success is true
    and
      block_date between (current_date - interval {{dateRange}} day) and (current_date - interval 1 day)
  ), append_farm_token_info as (
  select
    *,
    token_balances_account[array_position(token_balances_mint, '{{farmTokenMint}}')-1] as farm_token_balance_account,
    pre_token_balances_amount[array_position(token_balances_mint, '{{farmTokenMint}}')-1] as pre_farm_token_balance_amount,
    post_token_balances_amount[array_position(token_balances_mint, '{{farmTokenMint}}')-1] as post_farm_token_balance_amount
  from
    selected_and_transformed
  )
  select
    *,
    if(post_farm_token_balance_amount - pre_farm_token_balance_amount > 0, post_farm_token_balance_amount - pre_farm_token_balance_amount, 0) as deposit,
    if(post_farm_token_balance_amount - pre_farm_token_balance_amount < 0, abs(post_farm_token_balance_amount - pre_farm_token_balance_amount), 0) as withdraw
  from
    append_farm_token_info
)

select
  block_date,
  sum(deposit) as deposit,
  sum(withdraw) as withdraw
from
  orca_liquidity_by_pool
group by
  block_date
