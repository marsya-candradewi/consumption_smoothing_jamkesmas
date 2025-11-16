* 2007 and 2014 values by household
bys hhid07: egen ins07 = max(hformal_ins) if t==0
bys hhid07: egen ins14 = max(hformal_ins) if t==1
bys hhid07: egen jam07 = max(hjamkesmas)  if t==0
bys hhid07: egen jam14 = max(hjamkesmas)  if t==1
bys hhid07: egen prv07 = max(hprivate_ins)    if t==0
bys hhid07: egen prv14 = max(hprivate_ins)    if t==1

* Carry them to both rows and keep one copy
bys hhid07: replace ins07 = ins07[_N]
bys hhid07: replace ins14 = ins14[_N]
bys hhid07: replace jam07 = jam07[_N]
bys hhid07: replace jam14 = jam14[_N]
bys hhid07: replace prv07 = prv07[_N]
bys hhid07: replace prv14 = prv14[_N]

gen never_ins  = ins07==0 & ins14==0
gen new_ins    = ins07==0 & ins14==1   // expansion take-up (0→1)
gen lost_ins   = ins07==1 & ins14==0   // lost coverage (1→0)
gen always_ins = ins07==1 & ins14==1   // continuous (1→1)

* Collapse to a single categorical variable
gen coverage_status = .
replace coverage_status = 0 if never_ins
replace coverage_status = 1 if new_ins
replace coverage_status = 2 if lost_ins
replace coverage_status = 3 if always_ins

label define covlab 0 "Uninsured (0→0)" 1 "Newly insured (0→1)" 2 "Lost coverage (1→0)" 3 "Always insured (1→1)"
label values coverage_status covlab

* Attach status only to the delta observation
replace coverage_status = . if t==0

reg d_lmed i.coverage_status##c.d_dh base_heduc shareprodage sharechild i.provid14 ///
    if t==1, vce(cluster provid14)
