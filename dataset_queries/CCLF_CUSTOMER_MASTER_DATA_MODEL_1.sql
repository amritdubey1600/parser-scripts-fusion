SELECT
  CUST.PARTY_ID, 
  HPS.PARTY_SITE_ID, 
  HCA.CUST_ACCOUNT_ID, 
  HCAS.CUST_ACCT_SITE_ID,
  HCSU.SITE_USE_ID,
  CUST.party_name CustomerName,  
  CUST.ADDRESS1 ADDRESS,
  CUST.ADDRESS2 ADDRESS_LINE_2,
  CUST.ADDRESS3 ADDRESS_LINE_3,
  CUST.ADDRESS4 ADDRESS_LINE_4,
  CUST.CITY City,
  CUST.PROVINCE Province,
  CUST.COUNTRY Country,
  CUST.POSTAL_CODE Postal_Code,
  HCA.ACCOUNT_NUMBER customer_Account_num,
  DECODE(HCA.CUSTOMER_TYPE,'I','INTERNAL','R','EXTERNAL') CUSTOMER_TYPE,
  CUST.ORIG_SYSTEM_REFERENCE,
  HPS.PARTY_SITE_NAME,
  HPS.PARTY_SITE_NUMBER Site_Number,
  HPSU.SITE_USE_TYPE Site_Purpose,
  ADDR.ADDRESS1 SITE_ADDRESS_LINE_1,
  ADDR.ADDRESS2 SITE_ADDRESS_LINE_2,
  ADDR.ADDRESS3 SITE_ADDRESS_LINE_3,
  ADDR.ADDRESS4 SITE_ADDRESS_LINE_4,
  ADDR.CITY SITE_CITY,
  ADDR.PROVINCE SITE_PROVINCE,
  ADDR.COUNTRY SITE_COUNTRY,
  ADDR.POSTAL_CODE SITE_POSTAL_CODE,
  -- Tax Exempt Certificate Number
  (Select ex.exempt_certificate_number
   from zx_exemptions ex
       ,zx_party_tax_profile ptp_party_site
   where ex.party_tax_profile_id = ptp_party_site.party_tax_profile_id
   AND ptp_party_site.party_id = hps.party_site_id) Tax_exeption_num,
     To_char(HCAS.CREATION_DATE,'DD-Mon-YYYY'),
     TO_CHAR(HCAS.END_DATE,'DD-Mon-YYYY'),
--- Contact Name 
   (SELECT SUBSTR(HP.person_first_name || ' ' || HP.person_last_name, 1, 34)
        FROM hz_parties HP, hz_cust_account_roles HCAR
        WHERE HP.party_id = HCAR.contact_person_id
        AND  HCAR.cust_acct_site_id = HCAS.cust_acct_site_id 
        AND  HCAR.cust_account_id = HCAS.cust_account_id 
        --AND HCAR.role_type = 'CONTACT'
        --AND HCAR.primary_flag = 'Y'
		AND ROWNUM <2
		)  ContactName,
--- Phone Number ----
	(SELECT SUBSTR(HCP.raw_phone_number, 1, 23)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        AND  HCAR.cust_acct_site_id = HCAS.cust_acct_site_id 
        AND  HCAR.cust_account_id = HCAS.cust_account_id 
        --AND HCAR.role_type = 'CONTACT'
        --AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'PHONE'
        --AND HCP.phone_line_type = 'GEN'
        --AND HCP.primary_flag = 'Y' 
		AND ROWNUM <2
		)  PhoneNumber,
--- email address ---
	(SELECT SUBSTR(HCP.email_address, 1, 58)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        AND  HCAR.cust_acct_site_id = HCAS.cust_acct_site_id 
        AND  HCAR.cust_account_id = HCAR.cust_account_id 
        --AND HCAR.role_type = 'CONTACT'
        --AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'EMAIL'
        --AND HCP.primary_flag = 'Y' 
		AND ROWNUM <2 ) EmailAddress,
		FSS.SET_NAME,
		HCAS.set_id  set_ID, -- 300000002117005
		HCAS.TRANSLATED_CUSTOMER_NAME TRANSLATED_CUSTOMER_NAME,
		HCSU.LOCATION ADDRESS_PURPOSE_SITE_NAME,
