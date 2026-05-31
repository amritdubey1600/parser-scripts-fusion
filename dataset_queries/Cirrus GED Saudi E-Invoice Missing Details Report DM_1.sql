--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:                                                                              -#
--# CREATION DATE : 30-MAR-2023                                                                        -#
--# CREATED BY    : GE Digital Team                                                                           -#
--# CR#                         Author             Date                Description                     -#
--#-----------------------------------------------------------------------------------------------------#
--# REL-076                     Divya k          30-MAR-2023           Initial version                 -#
--# REL-077                     Divya k          29-MAY-2023           Changed logic for email and delivery method fields-#
--																	   Changed alias name for status code field-#
--# REL-088                     Ritika k         18-MAY-2024           Added 4 columns transaction_date, accounting_date, gross_amount, currency-#  
--                                                                     Added 2 parameters Transaction from and to date,Accounting from and to date-#
--                                                                     Added logic to remove non value invoices-# 
--                                                                     Added logic to group sales order based on Parent part number-#
-- REL-103                     Amjad Mohd        11-AUG-2025           GERITM51450658: fixed the BU parameter logic
--#-----------------------------------------------------------------------------------------------------#
WITH Order_details AS (SELECT dfla.root_parent_fulfill_line_id,
					          esib.attribute24,
							  dfla.fulfill_line_id,
					   CASE WHEN (dfla.root_parent_fulfill_line_id IS NOT NULL AND esib.attribute24='Y')  THEN 'Y'
						    WHEN (dfla.root_parent_fulfill_line_id IS NULL) THEN 'Y'				   
						    ELSE 'N' 
						    END as osp_flag
					   FROM DOO_FULFILL_LINES_ALL dfla,
					        EGP_SYSTEM_ITEMS_B esib
					   WHERE 1 = 1	 
					   AND dfla.inventory_organization_id 		       = esib.organization_id
					   AND dfla.inventory_item_id 				       = esib.inventory_item_id) 
