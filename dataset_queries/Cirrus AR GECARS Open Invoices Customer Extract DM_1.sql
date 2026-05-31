/*--#-----------------------------------------------------------------------------------------------------------------#
--# GECARS Customer Extract for Open Invoices data model
--# DESCRIPTION  : This data model query used to get the GECARS customer extract
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-018 EMG	        Neeraj Shrivastava 20-JUN-2018		    GECARS Customer Extract for Open Invoices data model
--# REL-018 EMG	        Neeraj Shrivastava 09-SEP-2018		    Added the condition to check accounting date.
--# REL-037             Raghunath Balaji   27-JAN-2020			Added a logic to extract the entire characters of 
--#                                                             Business customer number for Indonesia BU
--# REL-045 			Sowndarya          13-OCT-2020          Added logic to send Non IBS internal customer invoices to GECARS for collection
--# REL-055             Om Yellapragada    13-AUG-2021          GEINC9884828 / GERITM24320967 All non-external customers should be pulled as Internal , modified logic accordingly
--# REL-071             Venkatesh S        12-DEC-2022          Included new BU  to get BillingComponent																										
--# ---------------------------------------------------------------------------------------------------------------------
*/
SELECT     DISTINCT  NULL CustomerNumber,     --SUBSTR(CA.ACCOUNT_NUMBER, 1, 6) || SUBSTR(U.SITE_USE_ID, -6) BusinessCustomerNumber,
    --SUBSTR(U.SITE_USE_ID, -6) BusinessCustomerNumber, -- Change to use only Site Use Id. 10 Jun
	SUBSTR(s.party_site_number, 1, 12) BusinessCustomerNumber, -- Change to use Site Number. 24 Jul
    NULL ARCustomerNumber,
    NULL GECARSPayingCustomerNumber,
    NULL BusinessPayingCustomerNumber,
    NULL ARPayingCustomerNumber,
    --'BCO200' BillingComponent,
    CASE WHEN fabu.bu_name in('CA_CAD_BU','CA_CC2107_CAD_BU') THEN     --modified by Venkatesh for Canada Project--REL071                                -- REL-007 Added by Shankar
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
						 AND FABU1.bu_id = asp.org_id --Added by Venkatesh for Canada Project--REL071
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
    RCT.INVOICE_CURRENCY_CODE BilledCurrency,
	(SELECT GLL.CURRENCY_CODE 
	 FROM   GL_LEDGERS GLL
     WHERE  FABU.primary_ledger_id = GLL.ledger_id
	 AND ROWNUM = 1
    ) FunctionalCurrency,
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
    --DECODE(CA.customer_type, 'R', 'E') TypeOfCustomer, -- As only external customers are extracted REL-045 Commented Line
	--REL-045 Added below code
	--DECODE(CA.customer_type, 'R', 'E','I','E','N','E') TypeOfCustomer, --- Commented for REL-055 GEINC9884828 / GERITM24320967
	      -- As only external customers are extracted -- made all customers to 'E' as SOA was not able customers other than E.
	--REL-045 Added above code
	DECODE(CA.customer_type, 'R', 'E','I') TypeOfCustomer,  -- Added for REL-055 GEINC9884828 / GERITM24320967
	
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
        HZ_CUST_SITE_USES_ALL U, 
        AR_REF_ACCOUNTS_ALL ARAA, 
        fun_all_business_units_v FABU,
        AR_PAYMENT_SCHEDULES_ALL APS,
        RA_CUSTOMER_TRX_ALL RCT    
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
AND ARAA.BU_ID = FABU.bu_id
and EXISTS ( select fab.bu_name 
               FROM ar_system_parameters_all ASPA, 
                    fun_all_business_units_v FAB , 
                    hr_all_organization_units ha      
          where ha.organization_id = fab.bu_id     
           AND ASPA.attribute_category = 'CCLAR'
           AND   ASPA.attribute1 IS NOT NULL
               and ha.organization_id = aspa.org_id
               and fab.bu_id = FABU.bu_id ) 
