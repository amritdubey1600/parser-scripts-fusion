/*
**********************************************************************************
-- Name             : GED AR RevPro Interface     
-- Date               : 08/18/17                  
-- Author           : Himanshu Singh              
-- Purpose         : Revenue Recognition          
-- Type               : Sql                       
**********************************************************************************
-- Change history                                 
-- Version         Date          Developer         Description  
-- 2.0           08/30/17		Nitin Bhatt		   RevPro Interface ReWrite
-- 2.1           01/17/18       Nitin Bhatt        GEFCERPRR-50-VSOE flag should print as "False" REL-013
-- 2.1           01/24/18       Nitin Bhatt        GEFCERPRR-52-97_2 and ELIGIBLE_FOR_CV should print as "N" REL-013
-- 2.2           02/26/19       Nitin Bhatt        GEFCERPRR-I-59 Rule start and End date should be blank in case of Manual REL-027
												   GEFCERPRR-I-62 Trading Partner changes REL-027
-- 2.3			 04/27/19		Nitin Bhatt		   GEFCERPRR-I-69 Rebill Invoice REL-027
-- 2.4			 07/10/19		Nitin Bhatt		   Performance Tuning in rec_details subquery factor REL-030
--   			 07/10/19		Nitin Bhatt		   New Invoice Source "Nurego" added to Manual block REL-030
--  			 07/10/19		S. Thakur		   Removed GEFCERPRR-I-69 Rebill Invoice from REL-027 REL-030
												   Added RULE_START_DATE and RULE_END_DATE for Invoice Source "Nurego" REL-030
												   To Date and From Date to Cover Between Sysdate-1 and Sysdate	REL-030
--  			 07/10/19		Nitin Bhatt		   Added Period set name as "CCL CALENDAR" REL-030
-- 2.5			 08/07/19		Nitin Bhatt		   GEFCERPRR-I-70 Contract order number and line number will print from contract line REL-031
-- 2.6			 02/21/20	    H. Singh		   Removed Hardcoded Cost center as part of Vertical Reporting Project
-- 2.7           13/10/20		Sowndarya		   Added logic for exclusion of GRID BUs REL-045	
**********************************************************************************
*/
--
WITH ar_posted_to_gl AS (SELECT /*+ MATERIALIZE */ xte.source_id_int_1,
                                                   xah.ledger_id,
                                                   xdl.source_distribution_id_num_1,
                                                   xal.code_combination_id def_acctg_ccid,
                                                   gcc.segment1,
                                                   gcc.segment2,
                                                   gcc.segment3,
                                                   gcc.segment4,
                                                   gcc.segment5,
                                                   gcc.segment6,
                                                   gcc.segment7,
                                                   gcc.segment8,
                                                   gcc.segment9,
                                                   gcc.segment10,
                                                   gcc.segment11,
												   gll.currency_code
                           FROM xla_ae_headers           xah,
                                xla_transaction_entities xte,
                                xla_ae_lines xal,
                                xla_distribution_links xdl,
                                gl_code_combinations gcc,
								gl_ledgers gll
                          WHERE xah.application_id               = 222
                            AND xah.accounting_entry_status_code = 'F'
                            AND xah.gl_transfer_status_code      = 'Y'
                            AND xah.entity_id                    = xte.entity_id
                            AND xte.application_id               = 222
                            AND xte.entity_code                  = 'TRANSACTIONS'                           
                            AND xte.transaction_number           = NVL(:p_trx_num, xte.transaction_number)  
                            AND xah.ledger_id                    = xte.ledger_id
                            AND xah.ae_header_id                 = xal.ae_header_id
                            AND xdl.ae_header_id                 = xal.ae_header_id
                            AND xdl.ae_line_num                  = xal.ae_line_num
                            AND xal.application_id               = 222
                            AND xdl.application_id               = 222
                            --AND xal.accounting_class_code        IN ('REVENUE')
							AND xal.accounting_class_code        = 'REVENUE'
                            AND xal.code_combination_id          = gcc.code_combination_id
							--AND gcc.segment2					LIKE '2%'
							--omp aug10 AND SUBSTR(gcc.segment2,1,1)		 = '2'
							AND gcc.segment2		 = '2290713000'
							AND gll.ledger_id					 = xte.ledger_id
							AND xah.period_name IN (CASE 
														WHEN (:p_trx_num IS NOT NULL OR :p_order_number IS NOT NULL OR :p_contract_number IS NOT NULL) THEN xah.period_name
													ELSE
														(SELECT period_name
														FROM   gl_periods
														WHERE  (TO_DATE(NVL(:p_start_date, TO_CHAR(SYSDATE - 1,'YYYY-MM-DD')),'YYYY-MM-DD') BETWEEN trunc(start_date) AND trunc(end_date)	--REL-030
																OR TO_DATE(NVL(:p_end_date, TO_CHAR(SYSDATE,'YYYY-MM-DD')),'YYYY-MM-DD') BETWEEN trunc(start_date) AND trunc(end_date))		--REL-030
														AND    adjustment_period_flag = 'N'
														AND period_set_name = 'CCL CALENDAR' --REL-030
														GROUP BY period_name)
													END)
                            --AND trunc(xah.last_update_date) BETWEEN NVL2(:p_trx_num, TRUNC(xah.last_update_date), TO_DATE(NVL(:p_start_date,TO_CHAR(SYSDATE - 1,'YYYY-MM-DD')),'YYYY-MM-DD')) and nvl2(:p_trx_num, TRUNC(xah.last_update_date), TO_DATE(NVL(:p_end_date, TO_CHAR(SYSDATE - 1,'YYYY-MM-DD')),'YYYY-MM-DD'))
                            GROUP BY xte.source_id_int_1, xah.ledger_id, xdl.source_distribution_id_num_1, xal.code_combination_id,
                            gcc.segment1, gcc.segment2, gcc.segment3, gcc.segment4, gcc.segment5, gcc.segment6, gcc.segment7, 
                            gcc.segment8, gcc.segment9, gcc.segment10, gcc.segment11, gll.currency_code
                         ),
--REL-027 Start
rec_tp AS (
						SELECT /*+ MATERIALIZE */
							segment3,
							source_id_int_1
						FROM
						(
						SELECT
							 DENSE_RANK() OVER (PARTITION BY xte.source_id_int_1 ORDER BY xal.ae_line_num) RANKED, --some unusual invoices have more than 1 REC line accounted. will pick first line as suggested by Tiffany
							 gcc.segment3, --Trading Partner
							 xte.source_id_int_1								
						  FROM xla_transaction_entities xte,
								xla_ae_headers xah,
								xla_ae_lines xal,
								gl_code_combinations gcc
						 WHERE	xte.application_id = 222
							AND xte.entity_code    = 'TRANSACTIONS'
                            AND xte.transaction_number           = NVL(:p_trx_num, xte.transaction_number)  
							AND xah.ledger_id      = xte.ledger_id
							AND xah.entity_id      = xte.entity_id
							AND xah.application_id = 222
                            AND xah.accounting_entry_status_code = 'F'
                            AND xah.gl_transfer_status_code      = 'Y'
                            AND xah.ae_header_id                 = xal.ae_header_id						
							AND xal.accounting_class_code		 = 'RECEIVABLE'
							AND xal.code_combination_id = gcc.code_combination_id
							AND gcc.segment3 <> '0000' --- for Internal customer TP should be there. Check for TP otherwise take 0000
						)
						WHERE RANKED = 1
),	--REL-027 End
rec_details AS (SELECT /*+ MATERIALIZE */ rcta.trx_number ar_inv_number,
                       rcta.invoice_currency_code ar_inv_currency,
                       rcta.trx_date,
                       rcta.BILL_TO_SITE_USE_ID,
                       rcta.SHIP_TO_PARTY_SITE_USE_ID,
                       rcta.BILL_TO_CUSTOMER_ID,
                       rcta.SHIP_TO_PARTY_ID,
                       rcta.sold_to_party_id,
                       rcta.org_id,                                                               
                       rcta.interface_header_attribute1,
					   CASE
							WHEN rcta.previous_customer_trx_id IS NOT NULL THEN
								(select b.name 
									from ra_customer_trx_all a,
										ra_batch_sources_all b 
									where	a.batch_source_seq_id = b.batch_source_seq_id
									and		a.customer_trx_id = rcta.previous_customer_trx_id)
							ELSE
								NULL
						END			previous_source_name,
						rbsa.name	source_name,
                       ctl.inventory_item_id,
                       ctl.line_type,
                       ctl.line_number ar_line_number,
                       ctl.interface_line_attribute5,
                       ctl.interface_line_attribute2,
                       to_char(ctl.previous_customer_trx_line_id) previous_customer_trx_line_id,
                       ROUND(lgd.amount, fc.precision) dist_amount,             --To handle Rounding problem observed in AR base tables
                       lgd.ACCTD_AMOUNT Acct_dist_amount,
                       lgd.event_id,
                       lgd.cust_trx_line_gl_dist_id,
                       arpt_sql_func_util.get_first_real_due_date(rcta.customer_trx_id,
                                                                   rcta.term_id,
                                                                   rcta.trx_date) due_date,
                       rcta.exchange_rate,
                       rcta.invoice_currency_code trx_currency,
                       rcta.trx_class,
                       ROUND(ctl.extended_amount, fc.precision) extended_amount,
                       ctl.quantity_credited,
                       DECODE(rcta.trx_class, 'CM', -1 * ctl.quantity_credited, ctl.quantity_invoiced) quantity_invoiced,
                       rcta.customer_trx_id,
                       TO_CHAR(ctl.customer_trx_line_id) invoice_line_id,
                       TO_CHAR(ctl.line_number)invoice_line,
					   CASE
							WHEN rcta.previous_customer_trx_id IS NOT NULL THEN
								(select b.description 
									from ra_customer_trx_all a,
										ra_cust_trx_types_all b 
									where	a.cust_trx_type_seq_id = b.cust_trx_type_seq_id
									and 	a.customer_trx_id = rcta.previous_customer_trx_id)
							ELSE
								NULL
						END			previous_trx_type,
					   ctt.description trx_type,
                       rcta.purchase_order,
                       decode(rcta.trx_class,'CM'
                                            ,'Y'
                                            ,'N') return_flag,
                       rcta.set_of_books_id,
                       ctl.unit_selling_price * DECODE(rcta.trx_class,'CM',-1,1) unit_selling_price,
                       gl.currency_code,
                       fc_gl.currency_code base_currency,
                       ctl.interface_line_context,
                       ctl.created_by,
                       ctl.creation_date,
                       ctl.last_update_date,
                       '' last_updated_by,
                       rcta.creation_date    pro_creation_date,
                       rcta.last_update_date pro_last_update_date,
					   CASE
							WHEN ctl.previous_customer_trx_line_id IS NOT NULL THEN
								(SELECT recurring_bill_flag FROM ra_customer_trx_lines_all WHERE customer_trx_line_id = ctl.previous_customer_trx_line_id)
							ELSE
								ctl.RECURRING_BILL_FLAG
						END RECURRING_BILL_FLAG,
						--REL-030 Start Invoice Source "Nurego"
						ctl.interface_line_attribute1,
						ctl.interface_line_attribute3,
						ctl.interface_line_attribute4
						--REL-030 End Invoice Source "Nurego"
                        /*--Below code commented REL-030
						--REL-027 Added below code to print recurring billing flag and trx date from origianl invoice
						DECODE(UPPER(rbsa.name), UPPER('Rebill'),
						(SELECT rctla1.recurring_bill_flag 
						   FROM RA_CUSTOMER_TRX_ALL rcta1,
						        RA_CUSTOMER_TRX_LINES_ALL rctla1, 
						        RA_BATCH_SOURCES_ALL rbsa1
						  WHERE rctla1.interface_line_attribute5 = ctl.interface_line_attribute5
						    AND rcta1.customer_trx_id = rctla1.customer_trx_id
						    AND rbsa1.name = 'Distributed Order Orchestration'
							AND rcta1.batch_source_seq_id = rbsa1.batch_source_seq_id
							--AND UPPER(rbsa.name) = UPPER('Rebill')
							AND rctla1.recurring_bill_flag = 'Y'
							AND ROWNUM = 1
						)) rebill_recurring_bill_flag,
						
						DECODE(UPPER(rbsa.name), UPPER('Rebill'),
						(SELECT rcta1.trx_date 
						   FROM RA_CUSTOMER_TRX_ALL rcta1,
						        RA_CUSTOMER_TRX_LINES_ALL rctla1, 
						        RA_BATCH_SOURCES_ALL rbsa1
						  WHERE rctla1.interface_line_attribute5 = ctl.interface_line_attribute5
						    AND rcta1.customer_trx_id = rctla1.customer_trx_id
						    AND rbsa1.name = 'Distributed Order Orchestration'
							AND rcta1.batch_source_seq_id = rbsa1.batch_source_seq_id
							--AND UPPER(rbsa.name) = UPPER('Rebill')
							AND rctla1.recurring_bill_flag = 'Y'
							AND ROWNUM = 1
						)) rebill_trx_date
						
						--REL-027 Added above code to print recurring billing flag and trx date from origianl invoice
						--Above code commented REL-030
                        */						
                  FROM ra_customer_trx_all          rcta,
                       ra_batch_sources_all         rbsa,
                       ra_customer_trx_lines_all    ctl,
                       ra_cust_trx_line_gl_dist_all lgd,
                       ra_cust_trx_types_all        ctt,
                       fnd_currencies_vl            fc_gl,
                       gl_ledgers                   gl,
                       fnd_currencies               fc,
					   --REL-030 Start
		               xla_transaction_entities xte, 
		               xla_ae_headers  xah,
		               xla_distribution_links xdl,
		               xla_ae_lines xal
	                  --REL-030 End
                 WHERE lgd.customer_trx_line_id     = ctl.customer_trx_line_id
                   AND rcta.customer_trx_id         = ctl.customer_trx_id
                   AND rcta.customer_trx_id         = lgd.customer_trx_id
                   AND rcta.BATCH_SOURCE_SEQ_ID     = rbsa.BATCH_SOURCE_SEQ_ID
                   AND rcta.cust_trx_type_seq_id    = ctt.cust_trx_type_seq_id
                   AND gl.ledger_id                 = rcta.set_of_books_id
                   AND gl.currency_code             = fc_gl.currency_code
                   AND fc.currency_code             = rcta.invoice_currency_code
                   AND ctl.line_type                != 'TAX'
				   AND rcta.trx_number				= NVL(:p_trx_num, rcta.trx_number)	--REL-030 Performance Improvement for single invoice
				   --REL-030 Start	--Always ensure conditions for xte and xah is same as ar_posted_to_gl subquery factor
					AND xte.entity_code                  = 'TRANSACTIONS'    
					AND xte.application_id               = 222
					AND xte.source_id_int_1              = rcta.customer_trx_id
					AND xah.entity_id                    = xte.entity_id
					AND xah.ledger_id                    = xte.ledger_id
					AND xah.application_id               = 222
					AND xah.accounting_entry_status_code = 'F'
					AND xah.gl_transfer_status_code      = 'Y'
					AND xah.ae_header_id                 = xal.ae_header_id
                    AND xdl.ae_header_id                 = xal.ae_header_id
                    AND xdl.ae_line_num                  = xal.ae_line_num
                    AND xal.application_id               = 222
                    AND xdl.application_id               = 222
	                AND xal.accounting_class_code        = 'REVENUE'
	                AND xdl.source_distribution_id_num_1 = lgd.cust_trx_line_gl_dist_id
					AND xah.period_name IN (CASE 
												WHEN (:p_trx_num IS NOT NULL OR :p_order_number IS NOT NULL OR :p_contract_number IS NOT NULL) THEN xah.period_name
												ELSE
													(SELECT period_name
													FROM   gl_periods
													WHERE  (TO_DATE(NVL(:p_start_date, TO_CHAR(SYSDATE - 1,'YYYY-MM-DD')),'YYYY-MM-DD') BETWEEN trunc(start_date) AND trunc(end_date)
															OR TO_DATE(NVL(:p_end_date, TO_CHAR(SYSDATE,'YYYY-MM-DD')),'YYYY-MM-DD') BETWEEN trunc(start_date) AND trunc(end_date))
													AND    adjustment_period_flag = 'N'
													AND period_set_name = 'CCL CALENDAR' --REL-030
													GROUP BY period_name)
											END)
					--REL-030 End
					--REL-045 Added below code
					AND rcta.org_id not in (SELECT bu.bu_id 
											FROM fnd_lookup_values_vl flvl, fun_all_business_units_v bu
											WHERE flvl.lookup_type='GED_BU_NAMES' 
											AND flvl.description='GRID_SWS'
											AND flvl.meaning=bu.bu_name)
					--REL-045 Added above code
				),
