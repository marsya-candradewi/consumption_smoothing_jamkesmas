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
local WORKING_POLL "`WORKING'/pollution"

* Output Files
local OUTPUT "`DROPBOX_ROOT'/Data/Output"
local FIGURES "`OUTPUT'/Figures"
local TABLES "`OUTPUT'/Tables"
local LOG "`OUTPUT'/Log"

use "`WORKING_MER'/final0714", clear

gen PAP2 = (PKH == 1 | BLT == 1)

gen moved = (commid07 != commid14)

**# FINAL CLEANING
local headill "headADL headchronic dh"
local spouseill "spouseADL spousechronic ds"
local maincons "lpce lpcfoodcon lpcfoodall lpcnfoodall lpcnfoodess lpcdiscre lpcbadcon lpcintrans lpcmedical"
local pap "raskin BLT PKH PAP PAP2"
local hinsurance "hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins hjamkessos hjampersal hformal_ins"
local sinsurance "sjamkesmas saskes sjamsostek semp_ins semp_clinic sprivate_ins ssaving_ins sjamkessos sjampersal sformal_ins"
local hh_chara "learningpc prodage child shareprodage sharechild fhead urban"


foreach var in `headill' `spouseill' `maincons' `pap' ///
	`hh_chara' hjamkesmas sjamkesmas learning {
	bys hhid07 (t): gen d_`var'= `var' - `var'[_n-1]    
}

foreach var in `hinsurance' `sinsurance' {	
	gen `var'14_1 = 1 if `var' == 1 & t == 1
	replace `var'14_1 = 0 if `var' == 0 & t == 1
	egen `var'14 = mean(`var'14_1), by(hhid07)
	
	gen `var'07_1 = 1 if `var' == 1 & t == 0
	replace `var'07_1 = 0 if `var' == 0 & t == 0
	egen `var'07 = mean(`var'07_1), by(hhid07)
}

/*
foreach w in 07 14 {
	gen hsjamkesmas`w' = 1 if hjamkesmas`w' == 1 | sjamkesmas`w' == 1
	replace hsjamkesmas`w' = 0 if hjamkesmas`w' == 0 & sjamkesmas`w' == 0
}
*/
foreach var in `hinsurance' `insurance' {
	gen new_`var' = (`var'14 == 1 & `var'07 == 0)
	gen old_`var' = (`var'14 == 1 & `var'07 == 1)
	gen never_`var' = (`var' == 0 & `var' == 0)
}

sort hhid07 t 

foreach var in heduc shareprodage sharechild headage headagesq urban ///
	fhead prodage child hhsize lpce learning ///
	headADL headchronic dh totcons {
	egen base_`var' = first(`var'), by(hhid07)
}

gen allcons = totcons + xmedical // Add back medical to get 40 percentile 


label var d_dh "$\Delta$ Head's Days of Sickness"
label var d_headADL "$\Delta$ Head's ADL Index (0 - 1)"
label var d_headchronic "$\Delta$ Head's Chronic Illness (Yes = 1)"

label var d_ds "$\Delta$ Spouse's Days of Sickness"
label var d_spouseADL "$\Delta$ Spouse's ADL Index (0 - 1)"
label var d_spousechronic "$\Delta$ Spouse's Chronic Illness (Yes = 1)"

label var d_learningpc "$\Delta$ Labor Earnings per Capita"
label var d_lpcmedical "$\Delta$ Medical Expenditure per Capita"

label var d_lpce "$\Delta$ Ln Per Capita Total Non-Medical Consumption Earnings per Capita"
label var base_heduc "Head's Education"
label var base_headage "Head's Age"
label var base_headagesq "Head's Age$^2$"
label var d_prodage "$\Delta$ Adult"
label var d_child "$\Delta$ Children"
label var d_fhead "New Female Head"
label var moved "Any Movement (=1)"
label var d_urban "Moved to Urban"
label var base_lpce "Ln Per Capita Consumption"
label var base_learning "Ln Per Capita Earnings"
label var base_hhsize "\# HH Members"
label var base_shareprodage "\% Adults in HH"
label var base_sharechild "\% Children in HH"
label var base_urban "HH is Urban (Yes = 1)"
label var base_headADL "Head's ADL Index (0--1)"
label var base_headchronic "Head's Chronic Illness (Yes = 1)"
label var base_dh "Head's Days of Sickness"
label var base_fhead "Head is Female (Yes = 1)"
label var base_heduc "Head's years of education"

label var dh "Heads \# of Sick Days Last Month"
label var fhead "Female Head (Yes = 1)"
label var headADL "Head's ADL Index (0--1)"
label var headchronic "Head's Chronic Illness (Yes = 1)"

label var hjamkesmas "Head has Jamkesmas (Yes = 1)"
label var hjamsostek "Head has Gov. Employee Insurance (Yes = 1)" // Jamsostek
label var hemp_ins "Head has Private Employee Insurance (Yes = 1)"
label var hformal_ins "Head Formally Insured (Yes = 1)"

