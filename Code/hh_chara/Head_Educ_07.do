/*Education of Head*/
log using "`LOG'/Head's Edu 07", text replace

/*Generating Head*/
clear
set more off
use "`RAW_ID4'/bk_ar1.dta", clear
gen head=1 if ar02b==1
replace head=0 if head==.

keep if ar01a==1 | ar01a==2 | ar01a==5 | ar01a==11
drop if ar09>900 | ar08yr>9000
keep hhid07 pid07 pidlink head

/*Generating Year of Schooling*/
mmerge hhid07 pid07 pidlink using "`RAW_CHARA4'/b3a_dl1.dta"

generate educ=0 if dl04==3

/*SD*/
replace educ=0 if dl06==2 & dl07==0
replace educ=1 if dl06==2 & dl07==1
replace educ=1 if dl06==2 & dl07==.
replace educ=1 if dl06==2 & dl07==98
replace educ=2 if dl06==2 & dl07==2
replace educ=3 if dl06==2 & dl07==3
replace educ=4 if dl06==2 & dl07==4
replace educ=5 if dl06==2 & dl07==5
replace educ=6 if dl06==2 & dl07==6
replace educ=6 if dl06==2 & dl07==7

/*SMP Umum*/
replace educ=6 if dl06==3 & dl07==0
replace educ=7 if dl06==3 & dl07==98
replace educ=7 if dl06==3 & dl07==.
replace educ=7 if dl06==3 & dl07==1
replace educ=8 if dl06==3 & dl07==2
replace educ=9 if dl06==3 & dl07==3
replace educ=9 if dl06==3 & dl07==7

/*SMP Kejuruan*/
replace educ=6 if dl06==4 & dl07==0
replace educ=7 if dl06==4 & dl07==98
replace educ=7 if dl06==4 & dl07==.
replace educ=7 if dl06==4 & dl07==1
replace educ=8 if dl06==4 & dl07==2
replace educ=9 if dl06==4 & dl07==3
replace educ=9 if dl06==4 & dl07==7

/*SMA Umum*/
replace educ=9 if dl06==5 & dl07==0
replace educ=10 if dl06==5 & dl07==98
replace educ=10 if dl06==5 & dl07==.
replace educ=10 if dl06==5 & dl07==1
replace educ=11 if dl06==5 & dl07==2
replace educ=12 if dl06==5 & dl07==3
replace educ=12 if dl06==5 & dl07==7

/*SMK*/
replace educ=9 if dl06==6 & dl07==0
replace educ=10 if dl06==6 & dl07==98
replace educ=10 if dl06==6 & dl07==.
replace educ=10 if dl06==6 & dl07==1
replace educ=11 if dl06==6 & dl07==2
replace educ=12 if dl06==6 & dl07==3
replace educ=12 if dl06==6 & dl07==7

/*Akademi*/
replace educ=12 if dl06==60 & dl07==0
replace educ=13 if dl06==60 & dl07==98
replace educ=13 if dl06==60 & dl07==.
replace educ=13 if dl06==60 & dl07==1
replace educ=14 if dl06==60 & dl07==2
replace educ=15 if dl06==60 & dl07==3
replace educ=15 if dl06==60 & dl07==4
replace educ=15 if dl06==60 & dl07==7

/*S1*/
replace educ=12 if dl06==61 & dl07==0
replace educ=13 if dl06==61 & dl07==98
replace educ=13 if dl06==61 & dl07==.
replace educ=13 if dl06==61 & dl07==1
replace educ=14 if dl06==61 & dl07==2
replace educ=15 if dl06==61 & dl07==3
replace educ=16 if dl06==61 & dl07==4
replace educ=16 if dl06==61 & dl07==5
replace educ=16 if dl06==61 & dl07==6
replace educ=16 if dl06==61 & dl07==7

/*S2*/
replace educ=16 if dl06==62 & dl07==0
replace educ=17 if dl06==62 & dl07==98
replace educ=17 if dl06==62 & dl07==.
replace educ=17 if dl06==62 & dl07==1
replace educ=18 if dl06==62 & dl07==2
replace educ=18 if dl06==62 & dl07==7

/*S3*/
replace educ=18 if dl06==63 & dl07==0
replace educ=19 if dl06==63 & dl07==98
replace educ=19 if dl06==63 & dl07==.
replace educ=19 if dl06==63 & dl07==1
replace educ=20 if dl06==63 & dl07==2
replace educ=21 if dl06==63 & dl07==3
replace educ=22 if dl06==63 & dl07==4
replace educ=23 if dl06==63 & dl07==5
replace educ=23 if dl06==63 & dl07==7

