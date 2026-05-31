/*--#-----------------------------------------------------------------------------------------------------------------#
--# CCLF Alfresco Invoice archival extract
--# DESCRIPTION  : This data model query used to get the invoice archival extract for Alfresco
--#
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# -----------------------------------------------------------------------------------------------------------------#
--# REL-007           Shankar U        09-Aug-2017              For GC25 company code enabled alfresco extract
--# REL-034           Nuri Chetia       01-Nov-2019              GEINC5211971/GERITM5906234 modified for performance tuning
--# -----------------------------------------------------------------------------------------------------------------#*/
SELECT  rct.trx_number trx_number,
             rct.term_id,
             rct.customer_trx_id ,
             rct.purchase_order,
       TO_CHAR(rct.trx_date ,'DD-MON-YYYY') Invoice_date,
-----rct.trx_date  invoice_date,
         TO_CHAR(rct.ship_date_actual,'mm/dd/yyyy') date_shipped,
      ---   rct.ship_date_actual date_shipped,
             TO_CHAR(rct.purchase_order_date,'mm/dd/yyyy') date_order,
             rct.fob_point fob,
             rct.WAYBILL_NUMBER shipping_ref,
             rct.printing_original_date original_date,
             hca.account_number,
      TO_CHAR(aps.due_date,'DD-MON-YYYY') due_date,
      ---     aps.due_date  due_date,
             xep.name legal_entity,
             (SELECT a2.address_line_1
                FROM XLE_REGISTRATIONS_V a2
               WHERE a2.legal_entity_id = xep.legal_entity_id) LE_ADD,
