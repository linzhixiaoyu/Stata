**** This script characterizes the study cohort on different types of absences in the first absence. 
**** The respondents can claim multiple reasons for an absence. The absence reasons are measured in 2 ways: 1. reasons are mutually exclusive;  2. contains at least one reason.

**** Step 1 + 2: sample setup; Setp 3 (line 165): summary statistics for mutually exclusive reasons; Step 4 (line 331): summary statistics for at least 1 of x reasons
**** outcome types: frequency

**** measured variables: 
* age group: AGEGR5
* age at the beginning of the first absence: AGE_INT1BEG
* education: cat_educ_4
* number of children raised by respondent: TOTALCHDC
* number of children live in household full time: CHDINFTC
* total number of work periods: NO_WKPER
* total number of work interruptions: NO_INT
* annual personal income of respondent: INCMC (2 subgroups: all age; age under 60 in 2011)
* total household income: INCMHSD (2 subgroups: all age; age under 60 in 2011)
* whether spouse has ever been immigrants: spouse_immig
* region of residence: REGION
* occupation category: NOCS2006_C10
* industry category: NAICS2007_C16



****************************************************
***** Step 1: Define the study cohort: women. *****
****************************************************
* This step separate the cohort into 2 groups: immigrants and non-immigrants. And define the education categories: cat_educ_4. Add spousal immigrantion information.
clear all
set more off

capture log close
log using summarytables.log, replace

use ""

keep if SEX==2

gen immig=0
replace immig=1 if BPR_Q50==1
gen nonimmig = 1 if immig ~= 1

* define Education categories: 4 categories + 1 don't know */

* (GSS) edu5: Highest level of education obtained by the respondent - 5 groups 
* Coverage: All respondents

* (GSS) edu10: Highest level of education obtained by the respondent - 10 groups 
* Coverage: All respondents

gen cat_educ_4=.

replace cat_educ_4=1 if EDU5 == 5 | EDU5 == 4
replace cat_educ_4=2 if EDU5 == 3 | EDU5==2
replace cat_educ_4=3 if EDU10==2
replace cat_educ_4=4 if EDU10==1

* Whether spouse has ever been immigrants: BRTHPREG, spouse_immig.
* BRTHPREG: 
*    01, 02, 03: spouse born in Canada
*    04 - 11: spouse born outside of Canada
*    96: not stated/ do not know
*    97: not asked
*    98: Not stated in which country outside of Canada respondent was born
*    99: Don't know in which country outside of Canada respondent's spouse/partner was born
*    Respondents choosed 98 and 99 are included in the spouse_immig = 1 group, as at least knowing the respondents' spouses are immigrants.
gen spouse_immig = .
replace spouse_immig = 0 if inlist(BRTHPREG, 01,02,03)
replace spouse_immig = 1 if spouse_immig == . & (BRTHPREG ~= 96 & BRTHPREG ~= 97)

*************************************************************************************
***** Step 2: Charaterize the cohort by measuring the absence reasons in 2 ways *****
*************************************************************************************

***a. absence reasons are mutually exclusive ***

* reasons for absences categorical data - muturally exclusive categories
 
* Note: abscat[x] == 1: maternity (c12) = yes; own illness (c09), childcare (c13), eldercare (c14), other family responsibilities (c15) = no
*       abscat[x] == 2: childcare (c13) = yes; own illness (c09), maternity (c12), eldercare (c14), other family responsibilities (c15) = no
*       abscat[x] == 3: eldercare (c14) or  other family responsibilities (c15) = yes; own illness (c09), maternity (c12), childcare (c13) = no
*       abscat[x] == 4: own illness (c09) = yes; maternity (c12), childcare (c13), eldercare (c14), other family responsibilities (c15) = no
*       abscat[x] == 5: maternity (c12) and childcare (c13) = yes; own illness (c09), eldercare (c14), other family responsibilities (c15) = no
*       abscat[x] == 6: any of (c09), (c12), (c13), (c14), c(15) = yes; and abscat not equal to 1 - 5
*       abscat[x] == 7 any other abscences given 
*       abscat[x] == 8 all other observations (no absences, or missing information)

