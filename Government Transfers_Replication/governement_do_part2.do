/* *************************************************************************** */
/*                This do.file replicates the paper:                           */
/*			      "Governemnt Transfers and Political Support"                 */
/*			      by Marco Manacorda, Edward Miguel, and Andrea Vigorito       */
/*			      published in American Economic Journal, 2011                 */
/* *************************************************************************** */

/* PART 2 */

cap log using government_do_part2

/* Change this to reflect local working directory */

cd "C:\Users\Elisa Cascardi\Desktop\Data Replication Sets\Government Transfers_Replication"
u conf_president, replace

global cov="i.sexo*edad i.sexo*edad2    i.sexo*ed i.sexo*ed2 i.casa_propria    i.tvcol i.auto i.year"
xi: reg conf_lb $cov 

predict pred_conf_lb


g conf_seguimiento=(hv196-1)/2 if hv196<9



xi: reg conf_s $cov
predict pred_conf_s



keep if ind_reest>=-.02 & ind_reest<=.02
xtile pct=ind_reest if ind_reest<0 , nq(40)
xtile pct1=ind_reest if ind_reest>=0 , nq(20)

replace pct=pct1+100 if ind_reest>=0
egen newind_r=mean(ind_reest), by(pct)
sort newind_r
drop if newind_r==.
g newtreat=newind_r<0





keep if prot==1
keep if sample==1


egen mpred_conf_lb=mean(pred_conf_lb), by(newind)
egen mpred_conf_seguimiento=mean(conf_seguimiento), by(newind)


set obs 21000
replace newind_r=0 if newind_r==. 
replace newtreat=0 if newtreat==. 
capture drop newind_r2
xi: reg conf_s newind_r* if  newind_r<0

capture drop tmp
predict tmp
g pred_s=tmp if newind_r<=0


xi: reg conf_s newind_r*   if  newind_r>0

set obs 22000
g a=1 if newind_r==.
replace newind_r=0 if newind_r==. 


capture drop tmp1
predict tmp1
replace pred_s=tmp1 if newind_r>=0 & pred_s==.
replace newtreat=1 if newtreat==. 
 

xi: reg pred_conf_lb i.newtreat*newind_r* if  newind_r<0

predict pred_lb
label var newind_r "Predicted income"
sort newind newtre
g count=100
scatter pred_lb pred_s mpred*  newind_r [aw=count], c(l l)   s(i i t O) legend(off) xline(0) lpattern(- l .) ylabel(0.2 (0.2) .8)
graph save "figure_5.gph", replace
graph export figure_5.png, as(png) replace



