
OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";

/*when processes get too slow, run this and RERUN ALL OF HIST to free up memory

proc datasets library=work kill; run; 

*/

proc import datafile="E:\Research\Excel Files\data 2013\plothistory.csv"
out=hist 
dbms=csv replace;
getnames=yes;
run;
/*proc contents data=hist; title 'hist'; run;
proc print data=hist; run;  * N = 44; */
* plot history data in this file;
* variables: 
   burnsev (s, l, m, h) = wildfire severity
   hydr (x, n, l, h) = hydromulch [x = unknown, n = none, l = light, h = heavy]
   lastrx = year of last prescribed burn
   yrrx1, yrrx2, yrrx3 = years of rx burns since 2003
   plot = fmh plot #;
data hist2; set hist;
   if lastrx = 9999 then lastrx = .;
   if yrrx1 = 9999 then yrrx1 = .;
   if yrrx2 = 9999 then yrrx2 = .;
   if yrrx3 = 9999 then yrrx3 = .;
   /* years since prescribed fire variables. So far not very useful.
   lastrx = 2014 - yrrx;
   if (lastrx = .) then yrcat = 'nev';
   if (lastrx = 3| lastrx = 6 | lastrx = 7) then yrcat = 'rec';
   if (lastrx = 9 | lastrx = 11) then yrcat = 'old';   */
   * makes new set of treatment names with natural ordering for graphs and constrasts;
   if burnsev = 's' then burn = 1;
   if burnsev = 'l' then burn = 2;
   if burnsev = 'm' then burn = 3;
   if burnsev = 'h' then burn = 4;
   * poolingA - scorch, light, moderate;
   if (burnsev = 'h') then bcat1 = 'B';
   if (burnsev = 'm' | burnsev = 'l' | burnsev = 's') then bcat1 = 'A';
   * poolingB - combine scorch + light;
   if (burnsev = 'h') then bcat2 = 'C';
   if (burnsev = 'm') then bcat2 = 'B';
   if (burnsev = 's' | burnsev = 'l') then bcat2 = 'A';
run;

proc sort data=hist2; by plot burn; run;

*--------------------------------------- 2014 -----------------------------------------------------;
/*FUELS data were only collected in 1999.

proc import datafile="g:\Excel Files\FFI long-term data\duff-1999.csv"
out=duff 
dbms=csv replace;
getnames=yes;
run;

proc import datafile="g:\Excel Files\FFI long-term data\1000hrfuels-1999.csv"
out=cwd 
dbms=csv replace;
getnames=yes;
run;

proc import datafile="g:\Excel Files\FFI long-term data\finefuels-1999.csv"
out=finefuels 
dbms=csv replace;
getnames=yes;
run;

From FMH handbook--'Ocular estimates of cover for plant species on a macroplot'
Collected on about 13 plots, 2010-2013. no more than 5-6 spp recorded per plot, and no cover recorded. 
Also entered for 2002, 2003, 2005, 2006, but completely blank. 
proc import datafile="g:\Excel Files\FFI long-term data\cover-speciescomp-allyrs.csv"
out=spcomp 
dbms=csv replace;
getnames=yes;
run;

Done in 2011, one plot in 2008. Data for 2012 included but blank--maybe a mistake?
proc import datafile="g:\Excel Files\FFI long-term data\postburnsev-allyrs.csv"
out=postsev 
dbms=csv replace;
getnames=yes;
run;
*/

*NOTE FOR ALL: Count subspecies as separate species or lump together? Also: there are species in the database that are taxonomically something different now, should be corrected for consistency;

*---------------------------------------trees-----------------------------------------;
*seedlings/resprouts;
proc import datafile="E:\Research\Excel Files\FFI long-term data\seedlings-allyrs.csv"
out=seedlings 
dbms=csv replace;
getnames=yes;
run;  * N = 998;

/*proc sort data=seedlings; by plot; run;
proc print data=seedlings; title 'seedlings'; run;*/

* cleanup;
data seedlings1;
	set seedlings;
	if Species_Symbol='' then Species_Symbol = "XXXX";
data seedlings2 (rename=(MacroPlot_Name=plot) rename=(Species_Symbol=sspp) rename=(SizeClHt=shgt) rename=(Count=snum));
	set seedlings1;
data seedlings3 (keep=plot sspp shgt snum Date);
	set seedlings2;
