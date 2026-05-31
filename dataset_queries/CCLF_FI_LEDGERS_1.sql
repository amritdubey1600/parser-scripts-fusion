SELECT 'LEDGER' KEY, TO_CHAR(ledger_id)||'~'||short_name||'~'||currency_code||'~'||name||'~'||description||'~'||ledger_category_code||'~'||chart_of_accounts_id||'~'||period_set_name||'~'||
         attribute1||'~'||attribute2||'~'||attribute3||'~'||attribute4||'~'||created_by||'~'||TO_CHAR(creation_date,'YYYYMMDD HH24:MI:SS')||'~'||
         last_updated_by||'~'||TO_CHAR(last_update_date,'YYYYMMDD HH24:MI:SS') LEDGER
       FROM GL_LEDGERS
    WHERE ledger_attributes = 'L'

  -- REL-015 added  below code
  
AND  name  NOT  IN  
    (
        SELECT  lookup_code
          FROM FND_LOOKUP_VALUES
         WHERE lookup_type  ='CIRRUSGL_ERP_INT_LEDGER_NAME'
           AND  language='US'
           AND enabled_Flag='Y'
           AND   TRUNC( sysdate)  
               BETWEEN    NVL ( start_date_active , TRUNC(SYSDATE)) 
               AND NVL( end_date_active ,TRUNC(SYSDATE))
     )

-- REL-015 added  above  code