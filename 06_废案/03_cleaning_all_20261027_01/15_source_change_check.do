version 19.0
set more off
set linesize 180
log using "run_01/source_change_check.log", text
local raw "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas.dta"
use "`raw'", clear
describe
count
local ncurrent=_N
assert check_year==substr(Accper,1,4)
assert check_md==substr(Accper,6,5)
use "run_01/balance_annual.dta", clear
append using "run_01/balance_other_records.dta"
sort source_row
assert source_row==_n
assert _N==`ncurrent'
cf Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000 using "`raw'", all
display "ORIGINAL_SEVEN_FIELDS_UNCHANGED_ADDITIONAL_CHECK_FIELDS_CONFIRMED"
log close