--AND CA.customer_type = 'R' REL-045 Commented Line
--REL-045 Added below code
AND (CA.CUSTOMER_TYPE = 'R' OR ((ca.customer_type,rct.org_id) IN (SELECT a.customer_type,ract.org_id FROM hz_cust_accounts a,ra_customer_trx_all ract
                                                                   WHERE cust_account_id IN (SELECT lookup_code 
                                                                                               FROM fnd_lookup_values 
                                                                                              WHERE lookup_type='CIRRUSGSAR_GECARS_CUS_INV'--'CIRRUSAR_GS_GECARS_CUS_INV'
                                                                                                AND LANGUAGE='US'
                                                                                                AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                                                AND enabled_flag = 'Y' ) 
                                                                     AND a.cust_account_id = ract.bill_to_customer_id
                                                                     AND rct.customer_trx_id = ract.customer_trx_id
                                                                     AND ract.org_id IN (SELECT bu_id 
                                                                                           FROM fun_all_business_units_v 
                                                                                          WHERE bu_name IN(SELECT meaning 
                                                                                                             FROM fnd_lookup_values 
                                                                                                            WHERE lookup_type = 'GED_BU_NAMES' 
                                                                                                              AND LANGUAGE='US' 
                                                                                                              AND description = 'GRID_SWS'
                                                                                                              AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                                                              AND enabled_flag = 'Y')
                                                                                         )
                                                                  )
                                 )
      )
--REL-045 Added above code
AND ADDR.country NOT IN ('IR','SD','SY','KP')
AND CS.status ='A'
AND ADDR.status_flag ='A'
AND CA.status='A'
AND CA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
AND APS.ACCTD_AMOUNT_DUE_REMAINING <> 0
AND APS.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID      
AND APS.STATUS          = 'OP'
AND RCT.org_id = FABU.bu_id
AND U.site_use_id = RCT.bill_to_site_use_id
AND EXISTS( SELECT 1 
            FROM  XLA_AE_HEADERS XAH,
                  RA_CUST_TRX_LINE_GL_DIST_ALL RCG1
            WHERE RCG1.ACCOUNT_CLASS = 'REC'
            AND RCG1.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
            AND RCG1.EVENT_ID = XAH.EVENT_ID
            AND XAH.GL_TRANSFER_DATE IS NOT NULL
          ) 
-- Commented below code for REL-055 GEINC9884828 / GERITM24320967
/*
AND ( (:P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NULL AND ( RCT.LAST_UPDATE_DATE > NVL((SELECT MAX(ERH.processstart) 
FROM ess_request_history ERH
,ess_request_property ERP1
,ess_request_property ERP2
WHERE ERH.requestid = ERP1.requestid
AND ERH.requestid = ERP2.requestid
AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/Custom/Financials/AR/CIRRUS_GECAR_CUSTINV_EXTRACT'
 AND ERH.executable_status IN ( 'SUCCEEDED')
AND ERP1.name = 'submit.argument1'
AND ERP1.value IS NULL
AND ERP2.name = 'submit.argument2'
AND ERP2.value IS NULL),TRUNC(SYSDATE)-1) OR
-- Added by Neeraj Shrivastava to check GL_TRANSFER_DATE
(SELECT XAH.GL_TRANSFER_DATE 
            FROM  XLA_AE_HEADERS XAH,
                  RA_CUST_TRX_LINE_GL_DIST_ALL RCG1
            WHERE RCG1.ACCOUNT_CLASS = 'REC'
            AND RCG1.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
            AND RCG1.EVENT_ID = XAH.EVENT_ID
            AND XAH.GL_TRANSFER_DATE IS NOT NULL
            AND ROWNUM<=1 )
			> NVL((SELECT MAX(ERH.processstart) 
FROM ess_request_history ERH
,ess_request_property ERP1
,ess_request_property ERP2
WHERE ERH.requestid = ERP1.requestid
AND ERH.requestid = ERP2.requestid
AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/Custom/Financials/AR/CIRRUS_GECAR_CUSTINV_EXTRACT'
 AND ERH.executable_status IN ( 'SUCCEEDED')
AND ERP1.name = 'submit.argument1'
AND ERP1.value IS NULL
AND ERP2.name = 'submit.argument2'
AND ERP2.value IS NULL),TRUNC(SYSDATE)-1)
OR
       RCT.CREATION_DATE > NVL((SELECT MAX(ERH.processstart) 
FROM ess_request_history ERH
,ess_request_property ERP1
,ess_request_property ERP2
WHERE ERH.requestid = ERP1.requestid
AND ERH.requestid = ERP2.requestid
AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/Custom/Financials/AR/CIRRUS_GECAR_CUSTINV_EXTRACT'
 AND ERH.executable_status IN ( 'SUCCEEDED')
AND ERP1.name = 'submit.argument1'
AND ERP1.value IS NULL
AND ERP2.name = 'submit.argument2'
AND ERP2.value IS NULL),TRUNC(SYSDATE)-1)))
OR
(
 :P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NOT NULL AND
     ((RCT.LAST_UPDATE_DATE > NVL(TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE-1) OR
	 (SELECT XAH.GL_TRANSFER_DATE 
            FROM  XLA_AE_HEADERS XAH,
                  RA_CUST_TRX_LINE_GL_DIST_ALL RCG1
            WHERE RCG1.ACCOUNT_CLASS = 'REC'
            AND RCG1.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
            AND RCG1.EVENT_ID = XAH.EVENT_ID
            AND XAH.GL_TRANSFER_DATE IS NOT NULL
            AND ROWNUM<=1 ) > NVL(TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE-1)
	   OR
       RCT.CREATION_DATE > NVL(TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE-1 )
     )
)
)
)
--AND CA.account_number = '100020'

UNION ALL
*/
-- Commented above code for REL-055	GEINC9884828 / GERITM24320967	  
UNION   -- Added UNION for REL-055	GEINC9884828 / GERITM24320967	 
SELECT DISTINCT --'KEY' KEY,
NULL CustomerNumber, 
--SUBSTR(s.party_site_number, 1, 12) BusinessCustomerNumber, -- Change to use Site Number. 24 Jul
   (CASE 
       WHEN LENGTH(s.PARTY_SITE_NUMBER) <=12 THEN  s.PARTY_SITE_NUMBER
       --WHEN LENGTH(s.PARTY_SITE_NUMBER) >12 and FABU.BU_NAME not in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU')  THEN SUBSTR(s.PARTY_SITE_NUMBER,-12) --Commented as part of Rel-037
	   --Added the below code as part of REL-037
	   WHEN LENGTH(s.PARTY_SITE_NUMBER) >12 and FABU.BU_NAME not in (SELECT lookup_code 
																	   FROM FND_LOOKUP_VALUES
																      WHERE lookup_type='CIRRUSAR_GECARS_BUEXCEPTIONS'
																	    AND language='US'
																	    AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
																	    AND enabled_flag = 'Y')
	   THEN SUBSTR(s.PARTY_SITE_NUMBER,-12)
	   --Added the above code as part of REL-037
       WHEN FABU.BU_NAME  = 'JP_AVI_V834_BU' THEN  SUBSTR(s.PARTY_SITE_NUMBER,1,4)||SUBSTR(s.PARTY_SITE_NUMBER,-5)
       WHEN FABU.BU_NAME  = 'JP_AVI_V833_BU' THEN  SUBSTR(s.PARTY_SITE_NUMBER,1,4)||SUBSTR(s.PARTY_SITE_NUMBER,-5)       
       ELSE s.PARTY_SITE_NUMBER
      END) BusinessCustomerNumber,
