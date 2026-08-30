/**************************************************************************
* Project            : End-to-End Clinical SAS Programming Portfolio Project-(GitHub Portfolio)
* Author             : Mudit Kumar Srivastava 
* GitHub Repository  : Clinical-SAS-Programming-CDISC-SDTM-ADaM-TLF-Projects

* Program Name       : ADSL.SAS 
* Program Purpose    : Creation of Subject-Level Analysis Dataset (ADSL)
*                      from SDTM Domains according to ADaM principles.

* Output             : ADSL (Subject-Level Analysis Dataset)
* Source Dataset     : SDTM.DM, SDTM.DS. 

* SAS Version        : SAS 9.4
* Operating System   : Windows 11
* 
* Key Procedures     :
*                    - DATA Step Programming
*                    - Data Manipulation and Derivations
*                    - BY-Group Processing (FIRST./LAST.)
*                    - Conditional Logic (IF-THEN/ELSE)
*                    - RETAIN and KEEP Statements
*                    - SAS Functions (INPUT, DATEPART, SUBSTR)
*                    - PROC SORT
*                    - PROC SQL
*                    - Dataset Merging (MERGE Statement)
*                    - Label and Metadata Assignment
*
* Key Derivations    :
*                    - AGEGR1
*                    - SEXN
*                    - TRT01P/TRT01PN
*                    - TRT01A/TRT01AN
*                    - SCRNFL
*                    - SAFFL
*                    - ITTFL
*                    - RANDDT
*                    - TRTSDT/TRTEDT
*                    - TRTDURD
*                    - EOSSTT       
*                      
* Validation Method  :
*                    - Independent QC Programming
*                    - Dataset Reconciliation using PROC COMPARE
* Programming Notes  
*                    - Subject-Level Analysis Dataset (ADSL) derived from SDTM domains.
*                    - One record per subject maintained.
*                    - Population flags (SCRNFL, SAFFL, ITTFL) derived.
*                    - Treatment assignment variables (TRT01P/TRT01A) created.
                     - Treatment start and end dates derived.
*                    - Treatment duration calculated.
*                    - Randomization information derived from DS domain.
*                    - End-of-study status and discontinuation reasons derived.
*                    - Variable attributes assigned according to ADaM conventions.
*                    - Dataset validated through independent QC programming and PROC COMPARE reconciliation.

***************************************************************************************************************/

/*1- LIBRARY TO GET SDTM SOURCE DATASETS*/
libname SDTM "Path\SDTM_Program";

/*2- COPY ALL THE VARIABLES FROM DM.SDTM DOMAIN TO GET ALL PREDECESSOR VARIABLES*/
DATA DM1;
SET SDTM.DM;
RUN;

/*3- ASSIGNED VARIABLES DERIVATION AS PER SPECIFICATIONS*/
DATA DM2;
SET DM1;
LENGTH AGEGR1 $40.;
IF AGE NE . THEN DO;
IF AGE < 40 THEN AGEGR1='< 40 years old';
ELSE IF AGE >=40 THEN AGEGR1='>= 40 years old';
END;
if SEX = 'F' then SEXN= 2; 
else if SEX = 'M' then SEXN= 1;
RUN;

/*4- DERIVED VARIABLES DERIVATION AS PER SPECIFICATIONS*/

DATA DM3;
SET DM2;
IF ARMCD='TQ' THEN DO;
TRT01P='Tafenoquine';
TRT01PN=1;
END;
IF ACTARMCD='TQ' THEN DO;
TRT01A='Tafenoquine';
TRT01AN=1;
END;

IF ARMCD='PLACEBO' THEN DO;
TRT01P='Placebo';
TRT01PN=2;
END;

IF ACTARMCD='PLACEBO' THEN DO;
TRT01A='Placebo';
TRT01AN=2;
END;

IF RFXSTDTC NE ' ' THEN
TRTSDTM= INPUT (RFXSTDTC,DATETIME20.);
FORMAT TRTSDTM DATETIME20.;

