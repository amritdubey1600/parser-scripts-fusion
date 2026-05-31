--# CR#                   Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-032        Siva Kumar Dandu      25-AUG-2019        Developed new report to extract payment data--#
--# 														recon extract from Fusion to DIVE Daily Load--# 
--#-----------------------------------------------------------------------------------------------------#

SELECT 1 AS "key",
       ipa.payment_instruction_id AS "instruction_id",
       CASE WHEN (ipa.payment_method_code = 'WIRE') 
	        THEN 'Y' 
			ELSE 'N' 
			END AS "urgent",
	   ipa.payment_reference_number AS "key2",
       NVL(TO_CHAR(ipa.payment_amount, 'fm999999999999.00'),0) AS "amount",
       ipa.payment_currency_code AS "currency",
       SUBSTR(TO_CHAR(ipa.payment_date,'YYYY-MM-DD'),1,10) AS "payment_date",
       ipa.ext_bank_name AS "credit_bank_name",
       ieba.country_code AS "credit_bank_country_name",
       ipa.ext_bank_account_name AS "credit_account_name",
       COUNT(ipa.payment_instruction_id) OVER (PARTITION BY ipa.payment_instruction_id) AS "source_line",
             ipa.payment_reference_number AS "reference_value1",
       'DOCNO'||'-'||(SELECT aca2.check_number 
	                    FROM AP_CHECKS_ALL aca2 
					   WHERE aca2.payment_id = ipa.payment_id ) AS "reference_value2",
       ipa.int_bank_account_alt_name AS "treasury_code",
       ipa.ext_branch_number AS "credit_bank_route_code",
       SUBSTR(TO_CHAR(ipa.void_date,'YYYY-MM-DD'),1,10) AS "voided_date",
       DECODE (ipa.void_date,NULL,'NO','Yes') AS "voided_flag",
       ipa.payee_country,
       ipa.ext_eft_swift_code,
       ipa.payment_method_code,
       ipa.payment_reference_number,
       ipa.paper_document_number,
       'Digital Fusion' AS source_system,
       'GED' AS business,
       ipa.creation_date AS "creation_date",
       ipa.last_update_date AS "last_update_date"
  FROM IBY_PAYMENTS_ALL          ipa,
       IBY_EXT_BANK_ACCOUNTS     ieba,
       IBY_PAY_INSTRUCTIONS_ALL  ipi
 WHERE ieba.ext_bank_account_id(+) = ipa.external_bank_account_id
   AND ipa.payment_instruction_id  = ipi.Payment_instruction_id
   AND ipi.creation_date >= (SYSDATE-2)
   AND (UPPER(ipa.payment_profile_sys_name) LIKE '%WEBCASH%' OR UPPER(ipa.payment_profile_sys_name) LIKE '%DOMESTIC%')
   AND ipa.payment_instruction_id IS NOT NULL
UNION
SELECT 
NULL "key",
NULL instruction_id,
NULL urgent,
NULL key2,
NULL amount,
NULL currency,
NULL payment_date,
NULL credit_bank_name,
NULL credit_bank_country_name,
NULL credit_account_name,
NULL source_line,
NULL reference_value1,
NULL reference_value2,
NULL treasury_code,
NULL credit_bank_route_code,
NULL voided_date,
NULL voided_flag,
NULL payee_country,
NULL ext_eft_swift_code,
NULL payment_method_code,
NULL payment_reference_number,
NULL paper_document_number,
NULL source_system,
NULL business,
NULL creation_date,
NULL last_update_date
FROM SYS.DUAL