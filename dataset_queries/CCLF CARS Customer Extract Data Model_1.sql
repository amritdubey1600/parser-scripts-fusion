/*--#-----------------------------------------------------------------------------------------------------------------#
--# GECARS Customer Extract datamodel
--# DESCRIPTION  : This data model query used to get the GECARS customer extract
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# ----------------------------------------------------------------------------------------------------------------------------------------------------------------#
--# REL-007           Shankar U        07-August-2017           Added BCO Code logic should come from Company code DFF, BU_ID join to the main where clause and 
--#                                                             where clause to fetch lite customers extract logic.                 
--# ----------------------------------------------------------------------------------------------------------------------------------------------------------------#*/
/*-----------------------GECARS_Customer Query for Canada...........................*/
SELECT --'KEY' KEY,
NULL CustomerNumber,
--SUBSTR(CA.ACCOUNT_NUMBER, 1, 6) || SUBSTR(U.SITE_USE_ID, -6) BusinessCustomerNumber,
--SUBSTR(U.SITE_USE_ID, -6) BusinessCustomerNumber, -- Change to use only Site Use Id. 10 Jun
SUBSTR(s.party_site_number, 1, 12) BusinessCustomerNumber, -- Change to use Site Number. 24 Jul
NULL ARCustomerNumber,
NULL GECARSPayingCustomerNumber,
NULL BusinessPayingCustomerNumber,
NULL ARPayingCustomerNumber,
--'BCO200' BillingComponent,
CASE WHEN fabu.bu_name = 'CA_CAD_BU' THEN                                     -- REL-007 Added by Shankar
             (SELECT DISTINCT ASP.attribute1
                FROM AR_SYSTEM_PARAMETERS_ALL asp,
                     FUN_ALL_BUSINESS_UNITS_V fabu1,
                     FND_SETID_ASSIGNMENTS fsa
               WHERE     ASP.set_of_books_id = fabu1.primary_ledger_id
                     AND FABU1.bu_id = FSA.determinant_value
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = U.set_id
                     AND ASP.attribute_category = 'CCLAR'
                     AND FABU1.bu_id = FABU.bu_id --REL-007 Added to link the BU from the from main where clause
                     AND ROWNUM = 1)
          WHEN fabu.bu_name <> 'CA_CAD_BU' AND araa.rec_ccid IS NOT NULL --REL-007 Adding starts here
          THEN
             (SELECT fvv.ATTRIBUTE7
                FROM FND_FLEX_VALUE_SETS fvs,
                     FND_FLEX_VALUES fvv,
                     FND_SETID_ASSIGNMENTS fsa,
                     GL_CODE_COMBINATIONS gcc
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
                     AND FABU.bu_id = FSA.determinant_value
                     AND gcc.segment1 = fvv.flex_value
                     AND gcc.code_combination_id = ARAA.REC_CCID
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = u.set_id
                     AND ROWNUM = 1)
          WHEN fabu.bu_name <> 'CA_CAD_BU' AND araa.rev_ccid IS NOT NULL
          THEN
             (SELECT fvv.ATTRIBUTE7
                FROM FND_FLEX_VALUE_SETS fvs,
                     FND_FLEX_VALUES fvv,
                     FND_SETID_ASSIGNMENTS fsa,
                     GL_CODE_COMBINATIONS gcc
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
                     AND FABU.bu_id = FSA.determinant_value
                     AND gcc.segment1 = fvv.flex_value
                     AND gcc.code_combination_id = ARAA.REV_CCID
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = u.set_id
                     AND ROWNUM = 1)
          ELSE
             (SELECT fvv.ATTRIBUTE7
                FROM FND_FLEX_VALUE_SETS fvs,
                     FND_FLEX_VALUES fvv,
                     FND_SETID_ASSIGNMENTS fsa
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
                     AND FABU.bu_id = FSA.determinant_value
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = u.set_id
                     AND ROWNUM = 1)
       END                                          --REL-007 Adding ends here
    BillingComponent, -- Change to get from AR System Param. 07 Jul
NULL BusinessCode,
TRIM(SUBSTR(REPLACE(REPLACE((cust.party_name),'"',NULL),',',NULL),1,48)) CustomerName,
NULL Definer,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS1),'"',NULL),',',NULL),1,48)) MailingAddress1,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS2),'"',NULL),',',NULL),1,48)) MailingAddress2,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48)) MailingCity,
--TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) MailingState,
(CASE WHEN ADDR.COUNTRY = 'US' and  LENGTH(ADDR.STATE) > 2 THEN  (SELECT DISTINCT LOOKUP_CODE
																	FROM FND_LOOKUP_VALUES 
																	WHERE LOOKUP_TYPE='GED_FA_STATE_CODES'
																	and  upper(MEANING)  = upper(ADDR.STATE))         
       ELSE TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) 
      END) MailingState,

