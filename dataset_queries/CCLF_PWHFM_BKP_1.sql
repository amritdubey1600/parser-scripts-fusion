--# MODIFICATION HISTORY:
   --# CR#             Author              Date             Description
   --# --------------------------------------------------------------------------------------------------------------------------------------------------------#
   --# REL-78          Nagendra         13-MAR-2023        GERITM37807779 entire code was replaced with new code logic and 
   --#													   New property HFM_EXTRACT_EXCEPTION was added in DRM system to control CoCo exclusion
   --# REL-85		   Udaya Kumar 		01-FEB-2024		   Added transformation logic for the company codes under ENRGHQ hierarchy, 
   --#	   												   existing PWHFM logic will remain same.
  --# ---------------------------------------------------------------------------------------------------------------------------------------------------------#

WITH ccv AS
      (
SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
       FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c--, gl_code_combinations glc
       
WHERE a.flex_value_set_id   = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US'
		 --AND glc.segment1 = a.flex_value
AND  (
      EXISTS
        (SELECT /*+ PARALLEL_INDEX */  'X'
           FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
          WHERE 1=1
           AND ftn.tree_Code           = 'COMPANY UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
           AND ftv.tree_structure_code = ftn.tree_structure_code
           AND ftv.tree_version_name   = 'CURRENT'
           AND ftn.tree_version_id     = ftv.tree_version_id               
           AND parent_pk1_value        = 'HFMPW'  
           AND pk1_start_value         = a.flex_value)	
	)
	-- Added below code for REL-085
		and(
	not exists(
			   SELECT  'X'
           FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
          WHERE 1=1
           AND ftn.tree_Code           = 'COMPANY UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value
			and pk1_start_value not in ('ENRGHQ')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
			where tree_code = 'COMPANY UNPUBLISHED'
			and tree_version_name = 'CURRENT')
			-- and ftn.pk1_start_value = 'ENRGHQ'
			START WITH ftn.pk1_start_value = 'ENRGHQ'
			CONNECT BY prior tree_node_id = parent_tree_node_id  
	)
	)
 ) ,

 glcc AS
      (
SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
       FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c--, gl_code_combinations glc 
       
WHERE a.flex_value_set_id   = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US'	
		-- AND glc.segment1 = a.flex_value
AND  (
      EXISTS
        (  
		   SELECT  'X'
           FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
          WHERE 1=1
           AND ftn.tree_Code           = 'COMPANY UNPUBLISHED'
           AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
           AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value
			and pk1_start_value not in ('ENRGHQ')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
			where tree_code = 'COMPANY UNPUBLISHED'
			and tree_version_name = 'CURRENT')
			-- and ftn.pk1_start_value = 'ENRGHQ'
			START WITH ftn.pk1_start_value = 'ENRGHQ'
			CONNECT BY prior tree_node_id = parent_tree_node_id  
		   )	
	)
		group by a.flex_value ,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5
 )
 -- Added above code for REL-085
SELECT 1 extract_order,
'YEAR|MONTH|VIEW|CURRENCY CODE|COMPANY CODE|ACCOUNT|ICP|COST CENTER|GEOGRAPHY|PROJECT|REFERENCE|PRODUCT LINE|BOOK TYPE|FUTURE1|FUTURE2|AMOUNT' PW_HFM,
'PWHFM' KEY
FROM DUAL
UNION ALL
SELECT  /*+ PARALLEL_INDEX */ 
2 extract_order,
glb.period_year||'|'||SUBSTR(glb.period_name,1,3)||'|'||'YTD'||'|'||glb.currency_code||'|'||glc.segment1||'|'||glc.segment2||'|'||
glc.segment3||'|'||glc.segment4||'|'||glc.segment5 ||'|'||glc.segment6||'|'||glc.segment7||'|'||glc.segment8||'|'||glc.segment9||'|'||
glc.segment10||'|'||glc.segment11||'|'||TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) PW_HFM ,
'PWHFM' KEY
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
	   ccv
WHERE led.ledger_id            = glb.ledger_id
AND   ccv.company_code         = glc.segment1
AND   glb.currency_code        = NVL(ccv.functional_currency,glb.currency_code)
AND   glb.period_name = :P_PERIOD
AND   (led.name LIKE '%_'||ccv.functional_currency||'_FCY' OR
       led.name LIKE '%_'||ccv.functional_currency||'_PRM')
