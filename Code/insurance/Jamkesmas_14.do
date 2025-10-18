use "`RAW_INS5'/b3b_ak1.dta", clear
keep if ak01==1
reshape wide ak02 ak03x ak03 ak04 ak05, i(hhid14 pid14 pidlink) j(aktype) string
gen jamkesmas=1 if ak02H==1
replace jamkesmas=1 if ak02I==1
replace jamkesmas=1 if ak02L==1

mmerge hhid14 pid14 pidlink using "`RAW_ID5'/bk_ar1.dta"
drop if ar09>900 | ar08yr>9000
keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11

gen head=1 if ar02b==1
gen spouse=1 if ar02b==2

gen hjamkesmas=head*jamkesmas

***********************
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

***
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="A"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AB"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AC"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AD"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AV"


replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABC"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABD"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABV"

replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACD"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACV"

replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ADE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ADV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ADH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AHV"

replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCD"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABHV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACDE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACDV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACDH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ADEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ADEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="AEHV"

replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCDE"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCDV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCDH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCHV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABDEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABDEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABDHV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABEHV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACDEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACDEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ADEHV"

replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCDEH"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCDEV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABDEHV"
replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ACDEHV"

replace hjamkesmas=1 if spouse==1 & ak02I==1 &ak05I=="ABCDEHV"
***
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="A"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AB"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AC"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AD"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AV"


replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABC"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABD"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABV"

replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACD"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACV"

replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ADE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ADV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ADH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AHV"

replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCD"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABHV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACDE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACDV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACDH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ADEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ADEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="AEHV"

replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCDE"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCDV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCDH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCHV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABDEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABDEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABDHV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABEHV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACDEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACDEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ADEHV"

replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCDEH"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCDEV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABDEHV"
replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ACDEHV"

replace hjamkesmas=1 if spouse==1 & ak02L==1 &ak05L=="ABCDEHV"

collapse (sum) head hjam , by (hhid14)
drop if head~=1
drop head

replace hjam=1 if hjam>1

save "`WORKING_INS'/hjamkesmas14.dta", replace

***************************************************************************888
use "`RAW_INS5'/b3b_ak1.dta", clear
keep if ak01==1
reshape wide ak02 ak03x ak03 ak04 ak05, i(hhid14 pid14 pidlink) j(aktype) string
gen jamkesmas=1 if ak02H==1
replace jamkesmas=1 if ak02I==1
replace jamkesmas=1 if ak02L==1

mmerge hhid14 pid14 pidlink using "`RAW_ID5'/bk_ar1.dta"
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

************************************************


replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="A"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AB"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AC"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AD"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AV"


replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABC"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABD"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABV"

replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACD"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACV"

replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ADE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ADV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ADH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AHV"

replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCD"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABHV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACDE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACDV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACDH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ADEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ADEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="AEHV"

replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCDE"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCDV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCDH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCHV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABDEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABDEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABDHV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABEHV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACDEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACDEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ADEHV"

replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCDEH"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCDEV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABDEHV"
replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ACDEHV"

replace sjamkesmas=1 if head==1 & ak02I==1 &ak05I=="ABCDEHV"

**************************************

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="A"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AB"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AC"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AD"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AV"


replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABC"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABD"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABV"

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACD"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACV"

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ADE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ADV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ADH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AHV"

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCD"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABHV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACDE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACDV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACDH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ADEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ADEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="AEHV"

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCDE"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCDV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCDH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCHV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABDEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABDEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABDHV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABEHV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACDEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACDEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ADEHV"

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCDEH"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCDEV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABDEHV"
replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ACDEHV"

replace sjamkesmas=1 if head==1 & ak02L==1 &ak05L=="ABCDEHV"

collapse (sum) spouse sjam , by (hhid14)
drop if spouse~=1
drop spouse

replace sjam=1 if sjam>1

save "`WORKING_INS'/sjamkesmas14.dta", replace

