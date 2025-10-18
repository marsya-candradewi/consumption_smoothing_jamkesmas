/* Generating HH Size */
clear
use hhid14 ar00 ar01a if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11 using "`RAW_ID5'/bk_ar1", clear  
bys hhid14 ar00: keep if _n==_N 
bys hhid14: gen hhsize=_N  
bys hhid14: keep if _n==_N 
lab var hhsize "Household size"  
sort hhid14  
keep hhid14 hhsize

save "`WORKING_CHARA'/hhsize14.dta", replace
