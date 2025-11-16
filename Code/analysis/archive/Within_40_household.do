*** NOTE: 
* this returns error!!!!!!!!!!

* ===============================
* Diagnostic averages (bottom 40%) WITH true within-HH deltas
* ===============================
egen hh_id = group(hhid07), label
keep if hh_bottom40_07==1 | hh_bottom40_14==1
xtset hh_id t

local vars lpce lfood lnonfood lbad lmedical learningpc
local illnesses "headADL headchronic dh"

tempfile outlist
local first 1

foreach ill of local illnesses {
    preserve
    keep hh_id t `ill' `vars'
    reshape wide `ill' `vars', i(hh_id) j(t)

    * Normalize illness to binary where needed
    if inlist("`ill'", "headADL", "dh") {
        replace `ill'0 = (`ill'0 > 0) if !missing(`ill'0)
        replace `ill'1 = (`ill'1 > 0) if !missing(`ill'1)
    }

    drop if missing(`ill'0) | missing(`ill'1)

    gen byte trans = .
    replace trans = 1 if `ill'0==0 & `ill'1==0
    replace trans = 2 if `ill'0==0 & `ill'1==1
    replace trans = 3 if `ill'0==1 & `ill'1==0
    replace trans = 4 if `ill'0==1 & `ill'1==1
    label define translbl 1 "StayHealthy" 2 "BecomeSick" 3 "Recover" 4 "StaySick"
    label values trans translbl

    * Per-variable intersection flags + deltas
    foreach v of local vars {
        gen byte both_`v' = !missing(`v'0) & !missing(`v'1)
        gen d_`v' = `v'1 - `v'0 if both_`v'
    }

    * Also keep raw level means for reference (computed over "both_*" intersections)
    foreach v of local vars {
        gen `v'_0_ref = `v'0 if both_`v'
        gen `v'_1_ref = `v'1 if both_`v'
    }

    * Collapse: means of deltas over valid HHs for that variable; Ns = count of valid HHs
	collapse ///
		(mean) d_lpce d_lfood d_lnonfood d_lbad d_lmedical d_learningpc ///
				lpce_0_ref=lpce_0_ref lfood_0_ref=lfood_0_ref lnonfood_0_ref=lnonfood_0_ref ///
				lbad_0_ref=lbad_0_ref lmedical_0_ref=lmedical_0_ref learningpc_0_ref=learningpc_0_ref ///
				lpce_1_ref=lpce_1_ref lfood_1_ref=lfood_1_ref lnonfood_1_ref=lnonfood_1_ref ///
				lbad_1_ref=lbad_1_ref lmedical_1_ref=lmedical_1_ref learningpc_1_ref=learningpc_1_ref ///
		(count) N_lpce = d_lpce N_lfood = d_lfood N_lnonfood = d_lnonfood ///
				N_lbad = d_lbad N_lmedical = d_lmedical N_learningpc = d_learningpc, ///
		by(trans)
    * Tidy labels and illness tag
    gen str12 illness = "`ill'"

    if `first' {
        tempfile base
        save `base', replace
        local first 0
    }
    else {
        append using `base'
        save `base', replace
    }

    restore
}

use `base', clear
order illness trans ///
      lpce_0_ref lpce_1_ref d_lpce ///
      lmedical_0_ref lmedical_1_ref d_lmedical ///
      lfood_0_ref lfood_1_ref d_lfood ///
      lnonfood_0_ref lnonfood_1_ref d_lnonfood ///
      lbad_0_ref lbad_1_ref d_lbad ///
      learningpc_0_ref learningpc_1_ref d_learningpc ///
      N_lpce N_lmedical N_lfood N_lnonfood N_lbad N_learningpc

label var N_lpce        "HHs w/ both-year lpce"
label var N_lmedical    "HHs w/ both-year lmedical"
label var N_learningpc  "HHs w/ both-year learningpc"
list, abbrev(20)
