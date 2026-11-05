
* ======================================================
* 描述性统计、Pearson相关性、基准回归
* 模型调整：
* 1. Dturnt采用当前Dturnt_m口径
* 2. 省份×年份固定效应替代Index
* 3. DA_csv、Abacc_csv暂用来源值
* ======================================================

clear all
set more off
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"

use "10_2_正式筛选样本_缩尾后.dta", clear


* ======================================================
* 第一部分：定义研究变量
* ======================================================

* 核心解释变量：DH
* 被解释变量：FNCSKEW、FDUVOL
* 基准回归控制变量
global controls Size MB ROA Ret Dturnt GROWTH ///
    Big4 Zscore Disp DA_csv Abacc_csv

* 描述统计和相关分析变量
global tablevars FNCSKEW FDUVOL DH $controls

* 检查模型变量
describe $tablevars

* 检查缺失情况
misstable summarize $tablevars, all

egen byte check_missing = rowmiss( ///
    $tablevars ///
    firm_id industry_year_fe province_year_fe)

assert check_missing == 0

drop check_missing

* 确认ST/PT已剔除
assert STPT == 0

* 确认金融和房地产行业已剔除
assert !inlist(substr(industry,1,1), "J", "K")

* 确认风险计算有效周数不少于30
assert Nweek >= 30 & !missing(Nweek)

* 检查DH分布
tabulate DH, missing


* ======================================================
* 第二部分：检查扩展命令
* ======================================================

* reghdfe依赖ftools
capture which ftools

if _rc {
    ssc install ftools
}

capture which reghdfe

if _rc {
    ssc install reghdfe
}

* 描述统计导出
capture which sum2docx

if _rc {
    ssc install sum2docx
}

* 相关矩阵导出
capture which corr2docx

if _rc {
    ssc install corr2docx
}

* 回归表导出
capture which reg2docx

if _rc {
    ssc install reg2docx
}


* ======================================================
* 第三部分：描述性统计
* ======================================================

* 导出Word描述性统计表
sum2docx $tablevars using "10_描述性统计.docx", ///
    replace ///
    stats(N mean(%9.4f) sd(%9.4f) ///
          min(%9.4f) max(%9.4f)) ///
    title("表1：描述性统计")


* ======================================================
* 第四部分：Pearson相关性分析
* ======================================================

* 显示相关系数、P值和样本数
pwcorr $tablevars, sig obs

* 导出Word Pearson相关矩阵
corr2docx $tablevars using "10_Pearson相关矩阵.docx", ///
    replace ///
    star ///
    fmt(%6.3f) ///
    title("表2：Pearson相关性矩阵")


* ======================================================
* 第五部分：基准回归
* ======================================================

* ------------------------------------------------------
* 模型一：FNCSKEW
* ------------------------------------------------------

* 被解释变量：次年负收益偏态系数
* 解释变量：当年DH及各控制变量
* 固定效应：
* 公司
* 行业×年份
* 省份×年份
* 标准误：公司层面聚类
reghdfe FNCSKEW DH $controls, ///
    absorb(firm_id industry_year_fe province_year_fe) ///
    vce(cluster firm_id)

* 保存模型一估计结果
estimates store model_fn

* 标记实际参与回归的样本
gen byte sample_fn = e(sample)
* ------------------------------------------------------
* 模型二：FDUVOL
* ------------------------------------------------------
* 被解释变量：次年收益率上下波动率
* 固定效应和聚类方式与模型一保持一致
reghdfe FDUVOL DH $controls, ///
    absorb(firm_id industry_year_fe province_year_fe) ///
    vce(cluster firm_id)
* 保存模型二估计结果
estimates store model_fd
* 标记模型二实际回归样本
gen byte sample_fd = e(sample)
* ------------------------------------------------------
* 导出Word基准回归表
* ------------------------------------------------------
reg2docx model_fn model_fd using "10_基准回归结果.docx", ///
    replace ///
    b(%9.4f) ///
    t(%7.3f) ///
    scalars(N r2(%9.4f) r2_a(%9.4f)) ///
    mtitles("FNCSKEW" "FDUVOL") ///
    title("表3：存贷双高与股价崩盘风险——调整模型")

* ------------------------------------------------------
* Stata窗口显示回归结果
* ------------------------------------------------------

* 显示两个模型的系数、t值、N和R2
estimates table model_fn model_fd, ///
    b(%9.4f) t(%7.3f) stats(N r2)

save "10_基准回归样本标记.dta", replace
