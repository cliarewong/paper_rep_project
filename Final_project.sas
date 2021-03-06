options compress=yes linesize=150;

%let mepsdata=/schaeffer-a/sch-projects/STUDENTS/courses/PMEP547/PublicUse/yangzi/Data;

libname meps "&mepsdata";
libname output "/schaeffer-a/sch-projects/STUDENTS/courses/PMEP547/PublicUse/yangzi/SAS/Data";

/* macros to read in 8 kinds of expenditures in seperated expenses files */
%let ex1=ob;
%let ex2=op;
%let ex3=er;
%let ex4=ip;
%let ex5=rx;
%let ex6=dv;
%let ex7=hh;
%let ex8=om;
           
/* macros to adjust the 2004�C2011 medical costs to a common 2014 dollar value using the Consumer Price Index provided by the US Bureau of Labor Statistics (http://data.bls.gov/cgi-bin/cpicalc.pl). */
%let adexp2004=1.243;
%let adexp2005=1.203;
%let adexp2006=1.165;
%let adexp2007=1.133;
%let adexp2008=1.088;
%let adexp2009=1.096;
%let adexp2010=1.077;
%let adexp2011=1.044;

/* macro to loop through all years from 2004 to 2011 */
%macro do_year (begyr,endyr);
  %do yr4=&begyr %to &endyr;
  %let yr = %substr(&yr4, 3 ,2);

/* formats for raw and derived vars */
  proc format;
	 value Age_cat 0='0.No' 1='1.0-17' 2="2.18-44" 3="3.45-64" 4="4.65-85"; 
	 value Gender 1="1.Male" 2='2.Female';
	 value Race 1='1. Hispanic' 2='2.Black-Not Hispanic' 3='3.Asian-Not Hispanic' 4='4.Other Race/Not Hispanic';
	 value Marital_stat 1="1.Married" 2="2.Non-married" 3="3.Never married";
	 value Edu_cat 1="1.< High school" 2="2.High school" 3="3.College or more";
	 value Insurance 1="1.Private" 2="2.Public" 3="3.Uninsured";
	 value MSA 0="0.No_MSA" 1="1.MSA";
	 value Region 1='1.Northeast' 2='2.Midwest' 3='3.South' 4='4.West';
   value Econ_stat 1='1.Poor/Near Poor' 2='2.Low-income' 3='3.Middle-income' 4='4.High-income';
   value Hypertension 0='0.NO' 1='1.Yes';
   value CVD 0='0.NO' 1='1.Yes';
   value Stroke 0='0.NO' 1='1.Yes';
   value Emphysema 0='0.NO' 1='1.Yes';
   value Joint_pain 0='0.NO' 1='1.Yes';
   value Arthritis 0='0.NO' 1='1.Yes';
   value Asthma 0='0.NO' 1='1.Yes';
	 value Year_cat 1='1.2004/2005' 2='2.2006/2007' 3='3.2008/2009' 4='4.2010/2011';
	 value dep_cat 1="1.No depression" 2="2.Unrecognized depression" 3="3.Asymptomatic depression" 4="4.Symptomatic depression";
   value in_samp 0='0.No' 1='1.Yes';
   value adj_exp 1='Office-Based' 2='Outpatient'   3='Emergency Room Visit' 4='Inpatient' 
                 5='Prescription' 6='Dental Visit' 7='Home Health'          8='Other';
  run;
  
