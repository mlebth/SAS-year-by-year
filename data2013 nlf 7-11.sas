OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";
*--------------------------------------- plot history -----------------------------------------------------;
proc import datafile="h:\Excel Files\plothistory.csv"
out=hist 
dbms=csv replace;
getnames=yes;
run;
proc contents data=hist; title 'hist'; run;
proc print data=hist; run;  * N = 44;
proc sort data=hist; by plot sirx burn ; run;
* plot history data in this file;
* variables: 
   burn (s, l, m, h) = wildfire severity
   hydr (n, l, h) = hydromulch [needs completing]
   yrrx = year of last prescribed burn
   plot = fmh plot #
   sirx = years between last prescribed burn and 2013 (sirx = since prescribed);
data hist2; set hist;
   if yrrx = 9999 then yrrx = .;
   yrsincerx = 2013 - yrrx;
   * chk1 = yrsincerx - sirx;
   drop sirx;
   if (yrsincerx = .) then yrcat = 'nev';
   if (yrsincerx = 2| yrsincerx = 5 | yrsincerx = 6) then yrcat = 'rec';
   if (yrsincerx = 8 | yrsincerx = 10) then yrcat = 'old';
   if (burn = 'h') then bcat1 = 'H';
   if (burn = 'm' | burn = 'l' | burn = 's') then bcat1 = 'L';
   if (burn = 'h') then bcat2 = 'H';
   if (burn = 'm') then bcat2 = 'M';
   if (burn = 's' | burn = 'l') then bcat2 = 'L';
proc print data=hist2; title 'hist2';
proc freq data=hist2; tables burn*yrsincerx bcat1*yrcat bcat2*yrcat / fisher expected;
run;


*--------------------------------------- seedlings -----------------------------------------------------;
proc import datafile="h:\Excel Files\seedlings2013.csv"
out=seedling (keep=plot sspp shgt snum)
dbms=csv replace;
getnames=yes;
run;
data seedling1; set seedling;
  if (sspp NE 'XXXX' | sspp NE 'XXXX ');
proc contents data=seedling1; title 'seedling'; run;
proc print data=seedling1; run;  * N = 207;
proc freq data=seedling1; tables sspp; run;
* seedling data in this file;
* variables: 
   plot = fmh plot #
   sspp = species code
   shgt = height
   snum = number of seedlings;
/*
data empty; set seedling; if sspp="XXXX";
 holder = 0; * N = 1;
proc print data=empty; title 'empty';
run;
*/
*---- # of obs of each plot -------------------;
proc sort data=seedling1; by plot;
data seedling2; merge hist2 seedling1; by plot; run;
proc print data=seedling2; title 'datreorg'; run;



* ---- get plot-level information, pooling species -----;
proc sort data=seedling2; by burn bcat1 bcat2 yrcat yrsincerx plot; run;
proc means data=seedling2 noprint n mean sum; by burn bcat1 bcat2 yrcat yrsincerx plot;  
  var shgt snum;
  output out=seedling3 n=plantno plantnox 
                       mean = mhgt mstems 
                       sum  = sumhgt sumstems; * # records/species/plot;
proc print data=seedling3; title 'seedling3'; run;
* N = 207 species-plot combinations, 44 plots;
* plantno = number of plants/plot  
  plantnox is redundant
  mhgt = average ht of all plants in the plot
  mstems = avage # stems/plant in the plot
  sumhgt = junk?
  sumstems = # of stems of all species in the plot;
proc univariate data=seedling3 normal plot; title 'seedling3';
  var plantno sumstems mhgt;
run;

data seedling4; set seedling3;
  if plantno = 0 then plantno = .;
  logplantno = log10(plantno); logsumstems = log10(sumstems);
  logmhgt = log10(mhgt);
  drop plantnox sumhgt mstems;
