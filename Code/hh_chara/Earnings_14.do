clear
capture log close
set more off
log using "`LOG'/earningpc 14", text replace
use "`RAW_CHARA5'/b3a_tk2.dta", replace

gen mainearning=tk25a1 if tk24a==4 | tk24a==5 | tk24a==7 | tk24a==8
replace mainearning=tk26a1 if tk24a==1 | tk24a==2 | tk24a==3

gen sideearning=tk25b1 if tk24b==4 | tk24b==5 | tk24b==7 | tk24b==8
replace sideearning=tk26b1 if tk24a==1 | tk24a==2 | tk24a==3

drop if mainearning==. & sideearning==.
replace mainearning=0 if mainearning==.
replace sideearning=0 if sideearning==.

xtile sideearn100=sideearning, nq(100)
xtile mainearn100=sideearning, nq(100)

mmerge hhid14 using "`WORKING_CONS'/pcewohhsize14.dta"

egen mainearncom=mean(mainearning), by (commid14)
egen sideearncom=mean(sideearning), by (commid14)

replace mainearning=mainearncom if mainearn100==100
replace mainearning=mainearncom if mainearn100==1
replace sideearning=sideearncom if sideearn100==100

gen totearning=mainearning+sideearning

collapse (sum) mainearning sideearning totearning, by (hhid14)

mmerge hhid14 using "`WORKING_CHARA'/hhsize14.dta"
keep if _merge==3
gen earningpc=totearning/hhsize
gen mainearningpc=mainearning/hhsize
gen sideearningpc=sideearning/hhsize

gen learningpc=log(earningpc+1)
gen lmainearnpc=log(mainearningpc+1)

keep hhid14 mainearning sideearning totearning hhsize mainearningpc earningpc sideearningpc learningpc lmainearn

save "`WORKING_CHARA'/earningspercapita14.dta", replace
log close
