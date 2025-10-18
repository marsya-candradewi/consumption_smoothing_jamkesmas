log using "`LOG'/append 07-14", text replace

//*APPEND 2007 & 2014*//
clear

use "`WORKING_MER'/hhmerge_07.dta"
append using "`WORKING_MER'/hhmerge_14.dta"
order hhid07 t

/* For old version using xtreg, fe
egen hhid1=group(hhid)
sort hhid1 t
xtset hhid1 t
*/

/* Generating Interaction Variables*/
gen headADLjamkesmas=headADL*hjamkesmas
gen headIADLjamkesmas=headIADL*hjamkesmas
gen headgenjamkesmas=headgeneral*hjamkesmas

/*
gen headADL1jamkesmas=headADL1*hjamkesmas
gen headIADL1jamkesmas=headIADL1*hjamkesmas
gen headgen1jamkesmas=headgeneral1*hjamkesmas

gen headADL2jamkesmas=headADL2*hjamkesmas
gen headIADL2jamkesmas=headIADL2*hjamkesmas
gen headgen2jamkesmas=headgeneral2*hjamkesmas
*/

gen spouseADLjamkesmas=spouseADL*sjamkesmas
gen spouseIADLjamkesmas=spouseIADL*sjamkesmas
gen spousegenjamkesmas=spousegeneral*sjamkesmas

/*
gen spouseADL1jamkesmas=spouseADL1*sjamkesmas
gen spouseIADL1jamkesmas=spouseIADL1*sjamkesmas
gen spousegen1jamkesmas=spousegeneral1*sjamkesmas

gen spouseADL2jamkesmas=spouseADL2*sjamkesmas
gen spouseIADL2jamkesmas=spouseIADL2*sjamkesmas
gen spousegen2jamkesmas=spousegeneral2*sjamkesmas
*/
gen dhjamkesmas=dh*hjamkesmas
gen dsjamkesmas=ds*hjamkesmas

gen hchronicjamkesmas=headchronic*hjamkesmas
gen schronicjamkesmas=spousechronic*sjamkesmas

save "`WORKING_MER'/final0714", replace

/* Find out where bottom 40% is made 
**********************************************************
*bottom40*
**********************************************************
clear
use "`WORKING_MER'/hhmerge_07.dta"
keep if bottom40==1
append using "`WORKING_MER'/hhmerge_14.dta"

duplicates tag hhid, gen(pairhh)

sort hhid t

keep if pairhh==1
drop pairhh bottom40

egen hhid1=group(hhid)

xtset hhid1 t
/* Generating Interaction Variables*/
gen headADLjamkesmas=headADL*hjamkesmas
gen headIADLjamkesmas=headIADL*hjamkesmas
gen headgenjamkesmas=headgeneral*hjamkesmas

/*
gen headADL1jamkesmas=headADL1*hjamkesmas
gen headIADL1jamkesmas=headIADL1*hjamkesmas
gen headgen1jamkesmas=headgeneral1*hjamkesmas

gen headADL2jamkesmas=headADL2*hjamkesmas
gen headIADL2jamkesmas=headIADL2*hjamkesmas
gen headgen2jamkesmas=headgeneral2*hjamkesmas
*/

gen spouseADLjamkesmas=spouseADL*sjamkesmas
gen spouseIADLjamkesmas=spouseIADL*sjamkesmas
gen spousegenjamkesmas=spousegeneral*sjamkesmas

/*
gen spouseADL1jamkesmas=spouseADL1*sjamkesmas
gen spouseIADL1jamkesmas=spouseIADL1*sjamkesmas
gen spousegen1jamkesmas=spousegeneral1*sjamkesmas

gen spouseADL2jamkesmas=spouseADL2*sjamkesmas
gen spouseIADL2jamkesmas=spouseIADL2*sjamkesmas
gen spousegen2jamkesmas=spousegeneral2*sjamkesmas
*/

gen dhjamkesmas=dh*hjamkesmas
gen dsjamkesmas=ds*hjamkesmas

gen hchronicjamkesmas=headchronic*hjamkesmas
gen schronicjamkesmas=spousechronic*sjamkesmas

save "`WORKING_MER'/final0714_bottom40", replace

***********************************************************
*excl bottom 40*
***********************************************************
clear
use "`WORKING_MER'/hhmerge_07.dta"
keep if bottom40==0
append using "`WORKING_MER'/hhmerge_14.dta"
duplicates tag hhid, gen(pairhh)

sort hhid t

keep if pairhh==1
drop pairhh bottom40

egen hhid1=group(hhid)

xtset hhid1 t

/* Generating Interaction Variables*/
gen headADLjamkesmas=headADL*hjamkesmas
gen headIADLjamkesmas=headIADL*hjamkesmas
gen headgenjamkesmas=headgeneral*hjamkesmas

/*
gen headADL1jamkesmas=headADL1*hjamkesmas
gen headIADL1jamkesmas=headIADL1*hjamkesmas
gen headgen1jamkesmas=headgeneral1*hjamkesmas

gen headADL2jamkesmas=headADL2*hjamkesmas
gen headIADL2jamkesmas=headIADL2*hjamkesmas
gen headgen2jamkesmas=headgeneral2*hjamkesmas
*/
gen spouseADLjamkesmas=spouseADL*sjamkesmas
gen spouseIADLjamkesmas=spouseIADL*sjamkesmas
gen spousegenjamkesmas=spousegeneral*sjamkesmas

/*
gen spouseADL1jamkesmas=spouseADL1*sjamkesmas
gen spouseIADL1jamkesmas=spouseIADL1*sjamkesmas
gen spousegen1jamkesmas=spousegeneral1*sjamkesmas

gen spouseADL2jamkesmas=spouseADL2*sjamkesmas
gen spouseIADL2jamkesmas=spouseIADL2*sjamkesmas
gen spousegen2jamkesmas=spousegeneral2*sjamkesmas
*/
gen dhjamkesmas=dh*hjamkesmas
gen dsjamkesmas=ds*hjamkesmas

gen hchronicjamkesmas=headchronic*hjamkesmas
gen schronicjamkesmas=spousechronic*sjamkesmas

save "`WORKING'/final0714_excbottom40", replace

log close
