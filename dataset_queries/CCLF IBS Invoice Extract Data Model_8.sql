SELECT DISTINCT 
'I34' RECORD_KEY_I34,
'I36' RECORD_KEY_I36,
rctl.customer_trx_id,
rctl.customer_trx_line_id,
RPAD(' ',3) spl_tax_type_code,
flv.description special_charge_code,
decode(flv.description,'EXV',RPAD(flv.tag,' ',60),
	RPAD(RPAD(NVL(flv.tag,' '),3) || RPAD(' ',3)||
            (LPAD(DECODE(((rctl_tax.tax_rate)),NULL,' ',TRIM(TO_CHAR(((rctl_tax.tax_rate)),'99.99')||'%')),6 ) )||RPAD(' ',7)||
			      (SELECT NVL(UPPER(ISSUING_TERRITORY_CODE),'  ')
           			FROM FND_CURRENCIES
          			WHERE currency_code = rctt.attribute2)||(NVL((SELECT SUM(NVL(extended_amount,0))
								FROM RA_CUSTOMER_TRX_LINES_ALL
								WHERE customer_trx_line_id=rctl_tax.customer_trx_line_id
								AND   line_type='TAX'),0) * NVL((SELECT c.conversion_rate
							FROM GL_DAILY_CONVERSION_TYPES b,
							      GL_DAILY_RATES c,
							      FND_CURRENCIES d
							WHERE b.conversion_type = c.conversion_type
							  AND b.user_conversion_type = 'MOR'
							  AND c.conversion_date = TRUNC(NVL(rct.exchange_date,rct.trx_date)) -- exchange/trx date
							  AND c.from_currency = rct.invoice_currency_code
							  AND c.to_currency = rctt.attribute2
							  AND d.currency_code = c.to_currency),1)),60)) special_charge_text,
SUBSTR(DECODE(flv.description,'EXV','000000000000', LPAD(ABS(ROUND(NVL((SELECT SUM(NVL(extended_amount,0))
									FROM RA_CUSTOMER_TRX_LINES_ALL
									WHERE customer_trx_line_id=rctl_tax.customer_trx_line_id
									AND   line_type='TAX'),0),fc.precision)  * POWER(10,fc.precision)),12,0)),1,11) special_charge_amount,
SUBSTR(DECODE(flv.description,'EXV','0', LPAD(ABS(ROUND(NVL((SELECT SUM(NVL(extended_amount,0))
									FROM RA_CUSTOMER_TRX_LINES_ALL
									WHERE customer_trx_line_id=rctl_tax.customer_trx_line_id
									AND   line_type='TAX'),0),fc.precision)  * POWER(10,fc.precision)),12,0)),12,1) spl_amt_lastchr,
DECODE(flv.description,'EXV',0,SIGN(NVL((SELECT SUM(NVL(extended_amount,0))
						FROM RA_CUSTOMER_TRX_LINES_ALL
						WHERE customer_trx_line_id=rctl_tax.customer_trx_line_id
						AND   line_type='TAX'),0))) spl_charge_amt_sign
from RA_CUSTOMER_TRX_LINES_ALL rctl,
RA_CUSTOMER_TRX_LINES_ALL rctl_tax,
     RA_CUSTOMER_TRX_ALL rct,
     FND_CURRENCIES fc,
     RA_CUST_TRX_TYPES_ALL rctt,
     zx_lines zl,
     fnd_lookup_values flv
WHERE rctl.customer_trx_id = rct.customer_trx_id
AND fc.currency_code = rct.invoice_currency_code     
AND rctt.CUST_TRX_TYPE_SEQ_ID = rct.cust_trx_type_seq_id
AND rctt.attribute1 = 'Y'
AND zl.Tax_line_id =rctl_tax.tax_line_id
AND flv.lookup_type = 'CCLF_GECANADA_ZX_RATE_MAPPING'
AND flv.language = 'US'
AND flv.lookup_code = zl.tax_rate_code
AND rctl_tax.link_to_cust_trx_line_id=rctl.customer_trx_line_id
AND rctl_tax.line_type='TAX'