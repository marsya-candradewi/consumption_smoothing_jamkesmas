* Common support: trim extremes
_pctile d_dh if t==1, p(1 99)
local lo = r(r1)
local hi = r(r2)

twoway ///
 (lfit d_lfood d_dh if t==1 & jamkeg==1 & inrange(d_dh, `lo', `hi'), lcolor(red)) ///
 (lfit d_lfood d_dh if t==1 & jamkeg==2 & inrange(d_dh, `lo', `hi'), lcolor(blue)) ///
 (lfit d_lfood d_dh if t==1 & jamkeg==3 & inrange(d_dh, `lo', `hi'), lcolor(green)), ///
 legend(order(1 "Newly insured" 2 "Old insured" 3 "Never insured")) ///
 title("Consumption response to health shocks by Jamkesmas status") ///
 xtitle("Δ Health shock (d_dh)") ytitle("Δ Food consumption (fitted)")

 reg d_lfood c.d_dh##i.jamkeg if t==1, vce(cluster provid14)
margins jamkeg, at(d_dh=(-100(10)100))
marginsplot, noci recast(line) ///
 legend(order(1 "Newly insured" 2 "Old insured" 3 "Never insured")) ///
 title("Consumption response to health shocks by Jamkesmas status")

 sum d_dh if t==1, d
local p1 = r(p1)
local p99 = r(p99)

margins jamkeg, at(d_dh=(`p1'(5)`p99'))
marginsplot, noci recast(line) ///
 legend(order(1 "Newly insured" 2 "Old insured" 3 "Never insured")) ///
 title("Consumption response to health shocks by Jamkesmas status") ///
 xtitle("Δ Health shock (d_dh)") ytitle("Linear prediction")
 
preserve
	 * Keep only new vs never
	keep if (new_hjamkesmas == 1 | never_hjamkesmas == 1) & t == 1
	
	sum if new_hjamkesmas == 1
	sum if never_hjamkesmas == 1
	
	* Regression
	reg d_lfood c.d_dh##i.new_hjamkesmas i.provid14 ///
		base_heduc base_shareprodage base_sharechild base_headage ///
		base_headagesq base_urban d_totearning ///
		if d_PKH == 0, vce(cluster provid14)

restore

reg d_lfood i.new_hjamk##c.d_dh i.old_hjamk##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

twoway (lowess d_lfood d_dh if new_hjamk==1, bw(.8)) ///
       (lowess d_lfood d_dh if never_hjamk, bw(.8)), ///
       legend(order(1 "Newly insured" 2 "Never insured"))
	   
gen PAP14_1 = (PAP ==1 & t == 1)
egen PAP14 = sum(PAP14_1), by(hhid07)

gen nearpoor_control = (hjamkesmas14==0 & PAP14==1)

keep if new_hjamkesmas==1 | nearpoor_control==1

**#  VERY PRETTY GRAPH 
* Main regression
reg d_lfood i.new_hjamkesmas##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

sum d_dh if t==1
margins new_hjamkesmas, at(d_dh=(-10(5)10))
marginsplot, recast(line) noci xline(0) legend(order(1 "Control" 2 "New Jamkesmas"))

reg d_lfood i.new_hjamkesmas##c.d_headADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

sum d_headADL if t==1
margins new_hjamkesmas, at(d_headADL=(-10(5)10))
marginsplot, recast(line) noci xline(0) legend(order(1 "Control" 2 "New Jamkesmas"))


 //  (scatter d_lfood d_dh if t==1 & jamkeg==1 & inrange(d_dh, `lo', `hi'), mcolor(red%25)) ///
//  (scatter d_lfood d_dh if t==1 & jamkeg==2 & inrange(d_dh, `lo', `hi'), mcolor(blue%25)) ///
//  (scatter d_lfood d_dh if t==1 & jamkeg==3 & inrange(d_dh, `lo', `hi'), mcolor(green%25)) ///