TRIM(SUBSTR(ADDR.POSTAL_CODE,1,10)) MailingZip,
TRIM(SUBSTR(DECODE(ADDR.STATE,'PR','PR',ADDR.COUNTRY),1,2)) MailingCountry,
(SELECT GL.currency_code FROM gl_ledgers GL, fun_all_business_units_v FABU1, fnd_setid_assignments FSA
                        WHERE GL.ledger_id = fabu1.primary_ledger_id
                        AND   FABU1.bu_id = FSA.determinant_value
                        AND   FSA.determinant_type = 'BU'
                        AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
                        AND   FSA.set_id = U.set_id 
and rownum=1) BilledCurrency,
(SELECT GL.currency_code FROM gl_ledgers GL, fun_all_business_units_v FABU1, fnd_setid_assignments FSA
                        WHERE GL.ledger_id = fabu1.primary_ledger_id
                        AND   FABU1.bu_id = FSA.determinant_value
                        AND   FSA.determinant_type = 'BU'
                        AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
                        AND   FSA.set_id = U.set_id
and rownum=1 ) FunctionalCurrency,
'ENG' Language,
NULL HighCredit,
NULL DateofHighCredit,
NULL DateonLateCheck,
NULL AmountofLastCheck,
NULL CurrencyOfLastCheck,
NULL LastCheckNumber,
NULL NumberOfInvoicesBilledYTD,
NULL AmountofInvoiceBilledYTD,
NULL DateofLastSale,
NULL AmountofLastSale,
DECODE(CA.customer_type, 'R', 'E') TypeOfCustomer, -- As only external customers are extracted
NULL SIC,
NULL DUNSNumber,
NULL HQDUNSNumbr,
NULL NewProperty,
NULL DAndBCreditRating,
'N' StatmentMailedFlag,
'N' DunningLettersMailed,
NULL CreditGuide,
NULL SingleShipOrderControl,
NULL HoldIndicatororSpecialStatus,
NULL DateAccountWasOpen,
NULL LastCreditReviewDate,
(SELECT SUBSTR(HP.person_first_name || ' ' || HP.person_last_name, 1, 34)
        FROM hz_parties HP, hz_cust_account_roles HCAR
        WHERE HP.party_id = HCAR.contact_person_id
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
        ----     AND HCAR.role_type = 'CONTACT'
 ------     AND HCAR.primary_flag = 'Y'
and rownum=1 )  ContactName,
(SELECT SUBSTR(HCP.raw_phone_number, 1, 23)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        --AND  HCAR.cust_acct_site_id = CS.cust_acct_site_id -- Change to get from Account level instead of Site. 31 Aug
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
 ---       AND  HCAR.cust_acct_site_id IS NULL -- Change to get from Account level instead of Site. 31 Aug
---8th        AND HCAR.role_type = 'CONTACT'
----8th        AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'PHONE'
        AND HCP.phone_line_type = 'GEN'
        AND HCP.primary_flag = 'Y' 
and rownum=1)  PhoneNumber,
(SELECT SUBSTR(HCP.raw_phone_number, 1, 23)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        --AND  HCAR.cust_acct_site_id = CS.cust_acct_site_id -- Change to get from Account level instead of Site. 31 Aug
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
             AND HCAR.role_type = 'CONTACT'
        AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'PHONE'
        AND HCP.phone_line_type = 'FAX'
        AND HCP.primary_flag = 'Y' 
and rownum=1 ) FaxNumber,
(SELECT SUBSTR(HCP.email_address, 1, 58)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        --AND  HCAR.cust_acct_site_id = CS.cust_acct_site_id -- Change to get from Account level instead of Site. 31 Aug
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
               AND HCAR.role_type = 'CONTACT'
        AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'EMAIL'
        AND HCP.primary_flag = 'Y' 
and rownum=1) EmailAddress,
NULL DateOfLastCreditGuideChange,
NULL DateofLastSingleShipOrderContr,
NULL DateofCustomerStatusChange,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS1),'"',NULL),',',NULL),1,48)) PhysicalAddress1,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS2),'"',NULL),',',NULL),1,48)) PhysicalAddress2,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48)) PhysicalCity,
--TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) PhysicalState,
(CASE WHEN ADDR.COUNTRY = 'US' and  LENGTH(ADDR.STATE) > 2 THEN  (SELECT DISTINCT LOOKUP_CODE
																	FROM FND_LOOKUP_VALUES 
																	WHERE LOOKUP_TYPE='GED_FA_STATE_CODES'
																	and  upper(MEANING)  = upper(ADDR.STATE))         
       ELSE TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) 
      END) PhysicalState,
