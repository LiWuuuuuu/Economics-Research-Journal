
* 第五步：构造股价崩盘风险指标

* 1. 读取Stata回归完成的数据
use "周收益率_回归完成.dta", clear

* 2. 检查主要变量
describe stock year weekstr epsilon Nreg reg_ok

* 3. 检查股票—周唯一性
isid stock weekstr
* 检查残差有效数量
count if !missing(epsilon)

* 检查不能进行ln(1+epsilon)转换的记录
count if epsilon <= -1 & !missing(epsilon)

* 计算公司特质周收益率
gen double W = ln(1 + epsilon) if epsilon > -1 & !missing(epsilon) & reg_ok == 1

* 查看生成结果
summarize W, detail

* 查看前10条记录
list stock year epsilon W in 1/10, noobs

* 统计每家公司每年的有效W数量
bysort stock year: egen int Nweek = count(W)

* 为每家公司每年标记一条记录
egen byte tag_fy = tag(stock year)

* 统计不满30个有效周的公司年度数量
count if tag_fy == 1 & Nweek < 30

* 统计至少30个有效周的公司年度数量
count if tag_fy == 1 & Nweek >= 30

* =========================================
* 第五步（一）：构造 NCSKEW
* =========================================

* 1. 计算每个有效周收益率的平方与立方
gen double W2 = W^2 if !missing(W)
gen double W3 = W^3 if !missing(W)

* 2. 按公司、年份计算平方和与立方和
bysort stock year: egen double sumW2 = total(W2)
bysort stock year: egen double sumW3 = total(W3)

* 3. 根据公式计算 NCSKEW
gen double NCSKEW = -Nweek*(Nweek-1)^(3/2)*sumW3 / ((Nweek-1)*(Nweek-2)*sumW2^(3/2)) if Nweek>=30 & sumW2>0 & sumW2<.

* 4. 检查结果（每个公司年度只统计一次）
count if tag_fy==1 & !missing(NCSKEW)
summarize NCSKEW if tag_fy==1, detail

* =========================================
* 第五步（二）：构造 DUVOL
* =========================================

* 1. 计算各公司年度的平均特质周收益率
bysort stock year: egen double Wmean = mean(W)

* 2. 区分上涨周和下跌周
gen byte down = (W < Wmean) if !missing(W)
gen byte up = (W >= Wmean) if !missing(W)

* 3. 计算上涨周和下跌周的数量
bysort stock year: egen int nd = total(down)
bysort stock year: egen int nu = total(up)

* 4. 分别计算上涨周、下跌周的平方和
gen double downW2 = W2 if down==1
gen double upW2 = W2 if up==1

bysort stock year: egen double sumdown2 = total(downW2)
bysort stock year: egen double sumup2 = total(upW2)

* 5. 计算 DUVOL
gen double DUVOL = ln(((nu-1)*sumdown2)/((nd-1)*sumup2)) if Nweek>=30 & nd>1 & nu>1 & sumdown2>0 & sumdown2<. & sumup2>0 & sumup2<.

* 6. 检查结果
count if tag_fy==1 & !missing(DUVOL)
summarize DUVOL if tag_fy==1, detail

* 统计两个风险指标均有效的公司年度数量
count if tag_fy==1 & !missing(NCSKEW, DUVOL)

* 分别统计两个指标的缺失情况
count if tag_fy==1 & Nweek>=30 & missing(NCSKEW)
count if tag_fy==1 & Nweek>=30 & missing(DUVOL)

* ==========================================
* 第五步（三）：生成公司年度股价崩盘风险数据
* ==========================================

* 1. 先保存当前周度计算结果，防止丢失
save "周收益率_风险指标计算中.dta", replace

* 2. 检查风险年份分布
tab year

* 3. 保留具有有效风险指标的公司年度
keep if tag_fy == 1 & !missing(NCSKEW, DUVOL) & inrange(year, 2008, 2019)

* 4. 仅保留后续需要的字段
keep stock year Nweek NCSKEW DUVOL

* 5. 保存风险发生的实际年份
rename year risk_year

* 6. 与上一年财务数据对齐
gen int year = risk_year - 1

* 7. 重命名为下一年崩盘风险变量
rename NCSKEW FNCSKEW
rename DUVOL FDUVOL

* 8. 验证公司年度唯一性和年份对应关系
isid stock year
assert risk_year == year + 1

* 9. 检查结果
count
tab year
summarize FNCSKEW FDUVOL, detail

* 10. 保存最终年度风险数据
save "崩盘风险.dta",replace
