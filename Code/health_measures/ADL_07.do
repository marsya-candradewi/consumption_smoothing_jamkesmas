log using "`LOG'/ADL_07", text replace
clear
set more off
use "`RAW_HEALTH4'/b3b_kk3.dta", clear

reshape wide kk03, i (hhid07 pid07 pidlink) j (kk3type) string

/*Renaming the ADL variables*/
rename kk03A mengangkatair
rename kk03D menimbaair
rename kk03J jalankaki1
rename kk03C jalankaki5
rename kk03B menyapu
rename kk03E membungkuk
rename kk03F berpakaian
rename kk03H buangair
rename kk03M mandi
rename kk03K bangun
rename kk03L berjalan
rename kk03I berdirilantai
rename kk03G berdirikursi

*IADL*
rename kk03N belanja
rename kk03O menyiapkanmakan
rename kk03P minumobat
rename kk03Q berpergiandalamkota
rename kk03R berpergianluarkota

*Labelling the ADL variables*
label var mengangkatair "Mengangkat barang berat (seperti seember air) sejauh 20 meter"
label var menimbaair "Menimba seember air"
label var jalankaki1 "Berjalan kaki sejauh 1 kilometer"
label var jalankaki5 "Berjalan kaki sejauh 5 kilometer"
label var menyapu "Menyapu lantai rumah atau halaman"
label var membungkuk "Membungkuk, jongkok, berlutut, atau bersujud"
label var berpakaian "Berpakaian sendiri tanpa bantuan"
label var buangair "Buang air besar sendiri tanpa bantuan"
label var mandi "Mandi tanpa bantuan"
label var bangun "Berdiri dari tempat tidur"
label var berjalan "Berjalan melintasi ruangan"
label var berdirilantai "Berdiri sendiri setelah duduk di lantai tanpa bantuan"
label var berdirikursi "Berdiri sendiri setelah duduk di kursi tanpa bantuan"
label var belanja "Berbelanja untuk keperluan sendiri"
label var menyiapkanmakan "Menyiapkan makanan untuk diri sendiri"
label var minumobat "Meminum obat"
label var berpergiandalamkota "Bepergian sendiri untuk mengunjungi kenalan di desa ini"
label var berpergianluarkota "Bepergian sendiri ke luar kota"

*Cleaning Missing Data* 
drop if mengangkatair==9 | mengangkatair==.
drop if menimbaair==9 | menimbaair==.
drop if jalankaki1==9 | jalankaki1==.
drop if jalankaki5==9 | jalankaki5==. 
drop if menyapu==9 | menyapu==.
drop if membungkuk==9 | membungkuk==.
drop if berpakaian==9 | berpakaian==.
drop if buangair==9 | buangair==.
drop if mandi==9 | mandi==.
drop if bangun==9 | bangun==.
drop if berjalan==9 | berjalan==.
drop if berdirilantai==9 | berdirilantai==.
drop if berdirikursi==9 | berdirikursi==.
drop if belanja==9 | belanja==.
drop if menyiapkanmakan==9 | menyiapkanmakan==.
drop if minumobat==9 | minumobat==.
drop if berpergiandalamkota==9 | berpergiandalamkota==.
drop if berpergianluarkota==9 | berpergianluarkota==. 

//**Generating ADL indices**//
*Maximum variables*
egen maxmengangkatair=max(mengangkatair)
egen maxmenimbaair=max(menimbaair)
egen maxjalankaki1=max(jalankaki1)
egen maxjalankaki5=max(jalankaki5)
egen maxmenyapu=max(menyapu)
egen maxmembungkuk=max(membungkuk)
egen maxberpakaian=max(berpakaian)
egen maxbuangair=max(buangair)
egen maxmandi=max(mandi)
egen maxbangun=max(bangun)
egen maxberjalan=max(berjalan)
egen maxberdirilantai=max(berdirilantai)
egen maxberdirikursi=max(berdirikursi)
egen maxbelanja=max(belanja)
egen maxmenyiapkanmakan=max(menyiapkanmakan)
egen maxminumobat=max(minumobat)
egen maxberpergiandalamkota=max(berpergiandalamkota)
egen maxberpergianluarkota=max(berpergianluarkota)


