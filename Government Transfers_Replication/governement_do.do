

/* *************************************************************************** */
/*                This do.file replicates the paper:                           */
/*			      "Governemtn Transfers and Political Support"                 */
/*			      by Marco Manacorda, Edward Miguel, and Andrea Vigorito       */
/*			      published in American Economic Journal, 2011                 */
/* *************************************************************************** */

/* PART 1 */

/* *************************************************************************** */
/* *********************    -FIRST STEPS-    ********************************* */
/* *************************************************************************** */

set more 1
clear 
set mem 10g
set matsize 800
program drop _all
cap log close
log using government_do, text replace


 /* Change this to reflect your working directory */
 
cd "C:\Users\Elisa Cascardi\Desktop\Data Replication Sets\Government Transfers_Replication"
u reg_panes, replace


capture program drop initial
program define initial
reg newtreat newtreat

end

capture program drop cov
program define cov
keep if sample==1
global cov_bl=" i.geo bl_medad lnbl_ytoth_pc bl_hhsize bl_meduc  missbl_medad misslnbl_ytoth_pc missbl_hhsize missbl_meduc   "
global cov_ind=" i.sexo i.edad i.aniosed07 misssexo missedad missaniosed"
end

capture program drop cov_select
program define cov_select
global cov_bl=" i.geo bl_medad lnbl_ytoth_pc bl_hhsize bl_meduc  missbl_medad misslnbl_ytoth_pc missbl_hhsize missbl_meduc   "
global cov_ind=""
end



capture program drop donow
program define donow

preserve
drop if ind_reest<-.02
drop if ind_reest>.02

capture drop tmp* pct* pred n
cov${select}

xtile pct=ind_reest if ind_reest<0 , nq(30)
xtile pct1=ind_reest if ind_reest>=0 , nq(15)

replace pct=pct1+100 if ind_reest>=0
capture drop newind_r
egen newind_r=mean(ind_reest), by(pct)					% creating newind_r
sort newind_r
drop if newind_r==.
sort numform
qui by numfor: g n=_n


cap drop mx
egen   mx=mean(x) if x!=. , by(pct )

set obs 21000
replace newind_r=0 if newind_r==. 
replace newtreat=0 if newtreat==. 
capture drop newind_r2
xi: reg mx newind_r* if  newind_r<0

predict tmp
cap drop pred
g pred=tmp if newind_r<=0


set obs 22000
replace newind_r=0 if newind_r==. 


xi: reg mx newind_r*   if  newind_r>0

predict tmp1
replace pred=tmp1 if newind_r>=0 & pred==.
replace newtreat=1 if newtreat==. 
sort rewind_r newtreat
label var newind_r "Predicted income"
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)

capture drop coef se
g coef=string(_coef[_Inewtr], "%9.3f")
global coef=coef
g se=string(_se[_Inewtr], "%9.3f")
global se=se


xi: reg mx i.newtreat*newind_r*   , cluster(newind_r)
cap drop count
g count=100 
scatter pred mx newind_r [aw=count], c(l i)  xline(0) ms(i O) legend(off) $extra ylabel($min  ($gap) $max) xlabel(-.02 (0.01) 0.02) mcolor(black black) title($x)
graph save  graph_${x}.gph, replace
graph export graph_${x}.png, as(png) replace
*subtitle(RD estimate = $coef ($se))  $ylabel

restore
end

/* *************************************************************************** */
/* *********************    -TABLES-    ************************************** */
/* *************************************************************************** */


/* *************************************************************************** */
*Table 1
/* *************************************************************************** */

capture program drop regressnow
program define regressnow
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve

*creates mean values for tables
*mean
cov${select}
*no covariates
*no polynomial
xi: reg x i.newtreat ,  cluster(ind_reest)

/* Row 1 */ 
 
xi: reg x i.newtreat ,  cluster(ind_reest)
disp _cons
 outreg2 _Inewtr using " table_1_row_1.xls", title("Table 1", "Ever received PANES") append se bdec(3)  sdec(3)  coefastr nor2

 *first order polynomial
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)
outreg2 _Inewtr using " table_1_row_1.xls", title("Table 1", "Ever received PANES") append se bdec(3)  sdec(3)  coefastr  nocons nor2

