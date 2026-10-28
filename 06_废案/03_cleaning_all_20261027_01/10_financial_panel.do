* 财务三表仅做外连接，保留未匹配公司—年度，不提前做完整样本删除。
use "$OUT/balance_annual.dta", clear
isid Stkcd year
keep Stkcd year Accper A001101000 A001000000 A002101000 source_id source_row
rename source_id balance_source_id
rename source_row balance_source_row
rename Accper balance_Accper
tempfile eq inc
preserve
    use "$OUT/equity_annual.dta", clear
    isid Stkcd year
    keep Stkcd year Accper A003100000 A003000000 source_id source_row
    rename source_id equity_source_id
    rename source_row equity_source_row
    rename Accper equity_Accper
    save `eq'
restore
merge 1:1 Stkcd year using `eq', generate(merge_equity)
tab merge_equity
preserve
    use "$OUT/income_annual.dta", clear
    isid Stkcd year
    keep Stkcd year Accper B002000000 source_id source_row
    rename source_id income_source_id
    rename source_row income_source_row
    rename Accper income_Accper
    save `inc'
restore
merge 1:1 Stkcd year using `inc', generate(merge_income)
tab merge_income
generate byte flag_balance_absent=missing(balance_source_id)
generate byte flag_equity_absent=missing(equity_source_id)
generate byte flag_income_absent=missing(income_source_id)
generate byte flag_assets_invalid=missing(A001000000) | A001000000<=0
generate byte flag_loan_missing=missing(A002101000)
generate byte flag_cash_missing=missing(A001101000)
* 只生成已知公式的基础量，不估算DH，不做行业均值或连续年判断。
generate double CashRatio=A001101000/A001000000 if A001000000>0 & !missing(A001000000,A001101000)
generate double LoanRatio=A002101000/A001000000 if A001000000>0 & !missing(A001000000,A002101000)
generate double Size=ln(A001000000) if A001000000>0 & !missing(A001000000)
generate double ROA=B002000000/A001000000 if A001000000>0 & !missing(A001000000,B002000000)
sort Stkcd year
by Stkcd: generate double lag_assets=A001000000[_n-1] if year==year[_n-1]+1
generate double GROWTH=(A001000000-lag_assets)/lag_assets if lag_assets>0 & !missing(lag_assets,A001000000)
generate byte flag_growth_unavailable=missing(GROWTH)
generate byte explanatory_year=inrange(year,2007,2018)
table_metrics, table(financial_panel) fields(Stkcd year A001101000 A001000000 A002101000 A003100000 A003000000 B002000000 CashRatio LoanRatio Size ROA GROWTH)
save_review financial_panel
isid Stkcd year
save "$OUT/financial_panel_base.dta"