TRIM(SUBSTR(ADDR.POSTAL_CODE,1,10)) PhysicalZip,
TRIM(SUBSTR(ADDR.COUNTRY,1,2)) PhysicalCountry,
NULL MICRNumber,
NULL IBANNumber,
NULL CustAccountStat2_SW,
NULL CustAccountStat3_SW,
NULL CustAccountStat4_SW,
null GECARS_Collector_Code,
null Customer_AR_Type,
NULL TradingPartnerOrPubcode,
--SUBSTR(cust.party_number,1,20) FlexField1,
SUBSTR(CA.ACCOUNT_NUMBER, 1, 20) FlexField1, -- Change back to Cust Acct Number. 05th Aug
--NULL FlexField1, -- Change, no need to have values in flexfields. 28 Jul
NULL FlexField2,
CA.CUSTOMER_CLASS_CODE FlexField3,
NULL FlexField4,
NULL FlexField5,
NULL FlexField6,
NULL FlexField7,
NULL FlexField8,
NULL FlexField9,
NULL FlexField10,
NULL FlexField11,
NULL FlexField12,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS3),'"',NULL),',',NULL),1,48)) PhysicalAddress3,
NULL PhysicalAddress4,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS3),'"',NULL),',',NULL),1,48)) MailingAddress3,
NULL MailingAddress4,
NULL DebtorType,
NULL CompanyNumber,
NULL BICCode,
NULL MandateID,
NULL MandateDate,
NULL ServicingType,
TRIM(SUBSTR(REPLACE(REPLACE((cust.party_name),'"',NULL),',',NULL),1,48)) Extended_Customer_Name,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS1),'"',NULL),',',NULL),1,48)) Native_Address1,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS2),'"',NULL),',',NULL),1,48)) Native_Address2,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS3),'"',NULL),',',NULL),1,48)) Native_Address3,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS4),'"',NULL),',',NULL),1,48)) Native_Address4,
Null Native_Address5,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48)) Native_City,
--TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) Native_State,
(CASE WHEN ADDR.COUNTRY = 'US' and  LENGTH(ADDR.STATE) > 2 THEN  (SELECT DISTINCT LOOKUP_CODE
																	FROM FND_LOOKUP_VALUES 
																	WHERE LOOKUP_TYPE='GED_FA_STATE_CODES'
																	and  upper(MEANING)  = upper(ADDR.STATE))         
       ELSE TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) 
      END) Native_State,
TRIM(SUBSTR(ADDR.POSTAL_CODE,1,10)) Native_Postal_Code,
TRIM(SUBSTR(ADDR.COUNTRY,1,2)) Native_Country,
null Flex_Field13,
null Flex_Field14,
null Flex_Field15,
null Flex_Field16,
null Flex_Field17,
null SOAMessageID,
null TranslatedCustName      --- 02 Added by CG Team 15-Feb-16 ID 451
FROM
    HZ_PARTIES CUST,
    HZ_PARTY_SITES S,
    HZ_CUST_ACCT_SITES_ALL CS,
    HZ_LOCATIONS ADDR,
    HZ_CUST_ACCOUNTS CA,
    HZ_CUST_SITE_USES_ALL U  , AR_REF_ACCOUNTS_ALL ARAA , fun_all_business_units_v FABU
WHERE CUST.party_id = CA.party_id
AND CUST.PARTY_ID = S.PARTY_ID
AND S.PARTY_SITE_ID = CS.PARTY_SITE_ID
AND CUST.PARTY_ID = CA.PARTY_ID
AND CS.CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID
AND S.LOCATION_ID = ADDR.LOCATION_ID
AND CS.CUST_ACCT_SITE_ID = U.CUST_ACCT_SITE_ID
AND U.set_id = CS.set_id
AND U.SITE_USE_CODE = 'BILL_TO'
and ARAA.source_ref_table = 'HZ_CUST_SITE_USES_ALL'
AND ARAA.SOURCE_REF_ACCOUNT_ID = u.SITE_USE_ID
--AND HPSU1.SITE_USE_TYPE = 'BILL_TO'
AND ARAA.BU_ID = FABU.bu_id
-- Changed to extract only if the DFF in AR_SYSTEM_PARAMETERS for the BU associated with
-- the Set Id is not null. 16 Sep
/*AND U.set_id in (SELECT FSA.set_id FROM ar_system_parameters_all ASPA, fun_all_business_units_v FABU, fnd_setid_assignments FSA
                        WHERE ASPA.set_of_books_id = fabu.primary_ledger_id
                        AND   FABU.bu_id = FSA.determinant_value
                        AND   FSA.determinant_type = 'BU'
                        AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
                        AND   ASPA.attribute_category = 'CCLAR'
                        AND   ASPA.attribute1 IS NOT NULL)*/
/*AND U.set_id in (SELECT FSA.set_id FROM ar_system_parameters_all ASPA, fun_all_business_units_v FABU , hr_all_organization_units ha
,fnd_setid_assignments FSA
where aspa.org_id=ha.organization_id 
AND  ha.organization_id = fabu.bu_id
AND   ASPA.attribute_category = 'CCLAR'
AND   ASPA.attribute1 IS NOT NULL
AND   FABU.bu_id = FSA.determinant_value
                        AND   FSA.determinant_type = 'BU'
                        AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE')*/
/*and FABU.bu_name in ( select fab.bu_name FROM ar_system_parameters_all ASPA, fun_all_business_units_v FAB , hr_all_organization_units ha  	
 where 		ha.organization_id = fab.bu_id 	
AND   ASPA.attribute_category = 'CCLAR'
AND   ASPA.attribute1 IS NOT NULL
and ha.organization_id = aspa.org_id)*/
and EXISTS ( select fab.bu_name 
               FROM ar_system_parameters_all ASPA, 
                    fun_all_business_units_v FAB , 
                    hr_all_organization_units ha  	
 	     where ha.organization_id = fab.bu_id 	
	       AND ASPA.attribute_category = 'CCLAR'
	       AND   ASPA.attribute1 IS NOT NULL
               and ha.organization_id = aspa.org_id
               and fab.bu_id = FABU.bu_id ) 
