* ==========================================
* 第6步：资产负债表数据清洗
* ==========================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
use "FS_Combas_merged_A_2006_2019.dta", clear
count
describe Stkcd Accper Typrep
*保留合并报表
keep if Typrep == "A"
*保留12月31日的资产负债表
keep if substr(Accper, 6, 5) == "12-31"
*生成年份变量
gen int year = real(substr(Accper, 1, 4))
*统一关键变量名称
rename Stkcd stock
rename Accper accper
rename Typrep report_type
*统一股票代码并检查公司—年份唯一性

* 检查股票代码是否为字符串
capture confirm string variable stock

* 如果是数值型，转换为六位字符串
if _rc {
    tostring stock, replace format(%06.0f)
}

* 删除股票代码首尾多余空格
replace stock = strtrim(stock)

* 检查年份是否缺失
count if missing(year)

* 检查证券代码是否缺失
count if missing(stock)
duplicates report stock year
isid stock year
*统一核心财务变量名称
*货币资金
rename A001101000 cash
*短期借款
rename A002101000 short_debt
*资产总计
rename A001000000 total_assets
* 添加中文变量标签
label variable cash "货币资金"
label variable short_debt "短期借款"
label variable total_assets "资产总计"

describe stock year cash short_debt total_assets

*检查财务变量缺失值
*汇总缺失值情况
misstable summarize cash short_debt total_assets, all
* 分别统计三个财务变量的缺失数量
count if missing(cash)
count if missing(short_debt)
count if missing(total_assets)

*检查异常值并生成标记变量
count if total_assets <= 0 & !missing(total_assets)
*统计货币资金小于0的记录
count if cash < 0 & !missing(cash)
*统计短期借款小于0的记录
count if short_debt < 0 & !missing(short_debt)

*标记三个核心财务变量存在缺失的观测
gen byte fin_missing = missing(cash, short_debt, total_assets)

*标记存在明显异常金额的观测
gen byte fin_invalid = ///
    (!missing(total_assets) & total_assets <= 0) | ///
    (!missing(cash) & cash < 0) | ///
    (!missing(short_debt) & short_debt < 0)

*查看缺失与异常记录数量
tabulate fin_missing, missing
tabulate fin_invalid, missing
*查看财务变量的描述性统计
summarize cash short_debt total_assets, detail

*检查年份分布
tabulate year

save "资产负债表clean.dta", replace
