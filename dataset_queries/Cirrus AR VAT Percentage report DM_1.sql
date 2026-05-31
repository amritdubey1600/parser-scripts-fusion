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
FROM HZ_PARTIES hzp
,HZ_PARTY_SITES hps
,HZ_CUST_ACCOUNTS hca
,HZ_CUST_SITE_USES_ALL hcsu
,HZ_CUST_ACCT_SITES_ALL hcas
,HZ_LOCATIONS hl
WHERE 1=1
AND hZp.party_id = hps.party_id
AND hps.party_site_id = hcas.party_site_id
AND hca.cust_account_id = hcas.cust_account_id
AND hzp.party_id = hca.party_id
AND hcsu.cust_acct_site_id = hcas.cust_acct_site_id
AND hps.location_id = hl.location_id(+)
AND hcsu.site_use_code = 'BILL_TO')
SELECT DISTINCT ROWNUM AS Seq_num, b.*
FROM
(
SELECT DISTINCT a.tax_date
,a.tax_invoice_number
,a.invoice_date
,a.invoice_number
,a.exchange_rate
,a.customer
,a.customer_vat
,a.head_office
,a.branch_no
,a.transaction_currency
,a.net_amount
,a.bot_rate
,a.vat_rate
,a.converted_net_amt
,DECODE(a.transaction_currency,'THB',a.vat_amt,ROUND(((a.converted_net_amt*a.vat_rate)/100),2)) AS vat_amt
,a.le_name
,a.sender_address
,a.vat_reg_no
FROM
(
SELECT DISTINCT

TO_CHAR(acra.receipt_date,'DD/MM/YY') AS tax_date
,TO_CHAR(acra.doc_sequence_value) AS tax_invoice_number
,TO_CHAR(rcta.trx_date,'DD/MM/YY') AS invoice_date
,TO_CHAR(rcta.trx_number) AS invoice_number
,rcta.exchange_rate 

,bill_to.party_name AS customer
,NVL(
(SELECT rep_registration_number
FROM ZX_PARTY_TAX_PROFILE
WHERE party_id = bill_to.party_site_id
AND party_type_code = 'THIRD_PARTY_SITE'),
(SELECT rep_registration_number
FROM ZX_PARTY_TAX_PROFILE
WHERE party_id = bill_to.party_id
AND party_type_code = 'THIRD_PARTY')) AS customer_vat
,(CASE 
WHEN (NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')) = 'Branch No:00000'
THEN
NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')
ELSE
NULL
END) AS head_office
,(CASE 
WHEN (NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')) != 'Branch No:00000'
THEN
NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')
ELSE
NULL
END) AS branch_no 
,acra.currency_code AS transaction_currency

--------------AMOUNT BEFORE VAT(Foreign Curr)----------
,(CASE
WHEN acra.currency_code != 'THB'
THEN(SELECT ROUND(SUM(rctla.quantity_invoiced * rctla.unit_selling_price),2)
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE rcta.customer_trx_id = rctla.customer_trx_id)
ELSE 
NULL 
END) AS net_amount
----------------
,NVL((CASE
WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE =(SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END),0) AS bot_rate
,(SELECT DISTINCT zlv.tax_rate FROM ZX_LINES_V zlv where zlv.trx_id = rcta.customer_trx_id)AS vat_rate


-----------AMOUNT BEFORE VAT (THB) ----------


,(
CASE WHEN acra.currency_code ='THB'
THEN

CASE WHEN ((SELECT TRUNC(ract2.trx_date)
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) < TRUNC(acra.receipt_date))
THEN 
(
(   
SELECT ROUND(SUM(amount),2)
FROM
(  SELECT  
(
 CASE
WHEN (rctla.quantity_invoiced IS NOT NULL AND rctla.unit_selling_price IS NOT NULL)
THEN
NVL((rctla.quantity_invoiced * rctla.unit_selling_price),0)
ELSE
NVL(rctla.Extended_amount,0)
END
)  amount
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE rcta.customer_trx_id = rctla.customer_trx_id
AND rctla.line_type='LINE'
) )+

(SELECT NVL(SUM(Extended_amount),0)

FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE 1=1
AND rctla.line_type='LINE'
AND rctla.customer_trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) )
)

ELSE
(   
SELECT ROUND(SUM(amount),2)
FROM
(  SELECT  
(
 CASE
WHEN (rctla.quantity_invoiced IS NOT NULL AND rctla.unit_selling_price IS NOT NULL)
THEN
NVL((rctla.quantity_invoiced * rctla.unit_selling_price),0)
ELSE
NVL(rctla.Extended_amount,0)
END
)  amount
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE rcta.customer_trx_id = rctla.customer_trx_id
AND rctla.line_type='LINE'
) )
END

WHEN acra.currency_code !='THB'
THEN

CASE WHEN ((SELECT TRUNC(ract2.trx_date)
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) < TRUNC(acra.receipt_date))
THEN  
(
ROUND(
(
(   SELECT SUM(amount) FROM
(SELECT              
(
CASE
WHEN (rctla.quantity_invoiced IS NOT NULL AND rctla.unit_selling_price IS NOT NULL)
THEN
NVL((rctla.quantity_invoiced * rctla.unit_selling_price),0)
ELSE
NVL(rctla.extended_amount,0)
END
)  amount
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
 WHERE rcta.customer_trx_id = rctla.customer_trx_id
 AND rctla.line_type='LINE'
 )  )
 *
NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE  =(SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END),1 ) ),2) +
ROUND(((SELECT NVL(SUM(Extended_amount),0) 

FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE rctla.line_type='LINE'
AND rctla.customer_trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id))*
NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE  =(SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END),1)),2)
)
ELSE

ROUND(
(
(   SELECT SUM(amount) FROM
(SELECT              
(
CASE
WHEN (rctla.quantity_invoiced IS NOT NULL AND rctla.unit_selling_price IS NOT NULL)
THEN
NVL((rctla.quantity_invoiced * rctla.unit_selling_price),0)
ELSE
NVL(rctla.extended_amount,0)
END
)  amount
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
 WHERE rcta.customer_trx_id = rctla.customer_trx_id
 AND rctla.line_type='LINE'
 )  )
 *
NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE  =(SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END),1 ) ),2)

END

ELSE NULL
END
) 