run;
/*proc contents data=seedlings3; title 'seedlings3'; run;  * N = 798;
variables
   plot = fmh plot #
   sspp = species code
   shgt = height class
   snum = number of seedlings or resprouts per height class. sdlngs here on out for simplicity.
   Date = date of plot visit

proc print data=seedlings3; run;  * N = 798 (798 sdlngs);*/
/*proc freq data=seedlings3; tables sspp; run; */
	/* CAAM is entered 2x (shrub, not a seedling)
	ILVO is entered 9x (shrub, not a seedling)
	UNTR1 = unknown tree
	FOR ALL DATASETS: remove unknown observations?? */
*two sets, one with consistent trees, the other with inconsistent spp; 
data seedlings4; set seedlings3;
	if (sspp NE "CAAM2" & sspp NE "ILVO" & sspp NE "VAAR") ;
data seedlingprobspp; set seedlings3;
	if (sspp  = "CAAM2" | sspp  = "ILVO" | sspp  = "VAAR");
run;
/* proc freq data=seedlings4; tables sspp; title 'seedlings4'; run; * N = 648;
proc freq data=seedlingprobspp; tables sspp; title 'seedlings4'; run; * N = 150; */

*splitting out just important species--pines and quma, quma3;
data pineoak; set seedlings4;
	if (sspp = "PITA" |sspp = "QUMA" | sspp = "QUMA3");
run;

/*proc freq data=pineoak; tables sspp; title 'pineoak'; run; * N = 473;*/
proc sort data=pineoak; by plot;
data pineoak2; merge hist2 pineoak; by plot; year = year(date); run;
data pineoak3; set pineoak2;
   if year < 2011 then prpo = 'pref';
   if year >= 2011 then prpo = 'post';
run;
/*proc print data=pineoak3; run;
proc contents data = pineoak3; run;
proc freq data=pineoak3; tables sspp*burn; title 'pineoak'; run; * N = 491;*/

proc print data = seedlings3; title 'seedlings3'; run;
*splitting each separately and by year. Note that there are no observations in 2011--2011 sampling was done immediately post-BCCF;
*pines;



*---- subset the data by species-------------;
proc sort data=seedlings3; by plot;
proc print data = seedlings3; run;

*loblolly;
data pita; set seedlings3; if sspp="PITA"; 
  if shgt=1 then npita1 = snum; if shgt=2 then npita2 = snum;
  if shgt=3 then npita3 = snum; if shgt=4 then npita4 = snum;
  if shgt=5 then npita5 = snum; if shgt=6 then npita6 = snum; 
  if shgt=7 then npita7 = snum; 
proc print data=pita; title 'pita';  * N = 155 obs;
run;

proc sort data=pita; by plot;
data pita2; merge hist2 pita; by plot; year = year(date); run;
proc print data = pita2; run; * N = 181 obs;

proc means data=pita2 sum noprint; by plot burn year; 
 var npita1-npita7;
 output out=pita3 sum = spita1-spita7;
proc print data=pita3; title 'pita3';  
run; * N = 108 obs;
proc freq data=pita3; tables burn;
run;

*QUMA -- sand post oak;
data quma; set seedlings3; if sspp="QUMA"; 
  if shgt=1 then nquma1 = snum; if shgt=2 then nquma2 = snum;
  if shgt=3 then nquma3 = snum; if shgt=4 then nquma4 = snum;
  if shgt=5 then nquma5 = snum; if shgt=6 then nquma6 = snum; 
  if shgt=7 then nquma7 = snum; 
proc print data=quma; title 'quma';  * N = 141 obs;
run;

proc sort data=quma; by plot;
data quma2; merge hist2 quma; by plot; year = year(date); run;
proc print data = quma2; run; * N = 173 obs;

proc means data=quma2 sum noprint; by plot burn year; 
 var nquma1-nquma7;
 output out=quma3 sum = squma1-squma7;
proc print data=quma3; title 'quma3';  
run; * N = 109 obs;
proc freq data=quma3; tables burn;
run;





data quma; set seedlings3; if sspp="QUMA"|sspp="QUMA3"; 
  if shgt=1 then nquma1 = snum; if shgt=2 then nquma2 = snum;
  if shgt=3 then nquma3 = snum; if shgt=4 then nquma4 = snum;
  if shgt=5 then nquma5 = snum; if shgt=6 then nquma6 = snum; 
  if shgt=7 then nquma7 = snum; 
proc print data=quma; title 'quma';  * N = 318 obs;
run;

proc sort data=quma; by plot;
data quma2; merge hist2 quma; by plot; year = year(date); run;
proc print data = quma2; run; * N = 173 obs;

proc means data=quma2 sum noprint; by plot burn year; 
 var nquma1-nquma7;
 output out=quma3 sum = squma1-squma7;
proc print data=quma3; title 'quma3';  
run; * N = 109 obs;
proc freq data=quma3; tables burn;
run;




