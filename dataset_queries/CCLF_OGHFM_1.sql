SELECT 'OGHFM' KEY,glc.segment1 COMPANY_CODE,glc.segment2 ACCOUNT, glc.segment3 TRADING_PARTNER,glc.segment4 COST_CENTER,glc.segment5 GEOGRAPHY,
glc.segment6 PROJECT,glc.segment7 REFERENCE_CODE,glc.segment8 PRODUCT_LINE,glc.segment9 BOOK_TYPE ,
TO_CHAR((glb.begin_balance_dr - glb.begin_balance_cr) + (glb.period_net_dr - glb.period_net_cr)) ytd_balance,
TO_CHAR((glb.quarter_to_date_dr - glb.quarter_to_date_cr) + (glb.period_net_dr - glb.period_net_cr)) qtd_balance,
TO_CHAR(glb.period_net_dr - glb.period_net_cr) ptd_balance,
led.name LEDGER_NAME, glb.currency_code, glb.period_name
FROM   gl_balances glb,
       gl_code_combinations glc,
       gl_ledgers  led,
      (SELECT ftn.pk1_start_value COMPANY,fcycur.currency CURRENCY
         FROM fnd_tree_node ftn
             ,fnd_tree_version_vl ftv
             ,(SELECT pk1_start_value company, SUBSTR(parent_pk1_value,4) currency
                 FROM fnd_tree_node ftn
                     ,fnd_tree_version_vl ftv
                WHERE 1=1
                  AND ftn.tree_Code           = 'Company FCY'
                  AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
                  AND ftv.tree_Code           = ftn.tree_code
                  AND ftv.tree_structure_code = ftn.tree_structure_code
                  AND ftv.tree_version_name   = 'CURRENT'
                  AND ftn.tree_version_id     = ftv.tree_version_id ) FCYCUR	  
        WHERE 1=1
          AND ftn.tree_Code           =  'COMPANY UNPUBLISHED' --'COMPANY MARS UNPUBLISHED' 
          AND ftn.tree_structure_code = 'GL_ACCT_FLEX'
          AND ftv.tree_Code           = ftn.tree_code
          AND ftv.tree_structure_code = ftn.tree_structure_code
          AND ftv.tree_version_name   = 'CURRENT'
          AND ftn.tree_version_id     = ftv.tree_version_id
          AND ftn.parent_pk1_value    IN ('1OILGS','CLGLOG') -- 'OILTRN'
          AND fcycur.company          = ftn.pk1_start_value) FCY 
WHERE led.ledger_id                = glb.ledger_id
  AND glb.period_name              = NVL(:P_PERIOD , led.latest_opened_period_name)
  AND glc.code_combination_id      = glb.code_combination_id
  AND glb.currency_code            = fcy.currency
  AND   (led.name LIKE '%_'||FCY.currency||'_FCY' OR led.name LIKE '%_'||FCY.currency||'_PRM')
  AND glc.segment1                 = fcy.company 
  AND glc.segment9                 <> 'S'  
ORDER BY 2,3,4,5