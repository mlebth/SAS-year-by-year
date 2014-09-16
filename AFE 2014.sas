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

*---------------------------------------Ilex resprouts-----------------------;
proc import datafile="E:\Research\Excel Files\FFI long-term data\density-belts-allyrs.csv"
out=shrubs 
dbms=csv replace;
getnames=yes;
run;
/*proc print data=shrubs; title 'shrubs'; run;*/

*cleanup;
data shrubs1;
	set shrubs;
	if Species_Symbol='' then Species_Symbol='XXXX';
data shrubs2 (rename=(MacroPlot_Name=plot) rename=(Species_Symbol=shspp) rename=(Status=stat) rename=(AgeCl=agec) rename=(Count=shnum));
	set shrubs1;
data shrubs3 (keep=plot shspp stat agec shnum Date);
	set shrubs2;
run;


*---- ILVO subset -------------;
proc sort data=shrubs3; by plot;
proc print data = shrubs3; title 'shrubs3'; run; 

data ilvo; set shrubs3; if shspp="ILVO"; 
  if stat='L' then nilvo1 = shnum; if stat='D' then nilvo2 = shnum;
  if agec='I' then nilvo3 = shnum; if agec='M' then nilvo4 = shnum;
  if agec='R' then nilvo5 = shnum; 
proc print data=ilvo; title 'ilvo';  * N = 203 obs;
run;

proc sort data=ilvo; by plot;
data ilvo2; merge hist2 ilvo; by plot; year = year(date); if year='.' then nilvo6 = 0; run;
proc print data = ilvo2; title 'ilvo2'; run; * N = 221 obs;

proc means data=ilvo2 sum noprint; by plot burn year; 
 var nilvo1-nilvo6;
 output out=ilvo3 sum = silvo1-silvo6;
proc print data=ilvo3; title 'ilvo3';  
run; * N = 136 obs;
proc freq data=ilvo3; tables burn;
run;

data ilvo4; set ilvo3;
  if (silvo1=.) then silvo1=0; if (silvo2=.) then silvo2=0; 
  if (silvo3=.) then silvo3=0; if (silvo4=.) then silvo4=0; 
  if (silvo5=.) then silvo5=0; silvo6 = 0;
  totilvo = silvo1 + silvo2 + silvo3 + silvo4 + silvo5 + silvo6;

proc print data = ilvo4; title 'ilvo4'; run; *N = 136 observations;

data ilvo12; set ilvo4; if (year = "2012" | year = '.'); run;
proc sort data=tot12; by plot year burn;
proc print data = tot12; title 'ilvo 2012'; run; *N = 38 observations;
proc freq data=tot12; tables burn; title '2012'; run;

data ilvo13; set ilvo4; if (year = "2013" | year = '.'); run;
proc sort data=ilvo13; by plot year burn;
proc print data = ilvo13; run; title 'ilvo 2013'; *N = 47 observations;
proc freq data=ilvo13; tables sspp*burn;  run;


*---------------------------------------pine/oak seedlings and resprouts-----------------------------------------;
*seedlings/resprouts;
proc import datafile="E:\Research\Excel Files\FFI long-term data\seedlings-allyrs.csv"
out=seedlings 
dbms=csv replace;
getnames=yes;
run;  * N = 998;

/*proc print data=seedlings; title 'seedlings'; run;*/

* cleanup;
data seedlings1;
	set seedlings;
	if Species_Symbol='' then Species_Symbol = "XXXX";
data seedlings2 (rename=(MacroPlot_Name=plot) rename=(Species_Symbol=sspp) rename=(SizeClHt=shgt) rename=(Count=snum));
	set seedlings1;
data seedlings3 (keep=plot sspp shgt snum Date);
	set seedlings2;
run;



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


*both oaks pooled;
data quma; set seedlings3; if sspp="QUMA"|sspp="QUMA3"; 
  if shgt=1 then naquma1 = snum; if shgt=2 then naquma2 = snum;
  if shgt=3 then naquma3 = snum; if shgt=4 then naquma4 = snum;
  if shgt=5 then naquma5 = snum; if shgt=6 then naquma6 = snum; 
  if shgt=7 then naquma7 = snum; 
