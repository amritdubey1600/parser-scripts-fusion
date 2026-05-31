--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                      Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-ARR				  	 TCS(Shubhajit)		25-Sep-2024	   		REL-ARR same as REL-099 as per QA/Audit Compliance
--#																	Change the ADN code for Subscription and Intercompany Adn enablement
--#-----------------------------------------------------------------------------------------------------#
SELECT record_key_i13,
ship_to_address,
record_key_i14,
ship_to_city,
ship_to_state,
ship_to_zip,
ship_to_country,
record_key_i17,
ship_from_address,
record_key_i18,
ship_from_city,
ship_from_state,
ship_from_zip,
ship_from_country,
record_key_i19,
Date_Shipped,
Shipping_Costs,
Bill_of_Lading,
Shipped_Via,
site_use_id,
customer_trx_id,
dummy
FROM (
SELECT  '1' dummy, 'I13' record_key_i13,
                RPAD(UPPER(SUBSTR(h.address1||' ' ||
                h.address2||' ' ||
                h.address3||' ' ||
                h.address4 ,1,30)),30) ship_to_address,
                'I14' record_key_i14,
                  RPAD(UPPER(h.city),19) ship_to_city,
                  RPAD(UPPER(h.state),2) ship_to_state,
                  RPAD(UPPER(h.postal_code),9) ship_to_zip,
                  RPAD(UPPER(i.territory_short_name),3) ship_to_country,
				  'I17' record_key_i17,
				  RPAD(' ',30) ship_from_address,
				  'I18' record_key_i18,
				  RPAD(' ',19) ship_from_city,
                  RPAD(' ',2) ship_from_state,
                  RPAD(' ',9) ship_from_zip,
                  RPAD(' ',3) ship_from_country,
				  'I19' record_key_i19,
				  RPAD(' ',4) Date_Shipped,
                  RPAD(' ',10) Shipping_Costs,
                  RPAD(' ',20) Bill_of_Lading,
                  RPAD(nvl(b1.ship_via,' '),36) Shipped_Via,
				  f.site_use_id,
                  b1.customer_trx_id			  
FROM   hz_parties a,
       hz_cust_accounts b,
        fnd_lookup_values c,
        hz_cust_acct_sites_all d,
        hz_party_sites e,
        hz_cust_site_uses_all f,
        hz_locations h,
        fnd_territories_tl i,ra_customer_trx_all  b1
WHERE 1=1
AND a.party_id = b.party_id
AND c.lookup_code = b.customer_type
AND c.LANGUAGE = 'US'
AND c.lookup_type = 'CUSTOMER_TYPE'
AND b.cust_account_id = d.cust_account_id
AND d.party_site_id = e.party_site_id
AND d.cust_acct_site_id = f.cust_acct_site_id
AND e.location_id = h.location_id
AND h.country = i.territory_code
AND i.LANGUAGE = 'US'
AND f.site_use_code = 'SHIP_TO' 
and b1.ship_to_site_use_id= f.site_use_id
AND ROWNUM<2
--AND B1.TRX_NUMBER='13001100000201'
union
SELECT  '2' dummy, 'I13' record_key_i13,
                    'X' ship_to_address,
                  'I14' record_key_i14,
                  'X'ship_to_city,
                  'X' ship_to_state,
                  'X' ship_to_zip,
                  'X' ship_to_country,
				  'I17' record_key_i17,
                  'X' ship_from_address,
                  'I18' record_key_i18,
                  'X'ship_from_city,
                  'X' ship_from_state,
                  'X' ship_from_zip,
                  'X' ship_from_country,
				  'I19' record_key_i19,
				   null Date_Shipped,
                   null Shipping_Costs,
                  null  Bill_of_Lading,
                  RPAD(nvl(bbb.ship_via,'X'),36) Shipped_Via,
                  BBB.SHIP_TO_SITE_USE_ID site_use_id,
                  BBB.customer_trx_id
from ra_customer_trx_all bbb
where BBB.PURCHASE_ORDER IS NOT NULL
AND bbb.customer_trx_id  not in (SELECT customer_trx_id 
                                from 
								---added by subba
								(

SELECT rctla.customer_trx_id 
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', 
									(SELECT DISTINCT c.attribute8 
									  FROM  OKC_K_HEADERS_ALL_B C,
											PJB_CNTRCT_PROJ_LINKS A , 
											PJF_PROJECTS_ALL_B B 
									  WHERE A.project_id= b.Project_id
										AND A.contract_id= C.id
										AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
										AND c.attribute8 is not null
										AND rct.interface_header_attribute1=c.contract_number),
									'DISTRIBUTED ORDER ORCHESTRATION',
									(SELECT dlfeb.attribute_char2
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
										 --AND dlfeb.CONTEXT_CODE='GED Fline Context'
										 AND rownum<2
										-- AND RCTLA.INTERFACE_LINE_ATTRIBUTE1 = a.SOURCE_ORDER_NUMBER
										-- AND RCTLA.INTERFACE_LINE_ATTRIBUTE2 =a.SOURCE_ORDER_SYSTEM
									  AND dlfeb.attribute_char2 IS NOT NULL)
									,NVL(NVL(UPPER(rctla.attribute7)
									,case when (rbs.name = 'Oracle DOO Integrated Subscriptions'					--REL-ARR Added for Subscription enablement - Start
												and exists (SELECT 1 FROM HR_OPERATING_UNITS hou, FND_LOOKUP_VALUES_VL flv, RA_CUSTOMER_TRX_LINES_ALL rctla
															WHERE rctla.customer_trx_id = rct.customer_trx_id
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
													WHERE rct.customer_trx_id           = rctla.customer_trx_id
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
											when (rbs.name = 'GEV ES Intercompany'							--REL-ARR Added for Intercompany enablement - Start
												and exists (SELECT 1 FROM HR_OPERATING_UNITS hou, FND_LOOKUP_VALUES_VL flv, RA_CUSTOMER_TRX_LINES_ALL rctla
															WHERE rctla.customer_trx_id = rct.customer_trx_id
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
													WHERE rct.customer_trx_id           = rctla.customer_trx_id  
													AND rctla.INTERFACE_LINE_CONTEXT ='CCLAR'  
													AND rctla.ATTRIBUTE_CATEGORY = 'CCLAR'
													AND rctla.INTERFACE_LINE_ATTRIBUTE2 = rcta_parent.TRX_NUMBER
													AND rctla.INTERFACE_LINE_ATTRIBUTE3  = rctla_parent.line_number
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
													AND rctla.line_type         = 'LINE') end ) ,' ')),75))					--REL-ARR Added for Intercompany enablement - End
) is not null
)
)
AND  rctla.line_type = 'LINE'
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
UNION
SELECT rctla.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', 
									 (SELECT DISTINCT c.attribute8 
										FROM  OKC_K_HEADERS_ALL_B C,
											  PJB_CNTRCT_PROJ_LINKS A , 
											  PJF_PROJECTS_ALL_B B 
										WHERE A.project_id= b.Project_id
										  AND A.contract_id= C.id
										  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
										  AND c.attribute8 is not null
										  AND rct.interface_header_attribute1=c.contract_number),
									'DISTRIBUTED ORDER ORCHESTRATION',
									(SELECT dlfeb.attribute_char2
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
									   --and dlfeb.CONTEXT_CODE='GED Fline Context'
									   AND ROWNUM<2
									   --AND RCTLA.INTERFACE_LINE_ATTRIBUTE1 = a.SOURCE_ORDER_NUMBER
									   --AND RCTLA.INTERFACE_LINE_ATTRIBUTE2 =a.SOURCE_ORDER_SYSTEM
									   AND dlfeb.attribute_char2 IS NOT NULL),
									   NVL(NVL(UPPER(rctla.attribute7)
									   ,case when (rbs.name = 'Oracle DOO Integrated Subscriptions'					--REL-ARR Added for Subscription enablement - Start
												and exists (SELECT 1 FROM HR_OPERATING_UNITS hou, FND_LOOKUP_VALUES_VL flv, RA_CUSTOMER_TRX_LINES_ALL rctla
															WHERE rctla.customer_trx_id = rct.customer_trx_id
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
													WHERE rct.customer_trx_id           = rctla.customer_trx_id
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
											when (rbs.name = 'GEV ES Intercompany'							--REL-ARR Added for Intercompany enablement - Start
												and exists (SELECT 1 FROM HR_OPERATING_UNITS hou, FND_LOOKUP_VALUES_VL flv, RA_CUSTOMER_TRX_LINES_ALL rctla
															WHERE rctla.customer_trx_id = rct.customer_trx_id
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
													WHERE rct.customer_trx_id           = rctla.customer_trx_id  
													AND rctla.INTERFACE_LINE_CONTEXT ='CCLAR'  
													AND rctla.ATTRIBUTE_CATEGORY = 'CCLAR'
													AND rctla.INTERFACE_LINE_ATTRIBUTE2 = rcta_parent.TRX_NUMBER
													AND rctla.INTERFACE_LINE_ATTRIBUTE3  = rctla_parent.line_number
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
													AND rctla.line_type         = 'LINE') end ),' ')),75))					--REL-ARR Added for Intercompany enablement - End
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
                ))
								--ended by Subba
								)
) xx order by dummy