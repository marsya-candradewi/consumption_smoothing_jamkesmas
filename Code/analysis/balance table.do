if `baltab' == 1 {
    tempname H
    tempfile bal
    // no wave column
    postfile `H' str80 varlabel double(mean0 mean1 N diff pval) using "`bal'", replace

    // varlists
    local maincons "lfood lnonfood lbad"
    local headill  "headADL headchronic dh"
    local hhchara  "headage heduc fhead earningpc shareprodage sharechild urban"

    // make sure treatment var exists
    capture confirm variable hjamkesmas14
    if _rc {
        di as error "hjamkesmas14 not found"
        exit 111
    }

    foreach v of varlist `maincons' `headill' `hhchara' {
        capture confirm variable `v'
        if _rc continue

        regress `v' hjamkesmas14 if t == 0 & !missing(`v', hjamkesmas14), vce(cluster provid)
        if _rc | e(N)==. | e(N)==0 continue

        // control mean (non-Jamkesmas), treated mean, diff, p-val, N
        local m0   = _b[_cons]
        local diff = _b[hjamkesmas14]
        local m1   = `m0' + `diff'
        local pval = 2*ttail(e(df_r), abs(`diff'/_se[hjamkesmas14]))
        local N    = e(N)

        local lbl : variable label `v'
        if "`lbl'"=="" local lbl "`v'"

        post `H' ("`lbl'") (`m0') (`m1') (`N') (`diff') (`pval')
    }

    postclose `H'
    use "`bal'", clear
    order varlabel N mean0 mean1 diff pval
    format mean0 mean1 diff %9.2f

    gen str8 pvalstring = "<0.01" if pval < 0.01
    replace pvalstring = string(pval,"%9.2f") if pval >= 0.01

    label var varlabel ""
    label var mean0 "Non-Jamkesmas Means"
    label var mean1 "Jamkesmas Means"
    label var N "N"
    label var diff "$\Delta$ Means"
    label var pvalstring "p-value"

    texsave varlabel N mean0 mean1 diff pvalstring ///
        using "`TABLES'/Jamkesmas_balance.tex", ///
        frag nofix align(lccccc) location("H") replace varlabel ///
        title("Jamkesmas vs Non Jamkesmas Household") ///
        footnote("Covariate balance comparing households with Jamkesmas to those without. Means from OLS; control mean is _cons; SEs clustered at provid.")
}