run;
proc glm data=seedling4;
  class burn bcat1 bcat2 yrcat;
  * model sumstems = bcat2 yrcat bcat2*yrcat;
  model logsumstems = burn yrcat burn*yrcat;
  lsmeans burn*yrcat / stderr;
  output out=glmout1 r=ehat;
run;
proc univariate data=glmout1 plot normal; var ehat;
run;

*---- nlf stopped here July 11, 2013;

*--------------------------------------- overstory -----------------------------------------------------;
proc import datafile="h:\Excel Files\overstory2013.csv"
out=overstory (keep=plot ospp ostt odbh)
dbms=csv replace;
getnames=yes;
run;
proc contents data=overstory; title 'overstory'; run;
proc print data=overstory; run;  * N = 274;
proc freq data=overstory; tables ospp; run;
* overstory tree data in this file;
* variables: 
   plot = fmh plot #
   ospp = species code
   ostt = status (L/D)
   odbh = DBH;

*dataset with number of species per plot;
proc sort data=overstory; by plot;
proc means data=overstory noprint n; by plot;
  output out=overstory2 n=n;
proc contents data=overstory2; run;
proc print data=overstory2; title 'overstory2'; * N = 44 plots;
run;

*---- # of obs of each plot -------------------;
proc sort data=overstory2; by plot;
data overstory3; merge hist overstory; by plot; run;
proc print data=overstory3; title 'datreorg'; run;
proc means data=overstory3 noprint n; by plot ; * pooling points;
  output out=overstory4 n=n; * # records/species/plot;
data overstory5; set overstory4; trno = n;
	proc print data=overstory5; title 'overstory5'; run; * N = 274 species-plot combinations, 44 plots;
	proc contents data=overstory5; title 'overstory5'; run;
data overstory6; merge hist overstory5; by plot; run;
proc print data=overstory6; title'overstory6'; run;
proc freq data=overstory6; tables burn*sirx; run;

proc univariate data=overstory6 normal plot; title 'overstory6'; 
run;
*(trno): Skewness = 2.3436, kurtosis = 5.2380. Shapiro-Wilk: W=0.5932, p < 0.0001;

*--------------------------------------- pole trees -----------------------------------------------------;
proc import datafile="h:\Excel Files\poletrees2013.csv"
out=poles (keep=plot pspp pdbh phgt)
dbms=csv replace;
getnames=yes;
run;
proc contents data=poles; title 'poles'; run;
proc print data=poles; run;  * N = 75;
proc freq data=poles; tables pspp; run;
* pole tree data in this file;
* variables: 
   plot = fmh plot #
   pspp = species code
   pdbh = DBH
   phgt = height code;

*dataset with number of species per plot;
proc sort data=poles; by plot;
proc means data=poles noprint n; by plot;
  output out=poles2 n=n;
proc contents data=poles2; run;
proc print data=poles2; title 'poles2'; * N = 44 plots;
run;

*---- # of obs of each plot -------------------;
proc sort data=poles2; by plot;
data poles3; merge hist poles; by plot; run;
proc print data=overstory3; title 'datreorg'; run;
proc means data=poles3 noprint n; by plot ; * pooling points;
  output out=poles4 n=n; * # records/species/plot;
data poles5; set poles4; trnum = n;
	proc print data=poles5; title 'poles5'; run; * N = 274 species-plot combinations, 44 plots;
	proc contents data=poles5; title 'poles5'; run;
data poles6; merge hist poles5; by plot; run;
proc print data=poles6; title'poles6'; run;
proc freq data=poles6; tables burn*sirx; run;

proc univariate data=poles6 normal plot; title 'poles6'; 
run;
*(trno): Skewness = 4.9230, kurtosis = 25.1437. Shapiro-Wilk: W=0.2460, p < 0.0001;

