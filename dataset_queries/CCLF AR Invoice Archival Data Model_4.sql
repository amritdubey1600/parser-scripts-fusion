SELECT rct.trx_number  AS "KEY"
, decode (bu_name ,'CA_CAD_BU' ,'Invoice Archival Report', 'CA_WT_DG07_BU', decode(rcta.type,'CM', 'CUSTOM GED CANADA CN','CUSTOM GED CANADA'), 'US_WT_DG09_BU' , decode(rcta.type,'CM', 'CUSTOMGEDUSCM','CUSTOMGEDUS'), 'US_CR_DG05_BU', decode(rcta.type,'CM', 'CUSTOMGEDUSCM','CUSTOMGEDUS'),'US_CR_DG04_BU',decode(rcta.type,'CM', 'CUSTOMGEDUSCM','CUSTOMGEDUS'), 'US_CR_DG01_BU' ,decode(rcta.type,'CM', 'CUSTOMGEDUSCM','CUSTOMGEDUS'),'Invoice Archival Report') as TEMPLATE
            ,'PDF' AS OUTPUT_FORMAT
            ,'FTP' as "DEL_CHANNEL"
            ,'Invoice_Image_' || rct.trx_number || '_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.pdf' as "OUTPUT_NAME"
            ,'true' as "SAVE_OUTPUT"
            -- ,FND_PROFILE.VALUE('CCLF_BI_SFTP_SERVER') as "PARAMETER1"    DISABLED -- July 16th, 2020
            ,:P_DEST_DIR as "PARAMETER4"
            ,'Invoice_Image_' || rct.trx_number || '_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.pdf' as "PARAMETER5"
            ,'true' as "PARAMETER6"
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
-- added By Vijay
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
-- Added outer join when shipto is null. 26 JAN 16
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
--  changes by vijay AND  ha.organization_id = (select BU_ID from fun_all_business_units_v fab where bu_name = 'CA_CAD_BU')
AND  ha.organization_id = fabu.bu_id --  added by vijay 
-- addedd by vijay below 2 lines
and ha.organization_id in (   select BU_ID from fun_all_business_units_v fab where 
bu_name  in ( 'CA_CAD_BU','CA_WT_DG07_BU', 'US_WT_DG09_BU', 'US_CR_DG05_BU', 'US_CR_DG04_BU', 'US_CR_DG01_BU'
,'CA_SB_GC25_BU')) --REL-007 Enabled for GC25 BU.
 AND xle.legal_entity_id                 = rct.legal_entity_id
-----and rct.trx_number in ('11002100000042' ,'11002100000051' ,'201603WIRLSUSE129')
   AND hou.organization_id                 = rct.org_id
   and rct.cust_trx_type_seq_id= types.cust_trx_type_seq_id
 -- addition ends here
AND ((:P_INVOICE_NUM IS NOT NULL AND rct.trx_number IN (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, level)
    FROM DUAL
    CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, level) IS NOT NULL)) OR
(:P_INVOICE_NUM  IS NULL AND (xah.gl_transfer_date > NVL((SELECT MAX(ERH.processstart)
				FROM ess_request_history ERH
				    ,ess_request_property ERP1
				WHERE 1=1
--REL034 GEINC5211971/GERITM5906234 Starts
/*ERH.PARENTREQUESTID IN (SELECT REQUESTID 
							FROM ess_request_history ERH
							WHERE DEFINITION = 'JobSet://oracle/apps/ess/custom/CCLF_AR_Inv_Archival_Job_Set')*/
--REL034 GEINC5211971/GERITM5906234 Ends
				AND ERH.requestid = ERP1.requestid	
				AND ERP1.name = 'submit.argument1'
		       		AND ERP1.value IS NULL
				AND ERH.DEFINITION	= 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_AR_INV_ARCHIVAL_EXTRACT'		  
				AND ERH.executable_status = 'SUCCEEDED'), xah.gl_transfer_date-1)))
				)