----------------------------------Order Details Starts -----------------------------------
order_details AS (SELECT /*+ MATERIALIZE */ dha.org_id,
                         dha_eff.attribute_char1 order_type,
                         dha.sold_to_party_id,
                         nvl(dha_eff.attribute_char7, dha.order_number) opportunity_number,
                         dha_eff.attribute_char6 quote_number,
                         dha.order_number,
                         dla.inventory_organization_id,
                         dla.line_number,
                         dfla.fulfill_line_number,
                         dfla.line_type_code,
                         dha.header_id,
                         dla.line_id,
                         to_char(dfla.fulfill_line_id) fulfill_line_id,
                         dha.ordered_date,
                         dha.transactional_currency_code order_currency,                             
                         dha_eff.attribute_char10 related_opportunity_number,
                         --dfl_eff.attribute_char1  VSOE_FLAG,  --GEFCERPRR-50
                         'False'  VSOE_FLAG,                    --GEFCERPRR-50 --VSOE flag by default print as "False" REL-013
                         dfl_eff.attribute_date1,
                         dfl_eff.attribute_date2,
                         dla.ordered_qty,   
                         CASE
                             WHEN (SELECT COUNT('X')
                                     FROM doo_lines_all dl1
                                    WHERE dha.header_id = dl1.header_id
                                      AND dl1.parent_line_id IS NULL) > 1 THEN
								'N'
                         ELSE
								'Y'
                         END STANDALONE_FLAG,                         
                         DECODE(NVL(TO_NUMBER(REPLACE(dfl_eff.attribute_char7,',','.')), 0), 0, 0.99, 
						 NVL(TO_NUMBER(REPLACE(dfl_eff.attribute_char7,',','.')),0)) unit_list_price,
						 (SELECT bp.periodicity_code
                                     FROM   doo_billing_plans     bp
                                     WHERE  1=1
                                     AND    bp.fulfill_line_id =dfla.fulfill_line_id  
                                     AND    bp.OBJECT_VERSION_NUMBER = (select max(OBJECT_VERSION_NUMBER) from
									                                    doo_billing_plans bp1 where
																		bp1.fulfill_line_id = dfla.fulfill_line_id)
							AND rownum = 1
							) periodicity_code
						 
						 
                         FROM doo_headers_all           dha,
                              doo_lines_all             dla,
                              doo_fulfill_lines_all     dfla,
                              --doo_headers_eff_b         dha_eff,
                              --doo_fulfill_lines_eff_b   dfl_eff,
							  ( select fulfill_line_id,context_code,attribute_date2,attribute_date1, attribute_char7, attribute_char1
								from DOO_FULFILL_LINES_EFF_B
								where context_code= 'GED Fline Context'
							   )dfl_eff,
							   (select attribute_char1,
										attribute_char7,
										attribute_char6,
										attribute_char10,
										header_id
								from doo_headers_eff_b where context_code = 'GED HEADER EFF CONTEXT') dha_eff
                        WHERE 1=1
                          AND dha.header_id             =  dla.header_id
                          AND dla.line_id               =  dfla.line_id
                          AND dha.header_id             =  dha_eff.header_id(+)
                          --AND NVL(dha_eff.context_code,'GED HEADER EFF CONTEXT')   =  'GED HEADER EFF CONTEXT'
                          AND dfla.fulfill_line_id      =  dfl_eff.fulfill_line_id(+)
                          --AND NVL(dfl_eff.context_code, 'GED Fline Context')   = 'GED Fline Context'
						  AND dha.status_code NOT LIKE '%DOO%'
                          --AND dha.object_version_number = (SELECT MAX(object_version_number) FROM doo_headers_all dha1 WHERE dha1.order_number = dha.order_number))
						  --REL-045 Added below code
						  AND dha.org_id NOT IN (SELECT bu.bu_id 
											       FROM fnd_lookup_values_vl flvl, fun_all_business_units_v bu
											      WHERE flvl.lookup_type='GED_BU_NAMES' 
											        AND flvl.description='GRID_SWS'
											        AND flvl.meaning=bu.bu_name)
						  --REL-045 Added above code
						  ),
----------------------------------Order Details Closed ------------------------
----------------------------------Item Details Starts -------------------------
item_details AS (SELECT /*+ MATERIALIZE */ esib.item_number,
                        eic.inventory_item_id,
                        esib.description  item_description,
                        ecb.attribute2      product_family,
                        ecb.attribute4      product_line,
                        ecb.attribute5      product_type,
                        ecb.attribute6      product_subtype,
                        decode(ecb.attribute6, NULL, 'Default Flag', NULL) comments,
						CASE
							WHEN ecb.attribute5 = 'LIC' AND ecb.attribute6 = 'LICENSE' THEN
								'Y'
							WHEN ecb.attribute5 = 'SUB' AND ecb.attribute6 = 'SBXN' THEN
								'N'
							WHEN ecb.attribute5 = 'SUB' AND ecb.attribute6 = 'PARTNRFEES' THEN
								'Y'
							WHEN ecb.attribute5 = 'SUP' AND ecb.attribute6 = 'SUPP' THEN
								'Y'
							WHEN ecb.attribute5 = 'SVC' AND ecb.attribute6 IN('CONSSVC','IMPSVCS','MNGDSVC') THEN
								'Y'
							WHEN ecb.attribute5 = 'SVC' AND ecb.attribute6 IN('PRJ3PRHW','PRJ3PRSV','PRJ3PRSW','PRJTANDL','PRJTRNG','TANDL','THIRDPTYBDL','THIRDPTYHW','THIRDPTYSV','THIRDPTYSW','TRAINING','TRAININGMAT') THEN
								'N'
							WHEN ecb.attribute5 = 'HDW' AND ecb.attribute6 IN('ACCESSOR','LEASEDHW','PURCHHW','WARRANTY') THEN
								'N'
						END flag_97_2,
						CASE
							WHEN ecb.attribute5 = 'SUP' THEN
							'Y'
							WHEN ecb.attribute5 = 'SVC' AND ecb.attribute6 = 'MNGDSVC' THEN
								'Y'
							WHEN ecb.attribute5 IN('LIC','HDW') THEN
							'N'
							WHEN ecb.attribute5 = 'SVC' AND ecb.attribute6 IN('CONSSVC','IMPSVCS','TRAINING', 'TRAININGMAT') THEN
								'N'
						ELSE
								'N'
						END AS PCS_FLAG,
						CASE 
							WHEN ecb.attribute5 = 'SUP' THEN
								'Y'
							WHEN ecb.attribute5 = 'SVC' AND ecb.attribute6 = 'MNGDSVC' THEN 
								'Y' 
							WHEN ecb.attribute5 IN ('LIC', 'SUB', 'HDW') THEN 
								'N'
                        ELSE
								'N'
                        END undelivered_flag,
                        esib.organization_id
                        FROM egp_categories_b        ecb,
                             inv_org_parameters      iop,
                             egp_category_sets_vl    ecst,
                             egp_item_categories     eic,
                             egp_system_items_vl     esib
                       WHERE ecb.category_id         =  eic.category_id
                         AND esib.organization_id    =  iop.organization_id
                         AND iop.organization_code   =  'GED_IMO'
                         AND ecst.category_set_name  =  'Global_Inv_Default_Catalog'
                         AND eic.category_set_id     =  ecst.category_set_id(+)
                         AND esib.inventory_item_id  =  eic.inventory_item_id
                         AND esib.organization_id    =  eic.organization_id),
----------------------------------Item Details Closed -------------------------                         
----------------------------------BU Details-----------------------------------
bu_details AS (SELECT a.bu_id, a.bu_name, legal_entity_id 
                 FROM fun_all_business_units_v a
                WHERE 1 = 1
                  AND a.bu_name IN
                                (SELECT flv.lookup_code
                                   FROM fnd_lookup_values flv
                                  WHERE flv.lookup_type   = 'GED_BU_NAMES'
                                    AND flv.language      = 'US'
                                    AND flv.enabled_flag  = 'Y'
                                    AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                                    AND nvl(flv.end_date_active, SYSDATE) >= SYSDATE)
									AND  NOT EXISTS(SELECT 1 FROM fun_all_business_units_v fabu1
													WHERE 1=1
													AND fabu1.BU_NAME IN(SELECT meaning FROM fnd_lookup_values WHERE lookup_type LIKE 'AVD%BU%NAME%')
													AND fabu1.BU_ID=A.BU_ID)
				  --REL-045 Added below code									
				  AND a.bu_id not in (SELECT bu.bu_id 
											FROM fnd_lookup_values_vl flvl, fun_all_business_units_v bu
											WHERE flvl.lookup_type='GED_BU_NAMES' 
											AND flvl.description='GRID_SWS'
											AND flvl.meaning=bu.bu_name)												
				  --REL-045 Added above code
               ),
