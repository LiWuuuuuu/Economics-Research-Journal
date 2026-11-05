* 将路径换成实际存放该文件的文件夹
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
* 读取回归前数据
use "周收益率_回归前.dta", clear
* 查看变量
describe
* 检查所需变量是否存在
describe stock year weekstr type tw ri rm_l2 rm_l1 rm rm_f1 rm_f2

* ==================================================
* 公司年度扩展市场模型回归
* Stata 19
* 目的：生成每个股票-年度的周度回归残差
* ==================================================

* 1. 读取数据
* 先用 cd 设置好实际工作目录
use "周收益率_回归前.dta", clear

* 2. 检查所需变量
foreach v in stock year weekstr type tw ri rm_l2 rm_l1 rm rm_f1 rm_f2 {
    confirm variable `v'
}

assert !missing(stock, year)
isid stock weekstr

* 3. 保存原始行顺序与行数
local N0 = _N
gen long __rowid = _n

* 4. 清除可能存在的旧回归结果
foreach v in epsilon Nreg reg_ok {
    capture drop `v'
}

* 5. 标记回归所需变量均非缺失的交易周
gen byte __valid = !missing(ri, rm_l2, rm_l1, rm, rm_f1, rm_f2)

* 6. 计算每家公司每年的有效交易周数量
bysort stock year: egen int __nvalid = total(__valid)

* 至少30个有效周才记录Nreg
gen double Nreg = __nvalid if __nvalid >= 30

* 7. 提取符合周数要求的数据并分组回归
preserve

keep if __valid == 1 & __nvalid >= 30

statsby b0=_b[_cons] b_l2=_b[rm_l2] b_l1=_b[rm_l1] b_rm=_b[rm] b_f1=_b[rm_f1] b_f2=_b[rm_f2] rk=e(rank), by(stock year) clear dots(500): regress ri rm_l2 rm_l1 rm rm_f1 rm_f2

* 保存每家公司每年的回归系数
save "公司年度回归系数_临时.dta", replace

* 8. 恢复全部原始观测
restore

* 9. 将回归系数匹配回周度数据
merge m:1 stock year using "公司年度回归系数_临时.dta", keep(master match)

tabulate _merge
assert _N == `N0'
drop _merge

* 10. 标记符合要求的回归观测
gen byte reg_ok = 0
replace reg_ok = 1 if __valid == 1 & !missing(Nreg, rk) & rk == 6

* 11. 计算残差：实际收益率减去拟合收益率
gen double epsilon = .

replace epsilon = ri - (b0 + b_l2*rm_l2 + b_l1*rm_l1 + b_rm*rm + b_f1*rm_f1 + b_f2*rm_f2) if reg_ok == 1

* 12. 检查结果
tabulate reg_ok
count if !missing(epsilon)
count if reg_ok == 1 & epsilon <= -1

* 13. 删除辅助变量，恢复原始顺序
sort __rowid
drop __rowid __valid __nvalid b0 b_l2 b_l1 b_rm b_f1 b_f2 rk

* 14. 保存最终数据
save "周收益率_回归完成.dta", replace
