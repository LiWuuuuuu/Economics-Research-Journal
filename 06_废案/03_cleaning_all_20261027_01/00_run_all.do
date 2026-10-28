version 19.0
set more off
args run_name
if "`run_name'"=="" local run_name "run_02"
do 01_master.do "`run_name'"
do 12_verify_all_sources.do "`run_name'"
do 13_quality_checks.do "`run_name'"
do 14_annual_master_verified.do "`run_name'"
display "ALL_CLEANING_AND_VERIFICATION_COMPLETED"
