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

use "`WORKING_MER'/final0714_bottom40", clear

local shocks "dh headADL headchronic"
local names  "Days ADL Chronic"

*******************************
**# TOTAL CONSUMPTION Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpce d_`s' if t == 1, vce(cluster kabid14)

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpce d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster kabid14)


    * (3) ΔC ~ ΔH + controls + kab FE
    eststo reg_`s'_FEkab: reghdfe d_lpce d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, absorb(kabid14) vce(cluster kabid14)

	
	* (4) ΔC ~ ΔH + controls + kab FE + provid FE
    eststo reg_`s'_FEprov: reghdfe d_lpce d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, absorb(kabid14 provid14) vce(cluster kabid14)

	estfe reg_`s'_FEkab reg_`s'_FEprov, labels(kabid14 "District FE" provid14 "Province FE")

    * Export
	esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FEkab reg_`s'_FEprov using "`TABLES'/`label'_shock_bot40.tex", ///
		replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
		title("Effect of `label' Health Change on Total Non-Medical Consumption") ///
		alignment(D{.}{.}{-1}) nonotes booktabs ///
		nodepvars ///
	    nomtitles ///
		mgroups("OLS" "OLS + Controls" "District FE" "District + Prov FE", ///
				pattern(1 1 1 1) prefix(\multicolumn{1}{c}{) suffix(}) span) ///
		indicate("Controls = base_heduc base_headage base_headagesq d_prodage d_child d_fhead d_urban moved" `r(indicate_fe)') ///
		stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
		addnotes("Clustered standard errors at the district level are in parentheses.")

    local ++i
}

estfe reg_headADL_FEkab reg_dh_FEkab reg_headADL_FEprov reg_dh_FEprov, labels(kabid14 "District FE" provid14 "Province FE")

esttab reg_headADL_controls reg_headADL_FEkab reg_headADL_FEprov ///
    using "`TABLES'/panelA_ADL.tex", replace se label b(3) se(3) ///
	indicate(`r(indicate_fe)') ///
    star(* 0.1 ** 0.05 *** 0.01) nonotes booktabs nodepvars nomtitles ///
    stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
    addnotes("") fragment

esttab reg_dh_controls reg_dh_FEkab reg_dh_FEprov ///
    using "`TABLES'/panelB_days.tex", replace se label b(3) se(3) ///
		indicate(`r(indicate_fe)') ///
    star(* 0.1 ** 0.05 *** 0.01) nonotes booktabs nodepvars nomtitles ///
    stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
    addnotes("") fragment

pause

esttab reg_headADL_controls reg_headADL_FEkab reg_headADL_FEprov ///
       reg_dh_controls reg_dh_FEkab reg_dh_FEprov ///
    using "`TABLES'/combined_healthshock_trial.tex", replace ///
    order(d_headADL d_dh base_heduc base_headage base_headagesq ///
          d_prodage d_child d_fhead d_urban moved kabid14 provid14 _cons) ///
    se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Effect of Health Change on Total Non-Medical Consumption") ///
    alignment(D{.}{.}{-1}) nonotes booktabs nodepvars nomtitles ///
	indicate(`r(indicate_fe)') drop(kabid14 provid14) ///
    mgroups("ADL" "Days Sick", ///
            pattern(1 1) ///
            prefix(\multicolumn{3}{c}{) suffix(}) span ///
            erepeat(\cmidrule(lr){2-4}\cmidrule(lr){5-7})) ///
    stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
    addnotes("Clustered standard errors at the district level are in parentheses.")
	
pause

*******************************
**# FOOD without transfers Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpcfoodcon d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpcfoodcon d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    * (3) ΔC ~ ΔH + controls + province FE
    eststo reg_`s'_FE: reg d_lpcfoodcon d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
	
    * Export
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Food2_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Food Consumption") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔC ~ ΔH (continuous change). Regression (4): ΔC ~ i.transition (categorical shock). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# NONFOOD ESSENTIALS Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpcnfoodess d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpcnfoodess d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    * (3) ΔC ~ ΔH + controls + province FE
    eststo reg_`s'_FE: reg d_lpcnfoodess d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
	
    * Export
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Nfoodess_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Nonfood Essential Consumption") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔC ~ ΔH (continuous change). Regression (4): ΔC ~ i.transition (categorical shock). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# DISCRETIONARY Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpcdiscre d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpcdiscre d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    * (3) ΔC ~ ΔH + controls + province FE
    eststo reg_`s'_FE: reg d_lpcdiscre d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
	
    * Export
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Discre_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Discretionary Consumption") ///
        alignment(D{.}{.}{-1}) ///
		mtitles("OLS\\newline (1)" "OLS + Controls\\newline (2)" "District FE\\newline (3)" "District + Prov FE\\newline (4)") ///
		nodepvars nomtitles ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔC ~ ΔH (continuous change). Regression (4): ΔC ~ i.transition (categorical shock). Standard errors clustered at province level.")

    local ++i
}
pause
*******************************
**# HARMFUL Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpcbadcon d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpcbadcon d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    * (3) ΔC ~ ΔH + controls + province FE
    eststo reg_`s'_FE: reg d_lpcbadcon d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
	
    * Export
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Harm_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Harmful Consumption") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔC ~ ΔH (continuous change). Regression (4): ΔC ~ i.transition (categorical shock). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# IN KIND TRANSFERS #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpcintrans d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpcintrans d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    * (3) ΔC ~ ΔH + controls + province FE
    eststo reg_`s'_FE: reg d_lpcintrans d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"
	
    * Export
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Inkind_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Consumption from Transfers") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔC ~ ΔH (continuous change). Regression (4): ΔC ~ i.transition (categorical shock). Standard errors clustered at province level.")

    local ++i
}

*******************************
**# MEDICAL Regressions #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    eststo reg_`s'_nocontrol: reg d_lpcmedical d_`s' if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "No"

    eststo reg_`s'_controls: reg d_lpcmedical d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		 if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_lpcmedical d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Medical_`label'_shock_bot40.tex", ///
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
        d_prodage d_child d_fhead d_urban moved ///
		 if t == 1, vce(cluster provid14)
    estadd local FE "No"
    estadd local Controls "Yes"

    eststo reg_`s'_FE: reg d_learning d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		i.provid14 if t == 1, vce(cluster provid14)
    estadd local FE "Yes"
    estadd local Controls "Yes"

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Earnings_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Earnings (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔEarnings ~ ΔH. Regression (4): ΔEarnings ~ i.transition. Standard errors clustered at province level.")
    local ++i
}

pause


/* Deprecated
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

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Food_`label'_shock_bot40.tex", ///
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
	
    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Nonfood_`label'_shock_bot40.tex", ///
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

    esttab reg_`s'_nocontrol reg_`s'_controls reg_`s'_FE using "`TABLES'/Bad_`label'_shock_bot40.tex", ///
        replace se label b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
        title("Effect of `label' Health Change on Log Bad Consumption (Clustered at Province Level)") ///
        alignment(D{.}{.}{-1}) ///
        scalars("FE Province FE" "Controls Controls") ///
        stats(N r2, fmt(%9.0g 3) labels("Observations" "R-squared")) ///
        addnotes("Regressions (1)–(3): ΔBad ~ ΔH. Regression (4): ΔBad ~ i.transition. Standard errors clustered at province level.")
    local ++i
}



*/