----------------------------------BU Details Closed----------------------------
--------------------------------Bill To Starts-----------------------------------------
bill_to AS (SELECT su.site_use_id,
                   hca.customer_type,
                   REPLACE(REPLACE(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(hp.party_name))),CHR(10)),'"',' ') party_name,
                   hp.party_number,
                   hca.cust_account_id,
                   hca.account_number,
                   hl.country,
                   hca.attribute1,
                   cas.attribute2 cash_basis_customer,
                   hl.state,
                   hl.province
              FROM HZ_CUST_SITE_USES_ALL  su,
                   HZ_CUST_ACCT_SITES_ALL cas,
                   HZ_PARTY_SITES         hps,
                   HZ_LOCATIONS           hl,
                   HZ_PARTIES             hp,
                   HZ_CUST_ACCOUNTS       hca
             WHERE su.cust_acct_site_id   = cas.cust_acct_site_id
               AND cas.party_site_id      = hps.party_site_id
               AND hps.location_id        = hl.location_id
               AND hp.party_id            = hps.party_id
               AND cas.cust_account_id    = hca.cust_account_id
               AND su.site_use_code       = 'BILL_TO'
            ) ,
--------------------------------Bill To Closed---------------------------------
--------------------------------Ship To Starts---------------------------------------
ship_to AS (SELECT hpsu.party_site_use_id,
                   REPLACE(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(hp.party_name))),CHR(10)) party_name,
                   hca.account_number,
                   hl.country,
                   hl.province,
                   hl.state,
                   hca.cust_account_id,
                   hca.customer_type
              FROM hz_party_site_uses hpsu,
                   hz_party_sites     hps,
                   hz_locations       hl,
                   hz_parties         hp,
                   hz_cust_accounts   hca
             WHERE hpsu.party_site_id = hps.party_site_id
               AND hps.location_id    = hl.location_id
               AND hp.party_id        = hps.party_id
               AND hp.party_id        = hca.party_id) ,
--------------------------------Ship To Closed----------------------------
--------------------------------Sold To Starts-----------------------------------------
sold_to AS (SELECT hp.party_id,
                   hca.cust_account_id,
                   REPLACE(REPLACE(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(hp.party_name))),CHR(10)),'"',' ') customer_name,
                   hca.account_number,
                   hca.customer_class_code,
                   hca.customer_type
              FROM HZ_PARTIES           hp,
                   HZ_CUST_ACCOUNTS     hca
             WHERE hp.party_id          = hca.party_id
               ),
--------------------------------Sold To Closed---------------------------------
--------------------------------Contract and Project Detail Start--------------
con_proj_detail AS (SELECT /*+ MATERIALIZE */ okha.contract_number    project_contract_number,
                           okha.id                 project_contract_id,
                           pil.invoice_line_id, 
                           pil.contract_id,
                           ppe.element_number      task_number,
                           pj.name                 job_name,
                           pj.job_id               job_id,
                           peia.incurred_by_person_id person_id,
                           ppf.full_name           customer_class,
						   --okha.attribute1         order_number,  --REL-031
						   okla.attribute3         order_number,    --REL-031
                           okla.order_id,
                           --okha.attribute2         order_line_number, --REL-031
						   okla.attribute4         order_line_number,   --REL-031
                           okla.order_line_id,
                           okha.start_date,
                           okha.end_date,
                           okla.id                 contract_line_id, 
                           okla.item_name,
                           okla.item_description,
                           okha.attribute5,
                           okha.attribute4, 
                           okha.attribute3,
						   okla.OBJECT1_ID1 INVENTORY_ITEM_ID,
                           ppav.project_id,
                           ppav.segment1           project_number,
                           ppav.name               project_name,
                           flv.meaning             project_contract_status,
                           bill_meth.bill_method_name bill_plan_method_name,
                           rev_meth.bill_method_name  revenue_plan_method_name,
                           okha.attribute4 				opportunity_number,
                           ROUND(SUM(pild.TRNS_CURR_BILLED_AMT), fc.precision) project_inv_amount,
						   pild.invoice_dist_id pild_invoice_dist_id,
						   pild.credited_dist_id
                      from  okc_k_headers_all_b       okha,
                           okc_k_lines_vl            okla,
                           pjb_invoice_headers       pih, 
                           pjb_invoice_lines         pil,
                           pjb_inv_line_dists        pild,
                           pjf_projects_all_vl       ppav,
                           fnd_lookup_values_vl      flv,
                           pjc_exp_items_all         peia,
                           per_person_names_f        ppf,
                           per_jobs                  pj,
                           pjb_bill_plans_b          bill_pl,
                           pjb_billing_methods_vl    bill_meth,
                           pjb_bill_plans_b          rev_pl,
                           pjb_billing_methods_vl    rev_meth,
                           pjf_proj_elements_b       ppe,
                           fnd_currencies           fc
                       WHERE okha.major_version          =  okla.major_version 
                       AND okha.major_version          =  (SELECT MAX(a.major_version) 
                                                             FROM okc_k_headers_all_b a
                                                            WHERE a.contract_number = okha.contract_number)
                       AND okha.id                     =  okla.chr_id                  
                       AND pild.contract_id            =  okha.id 
                       AND pild.contract_line_id       =  okla.id 
                       AND pild.invoice_id             =  pih.invoice_id 
                       AND pild.invoice_line_id        =  pil.invoice_line_id 
                       AND pih.invoice_id              =  pil.invoice_id
                       AND ppav.project_id(+)          =  pild.transaction_project_id
                      -- AND okha.sts_code               IN('ACTIVE','CLOSED')
                       AND okha.version_type           =  'C'
                       AND flv.lookup_type             =  'OKC_STATUS'
                       AND flv.lookup_code             =  okha.sts_code
                       AND pild.transaction_id         =  peia.expenditure_item_id(+)
                       AND pild.transaction_project_id =  peia.project_id(+)
                       AND pild.transaction_task_id    =  peia.task_id(+)
                       AND peia.incurred_by_person_id  =  ppf.person_id(+)
                       AND peia.cost_job_id            =  pj.job_id(+)
                       AND NVL(ppf.name_type,'GLOBAL')            = 'GLOBAL'
                       AND (SYSDATE BETWEEN NVL(ppf.effective_start_date, SYSDATE-1) AND NVL(ppf.effective_end_date, SYSDATE))
                       AND okla.bill_plan_id           =  bill_pl.bill_plan_id(+)
                       AND okla.major_version          =  bill_pl.major_version(+)
                       AND bill_pl.bill_method_id      =  bill_meth.bill_method_id(+)
                       AND okla.revenue_plan_id        =  rev_pl.bill_plan_id(+)
                       AND okla.major_version          =  rev_pl.major_version(+)
                       AND rev_pl.bill_method_id       =  rev_meth.bill_method_id(+) 
                       AND pild.linked_task_id         =  ppe.proj_element_id(+)
                       AND fc.currency_code            =  pih.invoice_currency_code
                       -----------Below joins for Job----------                                                    
                       GROUP BY okha.contract_number, okha.id, pil.invoice_line_id, pil.contract_id, ppe.element_number, 
                                pj.name, 
								--okha.attribute1, okha.attribute2, --REL-031
								okla.attribute3, okla.attribute4,   --REL-031
								okla.order_id, okla.order_line_id, okha.start_date,
                                okha.end_date, okla.id, okla.item_name, okla.item_description, okha.attribute5, okha.attribute4,
                                okha.attribute3, okla.OBJECT1_ID1, ppav.project_id, ppav.segment1, ppav.name, flv.meaning,
                                bill_meth.bill_method_name, rev_meth.bill_method_name, okha.attribute4, ppf.full_name,peia.incurred_by_person_id,
                                fc.precision ,pj.job_id, pild.invoice_dist_id, pild.credited_dist_id)
--------------------------------Contract and Project Detail Closed---------------------------------
--------------------------------MAIN---------------------------------------------------------------
SELECT  ct.customer_account_number    AS "CUSTOMER_ACCOUNT_NUMBER",
        ct.customer_profile_class     AS "CUSTOMER_PROFILE_CLASS",
        (SELECT flv.meaning
           FROM fnd_lookup_values_vl flv
          WHERE flv.lookup_type          = 'CUSTOMER_TYPE'
            AND ct.customer_account_type = flv.lookup_code) AS "CUSTOMER_ACCOUNT_TYPE",
        ct.unbilled_ar_account        AS "UNBILLED_AR_ACCOUNT",
        ct.project_contract_number    AS "PROJECT_CONTRACT_NUMBER",
        ct.project_contract_id        AS "PROJECT_CONTRACT_ID",
        ct.project_number             AS "PROJECT_NUMBER",
        --ct.project_name               AS "PROJECT_NAME",
        ct.task_number                AS "TASK_NUMBER",
        ct.project_contract_status    AS "PROJECT_CONTRACT_STATUS",
        ct.revenue_plan               AS "REVENUE_PLAN",                
        ct.job_name                   AS "JOB_NAME",
        decode(decode(ct.order_type, 'Intercompany Order', 'I', ct.customer_account_type),	
          'I',
          '1129104000',
          'N',
          '1129104000',
          'W',
          '1129104000',
          '1080201003')               AS "CASH_BASIS_CUSTOMER",
        ct.region                     AS "REGION",
        CASE 
			/*--Below code commented REL-030
			WHEN
			--Query Starts--REL-027--2/6/19 Nitin Bhatt Added Rebill source
				ct.source_name = 'Rebill' 
			THEN
				'Rebill:'||ct.comments
			--Query Ends--REL-027--2/6/19 Nitin Bhatt Added Rebill source
			--Above code commented REL-030
			*/
			WHEN
				ct.related_opportunity_number IN (ct.sales_order, ct.project_contract_number)
			OR 	ct.opportunity_number IN (ct.sales_order, ct.project_contract_number)
			THEN
				'Error: CPQ skipped'
			WHEN
				ct.related_opportunity_number IN (ct.previous_invoice_number, ct.invoice_number)
			OR	ct.opportunity_number IN (ct.previous_invoice_number, ct.invoice_number)
			THEN
				'Error: Manual Invoice'
		ELSE
			ct.comments
		END														AS "COMMENTS",
        NVL(ct.related_opportunity_number, ct.opportunity_number) AS "RELATED_OPPORTUNITY_NUMBER",
        ct.bill_plan                  AS "BILL_PLAN",
        ct.opportunity_number         AS "OPPORTUNITY_NUMBER",
        ct.vsoe_flag                  AS "VSOE_FLAG",
        ct.base_curr_code             AS "BASE_CURR_CODE",
        ct.bill_to_country            AS "BILL_TO_COUNTRY",
        REPLACE(REPLACE(ct.bill_to_customer_name,'"',' '), CHR(13), ' ') AS "BILL_TO_CUSTOMER_NAME",
        ct.bill_to_customer_number    AS "BILL_TO_CUSTOMER_NUMBER",
        ct.bill_to_cust_id            AS "BILL_TO_ID",
        ct.business_unit              AS "BUSINESS_UNIT",
	   NULL 							   AS "COGS_D_SEG1",
	   NULL 							   AS "COGS_D_SEG2",
	   NULL 								AS "COGS_D_SEG3",
	   NULL 								AS "COGS_D_SEG4",
	   NULL 								AS "COGS_D_SEG5",
	   NULL 								AS "COGS_D_SEG6",
	   NULL 								AS "COGS_D_SEG7",
	   NULL 								AS "COGS_D_SEG8",
	   NULL 								AS "COGS_D_SEG9",
	   NULL 								AS "COGS_D_SEG10",
	   NULL 							   AS "COGS_R_SEG1",
	   NULL 							   AS "COGS_R_SEG2",
	   NULL 								AS "COGS_R_SEG3",
	   NULL 								AS "COGS_R_SEG4",
	   NULL 								AS "COGS_R_SEG5",
	   NULL 								AS "COGS_R_SEG6",
	   NULL 								AS "COGS_R_SEG7",
	   NULL 								AS "COGS_R_SEG8",
	   NULL 								AS "COGS_R_SEG9",
	   NULL 								AS "COGS_R_SEG10",
	   NULL 								AS "COST_AMOUNT",
       NULL 								AS "COST_CURR_CODE",
       NULL 								AS "COST_EX_RATE",	   
        ct.created_by                 AS "CREATED_BY",
        ct.creation_date              AS "CREATION_DATE",
        (SELECT flv.meaning
           FROM fnd_lookup_values_vl flv
          WHERE flv.lookup_type        = 'CUSTOMER CLASS'
            AND ct.customer_class_code = flv.lookup_code)        AS "CUSTOMER_CLASS",
        ct.customer_id                AS "CUSTOMER_ID",
        REPLACE(REPLACE(ct.customer_name,'"',' '), CHR(13), ' ') AS "CUSTOMER_NAME",
        ct.segment1                   AS "DEF_ACCTG_SEG1",
        ct.segment2                   AS "DEF_ACCTG_SEG2",
        ct.def_segment3               AS "DEF_ACCTG_SEG3",	--REL-027
        ct.segment4                   AS "DEF_ACCTG_SEG4",
        ct.segment5                   AS "DEF_ACCTG_SEG5",
        ct.segment6                   AS "DEF_ACCTG_SEG6",
        ct.segment7                   AS "DEF_ACCTG_SEG7",
        ct.segment8                   AS "DEF_ACCTG_SEG8",
        ct.segment9                   AS "DEF_ACCTG_SEG9",
        ct.segment10|| '-' ||ct.segment11 AS "DEF_ACCTG_SEG10",
        'Y'                           AS "DEFERRED_REVENUE_FLAG",
        ct.due_date                   AS "DUE_DATE",
        /* Below code commented REL-013 
       decode(decode(ct.order_type, 'Intercompany Order', 'I', ct.customer_account_type),
                                        'I'
                                       ,'N'
                                       ,'N'
                                       ,'N'
                                       ,'W'
                                       ,'N'
                                       ,'Y'
               )  AS "ELIGIBLE_FOR_CV",*/
        'N'       AS "ELIGIBLE_FOR_CV",             --ELIGIBLE_FOR_CV Flag by default print as "N" REL-013
        'Y'       AS "ELIGIBLE_FOR_FV",
        NVL(ct.exchange_rate,
                            (SELECT gdr.conversion_rate
                               FROM gl_daily_rates            gdr,
                                    gl_daily_conversion_types gdc
                              WHERE gdc.conversion_type      = gdr.conversion_type
                                AND gdr.from_currency        = ct.trans_curr_code
                                AND gdr.to_currency          = ct.base_curr_code
                                AND gdr.conversion_date      = TRUNC(ct.creation_date)
                                AND gdc.user_conversion_type = 'MOR'
                            )
            ) AS "EX_RATE",
        ct.ext_list_price          AS "EXT_LIST_PRICE",
        NVL(ct.ext_sell_price, 0)  AS "EXT_SELL_PRICE",
        /* Below code commented REL-013 
        decode(decode(ct.order_type, 'Intercompany Order', 'I', ct.customer_account_type),
                                         'I',
                                         'N',
                                         'N',
                                         'N',
                                         'W',
                                         'N',
                                          NVL(ct.flag_97_2,'N')) AS "FLAG_97_2",*/
        'N'                               AS "FLAG_97_2",        --97_2 Flag by default print as "N" REL-013
