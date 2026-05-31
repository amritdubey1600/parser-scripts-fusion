WITH 
CCLF_DR4_UNIFORM AS
(
SELECT sender_id||','||data_type||','||period_name||','||company_code||','||account||','||trading_partner||','||cost_center||','||
 geography||','||project_code||','||reference_code||','||product_line||','||book_type||','||future1||','||future2||','||
 functional_currency_code||','||
	TO_CHAR(ptd_func_equivalent)||','||
	reporting_currency_code||','||
  TO_CHAR(rep_curr_ptd_balance)||',,,,,,,,,,,,,,,,,'||rep_ledg_short_name DR4_TRANSP
FROM (
SELECT sender_id,data_type,PERIOD_NAME,COMPANY_CODE,ACCOUNT,TRADING_PARTNER,COST_CENTER,GEOGRAPHY,PROJECT_CODE,REFERENCE_CODE,PRODUCT_LINE,BOOK_TYPE,FUTURE1,FUTURE2,functional_currency_code,
    SUM(NVL(ytd_func_equivalent,0)) ytd_func_equivalent,
	SUM(NVL(begin_func_equivalent,0)) begin_func_equivalent,
    SUM(NVL(ptd_func_equivalent,0)) ptd_func_equivalent,
	reporting_currency_code,
	SUM(NVL(rep_curr_ytd_balance,0)) rep_curr_ytd_balance,
    SUM(NVL(rep_curr_begin_balance,0)) rep_curr_begin_balance, 
	SUM(NVL(rep_curr_ptd_balance,0)) rep_curr_ptd_balance,
	rep_ledg_short_name
FROM  (
SELECT 'GBSIMT' sender_id,'CCLBALEXFCES' data_type, glb.period_name ,glc.segment1 company_code,glc.segment2 account,glc.segment3 trading_partner,glc.segment4 cost_center,glc.segment5 geography,
        glc.segment6 project_code,glc.segment7 reference_code,glc.segment8 product_line,glc.segment9 book_type,glc.segment10 future1,glc.segment11 future2, 
        ccv.functional_currency functional_currency_code,
        'USD' reporting_currency_code,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) ytd_func_equivalent,
		NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) begin_func_equivalent,
        NVL(period_net_dr,0) - NVL(period_net_cr,0) ptd_func_equivalent,
        NULL rep_curr_ytd_balance,NULL rep_curr_begin_balance, 
		0 rep_curr_ptd_balance,
        led.ledger_id pri_ledg_id, led.short_name pri_ledg_short_name,
       led.name
          rep_ledg_short_name
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
     AND  (
	       (
		    ccv.functional_currency = 'USD' AND (led.name LIKE '%FCY' OR led.name = 'US_USD_PRM')			
			)		   
		   OR  
                   (ccv.functional_currency <> 'USD' AND led.name LIKE '%PRM')
          )		   
		   AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR        
  (glb.period_name = to_char(sysdate, 'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') AND :P_PERIOD IS NULL))
  AND   EXISTS  ( SELECT 'Y'  
                FROM fnd_flex_value_sets a1,
                     fnd_flex_values b1,
		             fnd_flex_values_tl c1
                WHERE a1.flex_value_set_id=b1.flex_value_set_id
               AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
                  and b1.flex_value_id =c1.flex_value_id
                  and c1.language = userenv('LANG')
 		          and b1.ENABLED_FLAG = 'Y'
				  and b1.FLEX_VALUE = glc.segment1 )
  AND ccv.company_code               = glc.segment1
  AND glc.code_combination_id      =   glb.code_combination_id
  AND glb.currency_code            =   led.currency_code
  --AND (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)<> 0 OR  NVL(period_net_dr,0) - NVL(period_net_cr,0) <>0)

)
GROUP BY sender_id,data_type,period_name, company_code, account, trading_partner,cost_center,geography,project_code, reference_code,
product_line,book_type,future1,future2, functional_currency_code,reporting_currency_code,rep_ledg_short_name,pri_ledg_short_name
UNION ALL
SELECT sender_id,data_type,PERIOD_NAME,COMPANY_CODE,ACCOUNT,TRADING_PARTNER,COST_CENTER,GEOGRAPHY,PROJECT_CODE,REFERENCE_CODE,PRODUCT_LINE,BOOK_TYPE,FUTURE1,FUTURE2,functional_currency_code,
    SUM(NVL(ytd_func_equivalent,0)) ytd_func_equivalent,
	SUM(NVL(begin_func_equivalent,0)) begin_func_equivalent,
    SUM(NVL(ptd_func_equivalent,0)) ptd_func_equivalent,
	reporting_currency_code,
	SUM(NVL(rep_curr_ytd_balance,0)) rep_curr_ytd_balance,
    SUM(NVL(rep_curr_begin_balance,0)) rep_curr_begin_balance, 
	SUM(NVL(rep_curr_ptd_balance,0)) rep_curr_ptd_balance,
	rep_ledg_short_name
