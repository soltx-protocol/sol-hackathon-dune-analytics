-- https://dune.com/queries/630914

select
  address,
  block_date as date,
  sum(token_balance_change) as total_fee_amount_lp,
  round(sum(token_balance_change) * 5 / 6, 2) as fee_amount_lps,
  round(sum(token_balance_change) * 2 / 15, 2) as fee_amount_treasury,
  round(sum(token_balance_change) * 1 / 30, 2) as fee_amount_impact_fund
from
  solana.account_activity
where
   block_time > (CURRENT_DATE - interval '{{dateRange}} days')
and
  address = '{{feeAccount}}'
and
  token_mint_address = '{{poolTokenMint}}'
and
  token_balance_change is not null
group by 1, 2
order by 1, 2

