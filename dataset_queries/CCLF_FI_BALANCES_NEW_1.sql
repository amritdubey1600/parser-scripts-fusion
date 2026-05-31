SELECT 'V360' COMPANY_CODE,ledger_id||'~'||ledger_short_name||'~'||ledger_category_code||'~'||functional_currency_code||'~'||period_name||'~'||period_num||'~'||period_year||'~'||code_combination_id||'~'||company_code||'~'||
  account||'~'||trading_partner||'~'||cost_center||'~'||geography||'~'||project_code||'~'||ref_code||'~'||product_line||'~'||book_type||'~'||future1||'~'||future2||'~'||BAL_CURRENCY_CODE||'~'||begin_balance||'~'||
  begin_func_equivalent||'~'||ptd_balance||'~'||ptd_func_equivalent||'~'||ytd_balance||'~'||ytd_func_equivalent||'~'||qtd_balance||'~'||qtd_func_equivalent||'~'||begin_balance_dr||'~'||begin_balance_cr||'~'||
  begin_balance_dr_beq||'~'||begin_balance_cr_beq||'~'||period_net_dr||'~'||period_net_cr||'~'||period_net_dr_beq||'~'||period_net_cr_beq||'~'||account_type||'~'||last_update_date
  "FI_BALANCES"
FROM
  (SELECT TO_CHAR(l.ledger_id) ledger_id, l.short_name ledger_short_name, l.ledger_category_code, l.currency_code functional_currency_code, b.period_name, 
          b.period_num , b.period_year, TO_CHAR(b.code_combination_id) code_combination_id, 
          cc.segment1 company_code,cc.segment2 account, cc.segment3 trading_partner, cc.segment4 cost_center,cc.segment5 geography,    
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
    TO_CHAR(b.last_update_date,'YYYY/MM/DD HH24:MI:SS') last_update_date
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
  AND   ((ccv.functional_currency = 'USD' AND l.name LIKE '%FCY') OR (ccv.functional_currency <> 'USD' AND l.name LIKE '%PRM')) 
  AND   ccv.company_code       = cc.segment1
  AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR (:P_PERIOD IS NULL))
 UNION ALL
 SELECT TO_CHAR(l.ledger_id) ledger_id, l.short_name ledger_short_name, l.ledger_category_code, l.currency_code functional_currency_code, b.period_name, b.period_num , b.period_year,
           TO_CHAR(b.code_combination_id) code_combination_id, cc.segment1 company_code,cc.segment2 account, cc.segment3 trading_partner, cc.segment4 cost_center,cc.segment5 geography,    
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
     TO_CHAR(b.last_update_date,'YYYY/MM/DD HH24:MI:SS') last_update_date
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
   AND   L.ledger_category_code     =   'SECONDARY' 
   AND   upper(L.description)   LIKE '%STATUTORY%'	
   AND   ccv.company_code       = cc.segment1
  UNION ALL
  SELECT TO_CHAR(l.ledger_id) ledger_id, l.short_name ledger_short_name, l.ledger_category_code, l.currency_code functional_currency_code, b.period_name, b.period_num , b.period_year,
            TO_CHAR(b.code_combination_id) code_combination_id, cc.segment1 company_code,cc.segment2 account, cc.segment3 trading_partner, cc.segment4 cost_center,cc.segment5 geography,    
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
      TO_CHAR(b.last_update_date,'YYYY/MM/DD HH24:MI:SS') last_update_date
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
    AND   l.name LIKE '%RPT'
    AND   l.currency_code='USD'
    AND   l.ledger_category_code     =   'ALC' 
    AND   UPPER(L.description)   LIKE '%REPORTING%'		
    AND   ccv.company_code       = cc.segment1
    AND  ((b.period_name = :P_PERIOD AND :P_PERIOD IS NOT NULL) OR (:P_PERIOD IS NULL)))