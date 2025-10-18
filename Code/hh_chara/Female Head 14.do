/*Female Head*/
log using "C:\Users\Marjoso\Documents\Skripsi\log file\Female Head 14", text replace

*Generating Head*
clear
set more off
use "C:\Users\Marjoso\Documents\IFLS\IFLS 5 HH\bk_ar1.dta", replace

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
save "C:\Users\Marjoso\Documents\Skripsi\data files\fhead14.dta", replace
log close