--REL-031 commented to avoid timestamp issue as SEP invoices are shown in AUG
--       ct.invoice_date                   AS "INVOICE_DATE",
		to_char(ct.invoice_date,'YYYY-MM-DD') AS "INVOICE_DATE",	---REL-031 removed UTC timestamp	
        ct.INVOICE_ID                     AS "INVOICE_ID",
        ct.invoice_line                   AS "INVOICE_LINE",
        ct.invoice_line_id                AS "INVOICE_LINE_ID",
        ct.INVOICE_NUMBER                 AS "INVOICE_NUMBER",
        ct.INVOICE_TYPE                   AS "INVOICE_TYPE",
        replace(ct.ITEM_DESC,'"','.')     AS "ITEM_DESC",
        ct.ITEM_ID                        AS "ITEM_ID",
        ct.item_number                    AS "ITEM_NUMBER",
        ct.last_update_date               AS "LAST_UPDATE_DATE",
        ct.last_updated_by                AS "LAST_UPDATED_BY",
        'N'                               AS "NON_CONTINGENT_FLAG",
        ct.org_id                         AS "ORG_ID",
        ct.orig_inv_line_id               AS "ORIG_INV_LINE_ID",
        ct.pcs_flag                       AS "PCS_FLAG",
        ct.po_num                         AS "PO_NUM",
        ct.product_category               AS "PRODUCT_CATEGORY",            
        ct.product_class                  AS "PRODUCT_CLASS",
        ct.product_family                 AS "PRODUCT_FAMILY",
        ct.product_line                   AS "PRODUCT_LINE",
        NVL(ct.quantity_invoiced,0)       AS "QUANTITY_INVOICED",
        ct.quantity_ordered               AS "QUANTITY_ORDERED",
        ct.quote_num                      AS "QUOTE_NUM",
        ct.return_flag                    AS "RETURN_FLAG",
        ct.segment1                       AS "REV_ACCTG_SEG1",
        DECODE(decode(ct.order_type, 'Intercompany Order', 'I', ct.customer_account_type),
				 'I','4020601000'
                ,'N','4020601000'
                ,'W','4020601000'
                ,'4020101000'
               )                          AS "REV_ACCTG_SEG2",
        ct.segment3                       AS "REV_ACCTG_SEG3",
		-- REL2.6
       -- 'DG5000'                        AS "REV_ACCTG_SEG4",
	   ct.segment4                        AS "REV_ACCTG_SEG4",
	   -- REL2.6
                CASE
                    WHEN ct.country = 'US' AND ct.state IS NOT NULL THEN
                         NVL((SELECT ffvv.flex_value
                                FROM fnd_flex_value_sets  ffvs,
                                     fnd_flex_values_vl   ffvv,
                                     fnd_lookup_values_vl flv
                               WHERE ffvs.flex_value_set_id   = ffvv.flex_value_set_id
                                 AND ffvs.flex_value_set_name = 'CCL_GEOGRAPHIES'
                                 AND ffvv.enabled_flag        = 'Y'
                                 AND SYSDATE BETWEEN NVL(ffvv.start_date_active, SYSDATE) AND nvl(ffvv.end_date_active, SYSDATE)
                                 AND ((UPPER(flv.description) = UPPER(NVL(NVL(ct.state, ct.state),'000'))) OR 
                                      (UPPER(flv.lookup_code) = UPPER(NVL(NVL(ct.state, ct.state),'000')))
                                      )
                                 AND flv.lookup_type = 'GED_FA_STATE_CODES'
                                 AND ffvv.description LIKE ct.country|| '-' || flv.lookup_code || '%'
                                 AND ROWNUM = 1)
                             ,'000')
                    WHEN ct.country = 'CA' AND ct.province IS NOT NULL THEN
                         NVL((SELECT ffvv.flex_value
                                FROM fnd_flex_value_sets ffvs,
                                     fnd_flex_values_vl  ffvv
                               WHERE ffvs.flex_value_set_id   = ffvv.flex_value_set_id
                                 AND ffvs.flex_value_set_name = 'CCL_GEOGRAPHIES'
                                 AND ffvv.enabled_flag        = 'Y'
                                 AND SYSDATE BETWEEN nvl(ffvv.start_date_active, SYSDATE) AND nvl(ffvv.end_date_active,SYSDATE)
                                 AND ffvv.description LIKE ct.country || '-' ||ct.province|| '%'
                                 AND ROWNUM = 1)
                            ,'000')
                    WHEN ct.country NOT IN ('CA','US') THEN
                        (SELECT ft.iso_territory_code
                           FROM fnd_territories ft
                          WHERE ft.territory_code = ct.country)
                ELSE
                   '000'
                END                               AS "REV_ACCTG_SEG5",
        '0000000000'                              AS "REV_ACCTG_SEG6",
        '000000'                                  AS "REV_ACCTG_SEG7",
        ct.segment8                               AS "REV_ACCTG_SEG8",
        ct.segment9                               AS "REV_ACCTG_SEG9",
        '000000000-000000'                        AS "REV_ACCTG_SEG10",
        SUBSTR(ct.rule_end_date,   0, 10)         AS "RULE_END_DATE",
        SUBSTR(ct.rule_start_date, 0, 10)         AS "RULE_START_DATE",
        ct.sales_order                            AS "SALES_ORDER",
        ct.sales_order_id                         AS "SALES_ORDER_ID",
        ct.sales_order_line                       AS "SALES_ORDER_LINE",
        ct.sales_order_line_id                    AS "SALES_ORDER_LINE_ID",
        ct.ship_to_country                        AS "SHIP_TO_COUNTRY",
        REPLACE(REPLACE(ct.ship_to_customer_name,'"',' '), CHR(13), ' ') AS "SHIP_TO_CUSTOMER_NAME",
        ct.ship_to_customer_number                AS "SHIP_TO_CUSTOMER_NUMBER",
        ct.sob_id                                 AS "SOB_ID",
        ct.standalone_flag                        AS "STANDALONE_FLAG",
        'N'                                       AS "STATED_FLAG",
        'INV'                                     AS "TRAN_TYPE",
        ct.trans_curr_code                        AS "TRANS_CURR_CODE",
        ct.unbilled_accounting_flag               AS "UNBILLED_ACCOUNTING_FLAG",
        ct.undelivered_flag                       AS "UNDELIVERED_FLAG",
        ct.unit_list_price                        AS "UNIT_LIST_PRICE",
        NVL(ct.unit_selling_price,0)              AS "UNIT_SELL_PRICE",
        ROWNUM 									  AS "KEY",
        ct.rcurr_ex_rate                          AS "RCURR_EX_RATE"
  FROM (
          --======================================DOO======================================================================
        SELECT sold_to.account_number                    AS "CUSTOMER_ACCOUNT_NUMBER",
               'Fusion AR - Invoice'                     AS "CUSTOMER_PROFILE_CLASS",
               bill_to.cash_basis_customer               AS "UNBILLED_AR_ACCOUNT",
               NULL                                      AS "PROJECT_CONTRACT_NUMBER",
               NULL                                      AS "PROJECT_CONTRACT_ID",
               NULL                                      AS "PROJECT_NUMBER",
               NULL                                      AS "PROJECT_NAME",
               NULL                                      AS "TASK_NUMBER",
               NULL                                      AS "PROJECT_CONTRACT_STATUS",
               NULL                                      AS "REVENUE_PLAN",                
               NULL                                      AS "JOB_NAME",
              --- sold_to.customer_type                     AS "CUSTOMER_ACCOUNT_TYPE",
               NVL(bill_to.customer_type,sold_to.customer_type)   AS "CUSTOMER_ACCOUNT_TYPE",	-- As per Jim we have to look for Bill To customer	03-03-021	  
               NULL                                      AS "REGION",
			   --To handle a situation when contract is created manually and invoice is generated via DOO, in such a case, if the item is a service, then print "Error: Undefined Use Case"
               DECODE (item_details.product_subtype, (	SELECT flv.lookup_code 
														FROM fnd_lookup_values flv
														WHERE flv.lookup_type  = 'GED_SERVICE_ITEM_SUBTYPES'
														AND flv.language     = 'US'
														AND flv.enabled_flag = 'Y'
														AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
														AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
														AND item_details.product_subtype        = flv.lookup_code
														AND ROWNUM = 1),
						'Error: Undefined Use Case', item_details.comments)     AS "COMMENTS",
               nvl(order_details.related_opportunity_number, order_details.opportunity_number) AS "RELATED_OPPORTUNITY_NUMBER",
               NULL                                      AS "BILL_PLAN",
               order_details.opportunity_number          AS "OPPORTUNITY_NUMBER",
               order_details.vsoe_flag                   AS "VSOE_FLAG",
               rec_details.base_currency                 AS "BASE_CURR_CODE",
               bill_to.country                           AS "BILL_TO_COUNTRY",
               bill_to.party_name                        AS "BILL_TO_CUSTOMER_NAME",
               bill_to.account_number                    AS "BILL_TO_CUSTOMER_NUMBER",
               bill_to.cust_account_id                   AS "BILL_TO_CUST_ID",
               bu_details.bu_name                        AS "BUSINESS_UNIT",
               rec_details.created_by                    AS "CREATED_BY",
               rec_details.creation_date                 AS "CREATION_DATE",
               rec_details.pro_creation_date             AS "PRO_CREATION_DATE",
               NULL                                      AS "CUSTOMER_CLASS",
               sold_to.customer_class_code               AS "CUSTOMER_CLASS_CODE",
               sold_to.cust_account_id                   AS "CUSTOMER_ID",
               sold_to.customer_name                     AS "CUSTOMER_NAME",
               rec_details.due_date                      AS "DUE_DATE",
               rec_details.exchange_rate                 AS "EXCHANGE_RATE",
               DECODE(NVL(order_details.unit_list_price,0)
                                            ,0
                                            ,0.99
                                            ,order_details.unit_list_price * DECODE(rec_details.trx_class,'CM', rec_details.quantity_credited, rec_details.quantity_invoiced)
                      )                                  AS "EXT_LIST_PRICE",
               DECODE(rec_details.RECURRING_BILL_FLAG, 'Y', rec_details.extended_amount, rec_details.dist_amount)	AS "EXT_SELL_PRICE",	--print whole amount in case of recurring invoices
               item_details.flag_97_2                    AS "FLAG_97_2",
               rec_details.trx_date                      AS "INVOICE_DATE",
               rec_details.customer_trx_id               AS "INVOICE_ID",
               rec_details.invoice_line                  AS "INVOICE_LINE",
               rec_details.invoice_line_id               AS "INVOICE_LINE_ID",
               rec_details.ar_inv_number                 AS "INVOICE_NUMBER",
               rec_details.trx_type                      AS "INVOICE_TYPE",
               item_details.item_description             AS "ITEM_DESC",
               item_details.inventory_item_id            AS "ITEM_ID",
               item_details.item_number                  AS "ITEM_NUMBER",
               rec_details.last_update_date              AS "LAST_UPDATE_DATE",
               rec_details.last_updated_by               AS "LAST_UPDATED_BY",
               bu_details.legal_entity_id                AS "ORG_ID",
               rec_details.previous_customer_trx_line_id AS "ORIG_INV_LINE_ID",
               item_details.pcs_flag                     AS "PCS_FLAG",
               rec_details.purchase_order                AS "PO_NUM",
               item_details.product_subtype              AS "PRODUCT_CATEGORY",            
               item_details.product_type                 AS "PRODUCT_CLASS",
               item_details.product_family               AS "PRODUCT_FAMILY",
               item_details.product_line                 AS "PRODUCT_LINE",
               rec_details.quantity_invoiced             AS "QUANTITY_INVOICED",
               order_details.ordered_qty                 AS "QUANTITY_ORDERED",
               order_details.quote_number                AS "QUOTE_NUM",
               rec_details.return_flag                   AS "RETURN_FLAG",			   
			   
               CASE
			     -- WHEN (order_details.order_type in ('Intercompany Order') or sold_to.customer_type in ('I','N','W'))
				  WHEN (order_details.order_type in ('Intercompany Order') or NVL(bill_to.customer_type,sold_to.customer_type) in ('I','N','W'))
				  THEN
				  rec_details.trx_date
			   
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC') 
						AND order_details.attribute_date1 IS NOT NULL
						AND NVL(rec_details.recurring_bill_flag, 'N') <> 'Y'
				  THEN
                  order_details.attribute_date1
				  
				  WHEN rec_details.recurring_bill_flag = 'Y'
				  THEN
				  rec_details.trx_date
               END AS "RULE_START_DATE",
			   
               CASE
			      WHEN (order_details.order_type in ('Intercompany Order') or NVL(bill_to.customer_type,sold_to.customer_type) in ('I','N','W'))
				  THEN
				  rec_details.trx_date
			   
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC') 
						AND order_details.attribute_date2 IS NOT NULL
						AND NVL(rec_details.recurring_bill_flag, 'N') <> 'Y'
				  THEN
                  order_details.attribute_date2
				  
				  WHEN rec_details.recurring_bill_flag = 'Y'
				  THEN
				  decode(order_details.periodicity_code
					   ,'DAY'    ,rec_details.trx_date
                       ,'WEEK'   ,rec_details.trx_date + 7
                       ,'MONTH'  ,add_months(rec_details.trx_date,1) - 1
                       ,'QUARTER',add_months(rec_details.trx_date,3) - 1
                       ,'YEAR'   ,add_months(rec_details.trx_date,12) - 1
					   , NULL)					    
               END AS "RULE_END_DATE",			   
               order_details.order_type,
			   --To handle a situation when contract is created manually and invoice is generated via DOO, in such a case, if the item is a service, then do not print SO info
			   DECODE (item_details.product_subtype, (	SELECT flv.lookup_code 
														FROM fnd_lookup_values flv
														WHERE flv.lookup_type  = 'GED_SERVICE_ITEM_SUBTYPES'
														AND flv.language     = 'US'
														AND flv.enabled_flag = 'Y'
														AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
														AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
														AND item_details.product_subtype        = flv.lookup_code
														AND ROWNUM = 1),
						NULL, DECODE(rec_details.trx_class, 'CM', NULL, order_details.order_number)
						)								AS "SALES_ORDER",
			   DECODE (item_details.product_subtype, (	SELECT flv.lookup_code 
														FROM fnd_lookup_values flv
														WHERE flv.lookup_type  = 'GED_SERVICE_ITEM_SUBTYPES'
														AND flv.language     = 'US'
														AND flv.enabled_flag = 'Y'
														AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
														AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
														AND item_details.product_subtype        = flv.lookup_code
														AND ROWNUM = 1),
						NULL, DECODE(rec_details.trx_class, 'CM', NULL, order_details.header_id)
						)								AS "SALES_ORDER_ID",
			   DECODE (item_details.product_subtype, (	SELECT flv.lookup_code 
														FROM fnd_lookup_values flv
														WHERE flv.lookup_type  = 'GED_SERVICE_ITEM_SUBTYPES'
														AND flv.language     = 'US'
														AND flv.enabled_flag = 'Y'
														AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
														AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
														AND item_details.product_subtype        = flv.lookup_code
														AND ROWNUM = 1),
						NULL, DECODE(rec_details.trx_class, 'CM', NULL, order_details.line_number)
						)								AS "SALES_ORDER_LINE",
			   DECODE (item_details.product_subtype, (	SELECT flv.lookup_code 
														FROM fnd_lookup_values flv
														WHERE flv.lookup_type  = 'GED_SERVICE_ITEM_SUBTYPES'
														AND flv.language     = 'US'
														AND flv.enabled_flag = 'Y'
														AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
														AND nvl(flv.end_date_active, SYSDATE)   >= SYSDATE
														AND item_details.product_subtype        = flv.lookup_code
														AND ROWNUM = 1),
						NULL, DECODE(rec_details.trx_class, 'CM', NULL, TO_CHAR(order_details.line_id))
						)								 AS "SALES_ORDER_LINE_ID",
               ship_to.country                           AS "SHIP_TO_COUNTRY",
               ship_to.party_name                        AS "SHIP_TO_CUSTOMER_NAME",
               ship_to.account_number                    AS "SHIP_TO_CUSTOMER_NUMBER",
               rec_details.set_of_books_id               AS "SOB_ID",
               order_details.standalone_flag             AS "STANDALONE_FLAG",
               rec_details.ar_inv_currency               AS "TRANS_CURR_CODE",
               rec_details.trx_currency                  AS "TRX_CURRENCY",
			   --'Y'										 AS "UNBILLED_ACCOUNTING_FLAG",        --GEFCERPRR-48
			   'N'										AS "UNBILLED_ACCOUNTING_FLAG",        --GEFCERPRR-48
               item_details.undelivered_flag              AS "UNDELIVERED_FLAG",
               (order_details.unit_list_price * DECODE(rec_details.trx_class,'CM', -1, 1)) AS "UNIT_LIST_PRICE",
               rec_details.unit_selling_price             AS "UNIT_SELLING_PRICE",
               ROWNUM AS "KEY",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.country
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.country
                    ELSE
                     '000'
               END            AS "COUNTRY",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.province
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.province
                    ELSE
                     '000'
               END            AS "PROVINCE",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.state
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.state
                    ELSE
                     '000'
                END           AS "STATE",
               CASE WHEN rec_details.currency_code = 'USD'  THEN 1
                    WHEN rec_details.currency_code <> 'USD' THEN 
                         (SELECT gdr.conversion_rate
                            FROM gl_daily_rates gdr, gl_daily_conversion_types gdc
                           WHERE gdc.conversion_type      = gdr.conversion_type
                             AND gdr.from_currency        = rec_details.currency_code
                             AND gdr.to_currency          = 'USD'
                             AND gdr.conversion_date      = trunc(rec_details.creation_date)
                             AND gdc.user_conversion_type = 'MOR')
               END                                   AS "RCURR_EX_RATE",
               --rec_details.name                      AS "SOURCE",
               rec_details.line_type                 AS "LINE_TYPE",
               rec_details.ar_line_number            AS "AR_LINE_NUMBER",
               rec_details.dist_amount               AS "DIST_AMOUNT",
               rec_details.acct_dist_amount          AS "ACCT_DIST_AMOUNT",
               ar_posted_to_gl.segment1              AS "SEGMENT1",
               ar_posted_to_gl.segment2              AS "SEGMENT2",
               
			   ar_posted_to_gl.segment3              AS "DEF_SEGMENT3", --REL-027 --28/03/2019
			   NVL(rec_tp.segment3,'0000')           AS "SEGMENT3",   --REL-027 --28/03/2019			   
               ar_posted_to_gl.segment4              AS "SEGMENT4",
               ar_posted_to_gl.segment5              AS "SEGMENT5",
               ar_posted_to_gl.segment6              AS "SEGMENT6",
               ar_posted_to_gl.segment7              AS "SEGMENT7",
               ar_posted_to_gl.segment8              AS "SEGMENT8",
               ar_posted_to_gl.segment9              AS "SEGMENT9",
               ar_posted_to_gl.segment10             AS "SEGMENT10",
               ar_posted_to_gl.segment11             AS "SEGMENT11",
			   rec_details.source_name,
			   NULL									 AS PREVIOUS_INVOICE_NUMBER
          FROM ar_posted_to_gl, 
               rec_details,
               order_details,
               item_details,
               bu_details,
               bill_to,
               ship_to,
               sold_to,
			   rec_tp	--REL-027
         WHERE 1                                         =   1
           AND rec_details.bill_to_site_use_id           =   bill_to.site_use_id(+)
           AND rec_details.ship_to_party_site_use_id     =   ship_to.party_site_use_id(+)
           AND rec_details.sold_to_party_id              =   sold_to.party_id(+)
           AND bu_details.bu_id                          =   rec_details.org_id
           AND rec_details.inventory_item_id             =   item_details.inventory_item_id(+)
           --AND rec_details.line_type                     IN  ('LINE','CB','CHARGES')
           --AND rec_details.interface_line_context      =   'DOO'
		   AND rec_details.source_name                   =   'Distributed Order Orchestration'
           AND rec_details.interface_line_attribute5     =   order_details.fulfill_line_id(+)
           AND ar_posted_to_gl.source_distribution_id_num_1 = rec_details.cust_trx_line_gl_dist_id
		   AND (order_details.order_number = :p_order_number OR :p_order_number IS NULL)
		   AND rec_details.customer_trx_id	= rec_tp.source_id_int_1(+)	--REL-027
UNION ALL
--=====================================Manual (Block 2,4)=======================================================================
        SELECT sold_to.account_number                    AS "CUSTOMER_ACCOUNT_NUMBER",
				CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						'Fusion AR - Project Invoice'
					ELSE
						'Fusion AR - Invoice'
				END										 AS "CUSTOMER_PROFILE_CLASS",
               bill_to.cash_basis_customer               AS "UNBILLED_AR_ACCOUNT",
               NULL                                      AS "PROJECT_CONTRACT_NUMBER",
               NULL                                      AS "PROJECT_CONTRACT_ID",
               NULL                                      AS "PROJECT_NUMBER",
               NULL                                      AS "PROJECT_NAME",
               NULL                                      AS "TASK_NUMBER",
               NULL                                      AS "PROJECT_CONTRACT_STATUS",
               NULL                                      AS "REVENUE_PLAN",
               NULL                                      AS "JOB_NAME",
              --- sold_to.customer_type                     AS "CUSTOMER_ACCOUNT_TYPE",
               NVL(bill_to.customer_type,sold_to.customer_type)   AS "CUSTOMER_ACCOUNT_TYPE",	-- As per Jim we have to look for Bill To customer	03-03-021	
               NULL                                      AS "REGION",
			   CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN --Previous implies CM
						'PPM-CM-GED Manual'
				ELSE
					item_details.comments
				END											AS "COMMENTS",
			   --Print related Opp Num, else print opp num, if no order or contract was found, print the original invoice number or 
			  --else print the invoice number of current record.
			  CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN			--Previous implies CM
						(SELECT NVL(con_proj_detail.attribute5, NVL(con_proj_detail.opportunity_number, con_proj_detail.project_contract_number))
						FROM con_proj_detail
						WHERE TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
						AND TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)
						AND ROWNUM = 1)
				ELSE
					NVL(NVL(order_details.related_opportunity_number, order_details.opportunity_number),
							NVL((SELECT trx_number from ra_customer_trx_all where customer_trx_id = pre_ctl.customer_trx_id),rec_details.ar_inv_number))
				END 									 AS "RELATED_OPPORTUNITY_NUMBER",
               NULL                                      AS "BILL_PLAN",
			  --Print opp num, in case if no order or contract was found, print the original invoice number or 
			  --else print the invoice number of current record.
			  CASE
					--REL-030 Start Invoice Source "Nurego"
					WHEN UPPER(rec_details.source_name)	= 'NUREGO' THEN
						rec_details.interface_line_attribute1
					--REL-030 End Invoice Source "Nurego"
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN			--Previous implies CM
						(SELECT NVL(con_proj_detail.opportunity_number, con_proj_detail.project_contract_number)
						FROM con_proj_detail
						WHERE TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
						AND TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)
						AND ROWNUM = 1)
				ELSE
					NVL(order_details.opportunity_number,
						NVL((SELECT trx_number from ra_customer_trx_all where customer_trx_id = pre_ctl.customer_trx_id),rec_details.ar_inv_number))
				END										 AS "OPPORTUNITY_NUMBER",
               order_details.vsoe_flag                   AS "VSOE_FLAG",
               rec_details.base_currency                 AS "BASE_CURR_CODE",
               bill_to.country                           AS "BILL_TO_COUNTRY",
               bill_to.party_name                        AS "BILL_TO_CUSTOMER_NAME",
               bill_to.account_number                    AS "BILL_TO_CUSTOMER_NUMBER",
               bill_to.cust_account_id                   AS "BILL_TO_CUST_ID",
               bu_details.bu_name                        AS "BUSINESS_UNIT",
               rec_details.created_by                    AS "CREATED_BY",
               rec_details.creation_date                 AS "CREATION_DATE",
               rec_details.pro_creation_date             AS "PRO_CREATION_DATE",
               NULL                                      AS "CUSTOMER_CLASS",
               sold_to.customer_class_code               AS "CUSTOMER_CLASS_CODE",
               sold_to.cust_account_id                   AS "CUSTOMER_ID",
               sold_to.customer_name                     AS "CUSTOMER_NAME",
               rec_details.due_date                      AS "DUE_DATE",
               rec_details.exchange_rate                 AS "EXCHANGE_RATE",
               DECODE(NVL(order_details.unit_list_price,0), 0, 0.99, order_details.unit_list_price * 
					DECODE(rec_details.trx_class, 'CM', rec_details.quantity_credited, rec_details.quantity_invoiced)) AS "EXT_LIST_PRICE",
			   DECODE(rec_details.RECURRING_BILL_FLAG, 'Y', rec_details.extended_amount, rec_details.dist_amount)	AS "EXT_SELL_PRICE",	--print whole amount in case of recurring parent invoices
               item_details.flag_97_2                    AS "FLAG_97_2",
               rec_details.trx_date                      AS "INVOICE_DATE",
               rec_details.customer_trx_id               AS "INVOICE_ID",
               rec_details.invoice_line                  AS "INVOICE_LINE",
               rec_details.invoice_line_id               AS "INVOICE_LINE_ID",
               rec_details.ar_inv_number                 AS "INVOICE_NUMBER",
               CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						rec_details.previous_trx_type
					ELSE
						rec_details.trx_type
				END										 AS "INVOICE_TYPE",
               item_details.item_description             AS "ITEM_DESC",
               item_details.inventory_item_id            AS "ITEM_ID",
               item_details.item_number                  AS "ITEM_NUMBER",
               rec_details.last_update_date              AS "LAST_UPDATE_DATE",
               rec_details.last_updated_by               AS "LAST_UPDATED_BY",
               bu_details.legal_entity_id                AS "ORG_ID",
				CASE
				WHEN NVL(rec_details.previous_source_name, '-1')	NOT IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
					rec_details.previous_customer_trx_line_id
				ELSE
					NULL
				END AS "ORIG_INV_LINE_ID",
			   item_details.pcs_flag                     AS "PCS_FLAG",
               rec_details.purchase_order                AS "PO_NUM",
               item_details.product_subtype              AS "PRODUCT_CATEGORY",            
               item_details.product_type                 AS "PRODUCT_CLASS",
               item_details.product_family               AS "PRODUCT_FAMILY",
               item_details.product_line                 AS "PRODUCT_LINE",
               rec_details.quantity_invoiced             AS "QUANTITY_INVOICED",
               order_details.ordered_qty                 AS "QUANTITY_ORDERED",
               order_details.quote_number                AS "QUOTE_NUM",
			   CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						'N'
					ELSE
						rec_details.return_flag
				END										AS "RETURN_FLAG",
               /* below code commented GEFCERPRR-I-59 Rule start and End date should be blank REL-027--2/26/19
               CASE
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC') 
					AND order_details.attribute_date1 IS NOT NULL
					THEN
                        order_details.attribute_date1
               ELSE
                   rec_details.trx_date
               END                                       AS "RULE_START_DATE",               
               CASE
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC') 
					AND order_details.attribute_date1 IS NOT NULL
					THEN
                        order_details.attribute_date2
               ELSE
                   rec_details.trx_date
               END 										 AS "RULE_END_DATE",
			   -- above code commented GEFCERPRR-I-59 Rule start and End date should be blank REL-027--2/26/19
			   */
			   --Added RULE_START_DATE and RULE_END_DATE for Invoice Source "Nurego" REL-030
			   --NULL AS "RULE_START_DATE",
			   --NULL AS "RULE_END_DATE",
			   CASE
					WHEN UPPER(rec_details.source_name)	= 'NUREGO' THEN
						to_date(rec_details.INTERFACE_LINE_ATTRIBUTE3, 'yyyy/mm/dd')
					ELSE
						NULL
			   END "RULE_START_DATE",
			   CASE
					WHEN UPPER(rec_details.source_name)	= 'NUREGO' THEN
						to_date(rec_details.INTERFACE_LINE_ATTRIBUTE4, 'yyyy/mm/dd')
					ELSE
						NULL
			   END "RULE_END_DATE",
               order_details.order_type,
               DECODE(rec_details.trx_class, 'CM', NULL, order_details.order_number)     AS "SALES_ORDER",
			  CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						(SELECT TO_CHAR(con_proj_detail.project_contract_id)
						FROM con_proj_detail
						WHERE TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
						AND TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)
						AND ROWNUM = 1)
				ELSE
					DECODE(rec_details.trx_class, 'CM', NULL, order_details.header_id)
				END 																	 AS "SALES_ORDER_ID",
               DECODE(rec_details.trx_class, 'CM', NULL, order_details.line_number)      AS "SALES_ORDER_LINE",
			   CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						(SELECT TO_CHAR(con_proj_detail.contract_line_id)
						FROM con_proj_detail
						WHERE TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
						AND TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)
						AND ROWNUM = 1)
				ELSE
					DECODE(rec_details.trx_class, 'CM', NULL, TO_CHAR(order_details.line_id)) 
				END															 AS "SALES_ORDER_LINE_ID",
               ship_to.country                                               AS "SHIP_TO_COUNTRY",
               ship_to.party_name                                            AS "SHIP_TO_CUSTOMER_NAME",
               ship_to.account_number                                        AS "SHIP_TO_CUSTOMER_NUMBER",
               rec_details.set_of_books_id                                   AS "SOB_ID",
               order_details.standalone_flag                                 AS "STANDALONE_FLAG",
               rec_details.ar_inv_currency                                   AS "TRANS_CURR_CODE",
               rec_details.trx_currency                                      AS "TRX_CURRENCY",
			   --'Y'										 				AS "UNBILLED_ACCOUNTING_FLAG",	--GEFCERPRR-48
			   'N'										AS "UNBILLED_ACCOUNTING_FLAG",        --GEFCERPRR-48
               item_details.undelivered_flag             					 AS "UNDELIVERED_FLAG",
               (order_details.unit_list_price * DECODE(rec_details.trx_class,'CM', -1, 1)) AS "UNIT_LIST_PRICE",
               rec_details.unit_selling_price            AS "UNIT_SELLING_PRICE",
               ROWNUM                                    AS "KEY",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.country
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.country
                    ELSE
                     '000'
               END            AS "COUNTRY",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.province
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.province
                    ELSE
                     '000'
               END            AS "PROVINCE",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.state
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.state
                    ELSE
                     '000'
                END           AS "STATE",
               CASE WHEN rec_details.currency_code = 'USD'  THEN 1
                    WHEN rec_details.currency_code <> 'USD' THEN 
                         (SELECT gdr.conversion_rate
                            FROM gl_daily_rates gdr, gl_daily_conversion_types gdc
                           WHERE gdc.conversion_type      = gdr.conversion_type
                             AND gdr.from_currency        = rec_details.currency_code
                             AND gdr.to_currency          = 'USD'
                             AND gdr.conversion_date      = trunc(rec_details.creation_date)
                             AND gdc.user_conversion_type = 'MOR')
               END                                       AS "RCURR_EX_RATE",
               --rec_details.name                          AS "SOURCE",
               rec_details.line_type                     AS "LINE_TYPE",
               rec_details.ar_line_number                AS "AR_LINE_NUMBER",
               rec_details.dist_amount                   AS "DIST_AMOUNT",
               rec_details.acct_dist_amount              AS "ACCT_DIST_AMOUNT",
               ar_posted_to_gl.segment1                  AS "SEGMENT1",
               ar_posted_to_gl.segment2                  AS "SEGMENT2",
			   
			   ar_posted_to_gl.segment3              AS "DEF_SEGMENT3", --REL-027 --28/03/2019
			   NVL(rec_tp.segment3,'0000')             AS "SEGMENT3",   --REL-027 --28/03/2019
			   
               ar_posted_to_gl.segment4                  AS "SEGMENT4",
               ar_posted_to_gl.segment5                  AS "SEGMENT5",
               ar_posted_to_gl.segment6                  AS "SEGMENT6",
               ar_posted_to_gl.segment7                  AS "SEGMENT7",
               ar_posted_to_gl.segment8                  AS "SEGMENT8",
               ar_posted_to_gl.segment9                  AS "SEGMENT9",
               ar_posted_to_gl.segment10                 AS "SEGMENT10",
               ar_posted_to_gl.segment11                 AS "SEGMENT11",
               rec_details.source_name,
			   (SELECT trx_number from ra_customer_trx_all where customer_trx_id = pre_ctl.customer_trx_id) AS PREVIOUS_INVOICE_NUMBER
          FROM ar_posted_to_gl,
               rec_details,
               order_details,
               item_details,
               bu_details,
               bill_to,
               ship_to,
               sold_to,
               ra_customer_trx_lines_all pre_ctl,
			   rec_tp	--REL-027
         WHERE 1                                           = 1
           AND bu_details.bu_id                            = rec_details.org_id
           AND rec_details.bill_to_site_use_id             = bill_to.site_use_id(+)
           AND rec_details.ship_to_party_site_use_id       = ship_to.party_site_use_id(+)
           AND rec_details.sold_to_party_id                = sold_to.party_id(+)
		   --AND UPPER(rec_details.source_name)			   = UPPER('GED Manual')         --Code Commented REL-030
		   AND UPPER(rec_details.source_name)			   IN ('GED MANUAL', 'NUREGO')   --New Source Nurego added REL-030
           AND rec_details.inventory_item_id               = item_details.inventory_item_id(+)
           AND rec_details.previous_customer_trx_line_id   = pre_ctl.customer_trx_line_id(+)
           AND pre_ctl.interface_line_attribute5           = order_details.fulfill_line_id(+)
           AND ar_posted_to_gl.source_distribution_id_num_1 = rec_details.cust_trx_line_gl_dist_id
		   AND (order_details.order_number = :p_order_number OR :p_order_number IS NULL)
		   AND rec_details.customer_trx_id	= rec_tp.source_id_int_1(+)	--REL-027
