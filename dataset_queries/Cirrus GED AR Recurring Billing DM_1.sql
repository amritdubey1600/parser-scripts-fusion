--#-----------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY: 
--# CR#          Author             Date                Description 
--#-----------------------------------------------------------------------------------------#
--# REL-079    Vignesh Kumar  	   04-Aug-2023		  Cirrus GED AR Recurring Billing Report --# 
--#-----------------------------------------------------------------------------------------#
SELECT   order_details.bu_name,
		 order_details.order_number,
		 order_details.line_number,
		 order_details.fulfill_line_number,
		 order_details.opportunity,
		 order_details.quote,
		 order_details.sales_doc_type,
		 order_details.order_status,
		 order_details.order_line_status,
		 order_details.order_fulfillement_status,
		 order_details.order_currency,
		 order_details.ordered_qty,
		 order_details.ordered_date,
         order_details.order_amt_usd,
         order_details.quantity,
		 order_details.unit_selling_price,
		 order_details.currency_code,
         order_details.order_amount, 
		 order_details.trx_date, 
		 order_details.gl_date, 
		 order_details.creation_date,
         order_details.billing_period_start_date,
		 order_details.billing_period_end_date,
         order_details.recurring_bill_flag,
		 order_details.requested_fulfillment_date,
		 order_details.billing_frequency,
		 TO_NUMBER(order_details.total_billing_periods),
		 order_details.service_start_date,
		 order_details.service_end_date,		 
		 item_details.part_number,
		 REPLACE(REPLACE(REPLACE(item_details.part_desc,CHR(10),''),CHR(13),''),',','') part_desc,
		 item_details.product_family,
		 item_details.product_line,
		 item_details.product_type,
		 item_details.product_subtype,
		 bill_to.party_name bill_to_party_name,
		 bill_to.party_number bill_to_party_number,
		 bill_to.country bill_to_country,
		 ship_to.party_name ship_to_party_name,
		 ship_to.party_number ship_to_party_number,
		 ship_to.country ship_to_country,
		(SELECT flv.meaning
         FROM FND_LOOKUP_VALUES_VL flv
         WHERE flv.lookup_type = 'CUSTOMER_TYPE'
         AND flv.lookup_code = bill_to.customer_type) customer_type,	
		DECODE(NVL((SELECT DISTINCT DOC_USER_KEY 
                    FROM DOO_DOCUMENT_REFERENCES 
					WHERE header_id=order_details.header_id
                    AND doc_ref_type(+) = 'ORIGINAL_ORCHESTRATION_ORDER'),'No Original Order'),
									'No Original Order','No','Yes') returned_order_flag,							
		CASE WHEN Item_Details.product_subtype IN (SELECT flv.lookup_code
												   FROM FND_LOOKUP_VALUES flv
												   WHERE flv.lookup_type = 'GED_SERVICE_ITEM_SUBTYPES'
												   AND flv.language = 'US'
												   AND flv.enabled_flag = 'Y'
												   AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
												   AND nvl(flv.end_date_active, SYSDATE) >= SYSDATE)
			THEN 'Y'
			WHEN order_details.line_type_code = 'Standard-Variable Billing'
			THEN 'Y'
			ELSE 'N'
			END AS ppm_item_flag,	
		item_details.shippable_item_flag,
		TO_CHAR(order_details.actual_ship_date,'MM/DD/YYYY') actual_ship_date,
		TO_CHAR(order_details.fulfillment_date,'MM/DD/YYYY') fulfillment_date,
		order_details.shipping_instructions,
		order_details.rebook_order,	
		order_details.rebook_reason,				   
		order_details.original_quote,				   
		order_details.original_order,
		order_details.cust_po_number,
		order_details.term_id,
		order_details.term_name,
		order_details.adn,
		order_details.segment_reporting segment_reporting,
		order_details.cost_center,
		order_details.requested_ship_date 		
	------------------------------------Main Select Closed------------------------		
