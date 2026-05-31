--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                     Author               Date               Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-ARR				   	TCS(Shubhajit)		 25-Sep-2024	    REL-ARR same as REL-099 as per QA/Audit Compliance
--#																	Change the ADN code for Subscription and Intercompany Adn enablement
--#-----------------------------------------------------------------------------------------------------#
SELECT DISTINCT 'I01' record_key_i01,
       from_buc,
       RPAD(' ',6) not_used,
     -- TO_CHAR(SYSDATE, 'HH24MISS') batch_header_id
       (select substr(dbms_random.value,-6) from dual) batch_header_id
FROM (SELECT DISTINCT nvl(m1.meaning, SUBSTR(a.transaction_type,1,6)) from_BUC
     FROM ( SELECT       a.customer_trx_id,
                a.bill_to_site_use_id,
                (SELECT  DECODE(REGEXP_SUBSTR(hps.party_site_name,'BUC',1,1),'BUC',SUBSTR(hps.party_site_name,1,6),hzca.attribute3) 
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
                nvl(m.tag, c.attribute2) buc_currency_code,
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
                a.attribute9,
				        g.amount_due_original,
				        n.customer_type
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
                RA_CUST_TRX_LINE_GL_DIST_ALL rctlg,
			    xla_ae_headers xah,
				FND_LOOKUP_VALUES M, 
				HZ_CUST_ACCOUNTS N   
              WHERE b.batch_source_seq_id = a.batch_source_seq_id
			          AND M.lookup_type(+) ='GED IBS EXTRACT LOOKUP'
                AND f.name = m.lookup_code(+)
				        AND m.ENABLED_FLAG(+)='Y' 				      
				        AND n.cust_account_id =a.bill_to_customer_id 
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
               -- AND rctlg.gl_posted_date IS NOT NULL
                AND rctlg.account_class = 'REC'
                AND rctlg.customer_trx_id = a.customer_trx_id
				        AND rctlg.event_id = xah.event_id
				        AND xah.gl_transfer_date IS NOT NULL
                AND f.name = NVL(:P_BUSINESS_UNIT, f.name) 
                AND ((:P_INVOICE_NUM IS NOT NULL AND a.trx_number IN (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, level)
                                                          FROM DUAL
                                                    CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, level) IS NOT NULL)) OR 
                  ((:P_FROM_DATE IS NOT NULL AND :P_TO_DATE IS NOT NULL) AND (TRUNC(xah.gl_transfer_date) BETWEEN :P_FROM_DATE AND :P_TO_DATE)) OR
                  (:P_INVOICE_NUM  IS NULL AND :P_FROM_DATE IS NULL  AND :P_TO_DATE IS NULL AND (
                 xah.gl_transfer_date  >   (SELECT MAX(ERH.processstart)
                                       FROM ess_request_history ERH
                                           ,ess_request_property ERP1
                                       WHERE ERH.requestid = ERP1.requestid
                                       AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_IBS_INVOICE_EXTRACT'
                                       AND ERH.executable_status = 'SUCCEEDED'
                                       AND ERP1.name = 'submit.argument1'
                             	       AND ERP1.value IS NULL 
									   AND ERH.processstart < (SELECT MAX(ERH.processstart)
                                       FROM ess_request_history ERH
                                           ,ess_request_property ERP1
                                       WHERE ERH.requestid = ERP1.requestid
                                       AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_IBS_INVOICE_EXTRACT'
                                       AND ERH.executable_status = 'SUCCEEDED'
                                       AND ERP1.name = 'submit.argument1'
                             	       AND ERP1.value IS NULL)))))
                ) a,
                RA_CUST_TRX_LINE_GL_DIST_ALL b,
                GL_CODE_COMBINATIONS c,
                FND_CURRENCIES d 
				,FND_LOOKUP_VALUES M1
    WHERE 1=1
	AND M1.lookup_type(+)     ='GED IBS EXTRACT LOOKUP'
                AND a.operating_unit             = m1.lookup_code(+)
                --AND m1.language        ='US'
                AND m1.ENABLED_FLAG(+)    ='Y'
    AND a.complete_flag = 'Y' -- Pick only completed transactions
    AND a.attribute4 IS NULL -- Records are extracted are marked with SYSDATE in this attribute4
    AND a.to_buc IS NOT NULL
    AND a.source NOT LIKE '%CONV%' 
    AND b.customer_trx_id = a.customer_trx_id
    AND b.account_class = 'REC'
    AND c.code_combination_id = b.code_combination_id
    AND d.currency_code = a.invoice_currency_code
	AND a.amount_due_original <> 0 
	AND decode(a.operating_unit,'CA_CAD_BU',a.operating_unit, a.customer_type) = decode(a.operating_unit,'CA_CAD_BU', a.operating_unit, 'I') 
   -- AND (a.purchase_order IS NOT NULL OR NOT EXISTS(SELECT '1' FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = a.customer_trx_id AND ral.attribute7 IS NULL AND ral.line_type = 'LINE'))
	AND ((a.operating_unit='CA_CAD_BU') OR ((A.OPERATING_UNIT!= 'CA_CAD_BU') AND (a.purchase_order IS NOT NULL OR (trim(  RPAD( DECODE(a.source,'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                            from  OKC_K_HEADERS_ALL_B C,
												      PJB_CNTRCT_PROJ_LINKS A1 , 
													  PJF_PROJECTS_ALL_B B,
													  ra_customer_trx_all rct
                                                where A1.project_id= b.Project_id
									                  and A1.contract_id= C.id
													  and c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													  and c.attribute8 is not null
													  and rownum<2
													  and a.customer_trx_id=rct.customer_trx_id
												  and rct.interface_header_attribute1=c.contract_number),
												  'Distributed Order Orchestration',
												  (SELECT dlfeb.attribute_char2
													  FROM doo_headers_all a1,
														   doo_lines_all b,
														   ra_customer_trx_lines_all rctla,
														   doo_fulfill_lines_all c,
														   DOO_FULFILL_LINES_EFF_B dlfeb
														   WHERE a1.header_id=b.header_id
													   AND b.line_id=c.line_id
													   AND c.fulfill_line_id=dlfeb.fulfill_line_id
													 --  AND rctla.INTERFACE_LINE_ATTRIBUTE3= a.ORDER_NUMBER
													   AND a1.status_code not like 'DOO_REFERENCE'
														AND TO_CHAR (c.fulfill_line_id) =RCTLA.INTERFACE_LINE_ATTRIBUTE5
													   AND rownum<2
													   and a.customer_trx_id=rctla.customer_trx_id
													  -- AND dlfeb.CONTEXT_CODE='GED Fline Context'
													  -- AND RCTLA.INTERFACE_LINE_ATTRIBUTE1 = a.SOURCE_ORDER_NUMBER
													   --AND RCTLA.INTERFACE_LINE_ATTRIBUTE2 =a.SOURCE_ORDER_SYSTEM
													   AND dlfeb.attribute_char2 IS NOT NULL), 
												   NVL((SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = a.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')
												   ,case when (a.source = 'Oracle DOO Integrated Subscriptions'					--REL-ARR Added for Subscription enablement - Start
														and exists (SELECT 1 FROM HR_OPERATING_UNITS hou, FND_LOOKUP_VALUES_VL flv, RA_CUSTOMER_TRX_LINES_ALL rctla
																	WHERE rctla.customer_trx_id = a.customer_trx_id
																	AND hou.organization_id = rctla.org_id 
																	AND rctla.line_type = 'LINE'
																	AND flv.meaning = hou.name
																	AND flv.lookup_type = 'GED_BU_NAMES'
																	AND flv.description = 'DIG' --in ('DIG','DIGAVN')
																	AND flv.enabled_flag = 'Y'
																	AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))))
													then (SELECT distinct dfleb.ATTRIBUTE_CHAR2
															FROM  doo_fulfill_lines_eff_b dfleb,
																  doo_fulfill_lines_all dfla,
																  ra_customer_trx_lines_all rctla,
																  HR_OPERATING_UNITS hou, 
																	FND_LOOKUP_VALUES_VL flv
															WHERE a.customer_trx_id           = rctla.customer_trx_id
															AND dfla.fulfill_line_id =rctla.INTERFACE_LINE_ATTRIBUTE5
															AND dfla.fulfill_line_id = dfleb.fulfill_line_id(+)
															AND dfleb.context_code(+) = 'GED Fline Context'
															AND hou.organization_id = rctla.org_id 
															AND flv.meaning = hou.name
															AND flv.lookup_type = 'GED_BU_NAMES'
															AND flv.description = 'DIG' --in ('DIG','DIGAVN')
															AND flv.enabled_flag = 'Y'
															AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))
															AND ROWNUM                <2
															AND rctla.line_type         = 'LINE')						--REL-ARR Added for subscription enablement - End
													when (a.source = 'GEV ES Intercompany'							--REL-ARR Added for Intercompany enablement - Start
														and exists (SELECT 1 FROM HR_OPERATING_UNITS hou, FND_LOOKUP_VALUES_VL flv, RA_CUSTOMER_TRX_LINES_ALL rctla
																	WHERE rctla.customer_trx_id = a.customer_trx_id
																	AND hou.organization_id = rctla.org_id 
																	AND rctla.line_type = 'LINE'
																	AND flv.meaning = hou.name
																	AND flv.lookup_type = 'GED_BU_NAMES'
																	AND flv.description = 'DIG'
																	AND flv.enabled_flag = 'Y'
																	AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))))
													then (SELECT distinct dfleb2.ATTRIBUTE_CHAR5
															FROM  ra_customer_trx_all rcta_parent,
																  ra_customer_trx_lines_all rctla_parent,
																  ra_customer_trx_lines_all rctla,
																  ra_batch_sources_all rbs,
																  doo_fulfill_lines_eff_b dfleb2,
																  doo_fulfill_lines_all dfla,
																  HR_OPERATING_UNITS hou, 
																	FND_LOOKUP_VALUES_VL flv
															WHERE a.customer_trx_id           = rctla.customer_trx_id  
															AND rctla.INTERFACE_LINE_CONTEXT ='CCLAR'  
															AND rctla.ATTRIBUTE_CATEGORY = 'CCLAR'
															AND rctla.INTERFACE_LINE_ATTRIBUTE2 = rcta_parent.TRX_NUMBER
															AND rctla.INTERFACE_LINE_ATTRIBUTE3 =rctla_parent.line_number
															AND rcta_parent.customer_trx_id = rctla_parent.customer_trx_id
															AND rctla_parent.INTERFACE_LINE_ATTRIBUTE5 = dfla.fulfill_line_id
															AND dfla.fulfill_line_id = dfleb2.fulfill_line_id(+)
															AND dfleb2.context_code(+) = 'GED FLine Context 2'
															AND dfleb2.ATTRIBUTE_CHAR5 IS NOT NULL
															AND hou.organization_id = rctla.org_id 
															AND flv.meaning = hou.name
															AND flv.lookup_type = 'GED_BU_NAMES'
															AND flv.description = 'DIG'
															AND flv.enabled_flag = 'Y'
															AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))
															AND ROWNUM                <2
															AND rctla.line_type         = 'LINE') end )),75))					--REL-ARR Added for Intercompany enablement - End
) is not null))) --R04 
	)
ORDER BY from_buc