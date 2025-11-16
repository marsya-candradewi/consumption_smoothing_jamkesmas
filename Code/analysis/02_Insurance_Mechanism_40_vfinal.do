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
local main "pce pcmedical earningpc"
local cons   "foodcon nfoodess discre badcon intrans"

**********************************************
**# TOTAL CONSUMPTION, MEDICAL, EARNING  #**
**********************************************
eststo clear
local i = 1

foreach s of local shocks {
	local label : word `i' of `names'
	foreach m of local main {
		display as text "Running Δ`m' on Δ`s', ΔI, and interaction"

		eststo reg_`s'_`m': ///
			reghdfe d_l`m' d_`s' d_hjamkesmas c.d_`s'#c.d_hjamkesmas ///
			base_heduc base_headage base_headagesq ///
			d_prodage d_child d_fhead d_urban moved ///
			if t == 1 & d_PKH !=1 , absorb(provid14) vce(cluster provid14)
	}
	local ++i
}

* -------------------------------- *
* Panel A: ADL
* -------------------------------- *
esttab reg_headADL_pce reg_headADL_pcmedical reg_headADL_earningpc ///
    using "`TABLES'/panel_ins_ADL.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
    keep(d_headADL d_hjamkesmas c.d_headADL#c.d_hjamkesmas) ///
    varlabels(d_headADL "$\Delta$ Head's ADL Index (0--1)" ///
              d_hjamkesmas "$\Delta$ Jamkesmas Coverage" ///
              c.d_headADL#c.d_hjamkesmas "$\Delta$ ADL $\times$ $\Delta$ Jamkesmas") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{6cm}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering})

filefilter "`TABLES'/panel_ins_ADL.tex" "`TABLES'/panel_ins_ADL_clean.tex", ///
    from("\BSmidrule") to("") replace


* -------------------------------- *
* Panel B: Days of Sickness
* -------------------------------- *
esttab reg_dh_pce reg_dh_pcmedical reg_dh_earningpc ///
    using "`TABLES'/panel_ins_Days.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
    keep(d_dh d_hjamkesmas c.d_dh#c.d_hjamkesmas) ///
    varlabels(d_dh "$\Delta$ Head's Days of Sickness" ///
              d_hjamkesmas "$\Delta$ Jamkesmas Coverage" ///
              c.d_dh#c.d_hjamkesmas "$\Delta$ Days $\times$ $\Delta$ Jamkesmas") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{6cm}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering})

filefilter "`TABLES'/panel_ins_Days.tex" "`TABLES'/panel_ins_Days_clean.tex", ///
    from("\BSmidrule") to("") replace

**********************************************
**# CONSUMPTION BREAKDOWN (5 CATEGORIES)   #**
**********************************************
eststo clear
local i = 1

foreach s of local shocks {
	local label : word `i' of `names'
	foreach c of local cons {
		display as text "Running Δ`c' on Δ`s', ΔI, and interaction"

		eststo reg_`s'_`c': ///
			reghdfe d_lpc`c' d_`s' d_hjamkesmas c.d_`s'#c.d_hjamkesmas ///
			base_heduc base_headage base_headagesq ///
			d_prodage d_child d_fhead d_urban moved ///
			if t == 1  & d_PKH !=1, absorb(provid14) vce(cluster provid14)
	}
	local ++i
}

* -------------------------------- *
* Panel A: ADL
* -------------------------------- *
esttab reg_headADL_foodcon reg_headADL_nfoodess reg_headADL_discre ///
    reg_headADL_badcon reg_headADL_intrans ///
    using "`TABLES'/panel_ins_ADL_cons.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
    keep(d_headADL d_hjamkesmas c.d_headADL#c.d_hjamkesmas) ///
    varlabels(d_headADL "$\Delta$ Head's ADL Index (0--1)" ///
              d_hjamkesmas "$\Delta$ Jamkesmas Coverage" ///
              c.d_headADL#c.d_hjamkesmas "$\Delta$ ADL $\times$ $\Delta$ Jamkesmas") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{6cm}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering})

filefilter "`TABLES'/panel_ins_ADL_cons.tex" "`TABLES'/panel_ins_ADL_cons_clean.tex", ///
    from("\BSmidrule") to("") replace


* -------------------------------- *
* Panel B: Days of Sickness
* -------------------------------- *
esttab reg_dh_foodcon reg_dh_nfoodess reg_dh_discre ///
    reg_dh_badcon reg_dh_intrans ///
    using "`TABLES'/panel_ins_Days_cons.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
    keep(d_dh d_hjamkesmas c.d_dh#c.d_hjamkesmas) ///
    varlabels(d_dh "$\Delta$ Head's Days of Sickness" ///
              d_hjamkesmas "$\Delta$ Jamkesmas Coverage" ///
              c.d_dh#c.d_hjamkesmas "$\Delta$ Days $\times$ $\Delta$ Jamkesmas") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{6cm}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering}p{2.3cm}<{\centering})

filefilter "`TABLES'/panel_ins_Days_cons.tex" "`TABLES'/panel_ins_Days_cons_clean.tex", ///
    from("\BSmidrule") to("") replace
