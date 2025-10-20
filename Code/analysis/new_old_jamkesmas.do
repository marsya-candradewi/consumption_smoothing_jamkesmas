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

reg d_lnonfood i.status##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lfood i.status##c.d_dh ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)

reg d_lnonfood i.status##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)
reg d_lfood i.status##c.d_headchronic ///
    base_heduc shareprodage sharechild i.provid14 if t==1, vce(cluster provid14)