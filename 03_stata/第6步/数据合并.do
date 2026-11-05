* Merge two uploaded FS_Combas parts (Stata 19)
* Only A consolidated statements are matched; originals remain untouched.
* Edit the project root on the next line before running.
local project "/Users/你的用户名/Documents/论文复现"

* Step 1: Read share-equity file and retain A consolidated reports
use "`project'/data/raw/FS_Combas(1)(2).dta", clear
keep if Typrep == "A"
keep Stkcd Accper Typrep A003100000 A003000000
isid Stkcd Accper Typrep
tempfile equity_a
save `equity_a'

* Step 2: Open cash/assets/short-debt file (already A only)
use "`project'/data/raw/FS_Combas(3).dta", clear
isid Stkcd Accper Typrep
assert Typrep == "A"

* Step 3: One-to-one horizontal merge; stop if any row unmatched
merge 1:1 Stkcd Accper Typrep using `equity_a'
tab _merge
assert _merge == 3
drop _merge

* Step 4: Audit and output without overwriting the original files
count
isid Stkcd Accper Typrep
misstable summarize A001101000 A001000000 A002101000 A003100000 A003000000
order Stkcd ShortName Accper Typrep A001101000 A001000000 A002101000 A003100000 A003000000 check_year check_md
capture mkdir "`project'/data/clean"
save "`project'/data/clean/FS_Combas_merged_A_2006_2019.dta", replace
