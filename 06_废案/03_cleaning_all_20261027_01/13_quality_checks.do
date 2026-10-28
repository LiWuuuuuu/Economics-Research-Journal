version 19.0
set more off
set linesize 180
args run_name
if "`run_name'"=="" local run_name "run_01"
global OUT "`c(pwd)'/`run_name'"
log using "$OUT/quality_checks.log", text
use "$OUT/stock_market_unmatched.dta", clear
contract Markettype year Trdwnt, freq(stock_rows)
list, noobs
export delimited using "$OUT/stock_market_unmatched_summary.csv"
use "$OUT/market_weekly_clean.dta", clear
keep if flag_return_missing
list Markettype Trdwnt Wretwdeq Wretwdos Wretwdtl, noobs
export delimited using "$OUT/market_missing_returns.csv"
use "$OUT/capital_events_clean.dta", clear
isid Stkcd cap_date
sort Stkcd cap_date
by Stkcd: gen double next_cap_date=cap_date[_n+1]
keep Stkcd cap_date next_cap_date Nshra Nshrttl
rename Nshra verify_shares_A
rename Nshrttl verify_shares_total
tempfile capcheck
save `capcheck'
use "$OUT/daily_turnover_base.dta", clear
merge m:1 Stkcd cap_date using `capcheck', keep(master match) generate(capcheck_match)
assert capcheck_match==3 if !missing(cap_date)
assert shares_A_asof==verify_shares_A if !missing(cap_date)
assert shares_total_asof==verify_shares_total if !missing(cap_date)
assert cap_date<=trade_date if !missing(cap_date,trade_date)
assert trade_date<next_cap_date if !missing(next_cap_date,trade_date)
assert abs(turnover_daily-Dnshrtrd/shares_A_asof)<1e-12 if !missing(turnover_daily)
count if turnover_daily>1 & !missing(turnover_daily)
count if missing(cap_date)
count if shares_A_asof==0
* 汇总未能计算换手率的原因。不同原因可能重叠。
gen byte B_or_other_market=!is_A_market
gen byte no_capital_history=missing(cap_date)
gen byte nonpositive_A_shares=shares_A_asof<=0 if !missing(shares_A_asof)
gen byte turnover_missing=missing(turnover_daily)
gen byte counter=1
collapse (sum) rows=counter B_or_other_market no_capital_history nonpositive_A_shares turnover_missing, by(year)
export delimited using "$OUT/turnover_missing_by_year.csv"
use "$OUT/shareholders_annual.dta", clear
count if flag_incomplete_top10
count if flag_sum_over100
count if flag_zero_denominator
count if missing(Disp_checked)
list Stkcd year n_top10 n_top10_observed sum_ranks2_10 if flag_zero_denominator, noobs
use "$OUT/audit_annual.dta", clear
tab Big4_domestic Big4_any, missing
preserve
    contract year Big4_domestic Big4_any, freq(rows)
    export delimited using "$OUT/big4_counts_by_year.csv"
restore
keep if flag_big4_scope_difference==1
export delimited using "$OUT/big4_scope_differences.csv"
* 基础财务面板合并完整性与连续年份约束。
use "$OUT/financial_panel_base.dta", clear
isid Stkcd year
assert !flag_balance_absent & !flag_equity_absent & !flag_income_absent
assert CashRatio==A001101000/A001000000 if !missing(CashRatio)
assert LoanRatio==A002101000/A001000000 if !missing(LoanRatio)
assert ROA==B002000000/A001000000 if !missing(ROA)
assert Size==ln(A001000000) if !missing(Size)
sort Stkcd year
by Stkcd: assert year==year[_n-1]+1 if !missing(GROWTH)
assert GROWTH==(A001000000-lag_assets)/lag_assets if !missing(GROWTH)
count if inrange(year,2007,2018)
use "$OUT/excel_reference_valid_keys.dta", clear
count
count if flag_duplicate_key
log close
