SELECT DISTINCT 'I01' record_key_i01,
       from_buc,
       RPAD(' ',6) not_used,
     -- TO_CHAR(SYSDATE, 'HH24MISS') batch_header_id
       (select substr(dbms_random.value,-6) from dual) batch_header_id
FROM (SELECT DISTINCT SUBSTR(a.transaction_type,1,6) from_BUC
     FROM ( SELECT       a.customer_trx_id,
                a.bill_to_site_use_id,
                (SELECT  SUBSTR(hps.party_site_name,1,6) 
					FROM 	hz_cust_acct_sites_all hzca,
				        	hz_party_sites hps,
				        	hz_cust_site_uses_all hcs
					WHERE 1=1
					AND hzca.party_site_id = hps.party_site_id
					AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
					AND hcs.site_use_code = 'BILL_TO'
			AND hcs.site_use_id = a.bill_to_site_use_id) to_buc,
                a.ship_to_site_use_id,
                a.trx_number,
                a.CREATION_DATE,
                 a.LAST_UPDATE_DATE,
                b.name source,
                c.name transaction_type,
                c.attribute2 buc_currency_code,
                f.name operating_unit,
                f.organization_id,
                a.trx_date,
                a.purchase_order,
                a.invoice_currency_code,
                a.complete_flag,
                i.currency_code functional_currency_code,
                k.precision functional_currency_precision,
                a.exchange_date,
                a.exchange_rate,
                a.attribute_category,
                a.attribute1,
                a.attribute2,
                a.attribute3,
                a.attribute4,
                a.attribute9
            FROM RA_CUSTOMER_TRX_ALL a,
                RA_BATCH_SOURCES_ALL b,
                RA_CUST_TRX_TYPES_ALL c,
                XLE_ENTITY_PROFILES d,
                RA_TERMS_TL e,
                HR_ALL_ORGANIZATION_UNITS f,
                AR_PAYMENT_SCHEDULES_ALL g,
                HR_ORGANIZATION_INFORMATION h,
                GL_LEDGERS i,
                GL_DAILY_CONVERSION_TYPES j,
                FND_CURRENCIES k,
-- Changed to extract only Accounted Invoices. 28 Jan 16
                RA_CUST_TRX_LINE_GL_DIST_ALL rctlg,
			    xla_ae_headers xah
            WHERE b.batch_source_seq_id = a.batch_source_seq_id
                AND c.CUST_TRX_TYPE_SEQ_ID = a.cust_trx_type_seq_id
                AND c.attribute1 = 'Y'
                AND d.legal_entity_id = a.legal_entity_id
                AND e.term_id(+) = a.term_id
                AND e.language(+) = 'US'
                AND f.organization_id = a.org_id
                AND g.customer_trx_id(+) = a.customer_trx_id
                AND h.org_information_context = 'FUN_BUSINESS_UNIT'
                AND h.organization_id = a.org_id                          -- OU join
                AND TO_NUMBER (h.org_information3) = i.ledger_id     
                AND j.conversion_type(+) = a.exchange_rate_type
                AND i.currency_code = k.currency_code
-- Changed to extract only Accounted Invoices and use Gl Transfer Date of RA_CUST_TRX_LINE_GL_DIST_ALL
-- to compare with last run date. 28 Jan 16
               -- AND rctlg.gl_posted_date IS NOT NULL
                AND rctlg.account_class = 'REC'
                AND rctlg.customer_trx_id = a.customer_trx_id
				AND rctlg.event_id = xah.event_id
				AND xah.gl_transfer_date IS NOT NULL
                AND ((:P_INVOICE_NUM IS NOT NULL AND a.trx_number IN (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, level)
                                                          FROM DUAL
                                                    CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, level) IS NOT NULL)) OR 
                  (:P_INVOICE_NUM  IS NULL AND  (
--rctlg.CREATION_DATE > NVL((SELECT MAX(ERH.processstart)
--                                       FROM ess_request_history ERH
--                                           ,ess_request_property ERP1
--                                       WHERE ERH.requestid = ERP1.requestid
--                                       AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_IBS_INVOICE_EXTRACT'
--                                       AND ERH.executable_status = 'SUCCEEDED'
--                                       AND ERP1.name = 'submit.argument1'
--                             	       AND ERP1.value IS NULL),rctlg.CREATION_DATE-1) OR
                 xah.gl_transfer_date  >   (SELECT MAX(ERH.processstart)
                                       FROM ess_request_history ERH
                                           ,ess_request_property ERP1
                                       WHERE ERH.requestid = ERP1.requestid
                                       AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_IBS_INVOICE_EXTRACT'
                                       AND ERH.executable_status = 'SUCCEEDED'
                                       AND ERP1.name = 'submit.argument1'
                             	       AND ERP1.value IS NULL)  )))
                ) a,
                RA_CUST_TRX_LINE_GL_DIST_ALL b,
                GL_CODE_COMBINATIONS c,
                FND_CURRENCIES d 
    WHERE 1=1
    AND a.complete_flag = 'Y' -- Pick only completed transactions
    AND a.attribute4 IS NULL -- Records are extracted are marked with SYSDATE in this attribute4
    AND a.to_buc IS NOT NULL
    AND a.source NOT LIKE '%CONV%' -- REL-033	
    AND b.customer_trx_id = a.customer_trx_id
    AND b.account_class = 'REC'
    AND c.code_combination_id = b.code_combination_id
    AND d.currency_code = a.invoice_currency_code
    AND (a.purchase_order IS NOT NULL OR NOT EXISTS(SELECT '1' FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = a.customer_trx_id AND ral.attribute7 IS NULL AND ral.line_type = 'LINE')))
UNION
SELECT DISTINCT 'I02' record_key_i01,
       'bursting_dummy',
       RPAD(' ',6) not_used,
      TO_CHAR(SYSDATE, 'HH24MISS') batch_header_id
FROM DUAL
ORDER BY from_buc