*--------------------------------------- herbaceous -----------------------------------------------------;
proc import datafile="h:\Excel Files\herbaceous2013.csv"
out=herbs (keep=plot hspp hnum)
dbms=csv replace;
getnames=yes;
run;
proc contents data=herbs; title 'herbs'; run;
proc print data=herbs; run;  * N = 2465;
proc freq data=herbs; tables hspp; run;
* herbaceous (quadrat) data in this file;
* variables: 
   plot = fmh plot #
   hspp = species code
   hnum = stem number;

*dataset with number of species per plot;
proc sort data=herbs; by plot;
proc means data=herbs noprint n; by plot;
  output out=herbs2 n=n;
proc contents data=herbs2; run;
proc print data=herbs2; title 'herbs2'; * N = 44 plots;
run;

*---- # of obs of each plot -------------------;
proc sort data=herbs2; by plot;
data herbs3; merge hist herbs; by plot; run;
proc print data=herbs3; title 'datreorg'; run;
proc means data=herbs3 noprint n; by plot ; * pooling points;
  output out=herbs4 n=n; * # records/species/plot;
data herbs5; set herbs4; stno = n;
	proc print data=herbs5; title 'herbs5'; run; * N = 2465 species-plot combinations, 44 plots;
	proc contents data=herbs5; title 'herbs5'; run;
data herbs6; merge hist herbs5; by plot; run;
proc print data=herbs6; title'herbs6'; run;
proc freq data=herbs6; tables burn*sirx; run;

proc univariate data=herbs6 normal plot; title 'herbs6'; 
run;
*(stno): Skewness = 0.6143, kurtosis = 0.1676. Shapiro-Wilk: W=0.9708, p = 0.3226;

*--------------------------------------- transect -----------------------------------------------------;
proc import datafile="h:\Excel Files\transect2013.csv"
out=transect (keep=plot tspp tpnt thgt)
dbms=csv replace;
getnames=yes;
run;
proc contents data=transect; title 'transect'; run;
proc print data=transect; run;  * N = 9456;
proc freq data=transect; tables tspp; run;
* point transect data in this file;
* variables: 
   plot = fmh plot #
   tspp = species code
   tpnt = point number along transect
   thgt = height;

*dataset with number of species per plot;
proc sort data=transect; by plot;
proc means data=transect noprint n; by plot;
  output out=transect2 n=n;
proc contents data=transect2; run;
proc print data=transect2; title 'transect2'; * N = 44 plots;
run;

*---- # of obs of each plot -------------------;
proc sort data=transect2; by plot;
data transect3; merge hist transect; by plot; run;
proc print data=transect3; title 'datreorg'; run;
proc means data=transect3 noprint n; by plot ; * pooling points;
  output out=transect4 n=n; * # records/species/plot;
data transect5; set transect4; stnum = n;
	proc print data=transect5; title 'transect5'; run; * N = 9456 species-plot combinations, 44 plots;
	proc contents data=transect5; title 'transect5'; run;
data transect6; merge hist transect5; by plot; run;
proc print data=transect6; title'transect6'; run;
proc freq data=transect6; tables burn*sirx; run;

proc univariate data=transect6 normal plot; title 'transect6'; 
run;
*(stno): Skewness = 0.8772, kurtosis = 0.2752. Shapiro-Wilk: W=0.9280, p = 0.0089;

*--------------------------------------- shrubs -----------------------------------------------------;
proc import datafile="h:\Excel Files\shrubs2013.csv"
out=shrubs (drop=date)
dbms=csv replace;
getnames=yes;
run;
proc contents data=shrubs; title 'shrubs'; run;
proc print data=shrubs; run;  * N = 128;
proc freq data=shrubs; tables shsp; run;
* shrub data in this file;
* variables: 
   shpl = fmh plot #
   shsp = species code
   shac = age class (I/R/M)
   shno = stem number;

*dataset with number of species per plot;
proc sort data=shrubs; by plot;
proc means data=shrubs noprint n; by plot;
  output out=shrubs2 n=n;
