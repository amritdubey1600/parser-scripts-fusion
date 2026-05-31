/* REL-005 adding company range parameters and Account description by Jonghun */
SELECT TO_CHAR(l.ledger_id) ledger_id, l.name ledger_short_name, l.ledger_category_code,
l.currency_code functional_currency_code, 
b.period_name, b.period_num , b.period_year,
          TO_CHAR(b.code_combination_id) code_combination_id, cc.segment1 company_code,cc.segment2 account, 
          (  -- REL-005 adding account description
          SELECT fvt.description ACCT_DESC --, fv.flex_value  ACCT_CODE, fseg.flex_value_set_id
          FROM   fnd_id_flex_structures_vl fstr, fnd_id_flex_segments fseg, fnd_flex_values fv, fnd_flex_values_tl fvt
          WHERE  fstr.id_flex_structure_code = 'CCL Accounting Flexfield'
          AND   fseg.segment_name = 'Account'
          AND   fseg.flex_value_set_id = fv.flex_value_set_id
          AND   fv.flex_value_id = fvt.flex_value_id
          AND   fvt.language    = 'US'
          AND   fv.flex_value = cc.segment2
          ) account_desc,
          cc.segment3 trading_partner, cc.segment4 cost_center,cc.segment5 geography,    
          cc.segment6 project_code, cc.segment7 ref_code, cc.segment8 product_line, cc.segment9 book_type, cc.segment10 future1, cc.segment11 future2,b.currency_code BAL_CURRENCY_CODE ,    
    TO_CHAR(b.begin_balance_dr - b.begin_balance_cr) begin_balance, 
    TO_CHAR(NVL(b.begin_balance_dr_beq, 0)    - NVL (b.begin_balance_cr_beq, 0)) begin_func_equivalent,
    TO_CHAR(b.period_net_dr - b.period_net_cr) ptd_balance,  TO_CHAR(NVL (b.period_net_dr_beq, 0)- NVL (b.period_net_cr_beq, 0)) ptd_func_equivalent,
    TO_CHAR((b.begin_balance_dr - b.begin_balance_cr) + (b.period_net_dr - b.period_net_cr)) ytd_balance,
    TO_CHAR( NVL (b.begin_balance_dr_beq, 0)   - NVL (b.begin_balance_cr_beq, 0) + NVL (b.period_net_dr_beq, 0) - NVL (b.period_net_cr_beq, 0) ) ytd_func_equivalent,
    TO_CHAR((b.quarter_to_date_dr - b.quarter_to_date_cr) + (b.period_net_dr - b.period_net_cr)) qtd_balance,
    TO_CHAR((NVL (b.quarter_to_date_dr_beq, 0) - NVL (b.quarter_to_date_cr_beq, 0)) + (NVL (b.period_net_dr_beq, 0) - NVL (b.period_net_cr_beq, 0))) qtd_func_equivalent,
    TO_CHAR(b.begin_balance_dr) begin_balance_dr,
    TO_CHAR(b.begin_balance_cr) begin_balance_cr,
    TO_CHAR(b.begin_balance_dr_beq) begin_balance_dr_beq,
    TO_CHAR(b.begin_balance_cr_beq) begin_balance_cr_beq,
    TO_CHAR(b.period_net_dr) period_net_dr,
    TO_CHAR(b.period_net_cr) period_net_cr,
    TO_CHAR(b.period_net_dr_beq) period_net_dr_beq,
    TO_CHAR(b.period_net_cr_beq) period_net_cr_beq,
    cc.account_type,
    b.last_update_date
  FROM gl_code_combinations cc,
       gl_ledgers l,
       gl_balances b,
        (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
           FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
          WHERE a.flex_value_set_id = b.flex_value_set_id
            AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
            AND a.flex_value_id       = c.flex_value_id
            AND c.language            = 'US') ccv
  WHERE l.ledger_id            = b.ledger_id
  AND   cc.code_combination_id = b.code_combination_id
  AND  NVL(b.translated_flag,'Z') <> 'Y'   
  AND  (l.name LIKE '%FCY' OR l.name LIKE '%PRM')
  AND  b.currency_code <> 'STAT'  
  /* REL-005 parameter changes
  AND  ((cc.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
        (1 = 1 AND :P_COMPANY IS NULL)) */
  AND  cc.segment1 >= nvl(:P_COMPANY_FROM, cc.segment1) 
  AND  cc.segment1 <= nvl(:P_COMPANY_TO, cc.segment1)    
  /* End of REL-005 parameter changes */
  AND   ccv.company_code       = cc.segment1
  AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (b.period_name = l.latest_opened_period_name AND :P_PERIOD IS NULL))
 UNION ALL
 SELECT TO_CHAR(l.ledger_id) ledger_id, l.name ledger_short_name, l.ledger_category_code, 
 DECODE(cc.segment1,'T283','USD',ccv.functional_currency) functional_currency_code, b.period_name, b.period_num , b.period_year,
           TO_CHAR(b.code_combination_id) code_combination_id, cc.segment1 company_code,cc.segment2 account, 
           (  -- REL-005 adding account description
          SELECT fvt.description ACCT_DESC --, fv.flex_value  ACCT_CODE, fseg.flex_value_set_id
          FROM   fnd_id_flex_structures_vl fstr, fnd_id_flex_segments fseg, fnd_flex_values fv, fnd_flex_values_tl fvt
          WHERE  fstr.id_flex_structure_code = 'CCL Accounting Flexfield'
          AND   fseg.segment_name = 'Account'
          AND   fseg.flex_value_set_id = fv.flex_value_set_id
          AND   fv.flex_value_id = fvt.flex_value_id
          AND   fvt.language    = 'US'
          AND   fv.flex_value = cc.segment2
          ) account_desc,
           cc.segment3 trading_partner, cc.segment4 cost_center,cc.segment5 geography,    
           cc.segment6 project_code, cc.segment7 ref_code, cc.segment8 product_line, cc.segment9 book_type, cc.segment10 future1, cc.segment11 future2,b.currency_code BAL_CURRENCY_CODE ,    
     TO_CHAR(b.begin_balance_dr - b.begin_balance_cr) begin_balance, 
     TO_CHAR(NVL(b.begin_balance_dr_beq, 0)    - NVL (b.begin_balance_cr_beq, 0)) begin_func_equivalent,
     TO_CHAR(b.period_net_dr - b.period_net_cr) ptd_balance,  TO_CHAR(NVL (b.period_net_dr_beq, 0)- NVL (b.period_net_cr_beq, 0)) ptd_func_equivalent,
     TO_CHAR((b.begin_balance_dr - b.begin_balance_cr) + (b.period_net_dr - b.period_net_cr)) ytd_balance,
     TO_CHAR( NVL (b.begin_balance_dr_beq, 0)   - NVL (b.begin_balance_cr_beq, 0) + NVL (b.period_net_dr_beq, 0) - NVL (b.period_net_cr_beq, 0) ) ytd_func_equivalent,
     TO_CHAR((b.quarter_to_date_dr - b.quarter_to_date_cr) + (b.period_net_dr - b.period_net_cr)) qtd_balance,
     TO_CHAR((NVL (b.quarter_to_date_dr_beq, 0) - NVL (b.quarter_to_date_cr_beq, 0)) + (NVL (b.period_net_dr_beq, 0) - NVL (b.period_net_cr_beq, 0))) qtd_func_equivalent,
     TO_CHAR(b.begin_balance_dr) begin_balance_dr,
     TO_CHAR(b.begin_balance_cr) begin_balance_cr,
     TO_CHAR(b.begin_balance_dr_beq) begin_balance_dr_beq,
     TO_CHAR(b.begin_balance_cr_beq) begin_balance_cr_beq,
     TO_CHAR(b.period_net_dr) period_net_dr,
     TO_CHAR(b.period_net_cr) period_net_cr,
     TO_CHAR(b.period_net_dr_beq) period_net_dr_beq,
     TO_CHAR(b.period_net_cr_beq) period_net_cr_beq,
     cc.account_type,
     b.last_update_date
   FROM gl_code_combinations cc,
        gl_ledgers l,
        gl_balances b,
         (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
            FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
           WHERE a.flex_value_set_id = b.flex_value_set_id
             AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
             AND a.flex_value_id       = c.flex_value_id
             AND c.language            = 'US') ccv
   WHERE l.ledger_id            = b.ledger_id
   AND   cc.code_combination_id = b.code_combination_id
   AND   L.name like '%STA'
   AND  NVL(b.translated_flag,'Z') <> 'Y'   
   AND  b.currency_code <> 'STAT'   
   AND   L.ledger_category_code     =   'SECONDARY' 
   AND   upper(L.description)   LIKE '%STATUTORY%'	
   /* REL-005 parameter changes
   AND  ((cc.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
        (1 = 1 AND :P_COMPANY IS NULL)) */
   AND  cc.segment1 >= nvl(:P_COMPANY_FROM, cc.segment1) 
   AND  cc.segment1 <= nvl(:P_COMPANY_TO, cc.segment1)    
    /* End of REL-005 parameter changes */     
   AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
        (b.period_name = l.latest_opened_period_name AND :P_PERIOD IS NULL))
   AND   ccv.company_code       = cc.segment1
  UNION ALL
  SELECT TO_CHAR(l.ledger_id) ledger_id, l.name ledger_short_name, l.ledger_category_code, 
  DECODE(cc.segment1,'T283','USD',ccv.functional_currency) functional_currency_code, b.period_name, b.period_num , b.period_year,
            TO_CHAR(b.code_combination_id) code_combination_id, cc.segment1 company_code,cc.segment2 account, 
            (  -- REL-005 adding account description
          SELECT fvt.description ACCT_DESC --, fv.flex_value  ACCT_CODE, fseg.flex_value_set_id
          FROM   fnd_id_flex_structures_vl fstr, fnd_id_flex_segments fseg, fnd_flex_values fv, fnd_flex_values_tl fvt
          WHERE  fstr.id_flex_structure_code = 'CCL Accounting Flexfield'
          AND   fseg.segment_name = 'Account'
          AND   fseg.flex_value_set_id = fv.flex_value_set_id
          AND   fv.flex_value_id = fvt.flex_value_id
          AND   fvt.language    = 'US'
          AND   fv.flex_value = cc.segment2
          ) account_desc,
            cc.segment3 trading_partner, cc.segment4 cost_center,cc.segment5 geography,    
            cc.segment6 project_code, cc.segment7 ref_code, cc.segment8 product_line, cc.segment9 book_type, cc.segment10 future1, cc.segment11 future2,b.currency_code BAL_CURRENCY_CODE ,    
      TO_CHAR(b.begin_balance_dr - b.begin_balance_cr) begin_balance, 
      TO_CHAR(NVL(b.begin_balance_dr_beq, 0)    - NVL (b.begin_balance_cr_beq, 0)) begin_func_equivalent,
      TO_CHAR(b.period_net_dr - b.period_net_cr) ptd_balance,  TO_CHAR(NVL (b.period_net_dr_beq, 0)- NVL (b.period_net_cr_beq, 0)) ptd_func_equivalent,
      TO_CHAR((b.begin_balance_dr - b.begin_balance_cr) + (b.period_net_dr - b.period_net_cr)) ytd_balance,
      TO_CHAR( NVL (b.begin_balance_dr_beq, 0)   - NVL (b.begin_balance_cr_beq, 0) + NVL (b.period_net_dr_beq, 0) - NVL (b.period_net_cr_beq, 0) ) ytd_func_equivalent,
      TO_CHAR((b.quarter_to_date_dr - b.quarter_to_date_cr) + (b.period_net_dr - b.period_net_cr)) qtd_balance,
      TO_CHAR((NVL (b.quarter_to_date_dr_beq, 0) - NVL (b.quarter_to_date_cr_beq, 0)) + (NVL (b.period_net_dr_beq, 0) - NVL (b.period_net_cr_beq, 0))) qtd_func_equivalent,
      TO_CHAR(b.begin_balance_dr) begin_balance_dr,
      TO_CHAR(b.begin_balance_cr) begin_balance_cr,
      TO_CHAR(b.begin_balance_dr_beq) begin_balance_dr_beq,
      TO_CHAR(b.begin_balance_cr_beq) begin_balance_cr_beq,
      TO_CHAR(b.period_net_dr) period_net_dr,
      TO_CHAR(b.period_net_cr) period_net_cr,
      TO_CHAR(b.period_net_dr_beq) period_net_dr_beq,
      TO_CHAR(b.period_net_cr_beq) period_net_cr_beq,
      cc.account_type,
      b.last_update_date
    FROM gl_code_combinations cc,
         gl_ledgers l,
         gl_balances b,
          (SELECT a.flex_value COMPANY_CODE,c.description, a.enabled_flag,a.start_date_active,a.end_date_active,a.summary_flag,a.attribute5 functional_currency
             FROM fnd_flex_values a, fnd_flex_value_sets b, fnd_flex_values_tl c
            WHERE a.flex_value_set_id = b.flex_value_set_id
              AND b.flex_value_set_name = 'CCL_COMPANY_CODES'
              AND a.flex_value_id       = c.flex_value_id
              AND c.language            = 'US') ccv
    WHERE l.ledger_id            = b.ledger_id
    AND   cc.code_combination_id = b.code_combination_id
    AND  L.name like '%RPT'
    AND  L.currency_code='USD'
    AND  NVL(b.translated_flag,'Z') <> 'Y'  
    AND  L.ledger_category_code     =   'ALC' 
    AND  b.currency_code <> 'STAT'    
    AND  upper(L.description)   LIKE '%REPORTING%'		
    /* REL-005 parameter changes 
    AND  ((cc.segment1 = :P_COMPANY AND :P_COMPANY IS NOT NULL) OR
        (1 = 1 AND :P_COMPANY IS NULL)) */
    AND  cc.segment1 >= nvl(:P_COMPANY_FROM, cc.segment1) 
    AND  cc.segment1 <= nvl(:P_COMPANY_TO, cc.segment1)    
    /* End of REL-005 parameter changes */    
    AND   ccv.company_code       = cc.segment1
    AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR
          (b.period_name = l.latest_opened_period_name AND :P_PERIOD IS NULL))
ORDER BY 39 DESC