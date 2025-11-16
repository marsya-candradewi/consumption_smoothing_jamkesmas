**# DAYS OF SICK
* Fit
reg d_lfood i.hjamkesmas14##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot predicted Δfood across shock values, by status
sum d_dh if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hjamkesmas14, at(d_dh=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")

**# ADL
* Fit
reg d_lnonfood i.hjamkesmas14##c.d_headADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot predicted Δfood across shock values, by status
sum d_dh if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hjamkesmas14, at(d_headADL=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")

**# CHRONIC ILLNESS
* Fit
reg d_lnonfood i.hjamkesmas14##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot predicted Δfood across shock values, by status
sum d_dh if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hjamkesmas14, at(d_dh=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")

**************** TOTAL AS HOUSEHOLD
**# DAYS OF SICKNESS
reg d_lfood i.hsjamkesmas14##c.d_hsdays ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

	* Plot predicted Δfood across shock values, by status
sum d_hsdays if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hsjamkesmas14, at(d_hsdays=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")

**# ADL
* Fit
reg d_lnonfood i.hsjamkesmas14##c.d_hsADL ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot predicted Δfood across shock values, by status
sum d_hsADL if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hsjamkesmas14, at(d_hsADL=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")

**# CHRONIC ILLNESS
* Fit
reg d_lnonfood i.hjamkesmas14##c.d_hschronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot predicted Δfood across shock values, by status
sum d_hschronic if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hjamkesmas14, at(d_hschronic=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (head)")
	
**#
* Fit
reg d_lfood i.hjamkesmas14##c.d_ds ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

* Plot predicted Δfood across shock values, by status
sum d_ds if t==1
local lo = floor(r(min))
local hi = ceil(r(max))

margins hjamkesmas14, at(d_ds=(`lo'(5)`hi'))
marginsplot, recast(line) noci xline(0, lp(dash)) ///
    legend(order(1 "Not Insured" 2 "Insured")) ///
    ytitle("Predicted Δ log(food)") xtitle("Δ days sick (spouse)")