*second order polynomial
xi: reg x i.newtreat*ind_reest i.newtreat|ind_reest2 ,  cluster(ind_reest)
outreg2 _Inewtr using " table_1_row_1.xls", title("Table 1", "Ever received PANES") append se bdec(3)  sdec(3)  coefastr  nocons nor2

capture drop newfechaing
capture drop newfecha

*
*no polynomial
xi: reg x i.newtreat $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using " table_1_row_1.xls", title("Table 1", "Ever received PANES") append se bdec(3)  sdec(3)  coefastr  nocons nor2

*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using " table_1_row_1.xls", title("Table 1", "Ever received PANES") append se bdec(3)  sdec(3)  coefastr  nocons nor2

*second order polynomial
xi: reg x i.newtreat*ind_reest i.newtreat|ind_reest2 $cov_bl $cov_ind,  cluster(ind_reest) 
 outreg2 _Inewtr using " table_1_row_1.xls", title("Table 1", "Ever received PANES") append se bdec(3)  sdec(3)  coefastr  nocons nor2

 restore
end
 
 capture program drop regressnowrow2
program define regressnowrow2
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve

 
 /* Row 2 */ 

xi: reg x i.newtreat ,  cluster(ind_reest)
disp _cons
 outreg2 _Inewtr using "table_1_row_2.xls", title("Table 1", "Gov Support'07") append se bdec(3)  sdec(3)  coefastr nor2
*first order polynomial
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_2.xls", title("Table 1", "Gov Support'07") append se bdec(3)  sdec(3) coefastr  nocons nor2

*second order polynomial
xi: reg x i.newtreat*ind_reest i.newtreat|ind_reest2 ,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_2.xls", title("Table 1", "Gov Support'07") append se bdec(3)  sdec(3) coefastr  nocons nor2

capture drop newfechaing
capture drop newfecha


*covariates
*no polynomial
xi: reg x i.newtreat $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_2.xls", title("Table 1", "Gov Support'07") append se bdec(3)  sdec(3) coefastr  nocons nor2

*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_2.xls", title("Table 1", "Gov Support'07") append se bdec(3)  sdec(3) coefastr  nocons nor2

*second order polynomial
xi: reg x i.newtreat*ind_reest i.newtreat|ind_reest2 $cov_bl $cov_ind,  cluster(ind_reest) 
 outreg2 _Inewtr using "table_1_row_2.xls", title("Table 1", "Gov Support'07") append se  bdec(3) sdec(3) coefastr nocons nor2

 
restore
end

 
 capture program drop regressnow3
program define regressnow3
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve



 
 /* Row 3 */ 

xi: reg x i.newtreat ,  cluster(ind_reest)
/*disp _cons */
 outreg2 _Inewtr using "table_1_row_3.xls", title("Table 1", "Gov Support'08") append se bdec(3) sdec(3)  coefastr nor2
*first order polynomial
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_3.xls", title("Table 1", "Gov Support'08") append se  bdec(3) sdec(3) coefastr  nocons nor2

*second order polynomial
xi: reg x i.newtreat*ind_reest i.newtreat|ind_reest2 ,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_3.xls", title("Table 1", "Gov Support'08") append se  bdec(3) sdec(3) coefastr  nocons nor2

capture drop newfechaing
capture drop newfecha


*covariates
*no polynomial
xi: reg x i.newtreat $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_3.xls", title("Table 1", "Gov Support'08") append se  bdec(3) sdec(3) coefastr  nocons nor2

*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using "table_1_row_3.xls", title("Table 1", "Gov Support'08") append se bdec(3)  sdec(3) coefastr  nocons nor2

*second order polynomial
xi: reg x i.newtreat*ind_reest i.newtreat|ind_reest2 $cov_bl $cov_ind,  cluster(ind_reest) 
 outreg2 _Inewtr using "table_1_row_3.xls", title("Table 1", "Gov Support'08") append se  bdec(3) sdec(3) coefastr nocons nor2

 
restore
end


/*Row 3 */

*only linear no controls
capture program drop regressnow1
program define regressnow1


for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve
cov${select}
*covariates
xi: reg x i.newtreat ,  cluster(ind_reest)


