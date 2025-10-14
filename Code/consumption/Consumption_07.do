log using "`LOG'/Consumption 07", text replace

/*Consumption 2007*/
clear
set more off
use "`RAW_CONS'/pce07nom.dta", clear

gen totcons= hhexp-xmedical
drop pce
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
gen lnonfood=log(pcnonfood)
gen lbad=log(pcbadcon+1)
gen linv=log(pcinvexp)
gen lmedical=log(pcmedicalexp+1)

gen lhhsize=log(hhsize)

keep hhid07 commid07 kabid kecid provid hhsize lhhsize totcons pce foodcon pcfoodcon badcon pcbadcon nonfoodcon pcnonfoodcon invexp pcinvexp xmedical pcmedicalexp ltot* lpce lfood lbad lnonfood linv lmedical

save "`WORKING_CONS'/consumption07.dta", replace

log close
