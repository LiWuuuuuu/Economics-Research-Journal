* ==================================================
* 第9.3步：构造总资产收益率 ROA
* 导入并检查利润表
* ==================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"
import excel "FS_Comins.xlsx", firstrow clear
count

describe

describe Stkcd Accper Typrep

* 检查常见的净利润字段是否存在
capture confirm variable B002000000
if _rc == 0 {
    describe B002000000
    summarize B002000000
}


tabulate Typrep, missing

list in 1/5

*清洗年度合并利润表

* 1. 保留合并报表A
* 同时自动排除Excel中的字段说明行与单位行
keep if Typrep == "A"

* 2. 保留12月31日年度报表
keep if substr(Accper, 6, 5) == "12-31"

* 3. 提取财务年份
gen int year = real(substr(Accper, 1, 4))

keep if inrange(year, 2006, 2019)

rename Stkcd stock
replace stock = strtrim(stock)

count if missing(stock)
count if !regexm(stock, "^[0-9]{6}$") & !missing(stock)

describe B002000000
* 将字符串净利润转换为数值
* 如果出现无法转换的字符，先停止并检查
destring B002000000, generate(net_profit) ignore(",")

label variable net_profit "年度合并报表净利润"

*检查净利润缺失和分布
count if missing(net_profit)
summarize net_profit, detail
tabulate year
* 检查公司—年份重复
duplicates report stock year
keep stock year net_profit

cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
save "09_净利润_公司年度_初步.dta", replace


* 合并净利润与总资产，构造ROA
use "资产负债表clean.dta", clear
* 保留计算ROA所需字段
keep stock year total_assets

isid stock year

merge 1:1 stock year using "09_净利润_公司年度_初步.dta"
tabulate _merge
count if _merge == 1
count if _merge == 2

keep if _merge == 1 | _merge == 3
drop _merge

* 计算总资产收益率
gen double ROA = net_profit / total_assets if !missing(net_profit, total_assets) & total_assets > 0


label variable ROA "总资产收益率：净利润/期末总资产"
count if missing(ROA)
summarize ROA, detail
* 检查极端值，但暂不删除
count if ROA > 1 & !missing(ROA)
count if ROA < -1 & !missing(ROA)
isid stock year

* 保存公司年度ROA
keep stock year net_profit ROA
save "09_ROA_公司年度_初步.dta", replace


use "09_核心XY_添加SizeGROWTHRet.dta", clear

count
isid stock year

merge 1:1 stock year using "09_ROA_公司年度_初步.dta", keep(master match) keepusing(net_profit ROA) gen(merge_roa)

tabulate merge_roa

count if missing(ROA)

count if ROA > 1 & !missing(ROA)
count if ROA < -1 & !missing(ROA)
summarize DH FNCSKEW FDUVOL Size GROWTH Ret ROA

* 验证时间关系
assert risk_year == year + 1

isid stock year

count

save "09_核心XY_添加SizeGROWTHRetROA_初步.dta", replace