AND   glc.code_combination_id  = glb.code_combination_id
--AND   NVL(glb.translated_flag,'ZZ') <> 'Y'  -- need to confirm
AND   led.name not like '%STA'    
AND   glc.segment9 <> 'S'
AND (
		((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) <> 0
    )
-- Added below code for REL-085	
/*UNION ALL

SELECT 1 extract_order,
'YEAR|MONTH|VIEW|CURRENCY CODE|COMPANY CODE|ACCOUNT|ICP|COST CENTER|GEOGRAPHY|PROJECT|REFERENCE|PRODUCT LINE|BOOK TYPE|FUTURE1|FUTURE2|AMOUNT' PW_HFM,
'PWHFM' KEY
FROM DUAL*/
UNION ALL
SELECT 2 extract_order, period_year||'|'||period_name||'|'||BAL_TYPE||'|'||currency_code||'|'||segment1||'|'||segment2||'|'||SEGMENT3
||'|'||segment4||'|'||segment5||'|'||segment6||'|'||segment7||'|'||segment8||'|'||segment9||'|'||segment10||'|'||segment11||'|'||TO_CHAR(TOTAL) PW_HFM ,
'PWHFM' KEY
FROM (SELECT period_year,
period_name,
bal_type,
currency_code,
segment1,
segment2,
segment3,
segment4,
segment5,
segment6,
segment7,
segment8,
segment9,
segment10,
segment11,
SUM(TOTAL) TOTAL FROM(SELECT  /*+ PARALLEL_INDEX */ 
glb.period_year,SUBSTR(glb.period_name,1,3) period_name, 'YTD' BAL_TYPE,glb.currency_code,glc.segment1,glc.segment2,
(CASE WHEN GLC.SEGMENT3 LIKE 'Y%'
and exists (SELECT  'X'
            FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
				 ,fnd_flex_values a
            WHERE 1=1
            AND ftn.tree_Code           = 'ACCOUNT UNPUBLISHED'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
			and a.flex_value			= glc.segment2
			AND pk1_start_value         = a.flex_value  
			and pk1_start_value not in ('ACCTTP')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
										where tree_code = 'ACCOUNT UNPUBLISHED'
										and tree_version_name = 'CURRENT')
										START WITH ftn.pk1_start_value = 'ACCTTP'
										CONNECT BY prior tree_node_id = parent_tree_node_id)
THEN NVL((SELECT flv.description
				FROM fnd_lookup_values flv
				WHERE flv.lookup_type = 'CCL_PWHFM_TP_CC_MAPPING'
				AND flv.enabled_flag = 'Y'
				AND flv.Language = 'US'
                and flv.lookup_code = glc.segment3),glc.segment3)
ELSE glc.segment3 
END) segment3,(CASE WHEN (glc.segment4 LIKE 'PW%'
               OR glc.segment4 LIKE 'IC%' OR glc.segment4 LIKE 'GQ%') THEN 
			   glc.segment4 
			   ELSE (CASE WHEN glc.segment4 is not null and
exists (SELECT  'X'
            FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
				 ,fnd_flex_values a
            WHERE 1=1
            AND ftn.tree_Code           = 'ACCOUNT UNPUBLISHED'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value  
			and a.flex_value			= glc.segment2
			and pk1_start_value not in ('ACCTFUNC')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
										where tree_code = 'ACCOUNT UNPUBLISHED'
										and tree_version_name = 'CURRENT')
										START WITH ftn.pk1_start_value = 'ACCTFUNC'
										CONNECT BY prior tree_node_id = parent_tree_node_id)
THEN NVL((SELECT flv.description
				FROM fnd_lookup_values flv
				WHERE flv.lookup_type = 'VER_PWHFM_COSTCENTER'
				AND flv.enabled_flag = 'Y'
				AND flv.Language = 'US'
                and flv.lookup_code = glc.segment4),'000000')
ELSE glc.segment4 END) END)segment4,(CASE WHEN glc.segment5 is not null and exists (SELECT  'X'
            FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
				 ,fnd_flex_values a
            WHERE 1=1
            AND ftn.tree_Code           = 'ACCOUNT UNPUBLISHED'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value  
			and a.flex_value			= glc.segment2
			and pk1_start_value not in ('ACCTGEO')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
										where tree_code = 'ACCOUNT UNPUBLISHED'
										and tree_version_name = 'CURRENT')
										START WITH ftn.pk1_start_value = 'ACCTGEO'
										CONNECT BY prior tree_node_id = parent_tree_node_id)
THEN 'ZZQ' 
ELSE '000' END)segment5 ,(CASE WHEN (glc.segment6 LIKE 'PW%' OR glc.segment6 LIKE 'CORP%') THEN
                            glc.segment6 
							ELSE (CASE WHEN glc.segment6 is not null and
exists (SELECT  'X'
            FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
				 ,fnd_flex_values a
            WHERE 1=1
            AND ftn.tree_Code           = 'ACCOUNT UNPUBLISHED'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value  
			and a.flex_value			= glc.segment2
			and pk1_start_value not in ('ACCTPROJ')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
										where tree_code = 'ACCOUNT UNPUBLISHED'
										and tree_version_name = 'CURRENT')
										START WITH ftn.pk1_start_value = 'ACCTPROJ'
										CONNECT BY prior tree_node_id = parent_tree_node_id)

THEN NVL((SELECT flv1.description
				FROM fnd_lookup_values flv1
				WHERE flv1.lookup_type = 'VER_PWHFM_PRJCCODE'
				AND flv1.enabled_flag = 'Y'
				AND flv1.Language = 'US'
               AND flv1.lookup_code = glc.segment6),'PW01900000')			
ELSE '0000000000' END) END) segment6,--glc.segment7

