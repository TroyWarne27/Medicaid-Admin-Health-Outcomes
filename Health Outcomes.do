clear 

cd "C:\Users\twarne\OneDrive\Medicaid Project\Health Outcomes Data"

import delimited using Unplanned_Hospital_Visits-Hospital.csv, varnames(1)

drop if score== "Not Available"

keep if measurename == "Rate of readmission after discharge from hospital (hospital-wide)"

drop measureid

drop phonenumber




drop city

drop address

drop facilityname 

gen str6 CCN_num = string(real(facilityid), "%06.0f")

drop facilityid

drop if CCN_num == "."

drop numberofpatients

drop numberofpatientsreturned

drop footnote

drop startdate

drop enddate

drop lowerestimate

drop higherestimate

rename score readmission

drop denominator 

drop measurename

rename zipcode zipcode1

rename state state1

save Hospital_readmission.dta, replace

clear 

cd "C:\Users\twarne\OneDrive\Medicaid Project\Health Outcomes Data"

import delimited using Timely_and_Effective_Care-Hospital.csv, varnames(1)

drop if score== "Not Available"

drop if sample== "Not Available"

gen keepvar = 0

replace keepvar = 1 if measurename == "Emergency department volume"
replace keepvar = 1 if measurename == "Average (median) time patients spent in the emergency department before leaving from the visit A lower number of minutes is better"
replace keepvar = 1 if measurename == "Left before being seen"

keep if keepvar == 1
gen str6 CCN_num = string(real(facilityid), "%06.0f")

gen str18 measure = "."

replace measure = "EDVolume" if measurename == "Emergency department volume"
replace measure = "MedianTimeSpent" if measurename == "Average (median) time patients spent in the emergency department before leaving from the visit A lower number of minutes is better"
replace measure = "Left" if measurename == "Left before being seen"


drop measurename

drop facilityid

drop if CCN_num == "."

drop measureid

drop phonenumber




drop city

drop address

drop facilityname 

drop footnote

drop startdate

drop enddate

rename zipcode zipcode2

rename state state2

drop condition 

drop keepvar

encode measure, generate(measureid)

drop measure

reshape wide score sample, i(CCN_num) j(measureid)

drop sample1

rename score1 EDvolume

rename score2 Left

rename score3 MedianWaitingTime

destring Left, replace

destring sample2, replace

destring MedianWaitingTime, replace

gen Leftpercent = Left/sample2

drop sample2

drop sample3

save ED_Outcomes.dta, replace

merge 1:1 CCN_num using Hospital_readmission.dta, nogen

destring readmission, replace

gen readmissioncompare = 0

replace readmissioncompare = 1 if comparedtonational == "Worse Than the National Rate"

drop Left

gen EDVolumeScore = 0 

replace EDVolumeScore = 1 if EDvolume == "low"
replace EDVolumeScore = 2 if EDvolume == "medium"
replace EDVolumeScore = 3 if EDvolume == "high"
replace EDVolumeScore = 4 if EDvolume == "very high"

save HealthOutcomeFinal.dta, replace


