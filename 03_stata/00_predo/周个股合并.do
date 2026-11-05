cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
*数据合并
use "TRD_Week_clean1.dta",clear
forvalues i = 2/4{
	append using "TRD_Week_clean`i'.dta"
}
save "周个股合并.dta",replace
