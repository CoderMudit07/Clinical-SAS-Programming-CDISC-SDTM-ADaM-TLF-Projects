
/**************************************************************************
* Project            : End-to-End Clinical SAS Programming Portfolio Project
* Author             : Mudit Kumar Srivastava 
* GitHub Repository  : Clinical-SAS-Programming-CDISC-SDTM-ADaM-TLF-Projects

* Program Name       : DM_Mapped.SAS 
* Program Purpose    : Creation of SDTM DM Domain from Raw Clinical Data
* Output             : SDTM Domain DM (Demographics)
* Source Dataset     : Raw_dm, Raw_ex, Raw_ds, Raw_dummy_rnd, Raw_ic. 

* SAS Version        : SAS 9.4
* Operating System   : Windows 11
* 
* Key Procedures     
*                    - DATA Step Processing
*                    - Data Manipulation and Derivations
*                    - BY-Group Processing (FIRST./LAST.)
*                    - Conditional Logic (IF-THEN/ELSE)
*                    - RETAIN Statement
*                    - SAS Functions
*                    - PROC SORT
*                    - PROC SQL
*                    - Dataset Merging
*                      
* Validation Method  
                     : Independent QC Programming 
*                    : Output Reconciliation using PROC COMPARE
* Programming Notes  :
*                    - DM domain generated from multiple source datasets.
*                    - USUBJID derived using STUDYID and SUBJECT identifiers.
*                    - RFSTDTC derived as earliest study participation date.
*                    - RFENDTC derived as latest study completion/disposition date.
*                    - ARM and ARMCD assigned using randomization information.
*                    - ACTARM and ACTARMCD assigned based on treatment exposure.
*                    - Country, Sex, Race and Age variables mapped from source data.
*                    - All SDTM date variables converted to ISO 8601 format.
*                    - Dataset structured to contain one observation per subject.
*                    - Independent QC programming performed and validated using PROC COMPARE.

**************************************************************************/

Libname Rawdata "Path\Dummy_Rawdata";

DATA DM0;
SET Rawdata.Raw_DM (RENAME=(AGE=AGEX SEX=SEXX));
DOMAIN= "DM";
STUDYID = "AAA-2024";						
USUBJID = STRIP(CATX("-",STUDYID,SUBNUM));          /* STUDYID-SITEID-SUBJID =USUBJID */
SUBJID=(SUBSTR(USUBJID,13));
SITEID= STRIP(PUT(SITENUM,BEST.));
IF AGEX NE . THEN DO;
AGE= AGEX;
END;
SEX=SEXX;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       /*YYYY-MM-DDTHH:MM:SS*/
/* ISO 8601 is as follows: year, month, day, hour, minutes, seconds, and milliseconds*/
BRTHDTC=PUT(BRTHDAT,IS8601DA.);                                 
PROC SORT ;
BY USUBJID;
RUN;


DATA EX0 ;
SET Rawdata.RAW_EX;
STUDYID= "AAA-2024";
USUBJID = STRIP(CATX("-",STUDYID,SUBNUM));           /*USUBJID: STUDYID-SITEID-SUBJID */
IF EXSTDAT NE . THEN DO;
RFXSTDTC= PUT(EXSTDAT,DATE9.) ||"T"||PUT(EXSTTIM,TOD8.);
RFSTDTC= PUT(EXSTDAT,DATE9.) ||"T"||PUT(EXSTTIM,TOD8.);
RFXENDTC = PUT (EXSTDAT,YYMMDD10.)||"T"|| PUT (EXSTTIM,TOD8.);
RFENDTC = PUT (EXSTDAT,YYMMDD10.)||"T"|| PUT (EXSTTIM,TOD8.);
END;
KEEP USUBJID RFXSTDTC RFSTDTC RFXENDTC RFENDTC EXSTDAT;
PROC SORT;
BY USUBJID EXSTDAT;
RUN;

DATA EX_ST;
SET EX0;
BY USUBJID EXSTDAT;
IF FIRST.USUBJID;
KEEP USUBJID RFXSTDTC RFSTDTC;
proc sort ;
by USUBJID;
RUN;

DATA EX_EN;
SET EX0;
BY USUBJID EXSTDAT;
IF LAST.USUBJID;
KEEP USUBJID RFXENDTC RFENDTC;
proc sort ;
by USUBJID;
RUN;


