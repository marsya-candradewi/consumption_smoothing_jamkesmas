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
local hh_chara "learningpc shareprodage sharechild fhead"

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

foreach var in heduc shareprodage sharechild headage headagesq urban {
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

pause

**# FINAL CLEAN UP TO HERE 
**# KEEPING BOTTOM 40% FOR JAMKESMAS
// 2007 
_pctile allcons if t == 0, p(40)
return list
gen all_bottom40_07 = `r(r1)'

// 2014 
_pctile allcons if t == 1, p(40)
return list
gen all_bottom40_14 = `r(r1)'

gen hh_bottom40_07 = (allcons <= all_bottom40_07)
gen hh_bottom40_14 = (allcons <= all_bottom40_14)

keep if (allcons < bottom40_07 & t == 0) | ///
	(allcons < bottom40_14 & t == 1 )
**

**# BALANCE
local baltab = 0
include "`CODE_ANALYSIS'/balance table.do"

**# GRAPHS
** days of sickness
twoway ///
	(scatter d_lfood d_dh if t == 1 , mcolor(blue)) ///
    (lfit d_lfood d_dh if t == 1, lcolor(blue)), ///
    title("Relationship between ΔFood Consumption and Days of Sickness Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

twoway ///
	(scatter d_lfood d_dh if t == 1 & d_dh >=0 , mcolor(blue)) ///
    (lfit d_lfood d_dh if t == 1 & d_dh >=0, lcolor(blue)), ///
    title("Relationship between ΔFood Consumption and Days of Sickness Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

twoway ///
 (lfit d_lfood d_dh if t==1 & d_dh>=0, lcolor(red) lpattern(solid)) ///
 (lfit d_lfood d_dh if t==1 & d_dh<=0, lcolor(blue) lpattern(dash)) ///
, ///
 ytitle("Δ log(Food Consumption)") ///
 xtitle("Δ Days Sick") ///
 title("Positive vs Negative Health Shocks") ///
 legend(order(1 "Health worsened" 2 "Health improved"))

 
twoway ///
 (lfit d_lfood d_dh if t==1 & d_dh>=0, lcolor(red) lpattern(solid)) ///
 (lfit d_lfood d_dh if t==1 & d_dh<=0, lcolor(blue) lpattern(dash)) ///
, ///
 ytitle("Δ log(Food Consumption)") ///
 xtitle("Δ Days Sick") ///
 title("Positive vs Negative Health Shocks") ///
 legend(order(1 "Health worsened" 2 "Health improved"))
twoway ///
	(scatter d_lfood d_headADL if t == 1 , mcolor(blue)) ///
    (lowess d_lfood d_headADL if t == 1, lcolor(blue)), ///
    title("Relationship between ΔFood Consumption and ADL Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

twoway ///
	(scatter d_lfood d_headchronic if t == 1 , mcolor(blue)) ///
    (lowess d_lfood d_headchronic if t == 1, lcolor(blue)), ///
    title("Relationship between ΔFood Consumption and Chronic Ill Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

	
twoway (scatter d_lfood d_dh if t == 1 & hjamkesmas14 == 1) ///
 (scatter d_lfood d_dh if t == 1 & hjamkesmas14 == 0) 
 
twoway (lfit d_lfood d_dh if t == 1 & hjamkesmas14 == 1) ///
	(lfit d_lfood d_dh if t == 1 & hjamkesmas14 == 0) ///
	(lfit d_lfood d_dh if t == 1 & new_hjamkesmas == 1) 

twoway (lfit d_lfood d_dh if t == 1 & new_hjamkesmas == 1) ///
	(lfit d_lfood d_dh if t == 1 & old_hjamkesmas == 0) ///
	(lfit d_lfood d_dh if t == 1 & never_hjamkesmas == 1) 
	
twoway ///
	(scatter d_lfood d_dh if t == 1 & hjamkesmas14 == 1, mcolor(blue)) ///
	(scatter d_lfood d_dh if t == 1 & hjamkesmas14 == 0, mcolor(red)) /// 
    (lfit d_lfood d_dh if t == 1 & hjamkesmas14 == 1, lcolor(blue)) ///
    (lfit d_lfood d_dh if t == 1 & hjamkesmas14 == 0, lcolor(red)), ///
    legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
    title("Relationship between ΔFood Consumption and Health Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")
	
twoway ///
	(scatter d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1, mcolor(blue)) ///
	(scatter d_lnonfood d_dh if t == 1 & hjamkesmas14 == 0, mcolor(red)) /// 
    (lfit d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1, lcolor(blue)) ///
    (lfit d_lnonfood d_dh if t == 1 & hjamkesmas14 == 0, lcolor(red)), ///
    legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
    title("Relationship between ΔFood Consumption and Health Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")
	
preserve
	collapse (mean) d_lfood, by(d_dh hjamkesmas14)

	twoway ///
		(lfit d_lfood d_dh if  hjamkesmas14 == 1, lcolor(blue)) ///
		(lfit d_lfood d_dh if  hjamkesmas14 == 0, lcolor(red)), ///
		legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
		title("Relationship between ΔFood Consumption and Health Shock") ///
		ytitle("Δ log(Food Consumption)") ///
		xtitle("Health Shock")
restore

preserve
	collapse (mean) d_lfood, by(d_headchronic hjamkesmas14)

	twoway ///
		(lfit d_lfood d_headchronic if  hjamkesmas14 == 1, lcolor(blue)) ///
		(lfit d_lfood d_headchronic if  hjamkesmas14 == 0, lcolor(red)), ///
		legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
		title("Relationship between ΔFood Consumption and Health Shock") ///
		ytitle("Δ log(Food Consumption)") ///
		xtitle("Health Shock")
restore

preserve
	collapse (mean) d_lfood, by(d_headADL hjamkesmas14)

	twoway ///
		(lfit d_lfood d_headADL if  hjamkesmas14 == 1, lcolor(blue)) ///
		(lfit d_lfood d_headADL if  hjamkesmas14 == 0, lcolor(red)), ///
		legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
		title("Relationship between ΔFood Consumption and Health Shock") ///
		ytitle("Δ log(Food Consumption)") ///
		xtitle("Health Shock")
restore

preserve
	collapse (mean) d_lnonfood, by(d_dh hjamkesmas14)

	twoway ///
		(lfit d_lnonfood d_dh if  hjamkesmas14 == 1, lcolor(blue)) ///
		(lfit d_lnonfood d_dh if  hjamkesmas14 == 0, lcolor(red)), ///
		legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
		title("Relationship between ΔFood Consumption and Health Shock") ///
		ytitle("Δ log(Food Consumption)") ///
		xtitle("Health Shock")
restore

preserve
	collapse (mean) d_lnonfood, by(d_headchronic hjamkesmas14)

	twoway ///
		(lfit d_lnonfood d_headchronic if  hjamkesmas14 == 1, lcolor(blue)) ///
		(lfit d_lnonfood d_headchronic if  hjamkesmas14 == 0, lcolor(red)), ///
		legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
		title("Relationship between ΔFood Consumption and Health Shock") ///
		ytitle("Δ log(Food Consumption)") ///
		xtitle("Health Shock")
restore

preserve
	collapse (mean) d_lnonfood, by(d_headADL hjamkesmas14)

	twoway ///
		(lfit d_lnonfood d_headADL if  hjamkesmas14 == 1, lcolor(blue)) ///
		(lfit d_lfood d_headADL if  hjamkesmas14 == 0, lcolor(red)), ///
		legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
		title("Relationship between ΔFood Consumption and Health Shock") ///
		ytitle("Δ log(Food Consumption)") ///
		xtitle("Health Shock")
restore

twoway ///
    (lowess d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1, lcolor(blue)) ///
    (lowess d_lnonfood d_dh if t == 1 & hjamkesmas14 == 0, lcolor(red)), ///
    legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
    title("Relationship between ΔFood Consumption and Health Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

twoway ///
    (lowess d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1, lcolor(blue)) ///
    (lowess d_lnonfood d_dh if t == 1 & hjamkesmas14 == 0, lcolor(red)), ///
    legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
    title("Relationship between ΔFood Consumption and Health Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

**# REGRESSIONS

**# FOOD
* 1. ADL 
reg d_lfood d_headADL if t == 1, vce(cluster provid14)
reg d_lfood d_headADL base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)


reg d_lfood i.hjamkesmas14##c.d_headADL ///
	if t==1, vce(cluster provid14)
reg d_lfood i.hjamkesmas14##c.d_headADL ///
	base_heduc shareprodage sharechild ///
	if t==1, vce(cluster provid14)
reg d_lfood i.hjamkesmas14##c.d_headADL ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

* 2. Days Sick
reg d_lfood d_dh if t == 1, vce(cluster provid14)
reg d_lfood d_dh base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lfood i.hjamkesmas14##c.d_dh ///
	if t==1, vce(cluster provid14)
reg d_lfood i.hjamkesmas14##c.d_dh ///
	base_heduc shareprodage sharechild ///
	if t==1, vce(cluster provid14)
reg d_lfood i.hjamkesmas14##c.d_dh ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

* 3. Chronic
reg d_lfood d_headchronic if t == 1, vce(cluster provid14)
reg d_lfood d_headchronic base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lfood i.hjamkesmas14##c.d_headchronic ///
	if t==1, vce(cluster provid14)
reg d_lfood i.hjamkesmas14##c.d_headchronic ///
	base_heduc shareprodage sharechild ///
	if t==1, vce(cluster provid14)
reg d_lfood i.hjamkesmas14##c.d_headchronic ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

**# NONFOOD
* 1. ADL 
reg d_lnonfood d_headADL if t == 1, vce(cluster provid14)
reg d_lnonfood d_headADL base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.hjamkesmas14##c.d_headADL ///
	if t==1, vce(cluster provid14)
reg d_lnonfood i.hjamkesmas14##c.d_headADL ///
	base_heduc shareprodage sharechild ///
	if t==1, vce(cluster provid14)
reg d_lnonfood i.hjamkesmas14##c.d_headADL ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.new_hjamkesmas##c.d_headADL ///
	i.old_hjamkesmas##c.d_headADL ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

* 2. Days Sick
reg d_lnonfood d_dh if t == 1, vce(cluster provid14)
reg d_lnonfood d_dh base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.hjamkesmas14##c.d_dh ///
	if t==1, vce(cluster provid14)
reg d_lnonfood i.hjamkesmas14##c.d_dh ///
	base_heduc shareprodage sharechild ///
	if t==1, vce(cluster provid14)
reg d_lnonfood i.hjamkesmas14##c.d_dh ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

* 3. Chronic
reg d_lnonfood d_headchronic if t == 1, vce(cluster provid14)
reg d_lnonfood d_headchronic base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.hjamkesmas14##c.d_headchronic ///
	if t==1, vce(cluster provid14)
reg d_lnonfood i.hjamkesmas14##c.d_headchronic ///
	base_heduc shareprodage sharechild ///
	if t==1, vce(cluster provid14)
reg d_lnonfood i.hjamkesmas14##c.d_headchronic ///
	base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

**# OVERALL
reg d_lpce d_headADL base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

reg d_lpce d_dh base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)
	
reg d_lpce d_headchronic base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

	
**# MEDICAL 

**# LABOR

/* Deprecated
* ADL
twoway (scatter d_lfood d_headADL if t == 1 & hjamkesmas14 == 1) ///
 (scatter d_lfood d_headADL if t == 1 & hjamkesmas14 == 0)

twoway (lfit d_lfood d_headADL if t == 1 & hjamkesmas14 == 1) ///
 (lfit d_lfood d_headADL if t == 1 & hjamkesmas14 == 0)

* Chronic
twoway (scatter d_lfood d_headchronic if t == 1 & hjamkesmas14 == 1) ///
 (scatter d_lfood d_headchronic if t == 1 & hjamkesmas14 == 0)

 twoway (lfit d_lfood d_headchronic if t == 1 & hjamkesmas14 == 1) ///
 (lfit d_lfood d_headchronic if t == 1 & hjamkesmas14 == 0)

 **# 2. Non Food
** days of sickness
twoway (scatter d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1 | ///
	lfit d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1) ///
	(scatter d_lnonfood d_dh if t == 1 & hjamkesmas14 == 0)

twoway (lfit d_lnonfood d_dh if t == 1 & hjamkesmas14 == 1) ///
 (lfit d_lnonfood d_dh if t == 1 & hjamkesmas14 == 0)

* ADL
twoway (scatter d_lnonfood d_headADL if t == 1 & hjamkesmas14 == 1) ///
 (scatter d_lnonfood d_headADL if t == 1 & hjamkesmas14 == 0)

twoway (lfit d_lnonfood d_headADL if t == 1 & hjamkesmas14 == 1) ///
 (lfit d_lnonfood d_headADL if t == 1 & hjamkesmas14 == 0)

* Chronic
twoway (scatter d_lnonfood d_headchronic if t == 1 & hjamkesmas14 == 1) ///
 (scatter d_lnonfood d_headchronic if t == 1 & hjamkesmas14 == 0)

twoway (lfit d_lnonfood d_headchronic if t == 1 & hjamkesmas14 == 1) ///
 (lfit d_lnonfood d_headchronic if t == 1 & hjamkesmas14 == 0)
 
 
 twoway (scatter d_lfood d_dh if t == 1 & hjamkesmas14 == 1) ///
 (scatter d_lfood d_dh if t == 1 & hjamkesmas14 == 0) ///
 (scatter d_lfood d_dh if t == 1 & new_hjamkesmas == 1)

twoway (scatter d_lfood d_hsdays if t == 1 & hsjamkesmas14 == 1) ///
 (scatter d_lfood d_hsdays if t == 1 & hsjamkesmas14 == 0) 

twoway (scatter d_lfood d_dh if t == 1 & hsjamkesmas14 == 1) ///
 (scatter d_lfood d_dh if t == 1 & hsjamkesmas14 == 0) 

twoway (scatter d_lfood d_headchronic if t == 1 & hsjamkesmas14 == 1) ///
 (scatter d_lfood d_headchronic if t == 1 & hsjamkesmas14 == 0) 

twoway (scatter d_lfood d_headchronic if t == 1 & hsjamkesmas14 == 1) ///
 (scatter d_lfood d_headchronic if t == 1 & hsjamkesmas14 == 0) 
 
 twoway (lpoly d_lfood d_hsdays if t == 1 & hsjamkesmas14 == 1) ///
 (lpoly d_lfood d_hsdays if t == 1 & hsjamkesmas14 == 0),  ///
   legend(label(1 "Jamkesmas = 1") label(2 "Jamkesmas = 0")) ///
    title("Relationship between ΔFood Consumption and Health Shock") ///
    ytitle("Δ log(Food Consumption)") ///
    xtitle("Health Shock")

