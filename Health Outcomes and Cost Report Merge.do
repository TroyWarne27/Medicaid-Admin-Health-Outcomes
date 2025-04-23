clear

 cd "C:\Users\twarne\OneDrive\Medicaid Project\Health Outcomes Data\"
 
 use "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2019\Cost_Report_2019.dta"

 drop rpt_num
 
 
 count if medicaidunpaid != 0 & stateagencyunpaid == 0
 
 drop if admintotal == 0
 
 drop if medicaredays == 0
 

 
 gen admintotal_abs = abs(admintotal)
 
 gen publicins_days = medicaiddays + medicaredays
 
gen totaladmin1 = admintotal_abs + medrecords

drop admintotal

drop admintotal_abs

rename totaladmin1 admintotal

gen medicare_unpaid = medicarebaddebt_allow - medicarebaddebt_reimb


 
 gen pubins_unpaid = (stateagencyunpaid + medicare_unpaid)

 drop socialservice
 
 drop state
  
 drop inpatientrev
 
 drop outpatientrev
 
 drop if provider_type > 1
 
 drop rpt_startdate
 
 drop rpt_enddate
 
 drop compenent_name 
 
 drop medicaidcharges
 
 drop fiscalyear
  
 drop zipcode
 
 drop Totalbaddebt
 
 drop medicarebaddebt_reimb
 
 drop provider_type
 
 drop adminsalaries_contract_s3
  
 drop adminsalaries_s3
 
 drop socialservicesalaries
 
 drop city
 
 drop county

 rename values200001_02100_00100 control_type
 

 
 drop CBSA_num
 

 
 gen adminperday = admintotal/publicins_days

 collapse (firstnm) control_type (sum) adminsalaries totalrev medicaidunpaid stateagencyunpaid medicaidrev medicaidcosts medicare_unpaid pubins_unpaid CMSuncompensatedcare publicins_days admintotal adminperday , by (CCN_num)
 
  gen non_profit = 0
 
 replace non_profit = 1 if control_type == "1" | control_type == "2"
 
 gen  for_profit = 0
 
 replace for_profit = 1 if control_type == "2" | control_type == "3" | control_type == "4" | control_type == "5" | control_type == "6"
 
 gen gov = 0
 
 replace gov = 1 if control_type == "7" | control_type == "8" | control_type == "9" | control_type == "10" | control_type == "11" | control_type == "12" | control_type == "13"
	
	gen revenuesize = 0
 
 _pctile totalrev, percentiles(20 40 60 80)
 
 replace revenuesize = 1 if totalrev <= `r(r1)'

  replace revenuesize = 2 if totalrev >= `r(r1)' & totalrev <= `r(r2)'
  
  replace revenuesize = 3 if totalrev >= `r(r2)' & totalrev <= `r(r3)'
  
  replace revenuesize = 4 if totalrev >= `r(r3)' & totalrev <= `r(r4)'
  
  replace revenuesize = 5 if totalrev >= `r(r4)'
	
  merge 1:1 CCN_num using HealthOutcomeFinal.dta
  
  keep if _merge == 3
  
 drop _merge
 
 replace state2 = state1 if missing(state2) 

 replace zipcode2 = zipcode1 if missing(state2) 
 
 rename zipcode2 zipcode

drop state1

drop zipcode1

drop if state2 == "PR"

drop if state2 == "VI"

drop if state2 == "GU"

drop if state2 == "MP"

 
 replace countyname = "Saint Louis1" if countyname == "Saint Louis" & state2 == "MN"
 
 replace countyname = "Saint Louis City" if countyname == "Saint Louis" & state2 == "MO"

 replace countyname = "STE Genevieve" if countyname == "Sainte Genevieve" & state2 == "MO"
 
 merge m:m countyname using "C:\Users\twarne\OneDrive\Medicaid Project\UrbanRural Dummy\PctUrbanRual_County.dta"
 

 

****rename state2 state


drop if _merge == 2


sort _merge

encode state2, gen(state_n)
 
 
save HealthOutcomeFinalMerged.dta, replace
 
