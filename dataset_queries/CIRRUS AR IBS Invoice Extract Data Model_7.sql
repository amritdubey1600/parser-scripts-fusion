select 
'I34' RECORD_KEY_I34,
UPPER(b.short_code) ou_short_code,
      RPAD('SVT',3) inr_tax_type_code,
      'ITX' inr_special_charge_code,
      RPAD(RPAD('SVT',3) || RPAD(' ',3)||
            (LPAD(DECODE(TRUNC(((SELECT SUM(NVL(extended_amount,0))
      				    FROM RA_CUSTOMER_TRX_LINES_ALL
      				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
      				    AND   line_type='TAX') * 100 / ABS(ROUND(NVL(a.extended_amount,1),c.precision))),2),
            NULL,' ',TRIM(TO_CHAR(TRUNC(((SELECT SUM(NVL(extended_amount,0))
      				    FROM RA_CUSTOMER_TRX_LINES_ALL
      				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
      				    AND   line_type='TAX') * 100 / ABS(ROUND(NVL(a.extended_amount,1),c.precision))),2),'99.99')||'%')),6 ) )||RPAD(' ',7)||
             (SELECT NVL(UPPER(ISSUING_TERRITORY_CODE),'  ')
           			FROM FND_CURRENCIES
          			WHERE currency_code = rctt.attribute2)||(NVL((SELECT SUM(NVL(extended_amount,0))
      				    FROM RA_CUSTOMER_TRX_LINES_ALL
      				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
				    AND   line_type='TAX'),0) * NVL((SELECT c.conversion_rate
							FROM GL_DAILY_CONVERSION_TYPES b,
							      GL_DAILY_RATES c,
							      FND_CURRENCIES d
							WHERE b.conversion_type = c.conversion_type
							  AND b.user_conversion_type = 'MOR'
							  AND c.conversion_date = TRUNC(NVL(rct.exchange_date,rct.trx_date)) -- exchange/trx date
							  AND c.from_currency = rct.invoice_currency_code
							  AND c.to_currency = rctt.attribute2
							  AND d.currency_code = c.to_currency),1)),60) inr_special_charge_text,
      SUBSTR(LPAD(ABS(ROUND(NVL((SELECT SUM(NVL(extended_amount,0))
      	FROM RA_CUSTOMER_TRX_LINES_ALL
      	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX'),0),c.precision)  * POWER(10,c.precision)),12,0),1,11) inr_special_charge_amount,
SUBSTR(LPAD(ABS(ROUND(NVL((SELECT SUM(NVL(extended_amount,0))
	      	FROM RA_CUSTOMER_TRX_LINES_ALL
	      	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX'),0),c.precision)  * POWER(10,c.precision)),12,0),12,1) inr_spl_amt_lastchr,
      SIGN(NVL((SELECT SUM(NVL(extended_amount,0))
      	FROM RA_CUSTOMER_TRX_LINES_ALL
      	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX'),0)) inr_spl_charge_amt_sign,
	 a.customer_trx_id,
         a.customer_trx_line_id
FROM RA_CUSTOMER_TRX_LINES_ALL A 
     ,RA_CUSTOMER_TRX_ALL rct
    ,HR_OPERATING_UNITS b 
    , FND_CURRENCIES c
    , RA_CUST_TRX_TYPES_ALL rctt
WHERE 1=1
AND a.line_type = 'LINE'
AND a.org_id=b.organization_id 
AND a.customer_trx_id = rct.customer_trx_id
AND c.currency_code = rct.invoice_currency_code   
AND rctt.CUST_TRX_TYPE_SEQ_ID = rct.cust_trx_type_seq_id
AND rctt.attribute1 = 'Y'
AND UPPER(b.short_code) LIKE '%INR%'
AND (SELECT SUM(NVL(extended_amount,0))
     FROM RA_CUSTOMER_TRX_LINES_ALL
     WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
     AND   line_type='TAX') <> 0