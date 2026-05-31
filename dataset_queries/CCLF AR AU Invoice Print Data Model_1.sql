/*--#-----------------------------------------------------------------------------------------------------------------#
--# CCLF AR Invoice Print Singapore Data Model
--# DESCRIPTION  : This data model query used for Singapore Invoice Print 
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author             Date                 Description
--# REL-030             Karun              25-JUN-2019          Modifications as per GEFCERPITC-I-210
--# REL-041             Sindhura Puppala   21-MAY-2020          Added Reason Code for Credit Note
--# REL-082             Pocharam Manoj Kumar   13-OCT-2023          Added GEII LE NAME CHANGE
--# ---------------------------------------------------------------------------------------------------------------------
*/

SELECT rct.trx_number trx_number ,
  bu.bu_name ,
  rct.term_id ,
  rct.customer_trx_id ,
  rct.purchase_order ,
  rct.SPECIAL_INSTRUCTIONS ,
  rct.remit_to_address_seq_id ,
  (SELECT zp.rep_registration_number
  FROM ZX_PARTY_TAX_PROFILE zp
  WHERE zp.party_id =hps.party_site_id
  AND rownum       <= 1
  ) bill_cust_tax_reg_no ,
  xep.LEGAL_ENTITY_IDENTIFIER LE_IDENTIFIER ,
  rct.remit_to_address_id ,
  rct.trx_class ,
  TO_CHAR(rct.trx_date ,'mm/dd/yyyy') Invoice_date ,
  TO_CHAR(rct.ship_date_actual,'mm/dd/yyyy') date_shipped ,
  TO_CHAR(rct.purchase_order_date,'mm/dd/yyyy') purchase_order_date ,
  rct.printing_original_date original_date ,
  (SELECT COUNT(1)
  FROM ra_customer_trx_lines_all
  WHERE line_type     = 'TAX'
  AND customer_trx_id = rct.customer_trx_id
  ) tax_cnt ,
  rct.ct_reference sales_order ,
  rct.exchange_rate conversion_rate ,
  hca.account_number ,
  CASE
    WHEN rcta.attribute1 = 'Y'
    THEN SUBSTR(rcta.name,1,6)
    ELSE ''
  END from_BUC ,
  CASE
    WHEN rcta.attribute1 = 'Y'
    THEN SUBSTR(hps1.party_site_name,1,6)
    ELSE ''
  END to_BUC ,
  TO_CHAR(aps.due_date,'mm/dd/yyyy') due_date ,
  (SELECT LISTAGG (trim(a2.description), ',') WITHIN GROUP (
  ORDER BY a2.tax_rate)
  FROM
    (SELECT DISTINCT REPLACE(trim(b.description),CHR(10),'') description,
      a.tax_rate,
      a.trx_id
    FROM zx_lines_v a,
      zx_rates_vl b
    WHERE a.tax_rate_id = b.tax_rate_id
    ) a2
  WHERE a2.trx_id = rct.customer_trx_id
  ) applied_taxes ,
  aps.amount_due_original oc_inv_amount ,
  TO_CHAR(aps.amount_due_original,fnd_currency.get_format_mask(rct.invoice_currency_code,40)) oc_inv_amount_f ,
  aps.tax_original oc_tax_amount ,
  TO_CHAR(aps.tax_original,fnd_currency.get_format_mask(rct.invoice_currency_code,40)) oc_tax_amount_f ,
  CASE
    WHEN rct.invoice_currency_code<>gl.currency_code
    THEN TRUNC((NVL(aps.amount_due_original, 0) * NVL(TRUNC(rct.exchange_rate,6), 1)),fc.precision)
    ELSE aps.amount_due_original
  END fc_inv_amount_c ,
  (SELECT SUM(ACCTD_AMOUNT)
  FROM RA_CUST_TRX_LINE_GL_DIST_ALL a2
  WHERE a2.customer_trx_id = rct.customer_trx_id
  AND a2.account_class     = 'REC'
  AND a2.account_set_flag  = 'N'
  ) fc_inv_amount ,
  CASE
    WHEN rct.invoice_currency_code<>gl.currency_code
    THEN TO_CHAR(ROUND((NVL(aps.amount_due_original, 0) * NVL(rct.exchange_rate, 1)),fc.precision) ,fnd_currency.get_format_mask(rct.invoice_currency_code,40))
    ELSE TO_CHAR(aps.amount_due_original,fnd_currency.get_format_mask(rct.invoice_currency_code,40))
  END fc_inv_amount_f ,
  CASE
    WHEN rct.invoice_currency_code<>gl.currency_code
    THEN ROUND((NVL(aps.tax_original, 0) * NVL(rct.exchange_rate, 1)),fc.precision)
    ELSE aps.tax_original
  END fc_tax_amount ,
  aps.amount_line_items_original oc_revenue_amount ,
  CASE
    WHEN rct.invoice_currency_code<>gl.currency_code
    THEN ROUND((NVL(aps.amount_line_items_original, 0) * NVL(rct.exchange_rate, 1)),fc.precision)
    ELSE aps.amount_line_items_original
  END fc_revenue_amount ,
  -- xep.name legal_entity , commented for REL-082 GE II LE Name Change
