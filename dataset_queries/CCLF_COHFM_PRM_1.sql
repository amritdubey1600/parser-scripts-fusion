SELECT glc.segment1 COMPANY_CODE,glc.segment2 ACCOUNT, glc.segment3 TRADING_PARTNER,glc.segment4 COST_CENTER,glc.segment5 GEOGRAPHY,
glc.segment6 PROJECT,glc.segment7 REFERENCE_CODE,glc.segment8 PRODUCT_LINE,glc.segment9 BOOK_TYPE ,
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) ytd_balance,
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr)) qtd_balance,
TO_CHAR(glb.period_net_dr - glb.period_net_cr) ptd_balance,
led.name LEDGER_NAME, glb.currency_code, glb.period_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
        FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
       WHERE a.flex_value_set_id = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US') ccv
WHERE led.ledger_id                = glb.ledger_id
AND   ccv.company_code             = glc.segment1
AND   glb.period_name              = :P_PERIOD 
--AND   TO_CHAR(glb.last_update_date,'DD-MM-YYYY')         <  '02-04-2016'
AND   glc.code_combination_id      =   glb.code_combination_id
AND  glb.currency_code = 'USD'
AND  led.name = 'CA_USD_FCY' 
AND  glc.segment1 IN ('W022', 'WELC', 'WY9C', 'W117', 'W127' , 'HQCA')
AND   glc.segment9                 <> 'S'
UNION
SELECT glc.segment1 COMPANY_CODE,glc.segment2 ACCOUNT, glc.segment3 TRADING_PARTNER,glc.segment4 COST_CENTER,glc.segment5 GEOGRAPHY,
glc.segment6 PROJECT,glc.segment7 REFERENCE_CODE,glc.segment8 PRODUCT_LINE,glc.segment9 BOOK_TYPE ,
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) ytd_balance,
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr)) qtd_balance,
TO_CHAR(glb.period_net_dr - glb.period_net_cr) ptd_balance,
led.name LEDGER_NAME, glb.currency_code, glb.period_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
        FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
       WHERE a.flex_value_set_id = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US') ccv
WHERE led.ledger_id                = glb.ledger_id
AND   ccv.company_code             = glc.segment1
AND   glb.period_name              = :P_PERIOD 
--AND   TO_CHAR(glb.last_update_date,'DD-MM-YYYY')         < '02-04-2016'
AND   glc.code_combination_id      =   glb.code_combination_id
AND  glb.currency_code = 'CAD'
AND   led.name = 'CA_CAD_PRM' 
AND   glc.segment1 IN ('WP66','WC68','W167','W168','W169','W185','W225','W252','W266','W268','W269','W118','W00N','W195',
'W200','W126','WP27','W129','W130','W051','WCCA','W054','W108','W109','WIS9','WVFS','WM37','WSM7','W6CA','WID9','WNP3','WNVA','WSM8','WSM9')
AND   glc.segment9                 <> 'S'