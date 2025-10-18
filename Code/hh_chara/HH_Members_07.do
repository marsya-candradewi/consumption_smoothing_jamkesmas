log using "`LOG'/Household_members_07", text replace

clear
set more off
use "`RAW_ID4'/bk_ar1.dta", clear
mmerge hhid07 pid07 pidlink using "`RAW_HEALTH4'/bus1_1.dta"

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

drop if us03>900 | us02yr>9000 

preserve
	** 1. Adult (Productive Age 15 - 65)
	gen prodage=1 if us03>=15 & us03<65
	gen adultmen=(prodage==1&ar07==1)
	gen adultwom=(prodage==1&ar07==3)

	collapse (sum) adultmen adultwom prodage, by (hhid07)

	mmerge hhid07 using "`RAW_ID4'/bk_ar0.dta"

	keep if _merge==3
	gen shareprodage=prodage/hhsize
	keep hhid07 adultmen adultwom prodage hhsize shareprodage

	save "`WORKING_CHARA'/shareprodage07.dta", replace
restore

preserve
	** 2. Children
	gen child=1 if us03<15
	replace child=0 if child==.

	collapse (sum) child, by (hhid07)

	mmerge hhid07 using "`RAW_ID4'/bk_ar0.dta"
	keep if _merge==3

	gen sharechild=child/hhsize
	keep hhid07 child hhsize sharechild

	save "`WORKING_CHARA'/sharechild07.dta", replace
restore

preserve
	** 3. Senior
	gen seniormen=(us03>64&ar07==1)
	gen seniorwom=(us03>64&ar07==3)

	collapse (sum) senior*, by (hhid07)

	save "`WORKING_CHARA'/numberofsenior07.dta", replace
restore

log close