IF TRTSDTM NE . THEN 
TRTSDT= DATEPART (TRTSDTM);
FORMAT TRTSDT DATE9.;

IF RFXENDTC NE '' THEN
TRTEDTM=INPUT (RFXENDTC,IS8601DT.);
FORMAT TRTEDTM DATETIME20.;

IF TRTEDTM NE .  THEN
TRTEDT=DATEPART (TRTEDTM);
FORMAT TRTEDT DATE9.;

IF TRTEDT NE . AND TRTSDT NE . THEN 
TRTDURD=(TRTEDT - TRTSDT)+1;

/*Screened Population Flag*/
IF RFICDTC NE '' THEN SCRNFL='Y';
ELSE SCRNFL='N';

/*Safety Population Flag*/
IF RFXSTDTC NE '' THEN SAFFL='Y';
ELSE SAFFL='N';
PROC SORT;
BY USUBJID;
RUN;

/*5- DS.SDTM VARIABLES DERIVATION AS PER SPECIFICATIONS*/
DATA DS;
SET SDTM.DS;
LENGTH EOSSTT  DCSREAS DCSREASP $200.;
IF DSCAT='DISPOSITION EVENT' AND DSSCAT='END OF STUDY/EARLY TERMINATION'
THEN DO;
IF DSDECOD='COMPLETED' THEN EOSSTT='Completed';
IF DSDECOD ^='COMPLETED' THEN EOSSTT='Discontinued';

IF DSDECOD NE '' THEN DCSREAS=DSDECOD;
IF DSDECOD EQ 'OTHER' THEN DCSREASP=DSTERM;
END;
IF DSCAT='DISPOSITION EVENT' AND 
DSSCAT='SCREEN FAILURE'
THEN DO;
IF DSDECOD NE '' THEN EOSSTT='Screen Failure';
END;
IF DSCAT = "DISPOSITION EVENT" THEN DO;
EOSDT =INPUT (SUBSTR(DSSTDTC,1,10),YYMMDD10.);
FORMAT EOSDT DATE9.;
END;
IF EOSSTT NE '';
KEEP USUBJID EOSSTT EOSDT DCSREAS DCSREASP;
PROC SORT;
BY USUBJID;
RUN;

DATA DS1;
SET SDTM.DS;
IF DSDECOD='RANDOMIZED' AND DSSTDTC NE '' THEN DO;
RANDDT =INPUT (SUBSTR(DSSTDTC,1,10),YYMMDD10.);
FORMAT RANDDT DATE9.;
RANDFL='Y';
ITTFL='Y';
END;
IF RANDDT NE .;
KEEP USUBJID RANDDT RANDFL ITTFL;
PROC SORT;
BY USUBJID;
RUN;

/*6- REMERGE WITH MAIN DATASET*/
DATA DM4;
MERGE DM3 (IN=A) DS DS1 ;
BY USUBJID;
IF A;
RUN;

/*7- GET THE FINAL DATASET BY RETAINING THE VARIABLES SEQUENCES AS PER SEPCS*/
DATA FINAL;
SET DM4;
RETAIN
STUDYID
USUBJID
SUBJID
RFSTDTC
RFENDTC
RFXSTDTC
RFXENDTC
RFICDTC
RFPENDTC
DTHDTC
DTHFL
SITEID
AGE
AGEGR1
SEX
SEXN
ARMCD
ARM
ACTARMCD
ACTARM
COUNTRY
RANDFL
RANDDT
SCRNFL
SAFFL
ITTFL
TRT01P
TRT01PN
TRT01A
TRT01AN
TRTSDTM
TRTSDT
TRTEDTM
TRTEDT
TRTDURD
EOSSTT
EOSDT
DCSREAS
DCSREASP
;
KEEP
STUDYID
USUBJID
SUBJID
RFSTDTC
RFENDTC
RFXSTDTC
RFXENDTC
RFICDTC
RFPENDTC
DTHDTC
DTHFL
SITEID
AGE
AGEGR1
SEX
SEXN
ARMCD
ARM
ACTARMCD
ACTARM
COUNTRY
RANDFL
RANDDT
SCRNFL
SAFFL
ITTFL
TRT01P
TRT01PN
TRT01A
TRT01AN
TRTSDTM
TRTSDT
TRTEDTM
TRTEDT
TRTDURD
EOSSTT
EOSDT
DCSREAS
DCSREASP
;
RUN;

