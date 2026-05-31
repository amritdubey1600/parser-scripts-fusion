SELECT 'ARM' KEY,
       b.period_year c1_year, 
       b.period_name c2_period, 
       b.period_num c3_period_num, 
       b.currency_code c4_currency, 
       gl.name c5_ledger_name, 
       cc.segment1 c6_company_code, 
       cc.segment2 c7_account, 
       cc.segment3 c8_trading_partner, 
       cc.segment4 c9_cost_center, 
       cc.segment5 c10_geo, 
       cc.segment6 c11_project, 
       cc.segment7 c12_reference, 
       cc.segment8 c13_product_line, 
       cc.segment9 c14_book_type, 
       cc.segment10 c15_flex1, 
       cc.segment11 c16_flex2, 
       b.begin_balance_dr c17_begin_balance_dr, 
       b.begin_balance_cr c18_begin_balance_cr, 
       b.period_net_dr c19_period_net_dr, 
       b.period_net_cr c20_period_net_cr, 
       ((b.begin_balance_dr-b.begin_balance_cr)+(b.period_net_dr-b.period_net_cr)) c21_amount, 
       cc.segment1||'-'||cc.segment2||'-'||cc.segment3||'-'||cc.segment4||'-'||cc.segment5||'-'||cc.segment6||'-'||cc.segment7||'-'||cc.segment8||'-'||cc.segment9||'-'||cc.segment10||'-'||cc.segment11 c22_profile 
FROM   gl_balances b,
       gl_code_combinations cc,
       gl_ledgers gl 
WHERE  1=1 
AND    b.period_num <> 13 
AND   ((b.period_name = :p_period AND :p_period IS NOT NULL) OR
       (b.period_name = gl.latest_opened_period_name AND :p_period IS NULL))
AND    (cc.segment2 LIKE '1%' OR cc.segment2 LIKE '2%' OR cc.segment2 LIKE '3%')  -- Account
AND    b.code_combination_id = cc.code_combination_id 
AND    b.ledger_id           = gl.ledger_id 
AND    b.currency_code       = gl.currency_code
AND    NVL(b.translated_flag,'ZZ') <> 'Y' 
AND    b.currency_code <> 'STAT'   
AND    cc.segment9 IN('P','G','S')  -- Book Type