AS converted_net_amt

---------vat_amount---------

,(CASE WHEN acra.currency_code = 'THB'
THEN

CASE WHEN ((SELECT TRUNC(ract2.trx_date)
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) < TRUNC(acra.receipt_date))
THEN

(
(SELECT ROUND(NVL(SUM(zlv.tax_amt),0),2)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = rcta.customer_trx_id) +
(SELECT ROUND(NVL(SUM(zlv.tax_amt),0),2)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id))
)

ELSE

(SELECT ROUND(NVL(SUM(zlv.tax_amt),0),2)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = rcta.customer_trx_id)

END

WHEN acra.currency_code != 'THB'
THEN

CASE WHEN ((SELECT TRUNC(ract2.trx_date)
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) < TRUNC(acra.receipt_date))
THEN

(
ROUND(((SELECT NVL(SUM(zlv.tax_amt),0)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = rcta.customer_trx_id)
*NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE = (SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END
),1)),2) +
ROUND(((SELECT NVL(SUM(zlv.tax_amt),0)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id))
*NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE = (SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END
),1)),2)
)

ELSE

ROUND(((SELECT NVL(SUM(zlv.tax_amt),0)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = rcta.customer_trx_id)
*NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE = (SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END
),1)),2)

END

 ELSE NULL
END) AS vat_amt 

----------------------------------------------------