/*8- ASSIGNING ATTRIBUTES TO VARIABLES*/
PROC SQL NOPRINT;
CREATE TABLE ADSL AS
SELECT
STUDYID	LABEL="	Study Identifier " ,
USUBJID	LABEL="	Unique Subject Identifier " ,
SUBJID	LABEL="	Subject Identifier for the Study" ,
RFSTDTC	LABEL="	Subject Reference Start Date/Time",
RFENDTC	LABEL="	Subject Reference End Date/Time" ,
RFXSTDTC LABEL="	Date/Time of First Study Treatment" ,
RFXENDTC LABEL="	Date/Time of Last Study Treatment	" ,
RFICDTC	LABEL="	Date/Time of Informed Consent	" ,
RFPENDTC	LABEL="	Date/Time of End of Participation	" ,
DTHDTC	LABEL="	Date/Time of Death	" ,
DTHFL	LABEL="	Subject Death Flag	" ,
SITEID	LABEL="	Study Site Identifier	" ,
AGE	 LABEL=" Age	" ,
AGEGR1 LABEL="	Pooled Age Group 1	" LENGTH=	40	,
SEX	LABEL="	Sex	" LENGTH=	1	,
SEXN LABEL="	Sex (N)	" LENGTH=	8	,
ARMCD LABEL="	Planned Arm Code	" ,
ARM	LABEL="	Description of Planned Arm	",
ACTARMCD LABEL="	Actual Arm Code	" 	,
ACTARM	LABEL="	Description of Actual Arm	" 	,
COUNTRY	LABEL="	Country	" ,
RANDFL	LABEL="	Randomization Flag	" LENGTH=	1	,
RANDDT	LABEL="	Date of Randomization	" LENGTH=	8	,
SCRNFL	LABEL="	Screened Population Flag	" LENGTH=	1	,
SAFFL	LABEL="	Safety Population Flag	" LENGTH=	1	,
ITTFL	LABEL="	Intent-To-Treat Population Flag	" LENGTH=	1	,
TRT01P	LABEL="	Planned Treatment for Period 01	" LENGTH=	40	,
TRT01PN	LABEL="	Planned Treatment for Period 01 (N)	" LENGTH=	8	,
TRT01A	LABEL="	Actual Treatment for Period 01	" LENGTH=	40	,
TRT01AN	LABEL="	Actual Treatment for Period 01 (N)	" LENGTH=	8	,
TRTSDTM	LABEL="	Datetime of First Exposure to Treatment	" LENGTH=	8	,
TRTSDT	LABEL="	Date of First Exposure to Treatment	" LENGTH=	8	,
TRTEDTM	LABEL="	Datetime of Last Exposure to Treatment	" LENGTH=	8	,
TRTEDT	LABEL="	Date of Last Exposure to Treatment	" LENGTH=	8	,
TRTDURD	LABEL="	Total Treatment Duration (minutes)	" LENGTH=	8	,
EOSSTT	LABEL="	End of Study Status	" LENGTH=	200	,
EOSDT	LABEL="	End of Study Date	" LENGTH=	8	,
DCSREAS	LABEL="	Reason for Discontinuation from Study	" LENGTH=	200	,
DCSREASP LABEL="Reason Spec for Discont from Study	" LENGTH=	200													
FROM FINAL;
QUIT;

/*9- TAKE THE FINAL OUTPUT DATASET "ADSL" IN PERMANENT LIBRARY*/

LIBNAME ADAM "Path\Output\ADaM";

DATA ADAM.ADSL (LABEL='Subject Level Analysis Dataset');
SET ADSL;
RUN;

/*10- QC/VALIDATION-*/

PROC COMPARE B=ADAM.ADSL C=ADAM.QC_ADSL LISTALL;
RUN;