forvalues i = 1(1)5 {

gen abscat`i' = 1 if WH`i'_Q370_C12 == 1 & WH`i'_Q370_C09 == 2 & WH`i'_Q370_C13 == 2 & WH`i'_Q370_C14 == 2 & WH`i'_Q370_C15 == 2
replace abscat`i' = 2 if WH`i'_Q370_C13 == 1 & WH`i'_Q370_C09 == 2 & WH`i'_Q370_C12 == 2 & WH`i'_Q370_C14 == 2 & WH`i'_Q370_C15 == 2
replace abscat`i' = 3 if (WH`i'_Q370_C14 == 1 | WH`i'_Q370_C15 == 1) & WH`i'_Q370_C09 == 2 & WH`i'_Q370_C12 == 2 & WH`i'_Q370_C13 == 2
replace abscat`i' = 4 if WH`i'_Q370_C09 == 1 & WH`i'_Q370_C12 == 2 & WH`i'_Q370_C13 == 2 & WH`i'_Q370_C14 == 2 & WH`i'_Q370_C15 == 2
replace abscat`i' = 5 if WH`i'_Q370_C12 == 1 & WH`i'_Q370_C13 == 1 & WH`i'_Q370_C09 == 2 & WH`i'_Q370_C14 == 2 & WH`i'_Q370_C15 == 2
replace abscat`i' = 6 if abscat`i' == . & (WH`i'_Q370_C09 == 1 | WH`i'_Q370_C12 == 1 | WH`i'_Q370_C13 == 1 | WH`i'_Q370_C14 == 1 | WH`i'_Q370_C15 == 1)
replace abscat`i' = 7 if abscat`i' == . & (WH`i'_Q370_C01 == 1 | WH`i'_Q370_C02 == 1 | WH`i'_Q370_C03 == 1 | WH`i'_Q370_C04 == 1 | WH`i'_Q370_C05 == 1 | WH`i'_Q370_C06 == 1 | WH`i'_Q370_C07 == 1 | WH`i'_Q370_C08 == 1 | WH`i'_Q370_C10 == 1 | WH`i'_Q370_C11 == 1 | WH`i'_Q370_C16 == 1 | WH`i'_Q370_C17 == 1)
replace abscat`i' = 8 if abscat`i' == .

}

* For 'any other observations', generate a variable for respondents who took other types of absences, and did not take any of the reasons in c9, c12-c15 (maternity; own illness; childcare; eldercare; other family responsibilities) 
forvalues i = 1(1)5 {

gen abscat_7exclude`i' = 1 if abscat`i' == 7 & (WH`i'_Q370_C12 == 2 & WH`i'_Q370_C09 == 2 & WH`i'_Q370_C13 == 2 & WH`i'_Q370_C14 == 2 & WH`i'_Q370_C15 == 2)
replace abscat_7exclude`i' = 0 if abscat_7exclude`i' == .
}

* For the data completeness, generate a variable for respondents who took other types of absences + at least one of the reasons in c9, c12-c15 (maternity; own illness; childcare; eldercare; other family responsibilities) 
* other reasons = yes; at least one of (maternity (c12), own illness (c09), childcare (c13), eldercare (c14), other family responsibilities (c15)) = yes
forvalues i = 1(1)5 {

gen abscat_7combine`i' = 1 if (WH`i'_Q370_C01 == 1 | WH`i'_Q370_C02 == 1 | WH`i'_Q370_C03 == 1 | WH`i'_Q370_C04 == 1 | WH`i'_Q370_C05 == 1 | WH`i'_Q370_C06 == 1 | WH`i'_Q370_C07 == 1 | WH`i'_Q370_C08 == 1 | WH`i'_Q370_C10 == 1 | WH`i'_Q370_C11 == 1 | WH`i'_Q370_C16 == 1 | WH`i'_Q370_C17 == 1) & (WH`i'_Q370_C12 == 1 | WH`i'_Q370_C09 == 1 | WH`i'_Q370_C13 == 1 | WH`i'_Q370_C14 == 1 | WH`i'_Q370_C15 == 1)
replace abscat_7combine`i' = 0 if abscat_7combine`i' == .
}


