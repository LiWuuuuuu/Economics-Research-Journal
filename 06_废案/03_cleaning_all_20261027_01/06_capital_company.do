use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/04_share_capital/TRD_Capchg.dta", clear
post $SOURCE_HANDLE (14) ("01_raw/04_share_capital/TRD_Capchg.dta") (_N)
generate int source_id = 14
generate long source_row = _n

check_key Stkcd Shrchgdt
datestring Shrchgdt, generate(cap_date)
generate int year=year(cap_date)
generate byte flag_date_invalid=missing(cap_date)
generate byte flag_total_shares_invalid=missing(Nshrttl) | Nshrttl<=0
generate byte flag_A_shares_missing=missing(Nshra)
generate byte flag_A_shares_nonpositive=Nshra<=0 if !missing(Nshra)
generate byte flag_A_shares_gt_total=Nshra>Nshrttl if !missing(Nshra,Nshrttl)
* 2006年前事件仍保留，用作2006年初流通股本的历史起点。
table_metrics, table(capital_events) fields(Stkcd Shrchgdt Shrtyp Nshrttl Nshra)
save_review capital_events
sort Stkcd cap_date
save "$OUT/capital_events_clean.dta"
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/05_company_info/TRD_Co.dta", clear
post $SOURCE_HANDLE (15) ("01_raw/05_company_info/TRD_Co.dta") (_N)
generate int source_id = 15
generate long source_row = _n

check_key Stkcd
datestring Listdt, generate(list_date)
generate str12 industry_snapshot=ustrtrim(Nnindcd)
generate str40 province_snapshot=ustrtrim(PROVINCE)
generate str12 province_code_snapshot=ustrtrim(PROVINCECODE)
foreach v in industry_snapshot province_snapshot province_code_snapshot {
    replace `v'="" if inlist(ustrlower(`v'),"none","null","nan","n/a")
}
generate byte flag_listing_date_invalid=missing(list_date)
generate byte flag_listed_after2019=list_date>mdy(12,31,2019) if !missing(list_date)
generate byte flag_industry_missing=missing(industry_snapshot)
generate byte flag_province_missing=missing(province_snapshot) | missing(province_code_snapshot)
generate byte snapshot_financial=substr(industry_snapshot,1,1)=="J" if !missing(industry_snapshot)
generate byte snapshot_realestate=substr(industry_snapshot,1,1)=="K" if !missing(industry_snapshot)
generate byte is_A_market=inlist(Markettype,1,4,16,32,64)
label variable industry_snapshot "Current snapshot; NOT annual historical industry"
label variable province_snapshot "Current snapshot; NOT annual historical province"
table_metrics, table(company_snapshot) fields(Stkcd Stknme Listdt Nnindcd Nnindnme PROVINCE PROVINCECODE Markettype)
save_review company_snapshot
sort Stkcd
save "$OUT/company_snapshot_clean.dta"
