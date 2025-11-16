gen status = 0
replace status = 1 if new_hjamkesmas==1
replace status = 2 if old_hjamkesmas==1
label define status 0 "none" 1 "new" 2 "old"
label values status status

* sanity checks
tab status if t==1
assert inlist(status,0,1,2)

* model (pick your controls/FE as before)
reg d_lnonfood i.status##c.d_headADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lfood i.status##c.d_headADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

reg d_lfood c.d_hjamkesmas##c.d_headADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lnonfood c.d_hjamkesmas##c.d_headADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.status##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lfood i.status##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

reg d_lfood c.d_hjamkesmas##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lnonfood c.d_hjamkesmas##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.status##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lfood i.status##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

reg d_lfood c.d_hjamkesmas##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lnonfood c.d_hjamkesmas##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

	
**# GRAPHING
* Fit (note: you used continuous "c." but it's a 0/1)
reg d_lfood c.d_hjamkesmas##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot two lines: control (0) vs newly insured (1)
sum d_dh if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins, at(d_hjamkesmas=(0 1) d_dh=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Control" 2 "New Jamkesmas")) ///
    by(d_hjamkesmas) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")

	
label define jamkeg 1 "Newly insured" 2 "Old insured" 3 "Never insured"
gen jamkeg = .
replace jamkeg = 1 if new_hjamkesmas
replace jamkeg = 2 if old_hjamkesmas
replace jamkeg = 3 if never_hjamkesmas
label values jamkeg jamkeg

* Plot with distinct colors and legend labels
twoway (lfit d_lfood d_dh if t == 1 & jamkeg == 1, lcolor(red)   lwidth(medthick)) ///
       (lfit d_lfood d_dh if t == 1 & jamkeg == 2, lcolor(blue)  lwidth(medthick)) ///
       (lfit d_lfood d_dh if t == 1 & jamkeg == 3, lcolor(green) lwidth(medthick)), ///
       legend(order(1 "Newly insured" 2 "Old insured" 3 "Never insured") pos(6)) ///
       ytitle("Fitted values") xtitle("Δ Health shock (d_dh)") ///
       title("Consumption response to health shocks by Jamkesmas status")
	   

* Plot with distinct colors and legend labels
twoway (scatter d_lfood d_dh if t == 1 & jamkeg == 1, lcolor(red)   lwidth(medthick)) ///
       (scatter d_lfood d_dh if t == 1 & jamkeg == 3, lcolor(green) lwidth(medthick)), ///
       legend(order(1 "Newly insured" 2 "Never insured") pos(6)) ///
       ytitle("Fitted values") xtitle("Δ Health shock (d_dh)") ///
       title("Consumption response to health shocks by Jamkesmas status")
	   

* Are groups mutually exclusive and how big?
tab jamkeg if t==1, m    // 1=new, 2=old, 3=never

* How much variation in d_dh within each group?
sum d_dh if t==1 & jamkeg==1, d
sum d_dh if t==1 & jamkeg==2, d
sum d_dh if t==1 & jamkeg==3, d

* What are the within-group slopes?
reg d_lfood c.d_dh if t==1 & jamkeg==1, vce(cluster provid14)
reg d_lfood c.d_dh if t==1 & jamkeg==2, vce(cluster provid14)
reg d_lfood c.d_dh if t==1 & jamkeg==3, vce(cluster provid14)
