log using "C:\Users\Marjoso\Documents\Skripsi\log file\Share Child 14", text replace
clear
use "C:\Users\Marjoso\Documents\IFLS\IFLS 5 HH\bk_ar1.dta", clear
set more off
mmerge hhid14 pid14 pidlink using "C:\Users\Marjoso\Documents\IFLS\IFLS 5 HH\bus_cov.dta"

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

drop if us03>900 | us02yr>9000
gen child=1 if us03<15
replace child=0 if child==.

collapse (sum) child, by (hhid14)

mmerge hhid14 using "C:\Users\Marjoso\Documents\Skripsi\data files\hhsize14.dta"

keep if _merge==3
gen sharechild=child/hhsize
drop if sharechild>1
keep hhid14 child hhsize sharechild

save "C:\Users\Marjoso\Documents\Skripsi\data files\sharechild14.dta", replace
log close