label var learning "Ln Per Capita Earnings"
label var earningpc "Earning per Capita ('000 Rp)"

label var lpce "Ln Per Capita Consumption"
label var pce "Per Capita Consumption ('000 Rp)"

label var lpcfoodcon "Ln Per Capita Food Consumption"
label var pcfoodcon "Per Capita Food Consumption ('000 Rp)"

label var lpcmedical "Ln Per Capita Medical Consumption"
label var pcmedical "Per Capita Medical Consumption ('000 Rp)"

label var lpcnfoodes "Ln Per Capita Non-Food Essential Consumption"
label var pcnfoodes "Per Capita Non-Food Essential Consumption ('000 Rp)"

label var pcdiscre "Per Capita Non-Food Discretionary Consumption ('000 Rp)"
label var pcbadcon "Per Capita Non-Food Harmful Consumption ('000 Rp)"

label var pcintrans "Per Capita Consumption from Transfers ('000 Rp)"

label var shareprodage "\% Adults in HH"
label var sharechild "\% Children in HH"
label var urban "HH is Urban (Yes = 1)"
label var heduc "Household head's years of schooling"
foreach var in earningpc pce pcfoodcon pcmedical pcnfoodes ///
	pcdiscre pcbadcon pcintrans {
	replace `var' = `var' / 1000
}


// 2007
_pctile allcons if t == 0, p(40)
scalar all_bottom40_07 = r(r1)

// 2014
_pctile allcons if t == 1, p(40)
scalar all_bottom40_14 = r(r1)

// Generate dummy using scalar values
gen hh_bottom40_07_1 = (allcons <= all_bottom40_07) if t == 0
gen hh_bottom40_14_1 = (allcons <= all_bottom40_14) if t == 1

egen hh_bottom40_07 = mean(hh_bottom40_07_1), by(hhid07)
egen hh_bottom40_14 = mean(hh_bottom40_14_1), by(hhid07)

keep if hh_bottom40_07==1 & hh_bottom40_14==1

**# Add pollution

merge m:1 provid14 using "`WORKING_POLL'/pollution_by_prov", gen(mergepol)
drop if mergepol == 2
drop mergepol 
 

save "`WORKING_MER'/final0714_bottom40", replace

**# EDA
local hinsurance "hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins hjamkessos hjampersal hformal_ins"
foreach var in `hinsurance' {
	tab `var'07 if t == 1
	tab `var'14 if t == 1
	
}

*1. Summary of Characteristics
preserve
    * Step 0. Row order + labels
    local vars pce pcmedical earning pcfoodcon pcnfoodess ///
		pcdiscre pcbadcon pcintrans ///
        headADL headchronic dh ///
		hjamkesmas hjamsostek hemp_ins ///
		hformal_ins ///
        hhsize shareprodage sharechild heduc fhead urban

    tempfile labels means
    postfile lbls str20 var str100 label using `labels'

    * add an explicit order index so rows don't sort alphabetically
    postfile stats int ord str20 var double mean07 double n07 double mean14 double n14 using `means'

    local i = 0
    foreach v of local vars {
        local ++i
        local lbl : variable label `v'
        post lbls ("`v'") ("`lbl'")

        quietly summarize `v' if t==0
        local m07 = r(mean)
        local N07 = r(N)

        quietly summarize `v' if t==1
        local m14 = r(mean)
        local N14 = r(N)

        post stats (`i') ("`v'") (`m07') (`N07') (`m14') (`N14')
    }
    postclose lbls
    postclose stats

    * Step 1. Merge labels, sort by our custom order, keep only needed cols
    use `means', clear
    merge 1:1 var using `labels', nogen
    sort ord
    keep label mean07 n07 mean14 n14

    * Step 2. Formats: 1 decimal for means; commas for N
    format mean07 mean14 %12.1gc
    format n07 n14 %12.0gc

    * Step 3. Export LaTeX fragment with custom header
    *  - nonames suppresses the default header row with variable names
    *  - headerlines adds the grouped column headers
    * ssc install texsave, replace
    texsave label mean07 n07 mean14 n14 using "`TABLES'/sumtab.tex", ///
        headerlines("& \multicolumn{2}{c}{2007} & \multicolumn{2}{c}{2014} \\" ///
                    "& Mean & N & Mean & N \\ \midrule") ///
        nofix nonames frag replace
restore
	
*2. New Coverage vs no new coverage balance
iebaltab base_lpce base_learning base_headage base_headADL base_headchronic ///
	base_dh base_hhsize base_shareprodage base_sharechild base_urban ///
	base_fhead base_heduc if t==1, groupvar(new_hjamkesmas) ///
	savetex("`TABLES'/jamkesmas_balance.tex") rowvarlabels ///
	nonote replace format(%9.1f) vce(cluster provid14)