-- TP segment ---
		to_char(GCC.SEGMENT3) TP	,	
		hou.NAME org_name
FROM  HZ_PARTIES CUST
     ,HZ_CUST_ACCOUNTS HCA
	 ,HZ_PARTY_SITES HPS
	 ,HZ_CUST_ACCT_SITES_ALL HCAS
	 ,HZ_LOCATIONS ADDR
	 ,HZ_PARTY_SITE_USES HPSU
	 ,FND_SETID_SETS FSS
	 ,HZ_CUST_SITE_USES_ALL HCSU -- New Table
	 -----------------------------------------
	 ,AR_REF_ACCOUNTS_ALL ARAA	
	 ,GL_CODE_COMBINATIONS GCC
	 ,hr_all_organization_units hou
WHERE 1=1
AND HCA.PARTY_ID= CUST.PARTY_ID
AND CUST.PARTY_ID = HPS.PARTY_ID
AND HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
AND HCAS.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
AND HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID -- New Join
AND ADDR.LOCATION_ID=HPS.LOCATION_ID
AND HPSU.PARTY_SITE_ID=HPS.PARTY_SITE_ID
AND FSS.SET_ID = HCAS.SET_ID
AND FSS. LANGUAGE = 'US'
----------------------------------
AND ARAA.source_ref_table = 'HZ_CUST_SITE_USES_ALL' 
AND ARAA.SOURCE_REF_ACCOUNT_ID = HCSU.SITE_USE_ID
AND ARAA.REC_CCID = gcc.code_combination_id
AND ARAA.BU_ID = hou.organization_id
----------------------------------------------
AND HCA.CUSTOMER_TYPE=decode(:CUST_TYPE,'Internal','I','External','R','All',HCA.CUSTOMER_TYPE)
--AND CUST.party_name = '3 PHASE POWER SYSTEMS INC.'
AND FSS.SET_NAME in(:Reference_set_name)
--AND hou.NAME = 'CA_CAD_BU'
AND hou.name = :BU_Name
--------------
UNION ALL
------------------
SELECT
  CUST.PARTY_ID, 
  HPS.PARTY_SITE_ID, 
  HCA.CUST_ACCOUNT_ID, 
  HCAS.CUST_ACCT_SITE_ID,
  HCSU.SITE_USE_ID,
  CUST.party_name CustomerName,  
  CUST.ADDRESS1 ADDRESS,
  CUST.ADDRESS2 ADDRESS_LINE_2,
  CUST.ADDRESS3 ADDRESS_LINE_3,
  CUST.ADDRESS4 ADDRESS_LINE_4,
  CUST.CITY City,
  CUST.PROVINCE Province,
  CUST.COUNTRY Country,
  CUST.POSTAL_CODE Postal_Code,
  HCA.ACCOUNT_NUMBER customer_Account_num,
  DECODE(HCA.CUSTOMER_TYPE,'I','INTERNAL','R','EXTERNAL') CUSTOMER_TYPE,
  CUST.ORIG_SYSTEM_REFERENCE,
  HPS.PARTY_SITE_NAME,
  HPS.PARTY_SITE_NUMBER Site_Number,
  HPSU.SITE_USE_TYPE Site_Purpose,
  ADDR.ADDRESS1 SITE_ADDRESS_LINE_1,
  ADDR.ADDRESS2 SITE_ADDRESS_LINE_2,
  ADDR.ADDRESS3 SITE_ADDRESS_LINE_3,
  ADDR.ADDRESS4 SITE_ADDRESS_LINE_4,
  ADDR.CITY SITE_CITY,
  ADDR.PROVINCE SITE_PROVINCE,
  ADDR.COUNTRY SITE_COUNTRY,
  ADDR.POSTAL_CODE SITE_POSTAL_CODE,
  -- Tax Exempt Certificate Number
  (Select ex.exempt_certificate_number
   from zx_exemptions ex
       ,zx_party_tax_profile ptp_party_site
   where ex.party_tax_profile_id = ptp_party_site.party_tax_profile_id
   AND ptp_party_site.party_id = hps.party_site_id) Tax_exeption_num,
     To_char(HCAS.CREATION_DATE,'DD-Mon-YYYY'),
     TO_CHAR(HCAS.END_DATE,'DD-Mon-YYYY'),
