WITH 
CCLF_CORPHFM AS
(
SELECT sender_id||','||data_type||','||period_name||','||company_code||','||account||','||trading_partner||','||cost_center||','||
 geography||','||project_code||','||reference_code||','||product_line||','||book_type||','||future1||','||future2||','||
 functional_currency_code||','||to_char(ytd_func_equivalent)||','||TO_CHAR(begin_func_equivalent)||','||
	TO_CHAR(ptd_func_equivalent)||','||reporting_currency_code||','||
  TO_CHAR(rep_curr_ytd_balance)||','||TO_CHAR(rep_curr_begin_balance)||','||TO_CHAR(rep_curr_ptd_balance)||','||rep_ledg_short_name CORPHFM
FROM (
SELECT sender_id,data_type,PERIOD_NAME,COMPANY_CODE,ACCOUNT,TRADING_PARTNER,COST_CENTER,GEOGRAPHY,PROJECT_CODE,REFERENCE_CODE,PRODUCT_LINE,BOOK_TYPE,FUTURE1,FUTURE2,functional_currency_code,
    SUM(NVL(ytd_func_equivalent,0)) ytd_func_equivalent,SUM(NVL(begin_func_equivalent,0)) begin_func_equivalent,
    SUM(NVL(ptd_func_equivalent,0)) ptd_func_equivalent,reporting_currency_code,SUM(NVL(rep_curr_ytd_balance,0)) rep_curr_ytd_balance,
    SUM(NVL(rep_curr_begin_balance,0)) rep_curr_begin_balance, SUM(NVL(rep_curr_ptd_balance,0)) rep_curr_ptd_balance,rep_ledg_short_name	
FROM  (
SELECT 'EMTRCA' sender_id,'CCLBALEXFCES' data_type, glb.period_name ,glc.segment1 company_code,glc.segment2 account,glc.segment3 trading_partner,glc.segment4 cost_center,glc.segment5 geography,
        glc.segment6 project_code,glc.segment7 reference_code,glc.segment8 product_line,glc.segment9 book_type,glc.segment10 future1,glc.segment11 future2, 
        ccv.functional_currency functional_currency_code,
        (SELECT  led_rep.currency_code
          FROM  gl_ledger_relationships glr_rep, gl_ledgers led_rep
         WHERE  glr_rep.target_ledger_id            = led_rep.ledger_id
           AND  glr_rep.target_ledger_id            <> glr_rep.source_ledger_id
           AND  glr_rep.target_ledger_category_code = 'ALC'
  	   AND upper(led_rep.description)   LIKE '%REPORTING%'		
           AND  glr_rep.target_currency_code        = 'USD' 
           AND  glr_rep.source_ledger_id	     = led.ledger_id	) reporting_currency_code,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) ytd_func_equivalent,NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) begin_func_equivalent,
        NVL(period_net_dr,0) - NVL(period_net_cr,0) ptd_func_equivalent,
        NULL rep_curr_ytd_balance,NULL rep_curr_begin_balance, NULL rep_curr_ptd_balance,
        led.ledger_id pri_ledg_id, led.short_name pri_ledg_short_name,
       (SELECT  led_rep.short_name
          FROM  gl_ledger_relationships glr_rep, gl_ledgers led_rep
         WHERE  glr_rep.target_ledger_id            = led_rep.ledger_id
           AND  glr_rep.target_ledger_id            <> glr_rep.source_ledger_id
           AND  glr_rep.target_ledger_category_code = 'ALC'
  	       AND upper(led_rep.description)   LIKE '%REPORTING%'		
           AND  glr_rep.target_currency_code        = 'USD' 
           AND  glr_rep.source_ledger_id	     = led.ledger_id	) rep_ledg_short_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       (SELECT a.flex_value COMPANY_CODE,a.attribute5 functional_currency
          FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
         WHERE a.flex_value_set_id = b.flex_value_set_id
           AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
           AND a.flex_value_id       = c.flex_value_id
           AND c.language            = 'US') ccv,
       gl_ledgers  led
WHERE led.ledger_id = glb.ledger_id
AND led.ledger_category_code     =   'PRIMARY' 
AND ccv.functional_currency <> 'USD'
AND led.short_name NOT LIKE '%STAT'
AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (glb.period_name = led.latest_opened_period_name AND :P_PERIOD IS NULL))
AND ccv.company_code               = glc.segment1
AND glc.code_combination_id      =   glb.code_combination_id
AND glb.currency_code            =   led.currency_code
AND glc.segment9                 <> 'S'
AND (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)<> 0 OR  NVL(period_net_dr,0) - NVL(period_net_cr,0) <>0)
UNION ALL
--
SELECT 'EMTRCA' sender_id,'CCLBALEXFCES' data_type, glb.period_name ,glc.segment1 company_code,glc.segment2 account,glc.segment3 trading_partner,glc.segment4 cost_center,glc.segment5 geography,
        glc.segment6 project_code,glc.segment7 reference_code,glc.segment8 product_line,glc.segment9 book_type,glc.segment10 future1,glc.segment11 future2, 
        ccv.functional_currency functional_currency_code,
        (SELECT  led_rep.currency_code
           FROM  gl_ledgers led_rep
          WHERE  led_rep.name = led.attribute1
    	   AND upper(led_rep.description)   LIKE '%REPORTING%'		
           AND  led_rep.currency_code        = 'USD' )  reporting_currency_code,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) ytd_func_equivalent,NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) begin_func_equivalent,
        NVL(period_net_dr,0) - NVL(period_net_cr,0) ptd_func_equivalent,
        NULL rep_curr_ytd_balance,NULL rep_curr_begin_balance, NULL rep_curr_ptd_balance,
        led.ledger_id pri_ledg_id, led.short_name pri_ledg_short_name,
       (SELECT  led_rep.short_name
          FROM  gl_ledgers led_rep
         WHERE  led_rep.name = led.attribute1
  	   AND upper(led_rep.description)   LIKE '%REPORTING%'		
           AND  led_rep.currency_code        = 'USD' ) rep_ledg_short_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       (SELECT a.flex_value COMPANY_CODE,a.attribute5 functional_currency
          FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
         WHERE a.flex_value_set_id = b.flex_value_set_id
           AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
           AND a.flex_value_id       = c.flex_value_id
           AND c.language            = 'US') ccv,
       gl_ledgers  led
