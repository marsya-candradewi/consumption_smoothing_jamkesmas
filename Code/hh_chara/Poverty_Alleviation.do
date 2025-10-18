***************************************************************
* Project: Health Shock, Consumption smoothing, and Jamkesmas
* Cleaning Poverty Alleviation Program
****************************************************************

*************
**# 2007 #**
*************
**# 1. CASH TRANSFER
	use "`RAW_CHARA4'/b1_ksr1.dta", clear

	reshape wide ksr1* ksr2*, i(hhid07) j(ksr3type) string

	gen BLT=1 if ksr17A==1
	replace BLT=0 if ksr17A==3

	gen PKH=1 if ksr17B==1
	replace PKH=0 if ksr17B==3 | ksr17B==6

	keep hhid07 BLT PKH
	save "`WORKING_CHARA'/CT07.dta", replace

**# 2. RASKIN
	use "`RAW_CHARA4'/b1_ksr2.dta", clear

	keep ksr24 ksr25 ksr4type hhid07
	reshape wide ksr24 ksr25, i(hhid07) j(ksr4type) string

	gen raskin=1 if ksr24A==1
	replace raskin=0 if ksr24A==3 | ksr24A==6

	keep hhid07 raskin
	save "`WORKING_CHARA'/raskin07.dta", replace

**# 3. All PAP 2007
	use "`WORKING_CHARA'/CT07.dta", clear
	mmerge hhid07 using "`WORKING_CHARA'/raskin07.dta"

	gen byte PAP=(BLT==1|PKH==1|raskin==1)
	save "`WORKING_CHARA'/PAP07.dta", replace

pause 

************
**# 2014 #**
************

**# 1. CASH TRANSFER
	use "`RAW_CHARA5'/b1_ksr1.dta", clear

	reshape wide ksr1* ksr2*, i(hhid14) j(ksr3type) string

	gen BLT=1 if ksr17A==1
	replace BLT=0 if ksr17A==3

	gen PKH=1 if ksr17B==1
	replace PKH=0 if ksr17B==3 | ksr17B==6

	gen BLSM=1 if ksr17C==1
	replace BLSM=0 if ksr17C==3

	keep hhid14 BLT PKH BLSM
	save "`WORKING_CHARA'/CT14.dta", replace

**# 2. RASKIN
	use "`RAW_CHARA5'/b1_ksr2.dta", clear

	gen raskin=1 if ksr24a=="A" | ksr24a=="AB" |ksr24a=="B"
	replace raskin=0 if ksr24a=="C" | ksr24a=="W"

	keep hhid14 raskin
	save "`WORKING_CHARA'/raskin14.dta", replace

**# 3. All PAP 2014
	use "`WORKING_CHARA'/CT14.dta", clear
	mmerge hhid14 using "`WORKING_CHARA'/raskin14.dta"

	gen byte PAP=(BLT==1|PKH==1|raskin==1|BLSM==1)
	save "`WORKING_CHARA'/PAP14.dta", replace

******************
**# APPEND PAP #**
******************
use "`WORKING_CHARA'/PAP07.dta", clear
append using "`WORKING_CHARA'/PAP14.dta"

*** Marsya figure out why we're doing this