-- End of Changes. 16 Sep
--AND ( (SUBSTR(CA.ACCOUNT_NUMBER, 1, 6) || SUBSTR(U.SITE_USE_ID, -6) = :P_BUSCUST AND :P_BUSCUST IS NOT NULL)
--AND ( (SUBSTR(U.SITE_USE_ID, -6) = :P_BUSCUST AND :P_BUSCUST IS NOT NULL) -- Change to use only Site Use Id. 10 Jun
--AND ( (SUBSTR(s.party_site_number, 1, 12) = :P_BUSCUST AND :P_BUSCUST IS NOT NULL) -- Change to use Site Number. 24 Jul
AND ( (REGEXP_INSTR(:P_BUSCUST, SUBSTR(s.party_site_number, 1, 12)) > 0  AND :P_BUSCUST IS NOT NULL) -- Change for multiple comma separate Site Numbers. 01 Aug
      OR
    (
      :P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NOT NULL AND
     ((U.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       U.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (CA.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       CA.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (CS.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       CS.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (CUST.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       CUST.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (S.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       S.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (ADDR.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       ADDR.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') )
      )
     )
      OR (:P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NULL AND
     ((U.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), U.LAST_UPDATE_DATE-1) OR
       U.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), U.CREATION_DATE-1) ) OR
      (CA.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CA.LAST_UPDATE_DATE-1) OR
       CA.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CA.CREATION_DATE-1) ) OR
      (CS.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL),CS.LAST_UPDATE_DATE-1) OR
       CS.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CS.CREATION_DATE-1) ) OR
      (CUST.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CUST.LAST_UPDATE_DATE-1) OR
       CUST.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CUST.CREATION_DATE-1) ) OR
      (S.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), S.LAST_UPDATE_DATE-1) OR
       S.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), S.CREATION_DATE-1) ) OR
      (ADDR.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), ADDR.LAST_UPDATE_DATE-1) OR
       ADDR.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), ADDR.CREATION_DATE-1) )
      )
     )
    )
AND CA.customer_type = 'R'
AND ADDR.country NOT IN ('IR','SD','SY','KP')
AND CS.status ='A'
AND ADDR.status_flag ='A'
AND CA.status='A'
union
/*-----------------------GECARS_Customer Query for Asia and GED...........................*/
 SELECT --'KEY' KEY,
NULL CustomerNumber,
--SUBSTR(s.party_site_number, 1, 12) BusinessCustomerNumber, -- Change to use Site Number. 24 Jul
   (CASE 
       WHEN LENGTH(s.PARTY_SITE_NUMBER) <=12 THEN  s.PARTY_SITE_NUMBER
       WHEN LENGTH(s.PARTY_SITE_NUMBER) >12 and FABU.BU_NAME not in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU')  THEN SUBSTR(s.PARTY_SITE_NUMBER,-12)
	   WHEN FABU.BU_NAME  = 'JP_AVI_V834_BU' THEN  SUBSTR(s.PARTY_SITE_NUMBER,1,4)||SUBSTR(s.PARTY_SITE_NUMBER,-5)
	   WHEN FABU.BU_NAME  = 'JP_AVI_V833_BU' THEN  SUBSTR(s.PARTY_SITE_NUMBER,1,4)||SUBSTR(s.PARTY_SITE_NUMBER,-5)	   
       ELSE s.PARTY_SITE_NUMBER
      END) BusinessCustomerNumber,
NULL ARCustomerNumber,
NULL GECARSPayingCustomerNumber,
NULL BusinessPayingCustomerNumber,
NULL ARPayingCustomerNumber,
CASE WHEN ARAA.REC_CCID IS NOT NULL THEN                         --REL-007 Adding starts here by Shankar
             (SELECT fvv.attribute7
                FROM FND_FLEX_VALUE_SETS fvs,
                     FND_FLEX_VALUES fvv,
                     FND_SETID_ASSIGNMENTS fsa,
                     GL_CODE_COMBINATIONS gcc
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
                     AND FABU.bu_id = FSA.determinant_value
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = u.set_id
                     AND gcc.segment1 = fvv.flex_value
                     AND gcc.code_combination_id = ARAA.REC_CCID
                     AND ROWNUM = 1)
          WHEN ARAA.REV_CCID IS NOT NULL
          THEN
             (SELECT fvv.attribute7
                FROM FND_FLEX_VALUE_SETS fvs,
                     FND_FLEX_VALUES fvv,
                     FND_SETID_ASSIGNMENTS fsa,
                     GL_CODE_COMBINATIONS gcc
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
                     AND FABU.bu_id = FSA.determinant_value
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = u.set_id
                     AND gcc.segment1 = fvv.flex_value
                     AND gcc.code_combination_id = ARAA.REV_CCID
                     AND ROWNUM = 1)
          ELSE                                      --REL-007 Adding ends here
             (SELECT fvv.attribute7
                FROM FND_FLEX_VALUE_SETS fvs,
                     FND_FLEX_VALUES fvv,
                     FND_SETID_ASSIGNMENTS fsa
               WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
                     AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
                     AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
                     AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
                     AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
                     AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
                     AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
                     AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
                     AND FABU.bu_id = FSA.determinant_value
                     AND FSA.determinant_type = 'BU'
                     AND FSA.reference_group_name =
                            'HZ_CUSTOMER_ACCOUNT_SITE'
                     AND FSA.set_id = u.set_id
                     AND ROWNUM = 1)
       END                                                     --REL-007 Added	
	BillingComponent,
