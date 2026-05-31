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



SELECT  SUM(b.converted_net_amt1)
, SUM(b.vat_amt1)
FROM
(
SELECT DISTINCT a.transaction_currency1
, a.vat_rate1
, a.converted_net_amt1
, a.vat_amt1
FROM
(
SELECT DISTINCT
acra.currency_code AS transaction_currency1

--------------AMOUNT BEFORE VAT(Foreign Curr)----------

,(SELECT DISTINCT zlv.tax_rate FROM ZX_LINES_V zlv where zlv.trx_id = rcta.customer_trx_id)AS vat_rate1


-----------AMOUNT BEFORE VAT (THB) ----------

,
(
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

AS converted_net_amt1

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
END) AS vat_amt1 

----------------------------------------------------


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
acra.currency_code AS transaction_currency1

--------------AMOUNT BEFORE VAT(Foreign Curr)----------

 
,(SELECT DISTINCT zlv.tax_rate FROM ZX_LINES_V zlv where zlv.trx_id = rcta.customer_trx_id)AS vat_rate1


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
END) AS converted_net_amt1

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
END) AS vat_amt1 

----------------------------------------------------



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
 AND ((SELECT TRUNC(ract2.trx_date)
FROM RA_CUSTOMER_TRX_ALL ract2
WHERE ract2.previous_customer_trx_id =rcta.customer_trx_id) >= TRUNC(acra.receipt_date))
)a 
WHERE a.vat_rate1 ='0'
)b