--#------------------------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#------------------------------------------------------------------------------------------------------------------#
--# REL-30                  Nuri Chetia       27-JUN-2019       As per case GERITM3722364 added province and orgid to get OU details
--# REL-31                  Nuri Chetia       02-AUG-2019       As per case GERITM4535753 added transaction type name field
--#------------------------------------------------------------------------------------------------------------------#
SELECT  rct.trx_number trx_number,
             rct.org_id, --REL030  GERITM3722364 Added
             rct.term_id,
             rct.customer_trx_id ,
             rct.purchase_order,
             TO_CHAR(rct.trx_date ,'DD-MON-YYYY') Invoice_date,
             TO_CHAR(rct.ship_date_actual,'DD-MON-YYYY') date_shipped,
             TO_CHAR(rct.purchase_order_date,'DD-MON-YYYY') date_order,
             rct.fob_point fob,
             rct.WAYBILL_NUMBER shipping_ref,
             rct.printing_original_date original_date,
             hca.account_number,
             TO_CHAR(aps.due_date,'DD-MON-YYYY') due_date,
             xep.name legal_entity,
             (SELECT a2.address_line_1
                FROM XLE_REGISTRATIONS_V a2
               WHERE a2.legal_entity_id = xep.legal_entity_id) LE_ADD,
             (SELECT  a2.town_or_city
                        || ', '
                        || a2.region_1
                FROM XLE_REGISTRATIONS_V a2
               WHERE a2.legal_entity_id = xep.legal_entity_id) LE_CITY,
            (SELECT a2.postal_code
               FROM  XLE_REGISTRATIONS_V a2
              WHERE a2.legal_entity_id = xep.legal_entity_id) LE_CODE,
           (SELECT  b2.territory_short_name
               FROM XLE_REGISTRATIONS_V a2,
                    FND_TERRITORIES_VL b2
              WHERE a2.legal_entity_id = xep.legal_entity_id
                AND a2.country = b2.territory_code) LE_COUNTRY,  
        --REL030  GERITM3722364 Added below code
          (SELECT  b2.province
               FROM XLE_REGISTRATIONS_V a2,
                   HZ_LOCATIONS b2
              WHERE a2.legal_entity_id = xep.legal_entity_id
                AND a2.location_id = b2.location_id) le_province,  
           --REL030  GERITM3722364 Added above code
             rt.name term_name,
             rct.ship_via,
             hp.party_name bill_to_customer,
             hl.address1 bill_to_add,
             hl.address2 bill_to_add1,
             hl.city||','|| hl.province  bill_to_city,
             hl.postal_code bill_to_code,
             hz_format_pub.format_address(hl.location_id,null,null,CHR(13)) bill_format_add,
             hz_format_pub.format_address(hl1.location_id,null,null,CHR(13)) ship_format_add,
             (SELECT territory_short_name
                FROM  FND_TERRITORIES_VL 
               WHERE  territory_code=hl.country) bill_to_country,
             hp1.party_name ship_to_customer,
             hl1.address1 ship_to_add,
             hl1.address2 ship_to_add1,
             hl1.city||','|| hl1.province ship_to_city,
             hl1.postal_code ship_to_code,
             (SELECT  a.territory_short_name
                FROM  FND_TERRITORIES_VL a
               WHERE  a.territory_code=hl1.country) ship_to_country ,
             rct.invoice_currency_code,
             (SELECT  hl2.address1||' '||hl2.address2||' '||hl2.city||' '||hl2.province||' '||hl2.postal_code||' '||(SELECT a.territory_short_name
                                                                                                                       FROM FND_TERRITORIES_VL a
                                                                                                                      WHERE a.territory_code=hl2.country)
                FROM  ra_remit_tos_all rta,
                      ar_remit_to_locs_all art,
                      hz_locations hl2  
               WHERE  rct.remit_to_address_seq_id=rta.address_loc_seq_id
                 AND  rta.address_loc_seq_id=art.address_loc_seq_id
                 AND  art.location_id=hl2.location_id
                 AND  art.location_id = hl2.location_id(+) 
                 AND  rta.attribute1 like '%'||(SELECT segment1 
                                                  FROM ra_cust_trx_line_gl_dist_all a,
                                                       gl_code_combinations b
                                                 WHERE a.code_combination_id=b.code_combination_id
                                                   AND a.customer_trx_id=rct.customer_trx_id
                                                   AND rownum=1)||'%' )Remit_to,
              (SELECT hz_format_pub.format_address(hl2.location_id, null, null, ',')
                FROM  ra_remit_tos_all rta,
                      ar_remit_to_locs_all art,
                      hz_locations hl2  
               WHERE  rct.remit_to_address_seq_id=rta.address_loc_seq_id
                 AND  rta.address_loc_seq_id=art.address_loc_seq_id
                 AND  art.location_id=hl2.location_id
                 AND  art.location_id = hl2.location_id(+) 
                 AND  rta.attribute1 like '%'||(SELECT segment1 
                                                  FROM ra_cust_trx_line_gl_dist_all a,
                                                       gl_code_combinations b
                                                 WHERE a.code_combination_id=b.code_combination_id
                                                   AND a.customer_trx_id=rct.customer_trx_id
                                                   AND rownum=1)||'%' )Remit_to_format,												   
             (SELECT EXEMPT_CERTIFICATE_NUMBER
                FROM ZX_EXEMPTIONS ZE,
	                 ZX_PARTY_TAX_PROFILE ZP,
                     HZ_PARTY_SITES HP1,
                     HZ_PARTIES HPP1,
                     HZ_CUST_ACCOUNTS HCA1,
                     RA_CUSTOMER_TRX_ALL RCT1,
		             RA_CUSTOMER_TRX_LINES_ALL RCTL1
               WHERE ZE.PARTY_TAX_PROFILE_ID = ZP.PARTY_TAX_PROFILE_ID
                 AND ZP.PARTY_ID = HP1.PARTY_SITE_ID
                 AND HP1.PARTY_ID = HPP1.PARTY_ID
                 AND HPP1.PARTY_ID = HCA1.PARTY_ID
                 AND HCA1.CUST_ACCOUNT_ID = RCT1.BILL_TO_CUSTOMER_ID
	             AND RCT1.CUSTOMER_TRX_ID = RCTL1.CUSTOMER_TRX_ID
	             AND RCTL1.LINE_TYPE = 'LINE'
	             AND RCTL1.USER_DEFINED_FISC_CLASS = 'NOPST'
                 AND RCT1.TRX_NUMBER = RCT.TRX_NUMBER
	             AND ROWNUM = 1) certificate_num,
                (SELECT segment1 
                         FROM ra_cust_trx_line_gl_dist_all a,
                              gl_code_combinations b
                        WHERE a.code_combination_id=b.code_combination_id
                          AND a.account_class='REC'
                          AND a.customer_trx_id=rct.customer_trx_id) segment1,
			  hca.customer_type