NULL BusinessCode,
TRIM(SUBSTR(REPLACE(REPLACE((cust.party_name),'"',NULL),',',NULL),1,48)) CustomerName,
 (CASE 
        WHEN  FABU.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then 	
														(select fvv.FLEX_VALUE
														from fnd_flex_value_sets  fvs,
															 fnd_flex_values      fvv,  
															 fnd_setid_assignments FSA
														where   fvv.flex_value_set_id        = fvs.flex_value_set_id
														AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'
														and  fvv.ATTRIBUTE9 is not null --BU_Number
														and  fvv.ATTRIBUTE7 is not null -- BCOCODE
														and  fvv.ATTRIBUTE2 is not null -- GECARS_IC
														and  fvv.ATTRIBUTE1 is not null -- GECARS_Extract enabled flag	
														and  fvv.ATTRIBUTE8 is not null -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
														and to_number(fvv.ATTRIBUTE9) = FABU.bu_id
														AND   FABU.bu_id = FSA.determinant_value
														AND   FSA.determinant_type = 'BU'
														AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
														AND   FSA.set_id = u.set_id
														and  rownum =1 )
		ELSE NUll
      END)		Definer ,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS1),'"',NULL),',',NULL),1,48)) MailingAddress1,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS2),'"',NULL),',',NULL),1,48)) MailingAddress2,
--TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48)) MailingCity,
(CASE 
       WHEN ADDR.CITY is null and  FABU.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then 'Tokyo'
	   else TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48))
	   End) MailingCity,
--TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) MailingState,
(CASE WHEN ADDR.COUNTRY = 'US' and  LENGTH(ADDR.STATE) > 2 THEN  (SELECT DISTINCT LOOKUP_CODE
																	FROM FND_LOOKUP_VALUES 
																	WHERE LOOKUP_TYPE='GED_FA_STATE_CODES'
																	and  upper(MEANING)  = upper(ADDR.STATE))         
      ELSE TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) 
	  --ELSE DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE))
      END) MailingState,
TRIM(SUBSTR(ADDR.POSTAL_CODE,1,10)) MailingZip,
TRIM(SUBSTR(DECODE(ADDR.STATE,'PR','PR',ADDR.COUNTRY),1,2)) MailingCountry,
/*(SELECT GL.currency_code FROM gl_ledgers GL, fun_all_business_units_v FABU1, fnd_setid_assignments FSA
                        WHERE GL.ledger_id = fabu.primary_ledger_id
                        AND   FABU1.bu_id = FSA.determinant_value
                        AND   FSA.determinant_type = 'BU'
                        AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
                        AND   FSA.set_id = cs.set_id 
                      AND   FABU1.bu_id = FABU.bu_id
and rownum=1) */
 (select fvv.ATTRIBUTE5
	from fnd_flex_value_sets  fvs,
		 fnd_flex_values      fvv,  
		 fnd_setid_assignments FSA
	where   fvv.flex_value_set_id        = fvs.flex_value_set_id
	AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'
	 and  fvv.ATTRIBUTE9 is not null --BU_Number
    and  fvv.ATTRIBUTE7 is not null -- BCOCODE
    and  fvv.ATTRIBUTE2 is not null -- GECARS_IC
    and  fvv.ATTRIBUTE1 is not null -- GECARS_Extract enabled flag	
    and  fvv.ATTRIBUTE8 is not null --  = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
	and to_number(fvv.ATTRIBUTE9) = FABU.bu_id
	AND   FABU.bu_id = FSA.determinant_value
	AND   FSA.determinant_type = 'BU'
	AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
	AND   FSA.set_id = u.set_id
	and  rownum =1)  BilledCurrency,
/*(SELECT GL.currency_code FROM gl_ledgers GL, fun_all_business_units_v FABU1, fnd_setid_assignments FSA
                        WHERE GL.ledger_id = fabu.primary_ledger_id
                        AND   FABU1.bu_id = FSA.determinant_value
                        AND   FSA.determinant_type = 'BU'
                        AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
                        AND   FSA.set_id = cs.set_id
						AND   FABU1.bu_id = FABU.bu_id
and rownum=1 ) */
(select fvv.ATTRIBUTE5
	from fnd_flex_value_sets  fvs,
		 fnd_flex_values      fvv,  
		 fnd_setid_assignments FSA
	where   fvv.flex_value_set_id        = fvs.flex_value_set_id
	AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'
	--and fvv.attribute8 is not null
	--and  fvv.ATTRIBUTE7 is not null
	and  fvv.ATTRIBUTE9 is not null --BU_Number
    and  fvv.ATTRIBUTE7 is not null -- BCOCODE
    and  fvv.ATTRIBUTE2 is not null -- GECARS_IC
    and  fvv.ATTRIBUTE1 is not null -- GECARS_Extract enabled flag	
    and  fvv.ATTRIBUTE8  is not null --= 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
	and to_number(fvv.ATTRIBUTE9) = FABU.bu_id
	AND   FABU.bu_id = FSA.determinant_value
	AND   FSA.determinant_type = 'BU'
	AND   FSA.reference_group_name = 'HZ_CUSTOMER_ACCOUNT_SITE'
	AND   FSA.set_id = u.set_id
	and  rownum =1) FunctionalCurrency,
