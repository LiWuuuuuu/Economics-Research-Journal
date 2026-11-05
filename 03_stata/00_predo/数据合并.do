cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/clean"
* 1. 读取周个股收益率
use "个股合并.dta", clear
* 2. 检查个股数据唯一性
isid 证券代码 交易周份
* 3. 合并市场周收益率
merge m:1 交易周份 市场类型 using "市场合并.dta"
* 4. 检查匹配结果
tabulate _merge
* 5.删除merge列
keep if _merge == 3
drop _merge
* 6. 保存完整合并结果
save "周收益率_合并检查.dta", replace
