
#delimit;

***ssc install estout, replace;

clear; 
 
cd "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\Hospital Medicaid Admin Data";

use Medicaid_Hospital_Admin.dta;

drop if fiscalyear == 2020;

***drop if provider_type > 1;
 
gen  admintotal2 = admintotal;

replace admintotal2 = abs(adminsalaries) if admintotal == 0;

gen adminreplace = 0;

replace adminreplace = 1 if admintotal == 0 & admintotal2 != 0;

ttest admintotal2, by(adminreplace)

ttest admintotal == admintotal2

stop 

drop if CCN_num == "030010" & fiscalyear == 2015;

drop if missing(urban);

drop if totalrev == 0;




gen medicaidcosts2 = abs(medicaidcosts);

drop medicaidcosts;

rename medicaidcosts2 medicaidcosts;

gen medicaidrev2 = abs(medicaidrev);

drop medicaidrev;

rename medicaidrev2 medicaidrev;

gen medicaidnet = medicaidcosts - medicaidrev;
 
gen medicaidunpaid2 = medicaidnet;

replace medicaidunpaid2 = 0  if medicaidnet < 0;

drop medicaidunpaid;

rename medicaidunpaid2 medicaidunpaid;

gen adminzero = 0;

replace adminzero = 1 if admintotal == 0;

***gen missingother = 0 ;

***replace missingother = 1 if medicaidrev == 0 | medicaidcosts == 0 | CMSuncompensatedcare == 0 | medicarebaddebt_reimb | medicaredays == 0  ;

***tab adminzero missingother;






preserve;

drop if medicaidcosts == 0 & medicaidrev != 0;

drop if CCN_num == "030010" & fiscalyear == 2015;

gen uncomp2 = CMSuncompensatedcare / 1000000;
gen medicaidunpaid2 = medicaidnet/ 1000000;

graph bar (mean) medicaidunpaid2 uncomp2, over(fiscalyear)
 title(Average Hospital Unpaid Costs)
 ytitle(Costs in Millions of $)
 legend(label(1 "Net Medicaid Unpaid Costs") label(2 "Uncompensated Care"));
graph save Average_Unpaid_Medicaid.gph,replace;
graph export "Average_Unpaid_Medicaid.eps", as(eps) replace;

tabstat medicaidcosts medicaidrev, by(fiscalyear) statistics(mean max min median);


restore;



preserve;

drop if CCN_num == "030010" & fiscalyear == 2015;

collapse (sum)  CMSuncompensatedcare medicaidnet, by (fiscalyear);



gen uncomp2 =  CMSuncompensatedcare/1000000000;

gen medicaidnet2 = medicaidnet/1000000000;



graph bar medicaidnet2 uncomp2, over(fiscalyear)
 title(Hospital Costs Unpaid by Medcaid)
 ytitle(Total Costs in Billions of $)
 legend(label(1 "Net Medicaid Unpaid Costs") label(2 "Uncompensated Care"))
 bar(1, color(green)) bar(2, color(red));
graph save Total_Unpaid_Medicaid.gph, replace;
graph export "Total_Unpaid_Medicaid.eps", as(eps) replace;

restore;



preserve;

gen BIRest = .085 * totalrev;

collapse (sum) admintotal BIRest, by(fiscalyear);

gen BIRest1 = BIRest/1000000000;

gen admintotal1 = admintotal/1000000000;

graph bar (sum) BIRest1 admintotal1, over(fiscalyear)
 title(BIR Estimates vs Limited Administrative Cost Estimates)
 ytitle(Costs in Billions of $)
 legend(label(1 "BIR Estimates") label(2 "Limited Admin Estimates"));
graph save Estimate_compare.gph,replace;
graph export "Estimate_compare.eps", as(eps) replace;


restore;




gen MMISspend = abs(MMISinhouse) + abs(MMISprivate);










gen MMISspend1 = MMISspend + 1;

gen log_MMIS = log(MMISspend1);

gen medicaidunpaid1 = medicaidnet + 1;

gen log_unpaid = log(medicaidunpaid1);

gen uncomp = CMSuncompensatedcare + 1;

gen log_uncomp1 = log(uncomp);

gen medadmin = Totalmedicaidadmin + 1;

gen log_medadmin = log(medadmin);

gen admintotal1 = admintotal + 1;

gen log_hosadmin = log(admintotal1);



preserve;



reg admintotal Totalmedicaidadmin CMSuncompensatedcare i.fiscalyear i.revenuesize, vce(robust);
estimates store lvl_OLS_unctrl;

reg admintotal Totalmedicaidadmin CMSuncompensatedcare i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store lvl_OLS_ctrl;

reg medicaidnet Totalmedicaidadmin CMSuncompensatedcare i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store lvl_OLS_ctrl_unpaid;