(CASE WHEN glc.segment7 LIKE 'BA%' and exists
	(SELECT  'X'
            FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
				 ,fnd_flex_values a
            WHERE 1=1
            AND ftn.tree_Code           = 'ACCOUNT UNPUBLISHED'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value
			and a.flex_value			= glc.segment2
			and pk1_start_value not in ('ACCTREF')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
										where tree_code = 'ACCOUNT UNPUBLISHED'
										and tree_version_name = 'CURRENT')
										START WITH ftn.pk1_start_value = 'ACCTREF'
										CONNECT BY prior tree_node_id = parent_tree_node_id)
THEN glc.segment7
ELSE '000000'
END)segment7
,(CASE WHEN (glc.segment8 LIKE 'PW%' OR glc.segment8 LIKE 'GL%') 
   THEN glc.segment8 
   ELSE
 (CASE WHEN glc.segment8 IS NOT NULL
and
exists (SELECT  'X'
            FROM   fnd_tree_node ftn
                 ,fnd_tree_version_vl ftv
				 ,fnd_flex_values a
            WHERE 1=1
            AND ftn.tree_Code           = 'ACCOUNT UNPUBLISHED'
            AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
            AND ftv.tree_Code           = ftn.tree_code
			AND pk1_start_value         = a.flex_value  
			and a.flex_value			= glc.segment2
			and pk1_start_value not in ('ACCTPROD')
			And ftn.tree_version_id = (select tree_version_id from fnd_tree_version_vl 
										where tree_code = 'ACCOUNT UNPUBLISHED'
										and tree_version_name = 'CURRENT')
										START WITH ftn.pk1_start_value = 'ACCTPROD'
										CONNECT BY prior tree_node_id = parent_tree_node_id)
THEN 'PW1085'
ELSE '000000' END) END) segment8,glc.segment9,
glc.segment10,glc.segment11,(glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr) TOTAL
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
	   glcc
WHERE led.ledger_id            = glb.ledger_id
AND   glcc.company_code         = glc.segment1
AND   glb.currency_code        = NVL(glcc.functional_currency,glb.currency_code)
AND   glb.period_name = :P_PERIOD
AND   (led.name LIKE '%_'||glcc.functional_currency||'_FCY' OR
       led.name LIKE '%_'||glcc.functional_currency||'_PRM')
AND   glc.code_combination_id  = glb.code_combination_id
--AND   NVL(glb.translated_flag,'ZZ') <> 'Y'  -- need to confirm
AND   led.name not like '%STA'    
AND   glc.segment9 <> 'S'
AND   glc.segment1 <> 'UC09'
AND (
		((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) <> 0
    ))
