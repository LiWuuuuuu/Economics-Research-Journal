* ==================================================
* 第9步：添加控制变量
* 9.2 构造 Size、GROWTH、Ret
* ==================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
* 使用完整资产负债表构造Size和GROWTH
use "资产负债表clean.dta", clear
isid stock year
keep stock year total_assets
* 企业规模：年末总资产自然对数
gen double Size = ln(total_assets) if total_assets > 0 & !missing(total_assets)
* 按公司和年份排序
sort stock year
* 资产增长率：只使用上一自然年
by stock: gen double GROWTH = (total_assets - total_assets[_n-1]) / total_assets[_n-1] if _n > 1 & year == year[_n-1] + 1 & !missing(total_assets, total_assets[_n-1]) & total_assets[_n-1] > 0
* 添加变量标签
label variable Size "企业规模：年末总资产自然对数"
label variable GROWTH "总资产同比增长率"
* 检查结果
summarize Size GROWTH, detail
* 保存公司年度控制变量
keep stock year Size GROWTH
isid stock year
save "09_SizeGROWTH_公司年度.dta", replace
*合并到第9.1步的核心XY数据
use "09_核心XY合并_初步.dta", clear
count
isid stock year
merge 1:1 stock year using "09_SizeGROWTH_公司年度.dta", keep(master match) keepusing(Size GROWTH) gen(merge_sizegrowth)
tabulate merge_sizegrowth
* 检查缺失数量
count if missing(Size)
count if missing(GROWTH)
summarize Size GROWTH, detail
isid stock year
save "09_核心XY_添加SizeGROWTH.dta", replace


* 构造并合并股票年度平均收益率 Ret
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
use "周收益率_回归完成.dta", clear
* 统计公司每年的周记录数
bysort stock year: gen int weekly_obs = _N
* 查看公司年度周记录分布
summarize weekly_obs, detail
* 删除临时检查变量
drop weekly_obs
* 9.2.4.4 计算公司年度平均周收益率
* Ret：同一年有效个股周收益率的算术平均
* Nret：参与计算的有效周收益率数量
collapse (mean) Ret=ri (count) Nret=ri, by(stock year)
* 检查Ret是否正确生成
isid stock year
* 查看年度收益率分布
summarize Ret, detail
* 查看有效周数分布
summarize Nret, detail
* 检查多少个公司年度有超过1个有效周收益率
count if Nret > 1
* 检查是否出现把年份误当成收益率的情况
count if inrange(Ret, 2000, 2100)
* 查看前20条结果
sort stock year
list stock year Ret Nret in 1/20, noobs
label variable Ret "当年平均个股周收益率"
label variable Nret "年度有效个股周收益率数量"
* 保存修正后的年度收益率数据
save "09_Ret_公司年度.dta", replace
* 读取已有核心XY数据
use "09_核心XY_添加SizeGROWTH.dta", clear
count
isid stock year
* 合并Ret
merge 1:1 stock year using "09_Ret_公司年度.dta", keep(master match) keepusing(Ret Nret) gen(merge_ret)
* 查看匹配情况
tabulate merge_ret
* 检查Ret缺失数量
count if missing(Ret)
* 查看Ret缺失集中在哪些年份
tabulate year if missing(Ret)
* 检查Ret和有效周数
summarize Ret Nret, detail
count
* 检查公司—年份唯一性
isid stock year
* 核查被解释变量与核心解释变量是否保留
describe DH FNCSKEW FDUVOL Size GROWTH Ret
* 核查财务年份与风险年份
assert risk_year == year + 1
save "09_核心XY_添加SizeGROWTHRet.dta", replace