proc contents data=shrubs2; run;
proc print data=shrubs2; title 'shrubs2'; * N = 44 plots;
run;

*---- # of obs of each plot -------------------;
proc sort data=shrubs2; by plot;
data shrubs3; merge hist shrubs; by plot; run;
proc print data=shrubs3; title 'datreorg'; run;
proc means data=shrubs3 noprint n; by plot ; * pooling points;
  output out=shrubs4 n=n; * # records/species/plot;
data shrubs5; set shrubs4; stno = n;
	proc print data=shrubs5; title 'shrubs5'; run; * N = 128 species-plot combinations, 44 plots;
	proc contents data=shrubs5; title 'shrubs5'; run;
data shrubs6; merge hist shrubs5; by plot; run;
proc print data=shrubs6; title'shrubs6'; run;
proc freq data=shrubs6; tables burn*sirx; run;

proc univariate data=shrubs6 normal plot; title 'shrubs6'; 
run;
*(stno): Skewness = 1.3040, kurtosis = 2.2681. Shapiro-Wilk: W=0.8509, p < 0.0001;


*--------------------------------------- canopy cover -----------------------------------------------------;
proc import datafile="h:\Excel Files\canopycover2013.csv"
out=canopy
dbms=csv replace;
getnames=yes;
run;
proc contents data=canopy; title 'canopy cover'; run;
proc print data=canopy; run;  * N = 44;
proc sort data=canopy; by plot;
* shrub data in this file;
* variables: 
   plot = fmh plot #
   date
   crecorder
   **a-d = percent open canopy at each corner and origin. 4 measurements per location;

*--------------------------------------- merge files -----------------------------------------------------;
data datreorg; merge hist seedling overstory poles herbs transect shrubs ; by plot;
proc print data=datreorg; title 'datreorg';
run;

*dataset with number of species per plot;
proc means data=datreorg noprint n; by plot;
  output out=datreorg2 n=n;
  proc contents data=datreorg2; run;
proc print data=datreorg2; title 'datreorg2'; * N = 44 plots;
run;

*---- # of obs of each plot -------------------;
data datreorg3; merge hist datreorg; by plot; run;
proc print data=datreorg3; title 'datreorg'; run;
proc means data=datreorg3 noprint n; by plot ; * pooling points;
  output out=datreorg4 n=n; * # records/species/plot;
data datreorg5; set datreorg4; stno = n;
	proc print data=datreorg5; title 'datreorg5'; run; * N = 9456 species-plot combinations, 44 plots;
	proc contents data=datreorg6; title 'datreorg5'; run;
data datreorg6; merge hist datreorg5; by plot; run;
proc print data=datreorg6; title'datreorg6'; run;
proc freq data=datreorg6; tables burn*sirx; run;

proc univariate data=datreorg6 normal plot; title 'datreorg6'; 
run;
*(stno): Skewness = 0.8772, kurtosis = 0.2752. Shapiro-Wilk: W=0.9279, p = 0.0089;




















*--------------------------------------- 2012 ---------------------------------------*

* --- analyze only plots without mulch, no pooling----;
data nomulch; set dattotn; if hydromulch = 'n';  * N = 14;
proc print data=nomulch; title 'nomulch';
run;
* pita - ols;
proc glm data=nomulch; class burnsev;
  model totpita = burnsev;
  output out=gout1 r=ehat;
proc univariate data=gout1 normal plot; var ehat;
run;
* pita - genmod;
proc genmod data=nomulch; class burnsev;
  model totpita = burnsev/ dist = negbin link=log type1 type3;
run;
* dispersion =  2.2050; 
* burnsev  df=4, X2 = 9.85, P = 0.0430;  * df issues!;
* quma - genmod;
proc genmod data=nomulch; class burnsev;
  model totquma = burnsev/ dist = negbin link=log type1 type3;
run; * NS;

