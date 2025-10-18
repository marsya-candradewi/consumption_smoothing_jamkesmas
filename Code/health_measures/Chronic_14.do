clear
use "`RAW_HEALTH5'/b3b_cd3.dta"

keep hhid14 pid* cd05 cdtype

drop if cd05==9 | cd05==.

reshape wide cd05, i (hhid14 pid14 pidlink) j (cdtype) string

for var cd05*: replace X=0 if X==3
generate chronic=1 if cd05A==1 | cd05B==1 | cd05C==1 | cd05D==1 | cd05E==1 | cd05F==1 | cd05G==1 | cd05H==1 | cd05I==1 | cd05J==1 
replace chronic=0 if chronic==.

ren cd05A hypertension
ren cd05B diabetes
ren cd05C TBC
ren cd05D asthma
ren cd05E otherlung
ren cd05F heartattack
ren cd05G liver
ren cd05H stroke 
ren cd05I cancertumor
ren cd05J arthritisrheumatism

drop cd05*
save "`WORKING_HEALTH'/chronic14.dta", replace

***
