SELECT 'I30' record_key_i30,
      RPAD(' ',32) supplier_product_code,
      RPAD(' ',10) quantity_ordered,
      LPAD(NVL(a.quantity_invoiced,a.quantity_credited),10,0) quantity_invoiced,
      LPAD(ABS(ROUND(a.unit_selling_price,4) * 10000),15,0) unit_price,
      SIGN(a.unit_selling_price) unit_price_sign,
      SUBSTR(LPAD(ABS(ROUND(a.unit_selling_price,4) * 10000),15,0),15,1) unit_price_last_char,
      'I31' record_key_i31,
      RPAD(a.line_number,5) po_line_item,
      RPAD(' ',2) unit_of_measure,
      RPAD(' ',11) not_used_1,
	SUBSTR(LPAD(ABS(ROUND((NVL(a.extended_amount,0) + (SELECT SUM(NVL(extended_amount,0))
							   FROM RA_CUSTOMER_TRX_LINES_ALL
							   WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
							   AND   line_type='TAX')),c.precision) * POWER(10,c.precision)),10,0),1,9) extended_amount, -- REL-049
        SUBSTR(LPAD(ABS(ROUND((NVL(a.extended_amount,0) + (SELECT SUM(NVL(extended_amount,0))
							   FROM RA_CUSTOMER_TRX_LINES_ALL
							   WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
							   AND   line_type='TAX')),c.precision) * POWER(10,c.precision)),10,0),10,1) 	extended_amount_last_char,						   
	SIGN(NVL(a.extended_amount,0) + (SELECT SUM(NVL(extended_amount,0))
					 FROM RA_CUSTOMER_TRX_LINES_ALL
					 WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
					 AND   line_type='TAX')) extended_amount_sign,-- REL-049
      RPAD(' ',11) not_used_2,
      RPAD(' ',1) price_per,
	SUBSTR(LPAD(ABS(ROUND(NVL(a.extended_amount,0),c.precision) * POWER(10,c.precision)),15,0),1,14) line_item_amount, -- REL-036
	SUBSTR(LPAD(ABS(ROUND(NVL(a.extended_amount,0),c.precision) * POWER(10,c.precision)),15,0),15,1) line_item_amt_last_char,
					  ABS(ROUND(NVL(a.extended_amount,1),c.precision)) line_amount, -- REL-049
      SIGN(NVL(a.extended_amount,0)) line_item_amount_sign, -- REL-025
      RPAD(' ',10) unspsc_code,
      'I32' record_key_i32,
      RPAD(UPPER(SUBSTR(NVL(a.description,' '),1,40)),40) line_item_description,
      'I34' record_key_i34,
      'I36' record_key_i36,
      a.tax_classification_code ,
    (SELECT tax_rate
      FROM RA_CUSTOMER_TRX_LINES_ALL
      WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX'
        AND ROWNUM =1) tax_rate,
	(SELECT SUM(NVL(extended_amount,0))
	FROM RA_CUSTOMER_TRX_LINES_ALL
	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX') ext_amount,
      a.customer_trx_id,
      a.customer_trx_line_id,
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
       (NVL((SELECT SUM(NVL(extended_amount,0))
				    FROM RA_CUSTOMER_TRX_LINES_ALL
				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
				    AND   line_type='TAX'),0) * NVL(rct.exchange_rate,1)),60) inr_special_charge_text,
      LPAD(ABS(ROUND(NVL((SELECT SUM(NVL(extended_amount,0))
	FROM RA_CUSTOMER_TRX_LINES_ALL
	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX'),0),c.precision)  * POWER(10,c.precision)),12,0) inr_special_charge_amount,
      SIGN(NVL((SELECT SUM(NVL(extended_amount,0))
	FROM RA_CUSTOMER_TRX_LINES_ALL
	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	AND   line_type='TAX'),0)) inr_spl_charge_amt_sign
FROM RA_CUSTOMER_TRX_LINES_ALL A--REL-049,
     ,RA_CUSTOMER_TRX_ALL rct
    ,HR_OPERATING_UNITS b 
    , FND_CURRENCIES c
WHERE 1=1
AND a.line_type = 'LINE'
AND a.org_id=b.organization_id 
AND a.customer_trx_id = rct.customer_trx_id
AND c.currency_code = rct.invoice_currency_code