*first order polynomial
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)

restore
end



*only linear + controls
capture program drop regressnow2
program define regressnow2
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve
cov${select}
xi: reg x i.newtreat ,  cluster(ind_reest)

*covariates
*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)


restore
end



cap program drop zscore1
program define zscore1
qui d ind_reest
end



cap program drop table1
program define table1 
global table="table1"
initial

*FIRST STAGE
*treated: ADMIN DATA
capture drop x
global x="Ever.received.PANES"  //aprobado
global min=0 
global max=1 
global gap=.2
global select=""
g x=aprobado if untracked07==0 
donow

zscore1
regressnow

*support for govt - first wave
capture drop  x
g x=(h_89-1)/2 if h_89 !=9
global x="Gov.support.2007" 
replace x= 0 if h_89==2
replace x= .5 if h_89==1
zscore1
global min=.6
global max=1
global gap=.1
global select=""
donow
regressnowrow2

*support for govt - second wave
capture drop x
g x=(hv34-1)/2 if  hv34 !=9
global x="Gov.support.2008" 
replace x= 0 if hv34==2
replace x= .5 if hv34==1
zscore1
global min=.6
global max=1
global gap=.1
global select=""
donow
regressnow3

end






/* *************************************************************************** */
*Table 2
/* *************************************************************************** */

/* In between */
*part1



capture program drop regressnow4
program define regressnow4
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve

 *first order polynomial
 
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)
outreg2 _Inewtr using "table_2.xls",  title("Table 2", "Program Eligibility Baseline Characteristics and Response Rates in 2005", "*see constant in log file for mean noneligibles", "1-5") append se bdec(3) sdec(3)    coefastr addn("(2) Log per capita income, (3) Household average years of education, (4) Household size, (5) Household average age, (6) Respondent is female")  nor2 

restore
end

*part2

capture program drop regressnow4B
program define regressnow4B
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve

 *first order polynomial
xi: reg x i.newtreat*ind_reest ,  cluster(ind_reest)
 outreg2 _Inewtr using "table_2B.xls", title("Table 2", "Program Eligibility Baseline Characteristics and Response Rates in 2005", "*see constant in log file for mean noneligibles", "6-10") append se  bdec(3) sdec(3)   coefastr addn("(2) Respondent years of education, (3) Respondent age, (4) Nonresponse/missing response on political support question (2007), (5) Nonresponse/missing response on political support question (2008), (6) Voted in 2004 elections") nor2


/* addnote("(2) Respondent years of education, (3) Respondent age, (4) Nonresponse/missing '07, (5) Nonresponse/missing '08, (6) Voted in 2004 elections") */ 
restore
end




cap program drop table2
program define table2 
global table="table2"
initial
preserve

*pretreatment characteristics

global ylabel=""
capture drop x
g x=lnbl_ytoth_pc if misslnbl_ytoth_pc==0 & untracked07==0
global x="Log.per.capita.income" //  lnbl_ytoth_pc
global select=""
zscore1
regressnow1
global min=6.0
global max=6.6
global gap=.1
donow
regressnow4

*average ed  at pretreatment 
capture drop x
global x="Household.average.years.of.education"  //aved
g x=bl_meduc if missbl_meduc==0 & untracked07==0
global select=""
zscore1
regressnow1
global min=3
global max=5
global gap=.5
donow
regressnow4

*hh size at pretreatment 
capture drop x
global x="Household.size" //hhsize
g x=bl_hhsize  if missbl_hhsize==0 & untracked07==0
global select=""
zscore1
regressnow1
global min=2
global max=4.5
global gap=.5
donow
regressnow4

*average age at at pretreatment 
capture drop x
global x="Household.average.age" //avage
g x=bl_medad if  missbl_medad==0 & untracked07==0
global select=""
zscore1
regressnow1	
global min=20
global max=40
global gap=5
donow
regressnow4


global ylabel=""
capture drop x
global x="Respondent.is.female" //sexo
g x=sexo-1 if misssexo==0 & untracked07==0
global select=""
zscore1
regressnow1
global min=.9
global max=.5
global gap=.1
donow
regressnow4


