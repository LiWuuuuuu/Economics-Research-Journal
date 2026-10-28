* Excel仅为最初下载测试表，单独核查，不与正式dta重复合并。
import excel using "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/09_original_download_test/FS_Combas.xlsx", firstrow allstring clear
generate long source_row=_n+1
generate byte flag_code_invalid=!regexm(Stkcd,"^[0-9][0-9][0-9][0-9][0-9][0-9]$")
datestring Accper, generate(report_date)
generate int year=year(report_date)
generate byte flag_date_invalid=missing(report_date)
table_metrics, table(excel_reference) fields(Stkcd ShortName Accper Typrep)
save "$OUT/excel_reference_imported.dta"
keep if !flag_code_invalid & !flag_date_invalid
check_key Stkcd Accper Typrep
save "$OUT/excel_reference_valid_keys.dta"
