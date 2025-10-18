clear
capture log close
set more off
use "`RAW_HEALTH5'/b3b_rj1.dta" , clear
collapse (sum) rj02, by (hhid14 pidlink)

mmerge hhid14 pidlink using "`RAW_HEALTH5'/b3b_rj0.dta"

drop if rj00==9|rj00==.
replace rj00=0 if rj00==3
ren rj00 outpatient

replace rj02=0 if out==0
ren rj02 numvisit

mmerge hhid14 pidlink using "`RAW_ID5'/bk_ar1.dta"

drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
replace head=0 if head==.

gen spouse=1 if ar02b==2
replace spouse=0 if spouse==.

gen houtpatient=head*outpatient
gen soutpatient=spouse*outpatient

gen hnumvisit=head*numvisit
gen snumvisit=spouse*numvisit

preserve
	*head health facil util*
	keep if head==1 
	duplicates tag hhid14, gen(pairhh)
	drop if pairhh==1
	keep hhid14 houtpatient hnumvisit

save "`WORKING_HEALTH'/hhealthutil14.dta", replace
restore

	*spouse health facil util*
	keep if spouse==1 
	duplicates tag hhid14, gen(pairhh)
	drop if pairhh==1
	keep hhid14 soutpatient snumvisit
	save "`WORKING_HEALTH'/shealthutil14.dta", replace
