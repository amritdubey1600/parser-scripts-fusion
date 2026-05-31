SELECT glc.segment1||','||glc.segment2||','||glc.segment3||','||glc.segment4||','||glc.segment5||','||glc.segment6||','||glc.segment7||','||glc.segment8||','||glc.segment9 combin,
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) YTD_BALANCE,
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr)) QTD_BALANCE,
TO_CHAR(glb.period_net_dr - glb.period_net_cr) PTD_BALANCE,
led.name,glb.currency_code,glb.period_name  
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
AND   led.name                     = :p_ledger
AND  glb.currency_code             = :p_currency
AND   ccv.company_code             = glc.segment1
AND   glc.code_combination_id      =   glb.code_combination_id
AND  glb.period_name = :p_period
AND   glc.segment9                 <> 'S'
AND   glc.segment1 = :p_segment1
AND   glc.segment2 = :p_segment2
AND   glc.segment3 = :p_segment3
AND   glc.segment4 = :p_segment4
AND   glc.segment5 = :p_segment5
AND   glc.segment6 = :p_segment6
AND   glc.segment7 = :p_segment7
AND   glc.segment8 = :p_segment8
AND   glc.segment9 = :p_segment9