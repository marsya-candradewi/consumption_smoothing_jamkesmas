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
local CODE_ANALYSIS "`GIT_ROOT'/analysis"

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

*************************
**# SWITCHES
*************************
local head_cons = 1 
local spouse_cons = 0
local head_medical 
*************************
**# MAIN: HEAD CONSUMPTION
*************************
if `head_cons' == 1 {
	eststo clear

	local shocks   "d_dh d_headADL d_headchronic"
	local names    "Days_Ill ADL Chronic"
	local stag     "DH ADL CHR"              // short shock tags

	* Now include Medical and Earnings
	local outcomes "d_lpce d_lfood d_lnonfood d_lmedical d_learningpc"
	local onames   "All Food Non-food Medical Earnings"
	local otag     "ALL FOOD NFOOD MED EARN" // short outcome tags

	local i = 1
	foreach s of local shocks {
		local label : word `i' of `names'
		local st    : word `i' of `stag'

		eststo clear

		local k = 1
		foreach y of local outcomes {
			local yl : word `k' of `onames'
			local ot : word `k' of `otag'

			* (1) No controls
			eststo m`st'_`ot'_0: reg `y' `s', vce(cluster provid14)
			estadd local Controls "No"
			estadd local FE       "No"

			* (2) Full controls + Province FE (+ t==1 as in your spec)
			eststo m`st'_`ot'_1: reg `y' `s' ///
				base_heduc base_headage base_headagesq ///
				d_fhead d_shareprodage d_sharechild ///
				i.provid14 if t==1, vce(cluster provid14)
			estadd local Controls "Yes"
			estadd local FE       "Yes"

			local ++k
		}

		* Export: 10 columns now (All, Food, Non-food, Medical, Earnings × 2)
		esttab ///
			m`st'_ALL_0  m`st'_ALL_1  ///
			m`st'_FOOD_0 m`st'_FOOD_1 ///
			m`st'_NFOOD_0 m`st'_NFOOD_1 ///
			m`st'_MED_0   m`st'_MED_1   ///
			m`st'_EARN_0  m`st'_EARN_1  ///
			using "`TABLES'/`label'_shock.tex", replace se label b(3) se(3) ///
			star(* 0.1 ** 0.05 *** 0.01) ///
			title("Effect of `label' Health Shock on Change in Expenditure and Earnings") ///
			alignment(D{.}{.}{-1}) ///
			keep(`s') ///
			mlabels("All" "All" "Food" "Food" "Non-food" "Non-food" "Medical" "Medical" "Earnings" "Earnings") ///
			stats(Controls FE N r2, fmt(%9s %9s %9.0g 3) ///
				  labels("Controls" "Province FE" "Observations" "R-squared")) ///
			nonotes ///
			addnotes("Standard errors clustered at province level."
					 "\sym{*} p<0.1, \sym{**} p<0.05, \sym{***} p<0.01")

		local ++i
	}
}


*************************
**# MAIN: SPOUSE CONSUMPTION
*************************
if `spouse_cons' == 1 {
	eststo clear

	local shocks   "d_ds d_spouseADL d_spousechronic"
	local names    "Days_Ill ADL Chronic"
	local stag     "DH ADL CHR"              // short shock tags

	local outcomes "d_lpce d_lfood d_lnonfood"
	local onames   "All Food Non-food"
	local otag     "ALL FOOD NFOOD"          // short outcome tags

	local i = 1
	foreach s of local shocks {
		local label : word `i' of `names'
		local st    : word `i' of `stag'

		* Keep only this shock's six models in the export
		eststo clear

		local k = 1
		foreach y of local outcomes {
			local yl : word `k' of `onames'
			local ot : word `k' of `otag'

			* (1) No controls
			eststo m`st'_`ot'_0: reg `y' `s', vce(cluster provid14)
			estadd local Controls "No"
			estadd local FE       "No"

			* (2) Full controls + Province FE (+ t==1 as in your spec)
			eststo m`st'_`ot'_1: reg `y' `s' ///
				base_heduc base_headage base_headagesq ///
				d_fhead d_shareprodage d_sharechild ///
				i.provid14 if t==1, vce(cluster provid14)
			estadd local Controls "Yes"
			estadd local FE       "Yes"

			local ++k
		}

		* Export: 6 columns = All, Food, Non-food × (No Ctrls / Full)
		esttab ///
			m`st'_ALL_0  m`st'_ALL_1  ///
			m`st'_FOOD_0 m`st'_FOOD_1 ///
			m`st'_NFOOD_0 m`st'_NFOOD_1 ///
			using "`TABLES'/spouse_`label'_shock.tex", replace se label b(3) se(3) ///
			star(* 0.1 ** 0.05 *** 0.01) ///
			title("Effect of Spouse's `label' Health Shock on Change of Per Capita Expenditure") ///
			alignment(D{.}{.}{-1}) ///
			keep(`s') ///
			mlabels("All" "All" "Food" "Food" "Non-food" "Non-food") ///
			stats(Controls FE N r2, fmt(%9s %9s %9.0g %9.3f) ///
				  labels("Controls" "Province FE" "Observations" "R-squared")) ///
			nonotes ///
			addnotes("Standard errors clustered at province level." ///
					 "\sym{*} p<0.1, \sym{**} p<0.05, \sym{***} p<0.01")

		local ++i
	}
}

