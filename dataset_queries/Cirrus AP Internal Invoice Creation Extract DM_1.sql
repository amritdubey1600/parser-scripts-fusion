/*
--#-----------------------------------------------------------------------------------------------------#
--# DESCRIPTION   :Cirrus AP Internal Invoice Creation Extract
--# CREATION DATE :09-DEC-19
--# CREATED BY    : Siva kumar Dandu
--# REL-35
--# MODIFICATION HISTORY:
--# CR#              Author               Date        Description
--#-----------------------------------------------------------------------------------------------------#
--#1			siva kumar Dandu		09-DEC-19		Report to create AP Invoice from AR Invoices.
--#-----------------------------------------------------------------------------------------------------#
*/

SELECT *
FROM((SELECT DISTINCT 1 KEY
			,a.customer_trx_id
			,(SELECT name
				FROM HR_ALL_ORGANIZATION_UNITS 
			   WHERE organization_id = (SELECT DISTINCT attribute2
											FROM FND_LOOKUP_VALUES 
										   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
											 AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) ))
											 AS business_unit
			,'External' AS source
			,a.trx_number AS invoice_number
			,(SELECT SUM(extended_amount) FROM RA_CUSTOMER_TRX_LINES_ALL WHERE customer_trx_id =a.customer_trx_id)AS invoice_amount
			,TO_CHAR(a.creation_date,'YYYY-MM-DD') AS invoice_date
			,(SELECT DISTINCT tag 
				FROM FND_LOOKUP_VALUES 
			   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
			     AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) ) AS supplier_name
			,(SELECT DISTINCT attribute4 
				FROM FND_LOOKUP_VALUES 
			   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
			     AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) ) AS supplier_number			
			,(SELECT DISTINCT attribute5 
				FROM FND_LOOKUP_VALUES 
			   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
			     AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) ) AS supplier_site
			,a.invoice_currency_code AS invoice_currency 
			,a.invoice_currency_code AS payment_currency
			,'FBDI IC AP INVOICE' AS description
			,'AR_INTER_CO'  AS import_set
			,(CASE WHEN a.trx_class IN ('CM','ONACC') THEN 'CREDIT' ELSE 'STANDARD' END) AS invoice_type
			,(SELECT DISTINCT description 
				FROM FND_LOOKUP_VALUES 
			   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
			     AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) ) AS legal_entity
			,'Immediate' AS payment_term
			,TO_CHAR(a.creation_date,'YYYY-MM-DD') AS terms_date
			,TO_CHAR(a.creation_date,'YYYY-MM-DD') AS accounting_date
			,'WIRE' AS payment_method
			,'N' AS calculate_tax_during_import
			,'N' AS add_tax_to_invoice_amount
			,j.lookup_code
			,'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) AS ap_lookup_code
			,(SELECT  DECODE(REGEXP_SUBSTR(hps.party_site_name,'BUC',1,1),'BUC',SUBSTR(hps.party_site_name,1,6),hzca.attribute3) 
			    FROM HZ_CUST_ACCT_SITES_ALL hzca,
		             HZ_PARTY_SITES         hps,
		             HZ_CUST_SITE_USES_ALL  hcs
		       WHERE 1=1
			     AND hzca.party_site_id = hps.party_site_id
			     AND hzca.cust_acct_site_id = hcs.cust_acct_site_id
			     AND hcs.site_use_code = 'BILL_TO'
			     AND hcs.site_use_id = a.bill_to_site_use_id) to_buc
  FROM RA_CUSTOMER_TRX_ALL          a
      ,HR_ALL_ORGANIZATION_UNITS    c
	  ,HR_ORGANIZATION_INFORMATION  d
	  ,GL_LEDGERS                   e
	  ,RA_CUST_TRX_LINE_GL_DIST_ALL f
	  ,xla_ae_headers 				g
	  ,XLA_AE_LINES                 h
	  ,XLA_DISTRIBUTION_LINKS       i
	  ,FND_LOOKUP_VALUES            j
 WHERE  1=1
   AND a.org_id              			= c.organization_id
   AND TO_NUMBER (d.org_information3) 	= e.ledger_id
   AND d.org_information_context 		= 'FUN_BUSINESS_UNIT'
   AND d.organization_id 				= a.org_id
   AND f.event_id        				= g.event_id
   AND f.customer_trx_id 				= a.customer_trx_id
   AND g.ae_header_id    				= h.ae_header_id
   AND g.ae_header_id    				= i.ae_header_id
   AND h.ae_line_num     				= i.ae_line_num
   AND g.gl_transfer_date 				IS NOT NULL
   AND j.lookup_type (+)     			= 'CIRRUSARAP_IBS_INTER_CO_EXCLUD'
   AND j.enabled_flag        			= 'Y'
   AND a.legal_entity_id 				= j.attribute1
   AND a.bill_to_customer_id 			= j.attribute3
   AND a.org_id         				= j.attribute2
   AND e.name 							= NVL(:ledger_name,e.name)
   AND c.name 							= NVL(:business_unit,c.name)
   AND a.trx_number 					= NVL(:p_invoice_number,a.trx_number)								  
   AND a.last_update_date > (SELECT MAX(reh.processstart)
							   FROM FUSION_ORA_ESS.request_property rep1
								   ,ESS_REQUEST_HISTORY 			 reh 
						      WHERE rep1.requestid = reh.requestid
							    AND reh.definition = 'JobDefinition://oracle/apps/ess/custom/AP/CIRRUS_AP_IC_01'
							    AND reh.executable_status = 'SUCCEEDED'
                                AND rep1.name = 'submit.argument2'
                                AND rep1.value = :ledger_name)					  
   )
 )
 WHERE 1=1
   AND to_buc IS NOT NULL