NULL ARCustomerNumber,
NULL GECARSPayingCustomerNumber,
NULL BusinessPayingCustomerNumber,
NULL ARPayingCustomerNumber,
(SELECT fvv.attribute7
 FROM FND_FLEX_VALUE_SETS fvs,
      FND_FLEX_VALUES fvv,
      RA_CUST_TRX_LINE_GL_DIST_ALL RCTLG,
      GL_CODE_COMBINATIONS GCC
 WHERE     fvv.flex_value_set_id = fvs.flex_value_set_id
 AND fvs.flex_value_set_name = 'CCL_COMPANY_CODES'
 AND fvv.ATTRIBUTE9 IS NOT NULL                --BU_Number
 AND fvv.ATTRIBUTE7 IS NOT NULL                 -- BCOCODE
 AND fvv.ATTRIBUTE2 IS NOT NULL               -- GECARS_IC
 AND fvv.ATTRIBUTE1 IS NOT NULL -- GECARS_Extract enabled flag
 AND fvv.ATTRIBUTE8 IS NOT NULL -- = 'C' -- GECARS type 'L' = 'Lite', 'C'= 'Classic', 'P' = 'Prime'
 AND TO_NUMBER (fvv.ATTRIBUTE9) = FABU.bu_id
 AND GCC.code_combination_id = RCTLG.code_combination_id
 AND RCTLG.ACCOUNT_CLASS = 'REC'
 AND RCTLG.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
 AND RCTLG.ACCOUNT_CLASS = 'REC'
 AND ROWNUM = 1) BillingComponent,
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
      END)        Definer ,
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
   RCT.INVOICE_CURRENCY_CODE BilledCurrency,
	(SELECT GLL.CURRENCY_CODE 
	 FROM   GL_LEDGERS GLL
     WHERE  FABU.primary_ledger_id = GLL.ledger_id
	 AND ROWNUM = 1
    ) FunctionalCurrency,
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
--DECODE(CA.customer_type, 'R', 'E') TypeOfCustomer, -- As only external customers are extracted --REL-045 Commented Line
--REL-045 Added below code
--DECODE(CA.customer_type, 'R', 'E','I','E','N','E') TypeOfCustomer, -- Commented for REL-055 GEINC9884828 / GERITM24320967
	          -- As only external customers are extracted -- made all customers to 'E' as SOA was not able customers other than E.
