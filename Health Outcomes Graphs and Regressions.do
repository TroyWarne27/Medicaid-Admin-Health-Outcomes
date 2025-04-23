
#delimit;

clear; 

cd "C:\Users\twarne\OneDrive\Medicaid Project\Health Outcomes Data";



***ssc install estout, replace;
***ssc install tabout, replace;

use HealthOutcomeFinalMerged.dta;

gen pubins_unpaid1 = pubins_unpaid/publicins_days;

rename pubins_unpaid pubins_unpaid_unadj;

rename pubins_unpaid1 pubins_unpaid;


gen medicaidunpaidpercent = medicaidunpaid/medicaidcosts;

summarize medicaidunpaidpercent;


drop if admintotal == 0;

 

 preserve; 
 
 drop if readmission == .;
 
 reg readmission adminperday pubins_unpaid i.revenuesize;
 estimates store readm_OLS;
 

 
 xtset state_n;
 
 xtreg readmission adminperday pubins_unpaid i.revenuesize, fe; 
 estimates store readm_FE;
 
 xtreg readmission adminperday pubins_unpaid i.revenuesize urban, fe; 
 estimates store readm_FE_urb;
 
  xtreg readmission adminperday pubins_unpaid i.revenuesize urban gov for_profit, fe; 
  estimates store readm_FE_urb_ctrl;
 
 reg readmission adminperday pubins_unpaid i.revenuesize i.state_n urban gov for_profit;
 estat vif;
  

 probit readmissioncompare adminperday pubins_unpaid i.revenuesize i.state_n urban gov for_profit;
 estimates store readm_probit;
 
 margins, dydx(adminperday pubins_unpaid) post;
 estimates store probit_margins;
 
  probit readmissioncompare adminperday pubins_unpaid i.revenuesize urban gov for_profit;
 estimates store readm_probit_nostate;
 
 margins, dydx(adminperday pubins_unpaid) post;
 estimates store probit_margins_nostate;
 

 esttab probit_margins probit_margins_nostate
using probmargins_results.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Marginal Effects on Probability of Being Worse than Average in Unplanned Readmissions)
scalars(N r2 r2_p )
replace;
 
 esttab readm_OLS readm_FE readm_FE_urb readm_FE_urb_ctrl
using readm_results.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Hospital Administrative Costs on Rates of Unplanned Readmissions)
scalars(N r2 )
replace;
 
  esttab readm_probit readm_probit_nostate
using readm_results.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Hospital Administrative Costs on Rates of Unplanned Readmissions)
scalars(N r2 r2_p )
replace;

 restore;
 
 preserve;
 
 drop if missing(Leftpercent);
 xtset state_n;
 
 xtreg Leftpercent adminperday pubins_unpaid i.revenuesize for_profit gov urban, fe;
 estimates store ED_leftpercent;
 
  xtreg Leftpercent admintotal pubins_unpaid i.revenuesize i.EDVolumeScore for_profit gov urban, fe;
 estimates store ED_leftpercent_vol_unadj;
 
 xtreg Leftpercent adminperday pubins_unpaid i.revenuesize i.EDVolumeScore for_profit gov urban, fe;
 estimates store ED_leftpercent_vol;
 
  esttab ED_leftpercent ED_leftpercent_vol ED_leftpercent_vol_unadj
using leftpercent_results.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Hospital Administrative Costs on Percentage of People Leaving ER without being seen)
scalars(N r2 )

replace;



 restore;
 
 preserve;
 
 drop if missing(MedianWaitingTime);
 
 xtset state_n;
 
 xtreg MedianWaitingTime adminperday pubins_unpaid i.revenuesize for_profit gov urban, fe;
 estimates store ED_waiting;

 drop if missing(EDvolume);
 
 xtreg MedianWaitingTime adminperday pubins_unpaid i.revenuesize i.EDVolumeScore for_profit gov urban, fe;
 estimates store ED_waiting_vol;
 
 xtreg MedianWaitingTime admintotal pubins_unpaid_unadj i.revenuesize i.EDVolumeScore for_profit gov urban, fe;
 estimates store ED_waiting_unadj;
 
 reg MedianWaitingTime adminperday pubins_unpaid i.revenuesize i.EDVolumeScore i.state_n for_profit gov urban;
 estat vif;
 
 esttab ED_waiting ED_waiting_vol ED_waiting_unadj
using ED_waitingresults.tex,
tex
se
star(* 0.10 ** 0.05 *** 0.01)
title(Hospital Administrative Costs on Percentage of People Leaving ER without being seen)
scalars(N r2 )
replace;

 restore;
 
 estpost tab state2 readmissioncompare;
 
 esttab using "readmitcomparetable.tex", cells(colpct(fmt(2))) unstack noobs replace;

 
preserve; 

gen admintotal1 = admintotal / 1000000;

gen pubins_unpaid_unadj1 = pubins_unpaid_unadj/ 1000000;

gen totalrev1 = totalrev/ 1000000;

estpost tabstat admintotal1 pubins_unpaid_unadj1 totalrev1,
 c(stat) stat(sum mean sd min max n);
 
 esttab using Unadj_summary.tex, cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber
  nomtitle nonote noobs booktabs collabels("Sum" "Mean" "SD" "Min" "Max" "N") replace;
  
graph bar (mean) pubins_unpaid_unadj1 admintotal1 totalrev1, 
 title("Average Hospital Characteristics")
 ytitle("Amounts in Millions of $")
legend(label(1 "Total Unpaid Costs") label(2 "Total Admin Costs") label(3 "Total Revenue"));
graph save Average_Char.gph, replace;
graph export "Average_Charactertics.eps", as(eps) replace;
  
  restore;
  
  estpost tabstat adminperday pubins_unpaid publicins_days,
 c(stat) stat(sum mean sd min max n);
 
 esttab using adj_summary.tex, cells("sum(fmt(%13.0fc)) mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count") nonumber
  nomtitle nonote noobs label booktabs collabels("Sum" "Mean" "SD" "Min" "Max" "N") replace;
  
  graph bar (mean) adminperday pubins_unpaid, over(revenuesize)
 title("Average Adjusted Hospital Characteristics by Revenue Size", size(medium))
 ytitle("Amounts in Millions of $", size(small))
 bargap(.5)
 legend(label(1 "Admin Spending Per Day") label(2 "Unpaid Costs Per Day"));
graph save Average_Char_adj.gph, replace;
graph export "Average_Charactertics_adjusted.eps", as(eps) replace;

 estpost tabstat readmission Leftpercent MedianWaitingTime,
 c(stat) stat(mean sd min max n);
 
 esttab using Healthoutcomes_summary.tex, cells( "mean(fmt(%13.2fc)) sd(fmt(%13.2fc)) min max count")
 nonumber  nomtitle nonote noobs label booktabs collabels( "Mean" "SD" "Min" "Max" "N") replace;

  
  gen control2 = 0;
  
  replace control2 = 1 if non_profit == 1;
  replace control2 = 2 if for_profit == 1;
  replace control2 = 3 if gov == 1;
  

  
 estpost tab control2 revenuesize;
 
 esttab using Control1_summary.tex, cells(colpct(fmt(2))) unstack noobs replace;
 
 estpost tab urban revenuesize;
 
 esttab using Control2_summary.tex, cells(colpct(fmt(2))) unstack noobs replace;
