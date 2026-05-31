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