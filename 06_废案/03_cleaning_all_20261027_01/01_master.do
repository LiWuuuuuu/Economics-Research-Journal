version 19.0
set more off
set linesize 180
* 在本程序目录运行：do 01_master.do run_01
* 每次使用新的运行目录；不使用replace覆盖任何交付文件。
args run_name
if "`run_name'" == "" local run_name "run_01"
mkdir "`run_name'"
global OUT "`c(pwd)'/`run_name'"
log using "$OUT/master.log", text
tempname audit sources
postfile `audit' str32 table str80 metric double value using "$OUT/audit_metrics.dta"
postfile `sources' int source_id str160 relative_path long rows using "$OUT/source_rows.dta"
global AUDIT_HANDLE `audit'
global SOURCE_HANDLE `sources'
do 02_helpers.do
do 03_financial.do
do 04_market_weekly.do
do 05_stock_weekly.do
do 06_capital_company.do
do 07_daily.do
do 08_shareholders.do
do 09_audit.do
do 10_financial_panel.do
do 11_excel_reference.do
postclose `audit'
postclose `sources'
use "$OUT/audit_metrics.dta", clear
export delimited using "$OUT/audit_metrics.csv"
use "$OUT/source_rows.dta", clear
isid source_id
export delimited using "$OUT/source_rows.csv"
display "ALL_TABLES_CLEANING_COMPLETED"
log close
