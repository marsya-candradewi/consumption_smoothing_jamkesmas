log using "`LOG'/urbansc 14", text replace
clear
set more off
use "`RAW_ID5'/bk_sc1.dta", clear

gen urban=1 if sc05==1
replace urban=0 if sc05==2

label var urban "=1 if household lives in urban community"
keep hhid14 urban
save "`WORKING_CHARA'/urban14_1.dta", replace
log close
