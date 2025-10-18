/*Household Head's Age*/
log using "`LOG'/Head_Age_14", text replace

*Generating Head*
clear
set more off
use "`RAW_ID5'/bk_ar1.dta", replace

mmerge hhid14 pid14 pidlink using "`RAW_HEALTH5'/bus_cov.dta"

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

*Generating Household Head*
gen head=1 if ar02b==1
replace head=0 if head==.

*Generating Age and Age Squared*
drop if us03>900| us02yr>9000 
gen age=us03
gen agesq=age^2

gen headage=head*age if head==1
gen headagesq=head*agesq if head==1

drop if head~=1
drop if headage<15

duplicates tag hhid14, gen(pairhh)
drop if pairhh==1

keep hhid14 headage headagesq
save "`WORKING_CHARA'/headage14.dta", replace
log close





