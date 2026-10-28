version 19.0
set more off
set linesize 180
args run_name
if "`run_name'"=="" local run_name "run_01"
global OUT "`c(pwd)'/`run_name'"
log using "$OUT/annual_master_verified.log", text
use "$OUT/financial_panel_base.dta", clear
local expected=_N
tempfile usingfile
* 各模块仅按唯一键连接，不因未匹配删除财务基础表记录。
preserve
    use "$OUT/stock_weekly_annual_coverage.dta", clear
    isid Stkcd year
    save `usingfile'
restore
merge 1:1 Stkcd year using `usingfile', keep(master match) generate(merge_weekly)
tab merge_weekly
preserve
    use "$OUT/shareholders_annual.dta", clear
    isid Stkcd year
    keep Stkcd year n_top10 n_top10_observed rank1_share sum_ranks2_10 sum_top10 n_over10 Disp_raw Disp_checked flag_incomplete_top10 flag_sum_over100 flag_zero_denominator
    save `usingfile', replace
restore
merge 1:1 Stkcd year using `usingfile', keep(master match) generate(merge_shareholders)
tab merge_shareholders
preserve
    use "$OUT/audit_annual.dta", clear
    isid Stkcd year
    keep Stkcd year domestic_auditor_clean foreign_auditor_clean Big4_domestic Big4_any flag_big4_scope_difference
    save `usingfile', replace
restore
merge 1:1 Stkcd year using `usingfile', keep(master match) generate(merge_audit)
tab merge_audit
preserve
    use "$OUT/market_value_yearend.dta", clear
    isid Stkcd year
    keep Stkcd year market_value_date Dsmvosd Dsmvtll Markettype market_value_yuan
    rename Markettype yearend_market_type
    save `usingfile', replace
restore
merge 1:1 Stkcd year using `usingfile', keep(master match) generate(merge_marketvalue)
tab merge_marketvalue
preserve
    use "$OUT/trading_status_annual.dta", clear
    isid Stkcd year
    keep Stkcd year n_daily_records n_ST_PT_days any_ST_PT_day flag_status_unknown
    save `usingfile', replace
restore
merge 1:1 Stkcd year using `usingfile', keep(master match) generate(merge_tradingstatus)
tab merge_tradingstatus
preserve
    use "$OUT/company_snapshot_clean.dta", clear
    isid Stkcd
    keep Stkcd industry_snapshot province_snapshot province_code_snapshot list_date snapshot_financial snapshot_realestate
    rename list_date company_list_date
    save `usingfile', replace
restore
merge m:1 Stkcd using `usingfile', keep(master match) generate(merge_company_snapshot)
tab merge_company_snapshot
* 明确标记：行业和省份是当前截面，不是已核实的历史面板。
generate byte flag_hist_industry_unverified=1
generate byte flag_hist_province_unverified=1
* 市账比保留两个候选分母，均不冒充作者已确定口径。
generate double MB_parent_candidate=market_value_yuan/A003100000 if !missing(market_value_yuan,A003100000) & A003100000>0
generate double MB_total_candidate=market_value_yuan/A003000000 if !missing(market_value_yuan,A003000000) & A003000000>0
label variable MB_parent_candidate "Candidate: year-end A-share market value / parent equity"
label variable MB_total_candidate "Candidate: year-end A-share market value / total equity"
assert _N==`expected'
isid Stkcd year
sort Stkcd year
save "$OUT/annual_master_base.dta"
preserve
    keep Stkcd year merge_* flag_* explanatory_year
    export delimited using "$OUT/annual_master_coverage.csv"
restore
foreach v in merge_weekly merge_shareholders merge_audit merge_marketvalue merge_tradingstatus merge_company_snapshot {
    preserve
        contract year `v', freq(rows)
        export delimited using "$OUT/`v'_counts.csv"
    restore
}
display "ANNUAL_MASTER_BASE_COMPLETED"
log close