,(SELECT description
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
AND meaning = 'LE_NAME_' || hou.name
AND enabled_flag = 'Y'
AND ROWNUM = 1
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))AND NVL (end_date_active,TRUNC (SYSDATE))) AS le_name
,(SELECT REPLACE (description, '~', CHR (13))
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'XXAR_INV_CONTACT'
AND lookup_code = 'SUPPLIER_ADDRESS_' || hou.name
AND enabled_flag = 'Y'
 AND ROWNUM = 1
 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))AND NVL (end_date_active,TRUNC (SYSDATE))) AS sender_address,
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
 FROM RA_CUSTOMER_TRX_ALL rcta,
	  AR_RECEIVABLE_APPLICATIONS_ALL ara,
	  AR_CASH_RECEIPTS_ALL acra,
	  HR_ORGANIZATION_UNITS hou,
	  BILL_TO,
	  XLE_FIRSTPARTY_INFORMATION_V xle
WHERE 1=1
AND ara.applied_customer_trx_id = rcta.customer_trx_id
AND ara.cash_receipt_id = acra.cash_receipt_id
AND ara.status ='APP' --'REV'
AND ara.gl_posted_date IS NOT NULL
AND ara.display = 'Y'
AND rcta.bill_to_customer_id = bill_to.cust_account_id
AND rcta.bill_to_site_use_id = bill_to.site_use_id
AND hou.organization_id = rcta.org_id

AND xle.legal_entity_id = rcta.legal_entity_id
AND hou.name = NVL(:bu_name,hou.name) --'TH_CR_DG88_BU'
 AND acra.receipt_date  BETWEEN NVL(:p_start_date,acra.receipt_date) AND NVL(:p_end_date,acra.receipt_date)
--AND rcta.trx_number IN ( '88001100000006','88001100000005')


UNION ALL

SELECT DISTINCT

(SELECT TO_CHAR(ract2.trx_date,'DD/MM/YY')
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) AS tax_date

,
(SELECT ract2.trx_number
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) AS TAX_INVOICE_NUMBER
,TO_CHAR(rcta.trx_date,'DD/MM/YY') AS invoice_date
,TO_CHAR(rcta.trx_number) AS invoice_number
,rcta.exchange_rate

,bill_to.party_name AS customer
,NVL(
(SELECT rep_registration_number
FROM ZX_PARTY_TAX_PROFILE
WHERE party_id = bill_to.party_site_id
AND party_type_code = 'THIRD_PARTY_SITE'),
(SELECT rep_registration_number
FROM ZX_PARTY_TAX_PROFILE
 WHERE party_id = bill_to.party_id
 AND party_type_code = 'THIRD_PARTY')) AS customer_vat
,(CASE 
WHEN (NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')) = 'Branch No:00000'
THEN
NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')
ELSE
NULL
END) AS head_office
,(CASE 
WHEN (NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')) != 'Branch No:00000'
THEN
NVL((SELECT SUBSTR(bill_to.address3,(SELECT INSTR(bill_to.address3,'Branch',1,1)FROM DUAL),(SELECT LENGTH (bill_to.address3) FROM DUAL)) FROM DUAL),'')
ELSE
NULL
END) AS branch_no 
,acra.currency_code AS transaction_currency

--------------AMOUNT BEFORE VAT(Foreign Curr)----------

 ,(CASE
WHEN acra.currency_code != 'THB'
THEN(SELECT ROUND(SUM(rctla.quantity_invoiced * rctla.unit_selling_price),2)
FROM RA_CUSTOMER_TRX_LINES_ALL rctla
 WHERE rcta.customer_trx_id = rctla.customer_trx_id)
ELSE 
NULL 
END) AS net_amount

----------------
,NVL((CASE
WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE =(SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END),0) AS bot_rate
,(SELECT DISTINCT zlv.tax_rate FROM ZX_LINES_V zlv where zlv.trx_id = rcta.customer_trx_id)AS vat_rate


-----------AMOUNT BEFORE VAT (THB) ----------



,(CASE WHEN acra.currency_code ='THB'
THEN
(SELECT ROUND(NVL(SUM(Extended_amount),0),2)

FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE 1=1
AND rctla.line_type='LINE'
AND rctla.customer_trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) )
WHEN acra.currency_code !='THB'
THEN
ROUND(((SELECT NVL(SUM(Extended_amount),0) 

FROM RA_CUSTOMER_TRX_LINES_ALL rctla
WHERE rctla.line_type='LINE'
AND rctla.customer_trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id))*
NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE  =(SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END),1)),2)
ELSE NULL
END) AS converted_net_amt