, SUBSTR(rcta.name,1,4) trx_type --REL031 GERITM4535753 Added
  FROM   ra_customer_trx_all rct,
             ra_cust_trx_types_all rcta,
             hr_all_organization_units ha,
             xle_entity_profiles xep,
             ar_payment_schedules_all aps,
             ra_terms_vl rt,
             hz_parties hp,
             hz_cust_accounts hca,
             hz_party_sites hps,  
             hz_cust_acct_sites_all hcas,  
             hz_cust_site_uses_all hcau,
             hz_locations hl,
             hz_parties hp1,
             hz_party_sites hps1,  
             hz_party_site_uses hpsu,
             hz_locations hl1,
             (SELECT b.flex_value company_code  
                FROM fnd_flex_value_sets a,
                     fnd_flex_values b
                WHERE a.flex_value_set_id=b.flex_value_set_id
                  AND a.flex_value_set_name='CCL_COMPANY_CODES' 
                  AND b.attribute1='Y'
                  AND b.value_category='CCL_COMPANY_CODES') cc 
WHERE rct.cust_trx_type_seq_id=rcta.cust_trx_type_seq_id
  AND rct.legal_entity_id=xep.legal_entity_id
  AND aps.customer_trx_id=rct.customer_trx_id
  AND rct.org_id=ha.organization_id
  AND rt.term_id(+)=rct.term_id
  AND hp.party_id=hps.party_id
  AND hca.cust_account_id=rct.bill_to_customer_id
  AND hca.party_id=hp.party_id
  AND hps.party_site_id=hcas.party_site_id
  AND hca.cust_account_id = hcas.cust_account_id
  AND hcas.cust_acct_site_id = hcau.cust_acct_site_id
  AND hcau.site_use_id = rct.BILL_TO_SITE_USE_ID
  AND hcau.site_use_code = 'BILL_TO' 
  AND hps.location_id=hl.location_id
  AND hpsu.site_use_type(+) = 'SHIP_TO'
  AND hpsu.party_site_use_id(+)=rct.ship_to_party_site_use_id
  AND hps1.party_site_id(+) = hpsu.party_site_id
  AND hps1.party_id=hp1.party_id(+)
  AND hps1.location_id=hl1.location_id(+)
  AND cc.company_code=(SELECT segment1 
                         FROM ra_cust_trx_line_gl_dist_all a,
                              gl_code_combinations b
                        WHERE a.code_combination_id=b.code_combination_id
                          AND a.account_class='REC'
                          AND a.customer_trx_id=rct.customer_trx_id
                          AND ROWNUM=1) 
  AND rct.complete_flag = 'Y'
 AND hca.customer_type='R' 
  AND ha.organization_id=NVL(:p_business_unit,ha.organization_id)
  AND rct.trx_number BETWEEN NVL(:p_from_trx_number,rct.trx_number) AND  NVL(:p_to_trx_number,rct.trx_number) 
  AND hca.account_number BETWEEN NVL(:p_from_account_number,hca.account_number)  AND NVL(:p_to_account_number,hca.account_number)
  AND hp.party_name BETWEEN NVL(:p_from_customer,hp.party_name) AND  NVL(:p_to_customer,hp.party_name)  
 AND  cc.company_code NOT IN (SELECT b.flex_value company_code  
                                  FROM fnd_flex_value_sets a,
                                       fnd_flex_values b
                                 WHERE a.flex_value_set_id=b.flex_value_set_id
                                   AND a.flex_value_set_name='CCL_CA_INVOICE_NOPRINT') 
