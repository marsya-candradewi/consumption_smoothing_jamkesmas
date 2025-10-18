log using "`LOG'/Merging_14", text replace

use "`RAW_ID5'/htrack", clear

// keep if household is interviewed and not a splitoff 
keep if result14 == 1 & splitoff14 == 0

keep hhid14 commid14 hhid07 commid07
sort hhid14 commid14
tempfile tstrack
save `tstrack', replace

**# 1. Consumption
	use "`WORKING_CONS'/consumption14.dta", clear

**# 2. Health 
	**# ADL
	mmerge hhid14 using "`WORKING_HEALTH'/headADL14.dta"
	mmerge hhid14 using "`WORKING_HEALTH'/spouseADL14.dta"

	**# Days of Sickness
	mmerge hhid14 using "`WORKING_HEALTH'/h14.dta"

	**# Chronic Illness
	mmerge hhid14 using "`WORKING_HEALTH'/headchronic14.dta"
	mmerge hhid14 using "`WORKING_HEALTH'/spousechronic14.dta"


	**# Health Facility Use
	mmerge hhid14 using "`WORKING_HEALTH'/hhealthutil14.dta"
	mmerge hhid14 using "`WORKING_HEALTH'/shealthutil14.dta"
		

**# 3. Insurance
	mmerge hhid14 using "`WORKING_INS'/hjamkesmas14.dta"
	mmerge hhid14 using "`WORKING_INS'/sjamkesmas14.dta"

**# 4. HH Characteristics
	**# Earnings
	mmerge hhid14 using "`WORKING_CHARA'/earningspercapita14.dta"
	
	**# Female Head
	mmerge hhid14 using "`WORKING_CHARA'/fhead14.dta"
	
	**# Head Age
	mmerge hhid14 using "`WORKING_CHARA'/headage14.dta"
	
	**# Head Educ
	mmerge hhid14 using "`WORKING_CHARA'/headeduc14.dta"
	
	**# HH Members
	mmerge hhid14 using "`WORKING_CHARA'/shareprodage14.dta"
	mmerge hhid14 using "`WORKING_CHARA'/sharechild14.dta"
	mmerge hhid14 using "`WORKING_CHARA'/numberofsenior14.dta"
	
	**# Urban	
	mmerge hhid14 using "`WORKING_CHARA'/urban14_1.dta"

**# 5. Final Year Clean
mmerge hhid14 commid14 using "`tstrack'"
keep if _merge == 3
keep if !missing(hhid07) & !missing(commid07) // 214 obs dropped

gen t = 1

pause
save "`WORKING_MER'/hhmerge_14.dta", replace

log close