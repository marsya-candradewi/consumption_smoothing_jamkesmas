log using "`LOG'/Consumption 07", text replace

/*Consumption 2007*/
clear
set more off
use "`RAW_CONS'/pce07nom.dta", clear

* 1. Generate Total Non Medical Consumption
gen totcons= hhexp-xmedical
drop pce
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

**# ADJUST WITH INDONESIA YEARLY INFLATION FROM BPS to be 2014 IDR
** 2008 - 2013 from BPS 11.06	2.78	6.96	3.79	4.30	8.38	
local allcons "totcons foodcon foodall nfoodall nfoodess discre badcon intrans xmedical" 
local allpccons "pce pcfoodcon pcfoodall pcnfoodall pcnfoodess pcdiscre pcbadcon pcintrans pcmedical"

foreach var in `allcons' `allpccons' {
	replace `var' = `var' * 1.111 * 1.0278 * 1.07 * 1.038 * 1.043 * 1.084
	gen l`var' = log(`var' + 1) // adding 1 rupiah for zero consumptions
}

local logcons "lpce lpcfoodcon lpcfoodall lpcnfoodall lpcnfoodess lpcdiscre lpcbadcon lpcintrans lpcmedical"

keep hhid07 commid07 kabid kecid provid hhsize `allcons' `allpccons' `logcons'

save "`WORKING_CONS'/consumption07.dta", replace

log close

/* Deprecated
/* CHECK BREAKDOWN EQUALS ACTUAL EXP
gen totcons2 = foodcon + nfoodess + discre + badcon + intrans + xmedical
assert totcons2 == hhexp
gen diff = totcons2 - hhexp
*/

// gen nonfoodcon=xnonfood-xmedical
// gen pcnonfoodcon=nonfoodcon/hhsize

**# INVESTMENT EXPENDITURE
gen invexp=xhouse+xeducall
gen pcinvexp=invexp/hhsize

gen ltotcons=log(totcons)
gen ltotfood=log(foodcon)
gen ltotnonfood=log(nonfood)
gen ltotbad=log(badcon)
gen ltotinv=log(invexp)
gen ltotmed=log(xmedical)

gen lpce=log(pce)
gen lfood=log(pcfoodcon)
gen ln=log(pcnonfood)
gen lbad=log(pcbadcon+1)
gen linv=log(pcinvexp)
gen lmedical=log(pcmedicalexp+1)

gen lhhsize=log(hhsize)

keep hhid07 commid07 kabid kecid provid hhsize lhhsize totcons pce foodcon pcfoodcon badcon pcbadcon nonfoodcon pcnonfoodcon invexp pcinvexp xmedical pcmedicalexp ltot* lpce lfood lbad lnonfood linv lmedical

*/
