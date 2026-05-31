/*
*************************************************************************************************
-- Name             : Cirrus AR India GST REPORT   
-- Date             : 30/03/19
-- Author           : Karun 
-- Purpose          : Create Receivables Output VAT report to extract all complete invoices, 
                      including tax related attributes, by transaction number for India
-- Type             : Sql
*************************************************************************************************
-- Change history
-- Version         Date          Developer                            Description  
-- REl 35          27-11-2019        Karun 503054500                 Initial Version Created
--REL 098          11-02-2025		Amor  M							 GEINC16885028-CGST and SGST tax rate and amount need to be reflecting in the respective column when we pull the report "Cirrus AR India GST Report Rpt "  
*************************************************************************************************
*/
SELECT DISTINCT dist.segment1 legal_entity_code,
         fun_curr.bu_name business_unit_code,
         rctla.product_type product_type,
         hca.customer_class_code customer_class,
         hp.party_name customer_name,
         hca.account_number customer_account_number,
         zptp.rep_registration_number cust_itx_reg_number,
         hp.country customer_country_code,
         zptp1.rep_registration_number cust_billto_itx_reg_number,
         hl.address1 bill_to_address1,
         hl.address2 bill_to_address2,
        hl.city bill_to_city,
         COALESCE (hl.state, hl.province) bill_to_state_or_province,
         hl.postal_code bill_to_postal_code,
         hl.country bill_to_country,
         ship_ps.party_site_number ship_to_site_number,
         zptp2.rep_registration_number cust_shipto_itx_reg_number,
         ship_loc.address1 ship_to_address1,
         ship_loc.address2 ship_to_address2,
         ship_loc.city ship_to_city,
         COALESCE (ship_loc.state, ship_loc.province) ship_to_state_or_province,
         ship_loc.postal_code ship_to_postal_code,
         ship_loc.country ship_to_country,
         al.meaning doc_type,
         TO_CHAR (rcta.trx_date, 'DD-MM-YYYY') doc_date,
         rcta.trx_number invoice_number,
         TO_CHAR (rcta.trx_date, 'DD-MM-YYYY') invoice_date,
         TO_CHAR (dist.gl_date, 'DD-MM-YYYY') accounting_date,
         rctla.line_number invoice_line_number,
         rctla.description invoice_line_description,
         CASE rcta.trx_class
            WHEN 'CM'
            THEN
               (SELECT trx_number
                  FROM RA_CUSTOMER_TRX_ALL
                 WHERE customer_trx_id = rcta.previous_customer_trx_id)
            WHEN 'ONACC'
            THEN
               (SELECT trx_number
                  FROM RA_CUSTOMER_TRX_ALL
                 WHERE customer_trx_id = rcta.previous_customer_trx_id)
            WHEN 'INV'
            THEN
               NVL (rcta.purchase_order_revision, rcta.purchase_order)
            ELSE
               NULL
         END
            reference_document,
			         CASE rcta.trx_class
            WHEN 'CM'
            THEN
               (SELECT trx_date
                  FROM RA_CUSTOMER_TRX_ALL
                 WHERE customer_trx_id = rcta.previous_customer_trx_id)
            WHEN 'ONACC'
            THEN
               (SELECT trx_date
                  FROM RA_CUSTOMER_TRX_ALL
                 WHERE customer_trx_id = rcta.previous_customer_trx_id)
            WHEN 'INV'
            THEN
               (SELECT trx_date
                  FROM RA_CUSTOMER_TRX_ALL
                 WHERE customer_trx_id = rcta.previous_customer_trx_id)
            ELSE
               NULL
         END
            reference_document_date,
         rcta.invoice_currency_code trx_currency_code,
         TO_CHAR (rctla.extended_amount,
                  FND_CURRENCY.GET_FORMAT_MASK (fun_curr.currency_code, 40))
            trx_line_amount,
         fun_curr.currency_code reporting_currency_code,
         TO_CHAR (NVL (NVL (rcta.exchange_rate, 1) * rctla.extended_amount, 0),
                  FND_CURRENCY.GET_FORMAT_MASK (fun_curr.currency_code, 40))
            rep_line_amount,
         TO_CHAR (
              (NVL (rcta.exchange_rate, 1) * rctla.extended_amount)
            + NVL (NVL (rcta.exchange_rate, 1) * zlv.tax_amt, 0),
            FND_CURRENCY.GET_FORMAT_MASK (fun_curr.currency_code, 40))
            rep_total_amount,
         DECODE (TO_CHAR (dist.gl_date, 'Mon'),
                 '01', 'Jan',
                 '02', 'Feb',
                 '03', 'Mar',
                 '04', 'Apr',
                 '05', 'May',
                 '06', 'Jun',
                 '07', 'Jul',
                 '08', 'Aug',
                 '09', 'Sep',
                 '10', 'Oct',
                 '11', 'Nov',
                 '12', 'Dec')
            gldeclaredreturnmonth,
         TO_CHAR (dist.gl_date, 'YYYY') gldeclaredreturnyear,
                             rcta.exchange_rate
							 ,(SELECT ROUND((SUM(a.extended_amount) * NVL(rcta.exchange_rate,1)),2) FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_RATES_B zb WHERE a.customer_trx_id= rcta.customer_trx_id AND  a.line_type='TAX' AND a.vat_tax_id = zb.tax_rate_id  AND zb.tax_regime_code LIKE '%IGST%') taxamtigst,
