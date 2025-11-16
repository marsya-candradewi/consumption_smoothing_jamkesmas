log using "`LOG'/Consumption_14", text replace

/*Consumption 2014*/
clear
set more off
use "`WORKING_CONS'/pcewohhsize14.dta", clear
mmerge hhid14 using "`WORKING_CHARA'/hhsize14.dta"
keep if _merge==3

* 1. Generate Total Non Medical Consumption
gen totcons= hhexp-xmedical
gen pce = totcons / hhsize

* 2. Food 
** Food (bought)
gen foodcon = mfood - maltb
gen pcfoodcon = foodcon / hhsize

** Food (all)
gen foodall = xfood
gen pcfoodall = foodall / hhsize

** Nonfood (all)
gen nfoodall = xnonfood - xmedical
gen pcnfoodall = nfoodall / hhsize

* 3. Non-Food Essentials (Bought)
gen nfoodess = xutility + xpersonal + xhhgood + xtransp + mcloth + xhouse + xeduc + xtax
gen pcnfoodess = nfoodess / hhsize

* 4. Discretionary
gen discre = xdomest + xrecreat + xlottery + xcerem + mother // Arisan not included in 
gen pcdiscre = discre / hhsize 

* 5. Harmful
gen badcon = maltb 
gen pcbadcon = badcon / hhsize

* 6. Transfers received
gen intrans = ifood + inonfood + icloth + ifurn + icerem + iother
gen pcintrans = intrans / hhsize

* 7. Medical
* medical == xmedical
gen pcmedical= xmedical/hhsize

local allcons "totcons foodcon foodall nfoodall nfoodess discre badcon intrans xmedical" 
local allpccons "pce pcfoodcon pcfoodall pcnfoodall pcnfoodess pcdiscre pcbadcon pcintrans pcmedical"

foreach var in `allcons' `allpccons' {
	gen l`var' = log(`var' + 1) // adding 1 rupiah for zero consumptions
}

local logcons "lpce lpcfoodcon lpcfoodall lpcnfoodall lpcnfoodess lpcdiscre lpcbadcon lpcintrans lpcmedical"

keep hhid14 commid14 kabid kecid provid hhsize `allcons' `allpccons' `logcons'

save "`WORKING_CONS'/consumption14.dta", replace

log close

/* Deprecated
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
**/