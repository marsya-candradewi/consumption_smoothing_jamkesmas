/****************************************************************
* Project: Health shocks, consumption smoothing, Jamkesmas
* Purpose: Health Status of HH Head and Spouse in 2007
** Marsya Edit October 2025: Removing irrelevant ADL1 and ADL2 
***************************************************************/
log using "`LOG'/HH_head_spouse_healthstat_07", text replace

***********************************
**# GENERATE HH HEAD AND SPOUSE 
***********************************
clear   
set more off
use "`RAW_ID4'/bk_ar1.dta", clear
drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
replace head=0 if head==.

gen spouse=1 if ar02b==2
replace spouse=0 if spouse==.

keep hhid07 pid07 pidlink head spouse

tempfile headspouse
save `headspouse', replace

***************
**# 1. ADL #**
***************
mmerge hhid07 pid07 pidlink using "`WORKING_HEALTH'/ADL07.dta"

drop if ADL==. | IADL==. | generalADL==. // ADL1==. | IADL1==. | generalADL1==. | ADL2==. | IADL2==. | generalADL2==.

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

	gen headmengangkatair=head*ADLmengangkat
	gen headjalan1=head*ADLjalankaki1
	gen headjalan5=head*ADLjalankaki5
	gen headmenyapu=head*ADLmenyapu
	gen headmembungkuk=head*ADLmembungkuk

	gen headberpakaian=head*ADLberpakaian
	gen headbuangair=head*ADLbuang
	gen headmandi=head*ADLmandi
	gen headbangun=head*ADLbangun
	gen headjalan=head*ADLberjalan
	gen headdirilantai=head*ADLberdirilantai
	gen headdirikursi=head*ADLberdirikursi

	gen headbelanja=head*ADLbelanja
	gen headmenyiapkanmakan=head*ADLmenyiapkanmakan
	gen headminumobat=head*ADLminumobat
	gen headberpergiandalamkota=head*ADLberpergiandalamkota
	gen headberpergianluarkota=head*ADLberpergianluarkota

	replace headADL=0 if head==0
	replace headIADL=0 if head==0
	replace headgeneral=0 if head==0

	replace headmengangkatair=0 if head==0
	replace headjalan1=0 if head==0
	replace headjalan5=0 if head==0
	replace headmenyapu=0 if head==0
	replace headmembungkuk=0 if head==0

	replace headberpakaian=0 if head==0
	replace headbuangair=0 if head==0
	replace headmandi=0 if head==0
	replace headbangun=0 if head==0
	replace headjalan=0 if head==0
	replace headdirilantai=0 if head==0
	replace headdirikursi=0 if head==0

	replace headbelanja=0 if head==0
	replace headmenyiapkanmakan=0 if head==0
	replace headminumobat=0 if head==0
	replace headberpergiandalamkota=0 if head==0
	replace headberpergianluarkota=0 if head==0

	keep if head==1
	duplicates tag hhid07, gen(pairhh)
	drop if pairhh~=0
	keep hhid07 head*
	drop head
	save "`WORKING_HEALTH'/headADL07.dta", replace

restore

