/*  
*************************************************************************************************
-- Name             : Cirrus India IRN Status Report
-- Date             : 01/01/21 
-- Author           : Venkateswarlu M  
-- Purpose          : Reporting  
-- Type             : Sql  
*************************************************************************************************
-- Change history  
-- Version         Date    REL            Developer                            Description    
-- 1.0           01/01/21  048             Venkateswarlu M                      Draft version ofCirrus India IRN Status Report

*************************************************************************************************
*/ 
SELECT fabu.bu_name,
       ract.trx_number 
       inv_no, 
       TO_CHAR(ract.trx_date, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = AMERICAN') 
       inv_date, 
       ract.invoice_currency_code, 
       bill_to.party_name, 
       bill_to.party_number,
	   ract.attribute3 Ack_date,
	   ract.trx_class,
	   decode (ract.attribute11,'S','Success','E','Error','IRN Not Processed') irn_status
FROM   RA_CUSTOMER_TRX_ALL ract, 
       FUN_ALL_BUSINESS_UNITS_V fabu,
       (SELECT hca.customer_type, 
               hp.party_name, 
               hp.party_number, 
               hca.cust_account_id 
        FROM   HZ_CUST_SITE_USES_ALL su, 
               HZ_CUST_ACCT_SITES_ALL cas, 
               HZ_PARTY_SITES hps, 
               HZ_LOCATIONS hl, 
               HZ_PARTIES hp, 
               HZ_CUST_ACCOUNTS hca 
        WHERE  su.cust_acct_site_id = cas.cust_acct_site_id 
               AND cas.party_site_id = hps.party_site_id 
               AND hps.location_id = hl.location_id 
               AND hp.party_id = hps.party_id 
               AND cas.cust_account_id = hca.cust_account_id 
               AND su.site_use_code = 'BILL_TO') bill_to
WHERE  ract.org_id = fabu.bu_id 
       AND ract.bill_to_customer_id = bill_to.cust_account_id
       AND ract.complete_flag = 'Y'
       AND TRUNC(ract.trx_date) BETWEEN NVL(:p_from_date, ract.trx_date) AND 
                                        NVL(:p_to_date, ract.trx_date) 
       AND fabu.bu_name ='IN_CR_DG40_BU'
       and trunc(ract.creation_date) >=('2021-01-25')
ORDER  BY fabu.bu_name, 
          ract.trx_number