* ---- analyze only plots without mulch, with pooling;
data nomulchpool; set nomulch;
  if (burnsev='u'|burnsev='s') then burn='L1';
  if (burnsev='l') then burn='L2';
*  if (burnsev='m'|burnsev='h') then burn='L3'; * not used;
  if (burnsev='m') then burn='L3';
  if (burnsev='h') then burn='L4';

* pita - genmod;
proc genmod data=nomulchpool; class burn;
  model totpita = burn/ dist = negbin link=log type1 type3;
run;
* dispersion =  2.7647;
* burn df=3 X2 = 7.17  P = 0.0666;

proc genmod data=nomulchpool; class burn;
  model totquma = burn/ dist = negbin link=log type1 type3;
run; * NS;


* ---- analyze only burned plots ------;
data allburn; set dattotn;
  if (burnsev='l'|burnsev='m'|burnsev='h'); * N = 19;
proc print data=allburn; title 'allburn';
run;
* pita;
proc genmod data=allburn; class burnsev hydromulch;
  model totpita = burnsev hydromulch / dist = negbin link=log type1 type3;
run;
* dispersion =  1.7247
  type 1
  burnsev df=2 X2=4.00 P = 0.1351 hydromulch df=2 X2 = 14.34 P = 0.0008
  hydromulch df=2 X2=7.32 P = 0.0257 burnsev df=2 X2=11.02 P = 0.0040
  type 3 - use these - order does not matter for type3 -  
  burnsev df=2, X2 = 11.02 P = 0.0040
  hydromulch df=2 X2 = 14.34  P = 0.0008;
proc genmod data=allburn; class burnsev hydromulch;
  model totpita =  hydromulch burnsev / dist = negbin link=log type1 type3;
run;

proc genmod data=allburn; class burnsev hydromulch;
  model totpita =  hydromulch burnsev hydromulch*burnsev/
     dist = negbin link=log type1 type3;
* interaction NS;
run;
* oak; 
proc genmod data=allburn; class burnsev hydromulch;
  model totquma = burnsev hydromulch / dist = poisson link=log type1 type3;
run;
* type 3 burnsev df=2 X2=3.71 P = 0.1567
         hydromulch  df=2  X2=10.91 P=0.0043;

proc genmod data=allburn; class burnsev hydromulch;
  model totquma = burnsev hydromulch  burnsev*hydromulch/ dist = poisson link=log type1 type3;
run;
* use this - note type 1 not type 3 - no type3 reported.
* type 1 burnsev df=2 X2=3.66 P = 0.1603
         hydromulch  df=2  X2=10.91 P=0.0043
         int df=3 X2=17.59 P = 0.0005;








*--------------------------------------- shrubs -----------------------------------------------------;

proc import datafile="F:\Research\2013 Spring\data2012excel.xls"
out=shrub0
dbms=excel replace; sheet=shrubs;
getnames=yes;
run;
proc contents data=shrub0; run;
proc print data=shrub0; title 'shrubdata'; run;  * N = 26;
* shrub data in this file;
* variables: 
   number of shrubs per plot from 0-30 on transect for species:
   caam, cevi, gavo, ilvo, ruri, smbo, topu
   plot = fmh code
   hydromulch (n,l,y)
   burnsev (u,s,l,m,h);
* for sigmaplot;
data shrub; set shrub0;
  * makes new set of treatment names with natural ordering for graphs and constrasts;
  if hydromulch = 'n' then hm = 1;
  if hydromulch = 'l' then hm = 2;
  if hydromulch = 'h' then hm = 3;
  if burnsev = 'u' then bs = 1;
  if burnsev = 's' then bs = 2;
  if burnsev = 'l' then bs = 3;
  if burnsev = 'm' then bs = 4;
  if burnsev = 'h' then bs = 5;
  * new variables pooling shrub species;
  allshrubnum = caam + cevi + gavo + ilvo + ruri + smbo + topu;
  allbutilex = caam + cevi + gavo + ruri + smbo + topu;
  * poolingA - combine only unburned and scorch;
  if (burnsev='u'|burnsev='s') then burn='AL1';
  if (burnsev='l') then burn='AL2';
  if (burnsev='m') then burn='AL3';
  if (burnsev='h') then burn='AL4'; 
  * poolingB - combine unburned + scorch, combine light, moderate, heavy burns;
  if (burnsev='u'|burnsev='s') then burn='BL1';
  if (burnsev='l'|burnsev='m'|burnsev='h') then burn='BL2'; 
