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

use "`WORKING_MER'/final0714_bottom40", clear

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

*******************************
**# TOTAL CONSUMPTION Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpce d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpce d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    * (3) ΔC ~ ΔH + controls + province FE
    eststo reg_`s'_FE: reg d_lpce d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    * (4) ΔC ~ transition (categorical)
    eststo reg_`s'_trans: reg d_lpce i.trans_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    * Export
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE reg_`s'_trans using "`TABLES'/`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Consumption (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔC ~ ΔH (continuous change). Regression (4): ΔC ~ i.transition (categorical shock). Standard errors clustered at province level.")

    local ++i
}


*******************************
**# FOOD CONSUMPTION Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    eststo reg_`s'_nocontrol: reg d_lfood d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    eststo reg_`s'_controls: reg d_lfood d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_lfood d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    eststo reg_`s'_trans: reg d_lfood i.trans_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE reg_`s'_trans using "`TABLES'/Food_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Food Consumption (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔFood ~ ΔH. Regression (4): ΔFood ~ i.transition. Standard errors clustered at province level.")
    local ++i
}


*******************************
**# NONFOOD CONSUMPTION Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    eststo reg_`s'_nocontrol: reg d_lnonfood d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    eststo reg_`s'_controls: reg d_lnonfood d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_lnonfood d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    eststo reg_`s'_trans: reg d_lnonfood i.trans_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE reg_`s'_trans using "`TABLES'/Nonfood_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Nonfood Consumption (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔNonfood ~ ΔH. Regression (4): ΔNonfood ~ i.transition. Standard errors clustered at province level.")
    local ++i
}


*******************************
**# BAD CONSUMPTION Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    eststo reg_`s'_nocontrol: reg d_lbad d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    eststo reg_`s'_controls: reg d_lbad d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_lbad d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    eststo reg_`s'_trans: reg d_lbad i.trans_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE reg_`s'_trans using "`TABLES'/Bad_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Bad Consumption (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔBad ~ ΔH. Regression (4): ΔBad ~ i.transition. Standard errors clustered at province level.")
    local ++i
}


*******************************
**# MEDICAL Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    eststo reg_`s'_nocontrol: reg d_lmedical d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    eststo reg_`s'_controls: reg d_lmedical d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_lmedical d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    eststo reg_`s'_trans: reg d_lmedical i.trans_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE reg_`s'_trans using "`TABLES'/Medical_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Medical Spending (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔMedical ~ ΔH. Regression (4): ΔMedical ~ i.transition. Standard errors clustered at province level.")
    local ++i
}


*******************************
**# EARNINGS Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    eststo reg_`s'_nocontrol: reg d_learning d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    eststo reg_`s'_controls: reg d_learning d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_learning d_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    eststo reg_`s'_trans: reg d_learning i.trans_`s' base_heduc base_headage base_headagesq ///
        d_shareprodage d_sharechild i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE reg_`s'_trans using "`TABLES'/Earnings_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Earnings (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔEarnings ~ ΔH. Regression (4): ΔEarnings ~ i.transition. Standard errors clustered at province level.")
    local ++i
}

