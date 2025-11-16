* ===============================
* Diagnostic averages (bottom 40%) WITH Ns
* ===============================

egen hh_id = group(hhid07)
keep if hh_bottom40_07==1 | hh_bottom40_14==1   // bottom 40 cohort
xtset hh_id t

local vars lpce lfood lnonfood lbad lmedical learningpc
local illnesses "headADL headchronic dh"

foreach ill of local illnesses {
    preserve
    keep hh_id t `ill' `vars'
    reshape wide `ill' `vars', i(hh_id) j(t)

    * --- normalize illness to binary (ADL & dh: >0 => sick) ---
    if inlist("`ill'", "headADL", "dh") {
        replace `ill'0 = (`ill'0 > 0) if !missing(`ill'0)
        replace `ill'1 = (`ill'1 > 0) if !missing(`ill'1)
    }

    * Require illness observed in BOTH waves for a valid transition  // NEW:
    drop if missing(`ill'0) | missing(`ill'1)

    * --- transition groups ---
    gen byte trans = .
    replace trans = 1 if `ill'0==0 & `ill'1==0   // stayed healthy
    replace trans = 2 if `ill'0==0 & `ill'1==1   // became sick
    replace trans = 3 if `ill'0==1 & `ill'1==0   // recovered
    replace trans = 4 if `ill'0==1 & `ill'1==1   // stayed sick
    label define translbl 1 "StayHealthy" 2 "BecomeSick" 3 "Recover" 4 "StaySick"
    label values trans translbl

    * --- per-variable pairwise non-missing flags (both years)  // NEW:
    foreach v of local vars {
        gen byte N_`v' = !missing(`v'0) & !missing(`v'1)
    }
    * overall N = households with both-year illness defined (already enforced above)  // NEW:
    gen byte N_total = 1

    * --- compute means for both years + Ns ---
    collapse (mean) lpce0 lpce1 lfood0 lfood1 lnonfood0 lnonfood1 ///
                     lbad0 lbad1 lmedical0 lmedical1 learningpc0 learningpc1 ///
             (sum)  N_total N_lpce N_lfood N_lnonfood N_lbad N_lmedical N_learningpc, ///
             by(trans)

    * --- deltas (2014 - 2007) ---
    foreach v of local vars {
        gen d_`v' = `v'1 - `v'0
    }

    gen str12 illness = "`ill'"
    tempfile f_`ill'
    save `f_`ill'', replace
    restore
}

* --- combine all illness transition summaries ---
use `f_headADL', clear
append using `f_headchronic'
append using `f_dh'

order illness trans ///
      lpce0 lpce1 d_lpce lmedical0 lmedical1 d_lmedical ///
      lfood0 lfood1 d_lfood lnonfood0 lnonfood1 d_lnonfood ///
      lbad0 lbad1 d_lbad learningpc0 learningpc1 d_learningpc ///
      N_total N_lpce N_lmedical N_lfood N_lnonfood N_lbad N_learningpc

label var trans "Transition (StayHealthy / BecomeSick / Recover / StaySick)"
label var N_total "Households in transition group"
label var N_lpce  "N with lpce in both years"
label var N_lmedical "N with lmedical in both years"
label var N_learningpc "N with learningpc in both years"

list, abbrev(20)
