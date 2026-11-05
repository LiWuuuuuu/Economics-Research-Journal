* ======================================================
* 第9步：控制变量整理
* ======================================================

cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"
* 检查源文件
confirm file "../raw/Control/Dturnt_d.csv"

* 导入CSV，第一列按字符串读取
import delimited using "../raw/Control/Dturnt_d.csv", varnames(1) stringcols(1) clear encoding("UTF-8")

* 统一Dturnt变量名称
* 兼容导入时自动转为小写的情况
capture confirm variable dturnt_d

if _rc == 0 {
    rename dturnt_d Dturnt
}
else {
    rename Dturnt_d Dturnt
}

*统一股票代码与变量格式
* 检查股票代码
count if !regexm(strtrim(stock), "^[0-9]{1,6}$")
* 如果代码格式异常，停止执行
assert regexm(strtrim(stock), "^[0-9]{1,6}$")
* 转换为六位股票代码字符串
gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock
* 确保年份为数值型
capture confirm numeric variable year

if _rc {
    destring year, replace
}

* 确保Dturnt为数值型
capture confirm numeric variable Dturnt

if _rc {
    destring Dturnt, replace
}

* 检查公司年度是否唯一
isid stock year
* 9.5.4 保留研究期并检查Dturnt
* 保留2007—2018年
keep if inrange(year, 2007, 2018)
* 添加变量标签
label variable Dturnt "月超额换手率：暂用Dturnt_d数据"

* 保留必要字段
keep stock year Dturnt

* 检查唯一性
isid stock year

* 保存整理后的Dturnt
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
save "09_Dturnt_公司年度_初步.dta", replace


use "09_核心XY_添加SizeGROWTHRetROAMB_初步.dta", clear

* 合并Dturnt到核心研究数据

* 按照股票代码与年份一对一合并
merge 1:1 stock year using "09_Dturnt_公司年度_初步.dta", keep(master match) keepusing(Dturnt) gen(merge_dturnt)


assert _N == 29092

* 保证公司年度唯一
isid stock year

* 验证时间对齐
assert !missing(year, risk_year)
assert risk_year == year + 1

* 核查所有主要变量
describe DH FNCSKEW FDUVOL Size GROWTH Ret ROA MB Dturnt

* 保存阶段性主数据
save "09_核心XY_添加SizeGROWTHRetROAMBDturnt_初步.dta", replace
