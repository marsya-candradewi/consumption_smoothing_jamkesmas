log using "`LOG'/urbansc 07", text replace
clear
set more off
use "`RAW_ID4'/bk_sc.dta", clear

gen urbansc=1 if sc05==1
replace urbansc=0 if sc05==2

label var urbansc "=1 if household lives in urban community"
keep hhid07 urbansc
ren urbansc urban
save "`WORKING_CHARA'/urban07_1.dta", replace
log close
