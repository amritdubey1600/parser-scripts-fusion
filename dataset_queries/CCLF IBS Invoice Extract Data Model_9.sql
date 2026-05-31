SELECT 'I37' RECORD_KEY_I37,
	RPAD(NVL(UPPER(attribute7),' '),75) adn,
	customer_trx_id,
        customer_Trx_line_id
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE 1=1
AND line_type = 'LINE'
AND 1 <> (SELECT count(1) 
FROM (SELECT a.customer_trx_line_id,
    a.customer_trx_id
     FROM (SELECT a.customer_trx_line_id,
                  a.customer_trx_id,
                  a.line_number,
                  a.line_type
            FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_LINES_DET_FACTORS b
            WHERE     a.customer_trx_id = b.trx_id(+)
            AND a.customer_trx_line_id = b.trx_line_id(+)) a,
          (SELECT d1.vat_tax_id,
                  d1.tax_rate,
                  d1.extended_amount,
                  d1.customer_trx_line_id,
                  d1.link_to_cust_trx_line_id,
                  a1.tax_rate_id,
                  a1.tax_rate_code,
                  b1.tax_rate_name,
                  c1.tax_regime_code,
                  NVL (c1.attribute1, 1) tax_regime_order
             FROM ZX_RATES_B a1,
                  ZX_RATES_TL b1,
                  ZX_REGIMES_B c1,
                  (SELECT a.customer_trx_line_id,
                          a.customer_trx_id,
                          a.line_number,
                          a.line_type,
                          a.vat_tax_id,
                          a.link_to_cust_trx_line_id,
                          a.tax_rate,
                          a.extended_amount
                    FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_LINES_DET_FACTORS b
                    WHERE     a.customer_trx_id = b.trx_id(+)
                    AND a.customer_trx_line_id = b.trx_line_id(+)) d1
            WHERE     a1.tax_regime_code = c1.tax_regime_code
                  AND d1.line_type = 'TAX'
                  AND NVL (c1.attribute1, 1) = 1
                  AND a1.tax_rate_id = d1.vat_tax_id
                  AND a1.tax_rate_id = b1.tax_rate_id
                  AND b1.LANGUAGE = USERENV ('LANG')) b,
          (SELECT d1.vat_tax_id,
                  d1.tax_rate,
                  d1.extended_amount,
                  d1.customer_trx_line_id,
                  d1.link_to_cust_trx_line_id,
                  a1.tax_rate_id,
                  a1.tax_rate_code,
                  b1.tax_rate_name,
                  c1.tax_regime_code,
                  NVL (c1.attribute1, 1) tax_regime_order
             FROM ZX_RATES_B a1,
                  ZX_RATES_TL b1,
                  ZX_REGIMES_B c1,
                  (SELECT a.customer_trx_line_id,
			  a.customer_trx_id,
			  a.line_number,
			  a.line_type,
			  a.vat_tax_id,
			  a.link_to_cust_trx_line_id,
			  a.tax_rate,
			  a.extended_amount
		    FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_LINES_DET_FACTORS b
		    WHERE     a.customer_trx_id = b.trx_id(+)
                    AND a.customer_trx_line_id = b.trx_line_id(+)) d1
            WHERE     a1.tax_regime_code = c1.tax_regime_code
                  AND d1.line_type = 'TAX'
                  AND NVL (c1.attribute1, 1) = 2
                  AND a1.tax_rate_id = d1.vat_tax_id
                  AND a1.tax_rate_id = b1.tax_rate_id
                  AND b1.LANGUAGE = USERENV ('LANG')) c,
          (SELECT d1.vat_tax_id,
                  d1.tax_rate,
                  d1.extended_amount,
                  d1.customer_trx_line_id,
                  d1.link_to_cust_trx_line_id,
                  a1.tax_rate_id,
                  a1.tax_rate_code,
                  b1.tax_rate_name,
                  c1.tax_regime_code,
                  NVL (c1.attribute1, 1) tax_regime_order
             FROM ZX_RATES_B a1,
                  ZX_RATES_TL b1,
                  ZX_REGIMES_B c1,
                  (SELECT a.customer_trx_line_id,
			  a.customer_trx_id,
			  a.line_number,
			  a.line_type,
			  a.vat_tax_id,
			  a.link_to_cust_trx_line_id,
			  a.tax_rate,
			  a.extended_amount
		    FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_LINES_DET_FACTORS b
		    WHERE     a.customer_trx_id = b.trx_id(+)
                    AND a.customer_trx_line_id = b.trx_line_id(+)) d1
            WHERE     a1.tax_regime_code = c1.tax_regime_code
                  AND d1.line_type = 'TAX'
                  AND NVL (c1.attribute1, 1) = 3
                  AND a1.tax_rate_id = d1.vat_tax_id
                  AND a1.tax_rate_id = b1.tax_rate_id
                  AND b1.LANGUAGE = USERENV ('LANG')) d
    WHERE     a.line_type = 'LINE'
          AND a.customer_trx_line_id = b.link_to_cust_trx_line_id(+)
          AND a.customer_trx_line_id = c.link_to_cust_trx_line_id(+)

          AND a.customer_trx_line_id = d.link_to_cust_trx_line_id(+)
          ) b
                WHERE b.customer_trx_id = rctla.customer_trx_id
                )