
* ==========================================
* 01 清洗周个股回报率
* ==========================================
*导入工作目录
cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data"
* 检查项目工作目录
pwd
* 导入第一份个股数据
import excel "raw/周个股回报率/TRD_Week3.xlsx", ///
    firstrow clear
/*
* 查看数据基本结构
describe
* 查看前5条真实记录
list 证券代码 交易周份 in 1/10, noobs
* 统计观测数量
count
* 检查同一证券在同一交易周是否重复
duplicates report 证券代码 交易周份

* 检验证券代码与交易周份能否唯一识别观测
isid 证券代码 交易周份

* 查看所有变量及其数据类型
describe

* 搜索收益率相关变量
lookfor 回报率

* 查看前5条记录
list in 1/5, abbreviate(16)

* 检查两个周个股回报率变量的缺失值
misstable summarize *回报率*, all

* 查看周个股回报率的描述性统计
summarize *回报率*

* 检查两种周回报率的缺失组合
misstable patterns *回报率*

* 查看市场类型的分布
tabulate 市场类型, missing

* 查看交易周的数据类型
describe 交易周份 市场类型

* 查看前10条记录
list 证券代码 交易周份 市场类型 in 1/10, noobs

* 检查证券代码和日期的数据类型
describe 证券代码 周开盘日期 周收盘日期

* 检查证券代码是否缺失
count if missing(证券代码)

* 检查交易周份是否缺失
count if missing(交易周份)

* 检查周开盘日期是否缺失
count if missing(周开盘日期)

* 检查周收盘日期是否缺失
count if missing(周收盘日期)

* 检查市场类型是否缺失
count if missing(市场类型)

* 将字符串日期转换为 Stata 日期
gen double 开盘日期_数值 = daily(周开盘日期, "YMD")
gen double 收盘日期_数值 = daily(周收盘日期, "YMD")

* 设置日期显示格式
format 开盘日期_数值 收盘日期_数值 %td

* 查看转换后的日期
list 周开盘日期 开盘日期_数值 周收盘日期 收盘日期_数值 in 1/10, noobs

* 检查无法识别的日期
count if missing(开盘日期_数值)
count if missing(收盘日期_数值)

* 检查开盘日期是否晚于收盘日期
count if 开盘日期_数值 > 收盘日期_数值 ///
    & !missing(开盘日期_数值, 收盘日期_数值)
*/
//以上为对原来数据检查
keep 证券代码 周开盘日期 交易周份 考虑现金红利再投资的周个股回报率 周个股总市值 市场类型
* 保存第一份清洗后的周个股回报率数据
save "clean/TRD_Week_clean3.dta"