proc print data=quma; title 'quma';  * N = 318 obs;
run;

proc sort data=quma; by plot;
data quma2; merge hist2 quma; by plot; year = year(date); run;
proc print data = quma2; run; * N = 173 obs;

proc means data=quma2 sum noprint; by plot burn year; 
 var naquma1-naquma7;
 output out=quma4 sum = saquma1-saquma7;
proc print data=quma3; title 'quma3';  
run; * N = 109 obs;
proc freq data=quma3; tables burn;
run;



data datreorg; merge pita3 quma3 quma4 blackj3; by plot burn year;
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
  if (saquma1=.) then saquma1=0; if (saquma2=.) then saquma2=0; 
  if (saquma3=.) then saquma3=0; if (saquma4=.) then saquma4=0; 
  if (saquma5=.) then saquma5=0;if (saquma6=.) then saquma6=0; 
  if (saquma7=.) then saquma7=0;
  totpita = spita1 + spita2 + spita3 + spita4 + spita5 + spita6 + spita7;
  totquma = squma1 + squma2 + squma3 + squma4 + squma5 + squma6 + squma7;
  totquma3 = sblak1 + sblak2 + sblak3 + sblak4 + sblak5 + sblak6 + sblak7;
  totoaks = saquma1 + saquma2 + saquma3 + saquma4 + saquma5 + saquma6 + saquma7;

proc print data = dattotn; run; *N = 245 observations;


data tot12; set dattotn; if (year = "2012"); run;
proc sort data=tot12; by plot year burn;
proc print data = tot12; run; *N = 32 observations;
proc freq data=tot12; tables burn; title '2012'; run;

data tot13; set dattotn; if (year = "2013"); run;
proc sort data=tot13; by plot year burn;
proc print data = tot13; run; *N = 46 observations;
proc freq data=tot13; tables sspp*burn; title '2013'; run;



*************************AFE POSTER results, year 2012****************************;
*tried poisson first, overdispersed;
proc genmod data=tot12; title 'loblolly 2012';
class burn ;
  model totpita = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat out=glmout1;
run;
proc univariate data=glmout1 plot normal; var ehat;
run;
*AIC=224.86 (better than poisson, around 750)
Shapiro-Wilk: W=0.95, P=0.1462
LR Type 3 Analysis--
burn: df=3, chi-square=6.21, P=0.1018
LSmeans: 
burn Estimate Standard Error  z Value  Pr > |z| 
1 	  1.6094   0.6649 		  2.42 		0.0155 
2 	  3.2144   0.4773 		  6.73 		<.0001 
3 	  3.0204   0.5858 		  5.16 		<.0001 
4 	  1.8326   0.4253 		  4.31 		<.0001 

;

proc genmod data=tot12; title 'sand post 2012';
class burn ;
  model totquma = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat2 out=glmout2;
run;
proc univariate data=glmout2 plot normal; var ehat2;
run;
*AIC=140.1959
Shapiro-Wilk: W=0.806, P<0.0001 ---non-normal residuals
LR Type 3 Analysis--
burn: df=3, chi-square=5.54, P=0.1364
LSmeans: 
burn Estimate Standard Error  z Value  Pr > |z| 
1 	  2.4681   	 0.9093		  2.71 		0.0066 
2 	  1.8971   	 0.6831 	  2.78 		0.0055
3 	  1.0415   	 0.8566		  1.22 		0.2240 
4 	  -0.08701   0.6545 	  -0.13 	0.8942 

;

proc genmod data=tot12; title 'blackjack 2012';
class burn ;
  model totquma3 = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat3 out=glmout3;
run;
proc univariate data=glmout3 plot normal; var ehat3;
run;
*AIC=169.6919
Shapiro-Wilk: W=0.898, P=0.0055
LR Type 3 Analysis--
burn: df=3, chi-square=9.14, P=0.0275 
LSmeans: 
burn 	Estimate 	Standard Error 	z Value 	Pr > |z| 
1 		-22.9321 	42674 			-0.00 		0.9996   ****crazy estimate and SE, only 2 obs
2 		2.1595 		0.6405 			3.37 		0.0007 
3 		2.7515 		0.7789 			3.53 		0.0004 
4 		2.0898 		0.5553 			3.76 		0.0002 