--REL-045 Added above code
DECODE(CA.customer_type, 'R', 'E','I') TypeOfCustomer,      -- Added for REL-055 GEINC9884828 / GERITM24320967

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
    HZ_CUST_SITE_USES_ALL U,
    RA_CUSTOMER_TRX_ALL RCT,
    fun_all_business_units_v FABU,
    AR_PAYMENT_SCHEDULES_ALL APS    
WHERE CUST.party_id = CA.party_id
AND CUST.PARTY_ID = S.PARTY_ID
AND S.PARTY_SITE_ID = CS.PARTY_SITE_ID    
AND CUST.PARTY_ID = CA.PARTY_ID
AND CS.CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID
AND S.LOCATION_ID = ADDR.LOCATION_ID
AND CS.CUST_ACCT_SITE_ID = U.CUST_ACCT_SITE_ID
AND U.set_id = CS.set_id
AND U.SITE_USE_CODE = 'BILL_TO'
--AND CA.customer_type = 'R' --REL-045 Commented Line
--REL-045 Added below code
AND (CA.CUSTOMER_TYPE = 'R' OR ((ca.customer_type,rct.org_id) IN (SELECT a.customer_type,ract.org_id FROM hz_cust_accounts a,ra_customer_trx_all ract
                                                                   WHERE cust_account_id IN (SELECT lookup_code 
                                                                                               FROM fnd_lookup_values 
                                                                                              WHERE lookup_type='CIRRUSGSAR_GECARS_CUS_INV'--'CIRRUSAR_GS_GECARS_CUS_INV'
                                                                                                AND LANGUAGE='US'
                                                                                                AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                                                AND enabled_flag = 'Y' ) 
                                                                     AND a.cust_account_id = ract.bill_to_customer_id
                                                                     AND rct.customer_trx_id = ract.customer_trx_id
                                                                     AND ract.org_id IN (SELECT bu_id 
                                                                                           FROM fun_all_business_units_v 
                                                                                          WHERE bu_name IN(SELECT meaning 
                                                                                                             FROM fnd_lookup_values 
                                                                                                            WHERE lookup_type = 'GED_BU_NAMES' 
                                                                                                              AND LANGUAGE='US' 
                                                                                                              AND description = 'GRID_SWS'
                                                                                                              AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                                                              AND enabled_flag = 'Y')
                                                                                         )
                                                                  )
                                 )
      )
--REL-045 Added above code
AND ADDR.country NOT IN ('IR','SD','SY','KP')
AND CS.status ='A'
AND ADDR.status_flag ='A'
AND CA.status='A'
and U.PRIMARY_FLAG = 'Y'
AND CA.CUST_ACCOUNT_ID = RCT.BILL_TO_CUSTOMER_ID
AND RCT.org_id = FABU.bu_id
AND APS.ACCTD_AMOUNT_DUE_REMAINING <> 0
AND APS.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID      
AND APS.STATUS          = 'OP'
--- Commented below code for REL-055 GEINC9884828 / GERITM24320967 as it is duplicated condition
/*
--AND CA.CUSTOMER_TYPE    = 'R' --REL-045 Commented Line
--REL-045 Added below code
AND (CA.CUSTOMER_TYPE = 'R' OR ((ca.customer_type,rct.org_id) IN (SELECT a.customer_type,ract.org_id FROM hz_cust_accounts a,ra_customer_trx_all ract
                                                                   WHERE cust_account_id IN (SELECT lookup_code 
                                                                                               FROM fnd_lookup_values 
                                                                                              WHERE lookup_type='CIRRUSGSAR_GECARS_CUS_INV'--'CIRRUSAR_GS_GECARS_CUS_INV'
                                                                                                AND LANGUAGE='US'
                                                                                                AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                                                AND enabled_flag = 'Y' ) 
                                                                     AND a.cust_account_id = ract.bill_to_customer_id
                                                                     AND rct.customer_trx_id = ract.customer_trx_id
                                                                     AND ract.org_id IN (SELECT bu_id 
                                                                                           FROM fun_all_business_units_v 
                                                                                          WHERE bu_name IN(SELECT meaning 
                                                                                                             FROM fnd_lookup_values 
                                                                                                            WHERE lookup_type = 'GED_BU_NAMES' 
                                                                                                              AND LANGUAGE='US' 
                                                                                                              AND description = 'GRID_SWS'
                                                                                                              AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                                                              AND enabled_flag = 'Y')
                                                                                         )
                                                                  )
                                 )
      )
--REL-045 Added above code
*/
--- Commented above code for REL-055	GEINC9884828 / GERITM24320967
AND U.site_use_id = RCT.bill_to_site_use_id
AND EXISTS( SELECT 1 
            FROM  XLA_AE_HEADERS XAH,
                  RA_CUST_TRX_LINE_GL_DIST_ALL RCG1
            WHERE RCG1.ACCOUNT_CLASS = 'REC'
            AND RCG1.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
            AND RCG1.EVENT_ID = XAH.EVENT_ID
            AND XAH.GL_TRANSFER_DATE IS NOT NULL
          )
