**# DAYS OF SICKNESS
gen shock_pos = d_dh if d_dh>0
gen shock_neg = d_dh if d_dh<0
gen shock_mid = d_dh if inrange(d_dh, -10, 10)

twoway (scatter d_lfood d_dh if d_dh>0, mcolor(red%50)) ///
       (lfit d_lfood d_dh if d_dh>0, lcolor(red)), ///
       title("Positive Shocks (Worse Health)")

twoway (scatter d_lfood d_dh if d_dh<0, mcolor(blue%50)) ///
       (lfit d_lfood d_dh if d_dh<0, lcolor(blue)), ///
       title("Negative Shocks (Improving Health)")

preserve
	* group by deciles of d_dh
	xtile bin = d_dh, nq(10)
	collapse (mean) mean_food=d_lfood (count) n=d_lfood, by(bin)
	list
restore


gen small = abs(d_dh) <= 30
gen big   = abs(d_dh) > 30
reg d_lfood c.d_dh##i.big , vce(cluster provid14)

twoway (scatter d_lfood d_dh if small, mcolor(navy%30)) ///
       (lfit d_lfood d_dh if small, lcolor(navy) lwidth(medthick)), ///
       title("Small Health Shocks (|Δ| ≤ 30)") ///
       xtitle("Δ Health (percent of 28 days)") ///
       ytitle("Δ log(Food Consumption)") ///
       legend(off)

	   twoway (scatter d_lfood d_dh if big, mcolor(maroon%40)) ///
       (lfit d_lfood d_dh if big, lcolor(maroon) lwidth(medthick)), ///
       title("Big Health Shocks (|Δ| > 30)") ///
       xtitle("Δ Health (percent of 28 days)") ///
       ytitle("Δ log(Food Consumption)") ///
       legend(off)

	   twoway (scatter d_lfood d_dh if small, mcolor(navy%25)) ///
       (scatter d_lfood d_dh if big, mcolor(maroon%40)) ///
       (lfit d_lfood d_dh if small, lcolor(navy)) ///
       (lfit d_lfood d_dh if big, lcolor(maroon)), ///
       legend(order(1 "Small shocks" 2 "Big shocks")) ///
       title("Δ log(Food) vs Health Shock: Small vs Big")

	   twoway ///
 (lowess d_lfood d_dh if abs(d_dh)<=30, lcolor(navy) lwidth(medthick)) ///
 (lowess d_lfood d_dh if abs(d_dh)>30,  lcolor(maroon) lwidth(medthick)), ///
 legend(order(1 "Small shocks" 2 "Big shocks")) ///
 title("Lowess Fit: Small vs Big Health Shocks") ///
 ytitle("Δ log(Food Consumption)") ///
 xtitle("Δ Health (percent of 28 days)")
 
**# ADL
gen adl_shock = .
replace adl_shock = -1 if d_headADL < 0
replace adl_shock =  0 if d_headADL == 0
replace adl_shock =  1 if d_headADL > 0

* 1. recode to ensure nonnegative factor levels
recode adl_shock (-1=1) (0=2) (1=3), gen(adl_shock_f)
label drop adlshock
label define adlshock 1 "Improved" 2 "No change" 3 "Worse"
label values adl_shock_f adlshock

* 2. run regression as a factor variable
reg d_lfood i.adl_shock_f if t==1, vce(cluster provid14)

* 3. get margins and plot
margins adl_shock_f
marginsplot, recast(bar) ytitle("Δ log(Food Consumption)") ///
    title("Average Δ log(Food) by ADL Shock Type")

**# Chronic
gen chronic_shock = .
replace chronic_shock = -1 if d_headchronic < 0
replace chronic_shock =  0 if d_headchronic == 0
replace chronic_shock =  1 if d_headchronic > 0
label define chronicshock 1 "Improved" 2 "No change" 3 "Worse"
recode chronic_shock (-1=1) (0=2) (1=3), gen(chronic_shock_f)
label values chronic_shock_f chronicshock

reg d_lfood i.chronic_shock_f if t==1, vce(cluster provid14)
margins chronic_shock_f
marginsplot, recast(bar) ///
    title("Average Δlog(Food) by Chronic Shock Type") ///
    ytitle("Δlog(Food Consumption)") ///
    xtitle("") 