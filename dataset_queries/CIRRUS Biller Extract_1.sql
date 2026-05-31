SELECT rcta.name AS transaction_type,
	   rcta.type AS transaction_class,
	   aps.amount_due_remaining AS amount_due_remaining,
	   fc.precision,
	   hca.account_number,
	   ha.name AS organization_name,
	   rctl.customer_trx_id AS Customer_trx_id ,
	   rctl.customer_trx_line_id AS customer_trx_line_id,
	   rct.trx_number AS trx_number,
	   rct.org_id,
	   rct.bill_to_customer_id,
	   aps.payment_schedule_id,
	   lep.legal_entity_id,
	   lep.name AS legal_entity,
	   flv.meaning AS Receivable_Trx_name ,
	   arta.receivables_trx_id,
	   flv2.description AS Receipt_method,
	   'Success' AS status
  FROM RA_CUSTOMER_TRX_ALL rct,
	   RA_CUSTOMER_TRX_LINES_ALL rctl,
	   RA_CUST_TRX_TYPES_ALL rcta,
	   AR_PAYMENT_SCHEDULES_ALL aps,
	   HR_OPERATING_UNITS ha,
	   XLE_ENTITY_PROFILES lep,
	   HZ_CUST_ACCOUNTS hca ,
	   FND_LOOKUP_VALUES flv,
	   AR_RECEIVABLES_TRX_ALL arta,
	   FND_LOOKUP_VALUES flv2,
	   FND_CURRENCIES fc
 WHERE rct.cust_trx_type_seq_id		= rcta.cust_trx_type_seq_id
   AND rct.trx_class 				= 'INV'		--Added as part of Rel 11
   AND fc.currency_code 			= rct.invoice_currency_code
   AND rct.customer_trx_id       	= rctl.customer_trx_id
   AND aps.customer_trx_id       	= rct.customer_trx_id
   AND rct.complete_flag         	= 'Y'
   ---AND hca.customer_type='I'
   AND rct.org_id					= ha.organization_id
   --- and rct.org_id= XLOLV.operating_unit_id
   AND hca.cust_account_id 			= rct.bill_to_customer_id
   AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
   AND lep.legal_entity_id 			= ha.default_legal_context_id
   AND flv.lookup_type     			= 'GED BILLER EXTRACT LOOKUP'
   AND ha.name             			= flv.lookup_code(+)
   AND flv.language        			= 'US'
   AND flv.enabled_flag    			= 'Y'
   AND SYSDATE 						BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
   AND arta.name					= flv.meaning
   AND flv2.lookup_type     		= 'GED BILLER RCPT MTH MAPPING'
   AND ha.name||'-'||rct.invoice_currency_code = flv2.lookup_code
   AND flv2.language        		= 'US'
   AND flv2.enabled_flag    		= 'Y'
   AND SYSDATE 						BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)
UNION
 SELECT NULL AS transaction_type,
		NULL AS transaction_class,
		NULL AS amount_due_remaining,
		NULL AS precision,
		NULL AS account_number,
		NULL AS organization_name,
		TO_NUMBER(:P_CUST_TRX_ID) AS Customer_trx_id ,
		NULL AS customer_trx_line_id,
		:P_TRX_NUMBER AS trx_number,
		NULL AS org_id,
		NULL AS bill_to_customer_id,
		NULL AS payment_schedule_id,
		NULL AS legal_entity_id,
		NULL AS legal_entity,
		NULL AS Receivable_Trx_name ,
		NULL AS receivables_trx_id,
		NULL AS Receipt_method,
		--Added below logic as part of Rel 11
		DECODE( ( SELECT COUNT(1) FROM FND_LOOKUP_VALUES flv,
                                       AR_RECEIVABLES_TRX_ALL arta,
									   HR_OPERATING_UNITS ha,
									   RA_CUSTOMER_TRX_ALL rct
								 WHERE 1=1
                                   AND flv.lookup_type     ='GED BILLER EXTRACT LOOKUP'
                                   AND ha.name             = flv.lookup_code(+)
                                   AND flv.language        ='US'
                                   AND flv.enabled_flag    ='Y'
								   AND rct.org_id=ha.organization_id
								   AND (rct.trx_number=:P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
                                   AND SYSDATE BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
                                   AND arta.name=flv.meaning),0,'Failure: BU Mapping is missing in setup',DECODE(( SELECT COUNT(1) 
																                                            FROM  FND_LOOKUP_VALUES flv2,
                                                                                                                  HR_OPERATING_UNITS ha,
									                                                                              RA_CUSTOMER_TRX_ALL rct																
																                                            WHERE flv2.lookup_type     ='GED BILLER RCPT MTH MAPPING'
                                                                                                              AND ha.name||'-'||rct.invoice_currency_code = flv2.lookup_code
                                                                                                              AND flv2.language        ='US'
                                                                                                              AND flv2.enabled_flag    ='Y'
                                                                                                              AND rct.org_id=ha.organization_id
                                                                                                              AND (rct.trx_number=:P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
                                                                                                              AND SYSDATE BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)),0,'Failure: Receipt Method config (BU-Currency) is missing in setup')) AS status
		--Added above logic as part of Rel 11																									  
   FROM DUAL
  WHERE (SELECT COUNT(1)
		   FROM RA_CUSTOMER_TRX_ALL rct,
				RA_CUSTOMER_TRX_LINES_ALL rctl,
				RA_CUST_TRX_TYPES_ALL rcta,
				AR_PAYMENT_SCHEDULES_ALL aps,
				HR_OPERATING_UNITS ha,
				XLE_ENTITY_PROFILES lep,
				HZ_CUST_ACCOUNTS hca ,
				FND_LOOKUP_VALUES flv,
				AR_RECEIVABLES_TRX_ALL arta,
				FND_LOOKUP_VALUES flv2,
				FND_CURRENCIES fc
		  WHERE rct.cust_trx_type_seq_id=rcta.cust_trx_type_seq_id
			AND rct.trx_class 				= 'INV'		--Added as part of Rel 11
			AND fc.currency_code 			= rct.invoice_currency_code
			AND rct.customer_trx_id       	= rctl.customer_trx_id
			AND aps.customer_trx_id       	= rct.customer_trx_id
			AND rct.complete_flag         	= 'Y'
			---AND hca.customer_type='I'
			AND rct.org_id					= ha.organization_id
			--- and rct.org_id= XLOLV.operating_unit_id
			AND hca.cust_account_id 		= rct.bill_to_customer_id
			AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
			AND lep.legal_entity_id 		= ha.default_legal_context_id
			AND flv.lookup_type     		= 'GED BILLER EXTRACT LOOKUP'
			AND ha.name             		= flv.lookup_code(+)
			AND flv.language        		= 'US'
			AND flv.enabled_flag    		= 'Y'
			AND SYSDATE 					BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
			AND arta.name					= flv.meaning
			AND flv2.lookup_type     		= 'GED BILLER RCPT MTH MAPPING'
			AND ha.name||'-'||rct.invoice_currency_code = flv2.lookup_code
			AND flv2.language        		= 'US'
			AND flv2.enabled_flag    		= 'Y'
			AND SYSDATE 					BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)) = 0 
			AND (SELECT COUNT(1)
				   FROM RA_CUSTOMER_TRX_ALL 
			      WHERE trx_class 	= 'INV' 
			        AND (trx_number	= :P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID)) > 0  --Added as part of Rel 11