AND EXISTS (select 'Y'
           from fnd_flex_value_sets  fvs,
                fnd_flex_values      fvv
           where   fvv.flex_value_set_id        = fvs.flex_value_set_id
            AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'
            and  fvv.attribute8  is not null
            and  fvv.ATTRIBUTE7 is not null
            and  fvv.ATTRIBUTE2 is not null
            and  fvv.ATTRIBUTE1 = 'Y'
            AND  fvv.ATTRIBUTE8 = 'L'  --REL-007 Added by Shankar to fetch only Lite customers
           and TO_NUMBER(fvv.ATTRIBUTE9) = FABU.bu_id)
--- Commented below code for REL-055 GEINC9884828 / GERITM24320967
/*
AND ( (:P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NULL AND ( RCT.LAST_UPDATE_DATE > NVL((SELECT MAX(ERH.processstart) 
FROM ess_request_history ERH
,ess_request_property ERP1
,ess_request_property ERP2
WHERE ERH.requestid = ERP1.requestid
AND ERH.requestid = ERP2.requestid
AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/Custom/Financials/AR/CIRRUS_GECAR_CUSTINV_EXTRACT'
 AND ERH.executable_status IN ( 'SUCCEEDED')
AND ERP1.name = 'submit.argument1'
AND ERP1.value IS NULL
AND ERP2.name = 'submit.argument2'
AND ERP2.value IS NULL),TRUNC(SYSDATE)-1) OR
-- Added by Neeraj Shrivastava to check GL_TRANSFER_DATE
(SELECT XAH.GL_TRANSFER_DATE 
            FROM  XLA_AE_HEADERS XAH,
                  RA_CUST_TRX_LINE_GL_DIST_ALL RCG1
            WHERE RCG1.ACCOUNT_CLASS = 'REC'
            AND RCG1.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
            AND RCG1.EVENT_ID = XAH.EVENT_ID
            AND XAH.GL_TRANSFER_DATE IS NOT NULL
            AND ROWNUM<=1 )
			> NVL((SELECT MAX(ERH.processstart) 
FROM ess_request_history ERH
,ess_request_property ERP1
,ess_request_property ERP2
WHERE ERH.requestid = ERP1.requestid
AND ERH.requestid = ERP2.requestid
AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/Custom/Financials/AR/CIRRUS_GECAR_CUSTINV_EXTRACT'
 AND ERH.executable_status IN ( 'SUCCEEDED')
AND ERP1.name = 'submit.argument1'
AND ERP1.value IS NULL
AND ERP2.name = 'submit.argument2'
AND ERP2.value IS NULL),TRUNC(SYSDATE)-1)
OR
       RCT.CREATION_DATE > NVL((SELECT MAX(ERH.processstart) 
FROM ess_request_history ERH
,ess_request_property ERP1
,ess_request_property ERP2
WHERE ERH.requestid = ERP1.requestid
AND ERH.requestid = ERP2.requestid
AND ERH.definition = 'JobDefinition://oracle/apps/ess/custom/Custom/Financials/AR/CIRRUS_GECAR_CUSTINV_EXTRACT'
 AND ERH.executable_status IN ( 'SUCCEEDED')
AND ERP1.name = 'submit.argument1'
AND ERP1.value IS NULL
AND ERP2.name = 'submit.argument2'
AND ERP2.value IS NULL),TRUNC(SYSDATE)-1)))
OR
(
 :P_BUSCUST IS NULL AND :P_LAST_RUN_DATE IS NOT NULL AND
     ((RCT.LAST_UPDATE_DATE > NVL(TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE-1) OR
	 (SELECT XAH.GL_TRANSFER_DATE 
            FROM  XLA_AE_HEADERS XAH,
                  RA_CUST_TRX_LINE_GL_DIST_ALL RCG1
            WHERE RCG1.ACCOUNT_CLASS = 'REC'
            AND RCG1.CUSTOMER_TRX_ID = RCT.CUSTOMER_TRX_ID
            AND RCG1.EVENT_ID = XAH.EVENT_ID
            AND XAH.GL_TRANSFER_DATE IS NOT NULL
            AND ROWNUM<=1 ) > NVL(TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE-1)
	   OR
       RCT.CREATION_DATE > NVL(TO_DATE(:P_LAST_RUN_DATE, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE-1 )
     )
)
)
)
*/
--- Commented above code for REL-055 GEINC9884828 / GERITM24320967
-- Added below code for REL-055 GEINC9884828 / GERITM24320967
UNION
SELECT     DISTINCT  NULL CustomerNumber,     --SUBSTR(CA.ACCOUNT_NUMBER, 1, 6) || SUBSTR(U.SITE_USE_ID, -6) BusinessCustomerNumber,
    --SUBSTR(U.SITE_USE_ID, -6) BusinessCustomerNumber, -- Change to use only Site Use Id. 10 Jun
    SUBSTR(s.party_site_number, 1, 12) BusinessCustomerNumber, -- Change to use Site Number. 24 Jul
    NULL ARCustomerNumber,
    NULL GECARSPayingCustomerNumber,
    NULL BusinessPayingCustomerNumber,
    NULL ARPayingCustomerNumber,
