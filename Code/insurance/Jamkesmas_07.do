use "`RAW_INS4'/b3b_ak1.dta", clear
keep if ak01==1
reshape wide ak02 ak03x ak03 ak04 ak05, i(hhid07 pid07 pidlink) j(aktype) string
gen jamkesmas=1 if ak02H==1

mmerge hhid07 pid07 pidlink using "`RAW_ID4'/bk_ar1.dta"
drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
gen spouse=1 if ar02b==2

gen hjamkesmas=head*jamkesmas

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="A"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AB"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AC"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AD"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AV"


replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABC"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABD"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABV"

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACD"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACV"

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ADE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ADV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ADH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AHV"

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCD"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABHV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACDE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACDV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACDH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ADEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ADEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="AEHV"

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCDE"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCDV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCDH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCHV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABDEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABDEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABDHV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABEHV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACDEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACDEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ADEHV"

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCDEH"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCDEV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABDEHV"
replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ACDEHV"

replace hjamkesmas=1 if spouse==1 & ak02H==1 &ak05H=="ABCDEHV"

collapse (sum) head hjam , by (hhid07)
drop if head~=1
drop head

replace hjam=1 if hjam>1

save "`WORKING_INS'/hjamkesmas07.dta", replace

***********************************************************************************
use "`RAW_INS4'/b3b_ak1.dta", clear
keep if ak01==1
reshape wide ak02 ak03x ak03 ak04 ak05, i(hhid07 pid07 pidlink) j(aktype) string
gen jamkesmas=1 if ak02H==1

mmerge hhid07 pid07 pidlink using "`RAW_ID4'/bk_ar1.dta"
drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
gen spouse=1 if ar02b==2

gen sjamkesmas=spouse*jamkesmas

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="A"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AB"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AC"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AD"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AV"


replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABC"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABD"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABV"

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACD"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACV"

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ADE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ADV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ADH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AHV"

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCD"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABHV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACDE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACDV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACDH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ADEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ADEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="AEHV"

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCDE"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCDV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCDH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCHV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABDEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABDEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABDHV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABEHV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACDEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACDEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ADEHV"

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCDEH"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCDEV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABDEHV"
replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ACDEHV"

replace sjamkesmas=1 if head==1 & ak02H==1 &ak05H=="ABCDEHV"

collapse (sum) spouse sjam , by (hhid07)
drop if spouse~=1
drop spouse

replace sjam=1 if sjam>1

save "`WORKING_INS'/sjamkesmas07.dta", replace
