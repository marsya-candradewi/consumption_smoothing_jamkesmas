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
**# TOTAL CONSUMPTION  #**
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

    local ++i
}

estfe reg_headADL_FEkab reg_dh_FEkab reg_headchronic_FEkab ///
	reg_headADL_FEprov reg_dh_FEprov reg_headchronic_FEprov, ///
	labels(kabid14 "District FE" provid14 "Province FE")

* -------------------------------- *
* Panel A: ADL
* -------------------------------- *
esttab reg_headADL_controls reg_headADL_FEkab reg_headADL_FEprov ///
    using "`TABLES'/panel_totcons_ADL.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
    keep(d_headADL) ///
    varlabels(d_headADL "$\Delta$ Head's ADL Index (0--1)") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering})

filefilter "`TABLES'/panel_totcons_ADL.tex" "`TABLES'/panel_totcons_ADL_clean.tex", ///
    from("\BSmidrule") to("") replace

* -------------------------------- *
* Panel B: Days of Sickness
* -------------------------------- *
esttab reg_dh_controls reg_dh_FEkab reg_dh_FEprov using "`TABLES'/panel_totcons_Days.tex", ///
    replace label nonotes noobs nodepvar ///
    b(%9.3f) se(%9.3f)     prehead("") posthead("") ///
    keep(d_dh) nomtitles nonumber ///
    varlabels(d_dh "$\Delta$ Head's Days of Sickness") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering}) ///
    booktabs fragment

filefilter "`TABLES'/panel_totcons_Days.tex" "`TABLES'/panel_totcons_Days_clean.tex", ///
    from("\BSmidrule") to("") replace

* -------------------------------- *
* Panel C: Chronic Illness
* -------------------------------- *
esttab reg_headchronic_controls reg_headchronic_FEkab reg_headchronic_FEprov /// 
	using "`TABLES'/panel_totcons_Chronic.tex", ///
    replace label nonotes noobs nodepvar ///
    b(%9.3f) se(%9.3f) prehead("") posthead("") ///
    keep(d_headchronic) nomtitles nonumber ///
    varlabels(d_headchronic "$\Delta$ Head's Chronic Illness (0--1)") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering}) ///
    booktabs fragment

filefilter "`TABLES'/panel_totcons_Chronic.tex" "`TABLES'/panel_totcons_Chronic_clean.tex", ///
    from("\BSmidrule") to("") replace

pause

*******************************
**# MEDICAL CONSUMPTION  #**
*******************************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_lpcmedical d_`s' if t == 1, vce(cluster kabid14)

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_lpcmedical d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster kabid14)

    * (3) ΔC ~ ΔH + controls + kab FE
    eststo reg_`s'_FEkab: reghdfe d_lpcmedical d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, absorb(kabid14) vce(cluster kabid14)
	
	* (4) ΔC ~ ΔH + controls + kab FE + provid FE
    eststo reg_`s'_FEprov: reghdfe d_lpcmedical d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, absorb(kabid14 provid14) vce(cluster kabid14)

    local ++i
}

estfe reg_headADL_FEkab reg_dh_FEkab reg_headchronic_FEkab ///
	reg_headADL_FEprov reg_dh_FEprov reg_headchronic_FEprov, ///
	labels(kabid14 "District FE" provid14 "Province FE")

* -------------------------------- *
* Panel A: ADL
* -------------------------------- *
esttab reg_headADL_controls reg_headADL_FEkab reg_headADL_FEprov ///
    using "`TABLES'/panel_med_ADL.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
    keep(d_headADL) ///
    varlabels(d_headADL "$\Delta$ Head's ADL Index (0--1)") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering})

filefilter "`TABLES'/panel_med_ADL.tex" "`TABLES'/panel_med_ADL_clean.tex", ///
    from("\BSmidrule") to("") replace

* -------------------------------- *
* Panel B: Days of Sickness
* -------------------------------- *
esttab reg_dh_controls reg_dh_FEkab reg_dh_FEprov using "`TABLES'/panel_med_Days.tex", ///
    replace label nonotes noobs nodepvar ///
    b(%9.3f) se(%9.3f)     prehead("") posthead("") ///
    keep(d_dh) nomtitles nonumber ///
    varlabels(d_dh "$\Delta$ Head's Days of Sickness") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering}) ///
    booktabs fragment

filefilter "`TABLES'/panel_med_Days.tex" "`TABLES'/panel_med_Days_clean.tex", ///
    from("\BSmidrule") to("") replace


pause