--	RCTA.RECEIPT_NUMBER,
    --'BCO200' BillingComponent,
    CASE WHEN fabu.bu_name in('CA_CAD_BU','CA_CC2107_CAD_BU') THEN                                     -- REL-007 Added by Shankar--modified by Venkatesh for Canada Project--REL071 -- REL-007 Added by Shankar
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
                         AND FABU1.bu_id = asp.org_id --Added by Venkatesh for Canada Project--REL071
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
    --RCT.INVOICE_CURRENCY_CODE BilledCurrency,     --Commented by 502754644
	RCTA.CURRENCY_CODE BilledCurrency,
	(SELECT GLL.CURRENCY_CODE 
	 FROM   GL_LEDGERS GLL
     WHERE  FABU.primary_ledger_id = GLL.ledger_id
	 AND ROWNUM = 1
    ) FunctionalCurrency,
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
    --DECODE(CA.customer_type, 'R', 'E') TypeOfCustomer, -- As only external customers are extracted REL-045 Commented Line
	--REL-045 Added below code
	--DECODE(CA.customer_type, 'R', 'E','I','E','N','E') TypeOfCustomer, Commented for REL-055 GEINC9884828 / GERITM24320967
	                    -- As only external customers are extracted -- made all customers to 'E' as SOA was not able customers other than E.
	--REL-045 Added above code
	DECODE(CA.customer_type, 'R', 'E','I') TypeOfCustomer,       -- Added for REL-055 GEINC9884828 / GERITM24320967
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
        HZ_CUST_SITE_USES_ALL U, 
        AR_REF_ACCOUNTS_ALL ARAA, 
        fun_all_business_units_v FABU,
        AR_PAYMENT_SCHEDULES_ALL APS,
       -- RA_CUSTOMER_TRX_ALL RCT     				 --Commented by 502754644
	    AR_CASH_RECEIPTS_ALL RCTA  					 -- Added by 502754644
		,AR_CASH_RECEIPT_HISTORY_ALL HIST			 -- Added by 502754644
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
AND ARAA.BU_ID = FABU.bu_id
AND APS.CASH_RECEIPT_ID   = RCTA.CASH_RECEIPT_ID   -- Added by 502754644
AND APS.ORG_ID            = RCTA.ORG_ID            -- Added by 502754644
AND HIST.CASH_RECEIPT_ID  = RCTA.CASH_RECEIPT_ID   -- Added by 502754644
AND HIST.ORG_ID           = RCTA.ORG_ID            -- Added by 502754644
AND RCTA.PAY_FROM_CUSTOMER = CA.CUST_ACCOUNT_ID    -- Added by 502754644
AND FABU.bu_id                 = rcta.org_id       -- Added by 502754644
AND HIST.CURRENT_RECORD_FLAG = 'Y'				  -- Added by 502754644
--AND APS.CUSTOMER_ID = CA.CUSTOMER_ID  -- Added by 502754644
--AND APS.CUSTOMER_SITE_USE_ID = CS.CUSTOMER_SITE_USE_ID   -- Added by 502754644
--AND U.CUSTOMER_SITE_USE_ID=RCTA.CUSTOMER_SITE_USE_ID     -- Added by 502754644
and EXISTS ( select fab.bu_name  
               FROM ar_system_parameters_all ASPA, 
                    fun_all_business_units_v FAB , 
                    hr_all_organization_units ha      
          where ha.organization_id = fab.bu_id     
           AND ASPA.attribute_category = 'CCLAR'
           AND   ASPA.attribute1 IS NOT NULL
               and ha.organization_id = aspa.org_id
               and fab.bu_id = FABU.bu_id ) 