'ENG' Language,
NULL HighCredit,
NULL DateofHighCredit,
NULL DateonLateCheck,
NULL AmountofLastCheck,
NULL CurrencyOfLastCheck,
NULL LastCheckNumber,
NULL NumberOfInvoicesBilledYTD,
NULL AmountofInvoiceBilledYTD,
NULL DateofLastSale,
NULL AmountofLastSale,
DECODE(CA.customer_type, 'R', 'E') TypeOfCustomer, -- As only external customers are extracted
NULL SIC,
NULL DUNSNumber,
NULL HQDUNSNumbr,
NULL NewProperty,
NULL DAndBCreditRating,
'N' StatmentMailedFlag,
'N' DunningLettersMailed,
NULL CreditGuide,
NULL SingleShipOrderControl,
NULL HoldIndicatororSpecialStatus,
NULL DateAccountWasOpen,
NULL LastCreditReviewDate,
(SELECT SUBSTR(HP.person_first_name || ' ' || HP.person_last_name, 1, 34)
        FROM hz_parties HP, hz_cust_account_roles HCAR
        WHERE HP.party_id = HCAR.contact_person_id
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
        ----     AND HCAR.role_type = 'CONTACT'
 ------     AND HCAR.primary_flag = 'Y'
and rownum=1 )  ContactName,
(SELECT SUBSTR(HCP.raw_phone_number, 1, 23)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        --AND  HCAR.cust_acct_site_id = CS.cust_acct_site_id -- Change to get from Account level instead of Site. 31 Aug
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
 ---       AND  HCAR.cust_acct_site_id IS NULL -- Change to get from Account level instead of Site. 31 Aug
---8th        AND HCAR.role_type = 'CONTACT'
----8th        AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'PHONE'
        AND HCP.phone_line_type = 'GEN'
        AND HCP.primary_flag = 'Y' 
and rownum=1)  PhoneNumber,
(SELECT SUBSTR(HCP.raw_phone_number, 1, 23)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        --AND  HCAR.cust_acct_site_id = CS.cust_acct_site_id -- Change to get from Account level instead of Site. 31 Aug
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
             AND HCAR.role_type = 'CONTACT'
        AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'PHONE'
        AND HCP.phone_line_type = 'FAX'
        AND HCP.primary_flag = 'Y' 
and rownum=1 ) FaxNumber,
(SELECT SUBSTR(HCP.email_address, 1, 58)
        FROM hz_contact_points HCP, hz_cust_account_roles HCAR
        WHERE HCP.owner_table_id = HCAR.contact_person_id
        AND HCP.owner_table_name = 'HZ_PARTIES'
        --AND  HCAR.cust_acct_site_id = CS.cust_acct_site_id -- Change to get from Account level instead of Site. 31 Aug
        AND  HCAR.cust_account_id = CA.cust_account_id -- Change to get from Account level instead of Site. 31 Aug
               AND HCAR.role_type = 'CONTACT'
        AND HCAR.primary_flag = 'Y'
        AND HCP.contact_point_type = 'EMAIL'
        AND HCP.primary_flag = 'Y' 
and rownum=1) EmailAddress,
NULL DateOfLastCreditGuideChange,
NULL DateofLastSingleShipOrderContr,
NULL DateofCustomerStatusChange,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS1),'"',NULL),',',NULL),1,48)) PhysicalAddress1,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS2),'"',NULL),',',NULL),1,48)) PhysicalAddress2,
--TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48)) PhysicalCity,
(CASE 
       WHEN ADDR.CITY is null and  FABU.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then 'Tokyo'
	   else TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48))
	   End) PhysicalCity,
--TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) PhysicalState,
(CASE WHEN ADDR.COUNTRY = 'US' and  LENGTH(ADDR.STATE) > 2 THEN  (SELECT DISTINCT LOOKUP_CODE
																	FROM FND_LOOKUP_VALUES 
																	WHERE LOOKUP_TYPE='GED_FA_STATE_CODES'
																	and  upper(MEANING)  = upper(ADDR.STATE))         
      ELSE TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) 
	--- ELSE DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE))
      END) PhysicalState,
TRIM(SUBSTR(ADDR.POSTAL_CODE,1,10)) PhysicalZip,
TRIM(SUBSTR(ADDR.COUNTRY,1,2)) PhysicalCountry,
NULL MICRNumber,
NULL IBANNumber,
NULL CustAccountStat2_SW,
NULL CustAccountStat3_SW,
NULL CustAccountStat4_SW,
null GECARS_Collector_Code,
null Customer_AR_Type,
NULL TradingPartnerOrPubcode,
--SUBSTR(cust.party_number,1,20) FlexField1,
SUBSTR(CA.ACCOUNT_NUMBER, 1, 20) FlexField1, -- Change back to Cust Acct Number. 05th Aug
--NULL FlexField1, -- Change, no need to have values in flexfields. 28 Jul
NULL FlexField2,
CA.CUSTOMER_CLASS_CODE FlexField3,
NULL FlexField4,
NULL FlexField5,
NULL FlexField6,
NULL FlexField7,
NULL FlexField8,
NULL FlexField9,
NULL FlexField10,
NULL FlexField11,
NULL FlexField12,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS3),'"',NULL),',',NULL),1,48)) PhysicalAddress3,
NULL PhysicalAddress4,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS3),'"',NULL),',',NULL),1,48)) MailingAddress3,
NULL MailingAddress4,
NULL DebtorType,
NULL CompanyNumber,
NULL BICCode,
NULL MandateID,
NULL MandateDate,
NULL ServicingType,
 (CASE  WHEN  FABU.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then CA.ACCOUNT_NAME  
 else TRIM(SUBSTR(REPLACE(REPLACE((cust.party_name),'"',NULL),',',NULL),1,48)) 
 END) Extended_Customer_Name,
