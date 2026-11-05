
* ======================================================
* 第10.1步：补齐四个控制变量
* Zscore、Disp、DA_csv、Abacc_csv
* 同时保留STPT供后续样本筛选
* Stata 19
* ======================================================

clear all
set more off

cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"


* ======================================================
* 第一部分：整理Zscore和STPT
* ======================================================

confirm file "../raw/Control/Zscore_STPT.csv"

import delimited using "../raw/Control/Zscore_STPT.csv", ///
    varnames(1) stringcols(1) case(lower) clear

* 统一股票代码为六位字符串
assert regexm(strtrim(stock), "^[0-9]{1,6}$")
gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock

* 检查并转换年份
capture confirm string variable year
if _rc == 0 {
    destring year, replace
}

* 转换可能存在的字符串数值字段
foreach v in zscore stpt issuspend {
    capture confirm string variable `v'
    if _rc == 0 {
        destring `v', replace
    }
}

* 统一名称
rename zscore Zscore
rename stpt STPT
rename issuspend IsSuspend

* 数据检查
isid stock year
assert inlist(STPT, 0, 1) if !missing(STPT)

tabulate STPT, missing
summarize Zscore, detail

keep stock year Zscore STPT IsSuspend
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

save "10_Zscore_STPT_公司年度.dta", replace


* ======================================================
* 第二部分：整理Disp
* ======================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"

import delimited using "../raw/Control/Disp.csv", ///
    varnames(1) stringcols(1) case(lower) clear

* 统一股票代码
assert regexm(strtrim(stock), "^[0-9]{1,6}$")
gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock

capture confirm string variable year
if _rc == 0 {
    destring year, replace
}

capture confirm string variable disp
if _rc == 0 {
    destring disp, replace
}

rename disp Disp

isid stock year
summarize Disp, detail

keep stock year Disp
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

save "10_Disp_公司年度.dta", replace


* ======================================================
* 第三部分：整理DA与Abacc
* ======================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"

confirm file "../raw/Control/DAAbacc.csv"

import delimited using "../raw/Control/DAAbacc.csv", ///
    varnames(1) stringcols(1) case(lower) clear

* 股票代码
assert regexm(strtrim(stock), "^[0-9]{1,6}$")
gen str6 stock6 = string(real(strtrim(stock)), "%06.0f")
drop stock
rename stock6 stock

capture confirm string variable year
if _rc == 0 {
    destring year, replace
}

* 转换指标格式
foreach v in da abacc {
    capture confirm string variable `v'
    if _rc == 0 {
        destring `v', replace
    }
}

* 明确标识为来源指标
rename da DA_csv
rename abacc Abacc_csv

label variable DA_csv "来源盈余管理指标：待正式验证"
label variable Abacc_csv "来源公司透明度指标：待正式验证"

isid stock year

summarize DA_csv Abacc_csv, detail

keep stock year DA_csv Abacc_csv
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

save "10_DAAbacc_公司年度_来源值.dta", replace


* ======================================================
* 第四部分：合并到当前核心研究数据
* ======================================================
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

use "09_核心XY_控制变量与固定效应_初步.dta", clear

* 检查原有数据
assert _N == 29092
isid stock year
assert risk_year == year + 1

* 防止重复合并覆盖变量
foreach v in Zscore Disp DA_csv Abacc_csv STPT {
    capture confirm variable `v'
    if _rc == 0 {
        display as error "主表已经包含`v'，请先核查"
        exit 459
    }
}

* 4.1 合并Zscore及STPT
merge 1:1 stock year using ///
    "10_Zscore_STPT_公司年度.dta", ///
    keep(master match) ///
    keepusing(Zscore STPT IsSuspend) ///
    gen(merge_zscore)

tabulate merge_zscore

* 4.2 合并Disp
merge 1:1 stock year using ///
    "10_Disp_公司年度.dta", ///
    keep(master match) ///
    keepusing(Disp) ///
    gen(merge_disp)

tabulate merge_disp

* 4.3 合并DA与Abacc来源值
merge 1:1 stock year using ///
    "10_DAAbacc_公司年度_来源值.dta", ///
    keep(master match) ///
    keepusing(DA_csv Abacc_csv) ///
    gen(merge_daabacc)

tabulate merge_daabacc


* ======================================================
* 第五部分：数据质量检查
* ======================================================

* 主表观测数不能改变
assert _N == 29092

* 公司年度唯一性
isid stock year

* 时间对齐
assert risk_year == year + 1

* 检查四项控制变量
misstable summarize Zscore Disp DA_csv Abacc_csv, all

* 检查STPT
tabulate STPT, missing

* 主要变量描述统计
summarize FNCSKEW FDUVOL DH Size MB ROA Ret ///
    Dturnt GROWTH Big4 Zscore Disp DA_csv Abacc_csv

* 检查完整候选样本
egen byte n_missing_baseline = rowmiss( ///
    FNCSKEW FDUVOL DH Size MB ROA Ret ///
    Dturnt GROWTH Big4 Zscore Disp DA_csv Abacc_csv ///
    STPT firm_id industry_year_fe province_year_fe)

gen byte sample_complete = (n_missing_baseline == 0)

* 全部模型字段非缺失的样本数量
count if sample_complete == 1

* 进一步检查排除J、K行业与ST/PT后的候选数量
* 这里只统计，暂不删除
count if sample_complete == 1 ///
    & !inlist(substr(industry, 1, 1), "J", "K") ///
    & STPT == 0


save "10_核心XY_补齐全部控制变量_初步.dta", replace
