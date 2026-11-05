* ========================================
* README 第7步：历史行业数据清洗与合并
* ========================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"
*导入历史行业数据
import excel "../raw/STK_LISTEDCOINFOANL.xlsx", firstrow allstring clear
*检查数据结构
describe
*查看前10条行业记录
list 股票代码 统计截止日期 行业代码C 行业名称C in 1/10, noobs
*保留本阶段所需字段
keep 股票代码 统计截止日期 行业代码C 行业名称C
*统一变量名称
rename 股票代码 stock
rename 统计截止日期 industry_date
rename 行业代码C indcode
rename 行业名称C indname
*从统计截止日期提取年份
gen int year = real(substr(industry_date, 1, 4))
*清理代码中的空格
replace stock = strtrim(stock)
replace indcode = upper(strtrim(indcode))
*检查股票代码格式
count if !regexm(stock, "^[0-9]{1,6}$") & !missing(stock)
isid stock year
*检查年份和行业信息缺失
misstable summarize stock year indcode indname, all
*检查公司—年份重复
duplicates report stock year
keep stock year indcode indname
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
save "公司行业代码_清洗完成.dta", replace
use "资产负债表clean.dta", clear
isid stock year

merge 1:1 stock year using "公司行业代码_清洗完成.dta"
keep if _merge == 3
tabulate _merge
