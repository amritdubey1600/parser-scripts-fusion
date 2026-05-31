SELECT name 
  FROM GL_LEDGERS gl
 WHERE (gl.name LIKE '%FCY' OR gl.name LIKE '%RPT')
   AND EXISTS(SELECT 'Y'
                FROM FND_LOOKUP_VALUES        flv, 
				     CST_COST_ORG_BOOKS       cob, 
					 CST_COST_BOOKS_B         ccbb,
					 GL_LEDGER_RELATIONSHIPS  glr
               WHERE flv.lookup_type          = 'GE_FX_TRUEUP_COST_BOOKS'
                 AND flv.language             = 'US'
                 AND flv.enabled_flag         = 'Y'
                 AND flv.lookup_code          = ccbb.cost_book_code
				 AND cob.cost_book_id         = ccbb.cost_book_id
				 AND glr.primary_ledger_id    = cob.ledger_id
			     AND glr.application_id       = 101
				 AND glr.target_ledger_id     = gl.ledger_id
                 AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                 AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
             )