--- Contact Name 
   (SELECT SUBSTR(HP.person_first_name || ' ' || HP.person_last_name, 1, 34)
        FROM hz_parties HP, hz_cust_account_roles HCAR
        WHERE HP.party_id = HCAR.contact_person_id
        AND  HCAR.cust_acct_site_id = HCAS.cust_acct_site_id 
        AND  HCAR.cust_account_id = HCAS.cust_account_id 
        --AND HCAR.role_type = 'CONTACT'
        --AND HCAR.primary_flag = 'Y'
		AND ROWNUM <2
		)  ContactName,
--- Phone Number ----
	(SELECT SUBSTR(HCP.raw_phone_number, 1, 23)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        AND  HCAR.cust_acct_site_id = HCAS.cust_acct_site_id 
        AND  HCAR.cust_account_id = HCAS.cust_account_id 
        --AND HCAR.role_type = 'CONTACT'
        --AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'PHONE'
        --AND HCP.phone_line_type = 'GEN'
        --AND HCP.primary_flag = 'Y' 
		AND ROWNUM <2
		)  PhoneNumber,
--- email address ---
	(SELECT SUBSTR(HCP.email_address, 1, 58)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        AND  HCAR.cust_acct_site_id = HCAS.cust_acct_site_id 
        AND  HCAR.cust_account_id = HCAR.cust_account_id 
        --AND HCAR.role_type = 'CONTACT'
        --AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'EMAIL'
        --AND HCP.primary_flag = 'Y' 
		AND ROWNUM <2 ) EmailAddress,
		FSS.SET_NAME,
		HCAS.set_id  set_ID, -- 300000002117005
		HCAS.TRANSLATED_CUSTOMER_NAME TRANSLATED_CUSTOMER_NAME,
		HCSU.LOCATION ADDRESS_PURPOSE_SITE_NAME,
		-- TP segment ---
		NULL TP	,	
		NULL org_name
FROM  HZ_PARTIES CUST
     ,HZ_CUST_ACCOUNTS HCA
	 ,HZ_PARTY_SITES HPS
	 ,HZ_CUST_ACCT_SITES_ALL HCAS
	 ,HZ_LOCATIONS ADDR
	 ,HZ_PARTY_SITE_USES HPSU
	 ,FND_SETID_SETS FSS
	 ,HZ_CUST_SITE_USES_ALL HCSU -- New Table
WHERE 1=1
AND HCA.PARTY_ID= CUST.PARTY_ID
AND CUST.PARTY_ID = HPS.PARTY_ID
AND HPS.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
AND HCAS.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
AND HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID -- New Join
AND ADDR.LOCATION_ID=HPS.LOCATION_ID
AND HPSU.PARTY_SITE_ID=HPS.PARTY_SITE_ID
AND FSS.SET_ID = HCAS.SET_ID
AND FSS. LANGUAGE = 'US'
---------------------------------------------------------------
AND HPSU.SITE_USE_TYPE = 'SHIP_TO'
AND HCSU.BILL_TO_SITE_USE_ID in (SELECT distinct SITE_USE_ID
								 FROM HZ_CUST_SITE_USES_ALL HCSU1
									  ,AR_REF_ACCOUNTS_ALL ARAA
									  ,hr_all_organization_units hou 
								 Where ARAA.source_ref_table = 'HZ_CUST_SITE_USES_ALL'
								 AND ARAA.SOURCE_REF_ACCOUNT_ID = HCSU1.SITE_USE_ID
								 --AND HPSU1.SITE_USE_TYPE = 'BILL_TO'
								 AND ARAA.BU_ID = hou.organization_id
								 --AND hou.NAME = 'CA_CAD_BU'
								 AND hou.name = :BU_Name)
-----------------------------------------------------------
AND HCA.CUSTOMER_TYPE=decode(:CUST_TYPE,'Internal','I','External','R','All',HCA.CUSTOMER_TYPE)
--AND CUST.party_name = '3 PHASE POWER SYSTEMS INC.'
AND FSS.SET_NAME in(:Reference_set_name)