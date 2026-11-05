cd "/Users/duantianhai/Documents/GitHub/Economics-Research-Journal/02_data/raw"
import excel "周市场回报率/TRD_Weekm.xlsx", sheet("sheet1") firstrow
keep 市场类型 交易周份 考虑现金红利再投资的周市场回报率等权平均法 考虑现金红利再投资的周市场回报率总市值加权平均法 考虑现金红利再投资的周市场回报率流通市值加权平均法 周市场流通市值 周市场总市值
save "市场合并",replace
