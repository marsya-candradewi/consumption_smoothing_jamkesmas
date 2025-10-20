log using "`LOG'/dayssick07", text replace

clear
set more off
use "`RAW_HEALTH4'/b3b_kk1.dta", clear

ren kk02a dayssick
ren kk02b daysbed

drop if dayssick>28 | dayssick==. | daysbed>28 | daysbed==.

keep hhid07 pid07 pidlink dayssick daysbed 

save "`WORKING_HEALTH'/dayssick07.dta", replace
log close
