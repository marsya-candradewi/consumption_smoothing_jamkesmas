clear all
set maxvar 120000
capture log close
set more off
pause on

if c(os) == "Windows" & c(username) == "marsyacandradewi" {
		local DROPBOX_ROOT "C:/Users/`c(username)'/Team MG Dropbox/Marsya Candradewi/Consumption_Smoothing"
		local GIT_ROOT "C:/Users/`c(username)'/Documents/GitHub/consumption_smoothing_jamkesmas/Code"
}

* Necessary Packages 
* ssc install mmerge
* ssc install reghdfe

* Code Files
local CODE_CONS "`GIT_ROOT'/consumption"
local CODE_HEALTH "`GIT_ROOT'/health_measures"
local CODE_INS "`GIT_ROOT'/insurance"
local CODE_CHARA "`GIT_ROOT'/hh_chara"
local CODE_MER "`GIT_ROOT'/merging"
local CODE_ANALYSIS "`GIT_ROOT'/analysis"

* Input (including IFLS)
local RAW "`DROPBOX_ROOT'/Data/Raw"
local RAW_ID4 "`RAW'/id_tracking/IFLS4"
local RAW_ID5 "`RAW'/id_tracking/IFLS5"
local RAW_CONS "`RAW'/consumption"
local RAW_CONS5 "`RAW'/consumption/IFLS5"
local RAW_HEALTH4 "`RAW'/health_measures/IFLS4"
local RAW_HEALTH5 "`RAW'/health_measures/IFLS5"
local RAW_INS4 "`RAW'/insurance/IFLS4"
local RAW_INS5 "`RAW'/insurance/IFLS5"
local RAW_CHARA4 "`RAW'/hh_chara/IFLS4"
local RAW_CHARA5 "`RAW'/hh_chara/IFLS5"

* Working Files
local WORKING "`DROPBOX_ROOT'/Data/Working"
local WORKING_ID "`WORKING'/id_tracking"
local WORKING_CONS "`WORKING'/consumption"
local WORKING_HEALTH "`WORKING'/health_measures"
local WORKING_INS "`WORKING'/insurance"
local WORKING_CHARA "`WORKING'/hh_chara"
local WORKING_MER "`WORKING'/merged"

* Output Files
local OUTPUT "`DROPBOX_ROOT'/Data/Output"
local FIGURES "`OUTPUT'/Figures"
local TABLES "`OUTPUT'/Tables"
local LOG "`OUTPUT'/Log"

use "`RAW_INS5'/b3b_ak1.dta", clear
preserve
	keep if ak01 == 3
	keep hhid14 pid14 pidlink
	
	mmerge hhid14 pid14 pidlink using "`RAW_ID5'/bk_ar1.dta"
	keep if _merge !=2
	
	drop if ar09>900 | ar08yr>9000
	keep if inlist(ar01a, 1, 2, 5, 11)

	gen head   = (ar02b==1)
	gen spouse = (ar02b==2)
	gen noinsurance = 1
	
	keep if head == 1
	keep hhid14 noins 
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
reshape wide ak02 ak03x ak03 ak04 ak05, i(hhid14 pid14 pidlink) j(aktype) string

gen jamkesmas=1 if ak02H==1 // Jamkesmas
replace jamkesmas=1 if ak02I==1 // Jamkesda
replace jamkesmas=1 if ak02L==1 // JKN

gen askes = (ak02A == 1)
gen jamsostek = (ak02B == 1)
gen emp_ins = (ak02C == 1)
gen emp_clinic = (ak02D == 1)
gen private_ins = (ak02E == 1)
gen saving_ins = (ak02G == 1)
gen jamkessos = (ak02J == 1)
gen jampersal = (ak02K == 1)


mmerge hhid14 pid14 pidlink using "`RAW_ID5'/bk_ar1.dta"

drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
gen spouse=1 if ar02b==2

foreach var in jamkesmas askes jamsostek emp_ins emp_clinic private_ins saving_ins jamkessos jampersal {
    gen h`var' = head   * `var'
    gen s`var' = spouse * `var'
}


**# Using spouse's eligibility 

local map "askes A  jamsostek B  emp_ins C  emp_clinic D  private_ins E  saving_ins G  jamkessos J  jampersal L"

forvalues i = 1(2) `=wordcount("`map'")' {
    local v : word `i'       of `map'   // scheme var name, e.g., askes
    local k : word `=`i'+1'  of `map'   // its letter, e.g., A

    capture confirm variable ak05`k'
    if !_rc {
        bys hhid14: egen _head_cov_`v' = max( head==1   & ak02`k'==1 & strpos(ak05`k',"A")>0 )
        bys hhid14: egen _spou_cov_`v' = max( spouse==1 & ak02`k'==1 & strpos(ak05`k',"A")>0 )

        replace s`v' = 1 if spouse==1 & _head_cov_`v'==1   // spouse covered by head's policy
        replace h`v' = 1 if head==1   & _spou_cov_`v'==1   // head covered by spouse's policy

        drop _head_cov_`v' _spou_cov_`v'
    }
}

* --- Jamkesmas group (H ∪ I ∪ L) spouse coverage (unchanged logic, just wrapped safely) ---
bys hhid14: egen _head_jkm_covers_spouse = ///
    max( head==1 & ( (ak02H==1 & strpos(ak05H,"A")>0) | (ak02I==1 & strpos(ak05I,"A")>0) | (ak02L==1 & strpos(ak05L,"A")>0) ) )
bys hhid14: egen _spou_jkm_covers_head = ///
    max( spouse==1 & ( (ak02H==1 & strpos(ak05H,"A")>0) | (ak02I==1 & strpos(ak05I,"A")>0) | (ak02L==1 & strpos(ak05L,"A")>0) ) )

replace sjamkesmas = 1 if spouse==1 & _head_jkm_covers_spouse==1
replace hjamkesmas = 1 if head==1   & _spou_jkm_covers_head==1

drop _head_jkm_covers_spouse _spou_jkm_covers_head

foreach hh in h s {
gen `hh'formal_ins = (`hh'jamkesmas == 1 | `hh'askes == 1 | ///
	`hh'jamsostek == 1 | `hh'emp_ins == 1 | ///
	`hh'emp_clinic == 1 | `hh'private_ins == 1 | ///
	`hh'saving_ins == 1 | `hh'jamkessos == 1 | `hh'jampersal == 1 )
}

**# Outputting
* Heads file
preserve
    collapse (max) head ///
        hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins hjamkessos hjampersal ///
        hformal_ins, by(hhid14)
    keep if head==1
    drop head
	
	merge 1:1 hhid14 using "`headnoinsurance'"
	keep if _merge != 2
	drop _merge
	
	local insvar "hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins"
	
	foreach ins in `insvar' {
		replace `ins' = 0 if missing(`ins') & noinsurance == 1
	}
	
	drop noinsurance

    save "`WORKING_INS'/heads_formal_ins_14.dta", replace
restore

* Spouses file
preserve
    collapse (max) spouse ///
        sjamkesmas saskes sjamsostek semp_ins semp_clinic sprivate_ins ssaving_ins sjamkessos sjampersal ///
        sformal_ins, by(hhid14)
    keep if spouse==1
    drop spouse
    save "`WORKING_INS'/spouses_formal_ins_14.dta", replace
restore
