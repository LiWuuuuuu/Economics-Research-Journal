
* ==================================================
* 样本筛选与缩尾
* ==================================================

clear all
set more off

cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

use "10_核心XY_补齐全部控制变量_初步.dta", clear

* 定义基础回归变量
global controls Size MB ROA Ret Dturnt GROWTH Big4 ///
    Zscore Disp DA_csv Abacc_csv

* 省份×年份固定效应代替Index
* 不修改现有Dturnt口径

* 定义连续变量，后面统一缩尾
global continuous FNCSKEW FDUVOL Size MB ROA Ret ///
    Dturnt GROWTH Zscore Disp DA_csv Abacc_csv
* 删除模型字段缺失的观测
egen nmiss_model = rowmiss( ///
    FNCSKEW FDUVOL DH $controls STPT ///
    firm_id industry_year_fe province_year_fe)

count
count if nmiss_model == 0

drop if nmiss_model > 0
* 行业信息不能缺失
drop if missing(industry)

count


* 剔除金融业、房地产业

* J表示金融业，K表示房地产业
drop if inlist(substr(industry, 1, 1), "J", "K")

count

* 剔除ST/PT

* STPT==1为ST/PT样本
drop if STPT == 1



* 核验年度周收益数量

* 原论文要求至少30个有效周观测
drop if missing(Nweek) | Nweek < 30



* 保存缩尾前样本
save "10_2_正式筛选样本_缩尾前.dta", replace
* 连续变量1%和99%缩尾
/*
* 检查winsor2是否已经安装
capture which winsor2

if _rc != 0 {
    display as error "请先运行：ssc install winsor2"
    exit 499
}
*/

* 不按年份分组
* 不对DH、Big4、STPT缩尾
winsor2 $continuous, replace

isid stock year
assert risk_year == year + 1

save "10_2_正式筛选样本_缩尾后.dta", replace

display as result "第10.2步执行完成"
