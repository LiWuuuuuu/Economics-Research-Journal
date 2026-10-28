use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/010_fin_audit/FIN_Audit.dta", clear
post $SOURCE_HANDLE (1) ("01_raw/010_fin_audit/FIN_Audit.dta") (_N)
generate int source_id = 1
generate long source_row = _n

check_key Stkcd Accper
datestring Accper, generate(report_date)
datestring Annodt, generate(audit_date)
generate int year=year(report_date)
generate byte flag_date_invalid=missing(report_date)
generate byte flag_audit_date_invalid=missing(audit_date)
generate str200 domestic_auditor_clean=ustrtrim(Dadtunit)
generate str200 foreign_auditor_clean=ustrtrim(Iadtunit)
foreach v in domestic_auditor_clean foreign_auditor_clean {
    replace `v'="" if inlist(ustrlower(`v'),"none","null","nan","n/a")
}
generate byte flag_domestic_auditor_missing=missing(domestic_auditor_clean)
generate byte flag_foreign_auditor_missing=missing(foreign_auditor_clean)
* 四大名称匹配可供复核，境内与境内外任一家两种口径分别输出。
generate byte Big4_domestic=ustrregexm(ustrlower(domestic_auditor_clean),"普华永道|安永|德勤|毕马威|pricewaterhouse|ernst.*young|deloitte|kpmg") if !missing(domestic_auditor_clean)
generate byte Big4_foreign=ustrregexm(ustrlower(foreign_auditor_clean),"普华永道|安永|德勤|毕马威|pricewaterhouse|ernst.*young|deloitte|kpmg") if !missing(foreign_auditor_clean)
generate byte Big4_any=1 if Big4_domestic==1 | Big4_foreign==1
replace Big4_any=0 if missing(Big4_any) & (!missing(Big4_domestic) | !missing(Big4_foreign))
generate byte flag_big4_scope_difference=Big4_any!=Big4_domestic if !missing(Big4_any,Big4_domestic)
table_metrics, table(audit_detail) fields(Stkcd Stknme Accper Annodt Audittyp Dadtunit Iadtunit)
save_review audit_detail
save "$OUT/audit_detail_clean.dta"
preserve
    contract domestic_auditor_clean foreign_auditor_clean Big4_domestic Big4_foreign Big4_any, freq(rows)
    export delimited using "$OUT/auditor_name_mapping.csv"
restore
preserve
    keep if !(month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019))
    save "$OUT/audit_other_records.dta"
restore
keep if month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019)
table_metrics, table(audit_annual) fields(Stkcd year Accper Dadtunit Iadtunit Big4_domestic Big4_any)
isid Stkcd year
sort Stkcd year
save "$OUT/audit_annual.dta"