FROM
	----------------------------------Order Details Starts Here--------------------------------
	(SELECT /*+ MATERIALIZE */
			a.bu_name,
			dha.org_id,
			dha_eff.attribute_char7 opportunity,
			dha_eff.attribute_char6 quote,
			dha_eff.attribute_char1 sales_doc_type,
			dha.order_number,
			dla.line_number,
			dfla.fulfill_line_number,
			dfla.line_type_code,
			dfla.customer_po_number,
			dha.header_id,
			dla.line_id,
			dha.status_code order_status,
			dla.status_code order_line_status,
			dfla.status_code order_fulfillement_status,
			dfla.fulfill_line_id,
			dla.inventory_item_id,
			bill_to_ad.cust_acct_site_use_id,
			ship_to_ad.party_site_id,
			TRUNC(TO_DATE(TO_CHAR(CAST(FROM_TZ(CAST(DHA.ORDERED_DATE AS TIMESTAMP), 'UTC') at time zone 'America/New_York' AS Date),'YYYY-MM-DD')))  ORDERED_DATE,
			dha.transactional_currency_code Order_Currency,
			dfl_eff.smart_part_desc,
			dfl_eff.smart_part_number,
			dfla.ordered_qty,
			NVL(dfla.unit_selling_price*dfla.ordered_qty,dfla.extended_amount) Order_Amount,
			TO_NUMBER((NVL(dfla.unit_selling_price*dfla.ordered_qty,dfla.extended_amount)))
			*(DECODE(dha.transactional_currency_code,'USD',1,
			  (SELECT DISTINCT gdr.conversion_rate
				FROM gl_daily_rates gdr
				WHERE gdr.conversion_type ='300000002138002'
				AND gdr.to_currency  ='USD'
				AND TO_CHAR(GDR.CONVERSION_DATE,'MM/DD/YYYY')= TO_CHAR(dha.ordered_date,'MM/DD/YYYY')
				AND gdr.from_currency = dha.transactional_currency_code
			  ))) order_amt_usd,
			  TRUNC(dfla.actual_ship_date) actual_ship_date,
			  TRUNC(dfla.fulfillment_date) fulfillment_date,		  
			  dfla.shipping_instructions,
			  dha_eff1.attribute_char1 rebook_order,	
			  dha_eff1.attribute_char2 rebook_reason,				   
			  dha_eff1.attribute_char3 original_quote,				   
			  dha_eff1.attribute_char4 original_order, 	
			  ract.sales_order_date,
			  ract.quantity,
			  ract.unit_selling_price,
			  ract.currency_code,
			  ract.amount, 		 
			  TRUNC(ract.trx_date)                  trx_date, 
			  TRUNC(ract.gl_date)                   gl_date, 
			  TRUNC(ract.creation_date)             creation_date,
			  TRUNC(ract.billing_period_start_date) billing_period_start_date,
			  TRUNC(ract.billing_period_end_date)   billing_period_end_date,
			  ract.recurring_bill_flag,
			  ract.interface_line_attribute5, 
			  ract.interface_line_attribute3,
			  ract.term_id,  						
			  (Select mpt.name
					from msc_payment_terms_vl mpt
					where dfla.payment_term_id = mpt.term_id)     term_name,
			  NVL(contract.cust_po_number,DHA.customer_po_number) cust_po_number,
			  NVL(contract.ADN,dfl_eff.attribute_char2)           ADN,					
			  dha_eff.attribute_char17                            segment_reporting,	
			  TRUNC(dfla.request_ship_date)                       requested_ship_date,
			  TRUNC(dfla.required_fulfillment_date)               requested_fulfillment_date,
			  NVL((SELECT
					DECODE(dbp1.periodicity_code,'MONTH','Monthly','YEAR','Yearly','DAY','Daily','QUARTER','Quarterly','WEEK','Weekly')
					FROM DOO_BILLING_PLANS DBP1 
					WHERE dbp1.fulfill_line_id=dfla.fulfill_line_id
							AND billing_plan_id =(SELECT MAX(billing_plan_id)
													FROM DOO_BILLING_PLANS DBP
													WHERE dbp.fulfill_line_id=dfla.fulfill_line_id
				)),'One Time Billing') billing_frequency,						
			NVL((SELECT NVL(dbp1.billing_num_of_periods,0)
						FROM DOO_BILLING_PLANS DBP1 
						WHERE dbp1.fulfill_line_id=dfla.fulfill_line_id
						AND billing_plan_id =(SELECT MAX(billing_plan_id)
											  FROM DOO_BILLING_PLANS DBP
											  WHERE dbp.fulfill_line_id=dfla.fulfill_line_id)),'1')total_billing_periods,
			dfl_eff.service_start_date,
			dfl_eff.service_end_date, 
			(SELECT gcc.segment4
			FROM  ar_ref_accounts_all araa,
				  ra_cust_trx_types_all rctta,
				  gl_code_combinations gcc
			WHERE  araa.source_ref_table    = 'RA_CUST_TRX_TYPES_ALL'
			AND  araa.source_ref_account_id = rctta.cust_trx_type_seq_id
			AND  rctta.name                 = ract.cust_trx_type_name
			AND  araa.bu_id                 = a.bu_id
			AND gcc.code_combination_id     = araa.rev_ccid
				AND SYSDATE BETWEEN NVL(gcc.start_date_active,SYSDATE) and NVL(gcc.end_date_active,SYSDATE+1)) cost_center   		
	FROM DOO_ORDER_ADDRESSES BILL_TO_AD,
		DOO_ORDER_ADDRESSES SHIP_TO_AD,
		DOO_HEADERS_ALL DHA,
		DOO_FULFILL_LINES_ALL DFLA,
		DOO_LINES_ALL DLA,
		(SELECT okha.cust_po_number,
				okha.attribute8 ADN,
				okla.attribute3,
				okla.attribute4
		FROM 
			OKC_K_LINES_B okla,
			OKC_K_HEADERS_ALL_B okha
		WHERE 1=1
			AND okha.major_version = okla.major_version 
			AND okha.id = okla.chr_id
			) contract,	
		(SELECT attribute_char1,
				attribute_char7,
				attribute_char6,
				attribute_char10,
				attribute_char17,
				header_id										
		from doo_headers_eff_b where context_code = 'GED HEADER EFF CONTEXT') dha_eff,
		(SELECT a.attribute_char1,
			  a.attribute_char2,
			  a.attribute_char3,
			  a.attribute_char4,
			  header_id
              FROM DOO_HEADERS_EFF_B a
              WHERE a.context_code = 'GED HEADER EFF CONTEXT2'
			  AND  UPPER(a.attribute_char1) = 'TRUE') dha_eff1,
		(SELECT fle.attribute_char13 smart_part_desc,
				fle.attribute_char4  smart_part_number,
				TRUNC(fle.attribute_date1) service_start_date,
				TRUNC(fle.attribute_date2) service_end_date,
				fle.attribute_char2,
				fle.fulfill_line_id
			FROM   doo_fulfill_lines_eff_b fle
			WHERE    fle.context_code = 'GED Fline Context'
				AND fle.object_version_number = (SELECT MAX(a1.object_version_number)
													FROM DOO_FULFILL_LINES_EFF_B a1
													WHERE a1.fulfill_line_id =fle.fulfill_line_id)) dfl_eff,
		RA_INTERFACE_LINES_ALL ract,
		FUN_ALL_BUSINESS_UNITS_V a
	WHERE 1=1
			AND dha.header_id 					 = dla.header_id
			AND dha.header_id 					 = dfla.header_id
			AND dla.line_id   					 = dfla.line_id
			AND dha.header_id 					 = dha_eff.header_id(+)
			AND dha.header_id 					 = dha_eff1.header_id(+)
			AND dha.header_id 					 = bill_to_ad.header_id(+)
			AND dfla.fulfill_line_id             = dfl_eff.fulfill_line_id(+)
			AND dha.header_id                    = bill_to_ad.header_id(+)
			AND bill_to_ad.address_use_type(+)   = 'BILL_TO'
			AND dha.header_id                    = ship_to_ad.header_id(+)
			AND ship_to_ad.address_use_type(+)   = 'SHIP_TO' 
			AND dha.order_number                 = contract.attribute3(+) 
			AND to_char(dla.line_number)         = contract.attribute4(+) 
			AND dha.object_version_number        = (SELECT MAX(oheader1.object_version_number)
													FROM doo_headers_all oheader1
													WHERE dha.order_number = oheader1.order_number
													AND oheader1.status_code NOT LIKE '%DOO%') 																		 
			AND dha.status_code NOT LIKE '%DOO%'
			AND (dfla.status_code IN (:p_so_fulfillment_status) OR COALESCE(:p_so_fulfillment_status,NULL) IS NULL)
			AND TRUNC(ract.trx_date) >= TRUNC(SYSDATE)
			AND (NVL((SELECT
						case when dbp1.periodicity_code IN ('MONTH','YEAR','DAY','QUARTER','WEEK') then 'Recurring billing'
								else 'One Time Billing'
								end 
						FROM DOO_BILLING_PLANS DBP1 
						WHERE DBP1.FULFILL_LINE_ID=DFLA.FULFILL_LINE_ID
								AND billing_plan_id =(SELECT MAX(billing_plan_id)
														FROM DOO_BILLING_PLANS DBP
														WHERE DBP.FULFILL_LINE_ID=DFLA.FULFILL_LINE_ID
					)),'One Time Billing')) = 'Recurring billing'
			AND (NVL(dha_eff.attribute_char1,'NULL') IN (:p_so_type) OR COALESCE(:p_so_type,NULL) IS NULL)			
			AND TO_CHAR(DFLA.fulfill_line_id) = ract.interface_line_attribute5
			AND dha.order_number              = ract.interface_line_attribute3
			AND dfla.status_code IN ('CLOSED','AWAIT_BILLING','BILLED')
			AND a.bu_name IN (SELECT fabuv.bu_name
			FROM FND_LOOKUP_VALUES flv,
			fun_all_business_units_v fabuv
			WHERE 1=1
			AND flv.lookup_code                      =  fabuv.bu_name
			AND flv.lookup_type                      = 'GED_BU_NAMES'
			AND LANGUAGE                             = 'US'
			AND flv.enabled_flag                     = 'Y'
			AND UPPER(NVL(flv.description, 'GED'))  != 'AVIATION')
			AND (a.BU_NAME IN (:P_BU) OR COALESCE(:P_BU,NULL) IS NULL)
			AND ract.org_id = DHA.org_id 
			AND dha.org_id = a.bu_id 
UNION
	SELECT  a.bu_name,
			dha.org_id,
			dha_eff.attribute_char7 opportunity,
			dha_eff.attribute_char6 quote,
			dha_eff.attribute_char1 sales_doc_type,
			dha.order_number,
			dla.line_number,
			dfla.fulfill_line_number,
			dfla.line_type_code,
			dfla.customer_po_number,
			dha.header_id,
			dla.line_id,
			dha.status_code order_status,
			dla.status_code order_line_status,
			dfla.status_code order_fulfillement_status,
			dfla.fulfill_line_id,
			dla.inventory_item_id,
			bill_to_ad.cust_acct_site_use_id,
			ship_to_ad.party_site_id,
			TRUNC(TO_DATE(TO_CHAR(CAST(FROM_TZ(CAST(DHA.ORDERED_DATE AS TIMESTAMP), 'UTC') at time zone 'America/New_York' AS Date),'YYYY-MM-DD')))  ORDERED_DATE,
			dha.transactional_currency_code order_currency,
			dfl_eff.smart_part_desc,
			dfl_eff.smart_part_number,
			dfla.ordered_qty,
			NVL(dfla.unit_selling_price*dfla.ordered_qty,dfla.extended_amount) order_amount,
			TO_NUMBER((NVL(Dfla.unit_selling_price*dfla.ordered_qty,dfla.extended_amount)))
			*(DECODE(dha.transactional_currency_code,'USD',1,
			  (SELECT DISTINCT gdr.conversion_rate
				FROM gl_daily_rates gdr
				WHERE gdr.conversion_type ='300000002138002'
						AND gdr.to_currency  ='USD'
						AND TO_CHAR(gdr.conversion_date,'MM/DD/YYYY')= TO_CHAR(dha.ordered_date,'MM/DD/YYYY')
						AND gdr.from_currency = dha.transactional_currency_code
			  ))) order_amt_usd,
			  TRUNC(dfla.actual_ship_date) actual_ship_date,
			  TRUNC(dfla.fulfillment_date) fulfillment_date,		  
			  dfla.shipping_instructions,
			  dha_eff1.attribute_char1 Rebook_Order,	
			  dha_eff1.attribute_char2 Rebook_Reason,				   
			  dha_eff1.attribute_char3 Original_Quote,				   
			  dha_eff1.attribute_char4 Original_Order,	
			  ract.sales_order_date,
			  ract.quantity,
			  ract.unit_selling_price,
			  ract.currency_code,
			  ract.amount, 		 
			  TRUNC(ract.trx_date)                  trx_date, 
			  TRUNC(ract.gl_date)                   gl_date, 
			  TRUNC(ract.creation_date)             creation_date,
			  TRUNC(ract.billing_period_start_date) billing_period_start_date,
			  TRUNC(ract.billing_period_end_date)   billing_period_end_date,
			  ract.recurring_bill_flag,
			  ract.interface_line_attribute5, 
			  ract.interface_line_attribute3,
			  ract.term_id,  						
			 (SELECT mpt.name
					from msc_payment_terms_vl mpt
					where dfla.payment_term_id = mpt.term_id)    term_name,
			 NVL(contract.cust_po_number,DHA.customer_po_number) cust_po_number,
			 NVL(contract.ADN,dfl_eff.attribute_char2)           adn,					
			 dha_eff.attribute_char17                            segment_reporting,		
			 TRUNC(dfla.request_ship_date)                       requested_ship_date,
			 TRUNC(dfla.required_fulfillment_date)               Requested_fulfillment_date,
			 NVL((SELECT
						DECODE(DBP1.PERIODICITY_CODE,'MONTH','Monthly','YEAR','Yearly','DAY','Daily','QUARTER','Quarterly','WEEK','Weekly')
						FROM DOO_BILLING_PLANS DBP1 
						WHERE DBP1.FULFILL_LINE_ID=DFLA.FULFILL_LINE_ID
								AND billing_plan_id =(SELECT MAX(billing_plan_id)
														FROM DOO_BILLING_PLANS DBP
														WHERE DBP.FULFILL_LINE_ID=DFLA.FULFILL_LINE_ID
					)),'One Time Billing')    billing_frequency,							
				NVL((SELECT NVL(dbp1.billing_num_of_periods,0)
					FROM DOO_BILLING_PLANS DBP1 
					WHERE dbp1.fulfill_line_id=dfla.fulfill_line_id
					AND billing_plan_id =(SELECT MAX(billing_plan_id)
										  FROM DOO_BILLING_PLANS DBP
										  WHERE DBP.FULFILL_LINE_ID=DFLA.FULFILL_LINE_ID) ),'1')total_billing_periods,
				dfl_eff.service_start_date,
				dfl_eff.service_end_date,
				(SELECT gcc.segment4
					FROM  ar_ref_accounts_all araa,
						ra_cust_trx_types_all rctta,
						gl_code_combinations gcc
					WHERE  araa.source_ref_table          = 'RA_CUST_TRX_TYPES_ALL'
						  AND  araa.source_ref_account_id = rctta.cust_trx_type_seq_id
						  AND  rctta.name                 =ract.cust_trx_type_name
						  AND  araa.bu_id                 = a.bu_id
						  AND gcc.code_combination_id     = araa.rev_ccid
						  AND SYSDATE BETWEEN NVL(gcc.start_date_active,SYSDATE) and NVL(gcc.end_date_active,SYSDATE+1)
				) cost_center   			
	FROM doo_order_addresses bill_to_ad,
		doo_order_addresses ship_to_ad,
		doo_headers_all dha,
		doo_fulfill_lines_all dfla,
		doo_lines_all dla,
		(SELECT okha.cust_po_number,
				okha.attribute8 ADN,
				okla.attribute3,
				okla.attribute4
		FROM 
			OKC_K_LINES_B okla,
			OKC_K_HEADERS_ALL_B okha
		WHERE 1=1
			AND okha.major_version = okla.major_version 
			AND okha.id = okla.chr_id
			 ) contract,	
		(SELECT attribute_char1,
				attribute_char7,
				attribute_char6,
				attribute_char10,
				attribute_char17,
				header_id										
		from doo_headers_eff_b where context_code = 'GED HEADER EFF CONTEXT') dha_eff,
		(SELECT a.attribute_char1,
			  a.attribute_char2,
			  a.attribute_char3,
			  a.attribute_char4,
			  header_id
              FROM DOO_HEADERS_EFF_B a
              WHERE a.context_code = 'GED HEADER EFF CONTEXT2'
			  AND  UPPER(a.attribute_char1) = 'TRUE') dha_eff1,
		(SELECT fle.attribute_char13 smart_part_desc,
				fle.attribute_char4  smart_part_number,
				TRUNC(fle.attribute_date1) service_start_date,
				TRUNC(fle.attribute_date2) service_end_date,
				fle.attribute_char2,
				fle.fulfill_line_id
			FROM   doo_fulfill_lines_eff_b fle
			WHERE    fle.context_code = 'GED Fline Context'
				AND fle.object_version_number = (SELECT MAX(a1.object_version_number)
													FROM DOO_FULFILL_LINES_EFF_B a1
													WHERE a1.fulfill_line_id =fle.fulfill_line_id)) dfl_eff,
		RA_INTERFACE_LINES_ALL ract,
		FUN_ALL_BUSINESS_UNITS_V a

	WHERE 1=1
			AND dha.header_id                    = dla.header_id
			AND dha.header_id                    = dfla.header_id
			AND dla.line_id                      = dfla.line_id
			AND dha.header_id                    = dha_eff.header_id(+)
			AND dha.header_id                    = dha_eff1.header_id(+)
			AND dha.header_id                    = bill_to_ad.header_id(+)
			AND dfla.fulfill_line_id             = dfl_eff.fulfill_line_id(+)
			AND dha.header_id                    = bill_to_ad.header_id(+)
			AND bill_to_ad.address_use_type(+)   = 'BILL_TO'
			AND dha.header_id                    = SHIP_TO_AD.HEADER_ID(+)
			AND ship_to_ad.address_use_type(+)   = 'SHIP_TO' 
			AND dha.order_number                 = contract.attribute3(+) 
			AND to_char(dla.line_number)         = contract.attribute4(+) 
			AND dha.object_version_number        = (SELECT MAX(oheader1.object_version_number)
																		  FROM doo_headers_all oheader1
																		 WHERE dha.order_number = oheader1.order_number
																		 AND oheader1.status_code NOT LIKE '%DOO%')  
			AND dha.status_code NOT LIKE '%DOO%'
			AND (dfla.status_code IN (:p_so_fulfillment_status) OR COALESCE(:p_so_fulfillment_status,NULL) IS NULL)
			AND (NVL((SELECT
						case when dbp1.periodicity_code IN ('MONTH','YEAR','DAY','QUARTER','WEEK') then 'Recurring billing'
								else 'One Time Billing'
								end 
						FROM DOO_BILLING_PLANS DBP1 
						WHERE dbp1.fulfill_line_id=dfla.fulfill_line_id
						AND billing_plan_id =(SELECT MAX(billing_plan_id)
											 FROM DOO_BILLING_PLANS DBP
											 WHERE dbp.fulfill_line_id=dfla.fulfill_line_id
					)),'One Time Billing')) = 'Recurring billing'
			AND (NVL(dha_eff.attribute_char1,'NULL') IN (:p_so_type) OR COALESCE(:p_so_type,NULL) IS NULL)
			AND dfla.status_code NOT IN ('CLOSED','AWAIT_BILLING','BILLED')				
			AND TO_CHAR(DFLA.fulfill_line_id) = ract.interface_line_attribute5(+)
			AND dha.order_number             = ract.interface_line_attribute3(+) 
			AND a.bu_name IN (SELECT fabuv.bu_name
			FROM FND_LOOKUP_VALUES flv,
			fun_all_business_units_v fabuv
			WHERE 1=1
			AND flv.lookup_code                      =  fabuv.bu_name
			AND flv.lookup_type                      = 'GED_BU_NAMES'
			AND LANGUAGE                             = 'US'
			AND flv.enabled_flag                     = 'Y'
			AND UPPER(NVL(flv.description, 'GED'))  != 'AVIATION')
			AND (a.BU_NAME IN (:P_BU) OR COALESCE(:P_BU,NULL) IS NULL)
			AND ract.org_id(+) = DHA.org_id 
			AND dha.org_id = a.bu_id			
	) Order_Details,
	--------------------------Order Details Ends Here-------------------------

	--------------------------Item Details Starts Here------------------------
	(SELECT 
			esib.item_number PART_NUMBER,
			eic.inventory_item_id,
			esib.description PART_DESC,
			ecb.attribute2 PRODUCT_FAMILY,
			ecb.attribute4 PRODUCT_LINE,
			ecb.attribute5 PRODUCT_TYPE,
			ecb.attribute6 PRODUCT_SUBTYPE,
			esib.SHIPPABLE_ITEM_FLAG   
	FROM    EGP_CATEGORIES_B ECB,
			INV_ORG_PARAMETERS IOP,
			EGP_CATEGORY_SETS_VL ECST,
			EGP_ITEM_CATEGORIES EIC,
			EGP_SYSTEM_ITEMS_VL ESIB
	WHERE 1=1
			AND ecb.category_id                  = eic.category_id
			AND esib.organization_id             = iop.organization_id
			AND iop.organization_code            = 'GED_IMO'
			AND ecst.category_set_name           = 'Global_Inv_Default_Catalog'
			AND eic.category_set_id              = ecst.category_set_id(+)
			AND esib.inventory_item_id           = eic.inventory_item_id
			AND esib.organization_id             = eic.organization_id 
			AND ecb.attribute6					NOT LIKE '%Default%'
			--AND esib.item_number NOT IN ('%Option%Class%','%OPTION%CLASS%','%OPT%CLASS%')
	) Item_Details,
	--------------------------------Item Details Ends Here------------------------

	--------------------------------Bill To-----------------------------------------
	(SELECT su.site_use_id,
			hca.customer_type,
			hp.party_name,
			hp.party_number,
			hca.account_number,
			hl.country,
			hca.attribute1
	  FROM  HZ_CUST_SITE_USES_ALL SU,
			HZ_CUST_ACCT_SITES_ALL CAS,
			HZ_PARTY_SITES HPS,
			HZ_LOCATIONS HL,
			HZ_PARTIES HP,
			HZ_CUST_ACCOUNTS HCA
	  WHERE SU.CUST_ACCT_SITE_ID = CAS.CUST_ACCT_SITE_ID
	  AND CAS.PARTY_SITE_ID      = HPS.PARTY_SITE_ID
	  AND HPS.LOCATION_ID        = HL.LOCATION_ID
	  AND HP.PARTY_ID            = HPS.PARTY_ID
	  AND CAS.CUST_ACCOUNT_ID    = HCA.CUST_ACCOUNT_ID
	  AND SU.SITE_USE_CODE       = 'BILL_TO'
	) BILL_TO,
	--------------------------------Bill To Ends---------------------------------
	--------------------------------Ship To Starts ------------------------------
	(SELECT hps.party_site_id,
		   hp.party_name,
		   hp.party_number ,  
		   hl.country   
	FROM HZ_PARTY_SITES hps,
		 HZ_LOCATIONS hl,
		 HZ_PARTIES hp,
		 HZ_PARTY_SITE_USES hpsu
	WHERE hp.party_id         = hps.party_id
	AND hps.location_id       = hl.location_id
	AND hps.party_site_id     = hpsu.party_site_id(+)
	AND hpsu.site_use_type    = 'SHIP_TO'
	AND NVL(hpsu.status, 'A') = 'A') SHIP_TO
	 --------------------------------Ship To Ends ---------------------------------------
WHERE 1=1
		AND Order_Details.inventory_item_id        = Item_Details.inventory_item_id
		AND Order_Details.cust_acct_site_use_id    = bill_to.site_use_id(+)
		AND Order_Details.party_site_id            = ship_to.party_site_id(+)
 ORDER BY order_details.order_number,
          order_details.line_number,
          order_details.fulfill_line_number