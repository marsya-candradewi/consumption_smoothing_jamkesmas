sum d_dh d_headADL d_headchronic if t==1
tab d_headADL if t==1
tab d_headchronic if t==1
count if t==1 & d_headADL!=0
count if t==1 & d_headchronic!=0

gen any_dh = (d_dh!=0)
reg d_lfood any_dh base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* sign & intensity separated
gen pos_dh = d_dh>0
gen neg_dh = d_dh<0
gen abs_dh = abs(d_dh)
reg d_lfood i.pos_dh i.neg_dh c.abs_dh base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

xtile wealth3 = earningpc if t==1, nq(3)
forvalues g=1/3 {
    reg d_lfood d_dh base_heduc shareprodage sharechild i.provid14 if t==1 & wealth3==`g', vce(cluster provid14)
}

**# Days Sick
* 1. Consumption Smoothing
eststo reg1: reg d_lpce d_dh base_heduc base_headage base_headagesq d_shareprodage d_sharechild  ///
	i.provid14 if t==1, vce(cluster provid14) // Negative, expected, but not sig

eststo reg2: reg d_lfood d_dh base_heduc base_headage base_headagesq  shareprodage sharechild  ///
	i.provid14 if t==1, vce(cluster provid14) // Negative, expected, but not sig

eststo reg3: reg d_lnonfood d_dh base_heduc base_headage base_headagesq  shareprodage sharechild  ///
	i.provid14 if t==1, vce(cluster provid14) // Negative, expected, but not sig

* 2. Channels
reg d_lmed d_dh base_heduc base_headage base_headagesq  shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14) // Positive, expected significant

reg d_learn d_dh base_heduc base_headage base_headagesq shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14) // Negative, expected significant
	
* 3. Insurance
* Create grouped categories for head
gen head_publicpoor = (hjamkesmas == 1)
gen head_state      = (haskes == 1 | hjamsostek == 1 | hjampersal == 1)
gen head_private    = (hemp_ins == 1 | hemp_clinic == 1 | hsaving_ins == 1 | hprivate_ins == 1)

* Mutually exclusive categorical variable
gen head_ins_group = 0
replace head_ins_group = 1 if head_publicpoor == 1
replace head_ins_group = 2 if head_state == 1 & head_publicpoor == 0
replace head_ins_group = 3 if head_private == 1 & head_publicpoor == 0 & head_state == 0

label define head_ins_lab 0 "None" 1 "Public poor-targeted" 2 "SOE/State" 3 "Private/formal"
label values head_ins_group head_ins_lab

reg d_lmed i.head_ins_group##c.d_dh base_heduc shareprodage sharechild ///
    i.provid14 if t==1, vce(cluster provid14)

reg d_lpce hformal_ins14##c.d_dh base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)
margins hformal_ins14, at(d_dh=(-20(4)20))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Uninsured" 2 "Insured")) ///
    ytitle("Predicted Δ log(PCE)") xtitle("Δ sick days (% of 28)") ///
    ylabel(, format(%4.3f)) scheme(s1color)

reg d_lmed i.hformal_ins14##c.d_dh base_heduc shareprodage sharechild ///
    i.provid14 if t==1, vce(cluster provid14)
	
reg d_lmed i.hformal_ins14##c.d_dh base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

* 4. Old vs New Insured
reg d_lpce new_hformal_ins##c.d_dh base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14)

gen switch_hformal_ins_1 = (hformal_ins14==1 & t == 0 & inlist(head_ins_group,2,3))  
egen switch_hformal_ins = sum(switch_hformal_ins_1), by(hhid07)

gen coverage_status = 0
replace coverage_status = 1 if new_hformal_ins==1
replace coverage_status = 2 if switch_hformal_ins==1
label define covlab 0 "Uninsured" 1 "Newly insured (expansion)" 2 "Switcher (crowded-out)"
label values coverage_status covlab

**# CONSUMPTION
* ALL
reg d_lpce i.coverage_status##c.d_dh base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* BOTTOM 40 ONLY
reg d_lpce i.coverage_status##c.d_dh base_heduc shareprodage sharechild i.provid14 ///
	if t==1 & hh_bottom40_07 == 1 & hh_bottom40_14 ///
	, vce(cluster provid14)
**# MED
reg d_lmedical i.coverage_status##c.d_dh base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* BOTTOM 40 ONLY
reg d_lmedical i.coverage_status##c.d_dh base_heduc shareprodage sharechild i.provid14 ///
	if t==1 & hh_bottom40_07 == 1 & hh_bottom40_14 ///
	, vce(cluster provid14)
	
**# ADL
reg d_lmed d_headADL base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14) // Positive, expected not sig
reg d_learn d_headADL base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14) // Negative, expected not sig

**# Chronic
reg d_lmed d_headchronic base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14) // Positive, expected
reg d_learn d_headchronic base_heduc shareprodage sharechild ///
	i.provid14 if t==1, vce(cluster provid14) // Negative, expected not sig