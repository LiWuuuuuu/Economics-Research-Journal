tempfile p0 p1
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/08_shareholders/HLD_Shareholders.dta", clear
post $SOURCE_HANDLE (19) ("01_raw/08_shareholders/HLD_Shareholders.dta") (_N)
generate int source_id = 19
generate long source_row = _n
save `p0'
use "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw/paper_replication_raw_data_2026-10-21/01_raw/08_shareholders/HLD_Shareholders1.dta", clear
post $SOURCE_HANDLE (20) ("01_raw/08_shareholders/HLD_Shareholders1.dta") (_N)
generate int source_id = 20
generate long source_row = _n
save `p1'
use `p0', clear
append using `p1'

check_key Stkcd Reptdt S0306a
datestring Reptdt, generate(report_date)
generate int year=year(report_date)
generate byte flag_date_invalid=missing(report_date)
generate byte flag_outside_window=!inrange(year,2006,2019)
generate byte flag_rank_invalid=missing(S0306a) | S0306a<1 | S0306a!=floor(S0306a)
generate byte flag_rank_over10=S0306a>10 if !missing(S0306a)
generate byte flag_pct_missing=missing(S0304a)
generate byte flag_pct_outside=(!inrange(S0304a,0,100)) if !missing(S0304a)
generate byte flag_pct_zero=S0304a==0
generate str200 holder_name_clean=ustrtrim(S0301a)
generate byte flag_holder_missing=inlist(ustrlower(holder_name_clean),"","none","null","nan","n/a")
table_metrics, table(shareholders_detail) fields(Stkcd Reptdt S0301a S0306a S0304a)
save_review shareholders_detail
sort Stkcd report_date S0306a
save "$OUT/shareholders_detail_clean.dta"
* 原始明细完整保留，年度聚合仅对12月31日报告期计算。
keep if month(report_date)==12 & day(report_date)==31 & inrange(year,2006,2019)
generate byte in_top10=inrange(S0306a,1,10)
generate byte top10_observed=in_top10 & !missing(S0304a)
generate byte rank1_observed=S0306a==1 & !missing(S0304a)
generate double rank1_pct=S0304a if S0306a==1
generate double ranks2_10_pct=S0304a if inrange(S0306a,2,10)
generate double top10_pct=S0304a if in_top10
generate byte count_unit=1
collapse (sum) n_detail_rows=count_unit n_top10=in_top10 n_top10_observed=top10_observed n_rank1=rank1_observed sum_ranks2_10=ranks2_10_pct sum_top10=top10_pct n_over10=flag_rank_over10 (max) rank1_share=rank1_pct flag_duplicate_key flag_rank_invalid flag_pct_missing flag_pct_outside flag_holder_missing, by(Stkcd year Reptdt)
generate byte flag_incomplete_top10=n_top10!=10 | n_top10_observed!=10 | n_rank1!=1 | flag_duplicate_key
generate byte flag_sum_over100=sum_top10>100.0000001
generate byte flag_zero_denominator=sum_ranks2_10<=0
generate double Disp_raw=rank1_share/sum_ranks2_10 if !flag_incomplete_top10 & sum_ranks2_10>0
generate double Disp_checked=Disp_raw if !flag_sum_over100 & !flag_pct_outside & !flag_rank_invalid
label variable Disp_checked "Rank1 / sum ranks2-10; incomplete/invalid groups set missing; project rule"
table_metrics, table(shareholders_annual) fields(Stkcd year Reptdt rank1_share sum_ranks2_10 sum_top10 Disp_raw Disp_checked)
save_review shareholders_annual
isid Stkcd year
save "$OUT/shareholders_annual.dta"