--AND CA.customer_type = 'R' REL-045 Commented Line
--REL-045 Added below code
AND (CA.CUSTOMER_TYPE = 'R' 
						OR (ca.cust_account_id IN (SELECT lookup_code 
                                                     FROM FND_LOOKUP_VALUES 
                                                    WHERE lookup_type='CIRRUSGSAR_GECARS_CUS_INV'
                                                      AND language='US'
                                                      AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                      AND enabled_flag = 'Y' ) 
							AND rcta.org_id IN (SELECT bu_id 
												 FROM FUN_ALL_BUSINESS_UNITS_V 
												WHERE bu_name IN(SELECT meaning 
																   FROM fnd_lookup_values
                                                                  WHERE lookup_type = 'GED_BU_NAMES' 
                                                                    AND LANGUAGE ='US' 
                                                                    AND description = 'GRID_SWS'
                                                                    AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                    AND enabled_flag = 'Y'))
							)						  
	)	
--REL-045 Added above code
AND ADDR.country NOT IN ('IR','SD','SY','KP')
AND CS.status ='A'
AND ADDR.status_flag ='A'
AND CA.status='A'
--AND RCTA.creation_date>sysdate-100
AND APS.ACCTD_AMOUNT_DUE_REMAINING <> 0
AND APS.STATUS          = 'OP'
UNION
SELECT DISTINCT --'KEY' KEY,
NULL CustomerNumber, 
--SUBSTR(s.party_site_number, 1, 12) BusinessCustomerNumber, -- Change to use Site Number. 24 Jul
   (CASE 
       WHEN LENGTH(s.PARTY_SITE_NUMBER) <=12 THEN  s.PARTY_SITE_NUMBER
       --WHEN LENGTH(s.PARTY_SITE_NUMBER) >12 and FABU.BU_NAME not in ('JP_AVI_V834_BU' , 'JP_AVI_V833_BU')  THEN SUBSTR(s.PARTY_SITE_NUMBER,-12) --Commented as part of Rel-037
	   --Added the below code as part of REL-037
	   WHEN LENGTH(s.PARTY_SITE_NUMBER) >12 and FABU.BU_NAME not in (SELECT lookup_code 
																	   FROM FND_LOOKUP_VALUES
																      WHERE lookup_type='CIRRUSAR_GECARS_BUEXCEPTIONS'
																	    AND language='US'
																	    AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
																	    AND enabled_flag = 'Y')
	   THEN SUBSTR(s.PARTY_SITE_NUMBER,-12)
	   --Added the above code as part of REL-037
       WHEN FABU.BU_NAME  = 'JP_AVI_V834_BU' THEN  SUBSTR(s.PARTY_SITE_NUMBER,1,4)||SUBSTR(s.PARTY_SITE_NUMBER,-5)
       WHEN FABU.BU_NAME  = 'JP_AVI_V833_BU' THEN  SUBSTR(s.PARTY_SITE_NUMBER,1,4)||SUBSTR(s.PARTY_SITE_NUMBER,-5)       
       ELSE s.PARTY_SITE_NUMBER
      END) BusinessCustomerNumber,
NULL ARCustomerNumber,
NULL GECARSPayingCustomerNumber,
NULL BusinessPayingCustomerNumber,
NULL ARPayingCustomerNumber,
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
                         AND ROWNUM = 1) BillingComponent,
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
      END)        Definer ,
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
   RCTA.CURRENCY_CODE BilledCurrency,
	(SELECT GLL.CURRENCY_CODE 
	 FROM   GL_LEDGERS GLL
     WHERE  FABU.primary_ledger_id = GLL.ledger_id
	 AND ROWNUM = 1
    ) FunctionalCurrency,
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
--DECODE(CA.customer_type, 'R', 'E') TypeOfCustomer, -- As only external customers are extracted REL-045 Commented Line
--REL-045 Added below code
	--DECODE(CA.customer_type, 'R', 'E','I','E','N','E') TypeOfCustomer, -- Commented for REL-055 GEINC9884828 / GERITM24320967
	             -- As only external customers are extracted -- made all customers to 'E' as SOA was not able customers other than E.