--Start of Receipt Reversal code - Added as part of Rel 11					
UNION
 SELECT rcta.name AS transaction_type,
        rcta.type AS transaction_class, 
        NULL AS amount_due_remaining,
		NULL AS precision,
		acr.receipt_number,
		hou.name AS organization_name,
		rct.customer_trx_id AS Customer_trx_id ,
		NULL AS customer_trx_line_id,
		rct.trx_number AS trx_number,
		rct.org_id,
		acr.cash_receipt_id,
		NULL AS payment_schedule_id,
		NULL AS legal_entity_id,
		NULL AS legal_entity,
		flv.meaning AS Receivable_Trx_name ,
		NULL AS receivables_trx_id,
		flv2.description AS Receipt_method,
		DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
											 FROM RA_CUSTOMER_TRX_ALL a, 
											      RA_CUSTOMER_TRX_LINES_ALL b 
											WHERE a.customer_trx_id 	= rct.customer_trx_id
											  AND a.customer_trx_id 	= b.customer_trx_id
											  AND a.org_id 				= rct.org_id) = 
										  (SELECT SUM(b.extended_amount) 
											 FROM RA_CUSTOMER_TRX_ALL a, 
												  RA_CUSTOMER_TRX_LINES_ALL b 
											WHERE a.customer_trx_id 	= rct1.customer_trx_id
											  AND a.customer_trx_id 	= b.customer_trx_id
											  AND a.org_id 				= rct1.org_id))
									 AND acr.amount = (SELECT ABS(SUM(b.extended_amount))
														 FROM RA_CUSTOMER_TRX_ALL a, 
															  RA_CUSTOMER_TRX_LINES_ALL b 
														WHERE a.customer_trx_id = rct.customer_trx_id
														  AND a.customer_trx_id = b.customer_trx_id
														  AND a.org_id = rct.org_id)
									 AND acr.currency_code = rct.invoice_currency_code),1,'Success', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																		  FROM RA_CUSTOMER_TRX_ALL a, 
																																			   RA_CUSTOMER_TRX_LINES_ALL b 
																																		 WHERE a.customer_trx_id = rct.customer_trx_id
																																		   AND a.customer_trx_id = b.customer_trx_id
																																		   AND a.org_id = rct.org_id) = 
																																	   (SELECT SUM(b.extended_amount) 
																																		  FROM RA_CUSTOMER_TRX_ALL a, RA_CUSTOMER_TRX_LINES_ALL b 
																																		 WHERE a.customer_trx_id = rct1.customer_trx_id
																																		   AND a.customer_trx_id = b.customer_trx_id
																																		   AND a.org_id = rct1.org_id))
																																		   AND ara.acctd_amount_applied_from = ara.acctd_amount_applied_to
																																		   AND acr.currency_code <> rct.invoice_currency_code),1,'Success', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																																												 FROM RA_CUSTOMER_TRX_ALL a, 
																																																												      RA_CUSTOMER_TRX_LINES_ALL b 
																																																												WHERE a.customer_trx_id 	= rct.customer_trx_id
																																																												  AND a.customer_trx_id 	= b.customer_trx_id
																																																												  AND a.org_id = rct.org_id) <= 
																																																											  (SELECT SUM(b.extended_amount) 
																																																												 FROM RA_CUSTOMER_TRX_ALL a, 
																																																												      RA_CUSTOMER_TRX_LINES_ALL b 
																																																												WHERE a.customer_trx_id = rct1.customer_trx_id
																																																												  AND a.customer_trx_id = b.customer_trx_id
																																																												  AND a.org_id = rct1.org_id))		
																																																										 AND acr.amount > (SELECT ABS(SUM(b.extended_amount))
																																																															 FROM RA_CUSTOMER_TRX_ALL a, RA_CUSTOMER_TRX_LINES_ALL b 
																																																															WHERE a.customer_trx_id = rct.customer_trx_id
																																																															  AND a.customer_trx_id = b.customer_trx_id
																																																															  AND a.org_id = rct.org_id)
																																																															  AND acr.currency_code = rct.invoice_currency_code),1, 'Failure: Partial CM', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																																																																												FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																													 RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																											   WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																												 AND a.customer_trx_id = b.customer_trx_id
																																																																																												 AND a.org_id = rct.org_id) < 
																																																																																										 	 (SELECT SUM(b.extended_amount) 
																																																																																												FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																													 RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																											   WHERE a.customer_trx_id = rct1.customer_trx_id
																																																																																												 AND a.customer_trx_id = b.customer_trx_id
																																																																																												 AND a.org_id = rct1.org_id))
																																																																																										AND acr.amount < (SELECT ABS(SUM(b.extended_amount))
																																																																																															FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																															     RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																														   WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																															 AND a.customer_trx_id = b.customer_trx_id
																																																																																															 AND a.org_id = rct.org_id)
																																																																																															AND acr.currency_code = rct.invoice_currency_code),1,'Failure: CM amount is greater than receipt', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																																																																																																																	FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																	     RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																   WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																																																																	 AND a.customer_trx_id = b.customer_trx_id
																																																																																																																																	 AND a.org_id = rct.org_id) >
																																																																																																																																 (SELECT SUM(b.extended_amount) 
																																																																																																																																	FROM RA_CUSTOMER_TRX_ALL a, RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																   WHERE a.customer_trx_id = rct1.customer_trx_id
																																																																																																																																	 AND a.customer_trx_id = b.customer_trx_id
																																																																																																																																	 AND a.org_id = rct1.org_id))),1,'Failure: CM amount is greator than Invoice amount','Failure: Reversal did not happen'))))) AS status
  FROM RA_CUSTOMER_TRX_ALL rct, 
       RA_CUSTOMER_TRX_ALL rct1,
	   RA_CUST_TRX_TYPES_ALL rcta,
	   AR_RECEIVABLE_APPLICATIONS_ALL ara,
	   AR_CASH_RECEIPTS_ALL acr,
	   HR_OPERATING_UNITS hou,
	   FND_LOOKUP_VALUES flv,
	   FND_LOOKUP_VALUES flv2
 WHERE rct.previous_customer_trx_id 	= rct1.customer_trx_id
   AND (rct.trx_number					= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
   AND rct.complete_flag         		= 'Y'
   AND rct.cust_trx_type_seq_id			= rcta.cust_trx_type_seq_id
   AND rct.trx_class 					= 'CM'
   AND rct1.trx_class 					= 'INV'
   AND rct.org_id 						= rct1.org_id
   AND hou.organization_id 				= rct.org_id
   AND ara.applied_customer_trx_id		= rct1.customer_trx_id
   AND ara.cash_receipt_id				= acr.cash_receipt_id
   AND acr.status						<> 'REV'   
   AND ara.status 						= 'APP'
   AND flv.lookup_type					= 'GED BILLER EXTRACT LOOKUP'
   AND hou.name             			= flv.lookup_code(+)
   AND flv.language        				= 'US'
   AND flv.enabled_flag    				= 'Y'
   AND SYSDATE 							BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
   AND flv2.lookup_type     			= 'GED BILLER RCPT MTH MAPPING'
   AND hou.name||'-'||rct1.invoice_currency_code = flv2.lookup_code
   AND flv2.language        			= 'US'
   AND flv2.enabled_flag    			= 'Y'
   AND SYSDATE 							BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)
   AND (SELECT COUNT(b.cash_receipt_id)  
          FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
			   AR_CASH_RECEIPTS_ALL b
	     WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
		   AND a.cash_receipt_id			= b.cash_receipt_id  
           AND a.status = 'APP'
		   AND b.status <> 'REV') = 1
   AND ((SELECT COUNT(b.cash_receipt_id)  
           FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
				AR_CASH_RECEIPTS_ALL b,
				RA_CUSTOMER_TRX_ALL rct, 
				RA_CUSTOMER_TRX_ALL rct1
		  WHERE a.applied_customer_trx_id 		= rct1.customer_trx_id
			AND rct.previous_customer_trx_id 	= rct1.customer_trx_id
		    AND rct.complete_flag         		= 'Y'
		    AND (rct.trx_number					= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
		    AND rct.trx_class 					= 'CM'
		    AND rct1.trx_class 					= 'INV'
		    AND b.currency_code 				<> rct.invoice_currency_code
		    AND a.acctd_amount_applied_from 	<> a.acctd_amount_applied_to 
		    AND rct.org_id 						= rct1.org_id
		    AND a.applied_customer_trx_id		= rct1.customer_trx_id
		    AND a.cash_receipt_id				= b.cash_receipt_id  
		    AND a.status = 'APP'
			AND b.status <> 'REV') = 0)
UNION
 SELECT rcta.name AS transaction_type,
        rcta.type AS transaction_class, 
        NULL AS amount_due_remaining,
		NULL AS precision,
	    acr.receipt_number,
	    hou.name AS organization_name,
	    rct.customer_trx_id AS Customer_trx_id ,  
	    NULL AS customer_trx_line_id,
	    rct.trx_number AS trx_number,  
	    rct.org_id,
	    acr.cash_receipt_id,
	    NULL AS payment_schedule_id,
	    NULL AS legal_entity_id,
	    NULL AS legal_entity,
	    flv.meaning AS Receivable_Trx_name ,
	    NULL AS receivables_trx_id,
	    flv2.description Receipt_method,
		DECODE((SELECT 1 FROM DUAL WHERE ((SELECT SUM(b.amount)  
											 FROM AR_RECEIVABLE_APPLICATIONS_ALL a, 
											      AR_CASH_RECEIPTS_ALL b
											WHERE a.applied_customer_trx_id = rct1.customer_trx_id
											  AND a.cash_receipt_id			= b.cash_receipt_id  
											  AND a.status = 'APP'
											  AND b.status <> 'REV') = 
										  (SELECT ABS(SUM(b.extended_amount))
											 FROM RA_CUSTOMER_TRX_ALL a, 
											      RA_CUSTOMER_TRX_LINES_ALL b 
										    WHERE a.customer_trx_id 		= rct.customer_trx_id
											  AND a.customer_trx_id 		= b.customer_trx_id
											  AND a.org_id 					= rct.org_id))),1,'Success', DECODE((SELECT 1 FROM DUAL WHERE (((SELECT ABS(SUM(b.extended_amount))
																																			   FROM RA_CUSTOMER_TRX_ALL a, 
																																			        RA_CUSTOMER_TRX_LINES_ALL b 
																																			  WHERE a.customer_trx_id 		= rct.customer_trx_id
																																				AND a.customer_trx_id 		= b.customer_trx_id
																																				AND a.org_id = rct.org_id) 	= acr.amount)
																																	   AND ((SELECT COUNT(b.cash_receipt_id)  
																																			   FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																				    AR_CASH_RECEIPTS_ALL b
																																			  WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
																																			    AND a.cash_receipt_id			= b.cash_receipt_id
																																			    AND b.amount 					= acr.amount
																																				AND b.status 					<> 'REV'
																																			    AND a.status 					= 'APP') = 1))),1, 'Success', DECODE((SELECT 1 FROM DUAL WHERE (((SELECT ABS(SUM(b.extended_amount))
																																																													FROM RA_CUSTOMER_TRX_ALL a, 
																																																													     RA_CUSTOMER_TRX_LINES_ALL b 
																																																												   WHERE a.customer_trx_id 	= rct.customer_trx_id
																																																													 AND a.customer_trx_id 	= b.customer_trx_id
																																																													 AND a.org_id 			= rct.org_id) <> acr.amount)
																																																											AND ((SELECT COUNT(b.cash_receipt_id)  
																																																													FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																													     AR_CASH_RECEIPTS_ALL b
																																																												   WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
																																																												     AND a.cash_receipt_id			= b.cash_receipt_id
																																																													 AND b.status 					<> 'REV'
																																																													 AND b.amount 					= (SELECT ABS(SUM(b.extended_amount))
																																																																						 FROM RA_CUSTOMER_TRX_ALL a, 
																																																																						      RA_CUSTOMER_TRX_LINES_ALL b 
																																																																						WHERE a.customer_trx_id = rct.customer_trx_id
																																																																						  AND a.customer_trx_id = b.customer_trx_id
																																																																						  AND a.org_id = rct.org_id)
																																																													 AND a.status = 'APP') = 1))),1, 'No Action Required: Other receipt will be reversed for this Credit Memo', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																																																																																	 FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																	      RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																	WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																																	  AND a.customer_trx_id = b.customer_trx_id
																																																																																																	  AND a.org_id 			= rct.org_id) <= 
																																																																																																  (SELECT SUM(b.extended_amount) 
																																																																																																	 FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																	      RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																	WHERE a.customer_trx_id = rct1.customer_trx_id
																																																																																																	  AND a.customer_trx_id = b.customer_trx_id
																																																																																																	  AND a.org_id = rct1.org_id))
																																																																																															 AND (SELECT SUM(b.amount)
																																																																																																	FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																																																																		 AR_CASH_RECEIPTS_ALL b
																																																																																																   WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
																																																																																																	 AND a.cash_receipt_id			= b.cash_receipt_id
																																																																																																	 AND b.status 					<> 'REV'
																																																																																																	 AND a.status 					= 'APP') < (SELECT ABS(SUM(b.extended_amount))
																																																																																																												  FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																												       RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																												 WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																																												   AND a.customer_trx_id = b.customer_trx_id
																																																																																																												   AND a.org_id 		 = rct.org_id)),1,'Failure: CM amount is greater than all the receipts', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																																																																																																																													  FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																													       RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																													 WHERE a.customer_trx_id 	= rct.customer_trx_id
																																																																																																																																													   AND a.customer_trx_id 	= b.customer_trx_id
																																																																																																																																													   AND a.org_id 			= rct.org_id) <=
																																																																																																																																												   (SELECT SUM(b.extended_amount) 
																																																																																																																																													  FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																													       RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																													 WHERE a.customer_trx_id 	= rct1.customer_trx_id
																																																																																																																																													   AND a.customer_trx_id 	= b.customer_trx_id
																																																																																																																																													   AND a.org_id 			= rct1.org_id)) 
																																																																																																																																											  AND ((SELECT COUNT(b.cash_receipt_id)
																																																																																																																																													  FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																																																																																																														   AR_CASH_RECEIPTS_ALL b
																																																																																																																																													 WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
																																																																																																																																													   AND a.cash_receipt_id			= b.cash_receipt_id
																																																																																																																																													   AND b.status 					<> 'REV'
																																																																																																																																													   AND a.status 					= 'APP'
																																																																																																																																													   AND b.amount 					=  (SELECT ABS(SUM(b.extended_amount))
																																																																																																																																																							  FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																							       RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																																							 WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																																																																																							   AND a.customer_trx_id = b.customer_trx_id
																																																																																																																																																							   AND a.org_id = rct1.org_id)) > 1)),1,'Failure: Multiple Receipts found', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT ABS(SUM(b.extended_amount))
																																																																																																																																																																																			 FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																																																				  RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																																																																			WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																																																																																																																			  AND a.customer_trx_id = b.customer_trx_id
																																																																																																																																																																																			  AND a.org_id 			= rct.org_id) <= 
																																																																																																																																																																																		   (SELECT SUM(b.extended_amount) 
																																																																																																																																																																																			  FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																																																			       RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																																																																			 WHERE a.customer_trx_id = rct1.customer_trx_id
																																																																																																																																																																																			   AND a.customer_trx_id = b.customer_trx_id
																																																																																																																																																																																			   AND a.org_id 		 = rct1.org_id))
																																																																																																																																																																																	 AND ((SELECT SUM(b.amount)
																																																																																																																																																																																			 FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																																																																																																																																																				  AR_CASH_RECEIPTS_ALL b
																																																																																																																																																																																			WHERE a.applied_customer_trx_id = rct1.customer_trx_id
																																																																																																																																																																																			  AND a.cash_receipt_id			= b.cash_receipt_id
																																																																																																																																																																																			  AND b.status 					<> 'REV'
																																																																																																																																																																																			  AND a.status 					= 'APP') > (SELECT ABS(SUM(b.extended_amount))
																																																																																																																																																																																														  FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																																																														       RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																																																																														 WHERE a.customer_trx_id 	= rct.customer_trx_id
																																																																																																																																																																																														   AND a.customer_trx_id 	= b.customer_trx_id
																																																																																																																																																																																													       AND a.org_id 			= rct.org_id))
																																																																																																																																																																																	 AND ((SELECT ABS(SUM(b.extended_amount))
																																																																																																																																																																																	   	     FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																																																			      RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																																																																			WHERE a.customer_trx_id = rct.customer_trx_id
																																																																																																																																																																																			  AND a.customer_trx_id = b.customer_trx_id
																																																																																																																																																																																			  AND a.org_id = rct.org_id) <> (SELECT b.amount
																																																																																																																																																																																											   FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																																																																																																																																																													AR_CASH_RECEIPTS_ALL b
																																																																																																																																																																																											  WHERE a.applied_customer_trx_id = rct1.customer_trx_id
																																																																																																																																																																																											    AND b.status <> 'REV'
																																																																																																																																																																																											    AND a.cash_receipt_id= b.cash_receipt_id
																																																																																																																																																																																											    AND b.cash_receipt_id = acr.cash_receipt_id
																																																																																																																																																																																											    AND a.status = 'APP'))),1,'Failure: Partial CM','Failure: Reversal did not happen')))))) AS status	   
   FROM RA_CUSTOMER_TRX_ALL rct, 
		RA_CUSTOMER_TRX_ALL rct1,
		RA_CUST_TRX_TYPES_ALL rcta,
		AR_RECEIVABLE_APPLICATIONS_ALL ara,
		AR_CASH_RECEIPTS_ALL acr,
		HR_OPERATING_UNITS hou,
		FND_LOOKUP_VALUES flv,
		FND_LOOKUP_VALUES flv2
  WHERE rct.previous_customer_trx_id 	= rct1.customer_trx_id  
	AND (rct.trx_number					= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
	AND rct.complete_flag         		= 'Y'  
	AND rct.cust_trx_type_seq_id		= rcta.cust_trx_type_seq_id
	AND rct.trx_class 					= 'CM'
	AND rct1.trx_class 					= 'INV'
	AND rct.org_id 						= rct1.org_id
	AND hou.organization_id 			= rct.org_id
	AND ara.applied_customer_trx_id		= rct1.customer_trx_id
	AND ara.cash_receipt_id				= acr.cash_receipt_id  
	AND acr.currency_code 				= rct.invoice_currency_code
	AND acr.status 						<> 'REV'
	AND ara.status 						= 'APP'
	AND flv.lookup_type					= 'GED BILLER EXTRACT LOOKUP'
	AND hou.name             			= flv.lookup_code(+)
	AND flv.language        			= 'US'
	AND flv.enabled_flag    			= 'Y'
	AND SYSDATE 						BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
	AND flv2.lookup_type     			= 'GED BILLER RCPT MTH MAPPING'
	AND hou.name||'-'||rct1.invoice_currency_code = flv2.lookup_code
	AND flv2.language        			= 'US'
	AND flv2.enabled_flag    			= 'Y'
	AND SYSDATE 						BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)  
	AND (SELECT COUNT(b.cash_receipt_id)  
           FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
			    AR_CASH_RECEIPTS_ALL b
	      WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
		    AND a.cash_receipt_id			= b.cash_receipt_id
			AND b.status 					<> 'REV'
            AND a.status 					= 'APP') > 1
