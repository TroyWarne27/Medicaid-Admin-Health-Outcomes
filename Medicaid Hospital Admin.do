
clear

forvalues j = 15(1)20 {

cd "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\20`j'"

use Cost_Report_20`j'.dta

rename values200001_02100_00100 control_type



gen zipcode2 = substr(zipcode,1,5)



gen admintotal2 = abs(admintotal) + medrecords

drop admintotal

rename admintotal2 admintotal

 drop rpt_num
 
 drop medrecords
 
 drop socialservice

 drop inpatientrev
 
 drop outpatientrev
 
 drop if provider_type > 1
 
 drop rpt_startdate
 
 drop rpt_enddate
  
 drop medicaidcharges
 
 drop compenent_name 
 

 
 drop zipcode
 


 
 drop provider_type
 
 drop adminsalaries_contract_s3
  
 drop adminsalaries_s3
 
 drop socialservicesalaries
 
 drop city
 
 drop county
 
 drop CBSA_num
 
 collapse (firstnm) state fiscalyear control_type zipcode2 (sum) adminsalaries totalrev medicaidrev medicaidcosts medicaidunpaid stateagencyunpaid medicarebaddebt_reimb CMSuncompensatedcare medicaredays medicaiddays admintotal, by (CCN_num)

 


 
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
  
  save Cost_Report_Limited_20`j'.dta, replace
  
  
}

clear 

cd "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\Hospital Medicaid Admin Data"

use "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2015\Cost_Report_Limited_2015.dta"

append using "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2016\Cost_Report_Limited_2016.dta"

append using "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2017\Cost_Report_Limited_2017.dta"

append using "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2018\Cost_Report_Limited_2018.dta"

append using "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2019\Cost_Report_Limited_2019.dta"

append using "C:\Users\twarne\OneDrive\Medicaid Project\Hospital Cost Report Data\2020\Cost_Report_Limited_2020.dta"

save Hospital_Cost_Report_Master.dta, replace



merge m:1 state fiscalyear using "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\FinalMerge\MedicaidAdminFinal.dta"



keep if _merge == 3

drop _merge

merge m:m zipcode2 using "C:\Users\twarne\OneDrive\Medicaid Project\UrbanRural Dummy\Zipcode RUCA\Urban_Zipcode.dta"

drop if _merge == 2

drop _merge

save Medicaid_Hospital_Admin.dta, replace



