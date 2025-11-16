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

**********************
**# FINAL CLEANING
**********************
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

********************
**# INSURANCE TYPE
********************
local hinsurance "hjamkesmas haskes hjamsostek hemp_ins hemp_clinic hprivate_ins hsaving_ins hjamkessos hjampersal hformal_ins"

foreach var in `hinsurance' {
	tab `var' t
}

****************
* HEALTH SHOCKS
****************
local shocks "dh headADL headchronic"
local names  "Days ADL Chronic"

foreach ill in `shocks' {

    bysort hhid07 (t): gen byte trans_`ill' = .

    * assign transitions only if both current and previous values exist
    bysort hhid07 (t): replace trans_`ill' = 1 if !missing(`ill', `ill'[_n-1]) &  `ill'[_n]==0 &  `ill'[_n-1]==0   // StayHealthy
    bysort hhid07 (t): replace trans_`ill' = 2 if !missing(`ill', `ill'[_n-1]) &  `ill'[_n]>0  &  `ill'[_n-1]==0   // BecomeSick
    bysort hhid07 (t): replace trans_`ill' = 3 if !missing(`ill', `ill'[_n-1]) &  `ill'[_n]==0 &  `ill'[_n-1]>0    // Recover
    bysort hhid07 (t): replace trans_`ill' = 4 if !missing(`ill', `ill'[_n-1]) &  `ill'[_n]>0  &  `ill'[_n-1]>0    // StaySick

}

gen ins_gain = (hformal_ins14 == 1 & hformal_ins07 == 0)

local ctrls base_heduc base_headage base_headagesq d_shareprodage d_sharechild