/*Paket A*/
replace educ=0 if dl06==11 & dl07==0
replace educ=1 if dl06==11 & dl07==1
replace educ=1 if dl06==11 & dl07==.
replace educ=1 if dl06==11 & dl07==98
replace educ=2 if dl06==11 & dl07==2
replace educ=3 if dl06==11 & dl07==3
replace educ=4 if dl06==11 & dl07==4
replace educ=5 if dl06==11 & dl07==5
replace educ=6 if dl06==11 & dl07==6
replace educ=6 if dl06==11 & dl07==7

/*Paket B*/
replace educ=6 if dl06==12 & dl07==0
replace educ=7 if dl06==12 & dl07==98
replace educ=7 if dl06==12 & dl07==.
replace educ=7 if dl06==12 & dl07==1
replace educ=8 if dl06==12 & dl07==2
replace educ=9 if dl06==12 & dl07==3
replace educ=9 if dl06==12 & dl07==7

/*Paket C*/
replace educ=9 if dl06==15 & dl07==0
replace educ=10 if dl06==15 & dl07==98
replace educ=10 if dl06==15 & dl07==.
replace educ=10 if dl06==15 & dl07==1
replace educ=11 if dl06==15 & dl07==2
replace educ=12 if dl06==15 & dl07==3
replace educ=12 if dl06==15 & dl07==7

/*Univ Terbuka*/
replace educ=12 if dl06==13 & dl07==0
replace educ=13 if dl06==13 & dl07==98
replace educ=13 if dl06==13 & dl07==.
replace educ=13 if dl06==13 & dl07==1
replace educ=14 if dl06==13 & dl07==2
replace educ=15 if dl06==13 & dl07==3
replace educ=16 if dl06==13 & dl07==4
replace educ=16 if dl06==13 & dl07==5
replace educ=16 if dl06==13 & dl07==6
replace educ=16 if dl06==13 & dl07==7

/*Pesantren*/
replace educ=0 if dl06==14 & dl07==0
replace educ=1 if dl06==14 & dl07==1
replace educ=1 if dl06==14 & dl07==.
replace educ=1 if dl06==14 & dl07==98
replace educ=2 if dl06==14 & dl07==2
replace educ=3 if dl06==14 & dl07==3
replace educ=4 if dl06==14 & dl07==4
replace educ=5 if dl06==14 & dl07==5
replace educ=6 if dl06==14 & dl07==6
replace educ=6 if dl06==14 & dl07==7

/*SLB*/
replace educ=1 if dl06==17& dl07==1
replace educ=2 if dl06==17 & dl07==2

/*MI*/
replace educ=0 if dl06==72 & dl07==0
replace educ=1 if dl06==72 & dl07==1
replace educ=1 if dl06==72 & dl07==.
replace educ=1 if dl06==72 & dl07==98
replace educ=2 if dl06==72 & dl07==2
replace educ=3 if dl06==72 & dl07==3
replace educ=4 if dl06==72 & dl07==4
replace educ=5 if dl06==72 & dl07==5
replace educ=6 if dl06==72 & dl07==6
replace educ=6 if dl06==72 & dl07==7

/*MTs*/
replace educ=6 if dl06==73 & dl07==0
replace educ=7 if dl06==73 & dl07==98
replace educ=7 if dl06==73 & dl07==.
replace educ=7 if dl06==73 & dl07==1
replace educ=8 if dl06==73 & dl07==2
replace educ=9 if dl06==73 & dl07==3
replace educ=9 if dl06==73 & dl07==7

/*MA*/
replace educ=9 if dl06==74 & dl07==0
replace educ=10 if dl06==74 & dl07==98
replace educ=10 if dl06==74 & dl07==.
replace educ=10 if dl06==74 & dl07==1
replace educ=11 if dl06==74 & dl07==2
replace educ=12 if dl06==74 & dl07==3
replace educ=12 if dl06==74 & dl07==7

/*TK*/
replace educ=0 if dl06==90

/*Unknown*/
replace educ=0 if dl06==95 | dl06==9

gen heduc=head*educ
keep if head==1
duplicates tag hhid07, gen(pairhh)
drop if pairhh~=0

keep hhid07 heduc

save "`WORKING_CHARA'/headeduc07.dta", replace
log close
