--#--------------------------------------------------------------------------------------#
--#MODIFICATION HISTORY:
  --#CR#           Author               Date             Description:
	--                                             
--#---------------------------------------------------------------------------------------#
--#REL-018    Yesukumar             17-Jul-2018     Added Two New Coulumns to Existing Query 
	--#                                                As per Business Requirement  – REL-018
--#REL-22	  Neeraj Shrivastava	21-NOV-2018     Modifed the email addresss derivation query and redesigned the SQL.
--#REL-24	  Neeraj Shrivastava	22-DEC-2018     Added PARTY_ID and SITE_USE_ID
--#REL-055	  Akash Mohanty			05-AUG-2021		Added oracle_erp_delivery_method
--#-------------------------------------------------------------------------------------------#	
SELECT 1 "KEY",
TRIM(hca.attribute1) sfdc_id,
hp.party_number oracle_erp_customer_id,
hca.account_number oracle_erp_customer_account_no,
hps.party_site_number oracle_erp_customer_site_no,
hca.cust_account_id oracle_erp_customer_account_id,
hps.party_site_id oracle_erp_customer_site_id,
hcpf.effective_start_date oracle_erp_create_date,
hcpf.last_update_date oracle_erp_update_date,
hcpf.credit_rating oracle_erp_credit_rating,
hcpf.credit_classification credit_classification,
hcpf.credit_currency_code credit_limit_currency,  --- rel 006
hcpf.credit_limit oracle_erp_credit_limit,
TRIM(hcas.attribute3) oracle_buc_code,
(SELECT name FROM RA_TERMS WHERE term_id=hcpf.standard_terms) oracle_erp_payment_term,  --- New field added F28061
zptp.rep_registration_number oracle_vat_tax_code,
NULL oracle_tax_jurisdiction_code,

(SELECT DISTINCT flv.meaning FROM FND_LOOKUP_VALUES flv
WHERE 1=1
AND flv.lookup_code=hca.customer_type
AND flv.lookup_type='CUSTOMER_TYPE' 
AND flv.language='US') oracle_erp_customer_type,
  -- REL-022 below code added by Neeraj
(SELECT HCP.email_address
	 FROM HZ_CUST_ACCOUNT_ROLES HCAA,
		  HZ_PARTIES ContactPersonParty,
		   HZ_PARTIES CustomerParty,
		  HZ_CONTACT_POINTS HCP
     WHERE 	HCA.CUST_ACCOUNT_ID = HCAA.CUST_ACCOUNT_ID
     AND 	HCAA.CONTACT_PERSON_ID = ContactPersonParty.PARTY_ID
	 AND    HCAA.CONTACT_PERSON_ID =  HCP.OWNER_TABLE_ID(+)
	 AND    HCAA.RELATIONSHIP_ID = HCP.RELATIONSHIP_ID(+) 
	 AND    HCA.PARTY_ID = CustomerParty.PARTY_ID(+)
	 AND    HCAA.status = 'A'
	 AND    HCP.OWNER_TABLE_NAME = 'HZ_PARTIES'
	 and    HCP.primary_flag = 'Y'
	 AND    HCAA.primary_flag ='Y'
	 AND    HCP.RELATIONSHIP_ID IS NOT NULL
AND hcp.contact_point_type='EMAIL'
	 AND    rownum<=1
 ) oracle_erp_email_address,
  -- REL-022 above code by Neeraj
  --REL-24 Added below code by Neeraj 
  HP.party_id ORACLE_PARTY_ID,
  HCU.SITE_USE_ID  ORACLE_ACCNT_SITE_USE_ID,
  --REL-24 Added above code by Neeraj 
  --REL-055 Added below code
(SELECT 
DECODE(txn_delivery_method,'PRINT_INV','Paper','EMAIL_INV','E-Mail',txn_delivery_method)
FROM HZ_CUSTOMER_PROFILES_F hpf 
WHERE hpf.party_id = HP.party_id
AND hpf.site_use_id = HCU.SITE_USE_ID
AND status = 'A'
AND SYSDATE BETWEEN effective_start_date AND effective_end_date
AND    rownum<=1 
) oracle_erp_delivery_method
 --REL-055 Added Above code