******************
**# EARNINGS  #**
******************
eststo clear
local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    * (1) ΔC ~ ΔH, no controls
    eststo reg_`s'_nocontrol: reg d_learningpc d_`s' if t == 1, vce(cluster kabid14)

    * (2) ΔC ~ ΔH + controls
    eststo reg_`s'_controls: reg d_learningpc d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, vce(cluster kabid14)

    * (3) ΔC ~ ΔH + controls + kab FE
    eststo reg_`s'_FEkab: reghdfe d_learningpc d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, absorb(kabid14) vce(cluster kabid14)
	
	* (4) ΔC ~ ΔH + controls + kab FE + provid FE
    eststo reg_`s'_FEprov: reghdfe d_learningpc d_`s' base_heduc base_headage base_headagesq ///
        d_prodage d_child d_fhead d_urban moved ///
		if t == 1, absorb(kabid14 provid14) vce(cluster kabid14)

    local ++i
}

estfe reg_headADL_FEkab reg_dh_FEkab reg_headchronic_FEkab ///
	reg_headADL_FEprov reg_dh_FEprov reg_headchronic_FEprov, ///
	labels(kabid14 "District FE" provid14 "Province FE")

* -------------------------------- *
* Panel A: ADL
* -------------------------------- *
esttab reg_headADL_controls reg_headADL_FEkab reg_headADL_FEprov ///
    using "`TABLES'/panel_earn_ADL.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
    keep(d_headADL) ///
    varlabels(d_headADL "$\Delta$ Head's ADL Index (0--1)") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering})

filefilter "`TABLES'/panel_earn_ADL.tex" "`TABLES'/panel_earn_ADL_clean.tex", ///
    from("\BSmidrule") to("") replace

* -------------------------------- *
* Panel B: Days of Sickness
* -------------------------------- *
esttab reg_dh_controls reg_dh_FEkab reg_dh_FEprov using "`TABLES'/panel_earn_Days.tex", ///
    replace label nonotes noobs nodepvar ///
    b(%9.3f) se(%9.3f)     prehead("") posthead("") ///
    keep(d_dh) nomtitles nonumber ///
    varlabels(d_dh "$\Delta$ Head's Days of Sickness") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering}) ///
    booktabs fragment

filefilter "`TABLES'/panel_earn_Days.tex" "`TABLES'/panel_earn_Days_clean.tex", ///
    from("\BSmidrule") to("") replace



pause

***************************************
**# DIFFERENT KINDS OF CONSUMPTION #**
***************************************
eststo clear
local shocks "dh headADL headchronic"
local names  "Days ADL Chronic"
local cons   "foodcon nfoodess discre badcon intrans"

local i = 1
foreach s of local shocks {
    local label : word `i' of `names'

    foreach c of local cons {
        eststo reg_`s'_`c': reghdfe d_lpc`c' d_`s' base_heduc base_headage base_headagesq ///
            d_prodage d_child d_fhead d_urban moved ///
            if t == 1, absorb(kabid14 provid14) vce(cluster kabid14)
    }

    local ++i
}

* -------------------------------- *
* Panel A: ADL
* -------------------------------- *

esttab reg_headADL_foodcon reg_headADL_nfoodess reg_headADL_discre ///
    reg_headADL_badcon reg_headADL_intrans ///
    using "`TABLES'/panel_constype_ADL.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
    keep(d_headADL) ///
    varlabels(d_headADL "$\Delta$ Head's ADL Index (0--1)") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering})

filefilter "`TABLES'/panel_constype_ADL.tex" "`TABLES'/panel_constype_ADL_clean.tex", ///
    from("\BSmidrule") to("") replace

* -------------------------------- *
* Panel B: Days of Sickness
* -------------------------------- *
esttab reg_dh_foodcon reg_dh_nfoodess reg_dh_discre ///
    reg_dh_badcon reg_dh_intrans ///
    using "`TABLES'/panel_constype_Days.tex", replace fragment booktabs ///
    nomtitles nonumber ///
    b(%9.3f) se(%9.3f) ///
    keep(d_dh) ///
    varlabels(d_dh "$\Delta$ Head's Days of Sickness") ///
    stats(N r2, fmt(0 3) labels("Observations" "R-squared")) ///
    prehead("") posthead("") postfoot("") refcat(N "", nolabel) ///
    alignment(p{5cm}p{2cm}<{\centering}p{2cm}<{\centering}p{2.5cm}<{\centering})

filefilter "`TABLES'/panel_constype_Days.tex" "`TABLES'/panel_constype_Days_clean.tex", ///
    from("\BSmidrule") to("") replace