/* macros to deal with variables with different names in different years */
  %if &yr4  = 2004 %then %let ed=EDUCYEAR;
  %else %let ed=EDUCYR;
  
  %if &yr4 >= 2007 %then %let a=X;
  %else %let a=X53;

  data full_&yr4.      (keep = DUPERSID Age_cat Gender Race Marital_stat Edu_cat Insurance MSA Region Econ_stat
  	                           Hypertension CVD Stroke Emphysema Joint_pain Arthritis Asthma 
  	                           Year_cat dep_cat in_samp PHQ242
  	                           PERWT VARPSU VARSTR ) ;
	 set meps.full_&yr4. (keep = DUPERSID AGE&yr.X SEX RACETHNX MARRY&yr.X &ed. INSCOV&yr MSA&yr REGION&yr POVCAT&yr  
	                             HIBPD&a. CHDD&a. ANGID&a. MID&a. OHRTD&a. STRKD&a. EMPHD&a. JTPAIN53 ARTHD&a. ASTHD&a. DIABD&a. 
  	                           ENDRFY&yr PHQ242
  	                           PERWT&yr.F VARPSU VARSTR );
    /* Recodes */     
   if     AGE&yr.X=-1  then Age_cat=0;	
   if  0<=AGE&yr.X<=17 then Age_cat=1;                   
   if 18<=AGE&yr.X<=44 then Age_cat=2;
 	 if 45<=AGE&yr.X<=64 then Age_cat=3;
	 if 65<=AGE&yr.X<=85 then Age_cat=4;
	 
	 if MARRY&yr.X=1          then Marital_stat=1;
	 if MARRY&yr.X in (2,3,4) then Marital_stat=2;
	 if MARRY&yr.X=5          then Marital_stat=3;
	
	 if  0<=&ed.<=8  then Edu_cat=1; 
	 if  9<=&ed.<=13 then Edu_cat=2; 
	 if 14<=&ed.<=16 then Edu_cat=3; 
	
	 if POVCAT&yr in (1,2) then Econ_stat=1;
	 if POVCAT&yr=3        then Econ_stat=2;
	 if POVCAT&yr=4        then Econ_stat=3;
	 if POVCAT&yr=5        then Econ_stat=4;
	 
	 if HIBPD&a.=1 then Hypertension=1;
	 if HIBPD&a.=2 then Hypertension=0;
	 
	 if CHDD&a.=1 | ANGID&a.=1 | MID&a.=1 | OHRTD&a.=1 then CVD=1;
	 if CHDD&a.=2 & ANGID&a.=2 & MID&a.=2 & OHRTD&a.=2 then CVD=0;
	 
	 if STRKD&a.=1 then Stroke=1;
	 if STRKD&a.=2 then Stroke=0;
	 
	 if EMPHD&a.=1 then Emphysema=1;
	 if EMPHD&a.=2 then Emphysema=0;
	 
	 if JTPAIN53=1 then Joint_pain=1;
	 if JTPAIN53=2 then Joint_pain=0;
	 
	 if ARTHD&a.=1 then Arthritis=1;
	 if ARTHD&a.=2 then Arthritis=0;
	 
	 if ASTHD&a.=1 then Asthma=1;
	 if ASTHD&a.=2 then Asthma=0;
	 
	 if ENDRFY&yr in (2004,2005) then Year_cat=1;
	 if ENDRFY&yr in (2006,2007) then Year_cat=2;
	 if ENDRFY&yr in (2008,2009) then Year_cat=3;
	 if ENDRFY&yr in (2010,2011) then Year_cat=4;
	 
  	/* Define the in-sample observations */              
	 if DIABD&a.=1 and not missing(DIABD&a.) and AGE&yr.X>=18 and not missing(AGE&yr.X) /* this just keeps adults(age>=18) with diabetes in sample */
	 and RACETHNX >=0 and not missing(RACETHNX)/* and just keeps not missing values in sample */
	 and MARRY&yr.X >=0 and not missing(MARRY&yr.X)
	 and &ed. >=0 and not missing(&ed.)
	 and INSCOV&yr. >=0 and not missing(INSCOV&yr.)
	 and MSA&yr >=0 and not missing(MSA&yr)
	 and REGION&yr >=0 and not missing(REGION&yr)
	 and POVCAT&yr >=0 and not missing(POVCAT&yr)
	 and HIBPD&a. >=0 and not missing(HIBPD&a.)
	 and CHDD&a. >=0  and not missing(CHDD&a.)
	 and ANGID&a. >=0 and not missing(ANGID&a.)
	 and MID&a. >=0   and not missing(MID&a.)
	 and OHRTD&a. >=0 and not missing(OHRTD&a.)
	 and STRKD&a. >=0 and not missing(STRKD&a.)
	 and EMPHD&a. >=0 and not missing(EMPHD&a.)
	 and JTPAIN53 >=0 and not missing(JTPAIN53)
	 and STRKD&a. >=0 and not missing(STRKD&a.)
	 and ARTHD&a. >=0 and not missing(ARTHD&a.)
	 and STRKD&a. >=0 and not missing(STRKD&a.)
	 and EMPHD&a. >=0 and not missing(EMPHD&a.)
	 and JTPAIN53 >=0 and not missing(JTPAIN53)
	 and ARTHD&a. >=0 and not missing(ARTHD&a.)
	 and ASTHD&a. >=0 and not missing(ASTHD&a.)
	 then in_samp=1;
   else in_samp=0;
   
   /* Rename the variables so that for each year they have consistent names */ 
	 Gender = sex;
	 Region = REGION&yr;
	 Insurance = INSCOV&yr;
	 MSA = MSA&yr;
	 PERWT= PERWT&yr.F;
	 Race = RACETHNX;
	 
	 format Age_cat Age_cat.  Region Region.   MSA MSA.   Gender Gender.   Race Race.  Insurance Insurance. Marital_stat Marital_stat. Edu_cat Edu_cat. Econ_stat Econ_stat. 
	        Hypertension Hypertension. CVD CVD. Stroke Stroke.  Emphysema Emphysema. Joint_pain Joint_pain. Arthritis Arthritis. Asthma Asthma.
	        Year_cat Year_cat. in_samp in_samp.;
  run;
   /* Read in 2004-2011 Medical Conditions Files and set flag for depression, 0=No 1=Yes*/
  data cond_&yr4(keep = dupersid dep_flag);
  	 set meps.cond_&yr4. (keep= ICD9CODX DUPERSID);
  	 if ICD9CODX not in (296,300,309,311) then dep_flag=0;
  	 if ICD9CODX     in (296,300,309,311) then dep_flag=1;
  run;
  
  /* Sum depression flags as the criteria for whether the patients have depression and to prevent the duplication of dupersid when do the merge step */
  proc sql;
  	create table cond_&yr4._dep as
      	select distinct dupersid, sum(dep_flag) as dep
      	from cond_&yr4.
      	group by dupersid;
    run;

  proc sort data= full_&yr4.;
	   by dupersid;
  run;
	
  proc sort data= cond_&yr4._dep;
	   by dupersid;
  run;
  
  /* Read in 2004-2011 eight kinds of expenditure Files and adjust them to 2014 value*/
  %do c=1 %to 8;
  	proc sql;
  	create table ex_&&ex&c.._&yr4 as
      	select distinct dupersid, sum(&&ex&c..XP&yr.X)*&&adexp&yr4.. as adj_&&ex&c..
      	from meps.&&ex&c.._&yr4.
      	group by dupersid;
    run;
	%end;	

	data ex_Total_&yr4.;
	   merge ex_ob_&yr4. ex_er_&yr4. ex_ip_&yr4. ex_rx_&yr4.
	   			 ex_dv_&yr4. ex_op_&yr4. ex_hh_&yr4. ex_om_&yr4.;
	   by dupersid;
	run;
  
  /* Merge the full-year, condition and expendture files together and calculate Totalal expenditure(the sum of 8 different expenses) */
  data final_&yr4.;
     merge full_&yr4. cond_&yr4._dep ex_Total_&yr4.;
     by dupersid;
     if dep<=0 & PHQ242<3  then dep_cat=1;
     if dep<=0 & PHQ242>=3 then dep_cat=2;
     if dep>0  & PHQ242<3  then dep_cat=3;
     if dep>0  & PHQ242>=3 then dep_cat=4;
     format dep_cat dep_cat.;
     %do c=1 %to 8;
	   			 if adj_&&ex&c.. = . then adj_&&ex&c.. = 0;
		 %end;
		 if dep =. then dep=0;
		 Total=adj_ob + adj_er + adj_ip + adj_rx + adj_dv + adj_op + adj_hh + adj_om;
		 format dep_cat dep_cat.;
  run; 
  
 %end;
  