--REL-088 added above logic for parent part number
SELECT  distinct b_bill.account_number bill_to_customer_number,
		b_bill_party.party_name  bill_to_customer_name,  
		b_ship_party.party_name ship_to_customer_name, 
		b_ship_party.party_number ship_to_customer_number,
		a_bill_loc.address1||'||'||a_bill_loc.address2||'||'||a_bill_loc.address3||'||'||a_bill_loc.state||'||'||a_bill_loc.postal_code||'||'||a_bill_loc.city||'||'||a_bill_loc.Country  Bill_to_address,  
		a_ship_loc.address1||'||'||a_ship_loc.address2||'||'||a_ship_loc.address3||'||'||a_ship_loc.state||'||'||a_ship_loc.postal_code||'||'||a_ship_loc.city||'||'||a_ship_loc.Country  Ship_to_address,    
		hou.name bu_name,
		a_bill.TRANSLATED_CUSTOMER_NAME  SoldTO_Translated_Cname,
		(select sites.TRANSLATED_CUSTOMER_NAME
		   from hz_cust_accounts b_bill,
			    hz_parties b_ship_party,
			    hz_cust_acct_sites_all sites,
			    hz_party_site_uses u_ship,                
			    hz_party_sites a_ship_ps		                
		   where 1=1
		   AND trx.ship_to_party_id = b_ship_party.party_id(+)
		   AND trx.ship_to_party_site_use_id = u_ship.party_site_use_id(+)
		   AND u_ship.party_site_id=a_ship_ps.party_site_id
		   AND a_ship_ps.party_id=b_ship_party.party_id
		   AND sites.party_site_id=u_ship.party_site_id
		   AND u_ship.SITE_USE_TYPE='SHIP_TO'
		   AND b_bill.party_id = b_ship_party.party_id
		   AND b_bill.cust_account_id=sites.cust_account_id
		   AND b_bill.account_termination_date >= sysdate
		   ) ShipTO_Translated_Cname 
		  ,a_bill_loc.ATTRIBUTE2  SoldTO_Translated_Customer_Address  
		  ,a_ship_loc.ATTRIBUTE2  ShipTO_Translated_Customer_Address
		  ,xle.name Legal_Entity_Name
		  ,(SELECT Meaning
		   FROM fnd_lookup_values_vl
		   WHERE lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
		   AND lookup_code = 'LL_LE_NAME_'||''||hou.name) Legal_Entity_Name_Trans
		   ,nvl((Select hps.party_site_number 
			from hz_party_sites hps
			where hps.party_site_name = xle.name
			AND hps.status = 'A'
			AND rownum=1),'0018a00001uobSSAAY') Legal_Entity_Number			
		  ,(SELECT description
			FROM fnd_lookup_values_vl
			WHERE lookup_type = 'XXAR_INV_CONTACT'
			AND meaning = 'SUPPLIER_VAT_NUM_' || hou.name
			AND enabled_flag = 'Y'
			AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active,TRUNC (SYSDATE))
			AND NVL (end_date_active,TRUNC (SYSDATE))) LEGAL_ENTITY_VAT_ID
		  ,(SELECT Tag
			FROM fnd_lookup_values_vl
			WHERE lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
			AND lookup_code = 'LL_LE_NAME_'||''||hou.name) Legal_Entity_Address_Trans
		  ,(SELECT Description
			FROM fnd_lookup_values_vl
			WHERE lookup_type = 'CIRRUS_AR_NEW_LE_DETAILS'
			AND lookup_code = 'LL_LE_NAME_'||''||hou.name) Legal_Entity_Address
		  ,NVL(bill_party.rep_registration_number,bill_party_site.rep_registration_number) Bill_VAT_number
		  ,NVL(ship_party.rep_registration_number,ship_party_site.rep_registration_number) Ship_VAT_number
		  ,(SELECT TO_CHAR(HTML_LONG_DESCRIPTION) 
			FROM egp_system_items_tl 
			WHERE inventory_item_id=esi.inventory_item_id 
			AND ORGANIZATION_ID =esi.ORGANIZATION_ID 
			AND language='AR') Item_number_translation
		  ,esi.item_number
		  ,trx.trx_number
		  ,rctla.line_number
		  /*,(SELECT hcpe.email_address
		    FROM HZ_CONTACT_POINTS hcpe,
		         HZ_CUST_ACCOUNT_ROLES hcar,
		         HZ_ROLE_RESPONSIBILITY hrr
			WHERE hcar.cust_Acct_Site_id	=	a_bill.cust_Acct_Site_id
			  AND b_bill.cust_Account_id		=	hcar.cust_Account_id
			  AND hcar.status				=	'A'
			  AND hcar.primary_flag			=	'Y'
			  AND hrr.responsibility_type	=	'BILL_TO'
			  AND hrr.cust_account_role_id	=	hcar.cust_account_role_id
			  AND hrr.STATUS_FLAG			=	'A'
			  AND hcpe.relationship_id		=	hcar.relationship_id
			  AND hcpe.contact_point_type	=	'EMAIL'
			  AND hcpe.status				=	'A'
			  AND hcpe.primary_flag			= 	'Y'
			  AND rownum = 1
			) Email*/ --Commented in Rel-077
		  --Rel-077 changed below logic for Email
		  ,CASE WHEN (SELECT hcp.txn_delivery_method
		   FROM HZ_CUSTOMER_PROFILES_F hcp
			   ,HZ_CUST_SITE_USES_ALL  hcsu 
		  WHERE hcp.cust_account_id	=	b_bill.cust_account_id
		  AND hcp.site_use_id 		IS 	NOT NULL
		  AND TRUNC(SYSDATE) BETWEEN hcp.effective_start_date AND hcp.effective_end_date
		  AND hcp.status			=	'A'
		  AND hcsu.site_use_id		=	hcp.site_use_id
		  AND hcsu.site_use_code	=	'BILL_TO'
		  AND hcsu.status			=	'A'
		  AND hcsu.primary_flag		=	'Y'
		  ) = 'EMAIL_INV' THEN (SELECT hcpe.email_address
		    FROM HZ_CONTACT_POINTS hcpe,
		         HZ_CUST_ACCOUNT_ROLES hcar,
		         HZ_ROLE_RESPONSIBILITY hrr
			WHERE hcar.cust_Acct_Site_id	=	a_bill.cust_Acct_Site_id
			  AND b_bill.cust_Account_id		=	hcar.cust_Account_id
			  AND hcar.status				=	'A'
			  AND hcar.primary_flag			=	'Y'
			  AND hrr.responsibility_type	=	'BILL_TO'
			  AND hrr.cust_account_role_id	=	hcar.cust_account_role_id
			  AND hrr.STATUS_FLAG			=	'A'
			  AND hcpe.relationship_id		=	hcar.relationship_id
			  AND hcpe.contact_point_type	=	'EMAIL'
			  AND hcpe.status				=	'A'
			  AND hcpe.primary_flag			= 	'Y'
			  AND rownum = 1
			) 
		  Else NULL END Email,
		   --Rel-077 changed above logic for Email