(SELECT ROUND((SUM(a.extended_amount) * NVL(rcta.exchange_rate,1)),2) FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_RATES_B zb  WHERE a.customer_trx_id= rcta.customer_trx_id  AND  a.line_type='TAX' AND a.vat_tax_id = zb.tax_rate_id  AND zb.tax_regime_code LIKE '%CGST%') taxamtcgst,
(SELECT ROUND(( SUM(a.extended_amount) * NVL(rcta.exchange_rate,1)) , 2) FROM RA_CUSTOMER_TRX_LINES_ALL a, ZX_RATES_B zb  WHERE a.customer_trx_id= rcta.customer_trx_id AND  a.line_type='TAX' AND a.vat_tax_id = zb.tax_rate_id  AND zb.tax_regime_code LIKE '%SGST%') taxamtsgst,
(SELECT DISTINCT zb.tax_rate_code 
FROM RA_CUSTOMER_TRX_LINES_ALL a,
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added
WHERE a.customer_trx_id= rcta.customer_trx_id 
AND a.tax_line_id = zb.tax_line_id
AND  a.line_type='TAX' 
AND (zb.tax_regime_code LIKE '%IGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'IGST%'))) igst,--REL-098 added 'or'
(SELECT DISTINCT zb.tax_rate_code 
FROM RA_CUSTOMER_TRX_LINES_ALL a,
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added 
WHERE a.customer_trx_id= rcta.customer_trx_id  
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id 
AND (zb.tax_regime_code LIKE '%CGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'CGST%'))) cgst,--REL-098 added 'or'
(SELECT DISTINCT zb.tax_rate_code FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added
WHERE a.customer_trx_id= rcta.customer_trx_id 
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id 
AND (zb.tax_regime_code LIKE '%SGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'SGST%'))) sgst,--REL-098 added 'or'
(SELECT DISTINCT a.tax_rate 
FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added
WHERE a.customer_trx_id= rcta.customer_trx_id 
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id
AND (zb.tax_regime_code LIKE '%IGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'IGST%'))) igst_rate,--REL-098 added 'or'
(SELECT DISTINCT a.tax_rate  FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added  
WHERE a.customer_trx_id= rcta.customer_trx_id  
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id  
AND (zb.tax_regime_code LIKE '%CGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'CGST%')))  cgst_rate,--REL-098 added 'or'
(SELECT DISTINCT a.tax_rate 
FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added
WHERE a.customer_trx_id= rcta.customer_trx_id 
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id    
AND (zb.tax_regime_code LIKE '%SGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'SGST%'))) sgst_rate,--REL-098 added 'or'
(SELECT DISTINCT ROUND((a.extended_amount) * NVL(rcta.exchange_rate,1),2) 
FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added  
WHERE a.customer_trx_id= rcta.customer_trx_id 
AND a.link_to_cust_trx_line_id = rctla.customer_trx_line_id
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id
AND (zb.tax_regime_code LIKE '%IGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'IGST%'))) line_igst,--REL-098 added 'or'
(SELECT DISTINCT ROUND((a.extended_amount) * NVL(rcta.exchange_rate,1),2) 
FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added
WHERE a.customer_trx_id= rcta.customer_trx_id 
AND a.link_to_cust_trx_line_id = rctla.customer_trx_line_id
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id
AND (zb.tax_regime_code LIKE '%CGST%'
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'CGST%'))) line_cgst,--REL-098 added 'or'
(SELECT DISTINCT ROUND((a.extended_amount) * NVL(rcta.exchange_rate,1),2) 
FROM RA_CUSTOMER_TRX_LINES_ALL a, 
--ZX_LINES zb--REL-098 commented
ZX_LINES_V zb --REL-098 added  
WHERE a.customer_trx_id= rcta.customer_trx_id
AND a.link_to_cust_trx_line_id = rctla.customer_trx_line_id 
AND  a.line_type='TAX' 
AND a.tax_line_id = zb.tax_line_id 
AND (zb.tax_regime_code LIKE '%SGST%' 
or (UPPER (tax_regime_name) ='INDIA' and upper(TAX_FULL_NAME) like 'SGST%'))) line_sgst,--REL-098 added 'or'
CASE WHEN EXISTS 
						(SELECT 1 
							FROM EGP_CATEGORIES_b b, FND_LOOKUP_VALUES_VL flv, HR_ORGANIZATION_UNITS hou
							WHERE category_id=rctla.product_fisc_classification
							AND hou.organization_id=rcta.org_id
							AND lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT'
							AND flv.meaning = hou.name||'_SAC_'||b.category_code) 
					THEN (SELECT hl.state||', '||hl.country
							FROM RA_CUSTOMER_TRX_ALL trx
								, RA_CUSTOMER_TRX_LINES_ALL line
								, HZ_PARTY_SITE_USES psu
								, HZ_PARTY_SITES ps
								, HZ_LOCATIONS hl
							WHERE rctla.customer_trx_id				=	trx.customer_trx_id
							AND trx.customer_trx_id				=	line.customer_trx_id
							AND line.customer_trx_line_id		=	rctla.customer_trx_line_id
							AND  trx.ship_to_party_site_use_id 	=	psu.party_site_use_id(+)
							AND  psu.party_site_id 				=	ps.party_site_id(+)
							AND  hl.location_id(+) 				= 	ps.location_id
							) 
					ELSE  
						(SELECT flv.description 
							FROM FND_LOOKUP_VALUES_VL flv
								, HR_ORGANIZATION_UNITS hou
							WHERE lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT'
							AND hou.organization_id=rcta.org_id
							AND meaning = hou.name||'_'||
															(SELECT flv1.description 
																FROM FND_LOOKUP_VALUES_VL flv1 
																	, HR_ORGANIZATION_UNITS hou
																	, RA_CUST_TRX_TYPES_ALL types
																WHERE lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT'
																AND rcta.cust_trx_type_seq_id=types.cust_trx_type_seq_id
																AND hou.organization_id=rcta.org_id
																AND meaning = hou.name||'_'||types.name)
					) END place_of_supply,
					       TO_CHAR (
            NVL (
               (SELECT SUM (extended_amount)
                  FROM RA_CUSTOMER_TRX_LINES_ALL lines
                 WHERE     lines.customer_trx_id = rcta.customer_trx_id
				           AND lines.customer_trx_line_id = rctla.customer_trx_line_id
                       AND lines.line_type = 'LINE'),
               TO_NUMBER (0))
                    + NVL (   
                       (SELECT SUM (extended_amount)
                          FROM RA_CUSTOMER_TRX_LINES_ALL lines
                         WHERE     lines.customer_trx_id = rcta.customer_trx_id
						 AND lines.customer_trx_line_id = rctla.customer_trx_line_id
                               AND lines.line_type = 'FREIGHT'),
                      TO_NUMBER (0))
               + NVL ((SELECT SUM (extended_amount)
                         FROM RA_CUSTOMER_TRX_LINES_ALL lines
                        WHERE lines.customer_trx_id = rcta.customer_trx_id
						AND lines.customer_trx_line_id = rctla.customer_trx_line_id
                          AND lines.line_type = 'CHARGES'),
               TO_NUMBER (0))
          + NVL ( (SELECT SUM (tax_amt)
                     FROM ZX_LINES_V zlv
                    WHERE zlv.trx_id = rcta.customer_trx_id
					AND zlv.TRX_LINE_ID = rctla.customer_trx_line_id
                   AND zlv.APPLICATION_ID = 222),
                 TO_NUMBER (0)),
          FND_CURRENCY.GET_FORMAT_MASK (rcta.invoice_currency_code, 40))total_amount_line,
		 (SELECT category_code 
				FROM EGP_CATEGORIES_b 
				WHERE category_id=rctla.product_fisc_classification) hsn_sac,
(SELECT name 
FROM RA_CUST_TRX_TYPES_ALL a
WHERE rcta.cust_trx_type_seq_id = a.cust_trx_type_seq_id) transaction_type
    FROM RA_CUSTOMER_TRX_ALL rcta,
         RA_CUSTOMER_TRX_LINES_ALL rctla,
         HZ_PARTIES hp,
         HZ_PARTY_SITES hps,
         HZ_CUST_ACCOUNTS hca,
         HZ_CUST_ACCT_SITES_ALL hcasa,
         HZ_CUST_SITE_USES_ALL hcsua,
         HZ_LOCATIONS hl,
         HZ_PARTIES ship_party,
         HZ_PARTY_SITES ship_ps,
         HZ_PARTY_SITE_USES ship_site_use,
         HZ_LOCATIONS ship_loc,
         ZX_LINES_V zlv,
         ZX_WITHHOLDING_LINES zwl,
         ZX_PARTY_TAX_PROFILE zptp,
         ZX_PARTY_TAX_PROFILE zptp1,
         ZX_PARTY_TAX_PROFILE zptp2,
         AR_MEMO_LINES_ALL_B ar_memo,
         AR_MEMO_LINES_ALL_VL ar_memo_tl,
         GL_DAILY_CONVERSION_TYPES gdct,
         AR_LOOKUPS al,
         (SELECT gl.currency_code currency_code,
                 ood.organization_id,
                 ood.name bu_name
            FROM HR_OPERATING_UNITS ood, GL_LEDGERS gl
           WHERE ood.set_of_books_id = gl.ledger_id) fun_curr,
         (SELECT DISTINCT
                 customer_trx_id,
                 customer_trx_line_id,
                 MIN (gl_date) OVER (PARTITION BY customer_trx_id) gl_date,
                 ffvv_nom.description,
                 gcc.segment1,
                 gcc.segment2,
				 recdist.gl_posted_date	
            FROM RA_CUST_TRX_LINE_GL_DIST_ALL recdist,
                 GL_CODE_COMBINATIONS gcc,
                 FND_VS_VALUE_SETS ffvs_nom,
                 FND_VS_VALUES_VL ffvv_nom
           WHERE     gcc.code_combination_id = recdist.code_combination_id
                 AND recdist.account_class = 'REV'
                 AND gcc.segment2 = ffvv_nom.VALUE
                 AND ffvs_nom.value_set_code = 'CCL_ACCOUNTS'
                 AND ffvs_nom.value_set_id = ffvv_nom.value_set_id
                 AND ffvv_nom.attribute_category = 'CCL_ACCOUNTS') dist
   WHERE     1 = 1
         AND hp.party_id = hca.party_id
         AND hp.party_id = hps.party_id
         AND hca.cust_account_id = hcasa.cust_account_id
         AND hps.party_site_id = hcasa.party_site_id
         AND hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
         AND hca.cust_account_id = rcta.bill_to_customer_id
         AND hcsua.site_use_id = rcta.bill_to_site_use_id
         AND rcta.customer_trx_id = rctla.customer_trx_id
         AND rcta.org_id = rctla.org_id
         AND rcta.org_id = fun_curr.organization_id
         AND hps.location_id = hl.location_id(+)
         AND ship_party.party_id = ship_ps.party_id
         AND ship_party.party_id = rcta.ship_to_party_id
         AND ship_ps.party_site_id = ship_site_use.party_site_id
         AND ship_site_use.party_site_use_id = rcta.ship_to_party_site_use_id
         AND ship_ps.location_id = ship_loc.location_id(+)
         AND rctla.line_type = 'LINE'
         AND rctla.customer_trx_line_id = zlv.trx_line_id(+)
         AND rctla.customer_trx_line_id = zwl.trx_line_id(+)
         AND zptp.party_id(+) = hp.party_id
         AND zptp1.party_id(+) = hps.party_site_id
         AND zptp2.party_id(+) = ship_ps.party_site_id
         AND rctla.memo_line_seq_id = ar_memo.memo_line_seq_id(+)
         AND ar_memo.memo_line_id = ar_memo_tl.memo_line_id(+)
         AND dist.customer_trx_id = rcta.customer_trx_id
         AND dist.customer_trx_line_id = rctla.customer_trx_line_id
         AND rcta.exchange_rate_type = gdct.conversion_type(+)
         AND rcta.trx_class = al.lookup_code(+)
         AND al.lookup_type(+) = 'AR_ALL_DOC_CLASSES'
         AND al.enabled_flag(+) = 'Y'
         AND rcta.complete_flag = 'Y'
		 AND dist.gl_posted_date IS NOT NULL	
         AND TRUNC (rcta.trx_date) BETWEEN :p_start_date AND :p_end_date
		 AND fun_curr.bu_name =(:p_bu_name)
		 ORDER BY invoice_number,
	              invoice_line_number