*QUMA3 -- blackjack oak;
data blackj; set seedlings3; if sspp="QUMA3"; 
  if shgt=1 then nblak1 = snum; if shgt=2 then nblak2 = snum;
  if shgt=3 then nblak3 = snum; if shgt=4 then nblak4 = snum;
  if shgt=5 then nblak5 = snum; if shgt=6 then nblak6 = snum; 
  if shgt=7 then nblak7 = snum; 
proc print data=blackj; title 'blackj';  * N = 177 obs;
run;

proc sort data=blackj; by plot;
data blackj2; merge hist2 blackj; by plot; year = year(date); run;
proc print data = blackj2; run; * N = 209 obs;

proc means data=blackj2 sum noprint; by plot burn year; 
 var nblak1-nblak7;
 output out=blackj3 sum = sblak1-sblak7;
proc print data=blackj3; title 'blackj3';  
run; * N = 104 obs;
proc freq data=blackj3; tables burn;
run;







data datreorg; merge pita3 quma3 blackj3; by plot burn year;
proc print data=datreorg; title 'datreorg';
run; *N = 245 obs;

data dattotn; set datreorg;
  if (spita1=.) then spita1=0; if (spita2=.) then spita2=0; 
  if (spita3=.) then spita3=0; if (spita4=.) then spita4=0; 
  if (spita5=.) then spita5=0; if (spita6=.) then spita6=0; 
  if (spita7=.) then spita7=0; 
  if (squma1=.) then squma1=0; if (squma2=.) then squma2=0; 
  if (squma3=.) then squma3=0; if (squma4=.) then squma4=0; 
  if (squma5=.) then squma5=0;if (squma6=.) then squma6=0; 
  if (squma7=.) then squma7=0; 
  if (sblak1=.) then sblak1=0; if (sblak2=.) then sblak2=0; 
  if (sblak3=.) then sblak3=0; if (sblak4=.) then sblak4=0; 
  if (sblak5=.) then sblak5=0;if (sblak6=.) then sblak6=0; 
  if (sblak7=.) then sblak7=0; 
  totpita = spita1 + spita2 + spita3 + spita4 + spita5 + spita6 + spita7;
  totquma = squma1 + squma2 + squma3 + squma4 + squma5 + squma6 + squma7;
  totquma3 = sblak1 + sblak2 + sblak3 + sblak4 + sblak5 + sblak6 + sblak7;

proc print data = dattotn; run; *N = 245 observations;


data tot12; set dattotn; if (year = "2012"); run;
proc sort data=tot12; by plot year burn;
proc print data = tot12; run; *N = 32 observations;
proc freq data=tot12; tables burn; title '2012'; run;

data tot13; set dattotn; if (year = "2013"); run;
proc sort data=tot13; by plot year burn;
proc print data = tot13; run; *N = 46 observations;
proc freq data=tot13; tables sspp*burn; title '2013'; run;


















proc sort data=pineoak3; by plot year sspp burn prpo;
proc means data=pineoak3 noprint sum; by plot year sspp burn prpo; var snum; 
  output out=numplantdatapo sum=npersppo;
  *npersppo = number per species for pines and oaks;
/*proc print data=numplantdatapo; title 'pine oak numplantdata'; 
  var plot year burn prpo sspp npersppo;
run;   * N = 240 plot-year combinations;

proc freq data=numplantdatapo; tables sspp*burn / fisher expected;
run;
*this has different values than pineoak3 table...not sure why yet;*/

proc sort data=numplantdatapo; by plot burn prpo;
proc means data=numplantdatapo noprint sum; by plot burn prpo; var npersppo; 
  output out=numperplot sum=nperplot;
/*proc print data=numperplot; title 'totals per plot'; 
  var plot burn prpo nperplot;
run;   * N = 249 plot-year combinations;*/
proc sort data = numperplot; by plot;
data numperplot2; merge numplantdatapo numperplot; by plot; run;
/*proc print data = numperplot2; run;*/
data numperplot3; set numperplot2;
	relabun = npersppo / nperplot;
/*proc print data = numperplot3; title 'numperplot3'; run;


proc freq data=numperplot3; tables sspp*burn / fisher expected;
run;
proc freq data=numperplot3; tables sspp*prpo / fisher expected;
run;
*/
*merging orig dataset (with all species) with plot history;
proc sort data=seedlings4; by plot;
data seedlings5; merge hist2 seedlings4; by plot; year = year(date); run;
/*proc print data=seedlings5; title 'seedlings merged with plot history'; run; * N = 659 no seedlings observed in plot 1237; */