(SELECT --hcp.txn_delivery_method --Commented in REL-077
         DECODE(hcp.txn_delivery_method,'EMAIL_INV','EMAIL','PRINT_INV','PAPER','ORA_PORTAL_UPLOAD_INV','PORTAL')  --Rel-077 Added Decode
		 FROM HZ_CUSTOMER_PROFILES_F hcp
			  ,HZ_CUST_SITE_USES_ALL  hcsu 
		WHERE hcp.cust_account_id	=	b_bill.cust_account_id
		  AND hcp.site_use_id 		IS 	NOT NULL
		  AND TRUNC(SYSDATE) BETWEEN hcp.effective_start_date AND hcp.effective_end_date
		  AND hcp.status			=	'A'
		  AND hcsu.site_use_id		=	hcp.site_use_id
		  AND hcsu.site_use_code	=	'BILL_TO'
		  AND hcsu.status			=	'A'
		  AND hcsu.primary_flag		=	'Y'
		  ) delivery_method,
        trx.attribute1 Zakat_Status,  --Status_code Rel-077 changed alias name
        trx.attribute2 UUID,
        nvl(a_bill_loc.building,'0000') bill_to_building_number,
        a_bill_loc.province bill_to_district,
        a_bill_loc.city bill_to_city,
        a_bill_loc.address1	bill_to_street,
        a_bill_loc.country bill_to_Country_code,
         --REL-088 added the below columns 
        trx.trx_date transaction_date,
        apsa.gl_date accounting_date,
        apsa.amount_due_original gross_amount,
        trx.invoice_currency_code currency,
		--REL-088 added the above columns
	   REGEXP_SUBSTR (replace(replace(a_bill_loc.attribute2,',','||'),'،','||'), '[^||]+', 1, 1) bill_to_street_trans,
       REGEXP_SUBSTR (replace(replace(a_bill_loc.attribute2,',','||'),'،','||'), '[^||]+', 1, 2) bill_to_district_trans, 
       REGEXP_SUBSTR (replace(replace(a_bill_loc.attribute2,',','||'),'،','||'), '[^||]+', 1, 3) bill_to_city_trans	   
FROM   ra_customer_trx_all trx,
       hz_cust_accounts b_bill,
       hz_parties b_bill_party,
       hz_cust_acct_sites_all a_bill,
       hz_party_sites a_bill_ps,
       hz_locations a_bill_loc,
       hz_parties b_ship_party,
       hz_party_sites a_ship_ps,
       hz_locations a_ship_loc,
       hz_cust_site_uses_all u_bill,
       hz_party_site_uses u_ship,
       xle_firstparty_information_v xle,
       hr_operating_units hou ,
	   (SELECT rep_registration_number,party_id
        FROM zx_party_tax_profile
        WHERE party_type_code = 'THIRD_PARTY_SITE') bill_party,
	   (SELECT rep_registration_number,party_id
	    FROM zx_party_tax_profile
	    WHERE party_type_code = 'THIRD_PARTY_SITE') bill_party_site,
	   (SELECT rep_registration_number,party_id
	    FROM zx_party_tax_profile
	    WHERE party_type_code = 'THIRD_PARTY_SITE') ship_party,
	   (SELECT rep_registration_number,party_id
	    FROM zx_party_tax_profile
	    WHERE party_type_code = 'THIRD_PARTY_SITE') ship_party_site,
	   ra_customer_trx_lines_all rctla,
	   egp_system_items esi,
	   ar_system_parameters_all aspa,
	   ra_batch_sources_all batch,
	   ar_payment_schedules_all apsa, --REL-088
	   Order_details  --REL-088
