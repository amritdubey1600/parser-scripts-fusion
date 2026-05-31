SELECT jeh.name journal_name, cc.segment1,
    sum(nvl(jel.entered_dr,0)), sum(nvl(jel.entered_cr,0)),
    sum(nvl(jel.accounted_dr,0)), sum(nvl(jel.accounted_cr,0))
FROM  gl_je_lines jel,
      gl_je_headers jeh,
      gl_code_combinations cc
WHERE jel.status = 'P'
AND   jeh.je_header_id = jel.je_header_id
AND   jeh.actual_flag = 'A'
AND   jeh.period_name = :P_PERIOD_NAME
AND   jel.ledger_id = :LEDGER_ID
AND   jel.period_name= :P_PERIOD_NAME
AND   cc.CHART_OF_ACCOUNTS_ID = :CHART_OF_ACCOUNTS_ID
AND   cc.CODE_COMBINATION_ID = jel.CODE_COMBINATION_ID
AND   cc.segment1 = :SEG1
GROUP BY jeh.name, cc.segment1
HAVING sum(nvl(jel.accounted_dr,0)) - sum(nvl(jel.accounted_cr,0)) != 0