(CASE  WHEN  FABU.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then ADDR.ADDRESS_LINES_PHONETIC
else TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS1),'"',NULL),',',NULL),1,48))
END) Native_Address1,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS2),'"',NULL),',',NULL),1,48)) Native_Address2,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS3),'"',NULL),',',NULL),1,48)) Native_Address3,
TRIM(SUBSTR(REPLACE(REPLACE((ADDR.ADDRESS4),'"',NULL),',',NULL),1,48)) Native_Address4,
null Native_Address5,
--TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48)) Native_City,
(CASE 
       WHEN ADDR.CITY is null and  FABU.BU_NAME  in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU') then 'Tokyo'
	   else TRIM(SUBSTR(REPLACE(REPLACE((ADDR.CITY),'"',NULL),',',NULL),1,48))
	   End) Native_City,
--TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) Native_State,
(CASE WHEN ADDR.COUNTRY = 'US' and  LENGTH(ADDR.STATE)  > 2 THEN  (SELECT DISTINCT LOOKUP_CODE
																	FROM FND_LOOKUP_VALUES 
																	WHERE LOOKUP_TYPE='GED_FA_STATE_CODES'
																	and  upper(MEANING)  = upper(ADDR.STATE))         
       ELSE TRIM(SUBSTR(DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE)),1,2)) 
	    -- ELSE DECODE(ADDR.COUNTRY,'US', ADDR.STATE ,'CA', UPPER(ADDR.PROVINCE) ,NVL(ADDR.STATE,ADDR.PROVINCE))
      END) Native_State,
TRIM(SUBSTR(ADDR.POSTAL_CODE,1,10)) Native_Postal_Code,
TRIM(SUBSTR(ADDR.COUNTRY,1,2)) Native_Country,
null Flex_Field13,
null Flex_Field14,
null Flex_Field15,
null Flex_Field16,
null Flex_Field17,
null SOAMessageID,
CS.TRANSLATED_CUSTOMER_NAME TranslatedCustName    ---  02 Added by CG Team 15-Feb-16  ID 451
FROM
    HZ_PARTIES CUST,
    HZ_PARTY_SITES S,
    HZ_CUST_ACCT_SITES_ALL CS,
    HZ_LOCATIONS ADDR,
    HZ_CUST_ACCOUNTS CA,
    HZ_CUST_SITE_USES_ALL U  , 
	AR_REF_ACCOUNTS_ALL ARAA , 
	fun_all_business_units_v FABU
WHERE CUST.party_id = CA.party_id
AND CUST.PARTY_ID = S.PARTY_ID
AND S.PARTY_SITE_ID = CS.PARTY_SITE_ID	
AND CUST.PARTY_ID = CA.PARTY_ID
AND CS.CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID
AND S.LOCATION_ID = ADDR.LOCATION_ID
AND CS.CUST_ACCT_SITE_ID = U.CUST_ACCT_SITE_ID
AND U.set_id = CS.set_id
AND U.SITE_USE_CODE = 'BILL_TO'
and ARAA.source_ref_table = 'HZ_CUST_SITE_USES_ALL'
AND ARAA.SOURCE_REF_ACCOUNT_ID = u.SITE_USE_ID
--AND HPSU1.SITE_USE_TYPE = 'BILL_TO'
AND ARAA.BU_ID = FABU.bu_id
AND CA.customer_type = 'R'
AND ADDR.country NOT IN ('IR','SD','SY','KP')
AND CS.status ='A'
AND ADDR.status_flag ='A'
AND CA.status='A'
and U.PRIMARY_FLAG = 'Y'
--and ARAA .OBJECT_VERSION_NUMBER = 1
--AND FABU.BU_NAME in ('JP_AVI_V834_BU','JP_AVI_V833_BU')
and EXISTS (select 'Y'
		   from fnd_flex_value_sets  fvs,
				fnd_flex_values      fvv
		  where   fvv.flex_value_set_id        = fvs.flex_value_set_id
		    AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'
            and  fvv.attribute8  is not null
            and  fvv.ATTRIBUTE7 is not null
			and  fvv.ATTRIBUTE2 is not null
			and  fvv.ATTRIBUTE1 = 'Y'
			AND  fvv.ATTRIBUTE8 = 'L'  --REL-007 Added by Shankar to fetch only Lite customers
           and to_number(fvv.ATTRIBUTE9) = FABU.bu_id)