*Generate indicator that tells is if at least one reason for absence #i was reason X , this variable is coded as missing if there is no reason given for absence #i *
forvalues i=1/5{
	foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		gen `var'`i'=0 if WH`i'_Q370_C01<.
		}
		
	replace ownill`i' =1 if WH`i'_Q370_C09==1
	replace matpat`i' =1 if WH`i'_Q370_C12==1
	replace child`i' =1 if WH`i'_Q370_C13==1
	replace elder`i' =1 if WH`i'_Q370_C14==1
	replace pers`i' =1 if WH`i'_Q370_C15==1

	replace seas`i' =1 if WH`i'_Q370_C01==1
	replace temp`i' =1 if WH`i'_Q370_C02==1
	replace lack`i' =1 if WH`i'_Q370_C03==1 
	replace quit`i' =1 if WH`i'_Q370_C04==1 
	replace fired`i' =1 if WH`i'_Q370_C05==1 
	replace busend`i' =1 if WH`i'_Q370_C06==1 
	replace moved`i' =1 if WH`i'_Q370_C07==1 
	replace chjob`i'=1 if WH`i'_Q370_C08==1 
	replace schl`i' =1 if WH`i'_Q370_C10==1 
	replace retire`i' =1 if WH`i'_Q370_C11==1
	replace oth`i' =1 if WH`i'_Q370_C16==1 
	replace trav`i' =1 if WH`i'_Q370_C17==1 
	}

*Generate variable that indicates # times reason X was given for absence across 5 potential absence periods, missing values are zeros here*
egen ownillall = rowtotal(ownill*)
egen matpatall = rowtotal(matpat*)
egen childall = rowtotal(child*)
egen elderall = rowtotal(elder*)
egen persall = rowtotal(pers*)

egen seasall = rowtotal(seas*)
egen tempall = rowtotal(temp*)
egen lackall = rowtotal(lack*) 
egen quitall = rowtotal(quit*) 
egen firedall = rowtotal(fired*) 
egen busendall = rowtotal(busend*) 
egen movedall = rowtotal(moved*) 
egen chjoball = rowtotal(chjob*) 
egen schlall = rowtotal(schl*) 
egen retireall = rowtotal(retire*) 
egen othall = rowtotal(oth*) 
egen travall = rowtotal(trav*)

save "C:\Users\xx3yu\OneDrive - University of Waterloo\Stata\summary stats\sample for summary statistics.dta", replace


**************************************************************
**** Step 3. Summary tables for 8 multiple exclusive reasons****
**************************************************************
**** outcome types: frequency
**** results are measured in 2 ways: unweighted and weighted (analytical weights, importance weights)
**** measured variables: 
* age group: AGEGR5
* age at the beginning of the first absence: AGE_INT1BEG
* education: cat_educ_4
* number of children raised by respondent: TOTALCHDC
* number of children live in household full time: CHDINFTC
* total number of work periods: NO_WKPER
* total number of work interruptions: NO_INT
* annual personal income of respondent: INCMC (2 subgroups: all age; age under 60 in 2011)
* total household income: INCMHSD (2 subgroups: all age; age under 60 in 2011)
* whether spouse has ever been immigrants: spouse_immig
* region of residence: REGION
* occupation category: NOCS2006_C10
* industry category: NAICS2007_C16
clear all
use "C:\Users\xx3yu\OneDrive - University of Waterloo\Stata\summary stats\sample for summary statistics.dta", clear 


**** 3a. unweighted statistics