*********************
**# SPOUSE ADL #**
*********************
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

	gen spousemengangkatair=spouse*ADLmengangkat
	gen spousejalan1=spouse*ADLjalankaki1
	gen spousejalan5=spouse*ADLjalankaki5
	gen spousemenyapu=spouse*ADLmenyapu
	gen spousemembungkuk=spouse*ADLmembungkuk

	gen spouseberpakaian=spouse*ADLberpakaian
	gen spousebuangair=spouse*ADLbuang
	gen spousemandi=spouse*ADLmandi
	gen spousebangun=spouse*ADLbangun
	gen spousejalan=spouse*ADLberjalan
	gen spousedirilantai=spouse*ADLberdirilantai
	gen spousedirikursi=spouse*ADLberdirikursi

	gen spousebelanja=spouse*ADLbelanja
	gen spousemenyiapkanmakan=spouse*ADLmenyiapkanmakan
	gen spouseminumobat=spouse*ADLminumobat
	gen spouseberpergiandalamkota=spouse*ADLberpergiandalamkota
	gen spouseberpergianluarkota=spouse*ADLberpergianluarkota

	replace spouseADL=0 if spouse==0
	replace spouseIADL=0 if spouse==0
	replace spousegeneral=0 if spouse==0

	replace spousemengangkatair=0 if spouse==0
	replace spousejalan1=0 if spouse==0
	replace spousejalan5=0 if spouse==0
	replace spousemenyapu=0 if spouse==0
	replace spousemembungkuk=0 if spouse==0

	replace spouseberpakaian=0 if spouse==0
	replace spousebuangair=0 if spouse==0
	replace spousemandi=0 if head==0
	replace spousebangun=0 if spouse==0
	replace spousejalan=0 if spouse==0
	replace spousedirilantai=0 if spouse==0
	replace spousedirikursi=0 if spouse==0

	replace spousebelanja=0 if spouse==0
	replace spousemenyiapkanmakan=0 if spouse==0
	replace spouseminumobat=0 if spouse==0
	replace spouseberpergiandalamkota=0 if spouse==0
	replace spouseberpergianluarkota=0 if spouse==0

	keep if spouse==1
	duplicates tag hhid07, gen(pairhh)
	drop if pairhh~=0

	keep hhid07 spouse*
	drop spouse

	save "`WORKING_HEALTH'/spouseADL07.dta", replace

********************
**# 2. DAYS SICK #**
********************
use "`headspouse'", clear
mmerge hhid07 pid07 pidlink using "`WORKING_HEALTH'/dayssick07.dta"
drop if dayssick==.

preserve
	**********************
	**# HEAD DAYS SICK #**
	**********************
	*household head*
	gen dh=head*dayssick

	keep if head==1
	duplicates tag hhid07, gen (pairhh)
	drop if pairhh~=0

	gen dh_rate=dh*100/28
	keep hhid07 dh*
	save "`WORKING_HEALTH'/dh07.dta", replace
restore

preserve
	************************
	**# SPOUSE DAYS SICK #**
	************************
	*head's spouse*
	gen ds=spouse*dayssick
	keep if spouse==1

	duplicates tag hhid07, gen(pairhh)
	drop if pairhh~=0

	replace ds=ds*100/28

	keep hhid07 ds
	save "`WORKING_HEALTH'/ds07.dta", replace
restore

**********************
**# TOTAL DAYS SICK #**
**********************
clear
set more off
use "`WORKING_HEALTH'/dh07.dta", replace
mmerge hhid07 using "`WORKING_HEALTH'/ds07.dta"

gen h=dh+ds

save "`WORKING_HEALTH'/h07.dta", replace

****************
**# 3. CHRONIC #**
****************
use "`headspouse'", clear
mmerge hhid07 pid07 pidlink using "`WORKING_HEALTH'/chronic07.dta"
drop if chronic==.

preserve
	**********************
	**# HEAD CHRONIC #**
	**********************

	*household head*
	gen headchronic=head*chronic
	keep if head==1
	duplicates tag hhid07, gen(pairhh)
	drop if pairhh~=0

	keep hhid07 headchronic
	save "`WORKING_HEALTH'/headchronic07.dta", replace
restore

	**********************
	**# HEAD CHRONIC #**
	**********************

	*hh head's spouse*
	gen spousechronic=spouse*chronic
	keep if spouse==1
	duplicates tag hhid07, gen (pairhh)
	drop if pairhh~=0

	keep hhid07 spousechronic
	save "`WORKING_HEALTH'/spousechronic07.dta", replace

log close

/* deprecated
mmerge hhid07 pid07 pidlink using "C:\Users\Marjoso\Documents\Skripsi\data files\ADL07_1.dta"  
mmerge hhid07 pid07 pidlink using "C:\Users\Marjoso\Documents\Skripsi\data files\ADL07_2.dta"
*/