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

use "`WORKING_MER'/final0714", clear

**# FINAL CLEANING
** checking how much health measures (ADL, days of sick, chronic ill) changes
gen hsADL = (headADL + spouseADL ) / 2
gen hschronic = headchronic == 1 | spousechronic == 1
gen hsdays = dh + ds 
gen PAP2 = (PKH == 1 | BLT == 1)

local headill "headADL headchronic dh"
local spouseill "spouseADL spousechronic ds"
local combinedill "hsADL hschronic hsdays"
local maincons "lfood lnonfood lbad lpce lmedical"
local pap "raskin BLT PKH PAP PAP2"
local hinsurance "hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins hjamkessos hjampersal hformal_ins"
local sinsurance "sjamkesmas saskes sjamsostek semp_ins semp_clinic sprivate_ins ssaving_ins sjamkessos sjampersal sformal_ins"
local hh_chara "child prodage learningpc shareprodage sharechild fhead"

foreach var in `headill' `spouseill' `combinedill' `maincons' `pap' ///
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

foreach var in heduc fhead child prodage shareprodage sharechild headage headagesq urban {
	egen base_`var' = first(`var'), by(hhid07)
}

gen allcons = totcons + xmedical // Marsya recheck tomorrow

summarize allcons if t == 0, detail
scalar p40 = r(p40)
** Labelling 

label var d_dh "$\Delta$ Head's Days of Sickness (\% Last Month)"
label var d_headADL "$\Delta$ Head's ADL Index (0 - 1)"
label var d_headchronic "$\Delta$ Head's Chronic Illness (Yes = 1)"

label var d_ds "$\Delta$ Spouse's Days of Sickness (\% Last Month)"
label var d_spouseADL "$\Delta$ Spouse's ADL Index (0 - 1)"
label var d_spousechronic "$\Delta$ Spouse's Chronic Illness (Yes = 1)"

label var d_learningpc "$\Delta$ Labor Earnings per Capita"
label var d_lmedical "$\Delta$ Medical Expenditure per Capita"

**# 1. HEALTH 
* ADL 
sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headADL == 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headADL > 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headADL == 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headADL >0

* Chronic Illness
sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headchronic == 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headchronic == 1
sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headchronic == 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headchronic == 1

* Days of Illness
sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & dh == 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & dh > 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & dh == 0
sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & dh >0

**# 1.A. Health with poor

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

preserve
	* keep bottom 40%
	keep if hh_bottom40_07 == 1 & hh_bottom40_14 == 1
	
	* ADL 
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headADL == 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headADL > 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headADL == 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headADL >0

	* Chronic Illness
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headchronic == 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & headchronic == 1
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headchronic == 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & headchronic == 1

	* Days of Illness
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & dh == 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 0 & dh > 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & dh == 0
	sum lpce lfood lnonfood lbad lmedical learningpc if t == 1 & dh >0
restore