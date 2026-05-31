/*--#-----------------------------------------------------------------------------------------------------------------#
--# CCLF GL Biller Extract Data Model
--# DESCRIPTION  : This data model query used to extract JEs and send to Biller 
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-027 EMG       Prasanth Thayi    24-Apr-2019		    Added condition to extract JEs posted only before program started running time
--#                                                         If JE posted during program running time, it is extracting in current run and next run 
--#		                                                    this condition is to eliminate such duplicate JEs
--# REL-030 REGULAR  Nagendra Naidu     19-JUN-2019         Added new value set 'CIRRUSGL_BILLEREXTRCT_CC' and which contains the Biller Company codes
--#															only, Alter the  code to restrict the company codes as per the above value set. 
--# REL-071 EMG      Ritodip A          29-Nov-2022	        Added logic to avoid Receivables entry for few China company codes 		
--# REL_085 EMG		Vignesh Kumar		17-Feb-2024			Column data change from 'CCF' to 'GE-PW-GL047'																												   
--# ---------------------------------------------------------------------------------------------------------------------
*/

WITH 
CCLFUS_BILLER_CCLJEBILEXES AS
(
SELECT 'GE-PW-GL047~' DATA_TYPE, SENDING_GL_SYSTEM||'~'||FILE_CREATED_DATE||'~'||FILE_CREATED_TIME||'~'||RECORD_TYPE||'~'|| JE_CTR_NUM||'~'||
            BUSINESS_UNIT_MARS||'~'||LEGAL_ENTITY_GOLD_ID||'~'||COUNTRY_CODE_ISO_STD||'~'||PL_NUMBER||'~'||BALANCING_SEGMENT||'~'||COST_CENTRE||'~'||REFERENCE_ID||'~'||ACCOUNT||'~'||PROJECT||'~'|| FUNCTIONAL_CURRENCY_CODE||'~'|| FUNCTIONAL_CURRENCY_AMOUNT||'~'|| JE_POSTED_PERIOD||'~'||JE_SOURCE||'~'|| JE_REFERENCE||'~'||JE_HEADER_ID||'~'||JE_LINE_NUMBER||'~'||JE_DESCRIPTION||'~'||ORIGINAL_CURRENCY_CODE||'~'|| ORIGINAL_AMOUNT||'~'|| BILLER_RUN_DATE||'~'|| BILLER_ROUND_NUMBER||'~'|| ACCOUNTING_RECORD_NUMBER BILLER_CCLJEBILEXES,
            NVL(functional_currency_amount,0) func_cur_amt, JE_CTR_NUM,SENDER_ID --Column data change from 'CCF' to 'GE-PW-GL047'   REL-085  
from(
SELECT 'CCLJEBILEXES' DATA_TYPE,
            'CCLFGL' SENDER_ID,
             RANK() OVER (PARTITION BY sysdate ORDER BY b.je_header_id,b.je_line_num,a.ledger_id) JE_CTR_NUM,
              E.SHORT_NAME,
              A.PERIOD_NAME,                 
              'GE-PW-GL047' SENDING_GL_SYSTEM,    --Column data change from 'CCF' to 'GE-PW-GL047'   REL-085  
              'GE-PW-GL047' SOURCE_OP_GL_SYSTEM ,  -- Column data change from 'CCF' to 'GE-PW-GL047'   REL-085     
        TO_CHAR(SYSDATE,'YYYYMMDD') FILE_CREATED_DATE, 
        TO_CHAR(SYSDATE,'HH.MM.SS') FILE_CREATED_TIME,
        'DTL' RECORD_TYPE,
        NULL business_unit_mars,
        NULL LEGAL_ENTITY_GOLD_ID,                          
        NULL COUNTRY_CODE_ISO_STD,
        NULL pl_number,
        D.SEGMENT1 BALANCING_SEGMENT,
        D.SEGMENT1 company_code,               
        D.SEGMENT4 cost_centre,                                   
        D.SEGMENT7 reference_id,                                  
        D.SEGMENT2 ACCOUNT,                                   
        D.SEGMENT6 project,                                   
        E.CURRENCY_CODE FUNCTIONAL_CURRENCY_CODE,                             
        NVL(b.accounted_dr,0)-NVL(b.accounted_cr,0) functional_currency_amount,        
        h.period_year||TRIM(TO_CHAR(h.period_num,'00')) JE_POSTED_PERIOD,                      
        F.USER_JE_SOURCE_NAME JE_SOURCE ,                       
        NULL  JE_REFERENCE,                                        
        A.JE_HEADER_ID JE_HEADER_ID,                               
        B.JE_LINE_NUM JE_LINE_NUMBER,
        --SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((b.description||' '||a.name),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' '),1,72) JE_DESCRIPTION,--commented for replacing delimiter ~ character with - 
		SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((b.description||' '||a.name),CHR(126),CHR(45)),',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' '),1,72) JE_DESCRIPTION,
		--DECODE(F.USER_JE_SOURCE_NAME , 'CCL_AP_INTERFACE', SUBSTR(B.ATTRIBUTE9,1,11)||'|'||SUBSTR(B.ATTRIBUTE4,1, 20)||'|'||SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(b.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' '),1,72),SUBSTR(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(b.description,',',';'), CHR(13), ' '), CHR(10), ' '),CHR(9), ' '),CHR(160),' '),1,72)) JE_DESCRIPTION,
		--DECODE(F.USER_JE_SOURCE_NAME , 'CCL_AP_INTERFACE', SUBSTR(B.ATTRIBUTE9,1,11)||'|'||SUBSTR(B.ATTRIBUTE4,1, 20)||'|'||SUBSTR(B.DESCRIPTION,1,72),SUBSTR(B.DESCRIPTION,1,72)) JE_DESCRIPTION,
        A.CURRENCY_CODE ORIGINAL_CURRENCY_CODE,                              
        NVL(B.ENTERED_DR,0)-NVL(B.ENTERED_CR,0) ORIGINAL_AMOUNT,      
        DECODE(B.ATTRIBUTE1,'BILCCL',B.ATTRIBUTE1,NULL) BILLER_RUN_DATE, 
        DECODE(B.ATTRIBUTE2,'BILCCL',B.ATTRIBUTE2,NULL) BILLER_ROUND_NUMBER, 
        DECODE(B.ATTRIBUTE3,'BILCCL',B.ATTRIBUTE3,NULL) ACCOUNTING_RECORD_NUMBER, 
        FND_PROFILE.VALUE('USERNAME') created_by,                                  
        sysdate creation_date                                     
      FROM GL_JE_HEADERS a,
           GL_JE_LINES b,
           GL_CODE_COMBINATIONS d,
           GL_LEDGERS e,
           GL_JE_SOURCES f,
           GL_JE_CATEGORIES g,
           GL_PERIODS h,
		  (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
           FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
		   ,fnd_flex_value_sets d -- REL-030  Added As per GERITM3594495
		   ,fnd_flex_values e -- REL-030  Added As per GERITM3594495
           WHERE a.flex_value_set_id = b.flex_value_set_id
          -- AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
		   AND b.FLEX_VALUE_SET_ID = 51243  -- CCL_COMPANY_CODES
		  -- AND a.attribute5 is not null
           AND a.flex_value_id       = c.flex_value_id
           AND c.language            = 'US'
		   --REL-030   Added below Code as per the GERITM3594495
		   AND d.flex_value_set_name = 'CIRRUSGL_BILLEREXTRCT_CC'  -- value set name for Biller company codes
		   AND d.flex_value_set_id = e.flex_value_set_id
		   AND a.flex_value = e.flex_value			
			AND e.enabled_flag = 'Y'
			AND e.end_date_active IS NULL
		   -- REL-030   Added above code as per the GERITM3594495
		   ) ccv
      WHERE a.je_header_id          = b.je_header_id
      AND a.period_name             = b.period_name      
      AND b.code_combination_id   = d.code_combination_id
      AND a.ledger_id               = e.ledger_id
	  AND a.je_source               = f.je_source_name
	  AND a.je_category             = g.je_category_name
	  AND a.status                  = 'P'
      AND a.period_name = h.period_name
      AND e.period_set_name = h.period_set_name
      AND e.ledger_category_code  IN('PRIMARY' ,'ALC')
      AND (e.name LIKE '%PRM' OR e.name LIKE '%FCY')
	  /* The Below REL-03 , As per Biz request we are exlusing the JE Source as Closing Journals i.e Generated by Year End Roll job .
	  Changes done by via SC Case #15515005 Sashi KL */
      AND f.je_source_name <>'Closing Journal' -- REL-03 
	   AND ((ccv.company_code  in ('NN03','NN04','NN09') and je_source_name <>'Receivables')or (ccv.company_code  not in ('NN03','NN04','NN09'))) --REL071 added logic to avoid Receivables entry for few China company codes 																																																				 
      AND ((ccv.functional_currency = 'USD' AND e.name LIKE '%FCY') OR (ccv.functional_currency <> 'USD' AND e.name LIKE '%PRM')) 
      AND ccv.company_code        = d.segment1      
      AND ((f.user_je_source_name = 'CCL_BILLER' AND b.attribute20 IS NULL) OR  (f.user_je_source_name <> 'CCL_BILLER'))        
	  AND d.segment9                 <> 'S'
	  AND ((a.period_name = :P_PERIOD_NAME AND :P_PERIOD_NAME IS NOT NULL) OR
          (a.period_name = e.latest_opened_period_name AND :P_PERIOD_NAME IS NULL))
	-- AND a.posted_date BETWEEN TO_DATE('2016-12-06T09:01:00', 'YYYY-MM-DD"T"HH24:MI:SS')  and  TO_DATE('2016-12-13T08:59:00', 'YYYY-MM-DD"T"HH24:MI:SS')
   	AND  a.posted_date >= 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
          -- WHERE  ERH.definition = 'JobDefinition://oracle/apps/ess/custom/cclf/CCLF_GL_Biller_Extract'
		   WHERE  ERH.definition =  'JobDefinition://oracle/apps/ess/custom/GL/CCLF_GL_Biller_Extract'
           AND    ERH.executable_status = 'SUCCEEDED'
			) ,a.posted_date) 
    --REL-027 EMG  Added condition 	
	--	REL 085 EMG commented for not getting Data
	/* AND  a.posted_date < 
           NVL((
           SELECT MAX(ERH.processstart)
           FROM   ess_request_history ERH
 		   WHERE  ERH.definition =  'JobDefinition://oracle/apps/ess/custom/GL/CCLF_GL_Biller_Extract'
           --AND    ERH.executable_status = 'SUCCEEDED'
		   AND    ERH.state = 3
			) ,a.posted_date)  */ 
	--REL-027 EMG Ended Above Condition 
	-- REL 085 EMG commented for not getting Data
     AND  (NVL(b.entered_dr,0) - NVL(b.entered_cr,0) <> 0 OR NVL(b.accounted_dr,0) - NVL(b.accounted_cr,0) <>0)
	AND EXISTS (SELECT 'X'
               FROM fnd_tree_node ftn
                   ,FND_TREE_VERSION_VL ftv
               WHERE 1=1
               AND ftn.tree_Code =  'COST CENTER BILLER UNPUBLISHED'--'REF CODE UNPUBLISHED'
               AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
               AND ftv.tree_Code = ftn.tree_code
               AND ftv.tree_structure_code = ftn.tree_structure_code
               AND ftv.TREE_VERSION_NAME = 'CURRENT'
               AND ftn.TREE_VERSION_ID = ftv.TREE_VERSION_ID
               AND pk1_start_value = d.segment4)
  AND d.segment2 NOT LIKE '1%' 
  AND d.segment2 NOT LIKE '2%' 
  AND d.segment2 NOT LIKE '3%'
  AND d.segment2 NOT LIKE '4%'
  --AND (d.segment1 LIKE 'GJP%' or d.segment1 LIKE 'JPN%' OR d.segment1 LIKE '00MX%' or d.segment1 LIKE 'GAU1%')
      ORDER BY A.JE_HEADER_ID,JE_LINE_NUMBER))
  
