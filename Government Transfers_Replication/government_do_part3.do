/* *************************************************************************** */
/*                This do.file replicates the paper:                           */
/*			      "Government Transfers and Political Support"                 */
/*			      by Marco Manacorda, Edward Miguel, and Andrea Vigorito       */
/*			      published in American Economic Journal, 2011                 */
/* *************************************************************************** */


clear
set mem 300m
set seed 1234567
cap log using government_do_part3

/* Change this to reflect local working directory */

cd "C:\Users\Elisa Cascardi\Desktop\Data Replication Sets\Government Transfers_Replication"
u mccrary, replace


***********
capture drop X Y r0 fh se_
DCdensity ind_r, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) graphname(DCdensity_example.eps)

capture drop low hi tot
g low=fh-1.96*se_
g hi=fh+1.96*se_
 
replace Xj=. if Xj<$min
replace Xj=. if Xj>$max
replace Yj=. if Yj>100

egen tot=sum(Y)
egen pct=pctile(Yj), p(99)
replace Yj=. if Yj>pct
*for any Y fh hi low: replace X=X/tot


gr twoway (scatter Yj Xj if Xj>-.02 & Xj<.02, msymbol(circle_hollow) mcolor(gray))           ///
      (line fh  r0 if r0< 0 & r0>-.02, lcolor(black) lwidth(medthick))   ///
        (line fh r0 if r0>0 & r0<.02, lcolor(black) lwidth(medthick))   ///
          (line hi r0 if r0< 0 & r0>-.02, lcolor(black) lwidth(vthin))              ///
            (line low r0 if r0< 0 & r0>-.02, lcolor(black) lwidth(vthin))              ///
              (line hi r0 if r0>0 & r0<.02, lcolor(black) lwidth(vthin))              ///
                (line low r0 if r0> 0 & r0<.02, lcolor(black) lwidth(vthin)),             ///
                  xline(0, lcolor(black)) legend(off) ylabe(5(5)25) yscale(range(4 25)) 
graph save "figure_Appendix.gph", replace
graph export figure_Appendix.png, as(png) replace

				  

*corrects for worst case scenario selection
