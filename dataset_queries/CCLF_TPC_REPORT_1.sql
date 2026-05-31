SELECT glb.period_name,glc.segment1||'.'||glc.segment2||'.'||glc.segment3||'.'||glc.segment4||'.'||glc.segment5||'.'||glc.segment6||'.'||glc.segment7||'.'||glc.segment8||'.'||glc.segment9||'.'||glc.segment10||'.'||glc.segment11 CCD,
ccv.functional_currency ,TO_CHAR(NVL(BEGIN_BALANCE_DR,0)-NVL(BEGIN_BALANCE_CR,0)+NVL(PERIOD_NET_DR,0)-NVL(PERIOD_NET_CR,0)) BALANCE ,TO_CHAR(led.ledger_id),led.name ,led.short_name ,glb.last_update_date
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
        FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
       WHERE a.flex_value_set_id = b.flex_value_set_id
         AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
         AND a.flex_value_id       = c.flex_value_id
         AND c.language            = 'US') ccv
WHERE led.ledger_id = glb.ledger_id
AND   led.ledger_category_code  IN('PRIMARY' ,'ALC')
AND   (led.name LIKE '%PRM' OR led.name LIKE '%FCY')
AND   ((ccv.functional_currency = 'USD' AND led.name LIKE '%FCY') OR      (ccv.functional_currency <> 'USD' AND led.name LIKE '%PRM')) 
AND   ccv.company_code               = glc.segment1
AND  ((glb.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
      (glb.period_name = led.latest_opened_period_name AND :P_PERIOD IS NULL))
AND   glc.segment1 IN ('W00N','W051','W108','W109','W118','W126','W127','W129','W130','W168','W169','W185','W195','W200','W225','W252','W6CA','WC68','WCCA','WELC','WIS9','WP27','WP66','WSM7','WSM8','WSM9')	  
AND   glc.code_combination_id      =   glb.code_combination_id
AND   glb.currency_code            =   led.currency_code
AND   glc.segment9                 <> 'S'
order by glb.last_update_date desc