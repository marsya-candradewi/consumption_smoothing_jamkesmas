log using "`LOG'/dayssick14", text replace
clear
set more off
use "`RAW_HEALTH5'/b3b_kk1.dta", replace

ren kk02a dayssick
ren kk02b daysbed
drop if dayssick>28 | dayssick==. | daysbed>28 | daysbed==.

keep hhid14 pid14 pidlink dayssick daysbed 

save "`WORKING_HEALTH'/dayssick14.dta", replace
log close