DATA DS0;
SET Rawdata.Raw_EX;
STUDYID= "AAA-2024";
USUBJID = STRIP(CATX("-",STUDYID,SUBNUM));
IF DSDTHDAT NE . THEN DO;
DTHDTC = PUT(DSDTHDAT,DATE9.);
DTHFL= "Y";
END;
IF DSDAT NE . THEN DO;
RFPENDTC=PUT(DSDAT,DATE9.);
END;
KEEP USUBJID STUDYID RFPENDTC  DTHDTC DTHFL ;
PROC SORT;
BY USUBJID;
RUN;


DATA IC0;
SET Rawdata.RAW_IC;
STUDYID= "AAA-2024";
USUBJID = STRIP(CATX("-",STUDYID,SUBNUM));
IF ICDAT NE . THEN DO;
RFICDTC= PUT(ICDAT,DATE9.);
END;
KEEP USUBJID STUDYID RFICDTC ICDAT ;
PROC SORT;
BY USUBJID;
RUN;

DATA TRT0;
SET Rawdata.Raw_DUMMY_RND;
STUDYID='AAA-2024';
DOMAIN='DM';
XX= SCAN (USUBJID,4,'-');
SITEID= SUBSTR (XX,1,3);
SUBJID= SUBSTR (XX,4);
USUBJID= CATX ('-',STUDYID,XX); 
ARMCD=TRTCD;
ARM=TRTCD;
ACTARMCD=TRTCD;
ACTARM=TRTCD;
KEEP USUBJID ARMCD ARM ACTARMCD ACTARM;
PROC SORT ;BY USUBJID ;
RUN;

DATA FINAL_MappedDM;
MERGE DM0 (IN=A) DS0 EX_ST EX_EN IC0 TRT0  ;
BY USUBJID ;
IF A;
RUN;

/*Retaining the variables in the same order  */
DATA DM_Final;
SET FINAL_MappedDM;
COUNTRY="USA";
IF RFXSTDTC NE " " THEN OUTPUT DM_Final;
RETAIN 
STUDYID
DOMAIN
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
SEX
ARMCD
ARM
ACTARMCD
ACTARM
COUNTRY
;
KEEP
STUDYID
DOMAIN
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
SEX
ARMCD
ARM
ACTARMCD
ACTARM
COUNTRY
;
RUN;

/*ATTRIBUTE SECTION*/
PROC SQL NOPRINT;
CREATE TABLE DM AS
SELECT
STUDYID	LABEL='	Study Identifier'	 LENGTH=20	,
DOMAIN	LABEL='	Domain Abbreviation'	  LENGTH=	6	,
USUBJID	LABEL='	Unique Subject Identifier'	  LENGTH=	200	,
SUBJID	LABEL='	Subject Identifier for the Study'	  LENGTH=	200	,
RFSTDTC	LABEL='	Subject Reference Start Date/Time'	  LENGTH=	20	,
RFENDTC	LABEL='	Subject Reference End Date/Time'	  LENGTH=	20	,
RFXSTDTC LABEL='	Date/Time of First Study Treatment'	  LENGTH=	20	,
RFXENDTC LABEL='	Date/Time of Last Study Treatment'	  LENGTH=	20	,
RFICDTC	LABEL='	Date/Time of Informed Consent'	  LENGTH=	20	,
RFPENDTC	LABEL='	Date/Time of End of Participation'	  LENGTH=	16	,
DTHDTC	LABEL='	Date/Time of Death'	  LENGTH=	10	,
DTHFL	LABEL='	Subject Death Flag'	  LENGTH=	1	,
SITEID	LABEL='	Study Site Identifier'	  LENGTH=	200	,
AGE	LABEL='	Age'	  LENGTH=	8	,
SEX	LABEL='	Sex'	  LENGTH=	1	,
ARMCD	LABEL='	Planned Arm Code'	  LENGTH=	20	,
ARM	LABEL='	Description of Planned Arm'	  LENGTH=	200	,
ACTARMCD	LABEL='	Actual Arm Code'	  LENGTH=	20	,
ACTARM	LABEL='	Description of Actual Arm'	  LENGTH=	200,
COUNTRY LABEL='Country' LENGTH= 200
FROM DM_Final;
QUIT;



/*Final Output SDTM- DM domain*/
LIBNAME SDTM "Path\Output\SDTM";

DATA SDTM.DM (LABEL='Demographics');
SET DM;
RUN;






                                           
