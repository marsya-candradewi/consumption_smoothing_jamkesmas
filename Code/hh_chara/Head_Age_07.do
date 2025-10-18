/*Household Head's Age*/
log using "`LOG'/Head's Age 07", text replace

*Generating Head*
clear
set more off
use "`RAW_ID4'/bk_ar1.dta", replace

mmerge hhid07 pid07 pidlink using "`RAW_HEALTH4'/bus1_1.dta"
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

*Generating Head of Household*
gen head=1 if ar02b==1
replace head=0 if head==.

*Generating Age and Squared Age*
drop if us03>900 | us02yr>9000
gen age=us03
gen agesq=age^2

gen headage=head*age if head==1
gen headagesq=head*agesq if head==1

drop if head~=1
drop if headage<15

duplicates tag hhid07, gen(pairhh)
drop if pairhh==1

keep hhid07 headage headagesq
save "`WORKING_CHARA'/headage07.dta", replace
log close






