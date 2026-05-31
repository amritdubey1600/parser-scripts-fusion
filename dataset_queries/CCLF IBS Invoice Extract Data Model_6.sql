SELECT 'I29' record_key_i29,
      RPAD(' ',21) not_used_1,
      RPAD(' ',6) invoice_group_id,
      RPAD(' ',7) not_used_2,
      RPAD(UPPER(c.attribute2),3) book_currency_code, 
      (SELECT SIGN(SUM(NVL(amount,0))) from RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC' ) invoice_amount_sign,
      (SELECT LPAD(ABS(SUM(ROUND(NVL(amount,0),fc.precision)) * POWER(10,fc.precision)),15,0) FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC') invoice_amount, -- REL-036
      (SELECT DECODE(gl.currency_code, c.attribute2, LPAD(ABS(SUM(ROUND(NVL(acctd_amount,1),fc.precision)) * POWER(10,fc.precision)),15,0)
	    , LPAD(ABS(SUM(ROUND((amount *  rct.exchange_rate), fc.precision)) * POWER(10,fc.precision)),15,0)
	      ) FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC' ) book_amount,  
      (SELECT DECODE(gl.currency_code, c.attribute2, SIGN(SUM(NVL(acctd_amount,1)))
	      , SIGN(SUM(ROUND((amount *  rct.exchange_rate), fc.precision)))
	      ) FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC') book_amount_sign,
      (SELECT DECODE(gl.currency_code, c.attribute2, (SUM(NVL(acctd_amount,1)) * POWER(10,fc.precision))
      , (SUM(ROUND((amount *  rct.exchange_rate), fc.precision)) * POWER(10,fc.precision))
      ) FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC') acctd_amount_actual
	,SUBSTR((SELECT LPAD(ABS(SUM(ROUND(NVL(amount,0),fc.precision)) * POWER(10,fc.precision)),15,0) FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC'),15,1) invoice_amount_last_char
      ,SUBSTR((SELECT DECODE(gl.currency_code, c.attribute2, LPAD(ABS(SUM(ROUND(NVL(acctd_amount,1),fc.precision)) * POWER(10,fc.precision)),15,0)
	    , LPAD(ABS(SUM(ROUND((amount *  rct.exchange_rate), fc.precision)) * POWER(10,fc.precision)),15,0)
	      ) FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
      WHERE rct_in.customer_trx_id = rctg.customer_trx_id AND account_class = 'REC' ),15,1) book_amount_last_char,
	rct.customer_trx_id
FROM RA_CUST_TRX_LINE_GL_DIST_ALL rctg
     ,RA_CUST_TRX_TYPES_ALL c
     ,RA_CUSTOMER_TRX_ALL rct
     ,GL_LEDGERS gl
     ,FND_CURRENCIES fc
     ,fun_all_business_units_v h
WHERE 1=1
AND rctg.customer_trx_id = rct.customer_trx_id
AND c.CUST_TRX_TYPE_SEQ_ID = rct.cust_trx_type_seq_id
AND c.attribute1 = 'Y'
AND fc.currency_code = rct.invoice_currency_code
AND h.bu_id= rct.org_id
--AND TO_NUMBER (h.org_information3) = gl.ledger_id 
AND h.primary_ledger_id = gl.ledger_id
--AND gl.currency_code = fc.currency_code
AND account_class = 'REC'