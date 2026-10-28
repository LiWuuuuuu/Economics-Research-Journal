tempfile p0 p1 p2 p3 p4 p5 p6 p7 p8
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr(2).dta", clear
post $SOURCE_HANDLE (5) ("01_raw/03_daily_trading/TRD_Dalyr(2).dta") (_N)
generate int source_id = 5
generate long source_row = _n
save `p0'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr(4).dta", clear
post $SOURCE_HANDLE (6) ("01_raw/03_daily_trading/TRD_Dalyr(4).dta") (_N)
generate int source_id = 6
generate long source_row = _n
save `p1'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr(5).dta", clear
post $SOURCE_HANDLE (7) ("01_raw/03_daily_trading/TRD_Dalyr(5).dta") (_N)
generate int source_id = 7
generate long source_row = _n
save `p2'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr1(2).dta", clear
post $SOURCE_HANDLE (8) ("01_raw/03_daily_trading/TRD_Dalyr1(2).dta") (_N)
generate int source_id = 8
generate long source_row = _n
save `p3'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr1(3).dta", clear
post $SOURCE_HANDLE (9) ("01_raw/03_daily_trading/TRD_Dalyr1(3).dta") (_N)
generate int source_id = 9
generate long source_row = _n
save `p4'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr1.dta", clear
post $SOURCE_HANDLE (10) ("01_raw/03_daily_trading/TRD_Dalyr1.dta") (_N)
generate int source_id = 10
generate long source_row = _n
save `p5'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr2(1).dta", clear
post $SOURCE_HANDLE (11) ("01_raw/03_daily_trading/TRD_Dalyr2(1).dta") (_N)
generate int source_id = 11
generate long source_row = _n
save `p6'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr2.dta", clear
post $SOURCE_HANDLE (12) ("01_raw/03_daily_trading/TRD_Dalyr2.dta") (_N)
generate int source_id = 12
generate long source_row = _n
save `p7'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr3.dta", clear
post $SOURCE_HANDLE (13) ("01_raw/03_daily_trading/TRD_Dalyr3.dta") (_N)
generate int source_id = 13
generate long source_row = _n
save `p8'
use `p0', clear
append using `p1'
append using `p2'
append using `p3'
append using `p4'
append using `p5'
append using `p6'
append using `p7'
append using `p8'

check_key Stkcd Trddt
datestring Trddt, generate(trade_date)
generate int year=year(trade_date)
generate int month=month(trade_date)
generate byte flag_date_invalid=missing(trade_date)
generate byte flag_outside_window=!inrange(year,2006,2019)
generate byte flag_volume_missing=missing(Dnshrtrd)
generate byte flag_volume_negative=Dnshrtrd<0
generate byte flag_float_mv_missing=missing(Dsmvosd)
generate byte flag_total_mv_missing=missing(Dsmvtll)
generate byte flag_float_mv_nonpositive=Dsmvosd<=0 if !missing(Dsmvosd)
generate byte flag_total_mv_nonpositive=Dsmvtll<=0 if !missing(Dsmvtll)
generate byte flag_float_mv_gt_total=Dsmvosd>Dsmvtll if !missing(Dsmvosd,Dsmvtll)
generate byte flag_status_unknown=!inrange(Trdsta,1,16) | Trdsta!=floor(Trdsta)
generate byte flag_market_unknown=!inlist(Markettype,1,2,4,8,16,32,64)
generate byte is_A_market=inlist(Markettype,1,4,16,32,64)
* 单位保留原始千元；本次不把B股外币市值混作人民币市值。
generate byte is_ST_PT_day=inlist(Trdsta,2,3,5,6,8,9,11,12,14,15,16)
table_metrics, table(daily_trading) fields(Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta)
save_review daily_trading
sort Stkcd trade_date
save "$OUT/daily_trading_clean.dta"
* 年内是否出现ST/PT只生成诊断指标；不在清洗阶段决定整年剔除口径。
preserve
    generate byte count_unit=1
    collapse (sum) n_daily_records=count_unit n_ST_PT_days=is_ST_PT_day (max) any_ST_PT_day=is_ST_PT_day flag_status_unknown, by(Stkcd year)
    isid Stkcd year
    save "$OUT/trading_status_annual.dta"
restore
* 年末最近交易日原始市值，不对缺失值向更早日期回填。
preserve
    keep if !flag_key_missing & !flag_duplicate_key & !flag_date_invalid & !flag_outside_window
    sort Stkcd year trade_date
    by Stkcd year: keep if _n==_N
    keep Stkcd year Trddt Dsmvosd Dsmvtll Markettype source_id source_row
    rename Trddt market_value_date
    generate double market_value_yuan=Dsmvtll*1000 if inlist(Markettype,1,4,16,32,64)
    isid Stkcd year
    save "$OUT/market_value_yearend.dta"
restore
* 将股本事件向后匹配到交易日，绝不使用未来股本。
preserve
    use "$OUT/capital_events_clean.dta", clear
    isid Stkcd cap_date
    keep if !flag_date_invalid & !flag_duplicate_key & !flag_key_missing
    keep Stkcd cap_date Nshra Nshrttl source_id source_row
    rename source_id cap_source_id
    rename source_row cap_source_row
    rename Nshra shares_A_asof
    rename Nshrttl shares_total_asof
    generate double event_date=cap_date
    generate byte capital_event=1
    tempfile capital_timeline
    save `capital_timeline'
restore
generate double event_date=trade_date
generate byte capital_event=0
append using `capital_timeline'
gsort Stkcd event_date -capital_event
foreach v in shares_A_asof shares_total_asof cap_date cap_source_id cap_source_row {
    by Stkcd: replace `v'=`v'[_n-1] if capital_event==0
}
keep if capital_event==0
assert cap_date<=trade_date if !missing(cap_date,trade_date)
generate byte flag_shares_history_missing=missing(cap_date) | missing(shares_A_asof)
generate byte flag_shares_zero_or_negative=shares_A_asof<=0 if !missing(shares_A_asof)
generate double turnover_daily=Dnshrtrd/shares_A_asof if is_A_market & !missing(Dnshrtrd,shares_A_asof) & Dnshrtrd>=0 & shares_A_asof>0 & !flag_duplicate_key & !flag_date_invalid
generate byte flag_turnover_gt1=turnover_daily>1 if !missing(turnover_daily)
label variable turnover_daily "Daily volume / latest available A float shares; same-day event applied"
foreach v in flag_shares_history_missing flag_shares_zero_or_negative flag_turnover_gt1 {
    count if `v'==1
    post $AUDIT_HANDLE ("daily_turnover") ("`v'") (r(N))
}
count if missing(turnover_daily)
post $AUDIT_HANDLE ("daily_turnover") ("missing:turnover_daily") (r(N))
drop event_date capital_event
sort Stkcd trade_date
save "$OUT/daily_turnover_base.dta"
generate byte count_unit=1
generate byte turnover_observed=!missing(turnover_daily)
collapse (sum) n_days=count_unit n_turnover_days=turnover_observed (mean) turnover_month_mean=turnover_daily, by(Stkcd year month)
generate byte flag_incomplete_turnover_month=n_turnover_days<n_days
* 完整日数据才给出可供后续使用的月均换手率，部分数据均值保留为诊断。
generate double turnover_month_complete=turnover_month_mean if !flag_incomplete_turnover_month
isid Stkcd year month
save "$OUT/turnover_monthly_base.dta"