NVL((select flv.Description -- Added for REL-082 GE II LE Name Change Start
from 
xle_entity_profiles xep1,
ra_customer_trx_all rct1,
fnd_lookup_values flv
where rct.legal_entity_id = xep.legal_entity_id
and rct1.legal_entity_id =xep1.legal_entity_id
AND xep.legal_entity_id= xep1.legal_entity_id
and flv.LOOKUP_CODE=xep1.LEGAL_ENTITY_IDENTIFIER
and flv.lookup_type='GE_II_LE_NAME_MAPPING_NEW'
AND rct1.legal_entity_id=:p_legal_entity
AND rct1.org_id=:p_business_unit
and flv.language='US'
and trunc(rct.trx_date)< trunc(flv.START_DATE_ACTIVE)
UNION
select xep1.name
from 
xle_entity_profiles xep1,
ra_customer_trx_all rct1,
fnd_lookup_values flv
where rct.legal_entity_id = xep.legal_entity_id
and rct1.legal_entity_id =xep1.legal_entity_id
AND xep.legal_entity_id= xep1.legal_entity_id
and flv.LOOKUP_CODE=xep1.LEGAL_ENTITY_IDENTIFIER
and flv.lookup_type='GE_II_LE_NAME_MAPPING_NEW'
AND rct1.legal_entity_id=:p_legal_entity
AND rct1.org_id=:p_business_unit
and flv.language='US'
and trunc(rct.trx_date)>= trunc(flv.START_DATE_ACTIVE)),xep.name) legal_entity,-- Added for REL-082 GE II LE Name Change End
  (SELECT a1.registration_number
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_REGN_NO ,
  (SELECT a1.address_line_1
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_ADD1 ,
  (SELECT a1.address_line_2
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_ADD2 ,
  (SELECT a1.address_line_3
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_ADD3 ,
  (SELECT a1.town_or_city
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_CITY ,
  (SELECT a1.REGION_2
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_STATE --Added by Shankar 07-Oct-16 for enhancement for AU business
  ,
  (SELECT a1.postal_code
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_POSTAL_CODE ,
  (SELECT DISTINCT c1.territory_short_name
  FROM XLE_REGISTRATIONS_V a1 ,
    FND_TERRITORIES_TL c1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  AND a1.country           = c1.territory_code
  AND language             = 'US'
  ) LE_COUNTRY ,
  rt.name term_name ,
  rct.ship_via ,
  hp.party_name bill_to_customer ,
  hl.address1 bill_to_add1 ,
  hl.address2 bill_to_add2 ,
  hl.address3 bill_to_add3 ,
  hl.address4 bill_to_add4 ,
  hl.city bill_to_city ,
  hl.postal_code bill_postal_code ,
  hl.state bill_to_state ,
  hl.province bill_to_province ,
  hl.county bill_to_county ,
  (SELECT DISTINCT territory_short_name
  FROM FND_TERRITORIES_VL
  WHERE territory_code=hl.country
  ) bill_to_country ,
  hp1.party_name ship_to_customer ,
  hl1.address1 ship_to_add1 ,
  hl1.address2 ship_to_add2 ,
  hl1.address3 ship_to_add3 ,
  hl1.city ship_to_city ,
  hl1.postal_code ship_postal_code ,
  hl1.state ship_to_state ,
  hl1.province ship_to_province ,
  hl1.county ship_to_county ,
  (SELECT DISTINCT a.territory_short_name
  FROM FND_TERRITORIES_VL a
  WHERE a.territory_code=hl1.country
  ) ship_to_country ,
  hz_format_pub.format_address(hl.location_id,NULL,NULL,CHR(13)) bill_format_add ,
  hz_format_pub.format_address(hl1.location_id,NULL,NULL,CHR(13)) ship_format_add ,
  rct.invoice_currency_code ,
  (SELECT wnd.delivery_id
  FROM doo_headers_all ooh ,
    doo_lines_all ool ,
    wsh_delivery_Details wdd ,
    wsh_new_deliveries wnd ,
    wsh_delivery_assignments wda
  WHERE 1                        =1
  AND wdd.source_header_id       = ooh.header_id
  AND ooh.header_id              = ool.header_id
  AND wdd.source_line_id         = ool.line_id
  AND wda.delivery_detail_id     = wdd.delivery_detail_id
  AND wda.delivery_id            = wnd.delivery_id
  AND TO_CHAR (ooh.order_number) = rct.interface_header_attribute1
  AND ooh.org_id                 = rct.org_id
  AND rownum                    <=1
  ) delivery_number ,
  (SELECT wnd.DELIVERED_DATE
  FROM doo_headers_all ooh ,
    doo_lines_all ool ,
    wsh_delivery_Details wdd ,
    wsh_new_deliveries wnd ,
    wsh_delivery_assignments wda
  WHERE 1                        =1
  AND wdd.source_header_id       = ooh.header_id
  AND ooh.header_id              = ool.header_id
  AND wdd.source_line_id         = ool.line_id
  AND wda.delivery_detail_id     = wdd.delivery_detail_id
  AND wda.delivery_id            = wnd.delivery_id
  AND TO_CHAR (ooh.order_number) = rct.interface_header_attribute1
  AND ooh.org_id                 = rct.org_id
  AND rownum                    <=1
  ) DELIVERED_DATE ,
  (SELECT wnd.FREIGHT_TERMS_CODE
  FROM doo_headers_all ooh ,
    doo_lines_all ool ,
    wsh_delivery_Details wdd ,
    wsh_new_deliveries wnd ,
    wsh_delivery_assignments wda
  WHERE 1                        =1
  AND wdd.source_header_id       = ooh.header_id
  AND ooh.header_id              = ool.header_id
  AND wdd.source_line_id         = ool.line_id
  AND wda.delivery_detail_id     = wdd.delivery_detail_id
  AND wda.delivery_id            = wnd.delivery_id
  AND TO_CHAR (ooh.order_number) = rct.interface_header_attribute1
  AND ooh.org_id                 = rct.org_id
  AND rownum                    <=1
  ) DELIVERY_terms ,
  (SELECT hl2.address1
    ||' '
    ||hl2.address2
    ||' '
    ||hl2.city
    ||' '
    ||hl2.province
    ||' '
    ||hl2.postal_code
    ||' '
    ||
    (SELECT DISTINCT a.territory_short_name
    FROM FND_TERRITORIES_VL a
    WHERE a.territory_code=hl2.country
    )
  FROM ar_remit_to_locs_all art,
    hz_locations hl2
  WHERE rct.remit_to_address_seq_id=art.address_loc_seq_id
  AND art.location_id              =hl2.location_id
  AND rownum                       =1
  ) Remit_to ,
  (SELECT exempt_certificate_number
  FROM zx_exemptions a,
    zx_party_tax_profile b,
    hz_parties c
  WHERE a.PARTY_TAX_PROFILE_ID   =b.PARTY_TAX_PROFILE_ID
  AND c.party_id                 =b.party_id
  AND rownum                     =1
  AND rct.user_defined_fisc_class='NOPST'
  ) certificate_num ,
  (SELECT segment1
  FROM ra_cust_trx_line_gl_dist_all a,
    gl_code_combinations b
  WHERE a.code_combination_id=b.code_combination_id
  AND a.account_class        ='REC'
  AND a.customer_trx_id      =rct.customer_trx_id
  AND rownum                 = 1
  ) segment1 ,
  gl.currency_code functional_currency_code ,
  (SELECT LISTAGG (b1.trx_number, ',') WITHIN GROUP (
  ORDER BY a1.apply_date)
  FROM AR_RECEIVABLE_APPLICATIONS_ALL a1,
    RA_CUSTOMER_TRX_ALL b1
  WHERE a1.applied_customer_trx_id = b1.customer_trx_id
  AND a1.org_id                    = b1.org_id
  AND a1.display                   ='Y'
  AND a1.customer_trx_id           = rct.customer_trx_id
   and rownum <=100 -- Case #17297798
  ) original_inv_num ,
  (SELECT LISTAGG (TO_CHAR(b1.trx_date,'mm/dd/yyyy'), ',') WITHIN GROUP (
  ORDER BY a1.apply_date)
  FROM AR_RECEIVABLE_APPLICATIONS_ALL a1,
    RA_CUSTOMER_TRX_ALL b1
  WHERE a1.applied_customer_trx_id = b1.customer_trx_id
  AND a1.org_id                    = b1.org_id
  AND a1.display                   ='Y'
  AND a1.customer_trx_id           = rct.customer_trx_id
   and rownum <=100 -- Case #17297798
  ) original_inv_date ,
  (SELECT SUBSTR(e.address2, instr(e.address2,'PRM',1)+4, instr(e.address2,'~',1) -instr(e.address2,'PRM',1)-4)
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b ,
    ar_remit_to_locs_all d,
    hz_locations e
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_REMIT_TO_ADDRESS'
  AND a.determinant_value    = rct.org_id
  AND d.set_id               = b.set_id
  AND e.location_id          = d.location_id
    --and d.ADDRESS_LOC_SEQ_ID = rct.REMIT_TO_ADDRESS_SEQ_ID
  AND SUBSTR(e.address1,1,6)= xep.LEGAL_ENTITY_IDENTIFIER
  AND e.address3            = bu.bu_name
  AND b.language            = userenv('LANG')
  AND rownum               <= 1
  ) local_curr_prm ,
  (SELECT SUBSTR(e.address2, instr(e.address2,'SEC',1)+4, instr(e.address2,'&&') -instr(e.address2,'SEC')-4 )
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b ,
    ar_remit_to_locs_all d,
    hz_locations e
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_REMIT_TO_ADDRESS'
  AND a.determinant_value    = rct.org_id
    --and d.ADDRESS_LOC_SEQ_ID = rct.REMIT_TO_ADDRESS_SEQ_ID
  AND d.set_id              = b.set_id
  AND e.location_id         = d.location_id
  AND SUBSTR(e.address1,1,6)= xep.LEGAL_ENTITY_IDENTIFIER
  AND e.address3            = bu.bu_name
  AND b.language            = userenv('LANG')
  AND rownum               <= 1
  ) local_curr_sec ,
  (SELECT SUBSTR(e.address2, instr(e.address2,'PRM',2,2)+4, instr(e.address2,'~',2,2) -(instr(e.address2,'PRM',2,2)+4) )
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b ,
    ar_remit_to_locs_all d,
    hz_locations e
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_REMIT_TO_ADDRESS'
  AND a.determinant_value    = rct.org_id
    --and d.ADDRESS_LOC_SEQ_ID = rct.REMIT_TO_ADDRESS_SEQ_ID
  AND d.set_id              = b.set_id
  AND e.location_id         = d.location_id
  AND SUBSTR(e.address1,1,6)= xep.LEGAL_ENTITY_IDENTIFIER
  AND e.address3            = bu.bu_name
  AND b.language            = userenv('LANG')
  AND rownum               <= 1
  ) fc_curr_prm ,
  (SELECT SUBSTR(e.address2, instr(e.address2,'SEC',2,2)+4, LENGTH(e.address2) )
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b ,
    ar_remit_to_locs_all d,
    hz_locations e
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_REMIT_TO_ADDRESS'
  AND a.determinant_value    = rct.org_id
    --and d.ADDRESS_LOC_SEQ_ID = rct.REMIT_TO_ADDRESS_SEQ_ID
  AND d.set_id              = b.set_id
  AND e.location_id         = d.location_id
  AND SUBSTR(e.address1,1,6)= xep.LEGAL_ENTITY_IDENTIFIER
  AND e.address3            = bu.bu_name
  AND b.language            = userenv('LANG')
  AND rownum               <= 1
  ) fc_curr_sec ,
  (SELECT SUBSTR(e.address2, instr(e.address2,'&&',1,1)+2 ,3 )
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b ,
    ar_remit_to_locs_all d,
    hz_locations e
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_REMIT_TO_ADDRESS'
  AND a.determinant_value    = rct.org_id
    --and d.ADDRESS_LOC_SEQ_ID = rct.REMIT_TO_ADDRESS_SEQ_ID
  AND d.set_id              = b.set_id
  AND e.location_id         = d.location_id
  AND SUBSTR(e.address1,1,6)= xep.LEGAL_ENTITY_IDENTIFIER
  AND e.address3            = bu.bu_name
  AND b.language            = userenv('LANG')
  AND rownum               <= 1
  ) fc_curr_code ,
  (SELECT SUBSTR(a1.address_line_3, 1, instr(a1.address_line_3,'~',1,1) -1 )
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_TEL ,
  (SELECT SUBSTR(a1.address_line_3, instr(a1.address_line_3,'~',1,1)+1, instr(a1.address_line_3,'~',2,2)-1 -instr(a1.address_line_3,'~',1,1) )
  FROM XLE_REGISTRATIONS_V a1
  WHERE a1.legal_entity_id = xep.legal_entity_id
  ) LE_FAX ,
  (SELECT c1.mailstop
  FROM XLE_REGISTRATIONS_V a1,
    hz_parties b1,
    hz_party_sites c1
  WHERE a1.party_id      = b1.party_id
  AND c1.party_id        = a1.party_id
  AND a1.legal_entity_id = xep.legal_entity_id
  AND rownum            <=1
  ) LE_MAIL ,
  (SELECT d.attribute1
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b,
    ra_batch_sources_all d
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_TRANSACTION_SOURCE'
  AND d.legal_entity_id      = xep.legal_entity_id
  AND a.set_id               = d.set_id
  AND SUBSTR(d.name,1,6)     = xep.legal_entity_identifier
  AND a.determinant_value    = rct.org_id
  AND d.attribute1          IS NOT NULL
  AND b.language             = userenv('LANG')
  AND rownum                <=1
  ) php_src_attribute1 ,
  (SELECT d.attribute2
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b,
    ra_batch_sources_all d
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_TRANSACTION_SOURCE'
  AND d.legal_entity_id      = xep.legal_entity_id
  AND a.set_id               = d.set_id
  AND SUBSTR(d.name,1,6)     = xep.legal_entity_identifier
  AND a.determinant_value    = rct.org_id
  AND d.attribute2          IS NOT NULL
  AND b.language             = userenv('LANG')
  AND rownum                <=1
  ) php_src_attribute2 ,
  (SELECT d.attribute3
  FROM fusion.fnd_setid_assignments a,
    fnd_setid_sets b,
    ra_batch_sources_all d
  WHERE a.set_id             = b.set_id
  AND a.reference_group_name = 'AR_TRANSACTION_SOURCE'
  AND d.legal_entity_id      = xep.legal_entity_id
  AND a.set_id               = d.set_id
  AND SUBSTR(d.name,1,6)     = xep.legal_entity_identifier
  AND a.determinant_value    = rct.org_id
  AND d.attribute3          IS NOT NULL
  AND b.language             = userenv('LANG')
  AND rownum                <=1
  ) php_src_attribute3,
-- REL-041 Added below code for Credit Note Reason By Sindhura Puppala
  rct.reason_code 
 -- REL-041 Added above code for Credit Note Reason By Sindhura Puppala
FROM ra_customer_trx_all rct ,
  ra_cust_trx_types_all rcta ,
  hr_all_organization_units ha ,
  xle_entity_profiles xep ,
  gl_ledgers gl ,
  hr_organization_information hoi ,
  ar_payment_schedules_all aps ,
  ra_terms_vl rt ,
  hz_parties hp ,
  hz_cust_accounts hca ,
  hz_party_sites hps ,
  hz_cust_acct_sites_all hcas ,
  hz_cust_site_uses_all hcau ,
  hz_locations hl ,
  hz_parties hp1 ,
  hz_party_sites hps1 ,
  hz_party_site_uses hpsu ,
  hz_locations hl1 ,
  fnd_currencies fc ,
  fun_all_business_units_v bu
WHERE rct.cust_trx_type_seq_id      =rcta.cust_trx_type_seq_id
AND rct.legal_entity_id             =xep.legal_entity_id
AND aps.customer_trx_id             =rct.customer_trx_id
AND rct.org_id                      =ha.organization_id
AND rct.org_id                      = bu.bu_id
AND rt.term_id(+)                   =rct.term_id
AND hp.party_id                     =hps.party_id
AND hca.cust_account_id             =rct.bill_to_customer_id
AND hca.party_id                    =hp.party_id
AND hps.party_site_id               =hcas.party_site_id
AND hca.cust_account_id             = hcas.cust_account_id
AND hcas.cust_acct_site_id          = hcau.cust_acct_site_id
AND hcau.site_use_id                = rct.BILL_TO_SITE_USE_ID
AND hcau.site_use_code              = 'BILL_TO'
AND hps.location_id                 =hl.location_id
AND hpsu.site_use_type(+)           = 'SHIP_TO'
AND hpsu.party_site_use_id(+)       =rct.ship_to_party_site_use_id
AND hps1.party_site_id(+)           = hpsu.party_site_id
AND hps1.party_id                   =hp1.party_id(+)
AND hps1.location_id                =hl1.location_id(+)
AND hoi.org_information_context     = 'FUN_BUSINESS_UNIT'
AND hoi.organization_id             = rct.org_id
AND TO_NUMBER(hoi.org_information3) = gl.ledger_id
AND gl.currency_code                = fc.currency_code
AND rct.complete_flag               = 'Y'
AND rct.legal_entity_id             = :p_legal_entity
AND ha.organization_id              =NVL(:p_business_unit,ha.organization_id)
AND rct.trx_number BETWEEN NVL(:p_from_trx_number,rct.trx_number) AND NVL(NVL(:p_to_trx_number,:p_from_trx_number),rct.trx_number)
AND hca.account_number BETWEEN NVL(:p_from_account_number,hca.account_number) AND NVL(:p_to_account_number,hca.account_number)
ORDER BY rct.trx_number