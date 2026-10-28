version 19.0
set more off
set linesize 180
args run_name
if "`run_name'" == "" local run_name "run_01"
global OUT "`c(pwd)'/`run_name'"
log using "$OUT/verification.log", text
tempname checks
postfile `checks' int source_id str160 source long rows byte raw_values_match using "$OUT/source_verification.dta"
use "$OUT/balance_annual.dta", clear
append using "$OUT/balance_other_records.dta"
isid source_id source_row
frame put Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000 source_row if source_id==17, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000 using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas.dta", all
frame sourcecheck: count
post `checks' (17) ("01_raw/06_balance_sheet/FS_Combas.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/equity_annual.dta", clear
append using "$OUT/equity_other_records.dta"
isid source_id source_row
frame put Stkcd ShortName Accper Typrep A003100000 A003000000 source_row if source_id==16, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd ShortName Accper Typrep A003100000 A003000000 using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/06_balance_sheet/FS_Combas(1).dta", all
frame sourcecheck: count
post `checks' (16) ("01_raw/06_balance_sheet/FS_Combas(1).dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/income_annual.dta", clear
append using "$OUT/income_other_records.dta"
isid source_id source_row
frame put Stkcd ShortName Accper Typrep B002000000 source_row if source_id==18, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd ShortName Accper Typrep B002000000 using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/07_income_statement/FS_Comins.dta", all
frame sourcecheck: count
post `checks' (18) ("01_raw/07_income_statement/FS_Comins.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/market_weekly_clean.dta", clear
isid source_id source_row
frame put Markettype Trdwnt Wretwdeq Wretwdos Wretwdtl source_row if source_id==2, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Markettype Trdwnt Wretwdeq Wretwdos Wretwdtl using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/01_weekly_market/TRD_Weekm.dta", all
frame sourcecheck: count
post `checks' (2) ("01_raw/01_weekly_market/TRD_Weekm.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/stock_weekly_clean.dta", clear
isid source_id source_row
frame put Stkcd Trdwnt Clsdt Ndaytrd Wretwd Markettype source_row if source_id==3, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trdwnt Clsdt Ndaytrd Wretwd Markettype using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/02_weekly_stock/TRD_Week.dta", all
frame sourcecheck: count
post `checks' (3) ("01_raw/02_weekly_stock/TRD_Week.dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trdwnt Clsdt Ndaytrd Wretwd Markettype source_row if source_id==4, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trdwnt Clsdt Ndaytrd Wretwd Markettype using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/02_weekly_stock/TRD_Week1.dta", all
frame sourcecheck: count
post `checks' (4) ("01_raw/02_weekly_stock/TRD_Week1.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/daily_trading_clean.dta", clear
isid source_id source_row
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==5, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr(2).dta", all
frame sourcecheck: count
post `checks' (5) ("01_raw/03_daily_trading/TRD_Dalyr(2).dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==6, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr(4).dta", all
frame sourcecheck: count
post `checks' (6) ("01_raw/03_daily_trading/TRD_Dalyr(4).dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==7, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr(5).dta", all
frame sourcecheck: count
post `checks' (7) ("01_raw/03_daily_trading/TRD_Dalyr(5).dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==8, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr1(2).dta", all
frame sourcecheck: count
post `checks' (8) ("01_raw/03_daily_trading/TRD_Dalyr1(2).dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==9, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr1(3).dta", all
frame sourcecheck: count
post `checks' (9) ("01_raw/03_daily_trading/TRD_Dalyr1(3).dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==10, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr1.dta", all
frame sourcecheck: count
post `checks' (10) ("01_raw/03_daily_trading/TRD_Dalyr1.dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==11, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr2(1).dta", all
frame sourcecheck: count
post `checks' (11) ("01_raw/03_daily_trading/TRD_Dalyr2(1).dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==12, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr2.dta", all
frame sourcecheck: count
post `checks' (12) ("01_raw/03_daily_trading/TRD_Dalyr2.dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta source_row if source_id==13, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Trddt Dnshrtrd Dsmvosd Dsmvtll Markettype Trdsta using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/03_daily_trading/TRD_Dalyr3.dta", all
frame sourcecheck: count
post `checks' (13) ("01_raw/03_daily_trading/TRD_Dalyr3.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/capital_events_clean.dta", clear
isid source_id source_row
frame put Stkcd Shrchgdt Shrtyp Nshrttl Nshra source_row if source_id==14, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Shrchgdt Shrtyp Nshrttl Nshra using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/04_share_capital/TRD_Capchg.dta", all
frame sourcecheck: count
post `checks' (14) ("01_raw/04_share_capital/TRD_Capchg.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/company_snapshot_clean.dta", clear
isid source_id source_row
frame put Stkcd Stknme Listdt Nnindcd Nnindnme PROVINCE PROVINCECODE Markettype source_row if source_id==15, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Stknme Listdt Nnindcd Nnindnme PROVINCE PROVINCECODE Markettype using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/05_company_info/TRD_Co.dta", all
frame sourcecheck: count
post `checks' (15) ("01_raw/05_company_info/TRD_Co.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/shareholders_detail_clean.dta", clear
isid source_id source_row
frame put Stkcd Reptdt S0301a S0306a S0304a source_row if source_id==19, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Reptdt S0301a S0306a S0304a using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/08_shareholders/HLD_Shareholders.dta", all
frame sourcecheck: count
post `checks' (19) ("01_raw/08_shareholders/HLD_Shareholders.dta") (r(N)) (1)
frame drop sourcecheck
frame put Stkcd Reptdt S0301a S0306a S0304a source_row if source_id==20, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Reptdt S0301a S0306a S0304a using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/08_shareholders/HLD_Shareholders1.dta", all
frame sourcecheck: count
post `checks' (20) ("01_raw/08_shareholders/HLD_Shareholders1.dta") (r(N)) (1)
frame drop sourcecheck
use "$OUT/audit_detail_clean.dta", clear
isid source_id source_row
frame put Stkcd Stknme Accper Annodt Audittyp Dadtunit Iadtunit source_row if source_id==1, into(sourcecheck)
frame sourcecheck: sort source_row
frame sourcecheck: assert source_row==_n
frame sourcecheck: cf Stkcd Stknme Accper Annodt Audittyp Dadtunit Iadtunit using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/010_fin_audit/FIN_Audit.dta", all
frame sourcecheck: count
post `checks' (1) ("01_raw/010_fin_audit/FIN_Audit.dta") (r(N)) (1)
frame drop sourcecheck
postclose `checks'
use "$OUT/source_verification.dta", clear
assert raw_values_match==1
assert _N==20
export delimited using "$OUT/source_verification.csv"
display "ALL_20_ORIGINAL_DATASETS_MATCH"
log close
