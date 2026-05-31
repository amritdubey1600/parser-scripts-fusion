/*--#-----------------------------------------------------------------------------------------------------------------#
--# Cirrus AR IBS Invoice Extract Report
--# DESCRIPTION  : This data model query used to get the invoice line level data extracted for IBS
--#
--# CREATION DATE   :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#               Author             Date                   Description
--# -----------------------------------------------------------------------------------------------------------------#
--# REL-034           Nuri Chetia        01-NOV-2019       		GEINC5144084/GERITM5769433 Modified query for perfomance issue
--# REL-ARR			  TCS(Shubhajit)	 25-Sep-2024	    	REL-ARR same as REL-099 as per QA/Audit Compliance
--#																Change the ADN code for Subscription and Intercompany Adn enablement
--# -----------------------------------------------------------------------------------------------------------------#*/

SELECT a.RECORD_KEY_I30,
a.SUPPLIER_PRODUCT_CODE,
a.QUANTITY_ORDERED,
a.QUANTITY_INVOICED,
a.UNIT_PRICE_SIGN,
a.PO_LINE_ITEM,
a.UNIT_OF_MEASURE,
a.UNIT_PRICE,
a.EXTENDED_AMOUNT,
a.LINE_ITEM_AMOUNT,
a.LINE_AMOUNT,
a.UNSPSC_CODE,
a.LINE_ITEM_DESCRIPTION,
a.TAX_CLASSIFICATION_CODE,
a.TAX_RATE,
a.INR_TAX_TYPE_CODE,
a.INR_SPECIAL_CHARGE_CODE,
a.INR_SPECIAL_CHARGE_AMOUNT,
a.PARTY_NAME,
a.ACCOUNT_NUMBER,
a.OPERATING_UNIT,
a.INVOICE_NUMBER,
a.INVOICE_CURRENCY_CODE,
a.PURCHASE_ORDER,
a.BILL_TO_SITE_USE_ID,
a.SHIP_TO_SITE_USE_ID,
a.RECEIVER_BUC,
a.FROM_BUC,
a.BUC_CURRENCY_CODE,
 a.SHIP_TO_CITY,
a.SHIP_TO_STATE,
a.SHIP_TO_ZIP,
a.SHIP_FROM_CITY,
a.SHIP_FROM_STATE,
a.SHIP_FROM_ZIP,
a.SHIPPED_VIA, 
a.BOOK_CURRENCY_CODE,
a.INVOICE_AMOUNT,
a.BOOK_AMOUNT,
a.ACCTD_AMOUNT_ACTUAL,
a.SHIP_TO_COUNTRY,
a.SHIP_FROM_COUNTRY,
a.INVOICE_GROUP_ID,
 a.SHIP_TO_ADDRESS,
a.SHIP_FROM_ADDRESS,
a.UNALLOWABLE,
a.PROFIT,
a.TAX_ADN,
a.EXCHANGE_DATE,
a.FUNCTIONAL_CURRENCY_CODE,
a.CUSTOMER_TRX_ID,
a.CUSTOMER_TRX_LINE_ID,
a.OU_SHORT_CODE,
  NVL ((CASE WHEN (a.functional_currency_code <> NVL(a.buc_currency_code,'###') AND (a.invoice_currency_code = a.buc_currency_code)) THEN 1
              WHEN (a.functional_currency_code <> NVL(a.buc_currency_code,'###')) THEN ( SELECT c.conversion_rate
											FROM GL_DAILY_CONVERSION_TYPES b,
											      GL_DAILY_RATES c,
											      FND_CURRENCIES d
											WHERE b.conversion_type = c.conversion_type
											  AND b.user_conversion_type = 'MOR'
											  AND c.conversion_date = TRUNC(NVL(a.exchange_date, a.trx_date)) -- exchange/trx date
											  AND c.from_currency = a.invoice_currency_code
											  AND c.to_currency = a.buc_currency_code
											  AND d.currency_code = c.to_currency )
          END) , a.exchange_rate) conversion_rate
		  