AND UPPER(:p_no_print) = 'Y'
UNION
SELECT  rct.trx_number trx_number,
             rct.org_id, --REL030  GERITM3722364 Added
             rct.term_id,
             rct.customer_trx_id ,
             rct.purchase_order,
             TO_CHAR(rct.trx_date ,'DD-MON-YYYY') Invoice_date,
             TO_CHAR(rct.ship_date_actual,'DD-MON-YYYY') date_shipped,
             TO_CHAR(rct.purchase_order_date,'DD-MON-YYYY') date_order,
             rct.fob_point fob,
             rct.WAYBILL_NUMBER shipping_ref,
             rct.printing_original_date original_date,
             hca.account_number,
             TO_CHAR(aps.due_date,'DD-MON-YYYY') due_date,
             xep.name legal_entity,
             (SELECT a2.address_line_1
                FROM XLE_REGISTRATIONS_V a2
               WHERE a2.legal_entity_id = xep.legal_entity_id) LE_ADD,
             (SELECT  a2.town_or_city
                        || ', '
                        || a2.region_1
                FROM XLE_REGISTRATIONS_V a2
               WHERE a2.legal_entity_id = xep.legal_entity_id) LE_CITY,
            (SELECT a2.postal_code
               FROM  XLE_REGISTRATIONS_V a2
              WHERE a2.legal_entity_id = xep.legal_entity_id) LE_CODE,
           (SELECT  b2.territory_short_name
               FROM XLE_REGISTRATIONS_V a2,
                    FND_TERRITORIES_VL b2
              WHERE a2.legal_entity_id = xep.legal_entity_id
                AND a2.country = b2.territory_code) LE_COUNTRY,  
         --REL030  GERITM3722364 Added below code
          (SELECT  b2.province
               FROM XLE_REGISTRATIONS_V a2,
                   HZ_LOCATIONS b2
              WHERE a2.legal_entity_id = xep.legal_entity_id
                AND a2.location_id = b2.location_id) le_province,  
           --REL030  GERITM3722364 Added above code
             rt.name term_name,
             rct.ship_via,
             hp.party_name bill_to_customer,
             hl.address1 bill_to_add,
             hl.address2 bill_to_add1,
             hl.city||','|| hl.province  bill_to_city,
             hl.postal_code bill_to_code,
             hz_format_pub.format_address(hl.location_id,null,null,CHR(13)) bill_format_add,
             hz_format_pub.format_address(hl1.location_id,null,null,CHR(13)) ship_format_add,
             (SELECT territory_short_name
                FROM  FND_TERRITORIES_VL 
               WHERE  territory_code=hl.country) bill_to_country,
             hp1.party_name ship_to_customer,
             hl1.address1 ship_to_add,
             hl1.address2 ship_to_add1,
             hl1.city||','|| hl1.province ship_to_city,
             hl1.postal_code ship_to_code,
             (SELECT  a.territory_short_name
                FROM  FND_TERRITORIES_VL a
               WHERE  a.territory_code=hl1.country) ship_to_country ,
             rct.invoice_currency_code,
             (SELECT  hl2.address1||' '||hl2.address2||' '||hl2.city||' '||hl2.province||' '||hl2.postal_code||' '||(SELECT a.territory_short_name
                                                                                                                       FROM FND_TERRITORIES_VL a
                                                                                                                      WHERE a.territory_code=hl2.country)
                FROM  ra_remit_tos_all rta,
                      ar_remit_to_locs_all art,
                      hz_locations hl2  
               WHERE  rct.remit_to_address_seq_id=rta.address_loc_seq_id
                 AND  rta.address_loc_seq_id=art.address_loc_seq_id
                 AND  art.location_id=hl2.location_id
                 AND  art.location_id = hl2.location_id(+) 
                 AND  rta.attribute1 like '%'||(SELECT segment1 
                                                  FROM ra_cust_trx_line_gl_dist_all a,
                                                       gl_code_combinations b
                                                 WHERE a.code_combination_id=b.code_combination_id
                                                   AND a.customer_trx_id=rct.customer_trx_id
                                                   AND rownum=1)||'%' )Remit_to,
              (SELECT hz_format_pub.format_address(hl2.location_id, null, null, ',')
                FROM  ra_remit_tos_all rta,
                      ar_remit_to_locs_all art,
                      hz_locations hl2  
               WHERE  rct.remit_to_address_seq_id=rta.address_loc_seq_id
                 AND  rta.address_loc_seq_id=art.address_loc_seq_id
                 AND  art.location_id=hl2.location_id
                 AND  art.location_id = hl2.location_id(+) 
                 AND  rta.attribute1 like '%'||(SELECT segment1 
                                                  FROM ra_cust_trx_line_gl_dist_all a,
                                                       gl_code_combinations b
                                                 WHERE a.code_combination_id=b.code_combination_id
                                                   AND a.customer_trx_id=rct.customer_trx_id
                                                   AND rownum=1)||'%' )Remit_to_format,													   
             (SELECT EXEMPT_CERTIFICATE_NUMBER
                FROM ZX_EXEMPTIONS ZE,
	                 ZX_PARTY_TAX_PROFILE ZP,
                     HZ_PARTY_SITES HP1,
                     HZ_PARTIES HPP1,
                     HZ_CUST_ACCOUNTS HCA1,
                     RA_CUSTOMER_TRX_ALL RCT1,
		             RA_CUSTOMER_TRX_LINES_ALL RCTL1
               WHERE ZE.PARTY_TAX_PROFILE_ID = ZP.PARTY_TAX_PROFILE_ID
                 AND ZP.PARTY_ID = HP1.PARTY_SITE_ID
                 AND HP1.PARTY_ID = HPP1.PARTY_ID
                 AND HPP1.PARTY_ID = HCA1.PARTY_ID
                 AND HCA1.CUST_ACCOUNT_ID = RCT1.BILL_TO_CUSTOMER_ID
	             AND RCT1.CUSTOMER_TRX_ID = RCTL1.CUSTOMER_TRX_ID
	             AND RCTL1.LINE_TYPE = 'LINE'
	             AND RCTL1.USER_DEFINED_FISC_CLASS = 'NOPST'
                 AND RCT1.TRX_NUMBER = RCT.TRX_NUMBER
	             AND ROWNUM = 1) certificate_num,
                (SELECT segment1 
                         FROM ra_cust_trx_line_gl_dist_all a,
                              gl_code_combinations b
                        WHERE a.code_combination_id=b.code_combination_id
                          AND a.account_class='REC'
                          AND a.customer_trx_id=rct.customer_trx_id) segment1,
				 hca.customer_type