UNION
 SELECT NULL AS transaction_type,
        NULL AS transaction_class,
		NULL AS amount_due_remaining,
		NULL AS precision,
		NULL AS account_number,
		NULL  AS organization_name,
		TO_NUMBER(:P_CUST_TRX_ID) AS Customer_trx_id ,
		NULL AS customer_trx_line_id,
		:P_TRX_NUMBER AS trx_number,
		NULL  AS org_id,
		NULL  AS bill_to_customer_id,
		NULL AS payment_schedule_id,
		NULL  AS legal_entity_id,
		NULL  AS  legal_entity,
		NULL  AS  Receivable_Trx_name ,
		NULL AS receivables_trx_id,
		NULL  AS Receipt_method,
		DECODE((SELECT COUNT(1) FROM FND_LOOKUP_VALUES flv,
                                     AR_RECEIVABLES_TRX_ALL arta,
									 HR_OPERATING_UNITS ha,
									 RA_CUSTOMER_TRX_ALL rct
							   WHERE 1=1
                                 AND flv.lookup_type     = 'GED BILLER EXTRACT LOOKUP'
                                 AND ha.name             = flv.lookup_code(+)
                                 AND flv.language        = 'US'
                                 AND flv.enabled_flag    = 'Y'
								 AND rct.org_id			 = ha.organization_id
								 AND (rct.trx_number	 = :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
								 AND rct.trx_class 		 = 'CM'
                                 AND SYSDATE 			 BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
                                 AND arta.name			 = flv.meaning),0,'Failure: BU Mapping is missing in setup', DECODE(( SELECT COUNT(1) 
																																FROM  FND_LOOKUP_VALUES flv2,
																																	  HR_OPERATING_UNITS ha,
																																	  RA_CUSTOMER_TRX_ALL rct																
																																WHERE flv2.lookup_type      = 'GED BILLER RCPT MTH MAPPING'
																																  AND ha.name||'-'||rct.invoice_currency_code = flv2.lookup_code
																																  AND flv2.language         = 'US'
																																  AND flv2.enabled_flag     = 'Y'
																																  AND rct.org_id			= ha.organization_id
																																  AND (rct.trx_number		= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
																																  AND rct.trx_class 		= 'CM'
																																  AND SYSDATE 				BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)),0,'Failure: Receipt Method config (BU-Currency) is missing in setup',DECODE((SELECT 1 FROM DUAL WHERE ((SELECT COUNT(1)
																																																																																						 FROM RA_CUSTOMER_TRX_ALL rct, 
																																																																																						      RA_CUSTOMER_TRX_ALL rct1
																																																																																						WHERE rct.previous_customer_trx_id 	= rct1.customer_trx_id
																																																																																						  AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
																																																																																						  AND rct.trx_class 				= 'CM'
																																																																																						  AND rct1.trx_class 				= 'INV'
																																																																																						  AND rct.org_id 					= rct1.org_id) = 0)
																																																																																				 AND ((SELECT COUNT(1)
																																																																																						 FROM RA_CUSTOMER_TRX_ALL rct
																																																																																						WHERE (rct.trx_number	= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
																																																																																						  AND rct.trx_class 	= 'CM') >0 )),1,'Failure: There is no Invoice/Receipt found for this CM', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT COUNT(1)
																																																																																																																							   FROM RA_CUSTOMER_TRX_ALL rct, 
																																																																																																																								    RA_CUSTOMER_TRX_ALL rct1
																																																																																																																							  WHERE rct.previous_customer_trx_id 	= rct1.customer_trx_id
																																																																																																																							    AND (rct.trx_number					=:P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
																																																																																																																							    AND rct.trx_class 					= 'CM'
																																																																																																																							    AND rct1.trx_class 					= 'INV'
																																																																																																																							    AND rct.org_id 						= rct1.org_id) > 0) 
																																																																																																																					   AND ((SELECT COUNT(b.cash_receipt_id)  
																																																																																																																						       FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																																																																																									AR_CASH_RECEIPTS_ALL b,
																																																																																																																									RA_CUSTOMER_TRX_ALL rct, 
																																																																																																																									RA_CUSTOMER_TRX_ALL rct1
																																																																																																																							  WHERE a.applied_customer_trx_id 		= rct1.customer_trx_id
																																																																																																																								AND rct.previous_customer_trx_id 	= rct1.customer_trx_id
																																																																																																																							    AND (rct.trx_number					= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
																																																																																																																							    AND rct.trx_class 					= 'CM'
																																																																																																																							    AND rct1.trx_class 					= 'INV'
																																																																																																																							    AND rct.org_id 						= rct1.org_id
																																																																																																																							    AND a.applied_customer_trx_id		= rct1.customer_trx_id
																																																																																																																							    AND a.cash_receipt_id				= b.cash_receipt_id
																																																																																																																								AND b.status 						<> 'REV'	
																																																																																																																							    AND a.status 						= 'APP') = 0)),1,'Failure: There is no valid receipt found for this CM', DECODE((SELECT 1 FROM DUAL WHERE (((SELECT ABS(SUM(b.extended_amount))
																																																																																																																																																													 FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																														  RA_CUSTOMER_TRX_LINES_ALL b 
																																																																																																																																																													WHERE a.customer_trx_id 	= b.customer_trx_id
																																																																																																																																																													  AND (a.trx_number			= :P_TRX_NUMBER OR a.customer_trx_id=:P_CUST_TRX_ID)
																																																																																																																																																													  AND a.trx_class 			= 'CM') <= 
																																																																																																																																																												  (SELECT SUM(b.extended_amount) 
																																																																																																																																																													 FROM RA_CUSTOMER_TRX_ALL a, 
																																																																																																																																																														  RA_CUSTOMER_TRX_LINES_ALL b, 
																																																																																																																																																														  RA_CUSTOMER_TRX_ALL c
																																																																																																																																																													WHERE (a.trx_number					=:P_TRX_NUMBER OR a.customer_trx_id=:P_CUST_TRX_ID)
																																																																																																																																																													  AND a.trx_class 					= 'CM'
																																																																																																																																																													  AND c.trx_class 					= 'INV'
																																																																																																																																																													  AND a.previous_customer_trx_id 	= c.customer_trx_id
																																																																																																																																																													  AND c.customer_trx_id 			= b.customer_trx_id))
																																																																																																																																																												 AND 
																																																																																																																																																												  ((SELECT COUNT(b.cash_receipt_id)  
																																																																																																																																																													  FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
																																																																																																																																																														   AR_CASH_RECEIPTS_ALL b,
																																																																																																																																																														   RA_CUSTOMER_TRX_ALL rct, 
																																																																																																																																																														   RA_CUSTOMER_TRX_ALL rct1
																																																																																																																																																													 WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
																																																																																																																																																													   AND rct.previous_customer_trx_id = rct1.customer_trx_id
																																																																																																																																																													   AND rct.complete_flag         	= 'Y'
																																																																																																																																																													   AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
																																																																																																																																																													   AND rct.trx_class 				= 'CM'
																																																																																																																																																													   AND rct1.trx_class 				= 'INV'
																																																																																																																																																													   AND b.status 					<> 'REV'
																																																																																																																																																													   AND b.currency_code 				<> rct.invoice_currency_code
																																																																																																																																																													   AND a.acctd_amount_applied_from 	<> a.acctd_amount_applied_to 
																																																																																																																																																													   AND rct.org_id 					= rct1.org_id
																																																																																																																																																													   AND a.applied_customer_trx_id	= rct1.customer_trx_id
																																																																																																																																																													   AND a.cash_receipt_id			= b.cash_receipt_id  
																																																																																																																																																													   AND a.status 					= 'APP') > 0))),1,'Failure: Cross Currency Receipt not reversed','Failure: Reversal did not happen'))))) AS status
   FROM DUAL
  WHERE (SELECT COUNT(1) 
           FROM RA_CUSTOMER_TRX_ALL 
		  WHERE trx_class 	= 'CM' 
		    AND (trx_number	= :P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID)) > 0
    AND (
			 ((SELECT COUNT(1)
				 FROM RA_CUSTOMER_TRX_ALL rct, 
					  RA_CUSTOMER_TRX_ALL rct1
				WHERE rct.previous_customer_trx_id 	= rct1.customer_trx_id
				  AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
				  AND rct.complete_flag         	= 'Y'
				  AND rct.trx_class 				= 'CM'
				  AND rct1.trx_class 				= 'INV'
				  AND rct.org_id 					= rct1.org_id) = 0)
		  OR
		    (
			   ((SELECT COUNT(1)
				   FROM RA_CUSTOMER_TRX_ALL rct, 
					    RA_CUSTOMER_TRX_ALL rct1
				  WHERE rct.previous_customer_trx_id 	= rct1.customer_trx_id
				    AND (rct.trx_number					= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
				    AND rct.complete_flag         		= 'Y'
				    AND rct.trx_class 					= 'CM'
				    AND rct1.trx_class 					= 'INV'
				    AND rct.org_id = rct1.org_id) 		> 0) 
				AND 
				(
					  ((SELECT COUNT(b.cash_receipt_id)  
						  FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
							   AR_CASH_RECEIPTS_ALL b,
							   RA_CUSTOMER_TRX_ALL rct, 
							   RA_CUSTOMER_TRX_ALL rct1
						 WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
						   AND rct.previous_customer_trx_id = rct1.customer_trx_id
						   AND rct.complete_flag         	= 'Y'
						   AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
						   AND rct.trx_class 				= 'CM'
						   AND rct1.trx_class 				= 'INV'
						   AND rct.org_id 					= rct1.org_id
						   AND a.applied_customer_trx_id	= rct1.customer_trx_id
						   AND a.cash_receipt_id			= b.cash_receipt_id
						   AND b.status 					<> 'REV'
						   AND a.status 					= 'APP') = 0 )
					  OR
					  (
						   ((SELECT ABS(SUM(b.extended_amount))
							  FROM RA_CUSTOMER_TRX_ALL a, 
							       RA_CUSTOMER_TRX_LINES_ALL b 
							 WHERE a.customer_trx_id 	= b.customer_trx_id
							   AND (a.trx_number		= :P_TRX_NUMBER OR a.customer_trx_id=:P_CUST_TRX_ID)
							   AND a.trx_class 			= 'CM') <= 
						   (SELECT SUM(b.extended_amount) 
							  FROM RA_CUSTOMER_TRX_ALL a, 
								   RA_CUSTOMER_TRX_LINES_ALL b, 
								   RA_CUSTOMER_TRX_ALL c
							 WHERE (a.trx_number				= :P_TRX_NUMBER OR a.customer_trx_id=:P_CUST_TRX_ID)
							   AND a.trx_class 					= 'CM'
							   AND c.trx_class 					= 'INV'
							   AND a.previous_customer_trx_id 	= c.customer_trx_id
							   AND c.customer_trx_id 			= b.customer_trx_id))
						AND 
						  ((SELECT COUNT(b.cash_receipt_id)  
							  FROM AR_RECEIVABLE_APPLICATIONS_ALL a,
								   AR_CASH_RECEIPTS_ALL b,
							       RA_CUSTOMER_TRX_ALL rct, 
							       RA_CUSTOMER_TRX_ALL rct1
							 WHERE a.applied_customer_trx_id 	= rct1.customer_trx_id
							   AND rct.previous_customer_trx_id = rct1.customer_trx_id
							   AND rct.complete_flag         	= 'Y'
							   AND (rct.trx_number				= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
							   AND rct.trx_class 				= 'CM'
							   AND rct1.trx_class 				= 'INV'
							   AND b.currency_code 				<> rct.invoice_currency_code
							   AND a.acctd_amount_applied_from 	<> a.acctd_amount_applied_to
							   AND b.status 					<> 'REV'	
							   AND rct.org_id 					= rct1.org_id
							   AND a.applied_customer_trx_id	= rct1.customer_trx_id
							   AND a.cash_receipt_id			= b.cash_receipt_id  
							   AND a.status 					= 'APP') > 0)
					  )
				)
		     )
		  OR
			(
				((SELECT COUNT(1) FROM FND_LOOKUP_VALUES flv,
									   AR_RECEIVABLES_TRX_ALL arta,
									   HR_OPERATING_UNITS ha,
									   RA_CUSTOMER_TRX_ALL rct
								 WHERE 1=1
								   AND flv.lookup_type     	= 'GED BILLER EXTRACT LOOKUP'
								   AND ha.name             	= flv.lookup_code(+)
								   AND flv.language        	= 'US'
								   AND flv.enabled_flag    	= 'Y'
								   AND rct.org_id			= ha.organization_id
								   AND (rct.trx_number		= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
								   AND rct.trx_class 		= 'CM'
								   AND SYSDATE 				BETWEEN NVL(flv.start_date_active,SYSDATE) AND NVL(flv.end_date_active,SYSDATE)
								   AND arta.name			= flv.meaning) = 0) OR 
				((SELECT COUNT(1) FROM FND_LOOKUP_VALUES flv2,
									   HR_OPERATING_UNITS ha,
									   RA_CUSTOMER_TRX_ALL rct																
								 WHERE flv2.lookup_type    	= 'GED BILLER RCPT MTH MAPPING'
								   AND ha.name||'-'||rct.invoice_currency_code = flv2.lookup_code
								   AND flv2.language        = 'US'
								   AND flv2.enabled_flag    = 'Y'
								   AND rct.org_id			= ha.organization_id
								   AND (rct.trx_number		= :P_TRX_NUMBER OR rct.customer_trx_id=:P_CUST_TRX_ID)
								   AND rct.trx_class 		= 'CM'
								   AND SYSDATE 				BETWEEN NVL(flv2.start_date_active,SYSDATE) AND NVL(flv2.end_date_active,SYSDATE)) = 0)
			)
		)										                                            
UNION
 SELECT NULL AS transaction_type,
        NULL AS transaction_class,
        NULL AS amount_due_remaining,
	    NULL AS precision,
	    NULL AS account_number,
	    NULL  AS organization_name,
	    TO_NUMBER(:P_CUST_TRX_ID) AS Customer_trx_id ,
        NULL AS customer_trx_line_id,
	    :P_TRX_NUMBER AS trx_number,
	    NULL  AS org_id,
	    NULL  AS bill_to_customer_id,
	    NULL AS payment_schedule_id,
	    NULL  AS legal_entity_id,
	    NULL  AS  legal_entity,
	    NULL  AS  Receivable_Trx_name ,
	    NULL AS receivables_trx_id,
	    NULL  AS Receipt_method,
	    DECODE((SELECT 1 FROM DUAL WHERE ((SELECT COUNT(1) 
                                             FROM RA_CUSTOMER_TRX_ALL 
									        WHERE (trx_number=:P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID)) = 0)),1, 'Failure: No record found', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT COUNT(1) 
																																														  FROM RA_CUSTOMER_TRX_ALL 
																																														 WHERE (trx_number=:P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID) 
																																														   AND trx_class IN ('INV','CM')) = 0)), 1, 'Failure: Invalid transaction type / There is no Invoice or Receipt found for this CM', DECODE((SELECT 1 FROM DUAL WHERE ((SELECT COUNT(1) 
																																																																																	  FROM RA_CUSTOMER_TRX_ALL 
																																																																																	 WHERE (trx_number=:P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID) 
																																																																																	   AND trx_class IN ('INV','CM')
																																																																																	   AND complete_flag <> 'Y') > 0)),1, 'Failure: Transaction not in Complete State','Failure: Reversal did not happen'))) AS status
   FROM DUAL	 
  WHERE (
			((SELECT COUNT(1) 
				FROM RA_CUSTOMER_TRX_ALL 
			   WHERE (trx_number=:P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID)) = 0)
		OR
			((SELECT COUNT(1) 
				FROM RA_CUSTOMER_TRX_ALL 
			   WHERE (trx_number=:P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID) 
			     AND trx_class IN ('INV','CM')) = 0)
		OR
			((SELECT COUNT(1) 
			    FROM RA_CUSTOMER_TRX_ALL 
			   WHERE (trx_number=:P_TRX_NUMBER OR customer_trx_id=:P_CUST_TRX_ID) 
			     AND trx_class IN ('INV','CM') 
				 AND complete_flag <> 'Y') > 0)
		)
--End of Receipt Reversal code - Added as part of Rel 11