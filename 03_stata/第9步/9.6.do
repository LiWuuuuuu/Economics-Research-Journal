
* ==================================================
* 导入并合并国际四大审计变量 Big4
* ==================================================

cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"
confirm file "../raw/Control/Big4.csv"

import delimited using "../raw/Control/Big4.csv", ///
    varnames(1) stringcols(1) clear encoding("UTF-8")


* Stata默认将变量名转为小写
rename big4 Big4

* 股票代码统一为六位字符串
assert regexm(strtrim(stock), "^[0-9]{1,6}$")

gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock

* 确认年份为数值型
capture confirm string variable year
if _rc == 0 {
    destring year, replace
}

* 确认Big4为数值型
capture confirm string variable Big4
if _rc == 0 {
    destring Big4, replace
}

* 9.6.4 检查Big4变量
assert inlist(Big4, 0, 1)
isid stock year

tabulate Big4, missing
tabulate year

* 保留研究期
keep if inrange(year, 2007, 2018)
* 添加变量标签
label variable Big4 "是否由国际四大会计师事务所审计"
* 保存年度Big4
keep stock year Big4
save "09_Big4_公司年度_初步.dta", replace
*合并到现有核心研究数据
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
use "09_核心XY_添加SizeGROWTHRetROAMBDturnt_初步.dta", clear

* 检查主数据
assert _N == 29092
isid stock year

* 合并Big4
merge 1:1 stock year using "09_Big4_公司年度_初步.dta", ///
    keep(master match) keepusing(Big4) gen(merge_big4)


* 主数据观测数应保持不变
assert _N == 29092

* 保存阶段性成果
save "09_核心XY_添加Big4_初步.dta", replace