FROM
(SELECT 'I30' record_key_i30,
       (select distinct item_number from EGP_system_items_b where inventory_item_id = a.inventory_item_id and rownum=1) supplier_product_code,
      RPAD(' ',10) quantity_ordered,
      LPAD(NVL(a.quantity_invoiced,a.quantity_credited),10,0) quantity_invoiced,
      ABS(ROUND(a.unit_selling_price,4)) unit_price,
      SIGN(a.unit_selling_price) unit_price_sign,
      SUBSTR(LPAD(ABS(ROUND(a.unit_selling_price,4) * 10000),15,0),15,1) unit_price_last_char,
      'I31' record_key_i31,
      RPAD(a.line_number,5) po_line_item,
      RPAD(DECODE(rct.purchase_order,NULL,' ',d.unit_of_measure),2) unit_of_measure,
      RPAD(' ',11) not_used_1,
	SUBSTR(LPAD(ABS(ROUND((NVL(a.extended_amount,0) + (SELECT SUM(NVL(extended_amount,0))
							   FROM RA_CUSTOMER_TRX_LINES_ALL
							   WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
							   AND   line_type='TAX')),c.precision) * POWER(10,c.precision)),10,0),1,9) extended_amount, 
        SUBSTR(LPAD(ABS(ROUND((NVL(a.extended_amount,0) + (SELECT SUM(NVL(extended_amount,0))
							   FROM RA_CUSTOMER_TRX_LINES_ALL
							   WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
							   AND   line_type='TAX')),c.precision) * POWER(10,c.precision)),10,0),10,1) 	extended_amount_last_char,						   
	SIGN(NVL(a.extended_amount,0) + (SELECT SUM(NVL(extended_amount,0))
					 FROM RA_CUSTOMER_TRX_LINES_ALL
					 WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
					 AND   line_type='TAX')) extended_amount_sign,
      RPAD(' ',11) not_used_2,
      RPAD(' ',1) price_per,
	ABS(ROUND(NVL(a.extended_amount,1),c.precision)) line_item_amount,
	SUBSTR(LPAD(ABS(ROUND(NVL(a.extended_amount,0),c.precision) * POWER(10,c.precision)),15,0),15,1) line_item_amt_last_char,
    ABS(ROUND(NVL(a.extended_amount,1),c.precision)) line_amount, 
      SIGN(NVL(a.extended_amount,0)) line_item_amount_sign, 
      RPAD(' ',10) unspsc_code, 
      'I32' record_key_i32,
      RPAD(UPPER(SUBSTR(NVL(a.description,' '),1,40)),40) line_item_description,
      'I34' record_key_i34,
      'I36' record_key_i36,
      a.tax_classification_code ,
    (SELECT tax_rate
       FROM RA_CUSTOMER_TRX_LINES_ALL
      WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	    AND line_type='TAX'
        AND ROWNUM =1) tax_rate,
	(SELECT SUM(NVL(extended_amount,0))
	   FROM RA_CUSTOMER_TRX_LINES_ALL
	  WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	    AND line_type='TAX') ext_amount,
      a.customer_trx_id,
      a.customer_trx_line_id,
      UPPER(b.short_code) ou_short_code,
      RPAD('SVT',3) inr_tax_type_code,
      'ITX' inr_special_charge_code,
      RPAD(RPAD('SVT',3) || RPAD(' ',3)||
      (LPAD(DECODE(TRUNC(((SELECT SUM(NVL(extended_amount,0))
				    FROM RA_CUSTOMER_TRX_LINES_ALL
				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
				    AND   line_type='TAX') * 100 / ABS(ROUND(NVL(decode(a.extended_amount,0,1,a.extended_amount),1),c.precision))),2),
      NULL,' ',TRIM(TO_CHAR(TRUNC(((SELECT SUM(NVL(extended_amount,0))
				    FROM RA_CUSTOMER_TRX_LINES_ALL
				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
				    AND   line_type='TAX') * 100 / ABS(ROUND(NVL(decode(a.extended_amount,0,1,a.extended_amount),1),c.precision))),2),'99.99')||'%')),6 ) )||RPAD(' ',7)||
       (NVL((SELECT SUM(NVL(extended_amount,0))
				    FROM RA_CUSTOMER_TRX_LINES_ALL
				    WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
				    AND   line_type='TAX'),0) * NVL(rct.exchange_rate,1)),60) inr_special_charge_text, 
      LPAD(ABS(ROUND(NVL((SELECT SUM(NVL(extended_amount,0))
	 FROM RA_CUSTOMER_TRX_LINES_ALL
	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	  AND line_type='TAX'),0),c.precision)  * POWER(10,c.precision)),12,0) inr_special_charge_amount,
          SIGN(NVL((SELECT SUM(NVL(extended_amount,0))
	 FROM RA_CUSTOMER_TRX_LINES_ALL
	WHERE link_to_cust_trx_line_id=a.customer_trx_line_id
	  AND line_type='TAX'),0)) inr_spl_charge_amt_sign,
	o.party_name,
    n.account_number,
	b.name operating_unit,
	rct.trx_number invoice_number, 
  rct.trx_date,
	rct.invoice_currency_code,
	gl.currency_code AS functional_currency_code,
	--rct.purchase_order,
	RPAD((CASE 
			       WHEN ((rct.PURCHASE_ORDER IS NOT NULL) AND
			            (DECODE(i.name,'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                            from  OKC_K_HEADERS_ALL_B C,
												      PJB_CNTRCT_PROJ_LINKS A ,
													  PJF_PROJECTS_ALL_B B,
													  ra_customer_trx_all rctt
                                                     where A.project_id= b.Project_id
												      and A.contract_id= C.id
													  and c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rctt.interface_header_attribute1=a1.contract_number)
													  and c.attribute8 is not null
													  and rctt.customer_trx_id= rct.customer_trx_id
													  and rownum<2
												      and rctt.interface_header_attribute1=c.contract_number),
										'Distributed Order Orchestration',
										(SELECT dlfeb.attribute_char2
										  FROM doo_headers_all a,
											   doo_lines_all b,
											   ra_customer_trx_lines_all rctla,
											   doo_fulfill_lines_all c,
											   DOO_FULFILL_LINES_EFF_B dlfeb
										 WHERE a.header_id=b.header_id
										   AND b.line_id=c.line_id
										   AND c.fulfill_line_id=dlfeb.fulfill_line_id
										  -- AND rctla.INTERFACE_LINE_ATTRIBUTE3= a.ORDER_NUMBER
										   AND a.status_code not like 'DOO_REFERENCE'
										   AND TO_CHAR (c.fulfill_line_id) =RCTLA.INTERFACE_LINE_ATTRIBUTE5
										   AND rownum<2
										   AND rct.customer_trx_id = rctla.customer_trx_id
										  -- AND dlfeb.CONTEXT_CODE='GED Fline Context'
										  -- AND RCTLA.INTERFACE_LINE_ATTRIBUTE1 = a.SOURCE_ORDER_NUMBER
										  -- AND RCTLA.INTERFACE_LINE_ATTRIBUTE2 =a.SOURCE_ORDER_SYSTEM
										   AND dlfeb.attribute_char2 IS NOT NULL), 
										   NVL((SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')
										   ,case when (i.name = 'Oracle DOO Integrated Subscriptions'					-- Added for Subscription enablement
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
														AND rctla.line_type         = 'LINE')
												when (i.name = 'GEV ES Intercompany'							-- Added for Intercompany enablement
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
														WHERE rct.customer_trx_id = rctla.customer_trx_id  
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
														AND rctla.line_type         = 'LINE') end )))IS NOT NULL)  THEN ' '
				    ELSE rct.PURCHASE_ORDER
                END),30) 	purchase_order,
  rct.bill_to_site_use_id, 
  rct.ship_to_site_use_id, 
	(SELECT DECODE(REGEXP_SUBSTR(hps.party_site_name,'BUC',1,1),'BUC',SUBSTR(hps.party_site_name,1,6),hzca.attribute3)
	   FROM hz_cust_acct_sites_all hzca,
		    hz_party_sites hps,
		    hz_cust_site_uses_all hcs
	  WHERE 1=1
	    AND hzca.party_site_id     = hps.party_site_id
	    AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
	    AND hcs.site_use_code      = 'BILL_TO'
	    AND hcs.site_use_id        = rct.bill_to_site_use_id
	) receiver_buc,	
	NVL((SELECT flv.meaning
	  FROM fnd_lookup_values flv 
	 WHERE flv.lookup_type ='GED IBS EXTRACT LOOKUP'
       AND flv.language = 'US'
       AND b.name  = flv.lookup_code), SUBSTR(rctt.name,1,6)) AS from_buc,
	   
	NVL((SELECT flv.tag
	  FROM fnd_lookup_values flv 
	 WHERE flv.lookup_type ='GED IBS EXTRACT LOOKUP'
       AND flv.language = 'US'
       AND b.name  = flv.lookup_code), rctt.attribute2) AS buc_currency_code,
  RPAD(NVL(rct.attribute2,'N'),1) unallowable,
  RPAD(NVL(rct.attribute3,'N'),1) profit,  
  UPPER(rctt.attribute2) book_currency_code, 
  NULL AS INVOICE_GROUP_ID,
  (SELECT TO_CHAR(amount, 'fm99999999999999999999999.00') 
     FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in     
    WHERE rct_in.customer_trx_id = rct.customer_trx_id 
      AND account_class = 'REC' 
      AND LATEST_REC_FLAG  ='Y' ) invoice_amount, 
  (SELECT DECODE(gl.currency_code, rctt.attribute2, ABS(SUM(ROUND(NVL(acctd_amount,1),c.precision)))
  , ABS(SUM(ROUND((amount *  rct.exchange_rate), c.precision)))) 
     FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in   
    WHERE rct_in.customer_trx_id = rct.customer_trx_id        
      AND account_class = 'REC' 
      AND nvl(LATEST_REC_FLAG,'Y') ='Y' ) book_amount,  
  (SELECT DECODE(gl.currency_code, rctt.attribute2, (SUM(NVL(acctd_amount,1)))
  , (SUM(ROUND((amount *  nvl(rct.exchange_rate,1)), c.precision))))  
     FROM RA_CUST_TRX_LINE_GL_DIST_ALL rct_in 
    WHERE rct_in.customer_trx_id = rct.customer_trx_id   
      AND account_class = 'REC' 
      AND nvl(LATEST_REC_FLAG,'Y') ='Y') acctd_amount_actual ,  
      
   (SELECT  RPAD(NVL(hzca.attribute2,' '),64) 
			FROM 	hz_cust_acct_sites_all hzca,
            hz_cust_site_uses_all hcs
			WHERE 1=1
			  AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
			  AND hcs.site_use_code = 'BILL_TO'
			  AND hcs.site_use_id = rct.bill_to_site_use_id) tax_adn, 
        
     NVL(rct.exchange_date,rct.trx_date) exchange_date , 
     rct.exchange_rate,
     --REL 034  GEINC5144084/GERITM5769433 starts
	 /*(
 SELECT  'X' ship_to_address                  
from ra_customer_trx_all bbb
where BBB.PURCHASE_ORDER IS NOT NULL
and bbb.customer_trx_id= rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
) ship_to_address,

(
SELECT  'X' SHIP_TO_CITY                  
from ra_customer_trx_all bbb
where BBB.PURCHASE_ORDER IS NOT NULL
and bbb.customer_trx_id= rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
) ship_to_city,
	(SELECT 'X' SHIP_TO_STATE            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_TO_STATE,
		(SELECT 'X' SHIP_TO_ZIP            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_TO_ZIP,
		(SELECT 'X' SHIP_FROM_CITY            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_FROM_CITY,
		(SELECT 'X' SHIP_FROM_STATE            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_FROM_STATE,
		(SELECT 'X' SHIP_FROM_ZIP            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_FROM_ZIP,
		(SELECT 'X' SHIPPED_VIA            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIPPED_VIA,
		(SELECT 'X' SHIP_TO_COUNTRY            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_TO_COUNTRY,
		(SELECT 'X' SHIP_FROM_COUNTRY            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_FROM_COUNTRY,
		(SELECT 'X' SHIP_FROM_ADDRESS            
        from ra_customer_trx_all bbb
       where 1=1
         and bbb.PURCHASE_ORDER IS NOT NULL
         and bbb.customer_trx_id =rct.customer_trx_id
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                  FROM  OKC_K_HEADERS_ALL_B C,
												            PJB_CNTRCT_PROJ_LINKS A , 
													        PJF_PROJECTS_ALL_B B 
                                                      WHERE A.project_id= b.Project_id
												        AND A.contract_id= C.id
														AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													    AND c.attribute8 is not null
														AND rownum<2
												        AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                                  AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
(trim(  RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', (SELECT DISTINCT c.attribute8 
	                                                        FROM  OKC_K_HEADERS_ALL_B C,
												                  PJB_CNTRCT_PROJ_LINKS A , 
													              PJF_PROJECTS_ALL_B B 
                                                            WHERE A.project_id= b.Project_id
												              AND A.contract_id= C.id
															  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
													          AND c.attribute8 is not null
															  AND rownum<2
												              AND rct.interface_header_attribute1=c.contract_number),'DISTRIBUTED ORDER ORCHESTRATION',(SELECT dlfeb.attribute_char2
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
                                                                                                                                               AND dlfeb.attribute_char2 IS NOT NULL),(SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')),75))
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
	) SHIP_FROM_ADDRESS */
    SHIP_DETAILS.SHIP_TO_CITY,
