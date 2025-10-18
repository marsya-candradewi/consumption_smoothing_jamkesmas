log using "`LOG'/Consumption_14", text replace

/*Consumption 2014*/
clear
set more off
use "`WORKING_CONS'/pcewohhsize14.dta", clear
mmerge hhid14 using "`WORKING_CHARA'/hhsize14.dta"
keep if _merge==3
gen totcons= hhexp-xmedical
gen pce=totcons/hhsize

gen foodcon=xfood
gen pcfoodcon=foodcon/hhsize

gen badcon=maltb
gen pcbadcon=badcon/hhsize

gen nonfoodcon=xnonfood-xmedical
gen pcnonfoodcon=nonfoodcon/hhsize

gen invexp=xhouse+xeducall
gen pcinvexp=invexp/hhsize

gen pcmedicalexp= xmedical/hhsize

gen ltotcons=log(totcons)
gen ltotfood=log(foodcon)
gen ltotnonfood=log(nonfood)
gen ltotbad=log(badcon)
gen ltotinv=log(invexp)
gen ltotmed=log(xmedical)

gen lpce=log(pce)
gen lfood=log(pcfoodcon)
gen lbad=log(pcbadcon+1)
gen lnonfood=log(pcnonfood)
gen linv=log(pcinvexp)
gen lmedical=log(pcmedicalexp+1)

gen lhhsize=log(hhsize)

keep hhid14 commid14 kabid kecid provid hhsize lhhsize totcons pce foodcon pcfoodcon badcon pcbadcon nonfoodcon pcnonfoodcon invexp pcinvexp xmedical pcmedicalexp ltot* lpce lfood lbad lnonfood linv lmedical

save "`WORKING_CONS'/consumption14.dta", replace

log close
