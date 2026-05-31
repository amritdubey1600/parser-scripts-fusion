--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                    Author               Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-ARR				   TCS(Shubhajit)		25-Sep-2024	   		REL-ARR same as REL-099 as per QA/Audit Compliance
--#																	Change the ADN code for Subscription and Intercompany Adn enablement
--#-----------------------------------------------------------------------------------------------------#
SELECT 'I22' record_key_i22,
	RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                            from  OKC_K_HEADERS_ALL_B C,
												      PJB_CNTRCT_PROJ_LINKS A , 
													  PJF_PROJECTS_ALL_B B 
                                                where A.project_id= b.Project_id
												      and A.contract_id= C.id
													  and c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													  and c.attribute8 is not null
												      and rct.interface_header_attribute1=c.contract_number),
							    'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
																	  FROM doo_headers_all a,
																		   doo_lines_all b,
																		   doo_fulfill_lines_all c,
																		   DOO_FULFILL_LINES_EFF_B dlfeb
																	 WHERE a.header_id=b.header_id
																	   AND b.line_id=c.line_id
																	   AND c.fulfill_line_id=dlfeb.fulfill_line_id
																	   --AND rctla.INTERFACE_LINE_ATTRIBUTE3= a.ORDER_NUMBER
																	   AND a.status_code not like 'DOO_REFERENCE'
																	   AND TO_CHAR (c.fulfill_line_id) =RCTLA.INTERFACE_LINE_ATTRIBUTE5
																	   AND ROWNUM<2
																	   --AND dlfeb.CONTEXT_CODE='GED Fline Context'
																	  -- AND RCTLA.INTERFACE_LINE_ATTRIBUTE1 = a.SOURCE_ORDER_NUMBER
																	  -- AND RCTLA.INTERFACE_LINE_ATTRIBUTE2 =a.SOURCE_ORDER_SYSTEM
																	   AND dlfeb.attribute_char2 IS NOT NULL),
								'ORACLE DOO INTEGRATED SUBSCRIPTIONS',(CASE WHEN rctla.attribute7 IS NULL 							--REL-ARR Added for subscription enablement - Start
															   THEN (SELECT dfleb.ATTRIBUTE_CHAR2
																		FROM  doo_fulfill_lines_eff_b dfleb,
																			  doo_fulfill_lines_all dfla,
																			  HR_OPERATING_UNITS hou, 
																				FND_LOOKUP_VALUES_VL flv
																		WHERE 1 = 1
																		AND dfla.fulfill_line_id =rctla.INTERFACE_LINE_ATTRIBUTE5
																		AND dfla.fulfill_line_id = dfleb.fulfill_line_id(+)
																		AND dfleb.context_code(+) = 'GED Fline Context'
																		AND hou.organization_id = rctla.org_id 
																		AND flv.meaning = hou.name
																		AND flv.lookup_type = 'GED_BU_NAMES'
																		AND flv.description = 'DIG' --in ('DIG','DIGAVN')
																		AND flv.enabled_flag = 'Y'
																		AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))
																		AND rownum <2)
																ELSE rctla.attribute7 END),						--REL-ARR Added for subscription enablement - End
				   'GEV ES INTERCOMPANY',(CASE WHEN rctla.attribute7 IS NULL 											--REL-ARR Added for Intercompany enablement - Start
											   THEN (SELECT NVL(rctla.attribute7,dfleb2.ATTRIBUTE_CHAR5)
														FROM  ra_customer_trx_all rcta_parent,
															  ra_customer_trx_lines_all rctla_parent,
															  ra_batch_sources_all rbs,
															  doo_fulfill_lines_eff_b dfleb2,
															  doo_fulfill_lines_all dfla,
															  HR_OPERATING_UNITS hou, 
																FND_LOOKUP_VALUES_VL flv
														WHERE 1=1  
														AND rctla.INTERFACE_LINE_CONTEXT ='CCLAR'  
														AND rctla.ATTRIBUTE_CATEGORY = 'CCLAR'
														AND rctla.INTERFACE_LINE_ATTRIBUTE2 = rcta_parent.TRX_NUMBER
														AND rctla.INTERFACE_LINE_ATTRIBUTE3  = rctla_parent.line_number
														AND rcta_parent.customer_trx_id = rctla_parent.customer_trx_id
														AND rctla_parent.INTERFACE_LINE_ATTRIBUTE5 = dfla.fulfill_line_id
														AND dfla.fulfill_line_id = dfleb2.fulfill_line_id(+)
														AND dfleb2.context_code(+) = 'GED FLine Context 2'
														AND hou.organization_id = rctla.org_id 
														AND flv.meaning = hou.name
														AND flv.lookup_type = 'GED_BU_NAMES'
														AND flv.description = 'DIG'
														AND flv.enabled_flag = 'Y'
														AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))
														AND rownum <2)
											   ELSE rctla.attribute7 END),					--REL-ARR Added for Intercompany enablement - End
					NVL(UPPER(rctla.attribute7),' ')),75) adn, 
	 rctla.customer_trx_id
FROM RA_CUSTOMER_TRX_LINES_ALL rctla,
     RA_CUSTOMER_TRX_ALL rct,
	 RA_BATCH_SOURCES_ALL rbs