FROM 
HZ_PARTIES hp,
HZ_PARTY_SITES hps,
HZ_CUST_ACCOUNTS hca,
HZ_CUST_ACCT_SITES_ALL hcas,
HZ_CUSTOMER_PROFILES_F hcpf,
ZX_PARTY_TAX_PROFILE zptp,
HZ_CUST_SITE_USES_ALL HCU      -- REL-24 Added by Neeraj
WHERE 1=1
AND hca.party_id = hp.party_id
AND hp.party_id = hps.party_id
AND hca.cust_account_id = hcas.cust_account_id
AND hca.cust_account_id = hcpf.cust_account_id
AND hcas.party_site_id = hps.party_site_id
AND zptp.party_id(+) = hps.party_site_id
AND hca.attribute1 IS NOT NULL
AND hcas.attribute1 IS NOT NULL
AND hcpf.site_use_id IS NULL
AND hp.status  = 'A'
AND hps.status  = 'A'
AND hca.status  = 'A'
AND hcas.status  = 'A'
AND hcpf.status = 'A'
AND HCPF.SITE_USE_ID IS NULL
-- REL-24 Added below code by Neeraj
AND HCU.site_use_code = 'BILL_TO'                     
and HCU.cust_acct_site_id = hcas.cust_acct_site_id   
AND HCU.PRIMARY_FLAG = 'Y'            
-- REL-24 Added above code by Neeraj
AND TRUNC(SYSDATE) BETWEEN HCPF.EFFECTIVE_START_DATE AND HCPF.EFFECTIVE_END_DATE
AND (
(CAST(hca.last_update_date AS TIMESTAMP) >
               (SELECT MAX (processstart)
                  FROM ESS_REQUEST_HISTORY
                 WHERE UPPER(definition) =
                              'JOBDEFINITION://ORACLE/APPS/ESS/CUSTOM/AR/GEDCUSTCREDIT/GEDCUSTCREDIT'
                       AND executable_status = 'SUCCEEDED'))
OR
(CAST(hps.last_update_date AS TIMESTAMP) >
               (SELECT MAX (processstart)
                  FROM ESS_REQUEST_HISTORY
                 WHERE UPPER(definition) =
                              'JOBDEFINITION://ORACLE/APPS/ESS/CUSTOM/AR/GEDCUSTCREDIT/GEDCUSTCREDIT'
                       AND executable_status = 'SUCCEEDED'))    
OR
(CAST(hcas.last_update_date AS TIMESTAMP) >
               (SELECT MAX (processstart)
                  FROM ESS_REQUEST_HISTORY
                 WHERE UPPER(definition) =
                              'JOBDEFINITION://ORACLE/APPS/ESS/CUSTOM/AR/GEDCUSTCREDIT/GEDCUSTCREDIT'
                       AND executable_status = 'SUCCEEDED')) 
OR
(CAST(hcpf.last_update_date AS TIMESTAMP) >
               (SELECT MAX (processstart)
                  FROM ESS_REQUEST_HISTORY
                 WHERE UPPER(definition) =
                              'JOBDEFINITION://ORACLE/APPS/ESS/CUSTOM/AR/GEDCUSTCREDIT/GEDCUSTCREDIT'
                       AND executable_status = 'SUCCEEDED')) 
)
UNION
  -- REL-022 below code added by Neeraj
SELECT 1 "KEY",
TRIM(hca.attribute1) sfdc_id,
hp.party_number oracle_erp_customer_id,
hca.account_number oracle_erp_customer_account_no,
hps.party_site_number oracle_erp_customer_site_no,
hca.cust_account_id oracle_erp_customer_account_id,
hps.party_site_id oracle_erp_customer_site_id,
hcpf.effective_start_date oracle_erp_create_date,
hcpf.last_update_date oracle_erp_update_date,
hcpf.credit_rating oracle_erp_credit_rating,
hcpf.credit_classification credit_classification,
hcpf.credit_currency_code credit_limit_currency,  --- rel 006
hcpf.credit_limit oracle_erp_credit_limit,
TRIM(hcas.attribute3) oracle_buc_code,
(SELECT name FROM RA_TERMS WHERE term_id=hcpf.standard_terms) oracle_erp_payment_term,  --- New field added F28061
zptp.rep_registration_number oracle_vat_tax_code,
NULL oracle_tax_jurisdiction_code,
-- REL-018 <F34248> added below code
(SELECT DISTINCT flv.meaning FROM FND_LOOKUP_VALUES flv
WHERE 1=1
AND flv.lookup_code=hca.customer_type
AND flv.lookup_type='CUSTOMER_TYPE' 
AND flv.language='US') oracle_erp_customer_type,
HCP.email_address oracle_erp_email_address,
--REL-24 Added below code by Neeraj 
HP.party_id ORACLE_PARTY_ID,
HCU.SITE_USE_ID  ORACLE_ACCNT_SITE_USE_ID,  		
--REL-24 Added above code by Neeraj 
  --REL-055 Added below code
