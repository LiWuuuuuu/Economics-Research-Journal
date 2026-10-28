# 全部数据清洗成果导航

首先阅读[全部数据清洗报告](全部数据清洗报告.md)。

## 常用文件

- run_01/annual_master_base.dta：37,922条年度基础主表，尚不是最终回归样本。
- run_01/balance_annual.dta、equity_annual.dta、income_annual.dta：年度合并财务三表。
- run_01/stock_weekly_clean.dta、market_weekly_clean.dta：原始口径完整周数据及标记。
- run_01/daily_trading_clean.dta：9份分片合并的日交易数据。
- run_01/capital_events_clean.dta：含2006年前历史的股本事件。
- run_01/daily_turnover_base.dta、turnover_monthly_base.dta：换手率基础量，不是最终Dturnt。
- run_01/company_snapshot_clean.dta：当前公司截面，不是历史行业/省份面板。
- run_01/shareholders_detail_clean.dta、shareholders_annual.dta：股东明细与年度汇总。
- run_01/audit_detail_clean.dta、audit_annual.dta：审计明细及年度信息。
- run_01/market_value_yearend.dta、trading_status_annual.dta：年末市值与交易状态摘要。
- run_01/*_review.dta：复核记录；这些记录在主清洗表中仍保留。
- run_01/*_other_records.dta：未采用的报表类型或报告期，仍保留可追溯。
- run_01/audit_metrics.csv：各表实际样本、各字段缺失及重复/质量标记数量。
- run_01/source_rows.csv：source_id到原始文件的映射。
- source_integrity_verified.json：源文件前后校验。资产负债表新增检查变量的变化另见报告。

## 复跑

在Stata中进入本文件夹，再运行：

```stata
do 00_run_all.do run_02
```

run_02须是不存在的新目录。源文件路径保持原位置；已有输出不会覆盖。

## 使用边界

最终解释变量窗口2007—2018尚待统一筛选。历史行业/省份、候选MB、两种Big4及Disp_checked均有口径说明，不能直接视作原论文最终变量。本成果含CSMAR数据，按原授权保管；没有自动上传GitHub。
