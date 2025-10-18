log using "`LOG'/ADL 14", text replace
clear
set more off
use "`RAW_HEALTH5'/b3b_kk3.dta", replace

reshape wide kk03, i (hhid14 pid14 pidlink) j (kk3type) string

/*Renaming the ADL variables*/
*ADL*
rename kk03F berpakaian
rename kk03M mandi
rename kk03K bangun
rename kk03KA makan
rename kk03KC kontrolba

*IADL*
rename kk03N belanja
rename kk03O menyiapkanmakan
rename kk03P minumobat
rename kk03PA pekerjaanrumah
rename kk03PB shopgroceries
rename kk03PC mengaturuang

/*Labelling the ADL variables*/

label var berpakaian "To dress without help"
label var mandi "To bathe"
label var bangun "To get out of bed"
label var makan "To eat (eating food by oneself when it is ready)"
label var kontrolba "To control urination or defecation"

label var belanja "To shop for personal needs"
label var menyiapkanmakan "To prepare hot meals (ingredients, cooking, serving)"
label var minumobat "To take medicine (taking right portion right on time)"
label var shopgroceries "To shop for groceries (deciding what to buy and pay)"
label var mengaturuang "To manage money"

/*Cleaning Missing Data*/
drop if berpakaian==9 | berpakaian==.
drop if mandi==9 | mandi==.
drop if bangun==9 | bangun==.
drop if makan==9 | makan==. 
drop if kontrolba==9 | kontrolba==.

drop if belanja==9 | belanja==.
drop if menyiapkanmakan==9 | menyiapkanmakan==.
drop if minumobat==9 | minumobat==.
drop if shopgroceries==9 | shopgroceries==.
drop if mengaturuang==9 | mengaturuang==.

//**Generating ADL indices**//
/*Maximum variables*/
egen maxberpakaian=max(berpakaian)
egen maxmandi=max(mandi)
egen maxbangun=max(bangun)
egen maxmakan=max(makan)
egen maxkontrolba=max(kontrolba)

egen maxbelanja=max(belanja)
egen maxmenyiapkanmakan=max(menyiapkanmakan)
egen maxminumobat=max(minumobat)
egen maxshopgroceries=max(shopgroceries)
egen maxmengaturuang=max(mengaturuang)

*Minumum variables*
egen minberpakaian=min(berpakaian)
egen minmandi=min(mandi)
egen minbangun=min(bangun)
egen minmakan=min(makan)
egen minkontrolba=min(kontrolba)

egen minbelanja=min(belanja)
egen minmenyiapkanmakan=min(menyiapkanmakan)
egen minminumobat=min(minumobat)
egen minshopgroceries=min(shopgroceries)
egen minmengaturuang=min(mengaturuang)

*ADL indices*
gen ADLberpakaian=(berpakaian-minberpakaian)/(maxberpakaian-minberpakaian)
gen ADLmandi=(mandi-minmandi)/(maxmandi-minmandi)
gen ADLbangun=(bangun-minbangun)/(maxbangun-minbangun)
gen ADLmakan=(makan-minmakan)/(maxmakan-minmakan)
gen ADLkontrolba=(kontrolba-minkontrolba)/(maxkontrolba-minkontrolba)

gen ADLbelanja=(belanja-minbelanja)/(maxbelanja-minbelanja)
gen ADLmenyiapkanmakan=(menyiapkanmakan-minmenyiapkanmakan)/(maxmenyiapkan-minmenyiapkan)
gen ADLminumobat=(minumobat-minminumobat)/(maxminumobat-minminumobat)
gen ADLshopgroceries=(shopgroceries-minshopgroceries)/(maxshopgroceries-minshopgroceries)
gen ADLmengaturuang=(mengaturuang-minmengaturuang)/(maxmengaturuang-minmengaturuang)

*ADL*
egen ADL=rowmean(ADLberpakaian ADLmandi ADLbangun)

*IADL*
egen IADL=rowmean(ADLbelanja ADLmenyiapkanmakan ADLminumobat)

*General ADL*
egen generalADL=rowmean(ADLberpakaian ADLmandi ADLbangun ADLbelanja ADLmenyiapkanmakan ADLminumobat)

*Relevant Variables*
keep pid14 hhid14 pidlink ADL* ADL IADL generalADL
label var ADL "=1 if there is difficulty in doing Activities of Daily Living"
label var IADL "=1 if there is difficulty in doing Instrumental Activities of Daily Living"
label var generalADL "=1 if there is difficulty in doing ADL and/or IADL"

save "`WORKING_HEALTH'/ADL14.dta", replace
log close