*Minumum variables*
egen minmengangkatair=min(mengangkatair)
egen minmenimbaair=min(menimbaair)
egen minjalankaki1=min(jalankaki1)
egen minjalankaki5=min(jalankaki5)
egen minmenyapu=min(menyapu)
egen minmembungkuk=min(membungkuk)
egen minberpakaian=min(berpakaian)
egen minbuangair=min(buangair)
egen minmandi=min(mandi)
egen minbangun=min(bangun)
egen minberjalan=min(berjalan)
egen minberdirilantai=min(berdirilantai)
egen minberdirikursi=min(berdirikursi)
egen minbelanja=min(belanja)
egen minmenyiapkanmakan=min(menyiapkanmakan)
egen minminumobat=min(minumobat)
egen minberpergiandalamkota=min(berpergiandalamkota)
egen minberpergianluarkota=min(berpergianluarkota)

*ADL indices*
gen ADLmengangkatair=(mengangkatair-minmengangkatair)/(maxmengangkatair-minmengangkatair)
gen ADLmenimbaair=(menimbaair-minmenimbaair)/(maxmenimbaair-minmenimbaair)
gen ADLjalankaki1=(jalankaki1-minjalankaki1)/(maxjalankaki1-minjalankaki1)
gen ADLjalankaki5=(jalankaki5-minjalankaki5)/(maxjalankaki5-minjalankaki5)
gen ADLmenyapu=(menyapu-minmenyapu)/(maxmenyapu-minmenyapu)
gen ADLmembungkuk=(membungkuk-minmembungkuk)/(maxmembungkuk-minmembungkuk)
gen ADLberpakaian=(berpakaian-minberpakaian)/(maxberpakaian-minberpakaian)
gen ADLbuangair=(buangair-minbuangair)/(maxbuangair-minbuangair)
gen ADLmandi=(mandi-minmandi)/(maxmandi-minmandi)
gen ADLbangun=(bangun-minbangun)/(maxbangun-minbangun)
gen ADLberjalan=(berjalan-minberjalan)/(maxberjalan-minberjalan)
gen ADLberdirilantai=(berdirilantai-minberdirilantai)/(maxberdirilantai-minberdirilantai)
gen ADLberdirikursi=(berdirikursi-minberdirikursi)/(maxberdirikursi-minberdirikursi)
gen ADLbelanja=(belanja-minbelanja)/(maxbelanja-minbelanja)
gen ADLmenyiapkanmakan=(menyiapkanmakan-minmenyiapkanmakan)/(maxmenyiapkanmakan-minmenyiapkanmakan)
gen ADLminumobat=(minumobat-minminumobat)/(maxminumobat-minminumobat)
gen ADLberpergiandalamkota=(berpergiandalamkota-minberpergiandalamkota)/(maxberpergiandalamkota-minberpergiandalamkota)
gen ADLberpergianluarkota=(berpergianluarkota-minberpergianluarkota)/(maxberpergianluarkota-minberpergianluarkota)

*ADL*
egen ADL=rowmean(ADLberpakaian ADLmandi ADLbangun)

*IADL*
egen IADL=rowmean(ADLbelanja ADLmenyiapkanmakan ADLminumobat)

*General ADL*
egen generalADL=rowmean(ADLberpakaian ADLmandi ADLbangun ADLbelanja ADLmenyiapkanmakan ADLminumobat)

*Relevant Variables*
keep pid07 hhid07 pidlink ADL* ADL IADL generalADL

label var ADL "=1 if there is difficulty in doing Activities of Daily Living"
label var IADL "=1 if there is difficulty in doing Instrumental Activities of Daily Living"
label var generalADL "=1 if there is difficulty in doing ADL and/or IADL"

save "`WORKING_HEALTH'/ADL07.dta", replace
log close