AND ( (REGEXP_INSTR(:P_BUSCUST, SUBSTR(s.party_site_number, 1, 12)) > 0  AND :P_BUSCUST IS NOT NULL) -- Change for multiple comma separate Site Numbers. 01 Aug
      OR
    (
      :P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NOT NULL AND
     ((U.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       U.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (CA.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       CA.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (CS.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       CS.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (CUST.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       CUST.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (S.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       S.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') ) OR
      (ADDR.LAST_UPDATE_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') OR
       ADDR.CREATION_DATE > TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS') )
      )
     )
      OR (:P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NULL AND
     ((U.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), U.LAST_UPDATE_DATE-1) OR
       U.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), U.CREATION_DATE-1) ) OR
      (CA.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CA.LAST_UPDATE_DATE-1) OR
       CA.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CA.CREATION_DATE-1) ) OR
      (CS.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL),CS.LAST_UPDATE_DATE-1) OR
       CS.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CS.CREATION_DATE-1) ) OR
      (CUST.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CUST.LAST_UPDATE_DATE-1) OR
       CUST.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), CUST.CREATION_DATE-1) ) OR
      (S.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), S.LAST_UPDATE_DATE-1) OR
       S.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), S.CREATION_DATE-1) ) OR
							     (ARAA.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), ARAA.LAST_UPDATE_DATE-1) )							 OR
							 
      (ADDR.LAST_UPDATE_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), ADDR.LAST_UPDATE_DATE-1) OR
       ADDR.CREATION_DATE > NVL( (SELECT MAX(ERH.processstart )
                             FROM ess_request_history ERH
                                 ,ess_request_property ERP1
                                 ,ess_request_property ERP2
                             WHERE ERH.requestid = ERP1.requestid
                             AND ERH.requestid = ERP2.requestid
                             AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_CARS_CUST_EXTRACT'
                             AND ERH.executable_status = 'SUCCEEDED'
                             AND ERP1.name = 'submit.argument1'
                             AND ERP1.value IS NULL
                             AND ERP2.name = 'submit.argument2'
                             AND ERP2.value IS NULL), ADDR.CREATION_DATE-1) )
      )
     )
    )  
UNION  
SELECT --'KEY' KEY,
NULL CustomerNumber,
NULL BusinessCustomerNumber,
NULL ARCustomerNumber,
NULL GECARSPayingCustomerNumber,
NULL BusinessPayingCustomerNumber,
NULL ARPayingCustomerNumber,
NULL BillingComponent,
NULL BusinessCode,
NULL CustomerName,
NULL Definer,
NULL MailingAddress1,
NULL MailingAddress2,
NULL MailingCity,
NULL MailingState,
NULL MailingZip,
NULL MailingCountry,
NULL BilledCurrency,
NULL FunctionalCurrency,
'X#Y#Z' Language,
NULL HighCredit,
NULL DateofHighCredit,
NULL DateonLateCheck,
NULL AmountofLastCheck,
NULL CurrencyOfLastCheck,
NULL LastCheckNumber,
NULL NumberOfInvoicesBilledYTD,
NULL AmountofInvoiceBilledYTD,
NULL DateofLastSale,
NULL AmountofLastSale,
NULL TypeOfCustomer,
NULL SIC,
NULL DUNSNumber,
NULL HQDUNSNumbr,
NULL NewProperty,
NULL DAndBCreditRating,
NULL StatmentMailedFlag,
NULL DunningLettersMailed,
NULL CreditGuide,
NULL SingleShipOrderControl,
NULL HoldIndicatororSpecialStatus,
NULL DateAccountWasOpen,
NULL LastCreditReviewDate,
NULL ContactName,
NULL PhoneNumber,
NULL FaxNumber,
NULL EmailAddress,
NULL DateOfLastCreditGuideChange,
NULL DateofLastSingleShipOrderContr,
NULL DateofCustomerStatusChange,
NULL PhysicalAddress1,
NULL PhysicalAddress2,
NULL PhysicalCity,
NULL PhysicalState,
NULL PhysicalZip,
NULL PhysicalCountry,
NULL MICRNumber,
NULL IBANNumber,
NULL CustAccountStat2_SW,
NULL CustAccountStat3_SW,
NULL CustAccountStat4_SW,
null GECARS_Collector_Code,
null Customer_AR_Type,
NULL TradingPartnerOrPubcode,
NULL FlexField1,
NULL FlexField2,
NULL FlexField3,
NULL FlexField4,
NULL FlexField5,
NULL FlexField6,
NULL FlexField7,
NULL FlexField8,
NULL FlexField9,
NULL FlexField10,
NULL FlexField11,
NULL FlexField12,
NULL PhysicalAddress3,
NULL PhysicalAddress4,
NULL MailingAddress3,
NULL MailingAddress4,
NULL DebtorType,
NULL CompanyNumber,
NULL BICCode,
NULL MandateID,
NULL MandateDate,
NULL ServicingType,
Null Extended_Customer_Name,
Null Native_Address1,
Null Native_Address2,
Null Native_Address3,
Null Native_Address4,
Null Native_Address5,
Null Native_City,
null Native_State,
null Native_Postal_Code,
null Native_Country,
null Flex_Field13,
null Flex_Field14,
null Flex_Field15,
null Flex_Field16,
null Flex_Field17,
null SOAMessageID,
null TranslatedCustName    ---  02 Added by CG Team 15-Feb-16  ID 451
FROM sys.dual
ORDER BY BusinessCustomerNumber