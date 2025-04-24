clear 

/* Import Cost Report Files */
forvalues j = 15(1)20 {
cd "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\20`j'"

import delimited HOSP10_20`j'_NMRC.csv, stringcols (3 4)

rename v1 rpt_num
 
rename v2 wksht

rename v3 line

rename v4 column

rename v5 value

save Numeric_20`j'.dta, replace

clear 

cd "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\20`j'"

import delimited HOSP10_20`j'_ALPHA, stringcols (3 4)

rename v1 rpt_num
 
rename v2 wksht

rename v3 line

rename v4 column

rename v5 value

save Alphanum_20`j'.dta, replace


use Alphanum_20`j'.dta, clear

/* Trim Alphanumeric Data to Relevant Values for Analysis */

gen keep = 0
 replace keep = 1 if wksht == "S200001"  & line == "00300"  & column == "00100"
 replace keep = 1 if wksht == "S200001"  & line == "00200"  & column == "00100"
 replace keep = 1 if wksht == "S200001"  & line == "00200"  & column == "00200"
 replace keep = 1 if wksht == "S200001"  & line == "00200"  & column == "00300"
 replace keep = 1 if wksht == "S200001"  & line == "00300"  & column == "00300"
 replace keep = 1 if wksht == "S200001"  & line == "00200"  & column == "00400"
 replace keep = 1 if wksht == "S200001"  & line == "02000"  & column == "00100"
 replace keep = 1 if wksht == "S200001"  & line == "02000"  & column == "00200"
 replace keep = 1 if wksht == "S200001"  & line == "00300"  & column == "00200"
 replace keep = 1 if wksht == "S200001"  & line == "02100"  & column == "00100"
keep if keep ==1

/* Create Single Identifier for Category Values */
gen field_loc = lower(wksht) + "_" + line + "_" + column
drop wksht line column
reshape wide value, i(rpt_num) j(field_loc) string

save Alphanum_20`j'_revised.dta, replace

use Numeric_20`j'.dta, clear

/* Trim Numeric Data to Relevant Values for Analysis */

gen keep = 0
replace keep = 1 if wksht == "S200001"  & line == "00300"  & column == "00400"
replace keep = 1 if wksht == "S300001"  & line == "00100"  & column == "00600"
replace keep = 1 if wksht == "S300001"  & line == "00100"  & column == "00700"
replace keep = 1 if wksht == "S300002"  & line == "02700"  & column == "00400"
replace keep = 1 if wksht == "S300002"  & line == "02800"  & column == "00400"
replace keep = 1 if wksht == "S300002"  & line == "04200"  & column == "00400"
replace keep = 1 if wksht == "A000000"  & line == "00500"  & column == "00100"

	forvalues k = 0(1)9 {
	replace keep = 1 if wksht == "A000000"  & line == "0050`k'"  & column == "00700"
	}

	forvalues k = 10(1)99 {
	replace keep = 1 if wksht == "A000000"  & line == "005`k'"  & column == "00700"
	}

replace keep = 1 if wksht == "A000000"  & line == "01600"  & column == "00700"

replace keep = 1 if wksht == "A000000"  & line == "01700"  & column == "00700"

replace keep = 1 if wksht == "G200000"  & line == "02800"  & column == "00100"
replace keep = 1 if wksht == "G200000"  & line == "02800"  & column == "00200"
replace keep = 1 if wksht == "G200000"  & line == "02800"  & column == "00300"
replace keep = 1 if wksht == "S100000"  & line == "00200"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "00600"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "00700"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "00800"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "01900"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "02600"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "02700"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "02701"  & column == "00100"
replace keep = 1 if wksht == "S100000"  & line == "02900"  & column == "00100"

keep if keep == 1

/* Create Single Identifier for Category Values */

gen field_loc = lower(wksht) + "_" + line + "_" + column
drop wksht line column
reshape wide value, i(rpt_num) j(field_loc) string

save Numeric_20`j'_revised.dta, replace

/* Merge Alphanumeric and Numeric Data */
merge 1:1 rpt_num using Alphanum_20`j'_revised.dta, nogen
    sort rpt_num 
    duplicates report rpt_num
	
save Merged_20`j'.dta, replace

gen fiscalyear = 20`j'

/* Sum Adminstrative Expense Categories */
	forvalues k = 0(1)9 {
	
	capture gen valuea000000_0050`k'_00700 = 0
	
	rename valuea000000_0050`k'_00700 admin_cat`k'

	}

	forvalues k = 10(1)99 {
	
	capture gen valuea000000_005`k'_00700 = 0
	
	rename valuea000000_005`k'_00700 admin_cat`k'

	}

egen admintotal = rowtotal(admin_cat*)

/* Rename Cost Categories to be Readable */

rename valuea000000_00500_00100 adminsalaries

rename valuea000000_01600_00700 medrecords

rename valuea000000_01700_00700 socialservice

rename valueg200000_02800_00100 inpatientrev

rename valueg200000_02800_00200 outpatientrev

rename valueg200000_02800_00300 totalrev

rename values100000_00200_00100 medicaidrev

rename values100000_00600_00100 medicaidcharges

rename values100000_00700_00100 medicaidcosts

rename values100000_00800_00100 medicaidunpaid

rename values100000_01900_00100 stateagencyunpaid

rename values100000_02600_00100 Totalbaddebt

rename values100000_02700_00100 medicarebaddebt_reimb

rename values100000_02701_00100 medicarebaddebt_allow

rename values100000_02900_00100 CMSuncompensatedcare

rename values200001_02000_00100 rpt_startdate

rename values200001_02000_00200 rpt_enddate

rename values200001_00300_00300 CBSA_num

rename values200001_00300_00400 provider_type

rename values200001_00300_00100 compenent_name

rename values200001_00200_00400 county

rename values200001_00200_00300 zipcode

rename values200001_00200_00200 state

rename values200001_00300_00200 CCN_num

rename values200001_00200_00100 city

rename values300002_02700_00400 adminsalaries_s3

rename values300002_02800_00400 adminsalaries_contract_s3

rename values300002_04200_00400 socialservicesalaries

rename values300001_00100_00600 medicaredays

rename values300001_00100_00700 medicaiddays

rename values200001_02100_00100 control_type

drop admin_cat*

drop keep

save Cost_Report_20`j'.dta, replace


clear 

}
