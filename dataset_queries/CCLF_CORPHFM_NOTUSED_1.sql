SELECT 'COMPANY_CODE,ACCOUNT,TRADING_PARTNER,COST_CENTER,GEOGRAPHY,PROJECT,REFERENCE_CODE,PRODUCT_LINE,BOOK_TYPE,YTD_BALANCE,QTD_BALANCE,PTD_BALANCE,LEDGER_NAME,CURRENCY,PERIOD' CORP_HFM
FROM DUAL
UNION
SELECT glc.segment1||','||glc.segment2||','||glc.segment3||','||glc.segment4||','||glc.segment5 ||','||glc.segment6||','||glc.segment7||','||glc.segment8||','||glc.segment9||','||
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR(glb.period_net_dr - glb.period_net_cr)||','||led.name||','||glb.currency_code||','||glb.period_name CORP_HFM
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
AND   glc.code_combination_id      =   glb.code_combination_id
AND  glb.currency_code = 'USD'
AND  led.name = 'CA_USD_FCY' 
AND  glc.segment1 IN ('W022', 'WELC', 'WY9C', 'W117', 'W127' , 'HQCA')
AND   glc.segment9                 <> 'S'
UNION
SELECT glc.segment1||','||glc.segment2||','||glc.segment3||','||glc.segment4||','||glc.segment5 ||','||glc.segment6||','||glc.segment7||','||glc.segment8||','||glc.segment9||','||
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr))||','||
TO_CHAR(glb.period_net_dr - glb.period_net_cr)||','||led.name||','||glb.currency_code||','||glb.period_name CORP_HFM
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
AND   glc.code_combination_id      =   glb.code_combination_id
AND  glb.currency_code = 'CAD'
AND   led.name = 'CA_CAD_PRM' 
AND   glc.segment1 IN ('WP66','WC68','W167','W168','W169','W185','W225','W252','W266','W268','W269','W118','W00N','W195',
'W200','W126','WP27','W129','W130','W051','WCCA','W054','W108','W109','WIS9','WVFS','WM37','WSM7','W6CA','WID9','WNP3','WNVA','WSM8','WSM9')
AND   glc.segment9                 <> 'S'