global ylabel=""
capture drop x
global x="Respondent.years.of.education" //ed
g x=aniosed  if missaniosed==0 & untracked07==0
global select=""
zscore1
regressnow1
global min=5.5
global max=8.5
global gap=.5
donow
regressnow4B

global ylabel=""
capture drop x
global x="Respondent.age" //edad
g x=edad if missedad==0 & untracked07==0
global select=""
zscore1
regressnow1
global min=30
global max=50
global gap=5
donow
regressnow4B

*no repsonse 07
cap drop x
g x=untracked07==1 | h_89>=9 if mue>0 & mue<.
global x="Non.response.2007"  //noresponse07
global select="_select"
zscore1
regressnow1
global min=.1
global max=.6
global gap=.1
donow
regressnow4B

*no response 08
cap drop x
g x=untracked08==1 | hv34>=9 if mue>0
global x="Non.response.2008"  //noresponse08
global select="_select"
zscore1
regressnow1
global min=.1
global max=.6
global gap=.1
donow
regressnow4B

*voted last elections
global ylabel="turnout"
capture drop x
global x="Voted.last.elections" //turnout05
global select=""
g x=2-j_98 if  j_98<3 & untracked07==0
zscore1
regressnow2
global min=.7
global max=1
global gap=.1
donow
regressnow4B

end



/* *************************************************************************** */
*TABLE 3
/* *************************************************************************** */


/* In between */



capture program drop regressnow5
program define regressnow5
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve


*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
disp _cons
outreg2 _Inewtr using "table_3.xls", title("Table 3", "Program Eligibility Income and View on PANES in 2007", "*see constant in log file for mean noneligibles") append se bdec(3)  sdec(3) coefastr  nor2 addn("(2) Log household per capita income, (3) Satisfaction with household situation, (4) There are people who received PANES who should not have, (5) There are people who did not receive PANES who should have, (6) Beneficiaries should have received less so that more people could benefit")
g d = e(sample) == 1
summ if newtreat == 0 & d == 1
 summ  if newtreat==0
 //outreg2  if newtreat == 0 & e(sample) == 1 using TableTRIAL.doc, replace sum(log) keep(lnytoth07_pc sithogar07 panes_perosnasnonessessitan panes_personasnessessitan  panes_cobrarmenos) dec(2) eqdrop(max min)

ereturn list
 restore
end


cap program drop table3
program define table3 
global table="table3"
initial


preserve
keep if h_89<9
*self reported PANES part.on 


*labor market and other outcomes
capture drop x
g x=lnytoth07_pc  
global x="lny07_pc"
global select=""
zscore1
regressnow2
regressnow5


capture drop x
g x=(h_86-1)/4 if h_86<9
global x="sithogar07"
global select=""
zscore1
regressnow2
regressnow5

*views 07
capture drop x
g x=(3-k_112_1)/2 if k_112_1<9 
global x="panes_perosnasnonessessitan"
 global select=""
zscore1
regressnow2
regressnow5

capture drop x
g x=(3-k_112_4)/2 if k_112_4<9 
global x="panes_personasnessessitan"
 global select=""
zscore1
regressnow2
regressnow5


capture drop x
g x=(3-k_112_3)/2 if k_112_3<9 
global x="panes_cobrarmenos"
global select=""
zscore1
regressnow2
regressnow5
 
restore
end





/* *************************************************************************** */
*Table4
/* *************************************************************************** */


/* In between */

*Part 1:


capture program drop regressnow6
program define regressnow6
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve


*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
disp _cons
 outreg2 _Inewtr using "table_4.xls", title("Table 4", "Program Eligibility Income Participation in Other Program and Political and Social Attitudes in 2008", "*see constants in log file for mean noneligibles" "1-6") append se bdec(3)  sdec(3) coefastr  /*nocons*/ nor2

 restore
end

*Part 2:
capture program drop regressnow6B
program define regressnow6B
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve


*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using "table_4B.xls", title("Table 4", "Program Eligibility Income Participation in Other Program and Political and Social Attitudes in 2008", "*see constants in log file for mean noneligibles", "7-12") append se bdec(3)  sdec(3) coefastr  /*nocons*/ nor2

 restore
end

*Part 3:
 


