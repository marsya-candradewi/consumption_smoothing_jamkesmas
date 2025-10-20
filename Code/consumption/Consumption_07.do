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

**# ADJUST WITH INDONESIA YEARLY INFLATION FROM BPS
** 2008 - 2013 from BPS 11.06	2.78	6.96	3.79	4.30	8.38	
local allcons "totcons foodcon nonfood badcon invexp xmedical" 
local allpccons "pce pcfoodcon pcbadcon pcnonfoodcon pcinvexp pcmedicalexp"

foreach var in `allcons' `allpccons' {
	replace `var' = `var' * 1.111 * 1.0278 * 1.07 * 1.038 * 1.043 * 1.084
}

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