;

proc genmod data=tot12; title 'all oaks 2012';
class burn ;
  model totoaks = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat2 out=glmout2;
run;
proc univariate data=glmout2 plot normal; var ehat2;
run;
*AIC=140.1959
Shapiro-Wilk: W=0.9354, P=0.0942 
LR Type 3 Analysis--
burn: df=3, chi-square=0.65, P=0.8851
LSmeans: 
burn Estimate 	Standard Error  z Value  Pr > |z| 
1 	 2.4681 	0.4906 			5.03 	<.0001 
2 	 2.8478 	0.3835 			7.43 	<.0001 
3 	 2.9178 	0.4421 			6.60 	<.0001 
4 	 2.6027 	0.3862 			6.74 	<.0001 


;

*yaupon;
proc genmod data=ilvo12; title 'ilvo 2012';
class burn ;
  model totilvo = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat2 out=glmout2;
run;
proc univariate data=glmout2 plot normal; var ehat2;
run;
*AIC=140.1959
Shapiro-Wilk: W=0.9464, P=0.3428
LR Type 3 Analysis--
burn: df=3, chi-square=8.78, P=0.0324
LSmeans: 
burn 	Estimate 	Standard Error  z Value  Pr > |z| 
1 		5.3356 		0.3993 			13.36 	<.0001 
2 		4.1363 		0.3398 			12.17 	<.0001 
3 		2.9957 		0.9178 			3.26 	0.0011 
4 		3.9943 		0.3403 			11.74 	<.0001 


;




*************************AFE POSTER results, year 2013****************************;
proc genmod data=tot13; title 'loblolly 2013';
class burn ;
  model totpita = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat4 out=glmout4;
run;
proc univariate data=glmout4 plot normal; var ehat4;
run;
*AIC=224.86 (better than poisson, around 750)
Shapiro-Wilk: W=0.93, P=0.0108
LR Type 3 Analysis--
burn: df=3, chi-square=6.21, P=0.1018
LSmeans: 
burn 	Estimate 	Standard Error  z Value  Pr > |z| 
1 		1.7228 		0.6374 			2.70 	0.0069 
2 		2.9653 		0.4364 			6.79 	<.0001 
3 		2.6672 		0.4385 			6.08 	<.0001 
4 		2.5649 		0.3032 			8.46 	<.0001 


;

proc genmod data=tot13; title 'sand post 2013';
class burn ;
  model totquma = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat5 out=glmout5;
run;
proc univariate data=glmout5 plot normal; var ehat5;
run;
*AIC=140.1959
Shapiro-Wilk: W=0.7652, P<0.0001 ---non-normal residuals
LR Type 3 Analysis--
burn: df=3, chi-square=5.54, P=0.1364
LSmeans: 
burn 	Estimate 	Standard Error  z Value  Pr > |z| 
1 		2.5494 		1.1086 			2.30 	0.0215 
2 		1.9021 		0.7884 			2.41 	0.0158 
3 		0.9163 		0.8042 			1.14 	0.2545 
4 		0.5664 		0.5621 			1.01 	0.3136 


;

proc genmod data=tot13; title 'blackjack 2013';
class burn ;
  model totquma3 = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat6 out=glmout6;
run;
proc univariate data=glmout6 plot normal; var ehat6;
run;
*AIC=169.6919
Shapiro-Wilk: W=0.846, P=0.0055
LR Type 3 Analysis--
burn: df=3, chi-square=9.14, P=0.0275 
LSmeans: 
burn 	Estimate 	Standard Error 	z Value 	Pr > |z| 
1 		-21.9922 	26673 			-0.00 		0.9993    ****crazy estimate and SE, only 2 obs
2 		2.4932 		0.6891 			3.62 		0.0003 
3 		2.2083 		0.6911 			3.20 		0.0014 
4 		2.1260 		0.4774 			4.45 		<.0001 


;

proc genmod data=tot13; title 'all oaks 2013';
class burn ;
  model totoaks = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat2 out=glmout2;
