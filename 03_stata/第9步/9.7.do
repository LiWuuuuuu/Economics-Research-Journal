* ==================================================
* 9.7整理和合并公司所属省份
* ==================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"

* 导入原始省份信息
import delimited using "../raw/Control/province.csv", ///
    varnames(1) stringcols(1) clear encoding("UTF-8")


* 股票代码统一为六位
assert regexm(strtrim(stock), "^[0-9]{1,6}$")

gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock

* 确认年份为数值型
capture confirm string variable year
if _rc == 0 {
    destring year, replace
}

* 保留公司、省份与年份信息
keep stock year province provincecode

* 检查唯一性和省份缺失
isid stock year
count if missing(province)

* 保存独立省份数据
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
save "09_公司年度所属省份.dta", replace

* 将省份合并进核心研究数据

use "09_核心XY_添加Big4_初步.dta", clear

isid stock year
assert _N == 29092

merge 1:1 stock year using "09_公司年度所属省份.dta", ///
    keep(master match) ///
    keepusing(province provincecode) ///
    gen(merge_province)

tabulate merge_province
count if missing(province)

assert _N == 29092
isid stock year
assert risk_year == year + 1

* 保存阶段性数据
save "09_核心XY_添加Big4省份_初步.dta", replace

* 构造省份×年份固定效应标识

cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
use "09_核心XY_添加Big4省份_初步.dta", clear

isid stock year
assert risk_year == year + 1

* 公司固定效应标识
egen long firm_id = group(stock)

* 行业×年份固定效应标识
egen long industry_year_fe = group(industry year)

* 省份×年份固定效应标识
egen long province_year_fe = group(provincecode year)
* 检查省份缺失
count if missing(province_year_fe)
* 检查固定效应分组数
codebook firm_id industry_year_fe province_year_fe

* 保存新主数据
save "09_核心XY_控制变量与固定效应_初步.dta", replace
