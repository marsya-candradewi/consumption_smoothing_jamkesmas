log using "`LOG'/Household_members_14", text replace

clear
set more off
use "`RAW_ID5'/bk_ar1.dta", clear

mmerge hhid14 pid14 pidlink using "`RAW_HEALTH5'/bus_cov.dta"

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

drop if us03>900 | us02yr>9000 

preserve
	** 1. Adult (Productive Age 15 - 65)
	gen prodage=1 if us03>=15 & us03<65
	gen adultmen=(prodage==1&ar07==1)
	gen adultwom=(prodage==1&ar07==3)

	collapse (sum) adult* prodage, by (hhid14)

	mmerge hhid14 using "`WORKING_CHARA'/hhsize14.dta"

	keep if _merge==3
	gen shareprodage=prodage/hhsize
	keep hhid14 adult* prodage hhsize shareprodage

	save "`WORKING_CHARA'/shareprodage14.dta", replace
restore

preserve
	** 2. Children
	gen child=1 if us03<15
	replace child=0 if child==.

	collapse (sum) child, by (hhid14)

	mmerge hhid14 using "`WORKING_CHARA'/hhsize14.dta"

	keep if _merge==3
	gen sharechild=child/hhsize
	drop if sharechild>1
	keep hhid14 child hhsize sharechild

	save "`WORKING_CHARA'/sharechild14.dta", replace
restore

preserve
	** 3. Senior
	gen seniormen=(us03>64&ar07==1)
	gen seniorwom=(us03>64&ar07==3)

	collapse (sum) senior*, by (hhid14)
	save "`WORKING_CHARA'/numberofsenior14.dta", replace
restore

log close