%mend do_year;

%do_year (begyr=2004, endyr=2011);

data final;
  	set final_: ;
  	if Total>0 then prob_flag=1;
  	else prob_flag=0;
  run;
  
proc print data=final (obs=19);
run;

proc print data=ex_ob_2004 (obs=19);
run;
 
ods trace on;
ods html file="Demographics.xls";
proc surveyfreq data=final /*alpha=0.1 lclm uclm*/;
	  cluster VARPSU;
	  strata VARSTR;
	  weight PERWT;
	  table in_samp*(Age_cat Gender Race Marital_stat Edu_cat Insurance MSA Region Econ_stat
  	               Hypertension CVD Stroke Emphysema Joint_pain Arthritis Asthma Year_cat)*dep_cat;
run;
ods html close;
ods trace off;

 /* Calculate Totalal Healthcare Expenditures (Mean and 95 % CI) by Depression Category Among Adults with Diabetes (Reported in 2014 Dollars)*/
ods trace on;
ods html file="Expenditure.xls";
ods output domain=tol_expen_means;
proc surveymeans data=final  ALPHA=0.05 ;
   cluster VARPSU;
   strata VARSTR;
   weight PERWT;
   domain in_samp in_samp*dep_cat in_samp*dep_cat*year_cat;
   class dep_cat;
   var Total; 
   run;