** for the entire sample
foreach var in AGEGR5 cat_educ_4 TOTALCHDC CHDINFTC NO_WKPER NO_INT INCMC INCMHSD spouse_immig REGION NOCS2006_C10 NAICS2007_C16 {
	foreach grp in immig nonimmig{
		tab `var' abscat1 if `grp' == 1, col matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "unweighted summary statistics.xlsx", sheet(`var'_`grp') modify
		putexcel A1 = "Frequency table of absence categories by `var'"
		putexcel A2 = "`var' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}
** age at the beginning of the first absence
forvalues i = 1(1)8{
	foreach grp in immig nonimmig{
		tab AGE_INT1BEG if `grp' == 1 & abscat1 == `i', matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "unweighted summary statistics_age at the beginning of the first absence.xlsx", sheet(AGE_INT1BEG_abscat1=`i'_`grp') modify
		putexcel A1 = "Frequency table of absence categories by `var'"
		putexcel A2 = "AGE_INT1BEG abscat`i' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}

/* or
bysort immig: tab AGE_INT1BEG if abscat1 == 1
bysort immig: tab AGE_INT1BEG if abscat1 == 2
bysort immig: tab AGE_INT1BEG if abscat1 == 3
bysort immig: tab AGE_INT1BEG if abscat1 == 4
bysort immig: tab AGE_INT1BEG if abscat1 == 5
bysort immig: tab AGE_INT1BEG if abscat1 == 6
bysort immig: tab AGE_INT1BEG if abscat1 == 7
bysort immig: tab AGE_INT1BEG if abscat1 == 8
*/

** income information of respondent age under 60
keep if inrange(AGEGR5, 1, 10)  
foreach var in INCMC INCMHSD{
	foreach grp in immig nonimmig{
		tab `var' abscat1 if `grp' == 1, col matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "unweighted summary statistics.xlsx", sheet(`var'_`grp'_under60) modify
		putexcel A1 = "Frequency table of absence categories by `var' under age 60"
		putexcel A2 = "`var' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}


**** 3b. weighted statistics: analytical weights
clear all
use "C:\Users\xx3yu\OneDrive - University of Waterloo\Stata\summary stats\sample for summary statistics.dta", clear 

** for the entire sample
foreach var in AGEGR5 cat_educ_4 TOTALCHDC CHDINFTC NO_WKPER NO_INT INCMC INCMHSD spouse_immig REGION NOCS2006_C10 NAICS2007_C16 {
	foreach grp in immig nonimmig{
		tab `var' abscat1 if `grp' == 1 [aw= WGHT_PER], col matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "analytical weighted summary statistics.xlsx", sheet(`var'_`grp') modify
		putexcel A1 = "Frequency table of absence categories by `var'"
		putexcel A2 = "`var' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}
** age at the beginning of the first absence
forvalues i = 1(1)8{
	foreach grp in immig nonimmig{
		tab AGE_INT1BEG if `grp' == 1 & abscat1 == `i' [aw= WGHT_PER], matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "analytical weighted summary statistics_age at the beginning of the first absence.xlsx", sheet(AGE_INT1BEG_abscat1=`i'_`grp') modify
		putexcel A1 = "Frequency table of absence categories by `var'"
		putexcel A2 = "AGE_INT1BEG abscat`i' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}

** income information of respondent age under 60
keep if inrange(AGEGR5, 1, 10)  
foreach var in INCMC INCMHSD{
	foreach grp in immig nonimmig{
		tab `var' abscat1 if `grp' == 1 [aw= WGHT_PER], col matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "analytical weighted summary statistics.xlsx", sheet(`var'_`grp'_under60) modify
		putexcel A1 = "Frequency table of absence categories by `var' under age 60"
		putexcel A2 = "`var' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}



**** 3c. weighted statistics: importance weights
clear all
use "C:\Users\xx3yu\OneDrive - University of Waterloo\Stata\summary stats\sample for summary statistics.dta", clear 

** for the entire sample
foreach var in AGEGR5 cat_educ_4 TOTALCHDC CHDINFTC NO_WKPER NO_INT INCMC INCMHSD spouse_immig REGION NOCS2006_C10 NAICS2007_C16 {
	foreach grp in immig nonimmig{
		tab `var' abscat1 if `grp' == 1 [iw= WGHT_PER], col matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "importance weighted summary statistics.xlsx", sheet(`var'_`grp') modify
		putexcel A1 = "Frequency table of absence categories by `var'"
		putexcel A2 = "`var' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}
* age at the beginning of the first absence
forvalues i = 1(1)8{
	foreach grp in immig nonimmig{
		tab AGE_INT1BEG if `grp' == 1 & abscat1 == `i' [iw= WGHT_PER], matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "importance weighted summary statistics_age at the beginning of the first absence.xlsx", sheet(AGE_INT1BEG_abscat1=`i'_`grp') modify
		putexcel A1 = "Frequency table of absence categories by `var'"
		putexcel A2 = "AGE_INT1BEG abscat`i' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}


** income information of respondent age under 60
keep if inrange(AGEGR5, 1, 10)  
foreach var in INCMC INCMHSD{
	foreach grp in immig nonimmig{
		tab `var' abscat1 if `grp' == 1 [iw= WGHT_PER], col matcell(freq) matrow(names)
		matrix list freq
		matrix list names
		putexcel set "importance weighted summary statistics.xlsx", sheet(`var'_`grp'_under60) modify
		putexcel A1 = "Frequency table of absence categories by `var' under age 60"
		putexcel A2 = "`var' groups" B2 = "mat"  C2 = "childcare" D2 = "eldercare" E2 = "own illness" F2 = "mat and child" G2 = "any of unincluded obs in the 5 groups before" H2 = "any other abscences" I2 = "all other abscences"
		putexcel A3 = matrix(names) B3 = matrix(freq)
	}
}


**************************************************************
**** Step 4. Summary tables for at least 1 reason ****
**************************************************************

* table
* age group
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab AGEGR5 `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab AGEGR5 `var'1 if WH1_Q370_C01<. & immig==0
		}

* education
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab cat_educ_4 `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab cat_educ_4 `var'1 if WH1_Q370_C01<. & immig==0
		}		

* the number of children raised by the respondent
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab TOTALCHDC `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab TOTALCHDC `var'1 if WH1_Q370_C01<. & immig==0
		}	
		
* the number of children live with the respondent full-time
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab CHDINFTC `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab CHDINFTC `var'1 if WH1_Q370_C01<. & immig==0
		}	

* the number of work periods
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab NO_WKPER `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab NO_WKPER `var'1 if WH1_Q370_C01<. & immig==0
		}	

* the number of work absences
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab NO_INT `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab NO_INT `var'1 if WH1_Q370_C01<. & immig==0
		}	

* personal income
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab INCMC `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab INCMC `var'1 if WH1_Q370_C01<. & immig==0
		}	
	
* household income
display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab INCMHSD `var'1 if WH1_Q370_C01<. & immig==1 
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab INCMHSD `var'1 if WH1_Q370_C01<. & immig==0
		}	
		
*Rename the absence variables to lowercase with corrected numbers for ease of next rowtotal*
forvalues i=1/5{
	forvalues j=1/9{
		gen  wh`i'_q370_c`j'a=1 if  WH`i'_Q370_C0`j'==1
		}
	forvalues j=10/17{
		gen  wh`i'_q370_c`j'a=1 if  WH`i'_Q370_C`j'==1
		}	
	}

*Generate variable that tells us # reasons for absence given (at each work period 1/5), missing are zeros here*
forvalues i=1/5{
		egen numreasa`i'= rowtotal(wh`i'_q370_c*)
		}
tab numreasa1 immig
*Generate total # reasons for absences (of any type) across all five potential work periods, missing coded missing here*
forvalues i=1/5{
	egen reastot`i'=rowtotal(ownill`i' matpat`i' child`i' elder`i' pers`i' seas`i' temp`i' lack`i' quit`i' fired`i' busend`i' moved`i' chjob`i' schl`i' retire`i' oth`i' trav`i')
	replace reastot`i'=. if WH`i'_Q370_C01>=.
	}

*Generate total number of absences, out of 5, for which we had any reasons given, abs`i' will tell us if we had an absence (with reason given) in i *
forvalues i=1/5{
	gen abs`i'=0 if WH`i'_Q370_C01<.
	replace abs`i'=1 if inrange(reastot`i', 1, 17)
	}
egen abstot=rowtotal(abs*)
replace abstot=. if abstot==0

tab abstot immig
*Generate indicator variable=1 if any of the reasons given for absences were reason X, in any period, missing values are . *
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
	gen `var'any=0 if abstot!=.
	replace `var'any=1 if inrange(`var'all, 1, 5)
	}
	
*Generate variable that tells us the porportion of times reason X is given out of total number of absence spells (up to 5) in which we had any reasons given*
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
	gen `var'pct=`var'all/abstot if inrange(abstot, 1, 5) 
	}

display " Tabulate if at least one reason for 1st absence was X, if had a reason for 1st absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab `var'1 if WH1_Q370_C01<. & immig==1 [aw= WGHT_PER]
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab `var'1 if WH1_Q370_C01<. & immig==0 [aw= WGHT_PER]
		}

display " Tabulate if at last one reason for any absence was X, across 5 potential absences, if had a reason for any absence, by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab `var'any if inrange(abstot, 1, 5) & immig==1 [aw= WGHT_PER]
		}
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab `var'any if inrange(abstot, 1, 5) & immig==0 [aw= WGHT_PER]
		}

display " Tabulate proportion of times reason X was given out of total absence periods (max 5 absences), by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab `var'pct if inrange(abstot, 1, 5) & immig==1 [aw= WGHT_PER]
		}
	foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		tab `var'pct if inrange(abstot, 1, 5) & immig==0 [aw= WGHT_PER]
		}

display " Mean proportion of times reason X was given out of total absence periods (max 5 absences), by immigrant status"
foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		sum `var'pct if inrange(abstot, 1, 5) & immig==1 [aw= WGHT_PER]
		}
	foreach var in ownill matpat child elder pers seas temp lack quit fired busend moved chjob schl retire oth trav{
		sum `var'pct if inrange(abstot, 1, 5) & immig==0 [aw= WGHT_PER]
		}

log close
