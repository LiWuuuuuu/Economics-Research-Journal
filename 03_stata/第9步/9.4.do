* ======================================================
* 第9.4步：控制变量整理
* ======================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"
confirm file "../raw/Control/mb.csv"

* 导入CSV
* 第一列强制按字符串读取，避免股票代码问题
import delimited using "../raw/Control/mb.csv", varnames(1) stringcols(1) clear encoding("UTF-8")
count
rename mb MB
rename mb_parent MB_parent
rename mb_ta MB_ta
describe stock year MB MB_parent MB_ta
list stock year MB MB_parent MB_ta in 1/10, noobs
* 统一公司代码、年份和变量类型
* 检查股票代码是否都是1至6位数字
count if !regexm(strtrim(stock), "^[0-9]{1,6}$")
*如果存在异常代码，停止运行
assert regexm(strtrim(stock), "^[0-9]{1,6}$")
*统一为六位字符串
gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock
* 如果年份被读取成字符串，则转换为数值
capture confirm string variable year
if _rc == 0 {
    destring year, replace
}
* 如果MB被读取成字符串，则转换为数值
capture confirm string variable MB
if _rc == 0 {
    destring MB, replace ignore(",")
}

describe stock year MB

isid stock year

*筛选研究年份并检查MB
* 保留当前财务研究期
keep if inrange(year, 2007, 2018)

tabulate year

count if missing(MB)

* 检查MB是否存在非正值
count if MB <= 0 & !missing(MB)

* 检查极端值
count if MB > 100 & !missing(MB)

* 查看MB分布
summarize MB, detail

label variable MB "市值账面比：市值/账面股东权益"
keep stock year MB
isid stock year
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

save "09_MB_公司年度_初步.dta", replace

use "09_核心XY_添加SizeGROWTHRetROA_初步.dta", clear

describe DH FNCSKEW FDUVOL Size GROWTH Ret ROA
count

assert _N == 29092

isid stock year

* 防止意外覆盖已有MB字段
capture confirm variable MB
if _rc == 0 {
    display as error "主数据已有MB，请先核查，不要重复合并"
    exit 459
}

* 将MB合并到核心研究数据

merge 1:1 stock year using "09_MB_公司年度_初步.dta", keep(master match) keepusing(MB) gen(merge_mb)

tabulate merge_mb

tabulate year merge_mb
count if merge_mb == 1

* 匹配成功但MB为空的记录
count if merge_mb == 3 & missing(MB)

* MB总缺失数量
count if missing(MB)


*检查MB数值及样本质量

summarize MB, detail

* 检查非正MB
count if MB <= 0 & !missing(MB)

* 检查极端MB
count if MB > 100 & !missing(MB)

* 临时查看最大的10条有效MB
preserve

keep if !missing(MB)
gsort -MB

list stock year MB in 1/10, noobs

restore

* 检查主要控制变量缺失
misstable summarize Size GROWTH Ret ROA MB, all

* 查看所有主要研究变量的描述性统计
summarize DH FNCSKEW FDUVOL Size GROWTH Ret ROA MB


assert _N == 29092


isid stock year

* 检查财务年份与风险年份
assert !missing(year, risk_year)
assert risk_year == year + 1
* 保存第9.4步成果
save "09_核心XY_添加SizeGROWTHRetROAMB_初步.dta", replace
