log using "`LOG'/Merging_07", text replace

**# 1. Consumption
	use "`WORKING_CONS'/consumption07.dta", clear

**# 2. Health 
	**# ADL
	mmerge hhid07 using "`WORKING_HEALTH'/headADL07.dta"
	mmerge hhid07 using "`WORKING_HEALTH'/spouseADL07.dta"

	**# Days of Sickness
	mmerge hhid07 using "`WORKING_HEALTH'/h07.dta"

	**# Chronic Illness
	mmerge hhid07 using "`WORKING_HEALTH'/headchronic07.dta"
	mmerge hhid07 using "`WORKING_HEALTH'/spousechronic07.dta"


	**# Health Facility Use
	mmerge hhid07 using "`WORKING_HEALTH'/hhealthutil07.dta"
	mmerge hhid07 using "`WORKING_HEALTH'/shealthutil07.dta"

**# 3. Insurance
	mmerge hhid07 using "`WORKING_INS'/heads_formal_ins_07.dta" // OLD : hjamkesmas
	mmerge hhid07 using "`WORKING_INS'/spouses_formal_ins_07.dta" // OLD: sjamkesmas

**# 4. HH Characteristics
	**# Earnings
	mmerge hhid07 using "`WORKING_CHARA'/earningspercapita07.dta"
	
	**# PAP
	mmerge hhid07 using "`WORKING_CHARA'/PAP07.dta"
	
	**# Female Head
	mmerge hhid07 using "`WORKING_CHARA'/fhead07.dta"
	
	**# Head Age
	mmerge hhid07 using "`WORKING_CHARA'/headage07.dta"
	
	**# Head Educ
	mmerge hhid07 using "`WORKING_CHARA'/headeduc07.dta"
	
	**# HH Members
	mmerge hhid07 using "`WORKING_CHARA'/shareprodage07.dta"
	mmerge hhid07 using "`WORKING_CHARA'/sharechild07.dta"
	mmerge hhid07 using "`WORKING_CHARA'/numberofsenior07.dta"
	
	**# Urban	
	mmerge hhid07 using "`WORKING_CHARA'/urban07_1.dta"

**# 5. Final Year Clean

gen t = 0 // 2007

save "`WORKING_MER'/hhmerge_07.dta", replace


log close