run;
proc univariate data=glmout2 plot normal; var ehat2;
run;
*AIC=140.1959
Shapiro-Wilk: W=0.9447, P=0.0654
LR Type 3 Analysis--
burn: df=3, chi-square=0.57, P=0.9040
LSmeans: 
burn 	Estimate 	Standard Error  z Value  Pr > |z| 
1 		2.7726 		0.5486 			5.05 	<.0001 
2 		2.9339 		0.3456 			8.49 	<.0001 
3 		2.5564 		0.3680 			6.95 	<.0001 
4 		2.7222 		0.2936 			9.27 	<.0001 


;

*yaupon;
proc genmod data=ilvo13; title 'ilvo 2013';
class burn ;
  model totilvo = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat2 out=glmout2;
run;
proc univariate data=glmout2 plot normal; var ehat2;
run;
*AIC=140.1959
Shapiro-Wilk: W=0.8943, P=0.0006
LR Type 3 Analysis--
burn: df=3, chi-square=4.99, P=0.1728
LSmeans: 
burn 	Estimate 	Standard Error  z Value  Pr > |z| 
1 		5.1240 		0.8620 			5.94 	<.0001 
2 		3.9336 		0.6376 			6.17 	<.0001 
3 		3.0819 		0.6707 			4.59 	<.0001 
4 		3.3763 		0.4860 			6.95 	<.0001 



;




**herbaceous richness;
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
proc sort data=herbs5; by burn plot; run; 
proc sort data=herbs5; by year burn plot hspp;
proc means data=herbs5 n noprint ; by year burn plot hspp;
	output out=out1 n=n; run;

proc means data=out1 n; by year burn plot;
	output out=out2 n=richness;
proc print data=out2; run;


data herb12; set out2; if (year = "2012"); run;
proc sort data=herb12; by plot year burn;
proc print data = herb12; run; *N = 32 observations;

data herb13; set out2; if (year = "2013"); run;
proc sort data=herb13; by plot year burn;
proc print data = herb13; run; *N = 46 observations;

proc genmod data=herb12; title 'richness 2012';
class burn;
  model richness = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat7 out=glmout7;
run;
proc univariate data=glmout7 plot normal; var ehat7;
run;
*AIC=169.6919
Shapiro-Wilk: W=0.9812, P=0.8363
LR Type 3 Analysis--
burn: df=3, chi-square=10.12, P=0.0176 * 
LSmeans: 
burn 	Estimate 	Standard Error 	z Value 	Pr > |z| 
1 		2.7973 		0.1123 			24.90 		<.0001 
2 		2.9267 		0.07865 		37.21 		<.0001 
3 		2.4709 		0.1201 			20.57 		<.0001 
4 		2.8670 		0.07011 		40.89 		<.0001 


;

proc genmod data=herb13; title 'richness 2013';
class burn;
  model richness = burn/ dist = negbin link=log type1 type3;
  lsmeans burn;
  contrast 'levels of burn: 1 v 2' burn 1 -1 0 0 / E;
  contrast 'levels of burn: 1 v 3' burn 1 0 -1 0 / E;
  contrast 'levels of burn: 1 v 4' burn 1 0 0 -4 / E;
  contrast 'levels of burn: 2 v 3' burn 0 1 -1 0 / E;
  contrast 'levels of burn: 2 v 4' burn 0 1 0 -1 / E;
  contrast 'levels of burn: 3 v 4' burn 0 0 1 -1/ E;
  output reslik=ehat7 out=glmout7;
run;
proc univariate data=glmout7 plot normal; var ehat7;
run;
*AIC=169.6919
Shapiro-Wilk: W=0.970722, P=0.2946
LR Type 3 Analysis--
burn: df=3, chi-square=1.56, P=0.6693 
LSmeans: 
burn 	Estimate 	Standard Error 	z Value 	Pr > |z| 
1 		2.9857 		0.1349 			22.14 		<.0001 
2 		3.0634 		0.09336 		32.81 		<.0001 
3 		3.0155 		0.09458 		31.88 		<.0001 
4 		3.1293 		0.06331 		49.43 		<.0001 


;