WHERE led.ledger_id = glb.ledger_id
  AND led.ledger_category_code       = 'ALC' 
  AND led.name LIKE '%FCY'
  AND ccv.functional_currency = 'USD'
  AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (glb.period_name = led.latest_opened_period_name AND :P_PERIOD IS NULL))
  AND upper(led.description)           NOT LIKE '%STATU%'
  AND ccv.company_code               = glc.segment1
  AND glc.code_combination_id      =   glb.code_combination_id
  AND glb.currency_code            =   led.currency_code
  AND glc.segment9                 <> 'S'
  AND (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)<> 0 OR  NVL(period_net_dr,0) - NVL(period_net_cr,0) <>0)
  --
UNION ALL
SELECT 'EMTRCA' sender_id,'CCLBALEXFCES' data_type, glb.period_name ,glc.segment1 company_code,glc.segment2 account,glc.segment3 trading_partner,glc.segment4 cost_center,glc.segment5 geography,
        glc.segment6 project_code,glc.segment7 reference_code,glc.segment8 product_line,glc.segment9 book_type,glc.segment10 future1,glc.segment11 future2, 
        ccv.functional_currency functional_currency_code, led.currency_code reporting_currency_code,
        NULL ytd_func_equivalent,
        NULL begin_func_equivalent,
        NULL ptd_func_equivalent,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) rep_curr_ytd_balance,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)) rep_curr_begin_balance, NVL(period_net_dr,0) - NVL(period_net_cr,0) rep_curr_ptd_balance,
	(SELECT a1.source_ledger_id 
                   FROM gl_ledger_relationships a1,
                        gl_ledgers b1
                  WHERE  a1.source_ledger_id           = b1.ledger_id
                    AND   a1.target_ledger_id            <> a1.source_ledger_id
                    AND   a1.target_ledger_category_code = 'ALC'
                    AND b1.name like '%PRM'                  
                    AND   a1.target_currency_code        = 'USD' -- to exclude non-USD reporting ledgers if any in future
                    AND   a1.target_ledger_id	     = led.ledger_id) pri_ledg_id,
       (SELECT b1.short_name
                   FROM gl_ledger_relationships a1,
                        gl_ledgers b1
                  WHERE  a1.source_ledger_id           = b1.ledger_id
                    AND   a1.target_ledger_id            <> a1.source_ledger_id
                    AND   a1.target_ledger_category_code = 'ALC'
                    AND b1.name like '%PRM'                                    
                    AND   a1.target_currency_code        = 'USD' -- to exclude non-USD reporting ledgers if any in future
                    AND   a1.target_ledger_id	     = led.ledger_id) pri_ledg_short_name,
        led.short_name rep_ledg_short_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       (SELECT a.flex_value COMPANY_CODE,a.attribute5 functional_currency
          FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
         WHERE a.flex_value_set_id = b.flex_value_set_id
           AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
           AND a.flex_value_id       = c.flex_value_id
           AND c.language            = 'US') ccv,
       gl_ledgers  led
WHERE led.ledger_id                  = glb.ledger_id
AND led.ledger_category_code       = 'ALC' 
AND led.name like '%RPT'
AND ccv.company_code               = glc.segment1
AND glc.code_combination_id        = glb.code_combination_id
AND glb.currency_code              = led.currency_code
AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (glb.period_name = led.latest_opened_period_name AND :P_PERIOD IS NULL))
AND led.currency_code              = 'USD'
AND glc.segment9                 <> 'S'
AND (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)<> 0 OR  NVL(period_net_dr,0) - NVL(period_net_cr,0) <>0))
GROUP BY sender_id,data_type,period_name, company_code, account, trading_partner,cost_center,geography,project_code, reference_code,
product_line,book_type,future1,future2, functional_currency_code,reporting_currency_code,rep_ledg_short_name))
SELECT CCLF_CORPHFM.*,'P' key
FROM CCLF_CORPHFM
union
SELECT 'EMTRCA,CCLBALEXFCES,'||TO_CHAR(SYSDATE,'YYYYMMDD')||',TRAILER,'||TO_CHAR(COUNT(*)) ||',P' DR4_TRANSP ,'P' key  FROM CCLF_CORPHFM
ORDER BY 1 DESC