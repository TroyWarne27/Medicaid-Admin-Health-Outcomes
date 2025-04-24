clear

ssc install statastates, replace

/* Loop for each Fiscal Year */
forvalues j = 15(1)20 {

cd "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\20`j'"

/* One sheet per state, labeled by number, loop over each sheet */
	forvalues i = 51(-1)1 {
	
	import excel using MedicaidAdmin`j'.xlsx, 	sheet(ADM`i') cellrange(A3:A3) clear
	
	local state = A
	
	
	import excel using MedicaidAdmin`j'.xlsx, sheet(ADM`i') cellrange(A7:D63) firstrow clear
	
	gen str20 state = "`state'"
	
		if `i' ==51 {
	
		save MedicaidAdmin`j'.dta, replace
	
		}
	
		else {
	
		append using MedicaidAdmin`j'.dta
		save MedicaidAdmin`j'.dta, replace
	
		}
	
	
	}

/* Keep Relevant Categories */
	gen keepvar = 0 
	replace keepvar = 1 if ServiceCategory == "MMIS - Inhouse Activities"
	replace keepvar = 1 if ServiceCategory == "MMIS - Private Sector"
	replace keepvar = 1 if ServiceCategory == "Total Net Expenditures"
	
	keep if keepvar ==1

	drop keepvar

/* Convert to Wide Dataset */
encode ServiceCategory, gen (catnum)
reshape wide TotalComputable FederalShare StateShare ServiceCategory, i(state) j(catnum) 
gen fiscalyear = 20`j'

rename TotalComputable1 MMISinhouse
drop FederalShare1
drop StateShare1

rename TotalComputable2 MMISprivate
drop FederalShare2
drop StateShare2

rename TotalComputable3 Totalmedicaidadmin
rename FederalShare3 FederalShare
rename StateShare3 StateShare

drop ServiceCategory1
drop ServiceCategory2
drop ServiceCategory3





/* Use statastates to get state_abbrev, clean output for DC */

statastates, name(state)

replace state_abbrev = "DC" if state == "DIST. OF COL."


drop if state == "DISTRICT OF COLUMBIA"

drop _merge

drop FederalShare StateShare state_fips state

rename state_abbrev state

cd "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\FinalMerge"

 

save MedicaidAdminFinal`j'.dta, replace

}

clear

cd "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\FinalMerge"

/* Append all Fiscal Year Files */

use MedicaidAdminFinal15

append using MedicaidAdminFinal16

append using MedicaidAdminFinal17

append using MedicaidAdminFinal18

append using MedicaidAdminFinal19

append using MedicaidAdminFinal20

/* Add data for enrollment to normalize Medicaid Expenditures and FMAP to control for influence of Federal dollars*/

merge m:m state fiscalyear using "C:\Users\twarne\OneDrive\Medicaid Project\FMAP Control\FMAPcontrol.dta"

drop _merge

merge m:m state fiscalyear using "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Enrollment\medicaidenrollmentfinal.dta"

drop _merge

save MedicaidAdminFinal.dta, replace