---------vat_amount---------



 

,(CASE WHEN acra.currency_code = 'THB'
THEN
(SELECT ROUND(NVL(SUM(zlv.tax_amt),0),2)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id))
WHEN acra.currency_code != 'THB'
THEN
ROUND(((SELECT NVL(SUM(zlv.tax_amt),0)
FROM ZX_LINES_V zlv
WHERE zlv.trx_id = (SELECT ract2.customer_trx_id FROM RA_CUSTOMER_TRX_ALL ract2 WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id))
*NVL((CASE WHEN acra.currency_code != 'THB'
THEN (SELECT gld.conversion_Rate
FROM GL_DAILY_RATES gld
WHERE TRUNC(gld.conversion_date) = TRUNC(acra.receipt_date)
AND gld.CONVERSION_TYPE = (SELECT meaning
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'CIRRUSAR_INVPRINT_DAILYRATE'
AND lookup_code = hou.name
AND enabled_flag = 'Y'
AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
AND NVL (end_date_active,TRUNC (SYSDATE)))
AND gld.from_currency = acra.currency_code
AND gld.to_currency = 'THB')
ELSE acra.exchange_rate
END
),1)),2)
ELSE NULL
END) AS vat_amt 

----------------------------------------------------

,(SELECT description
 FROM FND_LOOKUP_VALUES_VL
 WHERE lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
 AND meaning = 'LE_NAME_' || hou.name
 AND enabled_flag = 'Y'
 AND ROWNUM = 1
 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))AND NVL (end_date_active,TRUNC (SYSDATE))) AS le_name
,(SELECT REPLACE (description, '~', CHR (13))
FROM FND_LOOKUP_VALUES_VL
WHERE lookup_type = 'XXAR_INV_CONTACT'
AND lookup_code = 'SUPPLIER_ADDRESS_' || hou.name
 AND enabled_flag = 'Y'
AND ROWNUM = 1
 AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))AND NVL (end_date_active,TRUNC (SYSDATE))) AS sender_address,
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

FROM RA_CUSTOMER_TRX_ALL rcta,
	 AR_RECEIVABLE_APPLICATIONS_ALL ara,
	 AR_CASH_RECEIPTS_ALL acra,
	 HR_ORGANIZATION_UNITS hou,
	 BILL_TO,
	 XLE_FIRSTPARTY_INFORMATION_V xle
WHERE 1=1
AND ara.applied_customer_trx_id = rcta.customer_trx_id
AND ara.cash_receipt_id = acra.cash_receipt_id
AND ara.status ='APP' --'REV'
AND ara.gl_posted_date IS NOT NULL
AND ara.display = 'Y'
AND rcta.bill_to_customer_id = bill_to.cust_account_id
AND rcta.bill_to_site_use_id = bill_to.site_use_id
AND hou.organization_id = rcta.org_id
AND xle.legal_entity_id = rcta.legal_entity_id
AND hou.name = NVL(:bu_name,hou.name)--'TH_CR_DG88_BU'
AND acra.receipt_date  BETWEEN NVL(:p_start_date,acra.receipt_date) AND NVL(:p_end_date,acra.receipt_date)
--AND rcta.trx_number IN ( '88001100000006','88001100000005')
 AND ((SELECT TRUNC(ract2.trx_date)
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) >= TRUNC(acra.receipt_date))
)a 
WHERE a.vat_rate ='7'
ORDER BY TO_DATE(a.tax_date,'DD/MM/YY'), a.tax_invoice_number)b
ORDER BY ROWNUM