esttab  lvl_OLS_unctrl lvl_OLS_ctrl lvl_OLS_ctrl_unpaid
using OLS_lvl.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Total Medicaid and Hospital Admin Spending)
scalars(N r2 )
replace;

reg admintotal MMISspend CMSuncompensatedcare i.fiscalyear i.revenuesize, vce(robust);
estimates store lvl_OLS_unctrl_mmis;

reg admintotal MMISspend CMSuncompensatedcare i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store lvl_OLS_ctrl_mmis;

reg medicaidnet MMISspend CMSuncompensatedcare i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store lvl_OLS_ctrl_mmis_unpaid;

esttab lvl_OLS_unctrl_mmis lvl_OLS_ctrl_mmis lvl_OLS_ctrl_mmis_unpaid
using OLS_lvl_MMIS.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(MMIS Medicaid Spending and Hospital Admin Spending)
scalars(N r2 )
replace;

restore;



reg log_hosadmin log_medadmin log_uncomp i.fiscalyear i.revenuesize;
estimates store log_OLS_unctrl;

reg log_hosadmin log_medadmin log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store log_OLS_ctrl;

reg log_hosadmin log_MMIS log_uncomp i.fiscalyear i.revenuesize;
estimates store log_OLS_unctrl_MMIS;

reg log_hosadmin log_MMIS log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store log_OLS_ctrl_MMIS;


esttab log_OLS_ctrl log_OLS_ctrl_MMIS  
using OLS_log_MMIS.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Log Medicaid Spending and Log Hospital Administrative Spending)
scalars(N r2 )
replace;

reg log_unpaid log_medadmin log_uncomp i.fiscalyear i.revenuesize;
estimates store log_OLS_unctrl_unpaid;

reg log_unpaid log_medadmin log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store log_OLS_ctrl_unpaid;

reg log_unpaid log_MMIS log_uncomp i.fiscalyear i.revenuesize;
estimates store log_OLS_unctrl_unpaid_MMIS;

reg log_unpaid log_MMIS log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store log_OLS_ctrl_unpaid_MMIS;

esttab  log_OLS_ctrl_unpaid log_OLS_ctrl_unpaid_MMIS
using OLS_log_medadmin_unpaid.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Log Medicaid Admin Spending and Log Net Unpaid Medicaid Costs)
scalars(N r2 )
replace;


gen Medadmin_enr = Totalmedicaidadmin/totalenrollment; 

gen MMIS_enr = MMISspend /totalenrollment;


reg admintotal Medadmin_enr log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store medadmin_enr_admin;

reg medicaidnet Medadmin_enr log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store medadmin_enr_unpaid;

gen Medadmin_enr_log = log(Medadmin_enr) + 1;

gen MMIS_enr_log = log(MMIS_enr);

reg log_hosadmin Medadmin_enr_log log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store medadmin_enr_admin_log;

reg log_hosadmin MMIS_enr_log log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store MMIS_enr_admin_log;

reg log_unpaid Medadmin_enr_log log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store medadmin_enr_unpaid_log;

reg log_unpaid MMIS_enr_log  log_uncomp i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store MMIS_enr_unpaid_log;

esttab medadmin_enr_admin_log medadmin_enr_unpaid_log MMIS_enr_admin_log MMIS_enr_unpaid_log
using OLS_log_MMIS_enr.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Log Medicaid Admin Spending per Enrollee and Log of Hospital Admin and Unpaid Costs)
scalars(N r2 )
replace;

 

gen nomeddays = 0;

replace nomeddays = 1 if medicaiddays == 0;

estpost tab nomeddays revenuesize;

esttab using "revsize_meddays.tex", unstack replace; 



gen missingother = 0;

replace missingother = 1 if admintotal == 0 |  medicarebaddebt_reimb == 0 | CMSuncompensatedcare == 0 |  medicaredays == 0;

estpost tab missingother nomeddays;

esttab using "missingother_meddays.tex",  unstack replace; 

gen nomedstats = 0;

replace nomedstats = 1 if medicaidrev == 0 & medicaidcosts == 0;

estpost tab nomedstats nomeddays;

esttab using "medstats_meddays.tex", unstack replace; 





sort state fiscalyear ;

egen stateyeargroup = group(state fiscalyear);

egen meddaystot = total(medicaiddays), by(stateyeargroup);

gen admintotal_adj = admintotal/medicaiddays;

gen uncomp_adj = CMSuncompensatedcare /medicaiddays;

gen stateadmin_adj = Totalmedicaidadmin / meddaystot;

gen unpaid_adj = medicaidnet / medicaiddays;

gen logadm_adj = log(admintotal_adj);

gen logstate_adj = log(stateadmin_adj);

