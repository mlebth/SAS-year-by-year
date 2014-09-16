OPTIONS FORMCHAR="|----|+|---+=|-/\<>*";
*--------------------------------------- seedlings -----------------------------------------------------;
*VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\seedlingstest2.csv"
out=cjseedling 
dbms=csv replace;
getnames=yes;
run;
  * N = 208;

proc sort data=cjseedling; by plot;
proc means data=cjseedling noprint n; by plot;
  output out=cjseedling2 n=n;
proc print data=cjseedling2; title 'seedling2'; * N = 46 plots;
run;

data cjseedling1; set cjseedling;
  if (sspp NE 'XXXX' | sspp NE 'XXXX ');

proc sort data=cjseedling1; by plot sspp shgt snum; run;
proc sort data=seedling1; by plot sspp shgt snum; run;
proc compare base=seedling1 compare=cjseedling1 brief; by plot; id plot; run;

*--------------------------------------- overstory -----------------------------------------------------;
*VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\overstorytest2.csv"
out=cjoverstory (drop=date)
dbms=csv replace;
getnames=yes;
run;
 * N = 274;
proc freq data = cjoverstory; tables ospp; run;

proc sort data=cjoverstory; by plot;
proc means data=cjoverstory noprint n; by plot;
  output out=cjoverstory2 n=n;
proc print data=cjoverstory2; title 'overstory2'; * N = 46 plots;
run;

data cjoverstory1; set cjoverstory;
  if (ospp NE 'XXXX' | ospp NE 'XXXX ');
proc sort data=cjoverstory1; by plot ospp oqtr otag ostt odbh ocrn; run;
proc sort data=overstory1; by plot ospp oqtr otag ostt odbh ocrn; run;
proc compare base=overstory1 compare=cjoverstory1 brief; by plot; id plot; run;

*--------------------------------------- pole trees -----------------------------------------------------;
*VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\poletreestest2.csv"
out=cjpoles (keep=plot pspp pdbh phgt)
dbms=csv replace;
getnames=yes;
run;
 * N = 75;

proc sort data=cjpoles; by plot;
proc means data=cjpoles noprint n; by plot;
  output out=cjpoles2 n=n;
proc print data=cjpoles2; title 'poles2'; * N = 46 plots;
run;

data cjpoles1; set cjpoles;
  if (pspp NE 'XXXX' | pspp NE 'XXXX ');
proc sort data=cjpoles; by plot pspp; run;
proc sort data=poles; by plot pspp; run;
proc compare base=poles compare=cjpoles brief; by plot; id plot; run;

*--------------------------------------- herbaceous -----------------------------------------------------;
*VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\herbaceoustest2.csv"
out=cjherbs
dbms=csv replace;
getnames=yes;
run;
 * N = 2528 (eb 2564);

proc sort data=cjherbs; by plot;
proc means data=cjherbs noprint n; by plot;
  output out=cjherbs2 n=n;
proc print data=cjherbs2; title 'herbs2'; * N = 46 plots;
run;

proc sort data=cjherbs; by plot hspp hqua hnum; run;
proc sort data=herbs2; by plot hspp hqua hnum; run;
proc compare base=herbs2 compare=cjherbs brief; by plot; id plot; run;

*--------------------------------------- transect -----------------------------------------------------;
*NOT VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\transecttest2.csv"
out=cjtransect (drop=date ttpe)
dbms=csv replace;
getnames=yes;
run;

proc sort data=cjtransect; by plot; 
proc means data=cjtransect noprint n; by plot;
  output out=cjtransect2 n=n;
proc print data=cjtransect2; title 'transect2'; * N = 46 plots;
run;

proc contents data=cjtransect; run;
proc contents data=transect; run;

proc sort data=cjtransect; by plot tspp tpnt thgt; run;
proc sort data=transect; by plot tspp tpnt thgt; run;
proc compare base=transect compare=cjtransect ; by plot; id plot; run;

*--------------------------------------- shrubs -----------------------------------------------------;
*VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\shrubstest2.csv"
out=cjshrubs
dbms=csv replace;
getnames=yes;
run;
 * N = 128;

data shrubs4; set cjshrubs;
  if (shsp NE 'XXXX' | shsp NE 'XXXX ');

proc sort data=shrubs4; by plot;
proc means data=shrubs4 noprint n; by plot;
  output out=shrubs3 n=n;
proc print data=shrubs3; title 'shrubs2'; * N = 46 plots;
run;

proc sort data=shrubs3; by plot shsp shac shno; run;
proc sort data=shrubs; by plot shsp shac shno; run;
proc compare base=shrubs compare=shrubs3 brief; by plot; id plot; run;

*--------------------------------------- canopy cover -----------------------------------------------------;
*VALIDATED;
proc import datafile="G:\Excel Files\ffitestdata\canopytest2.csv"
out=cjcanopy
dbms=csv replace;
getnames=yes;
run;
* N = 44;
proc sort data=cjcanopy; by plot;
proc print data=cjcanopy; title 'canopy'; run;

proc sort data=cjcanopy; by plot; run;
proc sort data=canopy; by plot; run;
proc compare base=canopy compare=cjcanopy brief; by plot; id plot; run;
