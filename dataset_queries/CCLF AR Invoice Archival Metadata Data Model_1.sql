/*--#-----------------------------------------------------------------------------------------------------------------#
--# CCLF Alfresco Invoice archival metadata extract
--# DESCRIPTION  : This data model query used to get the invoice archival metadata extract
--#
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# -----------------------------------------------------------------------------------------------------------------#
--# REL-007           Shankar U        09-Aug-2017              For GC25 company code enabled alfresco extract
--#
--# -----------------------------------------------------------------------------------------------------------------#*/

SELECT rct.trx_number "Invoice Number"
      ,to_char(rct.trx_date ,'mm/dd/yyyy') "Invoice date"
      ,to_char(SYSDATE,'mm/dd/yyyy') "Processed date"
      ,hca.account_number "Customer number"
      ,hp.party_name "Customer name"
-- Changed to get the Billing Company from SEGMENT1 of Receivables Distribution Account. 12 Jan 16
--      ,substr(rcta.name,1,4) "Billing company code"
      ,(SELECT GCC.segment1
        FROM gl_code_combinations GCC
        WHERE GCC.code_combination_id = rctlg.code_combination_id
        AND   rctlg.account_class = 'REC') "Billing company code"
--
      ,(Select period_name from gl_periods where period_set_name = 'CCL CALENDAR' and rctlg.gl_date between START_DATE and END_DATE and Period_name not like '%ADJ%') "Accounting period"
FROM   ra_customer_trx_all rct,
             ra_cust_trx_types_all rcta,
             hr_all_organization_units ha,
             xle_entity_profiles xep,
             ar_payment_schedules_all aps,
             ra_terms_vl rt,
             hz_parties hp,
             hz_cust_accounts hca,
             hz_party_sites hps,  
             hz_cust_acct_sites_all hcas,  
             hz_cust_site_uses_all hcau,
             hz_locations hl,
             hz_parties hp1,
             hz_party_sites hps1,  
             hz_party_site_uses hpsu,
             hz_locations hl1,
RA_CUST_TRX_LINE_GL_DIST_ALL rctlg
-- added by Vijay
,fun_all_business_units_v fabu  
,xle_firstparty_information_v xle
,hr_operating_units hou
,ra_cust_trx_types_all types
,xla_ae_headers xah
WHERE rct.cust_trx_type_seq_id=rcta.cust_trx_type_seq_id
  AND rct.legal_entity_id=xep.legal_entity_id
  AND aps.customer_trx_id=rct.customer_trx_id
  AND rct.org_id=ha.organization_id
  AND rt.term_id(+)=rct.term_id
  AND hp.party_id=hps.party_id
  AND hca.cust_account_id=rct.bill_to_customer_id
  AND hca.party_id=hp.party_id
  AND hps.party_site_id=hcas.party_site_id
  AND hca.cust_account_id = hcas.cust_account_id
  AND hcas.cust_acct_site_id = hcau.cust_acct_site_id
  AND hcau.site_use_id = rct.BILL_TO_SITE_USE_ID
  AND hcau.site_use_code = 'BILL_TO' 
  AND hps.location_id=hl.location_id
-- Added outer join when ship_to is null. 26 JAN 16
  AND hpsu.site_use_type(+) = 'SHIP_TO'
  AND hpsu.party_site_use_id(+)=rct.ship_to_party_site_use_id
  AND hps1.party_site_id(+)= hpsu.party_site_id
  AND hps1.party_id=hp1.party_id(+)
  AND hps1.location_id=hl1.location_id(+)
  AND rct.complete_flag = 'Y'
--  AND hca.customer_type='R' -- Should include internal as well. 12 Nov 15
--AND rctlg.gl_posted_date IS NOT NULL
AND rctlg.event_id = xah.event_id
AND xah.gl_transfer_date IS NOT NULL
AND rctlg.account_class = 'REC'
AND rctlg.customer_trx_id = rct.customer_trx_id
---  added by Vijay
--  changes by vijay AND  ha.organization_id = (select BU_ID from fun_all_business_units_v fab where bu_name = 'CA_CAD_BU')
AND  ha.organization_id = fabu.bu_id --  added by vijay 
-- addedd by vijay below 2 lines
and ha.organization_id in (   select BU_ID from fun_all_business_units_v fab where 
bu_name  in ( 'CA_CAD_BU','CA_WT_DG07_BU', 'US_WT_DG09_BU', 'US_CR_DG05_BU', 'US_CR_DG04_BU', 'US_CR_DG01_BU'
,'CA_SB_GC25_BU')) --REL--007 enabled for GC25 BU
 AND xle.legal_entity_id                 = rct.legal_entity_id
---and rct.trx_number in ('11002100000042' ,'11002100000051')
   AND hou.organization_id                 = rct.org_id
   and rct.cust_trx_type_seq_id= types.cust_trx_type_seq_id
------
----AND  ha.organization_id = (select BU_ID from fun_all_business_units_v fab where bu_name = 'CA_CAD_BU')
AND ((:P_INVOICE_NUM IS NOT NULL AND rct.trx_number IN (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, level)
    FROM DUAL
    CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, level) IS NOT NULL) ) OR
(:P_INVOICE_NUM  IS NULL AND (xah.gl_transfer_date BETWEEN NVL((SELECT MAX(ERH.processstart)
				FROM ess_request_history ERH
					,ess_request_property ERP1
				WHERE PARENTREQUESTID IN (SELECT REQUESTID 
							FROM ess_request_history ERH
							WHERE DEFINITION = 'JobSet://oracle/apps/ess/custom/CCLF_AR_Inv_Archival_Job_Set')
				AND ERH.requestid = ERP1.requestid	
				AND ERP1.name = 'submit.argument1'
		       		AND ERP1.value IS NULL							
				AND  DEFINITION	= 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_AR_INV_ARCHIVAl_METADATA'		  
				AND ERH.executable_status = 'SUCCEEDED'), xah.gl_transfer_date-1)
				AND
				NVL((SELECT MAX(ERH.processstart)
					FROM ess_request_history ERH
						,ess_request_property ERP1
					WHERE PARENTREQUESTID IN (SELECT REQUESTID 
								FROM ess_request_history ERH
								WHERE DEFINITION = 'JobSet://oracle/apps/ess/custom/CCLF_AR_Inv_Archival_Job_Set')
					AND ERH.requestid = ERP1.requestid	
					AND ERP1.name = 'submit.argument1'
		       			AND ERP1.value IS NULL
					AND  DEFINITION	= 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_AR_INV_ARCHIVAL_EXTRACT'		  
					AND ERH.executable_status = 'SUCCEEDED'), xah.gl_transfer_date+1)))
				)
UNION
SELECT 'dummy' "Invoice Number"
      ,NULL "Invoice date"
      ,NULL "Processed date"
      ,NULL "Customer number"
      ,NULL "Customer name"
      ,NULL "Billing company code"
      ,NULL "Accounting period"
FROM DUAL