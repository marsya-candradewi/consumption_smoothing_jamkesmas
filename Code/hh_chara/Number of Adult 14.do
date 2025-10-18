log using "C:\Users\Marjoso\Documents\Skripsi\log file\Share working 14", text replace
clear
set more off
use "C:\Users\Marjoso\Documents\IFLS\IFLS 5 HH\bk_ar1.dta", clear
mmerge hhid14 pid14 pidlink using "C:\Users\Marjoso\Documents\IFLS\IFLS 5 HH\bus_cov.dta"

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

drop if us03>900 | us02yr>9000 
gen prodage=1 if us03>=15 & us03<65
gen adultmen=(prodage==1&ar07==1)
gen adultwom=(prodage==1&ar07==3)

collapse (sum) adult* prodage, by (hhid14)

mmerge hhid14 using "C:\Users\Marjoso\Documents\Skripsi\data files\hhsize14.dta"

keep if _merge==3
gen shareprodage=prodage/hhsize
keep hhid14 adult* prodage hhsize shareprodage

save "C:\Users\Marjoso\Documents\Skripsi\data files\shareprodage14.dta", replace
log close
