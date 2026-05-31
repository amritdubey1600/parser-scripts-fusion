SELECT 'TPC' KEY, period_name||','||segment1||','||segment2||','||segment3||','||segment4||','||segment5||','||segment6||','||segment7||','||segment8||','||segment9||','||segment10||','||segment11||','||
entered_currency_code||','||TO_CHAR(entered_amount)||','||functional_currency||','||TO_CHAR(functional_balance)||','||reporting_currency||','||reporting_balance||','||
TO_CHAR(ledger_id)||','||Ledger_name||','||Ledger_short_name||','||rep_ledger_id||','||rep_ledger_name||','||rep_ledger_short_name TPC_EXTRACT
FROM
(SELECT /*+ PARALLEL_INDEX */  glb.period_name ,glc.segment1 ,glc.segment2,glc.segment3,glc.segment4,glc.segment5,glc.segment6,glc.segment7,glc.segment8,glc.segment9,glc.segment10,glc.segment11,
       glb.currency_code as entered_currency_code,
       CASE
           WHEN glb.currency_code = ccv.functional_currency THEN (NVL(glb.begin_balance_dr_beq, 0) -  NVL(glb.begin_balance_cr_beq, 0) + 
                                                                  NVL(glb.period_net_dr_beq, 0) - NVL(glb.period_net_cr_beq, 0))
           ELSE (NVL(glb.begin_balance_dr, 0) - NVL(glb.begin_balance_cr, 0) + NVL(glb.period_net_dr, 0) - NVL(glb.period_net_cr, 0)) 
       END as entered_amount,
       ccv.functional_currency,
       NVL (glb.begin_balance_dr_beq, 0)   - NVL (glb.begin_balance_cr_beq, 0) + NVL (glb.period_net_dr_beq, 0) - NVL (glb.period_net_cr_beq, 0) as functional_balance,
       TO_CHAR(led.ledger_id) as ledger_id,led.name Ledger_name,led.short_name Ledger_short_name,
       NULL reporting_currency,NULL reporting_balance,NULL rep_ledger_id,NULL rep_ledger_name,NULL rep_ledger_short_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
        FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
       WHERE a.flex_value_set_id = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US'

-- REL-015 added  below code

         AND a.flex_value NOT IN 
         
          (   SELECT  lookup_code
	         FROM  FND_LOOKUP_VALUES
	      WHERE lookup_type  ='CIRRUSGL_ERP_INT_COCO_NAME'
	           AND  language='US'
	           AND enabled_Flag='Y'
	           AND   TRUNC( sysdate)  
                              BETWEEN   NVL ( start_date_active , TRUNC(SYSDATE)) 
                                        AND NVL( end_date_active ,TRUNC(SYSDATE)) )
         
         
-- REL-015 added Above code      
       
         ) ccv

WHERE led.ledger_id = glb.ledger_id
AND   led.ledger_category_code  IN('PRIMARY' ,'ALC')
AND   (led.name LIKE '%PRM' OR led.name LIKE '%FCY')
AND   NVL(glb.translated_flag,'ZZ') <> 'Y'  
AND   glb.currency_code <> 'STAT'    
AND ( (led.name LIKE '%FCY' AND ccv.functional_currency = SUBSTR(led.name,4,3) 
		 ) OR 
         (led.name LIKE '%PRM' AND ccv.functional_currency = SUBSTR(led.name,4,3) 
		 ))
AND   ccv.company_code               = glc.segment1
--REL-23 code change start here for performance issue
/*AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (glb.period_name = led.latest_opened_period_name AND :P_PERIOD IS NULL))*/	  
AND   glb.period_name = NVL(:P_PERIOD,led.latest_opened_period_name)	
--REL-23 code change end here  
AND   glc.code_combination_id      =   glb.code_combination_id
--AND   glb.currency_code            =   led.currency_code
AND   glc.segment9                 <> 'S'
ORDER BY glc.segment2,glb.currency_code)