*******************************
**# TOTAL CONSUMPTION Regressions (with Insurance Interactions)**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH × Baseline insurance
    eststo reg_`s'_base: reg d_lpce c.d_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline"

    * (2) ΔC ~ ΔH × Insurance Gain
    eststo reg_`s'_gain: reg d_lpce c.d_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain"

    * (3) ΔC ~ transition × Baseline insurance
    eststo reg_`s'_trans_base: reg d_lpce i.trans_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline (transition)"

    * (4) ΔC ~ transition × Insurance Gain
    eststo reg_`s'_trans_gain: reg d_lpce i.trans_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain (transition)"

    * Export neatly
    esttab reg_`s'_base reg_`s'_gain reg_`s'_trans_base reg_`s'_trans_gain using ///
        "`TABLES'/Total_`label'_shock_insurance.tex", replace se label b(3) se(3) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Total Consumption — Insurance Heterogeneity") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls" "Interaction Type") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Interaction terms show heterogeneous effects of ΔHealth by baseline (2007) and gained insurance (2007–2014). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# FOOD Regressions (with Insurance Interactions)**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH × Baseline insurance
    eststo reg_`s'_base: reg d_lfood c.d_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline"

    * (2) ΔC ~ ΔH × Insurance Gain
    eststo reg_`s'_gain: reg d_lfood c.d_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain"

    * (3) ΔC ~ transition × Baseline insurance
    eststo reg_`s'_trans_base: reg d_lfood i.trans_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline (transition)"

    * (4) ΔC ~ transition × Insurance Gain
    eststo reg_`s'_trans_gain: reg d_lfood i.trans_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain (transition)"

    * Export neatly
    esttab reg_`s'_base reg_`s'_gain reg_`s'_trans_base reg_`s'_trans_gain using ///
        "`TABLES'/Food_`label'_shock_insurance.tex", replace se label b(3) se(3) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Food Consumption — Insurance Heterogeneity") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls" "Interaction Type") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Interaction terms show heterogeneous effects of ΔHealth by baseline (2007) and gained insurance (2007–2014). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# FOOD Regressions (with Insurance Interactions)**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH × Baseline insurance
    eststo reg_`s'_base: reg d_lnonfood c.d_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline"

    * (2) ΔC ~ ΔH × Insurance Gain
    eststo reg_`s'_gain: reg d_lnonfood c.d_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain"

    * (3) ΔC ~ transition × Baseline insurance
    eststo reg_`s'_trans_base: reg d_lnonfood i.trans_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline (transition)"

    * (4) ΔC ~ transition × Insurance Gain
    eststo reg_`s'_trans_gain: reg d_lnonfood i.trans_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain (transition)"

    * Export neatly
    esttab reg_`s'_base reg_`s'_gain reg_`s'_trans_base reg_`s'_trans_gain using ///
        "`TABLES'/Nonfood_`label'_shock_insurance.tex", replace se label b(3) se(3) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Nonfood Consumption — Insurance Heterogeneity") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls" "Interaction Type") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Interaction terms show heterogeneous effects of ΔHealth by baseline (2007) and gained insurance (2007–2014). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# BAD CONSUMPTION Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH × Baseline insurance
    eststo reg_`s'_base: reg d_lbad c.d_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline"

    * (2) ΔC ~ ΔH × Insurance Gain
    eststo reg_`s'_gain: reg d_lbad c.d_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain"

    * (3) ΔC ~ transition × Baseline insurance
    eststo reg_`s'_trans_base: reg d_lbad i.trans_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline (transition)"

    * (4) ΔC ~ transition × Insurance Gain
    eststo reg_`s'_trans_gain: reg d_lbad i.trans_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain (transition)"

    * Export neatly
    esttab reg_`s'_base reg_`s'_gain reg_`s'_trans_base reg_`s'_trans_gain using ///
        "`TABLES'/Bad_`label'_shock_insurance.tex", replace se label b(3) se(3) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Bad Consumption — Insurance Heterogeneity") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls" "Interaction Type") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Interaction terms show heterogeneous effects of ΔHealth by baseline (2007) and gained insurance (2007–2014). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# MEDICAL Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH × Baseline insurance
    eststo reg_`s'_base: reg d_lmedical c.d_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline"

    * (2) ΔC ~ ΔH × Insurance Gain
    eststo reg_`s'_gain: reg d_lmedical c.d_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain"

    * (3) ΔC ~ transition × Baseline insurance
    eststo reg_`s'_trans_base: reg d_lmedical i.trans_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline (transition)"

    * (4) ΔC ~ transition × Insurance Gain
    eststo reg_`s'_trans_gain: reg d_lmedical i.trans_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain (transition)"

    * Export neatly
    esttab reg_`s'_base reg_`s'_gain reg_`s'_trans_base reg_`s'_trans_gain using ///
        "`TABLES'/Medical_`label'_shock_insurance.tex", replace se label b(3) se(3) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Medical Expenditure — Insurance Heterogeneity") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls" "Interaction Type") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Interaction terms show heterogeneous effects of ΔHealth by baseline (2007) and gained insurance (2007–2014). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# EARNINGS Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH × Baseline insurance
    eststo reg_`s'_base: reg d_learning c.d_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline"

    * (2) ΔC ~ ΔH × Insurance Gain
    eststo reg_`s'_gain: reg d_learning c.d_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain"

    * (3) ΔC ~ transition × Baseline insurance
    eststo reg_`s'_trans_base: reg d_learning i.trans_`s'##i.hformal_ins07 ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Baseline (transition)"

    * (4) ΔC ~ transition × Insurance Gain
    eststo reg_`s'_trans_gain: reg d_learning i.trans_`s'##i.ins_gain ///
        `ctrls' i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
    estadd local Interaction "Gain (transition)"

    * Export neatly
    esttab reg_`s'_base reg_`s'_gain reg_`s'_trans_base reg_`s'_trans_gain using ///
        "`TABLES'/Earning_`label'_shock_insurance.tex", replace se label b(3) se(3) ///
        star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Earning — Insurance Heterogeneity") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls" "Interaction Type") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Interaction terms show heterogeneous effects of ΔHealth by baseline (2007) and gained insurance (2007–2014). Standard errors clustered at province level.")

    local ++i
}