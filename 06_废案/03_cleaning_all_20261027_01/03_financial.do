* 财务表：核查原始记录，再分流年度合并报表与其他口径。
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas.dta", clear
post $SOURCE_HANDLE (17) ("01_raw/06_balance_sheet/FS_Combas.dta") (_N)
generate int source_id = 17
generate long source_row = _n

check_key Stkcd Accper Typrep
datestring Accper, generate(report_date)
generate int year=year(report_date)
generate byte flag_date_invalid=missing(report_date)
generate byte flag_report_type_unknown=!inlist(Typrep,"A","B")
generate byte flag_code_invalid=!regexm(Stkcd,"^[0-9][0-9][0-9][0-9][0-9][0-9]$")
generate byte annual_selected=Typrep=="A" & month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019)

generate byte flag_cash_missing=missing(A001101000)
generate byte flag_assets_missing=missing(A001000000)
generate byte flag_loan_missing=missing(A002101000)
generate byte flag_assets_nonpositive=A001000000<=0 if !missing(A001000000)
generate byte flag_cash_negative=A001101000<0 if !missing(A001101000)
generate byte flag_loan_negative=A002101000<0 if !missing(A002101000)
generate byte flag_cash_gt_assets=A001101000>A001000000 if !missing(A001101000,A001000000)
generate byte flag_loan_gt_assets=A002101000>A001000000 if !missing(A002101000,A001000000)

table_metrics, table(balance_raw) fields(Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000)
generate str64 exclusion_reason=""
replace exclusion_reason="not consolidated" if Typrep!="A"
replace exclusion_reason="not December 31" if Typrep=="A" & !(month(report_date)==12 & day(report_date)==31)
replace exclusion_reason="invalid date" if missing(report_date)
replace exclusion_reason="outside 2006-2019" if !missing(report_date) & !inrange(year,2006,2019)
preserve
    keep if !annual_selected
    save "$OUT/balance_other_records.dta"
restore
keep if annual_selected
drop flag_key_missing flag_duplicate_key
check_key Stkcd year
table_metrics, table(balance_annual) fields(Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000)
save_review balance_annual
sort Stkcd year
save "$OUT/balance_annual.dta"
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas(1).dta", clear
post $SOURCE_HANDLE (16) ("01_raw/06_balance_sheet/FS_Combas(1).dta") (_N)
generate int source_id = 16
generate long source_row = _n

check_key Stkcd Accper Typrep
datestring Accper, generate(report_date)
generate int year=year(report_date)
generate byte flag_date_invalid=missing(report_date)
generate byte flag_report_type_unknown=!inlist(Typrep,"A","B")
generate byte flag_code_invalid=!regexm(Stkcd,"^[0-9][0-9][0-9][0-9][0-9][0-9]$")
generate byte annual_selected=Typrep=="A" & month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019)

generate byte flag_parent_equity_missing=missing(A003100000)
generate byte flag_total_equity_missing=missing(A003000000)
generate byte flag_parent_equity_nonpositive=A003100000<=0 if !missing(A003100000)
generate byte flag_total_equity_nonpositive=A003000000<=0 if !missing(A003000000)

table_metrics, table(equity_raw) fields(Stkcd ShortName Accper Typrep A003100000 A003000000)
generate str64 exclusion_reason=""
replace exclusion_reason="not consolidated" if Typrep!="A"
replace exclusion_reason="not December 31" if Typrep=="A" & !(month(report_date)==12 & day(report_date)==31)
replace exclusion_reason="invalid date" if missing(report_date)
replace exclusion_reason="outside 2006-2019" if !missing(report_date) & !inrange(year,2006,2019)
preserve
    keep if !annual_selected
    save "$OUT/equity_other_records.dta"
restore
keep if annual_selected
drop flag_key_missing flag_duplicate_key
check_key Stkcd year
table_metrics, table(equity_annual) fields(Stkcd ShortName Accper Typrep A003100000 A003000000)
save_review equity_annual
sort Stkcd year
save "$OUT/equity_annual.dta"
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/07_income_statement/FS_Comins.dta", clear
post $SOURCE_HANDLE (18) ("01_raw/07_income_statement/FS_Comins.dta") (_N)
generate int source_id = 18
generate long source_row = _n

check_key Stkcd Accper Typrep
datestring Accper, generate(report_date)
generate int year=year(report_date)
generate byte flag_date_invalid=missing(report_date)
generate byte flag_report_type_unknown=!inlist(Typrep,"A","B")
generate byte flag_code_invalid=!regexm(Stkcd,"^[0-9][0-9][0-9][0-9][0-9][0-9]$")
generate byte annual_selected=Typrep=="A" & month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019)

generate byte flag_profit_missing=missing(B002000000)
* 净利润为负是亏损，不是数据错误，不因此筛除。
generate byte flag_profit_negative=B002000000<0 if !missing(B002000000)

table_metrics, table(income_raw) fields(Stkcd ShortName Accper Typrep B002000000)
generate str64 exclusion_reason=""
replace exclusion_reason="not consolidated" if Typrep!="A"
replace exclusion_reason="not December 31" if Typrep=="A" & !(month(report_date)==12 & day(report_date)==31)
replace exclusion_reason="invalid date" if missing(report_date)
replace exclusion_reason="outside 2006-2019" if !missing(report_date) & !inrange(year,2006,2019)
preserve
    keep if !annual_selected
    save "$OUT/income_other_records.dta"
restore
keep if annual_selected
drop flag_key_missing flag_duplicate_key
check_key Stkcd year
table_metrics, table(income_annual) fields(Stkcd ShortName Accper Typrep B002000000)
save_review income_annual
sort Stkcd year
save "$OUT/income_annual.dta"