GROUP BY period_year,
period_name,
bal_type,
currency_code,
segment1,
segment2,
segment3,
segment4,
segment5,
segment6,
segment7,
segment8,
segment9,
segment10,
segment11)
WHERE TOTAL <>0
 -- Added above code for REL-085
 
 
--Commented below code as per REL-78 GERITM37807779
/*
SELECT 'COMPANY_CODE,ACCOUNT,TRADING_PARTNER,COST_CENTER,GEOGRAPHY,PROJECT,REFERENCE_CODE,PRODUCT_LINE,BOOK_TYPE,YTD_BALANCE,QTD_BALANCE,PTD_BALANCE,LEDGER_NAME,CURRENCY,PERIOD' PW_HFM, 'PWHFM' KEY
FROM DUAL
UNION
SELECT glc.segment1||','||glc.segment2||','||glc.segment3||','||glc.segment4||','||glc.segment5 ||','||glc.segment6||','||glc.segment7||','||glc.segment8||','||glc.segment9||','||
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR(glb.period_net_dr - glb.period_net_cr)||','||led.name||','||glb.currency_code||','||glb.period_name PW_HFM , 'PWHFM' KEY
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
        FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
       WHERE a.flex_value_set_id   = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US') ccv,
	  (SELECT a.flex_value company,c.description ledger_name
         FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
        WHERE a.flex_value_set_id   = b.flex_value_set_id
          AND b.flex_value_set_name = 'CCLF_PWHFM_COMPANY'
          AND a.flex_value_id       = c.flex_value_id
          AND c.language            = 'US' ) FCY
WHERE led.ledger_id            = glb.ledger_id
AND   ccv.company_code         = glc.segment1
AND ((:P_PERIOD IS NULL AND  
       glb.period_name = led.latest_opened_period_name) OR  
     (glb.period_name          = :P_PERIOD ))
AND   glc.code_combination_id  = glb.code_combination_id
AND   glb.currency_code        = (SELECT SUBSTR(parent_PK1_VALUE,4)
                                    FROM fnd_tree_node ftn
                                        ,fnd_tree_version_vl ftv
                                   WHERE 1=1
                                     AND ftn.tree_Code           =  'Company FCY'
                                     AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                                     AND ftv.tree_Code           = ftn.tree_code
                                     AND ftv.tree_structure_code = ftn.tree_structure_code
                                     AND ftv.tree_version_name   = 'CURRENT'
                                     AND ftn.tree_version_id     = ftv.tree_version_id
                                     AND pk1_start_value         = glc.segment1) 
AND   led.name                 = fcy.ledger_name
AND   glc.segment1             = fcy.company
AND   glc.segment9            <> 'S'
AND   glc.
AND  ((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) <> 0
UNION
SELECT glc.segment1||','||glc.segment2||','||glc.segment3||','||glc.segment4||','||glc.segment5 ||','||glc.segment6||','||glc.segment7||','||glc.segment8||','||glc.segment9||','||
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR(glb.period_net_dr - glb.period_net_cr)||','||led.name||','||glb.currency_code||','||glb.period_name PW_HFM , 'PWHFM' KEY
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
        FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
       WHERE a.flex_value_set_id   = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US') ccv,
	  (SELECT a.flex_value company
         FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
        WHERE a.flex_value_set_id   = b.flex_value_set_id
          AND b.flex_value_set_name = 'CCLF_PWHFM_COMPANY'
          AND a.flex_value_id       = c.flex_value_id
          AND c.language            = 'US' ) FCY
WHERE led.ledger_id            = glb.ledger_id
AND   ccv.company_code         = glc.segment1
AND ((:P_PERIOD IS NULL AND  
       glb.period_name = led.latest_opened_period_name) OR  
     (glb.period_name          = :P_PERIOD ))
AND   glc.code_combination_id  = glb.code_combination_id
AND   glb.currency_code        = 'USD'
AND   led.name                 LIKE '%USD_RPT'
AND   glc.segment1             = fcy.company
AND   glc.segment9            <> 'S'
AND glc.segment1<>'UC09'
AND  ((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) <> 0
*/
--Commented above code as per REL-78 GERITM37807779