FROM  (
SELECT 'GBSIMT' sender_id,'CCLBALEXFCES' data_type, glb.period_name ,glc.segment1 company_code,glc.segment2 account,glc.segment3 trading_partner,glc.segment4 cost_center,glc.segment5 geography,
        glc.segment6 project_code,glc.segment7 reference_code,glc.segment8 product_line,glc.segment9 book_type,glc.segment10 future1,glc.segment11 future2, 
        ccv.functional_currency functional_currency_code,
        led.currency_code reporting_currency_code,
        (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) + NVL(period_net_dr,0) - NVL(period_net_cr,0)) ytd_func_equivalent,
		NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0) begin_func_equivalent,
        0 ptd_func_equivalent,
        NULL rep_curr_ytd_balance,NULL rep_curr_begin_balance, 
		NVL(period_net_dr,0) - NVL(period_net_cr,0) rep_curr_ptd_balance,
        led.ledger_id pri_ledg_id, led.short_name pri_ledg_short_name,
       led.name
          rep_ledg_short_name
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
	AND   led.name like '%USD_RPT'
	AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR        
  (glb.period_name = to_char(sysdate, 'MON-YY','NLS_DATE_LANGUAGE=AMERICAN') AND :P_PERIOD IS NULL))
  AND   EXISTS  ( SELECT 'Y'  
                FROM fnd_flex_value_sets a1,
                     fnd_flex_values b1,
		             fnd_flex_values_tl c1
                WHERE a1.flex_value_set_id=b1.flex_value_set_id
               AND a1.flex_value_set_name='CCLF_DR4_ENERGY_GLOBAL_EXTRACT' 
                  and b1.flex_value_id =c1.flex_value_id
                  and c1.language = userenv('LANG')
 		          and b1.ENABLED_FLAG = 'Y'
				  and b1.FLEX_VALUE = glc.segment1 )
  AND ccv.company_code               = glc.segment1
  AND glc.code_combination_id      =   glb.code_combination_id
  AND glb.currency_code            =   led.currency_code
  --AND (NVL(begin_balance_dr,0) - NVL(begin_balance_cr,0)<> 0 OR  NVL(period_net_dr,0) - NVL(period_net_cr,0) <>0)

)
GROUP BY sender_id,data_type,period_name, company_code, account, trading_partner,cost_center,geography,project_code, reference_code,
product_line,book_type,future1,future2, functional_currency_code,reporting_currency_code,rep_ledg_short_name,pri_ledg_short_name

))
SELECT 'GBSIMT' key,CCLF_DR4_UNIFORM.DR4_TRANSP DR4_TRANSP
FROM CCLF_DR4_UNIFORM
UNION
SELECT 'GBSIMT' key,'GBSIMT,CCLBALEXFCES,'||TO_CHAR(SYSDATE,'YYYYMMDD')||',TRAILER,'||TO_CHAR(COUNT(*)) ||',P' DR4_TRANSP FROM CCLF_DR4_UNIFORM
ORDER BY 2 desc