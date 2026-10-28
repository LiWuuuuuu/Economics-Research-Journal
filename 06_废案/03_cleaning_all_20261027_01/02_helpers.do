* 核查键，不自动删除重复或缺失的记录。
program define check_key
    syntax varlist
    generate byte flag_key_missing = 0
    foreach v of local varlist {
        replace flag_key_missing = 1 if missing(`v')
    }
    tempvar dup
    duplicates tag `varlist', generate(`dup')
    generate byte flag_duplicate_key = `dup'>0
    duplicates report `varlist'
end

* 报告包括每个字段的Stata缺失、文本None/null等缺失标记及每个质量标记。
program define table_metrics
    syntax, Table(string) Fields(varlist)
    post $AUDIT_HANDLE ("`table'") ("rows") (_N)
    foreach v of local fields {
        quietly count if missing(`v')
        post $AUDIT_HANDLE ("`table'") ("missing:`v'") (r(N))
        capture confirm string variable `v'
        if !_rc {
            quietly count if inlist(ustrlower(ustrtrim(`v')),"none","null","nan","n/a")
            post $AUDIT_HANDLE ("`table'") ("text_missing_token:`v'") (r(N))
        }
    }
    ds flag_*
    foreach v of varlist `r(varlist)' {
        quietly count if `v'==1
        post $AUDIT_HANDLE ("`table'") ("`v'") (r(N))
    }
    capture confirm numeric variable year
    if !_rc {
        quietly summarize year
        post $AUDIT_HANDLE ("`table'") ("year_min") (r(min))
        post $AUDIT_HANDLE ("`table'") ("year_max") (r(max))
        preserve
            generate byte count_unit=1
            collapse (sum) rows=count_unit flag_*, by(year)
            export delimited using "$OUT/`table'_by_year.csv"
        restore
    }
end

program define save_review
    args table
    egen byte flag_any=rowmax(flag_*)
    preserve
        keep if flag_any==1
        save "$OUT/`table'_review.dta"
    restore
end

program define datestring
    syntax varname, Generate(name)
    generate double `generate'=daily(`varlist',"YMD")
    format `generate' %tdCCYY-NN-DD
end