,SUBSTR(rcta.name,1,4) trx_type --REL031 GERITM4535753 Added
  FROM   ra_customer_trx_all rct,
             ra_cust_trx_types_all rcta,
             hr_all_organization_units ha,
             xle_entity_profiles xep,
             ar_payment_schedules_all aps,
             ra_terms_vl rt,
             hz_parties hp,
             hz_cust_accounts hca,
             hz_party_sites hps,  
             hz_cust_acct_sites_all hcas,  
             hz_cust_site_uses_all hcau,
             hz_locations hl,
             hz_parties hp1,
             hz_party_sites hps1,  
             hz_party_site_uses hpsu,
             hz_locations hl1,
             (SELECT b.flex_value company_code  
                FROM fnd_flex_value_sets a,
                     fnd_flex_values b
                WHERE a.flex_value_set_id=b.flex_value_set_id
                  AND a.flex_value_set_name='CCL_COMPANY_CODES' 
                  --AND b.attribute1='Y'
                  AND b.value_category='CCL_COMPANY_CODES') cc 
WHERE rct.cust_trx_type_seq_id=rcta.cust_trx_type_seq_id
  AND rct.legal_entity_id=xep.legal_entity_id
  AND aps.customer_trx_id=rct.customer_trx_id
  AND rct.org_id=ha.organization_id
  AND rt.term_id(+)=rct.term_id
  AND hp.party_id=hps.party_id
  AND hca.cust_account_id=rct.bill_to_customer_id
  AND hca.party_id=hp.party_id
  AND hps.party_site_id=hcas.party_site_id
  AND hca.cust_account_id = hcas.cust_account_id
  AND hcas.cust_acct_site_id = hcau.cust_acct_site_id
  AND hcau.site_use_id = rct.BILL_TO_SITE_USE_ID
  AND hcau.site_use_code = 'BILL_TO' 
  AND hps.location_id=hl.location_id
  AND hpsu.site_use_type (+)= 'SHIP_TO'
  AND hpsu.party_site_use_id(+)=rct.ship_to_party_site_use_id
  AND hps1.party_site_id(+) = hpsu.party_site_id
  AND hps1.party_id=hp1.party_id(+)
  AND hps1.location_id=hl1.location_id(+)
  AND cc.company_code=(SELECT segment1 
                         FROM ra_cust_trx_line_gl_dist_all a,
                              gl_code_combinations b
                        WHERE a.code_combination_id=b.code_combination_id
                          AND a.account_class='REC'
                          AND a.customer_trx_id=rct.customer_trx_id
                          AND ROWNUM=1) 
  AND rct.complete_flag = 'Y'
 --AND hca.customer_type='R' 
  AND ha.organization_id=NVL(:p_business_unit,ha.organization_id)
  AND rct.trx_number BETWEEN NVL(:p_from_trx_number,rct.trx_number) AND  NVL(:p_to_trx_number,rct.trx_number) 
  AND hca.account_number BETWEEN NVL(:p_from_account_number,hca.account_number)  AND NVL(:p_to_account_number,hca.account_number)
  AND hp.party_name BETWEEN NVL(:p_from_customer,hp.party_name) AND  NVL(:p_to_customer,hp.party_name)
  AND UPPER(:p_no_print) ='N'