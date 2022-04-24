# sol-hackathon-dune-analytics

## Source Table & transformed table
Basicly we have used these two table below to answer question and build dashboard .
- solana.transactions
- solana.account_activity

orca_swaps.sql is our transformed table having higher abstraction and easily to use based on solana.transactions.
https://github.com/soltx-protocol/sol-hackathon-dune-analytics/blob/main/orca_swaps.sql

## Challeng Dashboard

https://dune.com/c1mone_degen/Soltx

## Question

### Which wallet executed the first trade on Orca, what pool was it, and how much it for denominated in USDC?
- https://dune.com/queries/630624
- https://solscan.io/tx/ntohuJ8rrget8gSmDaYtbzj9zyGjddxR5W31gJUPPDAfUVqGobEYeWVm6HseyouyagQncBkmwCGi6DkCe4B35kk
- SOL/USDC POOL
- result : 817.95 USDC

### What is the largest trade that has been executed through Orca?
- https://dune.com/queries/632632
- We can find the largest trade based on btoken size in each pool through Orca (ex. GST/USDC[aquafarm])

### Which wallet has executed the most trades?
- https://dune.com/queries/630617/1176454

### What was the average daily trading volume in February 2022?
- https://dune.com/queries/631445
- 26958.07

### Which wallet is the largest liquidity provider in the SOL/USD pool?
- https://dune.com/queries/632729
- 6bm6H7NqcTiVYh3cBBVYsuS5qaA9GhpGyyLQP38s9mzT

### How many unique liquidity providers are there in the ORCA/SOL pool?
- https://dune.com/queries/633076
- 2101

### Which pool has the largest amount of liquidity? Which has the least?
- SOL/USDC[aquafarm] has the Largest Amount https://dune.com/queries/633010 
- UN/USDC[aquafarm] Least Amount https://dune.com/queries/633044