run;

proc sort data=shrub; by bs hm;
proc means data=shrub noprint mean; by bs hm;
   var caam cevi gavo ilvo ruri smbo topu;
   output out=mout1 mean = mcaam mcevi mgavo milvo mruri msmbo mtopu;
proc print data=mout1; title 'mout1';
run;

* --- analyze only plots without mulch, no pooling (ilvo)----;
data nomulchshrub; set shrub; if hydromulch = 'n';  * N = 14;
proc print data=nomulchshrub; title 'nomulchshrubs';
run;
* ilvo - ols;
proc glm data=nomulchshrub; class burnsev;
  model ilvo = burnsev;
  output out=gout1 r=ehat;
proc univariate data=gout1 normal plot; title 'ilvo ols'; var ehat;
run;
*Skewness = 2.0981, kurtosis = 7.0373

* ilvo - genmod;
proc genmod data=nomulchshrub; class burnsev; title'ilvo genmod';
  model ilvo = burnsev/ dist = negbin link=log type1 type3;
run;
* dispersion =  1.2525; 
* burnsev  df=4, X2 = 4.25, P = 0.3737;  *NS;

* ---- analyze only plots without mulch, with pooling;
data nomulchpool; set nomulchshrub;


run;
* ilvo - genmod;
proc genmod data=nomulchpool; class burn;
  * model ilvo = burn/ dist = negbin link=log type1 type3;
  model allbutilex = burn/ dist = negbin link=log type1 type3;
run;
* dispersion =  1.2526;
* burn df=3 X2 = 4.25  P = 0.2361 *NS;

* ---- analyze only burned plots ------;
data allburn; set shrub;
  if (burnsev='l'|burnsev='m'|burnsev='h'); * N = 19;
proc print data=allburn; title 'allburn';
run;
* ilvo;
proc genmod data=allburn; class burnsev hydromulch;
  model ilvo = burnsev hydromulch / dist = negbin link=log type1 type3;
run;
* dispersion =  0.3458
  type 1
  burnsev df=2 X2=2.26 P = 0.3223 hydromulch df=2 X2 = 1.30 P = 0.5230 *NS
  hydromulch df=2 X2=2.85 P = 0.2402 burnsev df=2 X2=0.71 P = 0.7017 *NS
  type 3 - use these - order does not matter for type3 -  
  burnsev df=2, X2 = 0.71 P = 0.7017 *NS
  hydromulch df=2 X2 = 1.30  P = 0.5230 *NS;
proc genmod data=allburn; class burnsev hydromulch;
  model ilvo =  hydromulch burnsev / dist = negbin link=log type1 type3;
run;

proc genmod data=allburn; class burnsev hydromulch;
  model ilvo =  hydromulch burnsev hydromulch*burnsev/
     dist = negbin link=log type1 type3;
run;
* interaction NS;













*--------------------------------------- herbaceous -----------------------------------------------------;
*What do I want to find? 
	percent bare -- sort by treatment type
	species richness
	abundances of each species;
proc import datafile="G:\Excel Files\data2012.xls"
out=herb (keep=plot hydromulch burnsev date hgt point spp count)
dbms=xls replace; sheet=herbaceous;
getnames=yes;
run;
proc contents data=herb; run;
proc print data=herb; title 'herbaceous'; run;  * N = 4384 observations;
* herbaceous data in this file;
* variables: 
   plot = fmh code
   hydromulch (n,l,y)
   burnsev (u,s,l,m,h)
   date = date data was collected (ddmonyy)
   hgt = height of tallest plant (cm)
   point = point on transect tape (m)
   spp = species code
   count = number of plants at each point of each species. always = 1;;