--REL-045 Added above code
DECODE(CA.customer_type, 'R', 'E','I') TypeOfCustomer,  -- Added for REL-055 GEINC9884828 / GERITM24320967
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
    HZ_CUST_SITE_USES_ALL U,
    fun_all_business_units_v FABU,
    AR_PAYMENT_SCHEDULES_ALL APS ,   
    AR_CASH_RECEIPTS_ALL RCTA  					 -- Added by 502754644
		,AR_CASH_RECEIPT_HISTORY_ALL HIST			 -- Added by 502754644
WHERE CUST.party_id = CA.party_id
AND CUST.PARTY_ID = S.PARTY_ID
AND S.PARTY_SITE_ID = CS.PARTY_SITE_ID    
AND CUST.PARTY_ID = CA.PARTY_ID
AND CS.CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID
AND S.LOCATION_ID = ADDR.LOCATION_ID
AND CS.CUST_ACCT_SITE_ID = U.CUST_ACCT_SITE_ID
AND U.set_id = CS.set_id
AND U.SITE_USE_CODE = 'BILL_TO'
--AND CA.customer_type = 'R' REL-045 Commented Line
--REL-045 Added below code
AND (CA.CUSTOMER_TYPE = 'R' 
						OR (ca.cust_account_id IN (SELECT lookup_code 
                                                     FROM FND_LOOKUP_VALUES 
                                                    WHERE lookup_type='CIRRUSGSAR_GECARS_CUS_INV'
                                                      AND language='US'
                                                      AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                      AND enabled_flag = 'Y' ) 
							AND rcta.org_id IN (SELECT bu_id 
												 FROM FUN_ALL_BUSINESS_UNITS_V 
												WHERE bu_name IN(SELECT meaning 
																   FROM fnd_lookup_values
                                                                  WHERE lookup_type = 'GED_BU_NAMES' 
                                                                    AND LANGUAGE ='US' 
                                                                    AND description = 'GRID_SWS'
                                                                    AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, TRUNC (SYSDATE)) AND NVL (end_date_active, TRUNC (SYSDATE))
                                                                    AND enabled_flag = 'Y'))
							)						  
	)	
--REL-045 Added above code
AND ADDR.country NOT IN ('IR','SD','SY','KP')
AND CS.status ='A'
AND ADDR.status_flag ='A'
AND CA.status='A'
and U.PRIMARY_FLAG = 'Y'
AND CA.CUST_ACCOUNT_ID = RCTA.PAY_FROM_CUSTOMER
AND RCTA.org_id = FABU.bu_id
AND APS.ACCTD_AMOUNT_DUE_REMAINING <> 0
AND APS.STATUS          = 'OP'
AND NOT EXISTS --- added by OMP
(
select 1
from
AR_REF_ACCOUNTS_ALL ARAA
where 1 = 1
and ARAA.source_ref_table = 'HZ_CUST_SITE_USES_ALL'
AND ARAA.SOURCE_REF_ACCOUNT_ID = u.SITE_USE_ID
AND ARAA.BU_ID = FABU.bu_id
)
AND EXISTS (select 'Y'
           from fnd_flex_value_sets  fvs,
                fnd_flex_values      fvv
           where   fvv.flex_value_set_id        = fvs.flex_value_set_id
            AND  fvs.flex_value_set_name      = 'CCL_COMPANY_CODES'
            and  fvv.attribute8  is not null
            and  fvv.ATTRIBUTE7 is not null
            and  fvv.ATTRIBUTE2 is not null
            and  fvv.ATTRIBUTE1 = 'Y'
            AND  fvv.ATTRIBUTE8 = 'L'  --REL-007 Added by Shankar to fetch only Lite customers
           and TO_NUMBER(fvv.ATTRIBUTE9) = FABU.bu_id)
AND APS.CASH_RECEIPT_ID   = RCTA.CASH_RECEIPT_ID   -- Added by 502754644
AND APS.ORG_ID            = RCTA.ORG_ID            -- Added by 502754644
AND HIST.CASH_RECEIPT_ID  = RCTA.CASH_RECEIPT_ID   -- Added by 502754644
AND HIST.ORG_ID           = RCTA.ORG_ID            -- Added by 502754644
AND RCTA.PAY_FROM_CUSTOMER = CA.CUST_ACCOUNT_ID    -- Added by 502754644
AND FABU.bu_id                 = rcta.org_id       -- Added by 502754644
AND HIST.CURRENT_RECORD_FLAG = 'Y'				  -- Added by 502754644
--- Added above code for REL-055 GEINC9884828 / GERITM24320967
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
null TranslatedCustName    
FROM sys.dual
ORDER BY BusinessCustomerNumber