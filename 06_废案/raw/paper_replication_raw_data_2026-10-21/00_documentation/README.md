# 14天论文复现项目｜原始数据整理归档

**归档日期：** 2026-10-21  
**用途：** 整理用户已在当前会话上传的 CSMAR 原始下载文件；为 Stata 19 的后续独立复现准备追溯材料。  
**重要：** 此归档未对 `.dta` 原始数据进行任何清洗、删行、填值、合并成新的实证数据集或回归。原始文件名保持不变。压缩包中的目录只是归档标签，不代表数据已可直接合并。

## 目录

```
01_raw/
  01_weekly_market/         TRD_Weekm：周市场收益率
  02_weekly_stock/          TRD_Week、TRD_Week1：周个股收益率
  03_daily_trading/         TRD_Dalyr：日个股成交量、市值、交易状态
  04_share_capital/         TRD_Capchg：股本变动事件
  05_company_info/          TRD_Co：公司基本信息及行业字段
  06_balance_sheet/         FS_Combas：资产负债表、所有者权益
  07_income_statement/      FS_Comins：净利润
  08_shareholders/          HLD_Shareholders：前十大股东/股东排名明细
  09_original_download_test/ FS_Combas.xlsx：原始测试表格
00_documentation/
  README.md
  data_inventory.csv
  shareholder_audit.md
  shareholder_annual_quality_flags.csv
  data_feasibility_update.md
  SHA256_IN_ARCHIVE.txt
  historical_data_feasibility_day03_original.md
```

## 归档原则

1. 保留 `.dta`、配套 `[DES]` 字段说明和原始 `.xlsx` 测试文件；不包含聊天截图。
2. **字节完全相同的重复文件仅留一份**，省去不必要的重复下载体积，并在 `data_inventory.csv` 中逐条注明。确认重复的 `.dta` 是：
   - `TRD_Dalyr(3).dta` = `TRD_Dalyr(2).dta`（保留后者）。
   - `TRD_Dalyr1(1).dta` = `TRD_Dalyr1.dta`（保留后者）。
   - 四个 `TRD_Dalyr[DES][dta](5..8).txt` 内容也逐字节相同，保留 `(8)` 一份。
3. **其他分批文件绝不去重删除。** 两份周个股文件 `TRD_Week.dta` 与 `TRD_Week1.dta`、两份股东数据、三个时期的日交易数据分片均需保留。
4. `FS_Combas.dta` 与 `FS_Combas(1).dta` **不是重复**，它们包含不同的财务变量。`FS_Combas.xlsx` 是此前上传的单独表格原件，归入下载测试目录。
5. `SHA256_IN_ARCHIVE.txt` 列出压缩包内每份原始数据/字段说明的原始 SHA256。`data_inventory.csv` 还记录了未放入压缩包的相同副本。
6. **勿将本压缩包或其中 CSMAR 商业数据库原始数据上传至公开 GitHub。** GitHub 可保留你自己写的研究日志、数据字典、处理代码和不包含受限原始记录的核验摘要。原始数据库文件须遵守学校及 CSMAR 授权。

## 当前数据的已知特点（实际文件检查）

- 个股周收益率：2份分片共 **1,701,727行**，无重复的 `Stkcd + Trdwnt`；实有2006—2019周码。尚未按有效交易周筛选。
- 周市场收益率：`TRD_Weekm.dta` 共 **3,411行**。
- 日交易数据：保留9份非相同分片，共 **7,983,858条**公司—交易日记录，覆盖2006—2019。
- 股本变动：`TRD_Capchg.dta` **71,837行**；从1990年开始，属于股本变化事件记录，不是逐日数据。
- 原始资产负债表：`FS_Combas.dta` **182,596行**，补充权益 `FS_Combas(1).dta` **360,672行**。
- 利润表：`FS_Comins.dta` **349,277行**。
- 股东明细：2份共 **1,118,356行**，细节和异常请阅读 `shareholder_audit.md`。
- 公司基础信息：`TRD_Co.dta` **6,036行**，最晚上市日期为2026年，不能直接假设其行业代码是每个历史年度的不变行业代码。

以上是**原始文件的初步审查**；未对所有跨表合并键及全部经济口径开展最终复现检验，完整字段见数据清单。

## 后续操作建议

先将本压缩包保存到本机不公开的科研项目目录，再按照论文真实需求逐表建立 Stata 19 的清洗与合并代码。特别注意：

- 日交易数据的文件名带有 `(2)`、`1(2)` 等，表示下载时的不同分片，**不能把后缀当成时间顺序或市场类型**。
- 对周数据先确认市场周收益率与个股周收益率的 `Markettype/Trdwnt` 对应规则。
- 对财务数据根据 `Typrep=A` 合并报表及年度报告期检查，暂时不能认为所有财务记录都可以直接按公司和年度一对一合并。
- 对前十大股东数据必须先把两个原始分片联合分析：有一个公司—报告期恰好跨文件分片。
- 所有变量公式、股东权益口径、异常值处理须以论文和附录为准；不要为了凑原论文样本量改变筛选规则。

## 来源与验证

本包中的内容仅来自当前对话上传并在本地实际可读取的文件；没有另外下载网上数据，也没有制作或伪造论文回归结果。

如需检查源文件是否完整未变，可将文件的SHA256与 `00_documentation/SHA256_IN_ARCHIVE.txt` 对照。
