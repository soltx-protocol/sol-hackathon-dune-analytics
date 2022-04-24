-- https://dune.com/queries/633076
with orca_liquidity_by_pool as (
  with selected_and_transformed as (
    select
      date_trunc('month', block_time) as block_month,
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
  ), dedupe_by_date as (
    select
      *
    from
    (select
      *,
      row_number() over (partition by block_date, farm_token_balance_account order by block_time desc, index desc) as row_num_date
    from
      append_farm_token_info)
    where
      row_num_date = 1
  ), dedupe_by_month as (
    select
      *
    from
    (select
      *,
      row_number() over (partition by block_month, farm_token_balance_account order by block_date desc) as row_num_month
    from
      dedupe_by_date)
    where
      row_num_month = 1
  ), dedupe_all as (
    select
      *
    from
    (select
      *,
      row_number() over (partition by farm_token_balance_account order by block_month desc) as row_num
    from
      dedupe_by_month)
    where
      row_num = 1
  )
  select
    *
  from
    dedupe_all
)
select
  farm_token_balance_account as address,
  post_farm_token_balance_amount as farm_token_amount,
  round(100 * post_farm_token_balance_amount / sum(post_farm_token_balance_amount) over (), 2) as percentage
from
 orca_liquidity_by_pool
where
  post_farm_token_balance_amount > 0
order by
  farm_token_amount desc