capture program drop regressnow6C
program define regressnow6C
for any 2 3 4: capture drop ind_reestX
for any 2 3 4: g ind_reestX=ind_reest^X

preserve


*first order polynomial
xi: reg x i.newtreat*ind_reest $cov_bl $cov_ind,  cluster(ind_reest)
 outreg2 _Inewtr using "table_4C.xls", title("Table 4", "Program Eligibility Income Participation in Other Program and Political and Social Attitudes in 2008", "*see constant in log file for mean noneligibles", "13-18") append se bdec(3)  sdec(3) coefastr  /*nocons*/ nor2

 restore
end





cap program drop table4
program define table4
global table="table4"

initial
preserve
keep if hv34<9

*self reported PANES part.on - second wave

capture drop x
g x=lnytoth08_pc  
global x="lnytoth08_pc"
global select=""
zscore1
regressnow2
regressnow6

capture drop x
g x=durables
global x="durables"
global select=""
zscore1
regressnow2
regressnow6


*participates in PE
capture drop x
g x=montobps_pe08>0 if montobps_pe08<. 
global x="pe08"
global select=""
zscore1
regressnow2
regressnow6
global min=0 
global max=1 
global gap=.1
donow

*tarjeta alimentaria
capture drop x
g x=2-hv25 if hv25<9 
replace x=0 if hv2==2 
global x="tarjeta08"
global select=""
zscore1
regressnow2
regressnow6


*opinions panes
capture drop x
g x=(hv178-1)/5 if hv178<9 
global x="opinion_panes08"
global select=""
zscore1
regressnow2
regressnow6



* opinion PE 
capture drop x
g x=(hv192-1)/5 if hv192<9 
global x="opinion_PE"
global select=""
zscore1
regressnow2
regressnow6

capture drop x
g x=(3-hv36)/2 if hv36<9
replace x=.5 if hv36==3
replace x=0 if hv36==2
global x="trend_diffsociales08"
global select=""
zscore1
regressnow2
regressnow6B


capture drop x
g x=(hv33-1)/4 if hv33<9
global x="futhogar08"
global select=""
zscore1
regressnow2
regressnow6B

capture drop x
g x=(hv32-1)/4 if hv32<9
global x="futpais08"
global select=""
zscore1
regressnow2
regressnow6B



*confidence
*MIDES
capture drop x
g x=(hv198-1)/2 if hv198<9
global x="conf_mides08"
global min=.3
global max=.7
global select=""
zscore1
regressnow2
regressnow6B





*confianza presidente - second wave
capture drop x
g x=(hv196-1)/2 if hv196<9
global x="conf_pres08"  
global select=""
zscore1
regressnow2
regressnow6B



*partidos
capture drop x
g x=(hv195-1)/2 if hv195<9
global x="conf_partidos"
global select=""
zscore1
regressnow2
regressnow6B


*BPS
capture drop x
g x=(hv197-1)/2 if hv197<9
global x="conf_bps08"
global select=""
zscore1
regressnow2
regressnow6C


*INTENDENCIAS
capture drop x
g x=(hv201-1)/2 if hv201<9 
global x="intendencias08"
zscore1
regressnow2
regressnow6C
global select=""


*PARLIAMENTO
capture drop x
g x=(hv200-1)/2 if hv200<9 
zscore1
global x="conf_parlamiento08"
global select=""
zscore1
regressnow2
regressnow6C


*pride
cap drop x
g x=(hv208-1)/3 if hv208<5
global x="orguglio08"
global select=""
zscore1
regressnow2
regressnow6C

*interest in politics
cap drop x
g x=(hv209-1)/3 if hv209<9
global x="interest_politics08"
global select=""
zscore1
regressnow2
regressnow6C



capture drop x
g x=(5-hv37)/4 if hv37<9
global x="socmobility08"
global select=""
zscore1
regressnow2
regressnow6C
restore


log close;
exit;


end


/* Calling out the programs to reproduce the tables */

/* If you only want to reproduce one single table, you can do so by making the
rest of the tables (the ones that you dont need) appear like comments. For example,
if you dont need Table 3, all you need to do is to add "//" right before table3 below, 
or "//table3", in which case the progrm that produces Table 3 in the paper wont run
  */
  

table1
	table2
		table3
			table4




