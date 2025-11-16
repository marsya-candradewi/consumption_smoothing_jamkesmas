* ---------- 2007 ----------
use "`RAW_INS4'/b3b_ak1.dta", clear
preserve
	keep if ak01 == 3
	keep hhid07 pid07 pidlink
	
	mmerge hhid07 pid07 pidlink using "`RAW_ID4'/bk_ar1.dta"
	keep if _merge !=2
	
	drop if ar09>900 | ar08yr>9000
	keep if inlist(ar01a, 1, 2, 5, 11)

	gen head   = (ar02b==1)
	gen spouse = (ar02b==2)
	gen noinsurance = 1
	
	keep if head == 1
	keep hhid07 noins 
	tempfile headnoinsurance
	save `headnoinsurance', replace
	
	/*
	keep if spouse == 1
	keep hhid07 noins 
	tempfile spousenoinsurance
	save `spousenoinsurance', replace
	*/
restore

keep if ak01==1
reshape wide ak02 ak03x ak03 ak04 ak05, i(hhid07 pid07 pidlink) j(aktype) string

* --- scheme flags (2007 set; no jamkessos or jampersal, only Jamkesmas=H) ---
gen jamkesmas  = (ak02H == 1)
gen askes      = (ak02A == 1)
gen jamsostek  = (ak02B == 1)
gen emp_ins    = (ak02C == 1)
gen emp_clinic = (ak02D == 1)
gen private_ins= (ak02E == 1)
gen saving_ins = (ak02G == 1)

* Merge roster
mmerge hhid07 pid07 pidlink using "`RAW_ID4'/bk_ar1.dta"

* Basic cleaning / keep heads, spouses, and key statuses
drop if ar09>900 | ar08yr>9000
keep if inlist(ar01a, 1, 2, 5, 11)

gen head   = (ar02b==1)
gen spouse = (ar02b==2)

* Person-level head/spouse indicators for each scheme
foreach var in jamkesmas askes jamsostek emp_ins emp_clinic private_ins saving_ins {
    gen h`var' = head   * `var'
    gen s`var' = spouse * `var'
}

* --- Cross-coverage via spouse's policy (look for "A" = spouse covered) ---
* 2007 map (no J/K/L in this year)
local map "jamkesmas H  askes A  jamsostek B  emp_ins C  emp_clinic D  private_ins E  saving_ins G"

forvalues i = 1(2) `=wordcount("`map'")' {
    local v : word `i'       of `map'   // scheme var name
    local k : word `=`i'+1'  of `map'   // scheme letter

    capture confirm variable ak05`k'
    if !_rc {
        bys hhid07: egen _head_cov_`v' = max( head==1   & ak02`k'==1 & strpos(ak05`k', "A")>0 )
        bys hhid07: egen _spou_cov_`v' = max( spouse==1 & ak02`k'==1 & strpos(ak05`k', "A")>0 )

        replace s`v' = 1 if spouse==1 & _head_cov_`v'==1   // spouse covered by head's policy
        replace h`v' = 1 if head==1   & _spou_cov_`v'==1   // head covered by spouse's policy

        drop _head_cov_`v' _spou_cov_`v'
    }
}

* Formal insurance aggregates (2007 set)
foreach hh in h s {
    gen `hh'formal_ins = ( ///
        `hh'jamkesmas == 1 | `hh'askes == 1 | `hh'jamsostek == 1 | ///
        `hh'emp_ins == 1   | `hh'emp_clinic == 1 | `hh'private_ins == 1 | ///
        `hh'saving_ins == 1 )
}

* --- Outputs ---
* Heads file (by household)
preserve
    collapse (max) head ///
        hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins ///
        hformal_ins, by(hhid07)
    keep if head==1
    drop head
	
	merge 1:1 hhid07 using "`headnoinsurance'"
	keep if _merge != 2
	drop _merge
	
	local insvar "hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins"
	
	foreach ins in `insvar' {
		replace `ins' = 0 if missing(`ins') & noinsurance == 1
	}
	
	drop noinsurance

    save "`WORKING_INS'/heads_formal_ins_07.dta", replace
restore

* Spouses file (by household)
preserve
    collapse (max) spouse ///
        sjamkesmas saskes sjamsostek semp_ins semp_clinic sprivate_ins ssaving_ins ///
        sformal_ins, by(hhid07)
    keep if spouse==1
    drop spouse
    save "`WORKING_INS'/spouses_formal_ins_07.dta", replace
restore
