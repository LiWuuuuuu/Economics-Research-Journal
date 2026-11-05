* ==================================================
* 第9步：核心解释变量与崩盘风险合并
* 9.1 合并DH与次年股价崩盘风险
* ==================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
use "崩盘风险.dta", clear
describe stock year risk_year FNCSKEW FDUVOL
isid stock year
assert !missing(year, risk_year)
assert risk_year == year + 1
count
* 合并DH数据
merge 1:1 stock year using "存贷双高_初步构造.dta"
tabulate _merge
* 成功匹配的观测数量
count if _merge == 3
* 检查成功匹配但核心变量缺失的数量
count if _merge == 3 & missing(DH, FNCSKEW, FDUVOL)
* 检查核心变量全部有效的观测数量
count if _merge == 3 & !missing(DH, FNCSKEW, FDUVOL)
* 保存完整合并记录
save "09_核心变量合并检查.dta", replace
* 保留成功匹配的公司年度
keep if _merge == 3
* 检查时间关系
assert !missing(year, risk_year)
assert risk_year == year + 1
* 删除合并状态变量
drop _merge
* 再次检查公司年度唯一性
isid stock year
* 查看最终观测数量
count
* 查看DH的分布
tabulate DH, missing
* 查看年份分布
tabulate year

save "09_核心XY合并_初步.dta", replace