(SELECT a2.address_line_2
                FROM XLE_REGISTRATIONS_V a2
               WHERE a2.legal_entity_id = xep.legal_entity_id) LE_ADD2,
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
             (SELECT  hl2.address1||','||hl2.address2||','||hl2.city||' '||hl2.province||' '||hl2.postal_code||','||(SELECT a.territory_short_name
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
                                                   AND rownum=1)||'%' )Remit_to_format,
 (  SELECT  hl3.address1||','||hl3.address2||','||hl3.city||' '||hl3.province||' '||hl3.postal_code||','||(SELECT a.territory_short_name
                                                                                                                       FROM FND_TERRITORIES_VL a
                                                                                                                      WHERE a.territory_code=hl3.country)
                 FROM   ar_remit_to_locs_all art,
                      hz_locations hl3  
               WHERE  rct.remit_to_address_seq_id=art.address_loc_seq_id(+)
                AND  art.location_id= hl3.location_id(+)) as Remit_to_format_canada,
             (SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_CONTACT'
               AND lookup_code = 'LOCKBOX_ADDR_' || xle.country
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE))) as Remit_to_format2,
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
             hca.customer_type 
			--- added bby vijay below 
			, fabu.bu_name  ---  added by Vijay
			, xle.name legal_entity_name  -- Supplier Name 
			, HZ_FORMAT_PUB.format_address (xle.location_id,
                                     NULL,
                                     NULL,
                                     CHR (13))
          as formatted_legal_address1	 -- Supplier Addresss
		  , (SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_CONTACT'
               AND lookup_code = 'SUPPLIER_TOLL_FREE_' || xle.country
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS supplier_toll_free
       ,(SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_CONTACT'
               AND lookup_code = 'SUPPLIER_EMAIL_' || xle.country
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS supplier_email
    ,(SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_CONTACT'
               AND lookup_code = 'REMIT_CONTACT_' || xle.country
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS remit_contact
       ,(SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_CONTACT'
               AND lookup_code = 'SUPPLIER_BUS_NUM_' || xle.country
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS supplier_bus_num    
,xle.registration_number  SUPP_VAT_NO		
,(SELECT REP_REGISTRATION_NUMBER
             FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID =  hps.party_site_id
              AND PARTY_TYPE_CODE = 'THIRD_PARTY_SITE') bill_tax_reg_no,
          (SELECT REP_REGISTRATION_NUMBER
             FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID =  hps1.party_site_id
              AND PARTY_TYPE_CODE = 'THIRD_PARTY_SITE') ship_tax_reg_no
			  , (SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_BANK_INFO'
               AND lookup_code = hou.name ||'_'|| rct.invoice_currency_code||'_BANK'
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS bank_name,
       (SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_BANK_INFO'
               AND lookup_code = hou.name ||'_'|| rct.invoice_currency_code||'_BANK_ACC'
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS bank_account_number, 
       (SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_BANK_INFO'
               AND lookup_code = hou.name ||'_'|| rct.invoice_currency_code||'_SWIFT'
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS swift_code,
       (SELECT description
          FROM fnd_lookup_values_vl
         WHERE     lookup_type = 'XXAR_INV_BANK_INFO'
               AND lookup_code = hou.name ||'_'|| rct.invoice_currency_code||'_ABA'
               AND enabled_flag = 'Y'
               AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (end_date_active,
                                                TRUNC (SYSDATE)))
          AS iban_number,
		  rct.CUSTOMER_REFERENCE,
		  rct.CT_reference,
		  rct.EXCHANGE_RATE_TYPE,
       TO_CHAR (rct.EXCHANGE_DATE, 'YYYY-MM-DD') EXCHANGE_DATE,
       rct.EXCHANGE_RATE,
	   (substr(fabu.bu_name,instr(fabu.bu_name,'_',1,2)+1, (instr(fabu.bu_name,'_',1,3)- instr(fabu.bu_name,'_',1,2))-1)) company_code,
DECODE(hca.CUSTOMER_TYPE,'I',SUBSTR(hcas.ORIG_SYSTEM_REFERENCE,-4),NULL) BUC_ID
,rct.SPECIAL_INSTRUCTIONS
,(SELECT party.party_name
          FROM JTF_RS_SALESREPS sales, Hz_parties party
         WHERE     sales.RESOURCE_SALESREP_ID =
                      rct.PRIMARY_RESOURCE_SALESREP_ID
               AND sales.RESOURCE_ID = party.party_id)
          primary_salesrep_name,
 (SELECT '+'||party.PRIMARY_PHONE_COUNTRY_CODE||' '||party.PRIMARY_PHONE_AREA_CODE||party.PRIMARY_PHONE_NUMBER
          FROM JTF_RS_SALESREPS sales, Hz_parties party
         WHERE     sales.RESOURCE_SALESREP_ID =
                      rct.PRIMARY_RESOURCE_SALESREP_ID
               AND sales.RESOURCE_ID = party.party_id)
          primary_salesrep_phone,
 (SELECT party.email_address
          FROM JTF_RS_SALESREPS sales, Hz_parties party
         WHERE     sales.RESOURCE_SALESREP_ID =
                      rct.PRIMARY_RESOURCE_SALESREP_ID
               AND sales.RESOURCE_ID = party.party_id)
          salesrep_email
, TO_CHAR (
          NVL (
             DECODE (
                types.accounting_affect_flag,
                'Y', aps.amount_line_items_original,
                'N', (SELECT SUM (extended_amount)
                        FROM ra_customer_trx_lines_all lines
                       WHERE     lines.customer_trx_id = rct.customer_trx_id
                             AND lines.line_type = 'LINE')),
             TO_NUMBER (0)),
          fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          line_amount,
TO_CHAR (
          NVL (
             DECODE (
                types.accounting_affect_flag,
                'Y', (aps.amount_line_items_original * nvl(rct.Exchange_rate,1)),
                'N', (SELECT SUM (extended_amount * nvl(rct.Exchange_rate,1))
                        FROM ra_customer_trx_lines_all lines
                       WHERE     lines.customer_trx_id = rct.customer_trx_id
                             AND lines.line_type = 'LINE')),
             TO_NUMBER (0)),
          fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          line_amount_exch,
       TO_CHAR (
          NVL (
             DECODE (
                types.accounting_affect_flag,
                'Y', aps.tax_original,
                'N', (SELECT SUM (extended_amount)
                        FROM ra_customer_trx_lines_all lines
                       WHERE     lines.customer_trx_id = rct.customer_trx_id
                             AND lines.line_type = 'TAX')),
             TO_NUMBER (0)),
          fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          tax_amount,
       TO_CHAR (
          NVL (
             DECODE (
                types.accounting_affect_flag,
                'Y', aps.freight_original,
                'N', (SELECT SUM (extended_amount)
                        FROM ra_customer_trx_lines_all lines
                       WHERE     lines.customer_trx_id = rct.customer_trx_id
                             AND lines.line_type = 'FREIGHT')),
             TO_NUMBER (0)),
          fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          freight_amount,
       TO_CHAR (
          NVL (
               DECODE (
                  types.accounting_affect_flag,
                  'Y', aps.amount_due_original,
                  'N', (SELECT SUM (extended_amount)
                          FROM ra_customer_trx_lines_all lines
                         WHERE lines.customer_trx_id = rct.customer_trx_id))
             + NVL (aps.amount_adjusted, TO_NUMBER (0)),
             TO_NUMBER (0)),
          fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          total_amount
 ,TO_CHAR (
          NVL (
               DECODE (
                  types.accounting_affect_flag,
                  'Y', (aps.amount_due_original *  nvl(rct.Exchange_rate,1) ),
                  'N', (SELECT SUM (extended_amount * nvl(rct.Exchange_rate,1) )
                          FROM ra_customer_trx_lines_all lines
                         WHERE lines.customer_trx_id = rct.customer_trx_id))
             + NVL (aps.amount_adjusted, TO_NUMBER (0)),
             TO_NUMBER (0)),
          fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          total_amount_exch,
       TO_CHAR (NVL (aps.amount_due_remaining, TO_NUMBER (0)),
                fnd_currency.get_format_mask (rct.invoice_currency_code, 40))
          amount_due_remaining ,
		  (SELECT territory_short_name FROM fnd_territories_vl WHERE territory_code = xle.country) as legal_country
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
RA_CUST_TRX_LINE_GL_DIST_ALL rctlg 
-- added By Vijay
,fun_all_business_units_v fabu  
,xle_firstparty_information_v xle
,hr_operating_units hou
,ra_cust_trx_types_all types
,xla_ae_headers xah
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
-- Added outer join when shipto is null. 26 JAN 16
  AND hpsu.site_use_type(+) = 'SHIP_TO'
  AND hpsu.party_site_use_id(+)=rct.ship_to_party_site_use_id
  AND hps1.party_site_id(+)= hpsu.party_site_id
  AND hps1.party_id=hp1.party_id(+)
  AND hps1.location_id=hl1.location_id(+)
  AND rct.complete_flag = 'Y'
--  AND hca.customer_type='R' -- Should include internal as well. 12 Nov 15
--AND rctlg.gl_posted_date IS NOT NULL
 AND rctlg.event_id = xah.event_id
 AND xah.gl_transfer_date IS NOT NULL
AND rctlg.account_class = 'REC'
AND rctlg.customer_trx_id = rct.customer_trx_id
--  changes by vijay AND  ha.organization_id = (select BU_ID from fun_all_business_units_v fab where bu_name = 'CA_CAD_BU')
AND  ha.organization_id = fabu.bu_id --  added by vijay 
-- addedd by vijay below 2 lines
and ha.organization_id in (   select BU_ID from fun_all_business_units_v fab where 
bu_name  in ( 'CA_CAD_BU','CA_WT_DG07_BU', 'US_WT_DG09_BU', 'US_CR_DG05_BU', 'US_CR_DG04_BU', 'US_CR_DG01_BU'
,'CA_SB_GC25_BU')) --REL-007 Added for GC25 
 AND xle.legal_entity_id                 = rct.legal_entity_id
-----and rct.trx_number in ('11002100000042' ,'11002100000051' ,'201603WIRLSUSE129')
   AND hou.organization_id                 = rct.org_id
   and rct.cust_trx_type_seq_id= types.cust_trx_type_seq_id
 -- addition ends here
AND ((:P_INVOICE_NUM IS NOT NULL AND rct.trx_number IN (SELECT REGEXP_SUBSTR(:P_INVOICE_NUM,'[^\,]+', 1, level)
    FROM DUAL
    CONNECT BY REGEXP_SUBSTR(:P_INVOICE_NUM, '[^\,]+', 1, level) IS NOT NULL)) OR
(:P_INVOICE_NUM  IS NULL AND (xah.gl_transfer_date > NVL((SELECT MAX(ERH.processstart)
				FROM ess_request_history ERH
				    ,ess_request_property ERP1
				WHERE 1=1
--REL034 GEINC5211971/GERITM5906234 Starts
/*ERH.PARENTREQUESTID IN (SELECT REQUESTID 
							FROM ess_request_history ERH
							WHERE DEFINITION = 'JobSet://oracle/apps/ess/custom/CCLF_AR_Inv_Archival_Job_Set')*/
--REL034 GEINC5211971/GERITM5906234 Ends
				AND ERH.requestid = ERP1.requestid	
				AND ERP1.name = 'submit.argument1'
		       		AND ERP1.value IS NULL
				AND ERH.DEFINITION	= 'JobDefinition://oracle/apps/ess/custom/AR/CCLF_AR_INV_ARCHIVAL_EXTRACT'		  
				AND ERH.executable_status = 'SUCCEEDED'), xah.gl_transfer_date-1)))
				)
UNION
SELECT  'dummy' trx_number,
             NULL,
             NULL ,
             NULL,
             NULL Invoice_date,
             NULL date_shipped,
             NULL date_order,
             NULL fob,
             NULL shipping_ref,
             NULL original_date,
             NULL,
             NULL due_date,
             NULL legal_entity,
             NULL LE_ADD,
             NULL LE_ADD2,
             NULL LE_CITY,
            NULL LE_CODE,
           NULL LE_COUNTRY,  
             NULL term_name,
             NULL,
             NULL bill_to_customer,
             NULL bill_to_add,
             NULL bill_to_add1,
             NULL  bill_to_city,
             NULL bill_to_code,
             NULL bill_format_add,
             NULL ship_format_add,
             NULL bill_to_country,
             NULL ship_to_customer,
             NULL ship_to_add,
             NULL ship_to_add1,
             NULL ship_to_city,
             NULL ship_to_code,
             NULL ship_to_country ,
             NULL,
             NULL Remit_to,
			 null Remit_to_format_canada,
            null Remit_to_format2,
               NULL certificate_num,
            NULL customer_type,
			NUll  bu_name
			,NUll  legal_entity_name
,NUll formatted_legal_address1
,NUll supplier_toll_free
,NUll supplier_email
,null remit_contact
,NUll supplier_bus_num
,NUll SUPP_VAT_NO
,NUll bill_tax_reg_no
,NUll ship_tax_reg_no
,NUll bank_name
,NUll bank_account_number
,NUll swift_code
,NUll iban_number
,NUll CUSTOMER_REFERENCE
,NUll CT_reference
,NUll EXCHANGE_RATE_TYPE
,NUll EXCHANGE_DATE
,NUll EXCHANGE_RATE
,NUll company_code
,NUll BUC_ID
,null SPECIAL_INSTRUCTIONS
,null primary_salesrep_name
,null primary_salesrep_phone
,null salesrep_email
,null line_amount
,null line_amount_exch
,null tax_amount
,null freight_amount
,null total_amount
,null  total_amount_exch
, null  amount_due_remaining
,null legal_country
FROM dual