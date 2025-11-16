/***********************************************************
* PROJECT: Health shocks, consumption smoothing, and JAMKESMAS
* AUTHOR: Marsya Candradewi
* LAST EDIT: October 2025
* STATA VERSION: 19.5
************************************************************/

****************************
**# SET UP AND DIRECTORIES 
****************************
clear all
set maxvar 120000
capture log close
set more off
pause off

if c(os) == "Windows" & c(username) == "marsyacandradewi" {
		local DROPBOX_ROOT "C:/Users/`c(username)'/Team MG Dropbox/Marsya Candradewi/Consumption_Smoothing"
		local GIT_ROOT "C:/Users/`c(username)'/Documents/GitHub/consumption_smoothing_jamkesmas/Code"
}

* Necessary Packages 
* ssc install mmerge
* ssc install reghdfe

* Code Files
local CODE_CONS "`GIT_ROOT'/consumption"
local CODE_HEALTH "`GIT_ROOT'/health_measures"
local CODE_INS "`GIT_ROOT'/insurance"
local CODE_CHARA "`GIT_ROOT'/hh_chara"
local CODE_MER "`GIT_ROOT'/merging"

* Input (including IFLS)
local RAW "`DROPBOX_ROOT'/Data/Raw"
local RAW_ID4 "`RAW'/id_tracking/IFLS4"
local RAW_ID5 "`RAW'/id_tracking/IFLS5"
local RAW_CONS "`RAW'/consumption"
local RAW_CONS5 "`RAW'/consumption/IFLS5"
local RAW_HEALTH4 "`RAW'/health_measures/IFLS4"
local RAW_HEALTH5 "`RAW'/health_measures/IFLS5"
local RAW_INS4 "`RAW'/insurance/IFLS4"
local RAW_INS5 "`RAW'/insurance/IFLS5"
local RAW_CHARA4 "`RAW'/hh_chara/IFLS4"
local RAW_CHARA5 "`RAW'/hh_chara/IFLS5"

* Working Files
local WORKING "`DROPBOX_ROOT'/Data/Working"
local WORKING_ID "`WORKING'/id_tracking"
local WORKING_CONS "`WORKING'/consumption"
local WORKING_HEALTH "`WORKING'/health_measures"
local WORKING_INS "`WORKING'/insurance"
local WORKING_CHARA "`WORKING'/hh_chara"
local WORKING_MER "`WORKING'/merged"

* Output Files
local OUTPUT "`DROPBOX_ROOT'/Data/Output"
local FIGURES "`OUTPUT'/Figures"
local TABLES "`OUTPUT'/Tables"
local LOG "`OUTPUT'/Log"

**************
**#  SWITCHES
**************
local cons = 1
local health = 1
local earn = 1
local insurance = 1
local chara = 1
local finmerge = 1

********************************
**#  PER CAPITA EXPENDITURE (PCE)
********************************
if `cons' == 1 {
	* 1. 2007 
	** Most consumption cleaning already done by RAND, so only need to do ...
	** ... final cleaning that corresponds to paper need 
	include "`CODE_CONS'/Consumption_07.do"

	* 2. 2014
	** include RAND-style cleaning
	include "`CODE_CONS'/PCE_14.do"

	** hhsize calculation
	include "`CODE_CHARA'/HHSize_1.do"

	** final 2014 consumption
	 include "`CODE_CONS'/Consumption_14.do"
}
	
**************
**#  HEALTH
**************
if `health' == 1 {
	
	* 1. ADL 
	include "`CODE_HEALTH'/ADL_07.do" // 2007
	include "`CODE_HEALTH'/ADL_14.do" // 2014

	* 2. Chronic Illness
	include "`CODE_HEALTH'/Chronic_07.do" // 2007
	include "`CODE_HEALTH'/Chronic_14.do" // 2014

	* 3. # Days of Sickness
	include "`CODE_HEALTH'/Days_Sick_07.do" // 2007
	include "`CODE_HEALTH'/Days_Sick_14.do" // 2014
	
	* 4. Head and Spouse Health Status (Specify 1-3 for HH Head and Spouse)
	include "`CODE_HEALTH'/Health Status 07.do" // 2007
	include "`CODE_HEALTH'/Health Status 14.do" // 2014
	
	* 5. Health facility utilization 
	include "`CODE_HEALTH'/Health Util 07.do" // 2007
	include "`CODE_HEALTH'/Health Util 14.do" // 2014

}

**************
**#  EARNING
**************
if `earn' == 1 {
	
	* Earning Per Capita
	include "`CODE_CHARA'/Earnings_07.do" // 2007
	include "`CODE_CHARA'/Earnings_14.do" // 2014

}

**************
**# INSURANCE 
**************
if `insurance' == 1 {
	
	include "`CODE_INS'/Jamkesmas_07_new"
	include "`CODE_INS'/Jamkesmas_14_new"
	
	* Archive: 
	* include "`CODE_INS'/Jamkesmas_07.do" // 2007	
	* include "`CODE_INS'/Jamkesmas_14.do" // 2014
	
}

**************
**# HH CHARA 
**************
if `chara' == 1 {
	
	* 1. Head Education 
	include "`CODE_CHARA'/Head_Educ_07.do" // 2007
	include "`CODE_CHARA'/Head_Educ_14.do" // 2014
	
	* 2. Head's Age
	include "`CODE_CHARA'/Head_Age_07.do" // 2007
	include "`CODE_CHARA'/Head_Age_14.do" // 2014

	* 3. Female Head
	include "`CODE_CHARA'/Female Head 07.do" // 2007
	include "`CODE_CHARA'/Female Head 14.do" // 2014

	* 3. HH Members
	include "`CODE_CHARA'/HH_Members_07.do" // 2007
	include "`CODE_CHARA'/HH_Members_14.do" // 2014
	
	* 4. HH lives in Urban comm 
	include "`CODE_CHARA'/Urban_07.do" // 2007
	include "`CODE_CHARA'/Urban_14.do" // 2014
	
	* 5. Poverty Alleviation Programs (PAP)
	include "`CODE_CHARA'/Poverty_Alleviation.do" 
}

*****************************
**# FINAL MERGE & APPEND #**
*****************************

if `finmerge' == 1 {
	
	* Within year merging
	include "`CODE_MER'/Merge07.do" // 2007
	include "`CODE_MER'/Merge14.do" // 2014

	* Appending years
	include "`CODE_MER'/Append 07-14.do"
}