WHERE 1=1
AND   rct.customer_trx_id=rctla.customer_trx_id
AND   rct.batch_source_seq_id=rbs.batch_source_seq_id
and    (
(trim(rct.purchase_order) is null)
OR
(
(trim(rct.purchase_order) is not null) AND
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                            from  OKC_K_HEADERS_ALL_B C,
												      PJB_CNTRCT_PROJ_LINKS A , 
													  PJF_PROJECTS_ALL_B B 
                                                where A.project_id= b.Project_id
												      and A.contract_id= C.id
													  and c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													  and c.attribute8 is not null
												      and rct.interface_header_attribute1=c.contract_number),
									'DISTRIBUTED ORDER ORCHESTRATION',(select dlfeb.attribute_char2
																		  FROM doo_headers_all a,
																			   doo_lines_all b,
																			   doo_fulfill_lines_all c,
																			   DOO_FULFILL_LINES_EFF_B dlfeb
																		 WHERE a.header_id=b.header_id
																		   AND b.line_id=c.line_id
																		   AND c.fulfill_line_id=dlfeb.fulfill_line_id
																		  -- AND rctla.INTERFACE_LINE_ATTRIBUTE3= a.ORDER_NUMBER
																		   AND a.status_code not like 'DOO_REFERENCE'
																		   AND TO_CHAR (c.fulfill_line_id) =RCTLA.INTERFACE_LINE_ATTRIBUTE5
																		   AND ROWNUM<2
																		  -- AND dlfeb.CONTEXT_CODE='GED Fline Context'
																		   --AND RCTLA.INTERFACE_LINE_ATTRIBUTE1 = a.SOURCE_ORDER_NUMBER
																		   --AND RCTLA.INTERFACE_LINE_ATTRIBUTE2 =a.SOURCE_ORDER_SYSTEM
																		   AND dlfeb.attribute_char2 IS NOT NULL),
									'ORACLE DOO INTEGRATED SUBSCRIPTIONS',(CASE WHEN rctla.attribute7 IS NULL 							--REL-ARR Added for subscription enablement - Start
															   THEN (SELECT dfleb.ATTRIBUTE_CHAR2
																		FROM  doo_fulfill_lines_eff_b dfleb,
																			  doo_fulfill_lines_all dfla,
																			  HR_OPERATING_UNITS hou, 
																				FND_LOOKUP_VALUES_VL flv
																		WHERE 1 = 1
																		AND dfla.fulfill_line_id =rctla.INTERFACE_LINE_ATTRIBUTE5
																		AND dfla.fulfill_line_id = dfleb.fulfill_line_id(+)
																		AND dfleb.context_code(+) = 'GED Fline Context'
																		AND hou.organization_id = rctla.org_id 
																		AND flv.meaning = hou.name
																		AND flv.lookup_type = 'GED_BU_NAMES'
																		AND flv.description = 'DIG' --in ('DIG','DIGAVN')
																		AND flv.enabled_flag = 'Y'
																		AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))
																		AND rownum <2)
																ELSE rctla.attribute7 END),						--REL-ARR Added for subscription enablement - End
								   'GEV ES INTERCOMPANY',(CASE WHEN rctla.attribute7 IS NULL 											--REL-ARR Added for Intercompany enablement - Start
															   THEN (SELECT NVL(rctla.attribute7,dfleb2.ATTRIBUTE_CHAR5)
																		FROM  ra_customer_trx_all rcta_parent,
																			  ra_customer_trx_lines_all rctla_parent,
																			  ra_batch_sources_all rbs,
																			  doo_fulfill_lines_eff_b dfleb2,
																			  doo_fulfill_lines_all dfla,
																			  HR_OPERATING_UNITS hou, 
																				FND_LOOKUP_VALUES_VL flv
																		WHERE 1=1  
																		AND rctla.INTERFACE_LINE_CONTEXT ='CCLAR'  
																		AND rctla.ATTRIBUTE_CATEGORY = 'CCLAR'
																		AND rctla.INTERFACE_LINE_ATTRIBUTE2 = rcta_parent.TRX_NUMBER
																		AND rctla.INTERFACE_LINE_ATTRIBUTE3  = rctla_parent.line_number
																		AND rcta_parent.customer_trx_id = rctla_parent.customer_trx_id
																		AND rctla_parent.INTERFACE_LINE_ATTRIBUTE5 = dfla.fulfill_line_id
																		AND dfla.fulfill_line_id = dfleb2.fulfill_line_id(+)
																		AND dfleb2.context_code(+) = 'GED FLine Context 2'
																		AND hou.organization_id = rctla.org_id 
																		AND flv.meaning = hou.name
																		AND flv.lookup_type = 'GED_BU_NAMES'
																		AND flv.description = 'DIG'
																		AND flv.enabled_flag = 'Y'
																		AND TRUNC(sysdate) between TRUNC(nvl(flv.start_date_active,sysdate)) AND TRUNC(nvl(flv.end_date_active,sysdate))
																		AND rownum <2)
															   ELSE rctla.attribute7 END),					--REL-ARR Added for Intercompany enablement - End
									NVL(UPPER(rctla.attribute7),' ')),75))
) is not null
)
)
AND   rctla.line_type = 'LINE'
AND 1 = (SELECT count(1) 
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