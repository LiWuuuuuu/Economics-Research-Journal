version 19.0
set more off
* 本程序在独立批处理进程执行，不影响用户打开的 Stata 窗口。
* 在本 do 文件所在的新输出文件夹运行；已有输出时立即停止，绝不覆盖。
local raw "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas.dta"
foreach f in cleaning.log audit_counts.dta audit_counts.csv annual_counts.csv balance_annual_2006_2019.dta balance_flagged_rows.dta balance_excluded_records.dta {
    confirm new file "`f'"
}
log using "cleaning.log", text
confirm file "`raw'"
use "`raw'", clear
describe
count
local n_raw = _N
* 原始行号用来追溯；原始7字段均保留。
generate long source_row = _n
count if missing(Stkcd) | missing(Accper) | missing(Typrep)
assert !missing(Stkcd) & !missing(Accper) & !missing(Typrep)
assert strlen(Stkcd)==6
assert regexm(Stkcd,"^[0-9][0-9][0-9][0-9][0-9][0-9]$")
duplicates report Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000
isid Stkcd Accper Typrep
* 使用会计截止日期，而非报告披露年份；日期无法解析时停止。
generate double report_date = daily(Accper,"YMD")
format report_date %tdCCYY-NN-DD
assert !missing(report_date)
assert Accper == string(report_date,"%tdCCYY-NN-DD")
generate int year = year(report_date)
generate str5 report_md = substr(Accper,6,5)
tabulate year, missing
tabulate report_md, missing
tabulate Typrep, missing
* 年度基础表保留2006—2019年；回归解释变量2007—2018年在后续合并时限定。
generate byte keep_annual = Typrep=="A" & month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019)
generate str80 exclusion_reason = ""
replace exclusion_reason = "Not consolidated" if Typrep!="A"
replace exclusion_reason = "Not December 31" if Typrep=="A" & report_md!="12-31"
replace exclusion_reason = "Outside 2006-2019" if Typrep=="A" & report_md=="12-31" & !inrange(year,2006,2019)
count if !keep_annual
local n_excluded = r(N)
preserve
    keep if !keep_annual
    save "balance_excluded_records.dta"
restore
keep if keep_annual
local n_annual = _N
assert `n_raw' == `n_excluded' + `n_annual'
isid Stkcd year
sort Stkcd year
* 全部财务原值保留。缺失不等于0；可疑值只标记，待结合行业等信息复核。
generate byte flag_cash_missing = missing(A001101000)
generate byte flag_assets_missing = missing(A001000000)
generate byte flag_loan_missing = missing(A002101000)
generate byte flag_cash_negative = A001101000<0 if !missing(A001101000)
generate byte flag_assets_nonpositive = A001000000<=0 if !missing(A001000000)
generate byte flag_loan_negative = A002101000<0 if !missing(A002101000)
generate byte flag_cash_gt_assets = A001101000>A001000000 if !missing(A001101000,A001000000)
generate byte flag_loan_gt_assets = A002101000>A001000000 if !missing(A002101000,A001000000)
egen byte any_quality_flag = rowmax(flag_*)
label variable any_quality_flag "Any missing or suspicious financial value; retained"
label variable year "Fiscal year from accounting period end"
label variable source_row "Row number in original FS_Combas.dta"
misstable summarize A001101000 A001000000 A002101000
summarize A001101000 A001000000 A002101000, detail
tabulate year, missing
tabulate any_quality_flag
* 机器可读的审计统计。
tempname audit
postfile `audit' str80 metric double value using "audit_counts.dta"
post `audit' ("raw_rows") (`n_raw')
post `audit' ("excluded_nonannual_or_outside_window") (`n_excluded')
post `audit' ("annual_rows") (`n_annual')
post `audit' ("duplicate_company_year_surplus") (0)
egen byte company_tag = tag(Stkcd)
count if company_tag
post `audit' ("annual_companies") (r(N))
foreach f of varlist flag_* any_quality_flag {
    count if `f'==1
    post `audit' ("`f'") (r(N))
}
count if inrange(year,2007,2018)
post `audit' ("annual_rows_2007_2018_before_other_filters") (r(N))
postclose `audit'
drop company_tag
save "balance_annual_2006_2019.dta"
preserve
    keep if any_quality_flag==1
    save "balance_flagged_rows.dta"
restore
preserve
    collapse (count) observations=source_row (sum) flag_*, by(year)
    export delimited using "annual_counts.csv"
restore
preserve
    use "audit_counts.dta", clear
    list, noobs abbreviate(50)
    export delimited using "audit_counts.csv"
restore
display "BALANCE_CLEANING_COMPLETED"
log close
