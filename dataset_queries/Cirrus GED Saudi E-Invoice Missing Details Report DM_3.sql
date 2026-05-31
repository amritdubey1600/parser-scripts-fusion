Select distinct trx_number from ra_customer_trx_all
where org_id IN (SELECT fabu.bu_id
FROM FND_LOOKUP_VALUES flv,
Fun_all_business_units_v fabu
WHERE flv.lookup_type                    = 'GED_BU_NAMES'
AND LANGUAGE                             = 'US'
AND flv.enabled_flag                     = 'Y'
AND NVL(flv.start_date_active, SYSDATE) <= SYSDATE
AND NVL(flv.end_date_active, SYSDATE)   >= SYSDATE
AND flv.lookup_code                      = fabu.bu_name
---AND flv.description ='DIGAVN' REL-103 GERITM51450658
AND flv.description ='DIG' -- Added for REL-103 GERITM51450658
AND flv.tag = 'E-INVOICING')