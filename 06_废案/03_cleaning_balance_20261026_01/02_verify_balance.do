version 19.0
set more off
confirm new file "verification.log"
confirm new file "quality_review.csv"
log using "verification.log", text
use "balance_annual_2006_2019.dta", clear
isid Stkcd year
assert Typrep=="A"
assert report_md=="12-31"
assert inrange(year,2006,2019)
count
list Stkcd ShortName year A001101000 A001000000 A002101000 if flag_assets_nonpositive==1, noobs
list Stkcd ShortName year A001101000 A001000000 A002101000 if flag_loan_gt_assets==1, noobs
preserve
    keep if any_quality_flag==1
    keep source_row Stkcd ShortName Accper year A001101000 A001000000 A002101000 flag_* any_quality_flag
    export delimited using "quality_review.csv"
restore
* 重组全部记录并逐字段对比原文件，证明只筛选分流、没有修改原值。
append using "balance_excluded_records.dta"
isid source_row
assert _N==182596
sort source_row
assert source_row==_n
cf Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000 using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas.dta", all
display "BALANCE_VERIFICATION_PASSED"
log close
