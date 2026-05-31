--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-047   				  S Karthik  		09-Dec-2020  	Initial Version - AR VAT Details		--#                                                                                 

--#-----------------------------------------------------------------------------------------------------#


WITH bill_to AS
(SELECT 
hzp.party_name
,hca.account_number
,hca.customer_type
,hcsu.site_use_code
,hcsu.location
,hca.cust_account_id
,hcsu.site_use_id
,hl.address3
,hl.country
,hzp.party_id
,hps.party_site_id			
FROM HZ_PARTIES 		hzp
,HZ_PARTY_SITES 		hps
,HZ_CUST_ACCOUNTS 		hca
,HZ_CUST_SITE_USES_ALL 	hcsu
,HZ_CUST_ACCT_SITES_ALL hcas
,HZ_LOCATIONS 			hl
WHERE 1=1
AND hZp.party_id 			= hps.party_id
AND hps.party_site_id 		= hcas.party_site_id
AND hca.cust_account_id 	= hcas.cust_account_id
AND hzp.party_id 			= hca.party_id
AND hcsu.cust_acct_site_id 	= hcas.cust_acct_site_id
AND hps.location_id 		= hl.location_id(+)
AND hcsu.site_use_code 		= 'BILL_TO')

SELECT * FROM
(SELECT DISTINCT
(SELECT DISTINCT zlv.tax_rate FROM ZX_LINES_V zlv where zlv.trx_id = rcta.customer_trx_id)AS vat_rate_header
,(SELECT description
    FROM FND_LOOKUP_VALUES_VL
   WHERE lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
     AND meaning = 'LE_NAME_' || hou.name
     AND enabled_flag = 'Y'
     AND ROWNUM = 1
     AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))AND NVL (end_date_active,TRUNC (SYSDATE))) AS le_name
,/*(SELECT REPLACE (description, '~', CHR (13))
    FROM fnd_lookup_values_vl
   WHERE lookup_type = 'XXAR_INV_CONTACT'
     AND lookup_code = 'SUPPLIER_ADDRESS_' || hou.name
     AND enabled_flag = 'Y'
     AND ROWNUM = 1
     AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))AND NVL (end_date_active,TRUNC (SYSDATE)))*/
'No. 87/1, Capital Tower,  All Seasons Place, 9th Floor,  Wireless Road,Lumpini, Pathumwan,  Bangkok 10330, Thailand'	 AS sender_address,
NVL((SELECT description
             FROM FND_LOOKUP_VALUES_VL
            WHERE     lookup_type = 'XXAR_INV_CONTACT'
                  AND meaning = 'SUPPLIER_VAT_NUM_' || hou.name
                  AND enabled_flag = 'Y'
                  AND ROWNUM = 1
                  AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                   TRUNC (SYSDATE))
                                          AND NVL (end_date_active,
                                                   TRUNC (SYSDATE))),
          xle.registration_number) AS vat_reg_no
,DECODE(SUBSTR((TO_CHAR(:p_start_date,'MON')),1,2),'01','JAN','02','FEB','03','MAR','04','APR','05','MAY','06','JUN','07','JUL',
 '08','AUG','09','SEP','10','OCT','11','NOV','12','DEC') ||'-'||TO_CHAR(:p_start_date,'YY')	AS start_date
 
,DECODE(SUBSTR((TO_CHAR(:p_end_date,'MON')),1,2),'01','JAN','02','FEB','03','MAR','04','APR','05','MAY','06','JUN','07','JUL',
 '08','AUG','09','SEP','10','OCT','11','NOV','12','DEC') ||'-'||TO_CHAR(:p_end_date,'YY') AS end_date
	   
  FROM RA_CUSTOMER_TRX_ALL 				rcta,
	   AR_RECEIVABLE_APPLICATIONS_ALL 	ara,
	   AR_CASH_RECEIPTS_ALL				acra,
	   HR_ORGANIZATION_UNITS 			hou,
	   BILL_TO,
	   XLE_FIRSTPARTY_INFORMATION_V 	xle
 WHERE 1=1
   AND ara.applied_customer_trx_id		= rcta.customer_trx_id
   AND ara.cash_receipt_id				= acra.cash_receipt_id
   AND ara.status						='APP' --'REV'
   AND ara.gl_posted_date IS NOT NULL
   AND rcta.bill_to_customer_id			= bill_to.cust_account_id
   AND rcta.bill_to_site_use_id			= bill_to.site_use_id
   AND hou.organization_id 				= rcta.org_id
   AND xle.legal_entity_id 				= rcta.legal_entity_id
   AND hou.name 						= NVL(:bu_name,hou.name) --'TH_CR_DG88_BU'
   AND acra.receipt_date  BETWEEN NVL(:p_start_date,acra.receipt_date) AND NVL(:p_end_date,acra.receipt_date)
   ) WHERE vat_rate_header = '7'