log using "`LOG'/earningpc 07", text replace
clear
set more off
use "`RAW_CHARA4'/b3a_tk2.dta"

gen mainearning=tk25a1 if tk24a==4 | tk24a==5 | tk24a==7 | tk24a==8
replace mainearning=tk26a1 if tk24a==1 | tk24a==2 | tk24a==3

gen sideearning=tk25b1 if tk24b==4 | tk24b==5 | tk24b==7 | tk24b==8
replace sideearning=tk26b1 if tk24a==1 | tk24a==2 | tk24a==3

drop if mainearning==. & sideearning==.
replace mainearning=0 if mainearning==.
replace sideearning=0 if sideearning==.

xtile sideearn100=sideearning, nq(100)
xtile mainearn100=sideearning, nq(100)

mmerge hhid07 using "`RAW_CONS'/pce07nom.dta"

egen mainearncom=mean(mainearning), by (commid07)
egen sideearncom=mean(sideearning), by (commid07)

replace mainearning=mainearncom if mainearn100==100
replace mainearning=mainearncom if mainearn100==1
replace sideearning=sideearncom if sideearn100==100

gen totearning=mainearning+sideearning

collapse (sum) mainearning sideearning totearning, by (hhid07)

**# ADJUST WITH INDONESIA YEARLY INFLATION FROM BPS
** 2008 - 2013 from BPS 11.06	2.78	6.96	3.79	4.30	8.38	
local allearn "mainearning sideearning totearning" 

foreach var in `allcons' `allpccons' {
	replace `var' = `var' * 1.111 * 1.0278 * 1.07 * 1.038 * 1.043 * 1.084
}


mmerge hhid07 using "`RAW_ID4'/bk_ar0.dta"
keep if _merge==3
gen earningpc=totearning/hhsize
gen mainearningpc=mainearning/hhsize
gen sideearningpc=sideearning/hhsize

gen learningpc=log(earningpc+1)
gen lmainearnpc=log(mainearningpc+1)

keep hhid07 mainearning sideearning totearning hhsize mainearningpc earningpc sideearningpc learningpc lmainearn

save "`WORKING_CHARA'/earningspercapita07.dta", replace
log close