(SELECT 
DECODE(txn_delivery_method,'PRINT_INV','Paper','EMAIL_INV','E-Mail',txn_delivery_method)
FROM HZ_CUSTOMER_PROFILES_F hpf 
WHERE hpf.party_id = HP.party_id
AND hpf.site_use_id = HCU.SITE_USE_ID
AND status = 'A'
AND SYSDATE BETWEEN effective_start_date AND effective_end_date
AND    rownum<=1 
) oracle_erp_delivery_method
 --REL-055 Added Above code
FROM 
HZ_PARTIES hp,
HZ_PARTY_SITES hps,
HZ_CUST_ACCOUNTS hca,
HZ_CUST_ACCT_SITES_ALL hcas,
HZ_CUSTOMER_PROFILES_F hcpf,
ZX_PARTY_TAX_PROFILE zptp,
HZ_CUST_ACCOUNT_ROLES HCAA,
HZ_PARTIES ContactPersonParty,
HZ_CONTACT_POINTS HCP,
HZ_CUST_SITE_USES_ALL HCU                  -- REL-24 Added by Neeraj
WHERE 1=1

AND hca.party_id = hp.party_id
AND hp.party_id = hps.party_id
AND hca.cust_account_id = hcas.cust_account_id
AND hca.cust_account_id = hcpf.cust_account_id
AND hcas.party_site_id = hps.party_site_id
AND zptp.party_id(+) = hps.party_site_id
AND hca.attribute1 IS NOT NULL
AND hcas.attribute1 IS NOT NULL
AND hcpf.site_use_id IS NULL
AND hp.status  = 'A'
AND hps.status  = 'A'
AND hca.status  = 'A'
AND hcas.status  = 'A'
AND hcpf.status = 'A'
and HCP.primary_flag = 'Y'
and HCAA.primary_flag = 'Y'
AND HCA.CUST_ACCOUNT_ID = HCAA.CUST_ACCOUNT_ID
AND HCAA.CONTACT_PERSON_ID = ContactPersonParty.PARTY_ID
AND  HCAA.CONTACT_PERSON_ID =  HCP.OWNER_TABLE_ID(+)
AND  HCAA.RELATIONSHIP_ID = HCP.RELATIONSHIP_ID(+) 
AND  HCAA.status = 'A'
AND  HCP.OWNER_TABLE_NAME = 'HZ_PARTIES'
AND  HCP.RELATIONSHIP_ID IS NOT NULL
AND  hcp.contact_point_type='EMAIL'
AND  HCPF.SITE_USE_ID IS NULL
--REL-24 Added below code by Neeraj 
AND  HCU.site_use_code = 'BILL_TO' 
and  HCU.cust_acct_site_id = hcas.cust_acct_site_id 
AND  HCU.PRIMARY_FLAG = 'Y'
--REL-24 Added above code by Neeraj 
AND TRUNC(SYSDATE) BETWEEN HCPF.EFFECTIVE_START_DATE AND HCPF.EFFECTIVE_END_DATE
AND (CAST(hcp.last_update_date AS TIMESTAMP) >
               (SELECT MAX (processstart)
                  FROM ESS_REQUEST_HISTORY
                 WHERE UPPER(definition) =
                              'JOBDEFINITION://ORACLE/APPS/ESS/CUSTOM/AR/GEDCUSTCREDIT/GEDCUSTCREDIT'
                       AND executable_status = 'SUCCEEDED'))