ods html close;
ods trace off;

ods output domain=tol_means;
proc surveymeans data=final  ALPHA=0.05 ;
   cluster VARPSU;
   strata VARSTR;
   weight PERWT;
   domain in_samp*dep_cat*year_cat;
   class dep_cat;
   var Total; 
   run;
ods output close;

proc print data=tol_means;
run;

data in_samp_means;
	set tol_means;
	where in_samp=1;
run;

ods output domain=exp_means;
proc surveymeans data=final  ALPHA=0.05 ;
   cluster VARPSU;
   strata VARSTR;
   weight PERWT;
   domain in_samp*dep_cat;
   class dep_cat;
   var adj_ob adj_er adj_ip adj_rx adj_op Total ;
   run;
ods output close;

proc print data=exp_means;
run;

data in_samp_exp(keep=Inpatient Prescription Office_based Outpatient Emergency_room_visit Total);
	set exp_means;
  Inpatient=adj_ip;
  Prescription=adj_rx;
  Office_based=adj_ob;
  Outpatient=adj_op;
  Emergency_room_visit=adj_er;
	where in_samp=1;
run;

proc print data=in_samp_exp;
run;

ods rtf file="final_exp" ;
ods graphics on;
   SYMBOL1 ci=blue  v=diamond  cv=blue  H=1 I=join;
   SYMBOL2 ci=red   v=square   cv=red   H=1 I=join;
   SYMBOL3 ci=green v=triangle cv=green H=1 I=join;
   SYMBOL4 ci=purple v=star       cv=purple H=1 I=join;
   Proc gplot data=in_samp_means;
   PLOT mean*year_cat = dep_cat;
   Run;
ods graphics off;
ods rtf close;


ods rtf file="mean_exp" ;
ods graphics on;
proc sgplot data = in_samp_exp;
	vbar varname /group = dep_cat GROUPDISPLAY = CLUSTER response=mean;
	xaxis values=('Total' 'Inpatient' 'Prescription' 'Office_based' 'Outpatient' 'Emergency_room_visit' );
	title 'Annual mean expenditures by depression categories, 2004�C2011'
run;
ods graphics off;
ods rtf close;
 	                            
proc surveylogistic data=final(where=(in_samp=1)) descending;
	class dep_cat age_cat gender race Marital_stat Edu_cat Insurance MSA Region Econ_stat
	      Hypertension CVD Stroke Emphysema Joint_pain Arthritis Asthma Year_cat /param=ref;
	model prob_flag = dep_cat age_cat gender race Marital_stat Edu_cat Insurance MSA Region Econ_stat
	      Hypertension CVD Stroke Emphysema Joint_pain Arthritis Asthma Year_cat /link=probit;
	 cluster VARPSU;
   strata VARSTR;
   weight PERWT;
run;


ods graphics on;
proc glm data=final(where=(in_samp=1 and prob_flag = 1));
	class dep_cat age_cat gender race Marital_stat Edu_cat Insurance MSA Region Econ_stat
	      Hypertension CVD Stroke Emphysema Joint_pain Arthritis Asthma Year_cat /param=ref;
   model Total=dep_cat age_cat gender race Marital_stat Edu_cat Insurance MSA Region Econ_stat
	      Hypertension CVD Stroke Emphysema Joint_pain Arthritis Asthma Year_cat / clm;
	 cluster VARPSU;
   strata VARSTR;
   weight PERWT;
run;
ods graphics off;