-- commented and added below to change column data for REL-085
	  
--SELECT 'CCF~' data_type,'CCF~'||TO_CHAR(SYSDATE,'YYYYMMDD')||'~'||TO_CHAR(sysdate,'HH.MM.SS')||'~'||'HDR' BILLER_CCLJEBILEXES, 0 func_cur_amt, 1 ctr, 1 JE_CTR_NUM, 'CCLFGL' SENDER_ID FROM CCLFUS_BILLER_CCLJEBILEXES
SELECT 'GE-PW-GL047~' data_type,'GE-PW-GL047~'||TO_CHAR(SYSDATE,'YYYYMMDD')||'~'||TO_CHAR(sysdate,'HH.MM.SS')||'~'||'HDR' BILLER_CCLJEBILEXES, 0 func_cur_amt, 1 ctr, 1 JE_CTR_NUM, 'CCLFGL' SENDER_ID FROM CCLFUS_BILLER_CCLJEBILEXES
UNION
SELECT  data_type,CCLFUS_BILLER_CCLJEBILEXES.BILLER_CCLJEBILEXES, CCLFUS_BILLER_CCLJEBILEXES.func_cur_amt, 2 ctr, CCLFUS_BILLER_CCLJEBILEXES.JE_CTR_NUM,'CCLFGL' SENDER_ID FROM CCLFUS_BILLER_CCLJEBILEXES
UNION
--SELECT 'CCF~' data_type,'CCF~'||TO_CHAR(SYSDATE,'YYYYMMDD')||'~'||TO_CHAR(sysdate,'HH.MM.SS')||'~'||'TRL'||'~'||TO_CHAR(COUNT(*))||'~'||TO_CHAR(SUM(CCLFUS_BILLER_CCLJEBILEXES.func_cur_amt)) BILLER_CCLJEBILEXES, 0 func_cur_amt, 3 ctr, 1 JE_CTR_NUM,'CCLFGL' SENDER_ID FROM CCLFUS_BILLER_CCLJEBILEXES
SELECT 'GE-PW-GL047~' data_type,'GE-PW-GL047~'||TO_CHAR(SYSDATE,'YYYYMMDD')||'~'||TO_CHAR(sysdate,'HH.MM.SS')||'~'||'TRL'||'~'||TO_CHAR(COUNT(*))||'~'||TO_CHAR(SUM(CCLFUS_BILLER_CCLJEBILEXES.func_cur_amt)) BILLER_CCLJEBILEXES, 0 func_cur_amt, 3 ctr, 1 JE_CTR_NUM,'CCLFGL' SENDER_ID FROM CCLFUS_BILLER_CCLJEBILEXES
UNION
SELECT 'CCLFGL,' data_type,'CCLJEBILEXES,'||TO_CHAR(SYSDATE,'YYYYMMDD')||','||'TRAILER,'||TO_CHAR(COUNT(*)+2)||',P' BILLER_CCLJEBILEXES, 0 func_cur_amt, 4 ctr, 1 JE_CTR_NUM,'CCLFGL' SENDER_ID  FROM CCLFUS_BILLER_CCLJEBILEXES
order by ctr, JE_CTR_NUM