proc sort data=herb; by hydromulch burnsev plot spp;
proc print data=herb; title 'by species'; run;
proc freq data=herb; tables spp; run;

data datchk1; set herb; if count ^= 1;
proc print data=datchk1; title 'check1';
run;


*dataset with number of species (including bare) per plot;
proc means data=herb noprint n; by hydromulch burnsev plot spp; * pooling points;
	output out=herb2 n=n; run;  * # records/species/plot;
	proc print data=herb2; title 'herb2'; run; * N = 200 species-plot combinations, 26 plots;
	proc contents data=herb2; title 'herb2'; run;

*---- # of obs of each plot -------------------;
proc sort data=herb2; by hydromulch burnsev plot ;
proc means data=herb2 noprint n; by hydromulch burnsev plot ;
  output out=herb3 n=n;
data herb4; set herb3; spnum = n; 
proc print data=herb4; title 'herb4'; 
run;
proc freq data=herb4; tables burnsev*hydromulch; run;

proc univariate data=herb4 normal plot; title 'herb4'; 
run;
*(spnum): Skewness = 0.8373, kurtosis = -0.0164. Shapiro-Wilk: W=0.8883, p = 0.0087;

* ---- analyze only plots without mulch, with pooling;
data nomulchherb; set herb3; if hydromulch = 'n';  * N = 15 plots;
proc print data=nomulchherb; title 'nomulchherb';
run;

data nomulchherb1; set nomulchherb;
  if (burnsev='u'|burnsev='s') then burn='L1';
  if (burnsev='l') then burn='L2';
  if (burnsev='m') then burn='L3';
  if (burnsev='h') then burn='L4';

 proc genmod data=nomulchherb1; class burn;
  model spnum = burn / dist = poisson link=log type1 type3; title 'no mulch pooled poisson';
run;
* burnsev NS: df= 3 X2 = 3.07 P = 0.3807 
BUT scale predictor Value/DF > 1 (1.8186)....use negative binomial distribution;

proc genmod data=nomulchherb1; class burn;
  model spnum = burn / dist = negbin link=log type1 type3; title 'no mulch pooled negbin';
run;
* burnsev NS: df= 3 X2 = 2.12  P = 0.5485 
Value/DF = 1.3217....a little better;

* ---- analyze only burned plots ------;
data allburn; set herb3;
  if (burnsev='l'|burnsev='m'|burnsev='h'); * N = 19;
proc print data=allburn; title 'allburn';
run;

proc genmod data=allburn; class burnsev hydromulch;
  model spnum = burnsev hydromulch / dist = poisson link=log type1 type3; title 'all burn poisson';
run;
*Value/DF =1.3169....use negative binomial distribution;

proc genmod data=allburn; class burnsev hydromulch;
  model spnum = burnsev hydromulch / dist = negbin link=log type1 type3; title 'all burn negbin';
run;
*Value/DF =1.2615--not much different;
* type 1
  burnsev df= 2 X2= 0.23 P = 0.8898 hydromulch df= 2 X2 = 0.49 P = 0.7831
  hydromulch df= 2 X2= 0.46 P = 0.7955 burnsev df= 2 X2= 0.26 P = 0.8760
* type 3  
  burnsev df= 2, X2 = 0.26 P = 0.8760
  hydromulch df= 2 X2 = 0.49  P = 0.7831;



/* ################ IGNORE---VARIABLES NOT SIG
proc genmod data=allburn; class burnsev hydromulch;
  model _FREQ_ =  hydromulch burnsev hydromulch*burnsev/
     dist = poisson link=log type1 type3;
run;
* interaction: ??; */