proc contents data = numperplot3; run;
*variables:
	burn = burn severity (1 = scorch, 2 = light, 3 = moderate, 4 = heavy)
	nperplot = total number of individuals per plot
	npersppo = number of individuals per species per plot
	plot = plot ID
	prpo = pref (pre-fire), post (post-fire). Date variable.
	relabun = relative abundance per species per plot
	sspp = species code
	year = year surveyed;
/*proc univariate data=numperplot3 plot normal; 
run;*/
*Shapiro-Wilk: 0.3359, P < 0.0001. 
Lognormally distributed, create new variable with transformed data;
data numperplot4; set numperplot3;
	logabund = log(relabun);
run;/*
proc univariate data=numperplot4 plot normal; 
run;*/
*Shapiro-Wilk: 0.983, p = 0.0074;

* ---- plot-level information -----;
* to compare spp among plots, we need a comparable variable for each plot;
* an obvious comparable variable is number of plants of that spp;
proc sort data=seedlings5; by plot year sspp;
proc means data=seedlings5 noprint sum; by plot year sspp; var snum; 
  output out=numplantdata sum=npersp;
/*proc print data=numplantdata; title 'numplantdata'; 
  var plot year sspp npersp;
run;   * N = 352;
*/
proc means data=numplantdata noprint sum; by plot year; 
  var npersp;
  output out=seedlings6 sum = sumseedlings;
* sumseedlings = # of all sdlngs in the plot;
/*proc print data=seedlings6; title 'seedling6';
  run; * n=168 plot-year combinations;

proc univariate data=numplantdatapo plot;
	var npersppo;
run;
* long right tail;*/

* which are the most common spp?;
proc sort data=numplantdata; by sspp;
proc means data=numplantdata sum noprint; by sspp; var npersp;
  output out=spptotals sum=spptot; run;
/*proc print data=spptotals; title 'plants/spp all plots, all year';
run;
*QUMA3: 1027, PITA: 937, QUMA: 725, SANI: 157;*/

*-------------------------------------herbaceous-----------------------------------------;
proc import datafile="E:\Research\Excel Files\FFI long-term data\density-quadrats-allyrs.csv"
out=herbs 
dbms=csv replace;
getnames=yes;
run;
/*proc print data=herbs; title 'herbs'; run;*/

*cleanup;
data herbs1;
	set herbs;
	if Species_Symbol='' then Species_Symbol=XXXX;
data herbs2 (rename=(MacroPlot_Name=plot) rename=(Species_Symbol=hspp) rename=(Status=stat) rename=(Count=hnum));
	set herbs1;
data herbs3 (keep=plot hspp stat hnum Date);
	set herbs2;
run;
proc contents data=herbs3; title 'herbs3'; run;
*variables
   plot = fmh plot #
   hspp = species code
   hnum = count variable
   stat = status (L/D)
   Date = date of plot visit;

/*proc print data=herbs3; run;  * N = 5081;*/



*---- subset the data by species-------------;
proc sort data=herbs3; by plot;
proc print data = herbs3; run;















proc freq data=herbs3; tables hspp; run; 
	/* ACGR = Acacia farnesiana (tree), probably meant ACGR2 (Acalypha gracilens).
	RUBUS should not be in here, it should be with shrubs.
	SMILA2 (Smilax spp.) also should be with shrubs.
	UNID1 = unidentified.
	UNFL1 = unknown flower.
	UNGR3 = unknown grass.
	UNSE1 = unknown seedling. Shouldn't even be in here! */
*removing incorrect observations and correcting Acalypha gracilens;
data herbs4;
	set herbs3;
	if hspp = "RUBUS" or hspp = "SMILA2" or hspp = "UNSE1" then delete;
	if hspp = "ACGR" then hspp = "ACGR2";
run;
proc freq data = herbs4; tables hspp; title 'herbs4'; run;

*merging with plot history;
proc sort data=herbs4; by plot;
data herbs5; merge hist2 herbs4; by plot; year = year(date); run;
/*proc print data=herbs5; title 'herbs merged with plot history'; run; * N = 5072; */

* ---- plot-level information -----;
proc sort data=herbs5; by burn plot; run; *stop here for afe analyses;
proc means data=herbs5 noprint n; by burn bcat1 bcat2 yrcat yrsincerx plot;  
  var hnum;
  output out=herbs6 n = hnum
  					   sum = sumherbs;
* hnum = number of individual observations in the plot  
  sumherbs = # of all stems in the plot;

proc print data=herbs6; title 'herbs6'; run; *n=55;

proc univariate data=herbs6 normal plot;
	var sumherbs;
run;
*N = 55, skewness = 1.2260, kurtosis = 2.7826. Shapiro-Wilk: W=0.9204, p = 0.0014;