WHERE trx.bill_to_customer_id       = b_bill.cust_account_id
AND   b_bill.party_id               = b_bill_party.party_id
AND   trx.ship_to_party_id          = b_ship_party.party_id(+)
AND   trx.bill_to_site_use_id       = u_bill.site_use_id
AND   trx.ship_to_party_site_use_id = u_ship.party_site_use_id(+)
AND   u_bill.cust_acct_site_id      = a_bill.cust_acct_site_id(+)
AND   a_bill.party_site_id          = a_bill_ps.party_site_id(+)
AND   a_bill_loc.location_id(+)     = a_bill_ps.location_id
AND   u_ship.party_site_id          = a_ship_ps.party_site_id(+)
AND   a_ship_loc.location_id(+)     = a_ship_ps.location_id
AND   hou.organization_id           = trx.org_id
AND   xle.legal_entity_id           = trx.legal_entity_id
AND   b_bill_party.party_id         = bill_party.party_id(+)
AND   a_bill_ps.party_site_id       = bill_party_site.party_id(+)
AND   b_ship_party.party_id         = ship_party.party_id(+)
AND   a_ship_ps.party_site_id       = ship_party_site.party_id(+)
AND   trx.customer_trx_id           = rctla.customer_trx_id
AND   rctla.inventory_item_id       = esi.inventory_item_id(+)
AND   rctla.org_id                  = aspa.org_id(+)
AND   trx.customer_trx_id           = apsa.customer_trx_id -- REl-088
AND   apsa.amount_due_original<>0       -- REL-088 added logic 
AND   ((rctla.inventory_item_id IS NOT NULL
AND   aspa.item_validation_org_id   = esi.organization_id)
OR    rctla.inventory_item_id IS NULL) 
AND   rctla.line_type               = 'LINE'
AND   trx.batch_source_seq_id       = batch.batch_source_seq_id
AND   batch.name NOT IN ('GED Conversion','GED Conversion1')
AND   TRUNC(trx.trx_date)             >= ('2023-05-15')
AND  (trx.trx_number IN (:p_trx_number) OR COALESCE(:p_trx_number,NULL) IS NULL)
AND  (hou.name IN (:p_bu_name) OR COALESCE(:p_bu_name,NULL) IS NULL)
AND  (trx.attribute1 IN (:p_status) OR COALESCE(:p_status,NULL) IS NULL)
AND TRUNC(trx.trx_date) BETWEEN NVL(:p_from_trx_date,trx.trx_date) AND NVL(:p_to_trx_date,trx.trx_date) --REL-088 added the parameter 
AND TRUNC(apsa.gl_date) BETWEEN NVL(:p_from_accounting_date,apsa.gl_date) AND NVL(:p_to_accounting_date,apsa.gl_date) --REL-088 added the parameter 
AND hou.name IN (SELECT fabu.bu_name
				FROM FND_LOOKUP_VALUES flv,
				Fun_all_business_units_v fabu
				WHERE flv.lookup_type                    = 'GED_BU_NAMES'
				AND LANGUAGE                             = 'US'
				AND flv.enabled_flag                     = 'Y'
				AND NVL(flv.start_date_active, SYSDATE) <= SYSDATE
				AND NVL(flv.end_date_active, SYSDATE)   >= SYSDATE
				AND flv.lookup_code                      = fabu.bu_name
				--AND flv.description ='DIGAVN'  REL-103 GERITM51450658 
				AND flv.description ='DIG'  --added for REL-103 GERITM51450658
				AND flv.tag = 'E-INVOICING')
--REL-088 Added below logic 
AND  TO_NUMBER(rctla.interface_line_attribute5) = Order_details.fulfill_line_id(+)
AND  Order_details.osp_flag(+) = 'Y'
AND (CASE WHEN rctla.interface_line_context = 'DOO'
          THEN (CASE WHEN TO_NUMBER(rctla.interface_line_attribute5) = (Order_details.fulfill_line_id)
		             AND Order_details.osp_flag = 'Y'
                 then '1'
		         else '0' end)
           else '1'
           end) = '1'
--REL-088 Added above logic 
ORDER BY trx.trx_number,
         rctla.line_number