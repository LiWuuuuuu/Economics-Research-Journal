tempfile p0 p1
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/02_weekly_stock/TRD_Week.dta", clear
post $SOURCE_HANDLE (3) ("01_raw/02_weekly_stock/TRD_Week.dta") (_N)
generate int source_id = 3
generate long source_row = _n
save `p0'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/02_weekly_stock/TRD_Week1.dta", clear
post $SOURCE_HANDLE (4) ("01_raw/02_weekly_stock/TRD_Week1.dta") (_N)
generate int source_id = 4
generate long source_row = _n
save `p1'
use `p0', clear
append using `p1'

check_key Stkcd Trdwnt
generate int year=real(substr(Trdwnt,1,4))
generate byte week_number=real(substr(Trdwnt,6,2))
datestring Clsdt, generate(close_date)
generate byte flag_week_invalid=!regexm(Trdwnt,"^[0-9][0-9][0-9][0-9]-[0-9][0-9]$") | !inrange(week_number,1,53)
generate byte flag_outside_window=!inrange(year,2006,2019)
generate byte flag_close_date_missing=missing(close_date)
generate byte flag_return_missing=missing(Wretwd)
generate byte flag_return_below_minus1=Wretwd< -1
generate byte flag_trading_days_invalid=missing(Ndaytrd) | Ndaytrd<0 | Ndaytrd>7 | Ndaytrd!=floor(Ndaytrd)
generate byte flag_no_trading=Ndaytrd==0
generate byte flag_market_unknown=!inlist(Markettype,1,2,4,8,16,32,64)
generate byte is_A_market=inlist(Markettype,1,4,16,32,64)
* 保留CSMAR周码作为键，不用Stata每年52周的周日期替代原周码。
generate byte usable_raw_return=!flag_key_missing & !flag_duplicate_key & !flag_week_invalid & !flag_outside_window & !flag_return_missing & !flag_return_below_minus1 & !flag_trading_days_invalid & Ndaytrd>0
table_metrics, table(stock_weekly) fields(Stkcd Trdwnt Clsdt Ndaytrd Wretwd Markettype)
save_review stock_weekly
sort Stkcd year week_number
save "$OUT/stock_weekly_clean.dta"
preserve
    keep if usable_raw_return
    save "$OUT/stock_weekly_usable.dta"
restore
* 年度有效原始周数用于覆盖诊断，不等同市场模型回归后的残差有效周数。
preserve
    generate double return_for_mean=Wretwd if usable_raw_return
    generate byte row_count=1
    collapse (sum) n_raw_weeks=row_count n_usable_weeks=usable_raw_return (mean) mean_raw_weekly_return=return_for_mean, by(Stkcd year)
    generate byte flag_under30_rawweeks=n_usable_weeks<30
    isid Stkcd year
    save "$OUT/stock_weekly_annual_coverage.dta"
restore
* 只验证精确市场×原周码的匹配覆盖，不估计崩盘风险。
preserve
    use "$OUT/market_weekly_clean.dta", clear
    isid Markettype Trdwnt
    keep Markettype Trdwnt Wretwdeq Wretwdos Wretwdtl
    tempfile marketlookup
    save `marketlookup'
restore
merge m:1 Markettype Trdwnt using `marketlookup', keep(master match) generate(market_merge)
generate byte flag_market_unmatched=market_merge==1
count if flag_market_unmatched
post $AUDIT_HANDLE ("stock_weekly") ("flag_market_unmatched") (r(N))
keep if flag_market_unmatched
save "$OUT/stock_market_unmatched.dta"
