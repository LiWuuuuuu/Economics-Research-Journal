use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/01_weekly_market/TRD_Weekm.dta", clear
post $SOURCE_HANDLE (2) ("01_raw/01_weekly_market/TRD_Weekm.dta") (_N)
generate int source_id = 2
generate long source_row = _n

check_key Markettype Trdwnt
generate int year=real(substr(Trdwnt,1,4))
generate byte week_number=real(substr(Trdwnt,6,2))
generate byte flag_week_invalid=!regexm(Trdwnt,"^[0-9][0-9][0-9][0-9]-[0-9][0-9]$") | !inrange(week_number,1,53)
generate byte flag_outside_window=!inrange(year,2006,2019)
generate byte flag_market_unknown=!inlist(Markettype,1,2,4,8,16,32,64)
generate byte flag_return_missing=missing(Wretwdeq) | missing(Wretwdos) | missing(Wretwdtl)
generate byte flag_return_below_minus1=(Wretwdeq< -1 | Wretwdos< -1 | Wretwdtl< -1)
generate byte is_A_market=inlist(Markettype,1,4,16,32,64)
table_metrics, table(market_weekly) fields(Markettype Trdwnt Wretwdeq Wretwdos Wretwdtl)
save_review market_weekly
sort Markettype Trdwnt
save "$OUT/market_weekly_clean.dta"
* 三个原始市场收益率口径均保留；不擅自指定作者采用何种加权法。