gen loguncomp_adj = log(uncomp_adj);

gen logunpaid_adj = log(unpaid_adj);




reg admintotal_adj stateadmin_adj uncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store adj_admin_OLS;

heckman admintotal_adj stateadmin_adj uncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, select( nomedstats missingother i.revenuesize) twostep;
estimates store adj_admin_hckman;

reg logadm_adj logstate_adj loguncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store adj_admin_OLS_log;

heckman logadm_adj logstate_adj loguncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, select( nomedstats missingother i.revenuesize) twostep;
estimates store adj_admin_hckman_log;

esttab  adj_admin_OLS adj_admin_hckman adj_admin_OLS_log adj_admin_hckman_log
using adj_admin.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Medicaid Admin Spending per Day and Hospital Administrative Spending per Day)
scalars(N r2 )
replace;



reg unpaid_adj stateadmin_adj uncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store adj_unpaid_OLS;

heckman unpaid_adj stateadmin_adj uncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, select( nomedstats missingother i.revenuesize) twostep;
estimates store adj_unpaid_hckman;

reg logunpaid_adj logstate_adj loguncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, vce(robust);
estimates store adj_unpaid_OLS_log;

heckman logunpaid_adj logstate_adj loguncomp_adj i.fiscalyear i.revenuesize urban for_profit gov fmappercentage, select( nomedstats missingother i.revenuesize) twostep;
estimates store adj_unpaid_hckman_log;

esttab adj_unpaid_OLS adj_unpaid_hckman adj_unpaid_OLS_log adj_unpaid_hckman_log
using adj_unpaid.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Medicaid Admin Spending per Day and Hospital Admin/Unpaid Costs per Day)
scalars(N r2 )
replace;





 

gen admintotal2 = admintotal/ 1000000;

gen medicaidnet2 = medicaidnet/ 1000000;

gen Totalmedicaidadmin2 = Totalmedicaidadmin/ 1000000;

gen MMISspend2 = MMISspend /1000000;

gen CMSuncompensatedcare2 = CMSuncompensatedcare /1000000;

gen medicaiddays2 = medicaiddays/ 100;

gen meddaystot2 = meddaystot/ 1000;




 
estpost tabstat admintotal2 medicaidnet2 medicaiddays2 CMSuncompensatedcare2, by(fiscalyear)
c(stat) stat(mean sum sd min max n);

esttab using Hospital_summary.tex, cells( "mean(fmt(%13.2fc)) sum(fmt(%13.2fc)) sd(fmt(%13.2fc)) min(fmt(%13.2fc)) max(fmt(%13.2fc)) count(fm(%13.0fc))")
 nonumber  nomtitle nonote noobs label booktabs collabels( "Mean" "Total" "SD" "Min" "Max" "N") replace;
 
 preserve;
 
 collapse (firstnm) fiscalyear (mean) Totalmedicaidadmin2 MMISspend2 meddaystot2, by(stateyeargroup);
 
 estpost tabstat Totalmedicaidadmin2 MMISspend2 meddaystot2, by(fiscalyear)
c(stat) stat(mean sum sd min max n);

esttab using State_summary.tex, cells( "mean(fmt(%13.2fc)) sum(fmt(%13.2fc))sd(fmt(%13.2fc)) min(fmt(%13.2fc)) max(fmt(%13.2fc)) count(fmt(%13.0fc))")
 nonumber  nomtitle nonote noobs label booktabs collabels( "Mean" "Total" "SD" "Min" "Max" "N") replace;



restore;

stop

clear;

cd "C:\Users\twarne\OneDrive\Medicaid Project\Medicaid Admin Data\FinalMerge";

use MedicaidAdminFinal.dta;

preserve;

gen MMISspend = abs(MMISinhouse) + abs(MMISprivate);

collapse (sum) Totalmedicaidadmin MMISspend, by(fiscalyear);

gen medicaidadm = Totalmedicaidadmin/1000000000;

gen techspend = MMISspend/1000000000;


graph bar (mean) medicaidadm techspend, over(fiscalyear)
 title(Average Medicaid Admin Spending)
 ytitle(Costs in Billions of $)
 legend(label(1 "Average Medicaid Admin Spending") label(2 "MMIS Spending"));
graph save Total_Medicaid_Admin.gph,replace;
graph export "Total_Medicaid_Admin.eps", as(eps) replace;


restore;


estpost tabstat Totalmedicaidadmin2 MMISspend2, by(fiscalyear)
c(stat) stat(mean sd min max n);

esttab using State_summary.tex, cells( "mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count(fmt(%13.0fc))")
 nonumber  nomtitle nonote noobs label booktabs collabels( "Mean" "SD" "Min" "Max" "N") replace;

