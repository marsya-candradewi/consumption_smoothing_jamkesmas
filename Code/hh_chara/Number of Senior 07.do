clear
set more off
use "C:\Users\Marjoso\Documents\IFLS\IFLS 4 HH\bk_ar1.dta", clear
mmerge hhid07 pid07 pidlink using "C:\Users\Marjoso\Documents\IFLS\IFLS 4 HH\bus1_1.dta"

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

drop if us03>900 | us02yr>9000 
gen seniormen=(us03>64&ar07==1)
gen seniorwom=(us03>64&ar07==3)

collapse (sum) senior*, by (hhid07)

save "C:\Users\Marjoso\Documents\Skripsi\data files\numberofsenior07.dta", replace
