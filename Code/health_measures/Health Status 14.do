/****************************************************************
* Project: Health shocks, consumption smoothing, Jamkesmas
* Purpose: Health Status of HH Head and Spouse in 2007
** Marsya Edit October 2025: Removing irrelevant ADL1 and ADL2 
***************************************************************/
log using "`LOG'/HH_head_spouse_healthstat_14", text replace


***********************************
**# GENERATE HH HEAD AND SPOUSE 
***********************************
clear
set more off
use "`RAW_ID5'/bk_ar1.dta", replace
drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
replace head=0 if head==.

gen spouse=1 if ar02b==2
replace spouse=0 if spouse==.

keep hhid14 pid14 pidlink head spouse

tempfile headspouse
save `headspouse', replace

***************
**# 1. ADL #**
***************
mmerge hhid14 pid14 pidlink using "`WORKING_HEALTH'/ADL14.dta"

drop if ADL==. | IADL==. | generalADL==. // |  ADL1==. | IADL1==. | generalADL1==. | ADL2==. | IADL2==. | generalADL2==.

preserve
	*******************
	**# HEAD ADL #**
	*******************
	*household head*
	gen headADL=head*ADL
	gen headIADL=head*IADL
	gen headgeneral=head*generalADL
	
	/*
	gen headADL1=head*ADL1
	gen headIADL1=head*IADL1
	gen headgeneral1=head*generalADL1

	gen headADL2=head*ADL2
	gen headIADL2=head*IADL2
	gen headgeneral2=head*generalADL2
	*/
	
	gen headberpakaian=head*ADLberpakaian
	gen headmandi=head*ADLmandi
	gen headbangun=head*ADLbangun

	gen headbelanja=head*ADLbelanja
	gen headmenyiapkanmakan=head*ADLmenyiapkanmakan
	gen headminumobat=head*ADLminumobat

	replace headADL=0 if head==0
	replace headIADL=0 if head==0
	replace headgeneral=0 if head==0

	replace headberpakaian=0 if head==0
	replace headmandi=0 if head==0
	replace headbangun=0 if head==0

	replace headbelanja=0 if head==0
	replace headmenyiapkanmakan=0 if head==0
	replace headminumobat=0 if head==0

	keep if head==1
	duplicates tag hhid14, gen(pairhh)
	drop if pairhh~=0
	keep hhid14 head*
	drop head

	save "`WORKING_HEALTH'/headADL14.dta", replace
restore

	*******************
	**# SPOUSE ADL #**
	*******************
	*head's spouse*
	gen spouseADL=spouse*ADL
	gen spouseIADL=spouse*IADL
	gen spousegeneral=spouse*generalADL
	
	/*
	gen spouseADL1=spouse*ADL1
	gen spouseIADL1=spouse*IADL1
	gen spousegeneral1=spouse*generalADL1

	gen spouseADL2=spouse*ADL2
	gen spouseIADL2=spouse*IADL2
	gen spousegeneral2=spouse*generalADL2
	*/
	
	gen spouseberpakaian=spouse*ADLberpakaian
	gen spousemandi=spouse*ADLmandi
	gen spousebangun=spouse*ADLbangun

	gen spousebelanja=spouse*ADLbelanja
	gen spousemenyiapkanmakan=spouse*ADLmenyiapkanmakan
	gen spouseminumobat=spouse*ADLminumobat

	replace spouseADL=0 if spouse==0
	replace spouseIADL=0 if spouse==0
	replace spousegeneral=0 if spouse==0

	replace spouseberpakaian=0 if spouse==0
	replace spousemandi=0 if head==0
	replace spousebangun=0 if spouse==0

	replace spousebelanja=0 if spouse==0
	replace spousemenyiapkanmakan=0 if spouse==0
	replace spouseminumobat=0 if spouse==0

	keep if spouse==1
	duplicates tag hhid14, gen(pairhh)
	drop if pairhh~=0
	keep hhid14 spouse*
	drop spouse

	save "`WORKING_HEALTH'/spouseADL14.dta", replace

********************
**# 2. DAYS SICK #**
********************
use "`headspouse'", clear
mmerge hhid14 pid14 pidlink using "`WORKING_HEALTH'/dayssick14.dta"
drop if dayssick==.

preserve
	**********************
	**# HEAD DAYS SICK #**
	**********************
	*household head*
	gen dh=head*dayssick
	keep if head==1
	duplicates tag hhid14, gen (pairhh)
	drop if pairhh~=0

	replace dh=dh*100/28
	keep hhid14 dh
	save "`WORKING_HEALTH'/dh14.dta", replace
restore

	**********************
	**# SPOUSE DAYS SICK #**
	**********************
	*head's spouse*
	gen ds=spouse*dayssick
	keep if spouse==1

	duplicates tag hhid14, gen(pairhh)
	drop if pairhh~=0

	replace ds=ds*100/28

	keep hhid14 ds

	save "`WORKING_HEALTH'/ds14.dta", replace

**********************
**# TOTAL DAYS SICK #**
**********************
*h equation*
clear
set more off
use "`WORKING_HEALTH'/dh14.dta", replace
mmerge hhid14 using "`WORKING_HEALTH'/ds14.dta"

gen h=dh+ds

save "`WORKING_HEALTH'/h14.dta", replace

****************
**# 3. CHRONIC #**
****************
use "`headspouse'", clear
mmerge hhid14 pid14 pidlink using "`WORKING_HEALTH'/chronic14.dta"
drop if chronic==.

preserve
	**********************
	**# HEAD CHRONIC ILL #**
	**********************
	*household head*
	gen headchronic=head*chronic
	keep if head==1
	duplicates tag hhid14, gen(pairhh)
	drop if pairhh~=0

	keep hhid14 headchronic
	save "`WORKING_HEALTH'/headchronic14.dta", replace
restore

	**********************
	**# SPOUSE CHRONIC ILL #**
	**********************

	*household head*
	gen spousechronic=spouse*chronic
	keep if spouse==1
	duplicates tag hhid14, gen (pairhh)
	drop if pairhh~=0

	keep hhid14 spousechronic
	save "`WORKING_HEALTH'/spousechronic14.dta", replace

log close
/* Deprecated
mmerge hhid14 pid14 pidlink using "C:\Users\Marjoso\Documents\Skripsi\data files\ADL14_1.dta"
mmerge hhid14 pid14 pidlink using "C:\Users\Marjoso\Documents\Skripsi\data files\ADL14_2.dta"