SHIP_DETAILS.SHIP_TO_STATE,
SHIP_DETAILS.SHIP_TO_ZIP,
SHIP_DETAILS.SHIP_FROM_CITY,
SHIP_DETAILS.SHIP_FROM_STATE,
SHIP_DETAILS.SHIP_FROM_ZIP,
SHIP_DETAILS.SHIPPED_VIA, 
SHIP_DETAILS.SHIP_TO_COUNTRY,
SHIP_DETAILS.SHIP_FROM_COUNTRY,
SHIP_DETAILS.SHIP_TO_ADDRESS,
SHIP_DETAILS.SHIP_FROM_ADDRESS
     --REL 034  GEINC5144084/GERITM5769433 Ends
FROM RA_CUSTOMER_TRX_LINES_ALL A
    ,RA_CUSTOMER_TRX_ALL rct
	  ,RA_CUST_TRX_TYPES_ALL rctt 
    ,HR_OPERATING_UNITS b 
    ,FND_CURRENCIES c
	  ,INV_UNITS_OF_MEASURE_VL d 
	  ,HZ_CUST_ACCOUNTS N
    ,HZ_PARTIES O
    ,GL_LEDGERS gl
    ,fun_all_business_units_v h 
	,RA_BATCH_SOURCES_ALL i,
       --REL 034  GEINC5144084/GERITM5769433 starts
  (
 SELECT  bbb.customer_trx_id       ,
  'X' SHIP_TO_CITY,
'X' SHIP_TO_STATE,
'X' SHIP_TO_ZIP,
'X' SHIP_FROM_CITY,
'X' SHIP_FROM_STATE,
'X' SHIP_FROM_ZIP,
'X' SHIPPED_VIA, 
'X' SHIP_TO_COUNTRY,
'X' SHIP_FROM_COUNTRY,
'X' SHIP_TO_ADDRESS,
'X' SHIP_FROM_ADDRESS                 
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
										AND rownum<2
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
									  AND dlfeb.attribute_char2 IS NOT NULL),
									NVL((SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')
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
													AND rctla.line_type         = 'LINE') end )),75))					--REL-ARR Added for Intercompany enablement - End
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
(trim( RPAD( DECODE(UPPER(rbs.name),'CONTRACT INVOICES', 
									(SELECT DISTINCT c.attribute8 
									 FROM  OKC_K_HEADERS_ALL_B C,
										  PJB_CNTRCT_PROJ_LINKS A , 
										  PJF_PROJECTS_ALL_B B 
									 WHERE A.project_id= b.Project_id
									  AND A.contract_id= C.id
									  AND c.MAJOR_VERSION= (select max(a1.MAJOR_VERSION) from OKC_K_HEADERS_ALL_B a1 where rct.interface_header_attribute1=a1.contract_number)
									  AND c.attribute8 is not null
									  AND rownum<2
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
									NVL((SELECT distinct ral.attribute7 FROM RA_CUSTOMER_TRX_LINES_ALL ral WHERE ral.customer_trx_id = rct.customer_trx_id AND ral.attribute7 IS NOT NULL AND ROWNUM<2  AND ral.line_type = 'LINE')
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
													AND rctla.line_type         = 'LINE') end )),75))					--REL-ARR Added for Intercompany enablement - End
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
) SHIP_DETAILS
     --REL 034  GEINC5144084/GERITM5769433 starts
WHERE 1=1
AND a.line_type = 'LINE'
AND a.org_id=b.organization_id 
AND a.customer_trx_id = rct.customer_trx_id
AND c.currency_code = rct.invoice_currency_code
AND a.uom_code=d.uom_code(+)
AND h.bu_id= rct.org_id
AND h.primary_ledger_id = gl.ledger_id 
AND n.party_id                     = o.party_id
AND n.cust_account_id              = rct.bill_to_customer_id
AND rct.CUST_TRX_TYPE_SEQ_ID       = rctt.cust_trx_type_seq_id
and i.batch_source_seq_id = rct.batch_source_seq_id
AND rctt.attribute1                = 'Y'
and SHIP_DETAILS.customer_trx_id(+) =a.customer_trx_id     --REL 034  GEINC5144084/GERITM5769433 Added
) a