UNION ALL
--======================================Project/Contract=========================================================================
        SELECT sold_to.account_number                    AS "CUSTOMER_ACCOUNT_NUMBER",
               'Fusion AR - Project Invoice'             AS "CUSTOMER_PROFILE_CLASS",
               bill_to.cash_basis_customer               AS "UNBILLED_AR_ACCOUNT",
               con_proj_detail.project_contract_number   AS "PROJECT_CONTRACT_NUMBER",
               con_proj_detail.project_contract_id       AS "PROJECT_CONTRACT_ID",
               con_proj_detail.project_number            AS "PROJECT_NUMBER",
               con_proj_detail.project_name              AS "PROJECT_NAME",
               con_proj_detail.task_number               AS "TASK_NUMBER",
               con_proj_detail.project_contract_status   AS "PROJECT_CONTRACT_STATUS",
               con_proj_detail.revenue_plan_method_name  AS "REVENUE_PLAN",                
               con_proj_detail.job_name                  AS "JOB_NAME",
              --- sold_to.customer_type                     AS "CUSTOMER_ACCOUNT_TYPE",
               NVL(bill_to.customer_type,sold_to.customer_type)   AS "CUSTOMER_ACCOUNT_TYPE",	-- As per Jim we have to look for Bill To customer	03-03-021	   
               NULL                                      AS "REGION",
               item_details.comments                     AS "COMMENTS",
               NVL(con_proj_detail.attribute5, NVL(con_proj_detail.opportunity_number, NVL(order_details.opportunity_number, con_proj_detail.project_contract_number))) AS "RELATED_OPPORTUNITY_NUMBER",
               con_proj_detail.bill_plan_method_name     AS "BILL_PLAN",
               NVL(con_proj_detail.opportunity_number, NVL(order_details.opportunity_number, con_proj_detail.project_contract_number))	AS "OPPORTUNITY_NUMBER",
               order_details.vsoe_flag                   AS "VSOE_FLAG",
               rec_details.base_currency                 AS "BASE_CURR_CODE",
               bill_to.country                           AS "BILL_TO_COUNTRY",
               bill_to.party_name                        AS "BILL_TO_CUSTOMER_NAME",
               bill_to.account_number                    AS "BILL_TO_CUSTOMER_NUMBER",
               bill_to.cust_account_id                   AS "BILL_TO_CUST_ID",
               bu_details.bu_name                        AS "BUSINESS_UNIT",
               rec_details.created_by                    AS "CREATED_BY",
               rec_details.creation_date                 AS "CREATION_DATE",
               rec_details.pro_creation_date             AS "PRO_CREATION_DATE",
               con_proj_detail.customer_class            AS "CUSTOMER_CLASS",
               sold_to.customer_class_code               AS "CUSTOMER_CLASS_CODE",
               sold_to.cust_account_id                   AS "CUSTOMER_ID",
               sold_to.customer_name                     AS "CUSTOMER_NAME",
               rec_details.due_date                      AS "DUE_DATE",
               rec_details.exchange_rate                 AS "EXCHANGE_RATE",
               DECODE(NVL(order_details.unit_list_price,0)
                                            ,0
                                            ,0.99
                                            ,order_details.unit_list_price * DECODE(rec_details.trx_class,'CM', rec_details.quantity_credited, rec_details.quantity_invoiced)
                      )                                  AS "EXT_LIST_PRICE",
			   
              -- rec_details.dist_amount                   AS "EXT_SELL_PRICE",
               con_proj_detail.project_inv_amount         AS "EXT_SELL_PRICE",
               item_details.flag_97_2                    AS "FLAG_97_2",
               rec_details.trx_date                      AS "INVOICE_DATE",
               rec_details.customer_trx_id               AS "INVOICE_ID",
               rec_details.invoice_line                  AS "INVOICE_LINE",
			   rec_details.invoice_line_id||'-'||con_proj_detail.pild_invoice_dist_id AS "INVOICE_LINE_ID",
               rec_details.ar_inv_number                 AS "INVOICE_NUMBER",
               rec_details.trx_type                      AS "INVOICE_TYPE",
               item_details.item_description             AS "ITEM_DESC",
               item_details.inventory_item_id            AS "ITEM_ID",
               item_details.item_number                  AS "ITEM_NUMBER",
               rec_details.pro_last_update_date          AS "LAST_UPDATE_DATE",
               rec_details.last_updated_by               AS "LAST_UPDATED_BY",
               bu_details.legal_entity_id                AS "ORG_ID",
               DECODE(rec_details.trx_class, 'CM', rec_details.previous_customer_trx_line_id||'-'||con_proj_detail.credited_dist_id, NULL) AS "ORIG_INV_LINE_ID",
               item_details.pcs_flag                     AS "PCS_FLAG",
               rec_details.purchase_order                AS "PO_NUM",
               item_details.product_subtype              AS "PRODUCT_CATEGORY",
               item_details.product_type                 AS "PRODUCT_CLASS",
               item_details.product_family               AS "PRODUCT_FAMILY",
               item_details.product_line                 AS "PRODUCT_LINE",
               rec_details.quantity_invoiced             AS "QUANTITY_INVOICED",
               order_details.ordered_qty                 AS "QUANTITY_ORDERED",
               con_proj_detail.attribute3                AS "QUOTE_NUM",
               rec_details.return_flag                   AS "RETURN_FLAG",
			   CASE
					WHEN (order_details.order_type in ('Intercompany Order') or NVL(bill_to.customer_type,sold_to.customer_type) in ('I','N','W'))
					THEN
						rec_details.trx_date
				  
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC')
				  THEN
						con_proj_detail.start_date
					
					ELSE
						rec_details.trx_date
				END 									 AS "RULE_START_DATE",
				CASE
					WHEN (order_details.order_type in ('Intercompany Order') or NVL(bill_to.customer_type,sold_to.customer_type) in ('I','N','W'))
					THEN
						rec_details.trx_date
					
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC')
				  THEN
						con_proj_detail.end_date
					
					ELSE
						rec_details.trx_date
				END 									AS "RULE_END_DATE",
               order_details.order_type,
               DECODE(rec_details.trx_class, 'CM', NULL, order_details.order_number)                AS "SALES_ORDER",
               DECODE(rec_details.trx_class, 'CM', NULL, TO_CHAR(con_proj_detail.project_contract_id))       AS "SALES_ORDER_ID",
               DECODE(rec_details.trx_class, 'CM', NULL, order_details.line_number)                 AS "SALES_ORDER_LINE",
               DECODE(rec_details.trx_class, 'CM', NULL, TO_CHAR(con_proj_detail.contract_line_id)) AS "SALES_ORDER_LINE_ID",
               ship_to.country                           AS "SHIP_TO_COUNTRY",
               ship_to.party_name                        AS "SHIP_TO_CUSTOMER_NAME",
               ship_to.account_number                    AS "SHIP_TO_CUSTOMER_NUMBER",
               rec_details.set_of_books_id               AS "SOB_ID",
               order_details.standalone_flag             AS "STANDALONE_FLAG",
               rec_details.ar_inv_currency               AS "TRANS_CURR_CODE",
               rec_details.trx_currency                  AS "TRX_CURRENCY",
			   --'Y'										 AS "UNBILLED_ACCOUNTING_FLAG",	--GEFCERPRR-48
				'N'										 AS "UNBILLED_ACCOUNTING_FLAG",		--GEFCERPRR-48			   
               item_details.undelivered_flag              AS "UNDELIVERED_FLAG",
               (order_details.unit_list_price * DECODE(rec_details.trx_class,'CM', -1, 1)) AS "UNIT_LIST_PRICE",
               rec_details.unit_selling_price             AS "UNIT_SELLING_PRICE",
               ROWNUM AS "KEY",
               CASE
                        WHEN ship_to.country IS NOT NULL THEN
                         ship_to.country
                        WHEN bill_to.country IS NOT NULL THEN
                         bill_to.country
                        ELSE
                         '000'
                   END              AS "COUNTRY",
                   CASE
                        WHEN ship_to.country IS NOT NULL THEN
                         ship_to.province
                        WHEN bill_to.country IS NOT NULL THEN
                         bill_to.province
                        ELSE
                         '000'
                   END            AS "PROVINCE",
                   CASE
                        WHEN ship_to.country IS NOT NULL THEN
                         ship_to.state
                        WHEN bill_to.country IS NOT NULL THEN
                         bill_to.state
                        ELSE
                         '000'
                    END          AS "STATE",
               CASE WHEN rec_details.currency_code = 'USD'  THEN 1
                    WHEN rec_details.currency_code <> 'USD' THEN 
                         (SELECT gdr.conversion_rate
                            FROM gl_daily_rates gdr, gl_daily_conversion_types gdc
                           WHERE gdc.conversion_type      = gdr.conversion_type
                             AND gdr.from_currency        = rec_details.currency_code
                             AND gdr.to_currency          = 'USD'
                             AND gdr.conversion_date      = TRUNC(rec_details.pro_creation_date)
                             AND gdc.user_conversion_type = 'MOR')
               END                                 AS "RCURR_EX_RATE",
               --rec_details.name                    AS "SOURCE",
               rec_details.line_type               AS "LINE_TYPE",
               rec_details.ar_line_number          AS "AR_LINE_NUMBER",
               --rec_details.dist_amount             AS "DIST_AMOUNT",
			   con_proj_detail.project_inv_amount  AS "DIST_AMOUNT",
               rec_details.acct_dist_amount        AS "ACCT_DIST_AMOUNT",
               ar_posted_to_gl.segment1            AS "SEGMENT1",
               ar_posted_to_gl.segment2            AS "SEGMENT2",
			   
			   ar_posted_to_gl.segment3              AS "DEF_SEGMENT3", --REL-027 --28/03/2019
			   NVL(rec_tp.segment3,'0000')           AS "SEGMENT3",   --REL-027 --28/03/2019			   
			   
               ar_posted_to_gl.segment4            AS "SEGMENT4",
               ar_posted_to_gl.segment5            AS "SEGMENT5",
               ar_posted_to_gl.segment6            AS "SEGMENT6",
               ar_posted_to_gl.segment7            AS "SEGMENT7",
               ar_posted_to_gl.segment8            AS "SEGMENT8",
               ar_posted_to_gl.segment9            AS "SEGMENT9",
               ar_posted_to_gl.segment10           AS "SEGMENT10",
               ar_posted_to_gl.segment11           AS "SEGMENT11",
               rec_details.source_name,
			   NULL AS PREVIOUS_INVOICE_NUMBER
          FROM ar_posted_to_gl, 
               rec_details,
               order_details,
               item_details,
               bu_details,
               bill_to,
               ship_to,
               sold_to,
               con_proj_detail,
               ra_customer_trx_lines_all pre_ctl,
			   rec_tp --REL-027
         WHERE rec_details.bill_to_site_use_id             =  bill_to.site_use_id(+)
           AND rec_details.ship_to_party_site_use_id       =  ship_to.party_site_use_id(+)
           AND rec_details.sold_to_party_id                =  sold_to.party_id(+)
           AND bu_details.bu_id                            =  rec_details.org_id
           AND rec_details.source_name  IN ('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES')	   
           AND TO_NUMBER(NVL(TRIM(rec_details.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
           AND TO_NUMBER(NVL(TRIM(rec_details.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)      
           AND TRIM(con_proj_detail.order_number)          =  TO_CHAR(order_details.order_number(+))
           AND TRIM(con_proj_detail.order_line_number)     =  TO_CHAR(order_details.line_number(+))
		   AND con_proj_detail.INVENTORY_ITEM_ID 		   = item_details.inventory_item_id(+)
           AND rec_details.previous_customer_trx_line_id   =  pre_ctl.customer_trx_line_id(+)
           AND ar_posted_to_gl.source_distribution_id_num_1 = rec_details.cust_trx_line_gl_dist_id
		   AND (order_details.order_number = :p_order_number OR :p_order_number IS NULL)
		   AND (con_proj_detail.project_contract_number = :p_contract_number OR :p_contract_number IS NULL)
		   AND rec_details.customer_trx_id	= rec_tp.source_id_int_1(+)	--REL-027
/*UNION ALL
--==================================Query Starts===-REL-027 2/6/19 Nitin Bhatt Added Rebill source========================================
        SELECT sold_to.account_number                    AS "CUSTOMER_ACCOUNT_NUMBER",
				CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						'Fusion AR - Project Invoice'
					ELSE
						'Fusion AR - Invoice'
				END										 AS "CUSTOMER_PROFILE_CLASS",
               bill_to.cash_basis_customer               AS "UNBILLED_AR_ACCOUNT",
               NULL                                      AS "PROJECT_CONTRACT_NUMBER",
               NULL                                      AS "PROJECT_CONTRACT_ID",
               NULL                                      AS "PROJECT_NUMBER",
               NULL                                      AS "PROJECT_NAME",
               NULL                                      AS "TASK_NUMBER",
               NULL                                      AS "PROJECT_CONTRACT_STATUS",
               NULL                                      AS "REVENUE_PLAN",
               NULL                                      AS "JOB_NAME",
               sold_to.customer_type                     AS "CUSTOMER_ACCOUNT_TYPE",
               NULL                                      AS "REGION",
			   NVL(pre_ctl.interface_line_attribute5, rec_details.interface_line_attribute5)	AS "COMMENTS",
			   --Print related Opp Num, else print opp num, if no order or contract was found, print the original invoice number or 
			  --else print the invoice number of current record.
			  CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN			--Previous implies CM
						(SELECT NVL(con_proj_detail.attribute5, NVL(con_proj_detail.opportunity_number, con_proj_detail.project_contract_number))
						FROM con_proj_detail
						WHERE TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
						AND TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)
						AND ROWNUM = 1)
				ELSE
					NVL(NVL(order_details.related_opportunity_number, order_details.opportunity_number),
							NVL((SELECT trx_number from ra_customer_trx_all where customer_trx_id = pre_ctl.customer_trx_id),rec_details.ar_inv_number))
				END 									 AS "RELATED_OPPORTUNITY_NUMBER",
               NULL                                      AS "BILL_PLAN",
			  --Print opp num, in case if no order or contract was found, print the original invoice number or 
			  --else print the invoice number of current record.
			  CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN			--Previous implies CM
						(SELECT NVL(con_proj_detail.opportunity_number, con_proj_detail.project_contract_number)
						FROM con_proj_detail
						WHERE TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute5),0)) = con_proj_detail.invoice_line_id(+)
						AND TO_NUMBER(NVL(TRIM(pre_ctl.interface_line_attribute2),0)) = con_proj_detail.contract_id(+)
						AND ROWNUM = 1)
				ELSE
					NVL(order_details.opportunity_number,
						NVL((SELECT trx_number from ra_customer_trx_all where customer_trx_id = pre_ctl.customer_trx_id),rec_details.ar_inv_number))
				END										 AS "OPPORTUNITY_NUMBER",
               order_details.vsoe_flag                   AS "VSOE_FLAG",
               rec_details.base_currency                 AS "BASE_CURR_CODE",
               bill_to.country                           AS "BILL_TO_COUNTRY",
               bill_to.party_name                        AS "BILL_TO_CUSTOMER_NAME",
               bill_to.account_number                    AS "BILL_TO_CUSTOMER_NUMBER",
               bill_to.cust_account_id                   AS "BILL_TO_CUST_ID",
               bu_details.bu_name                        AS "BUSINESS_UNIT",
               rec_details.created_by                    AS "CREATED_BY",
               rec_details.creation_date                 AS "CREATION_DATE",
               rec_details.pro_creation_date             AS "PRO_CREATION_DATE",
               NULL                                      AS "CUSTOMER_CLASS",
               sold_to.customer_class_code               AS "CUSTOMER_CLASS_CODE",
               sold_to.cust_account_id                   AS "CUSTOMER_ID",
               sold_to.customer_name                     AS "CUSTOMER_NAME",
               rec_details.due_date                      AS "DUE_DATE",
               rec_details.exchange_rate                 AS "EXCHANGE_RATE",
               DECODE(NVL(order_details.unit_list_price,0), 0, 0.99, order_details.unit_list_price * 
					DECODE(rec_details.trx_class, 'CM', rec_details.quantity_credited, rec_details.quantity_invoiced)) AS "EXT_LIST_PRICE",
			   DECODE(rec_details.RECURRING_BILL_FLAG, 'Y', rec_details.extended_amount, rec_details.dist_amount)	AS "EXT_SELL_PRICE",	--print whole amount in case of recurring parent invoices
               item_details.flag_97_2                    AS "FLAG_97_2",
               rec_details.trx_date                      AS "INVOICE_DATE",
               rec_details.customer_trx_id               AS "INVOICE_ID",
               rec_details.invoice_line                  AS "INVOICE_LINE",
               rec_details.invoice_line_id               AS "INVOICE_LINE_ID",
               rec_details.ar_inv_number                 AS "INVOICE_NUMBER",
               CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						rec_details.previous_trx_type
					ELSE
						rec_details.trx_type
				END									     AS "INVOICE_TYPE",
               item_details.item_description             AS "ITEM_DESC",
               item_details.inventory_item_id            AS "ITEM_ID",
               item_details.item_number                  AS "ITEM_NUMBER",
               rec_details.last_update_date              AS "LAST_UPDATE_DATE",
               rec_details.last_updated_by               AS "LAST_UPDATED_BY",
               bu_details.legal_entity_id                AS "ORG_ID",
			   NULL                                      AS "ORIG_INV_LINE_ID",
			   item_details.pcs_flag                     AS "PCS_FLAG",
               rec_details.purchase_order                AS "PO_NUM",
               item_details.product_subtype              AS "PRODUCT_CATEGORY",            
               item_details.product_type                 AS "PRODUCT_CLASS",
               item_details.product_family               AS "PRODUCT_FAMILY",
               item_details.product_line                 AS "PRODUCT_LINE",
               rec_details.quantity_invoiced             AS "QUANTITY_INVOICED",
               order_details.ordered_qty                 AS "QUANTITY_ORDERED",
               order_details.quote_number                AS "QUOTE_NUM",
			   CASE
					WHEN NVL(rec_details.previous_source_name, '-1')	IN	('CONTRACT INVOICES','CONTRACT INTERNAL INVOICES') THEN
						'N'
					ELSE
						rec_details.return_flag
				END										AS "RETURN_FLAG",
			   
				CASE
			      WHEN (order_details.order_type in ('Intercompany Order') or sold_to.customer_type in ('I','N','W'))
				  THEN
				  rec_details.trx_date
			   
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC') 
						AND order_details.attribute_date1 IS NOT NULL
						AND NVL(rec_details.rebill_recurring_bill_flag, 'N') <> 'Y'
				  THEN
                  order_details.attribute_date1
				  
				  WHEN rec_details.rebill_recurring_bill_flag = 'Y'
				  THEN
				  rec_details.rebill_trx_date
               END AS "RULE_START_DATE",
			   
               CASE
			      WHEN (order_details.order_type in ('Intercompany Order') or sold_to.customer_type in ('I','N','W'))
				  THEN
				  rec_details.trx_date
			   
                  WHEN (item_details.product_type IN ('SUB', 'SUP') OR item_details.product_subtype = 'MNGDSVC') 
						AND order_details.attribute_date2 IS NOT NULL
						AND NVL(rec_details.rebill_recurring_bill_flag, 'N') <> 'Y'
				  THEN
						order_details.attribute_date2
				  
				  WHEN rec_details.rebill_recurring_bill_flag = 'Y'
				  THEN
				  decode(order_details.periodicity_code
					   ,'DAY'    ,rec_details.rebill_trx_date
                       ,'WEEK'   ,rec_details.rebill_trx_date + 7
                       ,'MONTH'  ,add_months(rec_details.rebill_trx_date,1) - 1
                       ,'QUARTER',add_months(rec_details.rebill_trx_date,3) - 1
                       ,'YEAR'   ,add_months(rec_details.rebill_trx_date,12) - 1
					   , NULL)					    
               END AS "RULE_END_DATE",
			   
               order_details.order_type,
			   NULL AS "SALES_ORDER",
			   NULL AS "SALES_ORDER_ID",
               NULL AS "SALES_ORDER_LINE",
			   NULL AS "SALES_ORDER_LINE_ID",
               ship_to.country                                               AS "SHIP_TO_COUNTRY",
               ship_to.party_name                                            AS "SHIP_TO_CUSTOMER_NAME",
               ship_to.account_number                                        AS "SHIP_TO_CUSTOMER_NUMBER",
               rec_details.set_of_books_id                                   AS "SOB_ID",
               order_details.standalone_flag                                 AS "STANDALONE_FLAG",
               rec_details.ar_inv_currency                                   AS "TRANS_CURR_CODE",
               rec_details.trx_currency                                      AS "TRX_CURRENCY",
			   --'Y'										 				AS "UNBILLED_ACCOUNTING_FLAG",	--GEFCERPRR-48
			   'N'										AS "UNBILLED_ACCOUNTING_FLAG",        --GEFCERPRR-48
               item_details.undelivered_flag             					 AS "UNDELIVERED_FLAG",
               (order_details.unit_list_price * DECODE(rec_details.trx_class,'CM', -1, 1)) AS "UNIT_LIST_PRICE",
               rec_details.unit_selling_price            AS "UNIT_SELLING_PRICE",
               ROWNUM                                    AS "KEY",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.country
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.country
                    ELSE
                     '000'
               END            AS "COUNTRY",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.province
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.province
                    ELSE
                     '000'
               END            AS "PROVINCE",
               CASE
                    WHEN ship_to.country IS NOT NULL THEN
                     ship_to.state
                    WHEN bill_to.country IS NOT NULL THEN
                     bill_to.state
                    ELSE
                     '000'
                END           AS "STATE",
               CASE WHEN rec_details.currency_code = 'USD'  THEN 1
                    WHEN rec_details.currency_code <> 'USD' THEN 
                         (SELECT gdr.conversion_rate
                            FROM gl_daily_rates gdr, gl_daily_conversion_types gdc
                           WHERE gdc.conversion_type      = gdr.conversion_type
                             AND gdr.from_currency        = rec_details.currency_code
                             AND gdr.to_currency          = 'USD'
                             AND gdr.conversion_date      = trunc(rec_details.creation_date)
                             AND gdc.user_conversion_type = 'MOR')
               END                                       AS "RCURR_EX_RATE",
               --rec_details.name                          AS "SOURCE",
               rec_details.line_type                     AS "LINE_TYPE",
               rec_details.ar_line_number                AS "AR_LINE_NUMBER",
               rec_details.dist_amount                   AS "DIST_AMOUNT",
               rec_details.acct_dist_amount              AS "ACCT_DIST_AMOUNT",
               ar_posted_to_gl.segment1                  AS "SEGMENT1",
               ar_posted_to_gl.segment2                  AS "SEGMENT2",
			   
			   ar_posted_to_gl.segment3              AS "DEF_SEGMENT3", --REL-027 --28/03/2019
			   rec_tp.segment3                      AS "SEGMENT3",   --REL-027 --28/03/2019
			   
               ar_posted_to_gl.segment4                  AS "SEGMENT4",
               ar_posted_to_gl.segment5                  AS "SEGMENT5",
               ar_posted_to_gl.segment6                  AS "SEGMENT6",
               ar_posted_to_gl.segment7                  AS "SEGMENT7",
               ar_posted_to_gl.segment8                  AS "SEGMENT8",
               ar_posted_to_gl.segment9                  AS "SEGMENT9",
               ar_posted_to_gl.segment10                 AS "SEGMENT10",
               ar_posted_to_gl.segment11                 AS "SEGMENT11",
               rec_details.source_name,
			   (SELECT trx_number from ra_customer_trx_all where customer_trx_id = pre_ctl.customer_trx_id) AS PREVIOUS_INVOICE_NUMBER
          FROM ar_posted_to_gl,
               rec_details,
               order_details,
               item_details,
               bu_details,
               bill_to,
               ship_to,
               sold_to,
               ra_customer_trx_lines_all pre_ctl,
			   rec_tp	--REL-027
         WHERE 1                                           = 1
           AND bu_details.bu_id                            = rec_details.org_id
           AND rec_details.bill_to_site_use_id             = bill_to.site_use_id(+)
           AND rec_details.ship_to_party_site_use_id       = ship_to.party_site_use_id(+)
           AND rec_details.sold_to_party_id                = sold_to.party_id(+)
		   AND UPPER(rec_details.source_name)			   = UPPER('Rebill')
           AND rec_details.inventory_item_id               = item_details.inventory_item_id(+)
           AND rec_details.previous_customer_trx_line_id   = pre_ctl.customer_trx_line_id(+)
           AND NVL(pre_ctl.interface_line_attribute5, rec_details.interface_line_attribute5)           = order_details.fulfill_line_id(+)
           AND ar_posted_to_gl.source_distribution_id_num_1 = rec_details.cust_trx_line_gl_dist_id
		   AND (order_details.order_number = :p_order_number OR :p_order_number IS NULL)
		   AND rec_details.customer_trx_id	= rec_tp.source_id_int_1	--REL-027
--==================================Query Ends===-REL-027 2/6/19 Nitin Bhatt Added Rebill source==================================
*/
)ct