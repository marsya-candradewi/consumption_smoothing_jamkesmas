/*Female Head*/
log using "`LOG'/Female Head 14", text replace

*Generating Head*
clear
set more off
use "`RAW_ID5'/bk_ar1.dta", replace

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
replace head=0 if head==.

*Generating Female Head*
gen fhead=1 if head==1 & ar07==3
keep if head==1

duplicates tag hhid14, gen(pairhh)
drop if pairhh~=0
replace fhead=0 if fhead==. & ar07==1

keep hhid14 fhead
save "`WORKING_CHARA'/fhead14.dta", replace
log close
