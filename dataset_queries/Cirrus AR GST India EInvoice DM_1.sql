--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:                                                                              -#
--# CREATION DATE : 12-DEC-2020                                                                        -#
--# CREATED BY    : Venkateswarlu M                                                                    -#
--# CR#                         Author             Date                Description                     -#
--#-----------------------------------------------------------------------------------------------------#
--# REL-048                      Venkateswarlu M  12-DEC-2020           Initial version                -#
--# REL-078                      Nuri Chetia            12-JUL-2023            GERITM40851081 amount not populating correctly for CM                -#

WITH bill_to AS (
  SELECT 
    su.site_use_id, 
    hca.customer_type, 
    hp.party_name, 
    hp.party_id, 
    hps.party_site_id, 
    hp.party_number, 
    hca.cust_account_id, 
    hca.account_number, 
    Replace(
      hl.country, 
      Chr(10), 
      ''
    ) country, 
    hca.attribute1, 
    cas.attribute2 cash_basis_customer, 
    hl.address1, 
    hl.address2, 
    hl.city, 
    hl.postal_code, 
    hl.province, 
    hl.state 
  FROM 
    HZ_CUST_SITE_USES_ALL su, 
    HZ_CUST_ACCT_SITES_ALL cas, 
    HZ_PARTY_SITES hps, 
    HZ_LOCATIONS hl, 
    HZ_PARTIES hp, 
    HZ_CUST_ACCOUNTS hca 
  WHERE 
    su.cust_acct_site_id = cas.cust_acct_site_id 
    AND cas.party_site_id = hps.party_site_id 
    AND hps.location_id = hl.location_id 
    AND hp.party_id = hps.party_id 
    AND cas.cust_account_id = hca.cust_account_id 
    AND su.site_use_code = 'BILL_TO'
), 
ship_to AS (
  SELECT 
    hp.party_id, 
    hp.party_name, 
    hp.party_number, 
    hpsu.party_site_id, 
    hpsu.party_site_use_id, 
    Replace(
      hl.country, 
      Chr(10), 
      ''
    ) country, 
    hl.address1, 
    hl.address2, 
    hl.city, 
    hl.postal_code, 
    hl.province, 
    hl.state 
  FROM 
    hz_party_site_uses hpsu, 
    hz_party_sites hps, 
    hz_locations hl, 
    hz_parties hp 
  WHERE 
    1 = 1 
    AND hpsu.party_site_id(+) = hps.party_site_id 
    AND hps.location_id = hl.location_id(+) 
    AND hp.party_id = hps.party_id(+) 
    AND hpsu.site_use_type(+) = 'SHIP_TO'
) 
SELECT 
  (
    SELECT 
      description 
    FROM 
      FND_LOOKUP_VALUES_VL 
    WHERE 
      lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
      AND meaning = hou.name || '_' ||(
        SELECT 
          description 
        FROM 
          FND_LOOKUP_VALUES_VL 
        WHERE 
          lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
          AND meaning = hou.name || '_' || types.name 
          AND enabled_flag = 'Y' 
          AND ROWNUM = 1 
          AND Trunc (SYSDATE) BETWEEN Nvl (
            start_date_active, 
            Trunc (SYSDATE)
          ) 
          AND Nvl (
            end_date_active, 
            Trunc (SYSDATE)
          )
      ) || '_GST_NO' 
      AND enabled_flag = 'Y' 
      AND ROWNUM = 1 
      AND Trunc (SYSDATE) BETWEEN Nvl (
        start_date_active, 
        Trunc (SYSDATE)
      ) 
      AND Nvl (
        end_date_active, 
        Trunc (SYSDATE)
      )
  ) AS User_GSTIN, 
  '1.0' AS Version, 
  NULL AS IRN, 
  'Fusion' AS Source_System, 
  'Y' AS Is_IRN, 
  NULL AS Is_EWB, 
 -- 'EInvoice.IndiaGST@ge.com' AS E_mail_ID, 
 'GSTIndia.EInvoice@ge.com' AS E_mail_ID,  
  'GST' AS TranDtls_TaxSch, 
  'Outward' AS Outward_Inward, 
  'Supply' AS Sub_type, 
  NULL AS Sub_type_description, 
  (
    CASE WHEN (ship_to.country) = 'IN' THEN 'B2B' WHEN (ship_to.country) != 'IN' THEN (
													
	   
      CASE WHEN (
        NVL(
          (
            SELECT 
              Round(
                abs(
                  sum(tax_amt)
                ), 
                2
              ) 
            FROM 
              zx_lines_v a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_CGST' 
              AND a.trx_id = rct.customer_trx_id
          ), 
          0
        )+ NVL(
          (
            SELECT 
              Round(
                abs(
                  sum(tax_amt)
                ), 
                2
              ) 
            FROM 
              zx_lines_v a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_SGST' 
              AND a.trx_id = rct.customer_trx_id
          ), 
          0
        )+ NVL(
          (
            SELECT 
              Round(
                abs(
                  sum(tax_amt)
                ), 
                2
              ) 
            FROM 
              zx_lines_v a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_IGST' 
              AND a.trx_id = rct.customer_trx_id
          ), 
          0
        )
      )> 0 THEN 'EXPWP' ELSE 'EXPWOP' END
    ) END
  ) AS TranDtls_SupTyp, 
  'N' AS TranDtls_Regrev, 
  NULL AS TranDtls_Typ, 
  NULL AS TranDtls_EcmGstin, 
  'N' AS TranDtls_IgstOnIntra, 
  NULL AS Diff_percentage, 
  NULL AS Taxability, 
  NULL AS Inter_Intra, 
  NULL AS Cancelled_Flag, 
  NULL AS Cancelled_Reason, 
  NULL AS Cancelled_Remarks, 
  DECODE(
    rct.trx_class, 'INV', 'INV', 'CM', 
    'CRN', 'DM', 'DBN'
	,'ONACC','CRN' --REL078 GERITM40851081 added
  ) AS DocDtls_Typ, 
  rct.trx_number AS DocDtls_No, 
  To_char(
    rct.trx_date, 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE = American'
  ) AS DocDtls_Dt, 
  NULL AS Reason_for_CN_DN, 
  (
    SELECT 
      description 
    FROM 
      FND_LOOKUP_VALUES_VL 
    WHERE 
      lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
      AND meaning = hou.name || '_' ||(
        SELECT 
          description 
        FROM 
          FND_LOOKUP_VALUES_VL 
        WHERE 
          lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
          AND meaning = hou.name || '_' || types.name 
          AND enabled_flag = 'Y' 
          AND ROWNUM = 1 
          AND Trunc (SYSDATE) BETWEEN Nvl (
            start_date_active, 
            Trunc (SYSDATE)
          ) 
          AND Nvl (
            end_date_active, 
            Trunc(SYSDATE)
          )
      ) || '_GST_NO' 
      AND enabled_flag = 'Y' 
      AND ROWNUM = 1 
      AND Trunc (SYSDATE) BETWEEN Nvl (
        start_date_active, 
        Trunc(SYSDATE)
      ) 
      AND Nvl (
        end_date_active, 
        Trunc (SYSDATE)
      )
  ) AS SellerDtls_Gstin, 
  (
    SELECT 
      a2.legal_entity_name 
    FROM 
      xle_registrations_v a2 
    WHERE 
      a2.legal_entity_id = xle.legal_entity_id
  ) AS SellerDtls_LglNm, 
  NULL AS SellerDtls_TrdNm, 
  CASE WHEN (
    (
      SELECT 
        decode(
          description, 'TS', 'TELANGANA', null
        ) 
      FROM 
        FND_LOOKUP_VALUES_VL 
      WHERE 
        lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
        AND meaning = hou.name || '_' || types.name 
        AND enabled_flag = 'Y' 
        AND ROWNUM = 1 
        AND TRUNC (SYSDATE) BETWEEN NVL (
          start_date_active, 
          TRUNC (SYSDATE)
        ) 
        AND NVL (
          end_date_active, 
          TRUNC (SYSDATE)
        )
    )= 'TELANGANA'
  ) THEN '6th, Floor Cyber Pearl IT Park Limited ,Block I Hitec City , Madhapur' ELSE(
    SELECT 
      a2.address_line_1 
    FROM 
      xle_registrations_v a2 
    WHERE 
      a2.legal_entity_id = xle.legal_entity_id
  ) END AS SellerDtls_Addr1, 
  NULL AS SellerDtls_Addr2, 
  CASE WHEN (
    (
      SELECT 
        decode(
          description, 'TS', 'TELANGANA', null
        ) 
      FROM 
        FND_LOOKUP_VALUES_VL 
      WHERE 
        lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
        AND meaning = hou.name || '_' || types.name 
        AND enabled_flag = 'Y' 
        AND ROWNUM = 1 
        AND TRUNC (SYSDATE) BETWEEN NVL (
          start_date_active, 
          TRUNC (SYSDATE)
        ) 
        AND NVL (
          end_date_active, 
          TRUNC (SYSDATE)
        )
    )= 'TELANGANA'
  ) THEN 'HYDERABAD' ELSE (
    SELECT 
      a2.town_or_city || ', ' || a2.region_1 
    FROM 
      xle_registrations_v a2 
    WHERE 
      a2.legal_entity_id = xle.legal_entity_id
  ) END AS SellerDtls_Loc, 
  CASE WHEN (
    (
      SELECT 
        decode(
          description, 'TS', 'TELANGANA', null
        ) 
      FROM 
        FND_LOOKUP_VALUES_VL 
      WHERE 
        lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
        AND meaning = hou.name || '_' || types.name 
        AND enabled_flag = 'Y' 
        AND ROWNUM = 1 
        AND TRUNC (SYSDATE) BETWEEN NVL (
          start_date_active, 
          TRUNC (SYSDATE)
        ) 
        AND NVL (
          end_date_active, 
          TRUNC (SYSDATE)
        )
    )= 'TELANGANA'
  ) THEN '500081' ELSE (
    SELECT 
      a2.postal_code 
    FROM 
      XLE_REGISTRATIONS_V a2 
    WHERE 
      a2.legal_entity_id = xle.legal_entity_id
  ) END AS SellerDtls_Pin, 
  (
    SELECT 
      flv.tag 
    FROM 
      XLE_REGISTRATIONS_V a2, 
      FND_LOOKUP_VALUES flv 
    WHERE 
      a2.legal_entity_id = xle.legal_entity_id 
      AND NVL(
        (
          SELECT 
            decode(
              description, 'TS', 'TELANGANA', null
            ) 
          FROM 
            fnd_lookup_values_vl 
          WHERE 
            lookup_type = 'CIRRUSAR_IND_IN_CM_LAYOUT' 
            AND meaning = hou.name || '_' || types.name 
            AND enabled_flag = 'Y' 
            AND ROWNUM = 1 
            AND TRUNC (SYSDATE) BETWEEN NVL (
              start_date_active, 
              TRUNC (SYSDATE)
            ) 
            AND NVL (
              end_date_active, 
              TRUNC (SYSDATE)
            )
        ), 
        Upper(a2.region_2)
      ) = Upper(flv.meaning) 
     -- AND flv.lookup_type = 'CIRRUSAR_DG40_GST_INDIA_EINVOICE' 
	 AND flv.lookup_type = 'CIRRUSAR_DG40_GST_INDIA_EINVOI'
      AND flv.LANGUAGE = 'US'
  ) AS SellerDtls_State, 
  NULL AS SellerDtls_Ph, 
  NULL AS SellerDtls_Em, 
  NULL AS Supplier_Code, 
 
  (
    CASE WHEN (ship_to.country) != 'IN' THEN 'URP' ELSE Nvl(
					 
      (
        SELECT 
          zr.registration_number 
        FROM 
          ZX_REGISTRATIONS zr, 
          ZX_PARTY_TAX_PROFILE zptn 
        WHERE 
          1 = 1 
          AND zr.party_tax_profile_id = zptn.party_tax_profile_id 
          AND SYSDATE BETWEEN Nvl(zr.effective_from, SYSDATE) 
          AND Nvl(zr.effective_to, SYSDATE + 1) 
          AND zptn.party_id = bill_to.party_site_id
      ), 
      (
        SELECT 
          zpt.rep_registration_number 
        FROM 
          ZX_PARTY_TAX_PROFILE zpt 
        WHERE 
          1 = 1 
          AND zpt.party_id = bill_to.party_site_id
      )
    ) END
  ) BuyerDtls_Gstin, 
  bill_to.party_name AS BuyerDtls_LglNm, 
  NULL AS BuyerDtls_TrdNm, 
  bill_to.address1 AS BuyerDtls_Addr1, 
  NULL AS BuyerDtls_Addr2, 
  bill_to.city AS BuyerDtls_Loc, 
  (
    CASE WHEN (ship_to.country) = 'IN' THEN bill_to.postal_code WHEN (ship_to.country) != 'IN' THEN '999999' END
				  
  ) AS BuyerDtls_Pin, 
  (
    CASE WHEN (ship_to.country) = 'IN' THEN (
      substr(
        (
          Nvl(
            (
              SELECT 
                zr.registration_number 
              FROM 
                ZX_REGISTRATIONS zr, 
                ZX_PARTY_TAX_PROFILE zptn 
              WHERE 
                1 = 1 
                AND zr.party_tax_profile_id = zptn.party_tax_profile_id 
                AND SYSDATE BETWEEN Nvl(zr.effective_from, SYSDATE) 
                AND Nvl(zr.effective_to, SYSDATE + 1) 
                AND zptn.party_id = bill_to.party_site_id
            ), 
            (
              SELECT 
                zpt.rep_registration_number 
              FROM 
                ZX_PARTY_TAX_PROFILE zpt 
              WHERE 
                1 = 1 
                AND zpt.party_id = bill_to.party_site_id
            )
          )
        ), 
        1, 
        2
      )
    ) WHEN (ship_to.country) != 'IN' THEN '96' END
			  
  ) AS BuyerDtls_State,
  (
    CASE WHEN (ship_to.country) = 'IN' THEN (
      substr(
        (
          Nvl(
            (
              SELECT 
                zr.registration_number 
              FROM 
                ZX_REGISTRATIONS zr, 
                ZX_PARTY_TAX_PROFILE zptn 
              WHERE 
                1 = 1 
                AND zr.party_tax_profile_id = zptn.party_tax_profile_id 
                AND SYSDATE BETWEEN Nvl(zr.effective_from, SYSDATE) 
                AND Nvl(zr.effective_to, SYSDATE + 1) 
                AND zptn.party_id = bill_to.party_site_id
            ), 
            (
              SELECT 
                zpt.rep_registration_number 
              FROM 
                zx_party_tax_profile zpt 
              WHERE 
                1 = 1 
                AND zpt.party_id = bill_to.party_site_id
            )
          )
        ), 
        1, 
        2
      )
    ) WHEN (ship_to.country) != 'IN' THEN '96' END
			  
  ) AS BuyerDtls_Pos,
  NULL AS BuyerDtls_Ph, 
  NULL AS BuyerDtls_Em, 
  NULL AS Customer_Code, 
  NULL AS DispDtls_Gstin, 
  NULL AS DispDtls_Nm, 
  NULL AS DispDtls_Addr1, 
  NULL AS DispDtls_Addr2, 
  NULL AS DispDtls_Loc, 
  NULL AS DispDtls_Pin, 
  NULL AS DispDtls_Stcd, 
  (
    CASE WHEN (
      ship_to.country = 'IN' 
      and (
        Upper(ship_to.state) <> Upper(bill_to.state)
      )
    ) THEN Nvl(
      (
        SELECT 
          zr.registration_number 
        FROM 
          ZX_REGISTRATIONS zr, 
          ZX_PARTY_TAX_PROFILE zptn 
        WHERE 
          1 = 1 
          AND zr.party_tax_profile_id = zptn.party_tax_profile_id 
          AND SYSDATE BETWEEN Nvl(zr.effective_from, SYSDATE) 
          AND Nvl(zr.effective_to, SYSDATE + 1) 
          AND zptn.party_id = ship_to.party_site_id
      ), 
      (
        SELECT 
          zpt.rep_registration_number 
        FROM 
          ZX_PARTY_TAX_PROFILE zpt 
        WHERE 
          1 = 1 
          AND zpt.party_id = ship_to.party_site_id
      )
    ) ELSE NULL END
  ) AS ShipDtls_Gstin, 
  (
    CASE WHEN (
      ship_to.country = 'IN' 
      and (
        Upper(ship_to.state) <> Upper(bill_to.state)
      )
    ) THEN xle.name ELSE NULL END
  ) AS ShipDtls_LglNm, 
  NULL AS SHIPDTLS_TRDNM, 
  (
    CASE WHEN (
      ship_to.country = 'IN' 
      and (
        Upper(ship_to.state)<> Upper(bill_to.state)
      )
    ) THEN ship_to.address1 ELSE NULL END
  ) AS ShipDtls_Addr1, 
  NULL AS ShipDtls_Addr2, 
  (
    CASE WHEN (
      ship_to.country = 'IN' 
      and (
        Upper(ship_to.state) <> Upper(bill_to.state)
      )
    ) THEN ship_to.city ELSE NULL END
  ) AS ShipDtls_Loc, 
  (
    CASE WHEN (
      ship_to.country = 'IN' 
      and Upper(ship_to.state) <> Upper(bill_to.state)
    ) THEN ship_to.postal_code --  WHEN ( ship_to.country) != 'IN'
    --    THEN  '999999'
    ELSE NULL END
  ) AS ShipDtls_Pin, 
  (
    CASE WHEN (
      ship_to.country = 'IN' 
      and (
        Upper(ship_to.state) <> Upper(bill_to.state)
      )
    ) THEN substr(
      (
        Nvl(
          (
            SELECT 
              zr.registration_number 
            FROM 
              ZX_REGISTRATIONS zr, 
              ZX_PARTY_TAX_PROFILE zptn 
            WHERE 
              1 = 1 
              AND zr.party_tax_profile_id = zptn.party_tax_profile_id 
              AND SYSDATE BETWEEN Nvl(zr.effective_from, SYSDATE) 
              AND Nvl(zr.effective_to, SYSDATE + 1) 
              AND zptn.party_id = ship_to.party_site_id
          ), 
          (
            SELECT 
              zpt.rep_registration_number 
            FROM 
              ZX_PARTY_TAX_PROFILE zpt 
            WHERE 
              1 = 1 
              AND zpt.party_id = ship_to.party_site_id
          )
        )
      ), 
      1, 
      2
    )
    ELSE NULL END
  ) AS ShipDtls_Stcd, 
  rctl.line_number AS ItemsList_SlNo, 
  NULL AS ItemsList_OrdLineRef, 
  NULL AS ItemsList_PrdSlNo, 
  NULL AS Item_code, 
  Item_val.item_number AS ItemsList_PrdNm, 
  nvl(
    Item_val.description, 
    AR_BPA_UTILS_PKG.fn_get_line_description(rctl.customer_trx_line_id)
  ) AS ItemsList_PrdDesc, 
  (
    SELECT 
      ecb.category_code 
    FROM 
      egp_categories_b ecb 
    WHERE 
      1 = 1 
      AND ecb.category_id = rctl.product_fisc_classification
  ) AS ItemsList_HsnCd, 
  CASE WHEN rctl.inventory_item_id IS NULL THEN 'Y' ELSE (
    Decode(
      rctl.product_type, 'SERVICES', 'Y', 
      'N'
    )
  ) END AS ItemsList_IsServc, 
  NULL AS ItemsList_BarCde, 
  --REL078 GERITM40851081 commented below
  /*
  NVL(
    rctl.quantity_invoiced, 
    NVL(rctl.quantity_ordered, 0)
  ) AS ItemsList_Qty, 
 */																										
--REL078 GERITM40851081 commented above
--REL078 GERITM40851081 added below	
CASE WHEN rct.trx_class IN ('CM','ONACC') THEN NVL(abs(QUANTITY_CREDITED),rctl.quantity_invoiced) --omp 
ELSE NVL(rctl.quantity_invoiced, NVL(rctl.quantity_ordered, 0))
END AS ItemsList_Qty,  
--REL078 GERITM40851081 added above													      
  NULL AS ItemsList_FreeQty, 
  CASE WHEN rctl.inventory_item_id IS NULL THEN 'OTH' ELSE (
    Decode(
      rctl.product_type, 'SERVICES', 'OTH', 
      'UNT'
    )
  ) END AS ItemsList_Unit, 
  (
    --CASE WHEN rct.trx_class = 'CM' THEN round( --REL078 GERITM40851081 commented
	CASE WHEN rct.trx_class IN ('CM','ONACC') THEN round( --REL078 GERITM40851081 added
      abs(rctl.unit_selling_price), 
      2
    ) ELSE round(
      abs(rctl.unit_selling_price), 
      2
    ) END
  ) AS ItemsList_UnitPrice, 
  (
   -- CASE WHEN rct.trx_class = 'CM' THEN round( --REL078 GERITM40851081 commented
	CASE WHEN rct.trx_class IN ('CM','ONACC') THEN round( --REL078 GERITM40851081 added
      (
        NVL(
           --rctl.quantity_invoiced, --REL078 GERITM40851081 commented
	 abs(rctl.QUANTITY_CREDITED),    --REL078 GERITM40851081 added
          NVL(rctl.quantity_ordered, 0)
        )
      ) * (
        abs(rctl.unit_selling_price)
      ), 
      2
    ) ELSE round(
      (
        NVL(
          rctl.quantity_invoiced, 
          NVL(rctl.quantity_ordered, 0)
        )
      ) * (
        abs(rctl.unit_selling_price)
      ), 
      2
    ) END
  ) AS ItemsList_TotAmt, 
  NULL AS ItemsList_Discount, 
  NULL AS ItemsList_OthChrg, 
  NULL AS VAT, 
  NULL AS Central_Excise, 
  NULL AS State_Excise, 
  NULL AS Export_Duty, 
  NULL AS value_before_bcd, 
  NULL AS BCD, 
  NULL AS ItemsList_PreTaxVal, 
  (
    --CASE WHEN rct.trx_class = 'CM' THEN (  --REL078 GERITM40851081 commented
	CASE WHEN rct.trx_class IN ('CM','ONACC') THEN (  --REL078 GERITM40851081 added
      (
        NVL(
		   --REL078 GERITM40851081 commented below
          /*rctl.quantity_invoiced, 
          NVL(rctl.quantity_ordered, 0)*/
		   --REL078 GERITM40851081 added below
		   abs(QUANTITY_CREDITED),  
          NVL(rctl.quantity_invoiced, 0)
		   --REL078 GERITM40851081 added above
        ) * abs(rctl.unit_selling_price)
      ) -0
    ) ELSE (
      (
        NVL(
          rctl.quantity_invoiced, 
          NVL(rctl.quantity_ordered, 0)
        ) * abs(rctl.unit_selling_price)
      ) -0
    ) END
  ) AS itemslist_assamt,
  NVL(
    (
      SELECT 
        NVL(tax_rate, 0) 
      FROM 
        zx_lines_v a 
      WHERE 
        Upper (tax_regime_name) LIKE 'INDIA_CGST' 
        AND a.trx_id = rctl.customer_trx_id 
        AND a.trx_line_id = rctl.customer_trx_line_id
    ), 
    0
  )+ NVL(
    (
      SELECT 
        NVL(tax_rate, 0) 
      FROM 
        zx_lines_v a 
      WHERE 
        Upper (tax_regime_name) LIKE 'INDIA_SGST' 
        AND a.trx_id = rctl.customer_trx_id 
        AND a.trx_line_id = rctl.customer_trx_line_id
    ), 
    0
  )+ NVL(
    (
      SELECT 
        NVL(tax_rate, 0) 
      FROM 
        zx_lines_v a 
      WHERE 
        Upper (tax_regime_name) LIKE 'INDIA_IGST' 
        AND a.trx_id = rctl.customer_trx_id 
        AND a.trx_line_id = rctl.customer_trx_line_id
    ), 
    0
  ) AS ItemsList_GstRt, 
  (
    SELECT 
      tax_rate 
    FROM 
      zx_lines_v a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_CGST' 
      AND a.trx_id = rctl.customer_trx_id 
      AND a.trx_line_id = rctl.customer_trx_line_id
  ) AS ItemsList_CgstRt, 
  (
    SELECT 
      tax_rate 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_SGST' 
      AND a.trx_id = rctl.customer_trx_id 
      AND a.trx_line_id = rctl.customer_trx_line_id
  ) AS ItemsList_SgstRt, 
  (
    SELECT 
      tax_rate 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_IGST' 
      AND a.trx_id = rctl.customer_trx_id 
      AND a.trx_line_id = rctl.customer_trx_line_id
  ) AS ItemsList_IgstRt, 
  NULL AS ItemsList_CesRt, 
  NULL AS ItemsList_Cess_Non_Advol_Rt, 
  NULL AS ItemsList_StateCesRt, 
  (
    SELECT 
      Round(
        abs(tax_amt), 
        2
      ) 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_IGST' 
      AND a.trx_id = rctl.customer_trx_id 
      AND a.trx_line_id = rctl.customer_trx_line_id
  ) AS ItemsList_IgstAmt, 
  (
    SELECT 
      Round(
        abs(tax_amt), 
        2
      ) 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_CGST' 
      AND a.trx_id = rctl.customer_trx_id 
      AND a.trx_line_id = rctl.customer_trx_line_id
  ) AS ItemsList_CgstAmt, 
  (
    SELECT 
      Round(
        abs(tax_amt), 
        2
      ) 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_SGST' 
      AND a.trx_id = rctl.customer_trx_id 
      AND a.trx_line_id = rctl.customer_trx_line_id
  ) AS ItemsList_SgstAmt, 
  NULL AS ItemsList_CesAmt, 
  NULL AS ItemsList_CesNonAdvlAmt, 
  NULL AS ItemsList_StateCesAmt, 
  NULL AS ItemsList_StateCesNonAdvlAmt, 
  (
   -- CASE WHEN rct.trx_class = 'CM' THEN round( --REL078 GERITM40851081 commented
    CASE WHEN rct.trx_class IN ('CM','ONACC') THEN round( --REL078 GERITM40851081 added
      (
        Nvl(
          (
            (
              NVL(
			  --REL078 GERITM40851081 commented below
               /* rctl.quantity_invoiced, 
                NVL(rctl.quantity_ordered, 0)*/
				--REL078 GERITM40851081 commented above
				--REL078 GERITM40851081 added below
				 abs(QUANTITY_CREDITED),  
                   NVL(rctl.quantity_invoiced, 0)	
				  --REL078 GERITM40851081 added above
              )* abs(rctl.unit_selling_price)
            )-0
          ), 
          0
        ) + Nvl(
          (
            SELECT 
              abs(tax_amt) 
            FROM 
              ZX_LINES_V a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_IGST' 
              AND a.trx_id = rctl.customer_trx_id 
              AND a.trx_line_id = rctl.customer_trx_line_id
          ), 
          0
        ) + Nvl(
          (
            SELECT 
              tax_amt 
            FROM 
              ZX_LINES_V a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_CGST' 
              AND a.trx_id = rctl.customer_trx_id 
              AND a.trx_line_id = rctl.customer_trx_line_id
          ), 
          0
        ) + Nvl(
          (
            SELECT 
              abs(tax_amt) 
            FROM 
              ZX_LINES_V a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_SGST' 
              AND a.trx_id = rctl.customer_trx_id 
              AND a.trx_line_id = rctl.customer_trx_line_id
          ), 
          0
        )
      ), 
      2
    ) ELSE round(
      (
        Nvl(
          (
            (
              NVL(
                rctl.quantity_invoiced, 
                NVL(rctl.quantity_ordered, 0)
              )* abs(rctl.unit_selling_price)
            )-0
          ), 
          0
        ) + Nvl(
          (
            SELECT 
              abs(tax_amt) 
            FROM 
              ZX_LINES_V a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_IGST' 
              AND a.trx_id = rctl.customer_trx_id 
              AND a.trx_line_id = rctl.customer_trx_line_id
          ), 
          0
        ) + Nvl(
          (
            SELECT 
              abs(tax_amt) 
            FROM 
              ZX_LINES_V a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_CGST' 
              AND a.trx_id = rctl.customer_trx_id 
              AND a.trx_line_id = rctl.customer_trx_line_id
          ), 
          0
        ) + Nvl(
          (
            SELECT 
              abs(tax_amt) 
            FROM 
              ZX_LINES_V a 
            WHERE 
              Upper (tax_regime_name) LIKE 'INDIA_SGST' 
              AND a.trx_id = rctl.customer_trx_id 
              AND a.trx_line_id = rctl.customer_trx_line_id
          ), 
          0
        )
      ), 
      2
    ) END
  ) AS ItemsList_TotItemVal, 
  NULL AS ItemsList_OrgCntry, 
  NULL AS ItemsList_Batch_Nm, 
  NULL AS ItemsList_Batch_ExpDt, 
  NULL AS ItemsList_Batch_WrDt, 
  NULL AS ItemsList_Atrr_Nm, 
  NULL AS ItemsList_Atrr_Val, 
  NULL AS Eligibility_ITC, 
  NULL AS ITC_IGST, 
  NULL AS ITC_CGST, 
  NULL AS ITC_SGST, 
  NULL AS ITC_Cess, 
  NULL AS Nature_of_expense, 
  NULL AS GL_code_Revenue_expense, 
  NULL AS GL_code_IGST, 
  NULL AS GL_code_CGST, 
  NULL AS GL_code_SGST, 
  NULL AS GL_code_Cess, 
  NULL AS GL_code_IGST_ITC, 
  NULL AS GL_code_CGST_ITC, 
  NULL AS GL_code_SGST_ITC, 
  NULL AS GL_code_Cess_ITC ------ 
  , 
  NULL AS MIS_1, 
  NULL AS MIS_2, 
  NULL AS MIS_3, 
  NULL AS MIS_4, 
  NULL AS MIS_5, 
  NULL AS MIS_6, 
  NULL AS MIS_7, 
  NULL AS MIS_8, 
  NULL AS MIS_9, 
  NULL AS MIS_10, 
  NULL AS MIS_11, 
  NULL AS MIS_12, 
  NULL AS MIS_13, 
  NULL AS MIS_14, 
  NULL AS MIS_15, 
  NULL AS MIS_16, 
  NULL AS MIS_17, 
  NULL AS MIS_18, 
  NULL AS MIS_19, 
  NULL AS MIS_20, 
  NULL AS MIS_21, 
  NULL AS MIS_22, 
  NULL AS MIS_23, 
  NULL AS MIS_24, 
  NULL AS MIS_25, 
  NULL AS MIS_26, 
  NULL AS MIS_27, 
  NULL AS MIS_28, 
  NULL AS MIS_29, 
  NULL AS MIS_30, 
  NULL AS FU_1, 
  NULL AS FU_2, 
  NULL AS FU_3, 
  NULL AS FU_4, 
  NULL AS FU_5, 
  NULL AS FU_6, 
  NULL AS FU_7, 
  NULL AS FU_8, 
  NULL AS FU_9, 
  NULL AS FU_10 ------- 
  ,
  (
    SELECT 
      ROUND(
        SUM(
          NVL(
            abs(extended_amount), 
            0
          )
        ), 
        2
      ) 
    FROM 
      RA_CUSTOMER_TRX_LINES_ALL 
    WHERE 
      customer_trx_id = rct.customer_trx_id 
      AND LINE_TYPE = 'LINE'
  ) AS ValDtls_AssVal, 
  (
    SELECT 
      Round(
        abs(
          sum(tax_amt)
        ), 
        2
      ) 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_CGST' 
      AND a.trx_id = rct.customer_trx_id
  ) AS ValDtls_CgstVal, 
  (
    SELECT 
      Round(
        abs(
          sum(tax_amt)
        ), 
        2
      ) 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_SGST' 
      AND a.trx_id = rct.customer_trx_id
  ) AS ValDtls_SgstVal, 
  (
    SELECT 
      Round(
        abs(
          sum(tax_amt)
        ), 
        2
      ) 
    FROM 
      ZX_LINES_V a 
    WHERE 
      Upper (tax_regime_name) LIKE 'INDIA_IGST' 
      AND a.trx_id = rct.customer_trx_id
  ) AS ValDtls_IgstVal, 
  NULL AS ValDtls_CesVal, 
  NULL AS ValDtls_StCesVal, 
  NULL AS ValDtls_CesNonAdval, 
  NULL AS ValDtls_Disc, 
  NULL AS ValDtls_OthChrg, 
  NULL AS ValDtls_RndOffAmt,
  (
    SELECT 
      ROUND(
        SUM(
          NVL(
            abs(
              nvl(extended_amount, 0)
            ), 
            0
          )
        ), 
        2
      ) 
    FROM 
      ra_customer_trx_lines_all 
    WHERE 
      customer_trx_id = rct.customer_trx_id 
      AND LINE_TYPE = 'LINE'
  )+ NVL(
    (
      SELECT 
        Round(
          abs(
            sum(tax_amt)
          ), 
          2
        ) 
      FROM 
        ZX_LINES_V a 
      WHERE 
        Upper (tax_regime_name) LIKE 'INDIA_CGST' 
        AND a.trx_id = rct.customer_trx_id
    ), 
    0
  )+ NVL(
    (
      SELECT 
        Round(
          abs(
            sum(tax_amt)
          ), 
          2
        ) 
      FROM 
        ZX_LINES_V a 
      WHERE 
        Upper (tax_regime_name) LIKE 'INDIA_SGST' 
        AND a.trx_id = rct.customer_trx_id
    ), 
    0
  )+ NVL(
    (
      SELECT 
        Round(
          abs(
            sum(tax_amt)
          ), 
          2
        ) 
      FROM 
        ZX_LINES_V a 
      WHERE 
        Upper (tax_regime_name) LIKE 'INDIA_IGST' 
        AND a.trx_id = rct.customer_trx_id
    ), 
    0
  ) AS ValDtls_TotInvVal, 
  NULL AS ValDtls_TotInvValFc, 
  NULL AS PayDtls_Nm, 
  NULL AS PayDtls_Mode, 
  NULL AS PayDtls_FinInsBr, 
  NULL AS PayDtls_PayTerm, 
  NULL AS PayDtls_PayInstr, 
  NULL AS PayDtls_CrTrn, 
  NULL AS PayDtls_DirDr, 
  NULL AS PayDtls_CrDay, 
  NULL AS PayDtls_PaidAmt, 
  NULL AS PayDtls_PaymtDue, 
  NULL AS PayDtls_AcctDet, 
  NULL AS RefDtls_InvRm, 
  NULL AS RefDtls_InvStDt, 
  NULL AS RefDtls_InvEndDt, 
  (
    --CASE WHEN (rct.trx_class) IN ('CM', 'DM') THEN  --REL078 GERITM40851081 commented 
	CASE WHEN (rct.trx_class) IN ('CM', 'DM','ONACC') THEN ( --REL078 GERITM40851081 added
      SELECT 
        trx_number 
      FROM 
        ra_customer_trx_all 
      WHERE 
        customer_trx_id = rct.previous_customer_trx_id
    ) END
  ) AS RefDtls_PrecDoc_InvNo, 
  To_char(
    (
     -- CASE WHEN (rct.trx_class) IN ('CM', 'DM') THEN (  --REL078 GERITM40851081 commented 
       CASE WHEN (rct.trx_class) IN ('CM', 'DM','ONACC') THEN (    --REL078 GERITM40851081 added  
 	   SELECT 
          trx_date 
        FROM 
          ra_customer_trx_all 
        WHERE 
          customer_trx_id = rct.previous_customer_trx_id
      ) END
    ), 
    'DD/MM/YYYY', 
    'NLS_DATE_LANGUAGE = American'
  ) AS RefDtls_PrecDoc_InvDt, 
  NULL AS RefDtls_PrecDoc_OthRefNo, 
  NULL AS RefDtls_Contr_RecAdvRefr, 
  NULL AS RefDtls_Contr_RecAdvDt, 
  NULL AS RefDtls_Contr_TendRefr, 
  NULL AS RefDtls_Contr_Refr, 
  NULL AS RefDtls_Contr_ExtRefr, 
  NULL AS RefDtls_Contr_ProjRefr, 
  NULL AS RefDtls_Contr_PORefr, 
  NULL AS RefDtls_Contr_PORefDt, 
  NULL AS Accounting_doc_No, 
  NULL AS Accounting_doc_dt, 
  NULL AS SO_No, 
  NULL AS SO_dt, 
  NULL AS Advance_Ref_No, 
  NULL AS Advance_Ref_dt, 
  NULL AS Advance_Amt, 
  NULL AS AddlDocDtls_Url, 
  NULL AS AddlDocDtls_Docs, 
  NULL AS AddlDocDtls_Info, 
  NULL AS ExpDtls_RefClm, 
  NULL AS ExpDtls_ShipBNo, 
  NULL AS ExpDtls_ShipBDt, 
  NULL AS ExpDtls_Port, 
  NULL AS ExpDtls_ForCur, 
  NULL AS ExpDtls_CntCode, 
  NULL AS EwbDtls_TransId, 
  NULL AS EwbDtls_Distance, 
  NULL AS EwbDtls_TransName, 
  NULL AS EwbDtls_TransMode, 
  NULL AS EwbDtls_TransDocNo, 
  NULL AS EwbDtls_TransDocDt, 
  NULL AS EwbDtls_VehNo, 
  NULL AS EwbDtls_VehType, 
  NULL AS "TAN", 
  NULL AS Vendor_site_ID, 
  NULL AS WHT_Trans_Category, 
  NULL AS Source_Doc_Type, 
  NULL AS Line_description, 
  NULL AS Date_of_deduction, 
  NULL AS Entry_date, 
  NULL AS Project_code, 
  NULL AS Tax_code_ERP, 
  NULL AS Currency, 
  NULL AS Exchange_rate, 
  NULL AS Exchange_type, 
  NULL AS Notification_21_2012, 
  NULL AS Country_remittance, 
  NULL AS Is_grossed_up, 
  NULL AS PO_description, 
  NULL AS Voucher_ID, 
  NULL AS Debit_Credit_identifier, 
  NULL AS Gross_expense_amt, 
  NULL AS TDS_base_amt, 
  NULL AS TDS_section, 
  NULL AS TDS_Rate, 
  NULL AS TDS_Amt, 
  NULL AS Offset_GL_Code, 
  NULL AS TDS_GL_Code, 
  hou.name AS BU, 
  NULL AS SBU, 
  NULL AS Location, 
  NULL AS "User", 
  NULL AS Company_Code, 
  NULL AS Company_Name, 
  NULL AS Tracking_No, 
  NULL AS Transaction_count, 
  NULL AS EWB_No, 
  NULL AS Return_Period, 
  NULL AS TDS_applicable, 
  NULL AS MIS_31, 
  NULL AS MIS_32, 
  NULL AS MIS_33, 
  NULL AS MIS_34, 
  NULL AS MIS_35, 
  NULL AS MIS_36, 
  NULL AS MIS_37, 
  NULL AS MIS_38, 
  NULL AS MIS_39, 
  NULL AS MIS_40, 
  NULL AS MIS_41, 
  NULL AS MIS_42, 
  NULL AS MIS_43, 
  NULL AS MIS_44, 
  NULL AS MIS_45, 
  NULL AS MIS_46, 
  NULL AS MIS_47, 
  NULL AS MIS_48, 
  NULL AS MIS_49, 
  NULL AS MIS_50, 
  NULL AS MIS_51, 
  NULL AS MIS_52, 
  NULL AS MIS_53, 
  NULL AS MIS_54, 
  NULL AS MIS_55, 
  NULL AS MIS_56, 
  NULL AS MIS_57, 
  NULL AS MIS_58, 
  NULL AS MIS_59, 
  NULL AS MIS_60, 
  NULL AS FU_11, 
  NULL AS FU_12, 
  NULL AS FU_13, 
  NULL AS FU_14, 
  NULL AS FU_15, 
  NULL AS FU_16, 
  NULL AS FU_17, 
  NULL AS FU_18, 
  NULL AS FU_19, 
  NULL AS FU_20, 
  NULL AS FU_21, 
  NULL AS FU_22, 
  NULL AS FU_23, 
  NULL AS FU_24, 
  NULL AS FU_25, 
  NULL AS FU_26, 
  NULL AS FU_27, 
  NULL AS FU_28, 
  NULL AS FU_29, 
  NULL AS FU_30, 
  bill_to.state ----Reference columns--------- 
  , 
  rct.customer_trx_id, 
  rctl.line_number, 
  rctl.customer_trx_line_id, 
  rctl.LINE_TYPE, 
  'ENG' KEY 
					  
			
FROM 
  RA_CUSTOMER_TRX_ALL rct, 
  RA_CUST_TRX_TYPES_ALL types, 
  RA_CUSTOMER_TRX_LINES_ALL rctl, 
  XLE_FIRSTPARTY_INFORMATION_V xle --  ,egp_system_items_b         eitem 
  --  ,egp_system_items_tl        eiteml 
  , 
  --  ar_system_parameters_all sysp, 
  HR_OPERATING_UNITS hou, 
  BILL_TO, 
  SHIP_TO, 
  (
    SELECT 
      eiteml.description, 
      eitem.item_number, 
      sysp.org_id, 
      eitem.inventory_item_id 
    FROM 
      EGP_SYSTEM_ITEMS_B eitem, 
      EGP_SYSTEM_ITEMS_TL eiteml, 
      AR_SYSTEM_PARAMETERS_ALL sysp 
    WHERE 
      eitem.inventory_item_id(+) = eiteml.inventory_item_id 
      AND eitem.organization_id = eiteml.organization_id 
      AND eiteml.LANGUAGE = Userenv('LANG') 
      AND eitem.approval_status = 'A' --AND   rctl.org_id = sysp.org_id  
      AND sysp.item_validation_org_id = eitem.organization_id
  ) item_val ---------- 
WHERE 
  1 = 1 
  AND rct.legal_entity_id = xle.legal_entity_id 
  AND rct.customer_trx_id = rctl.customer_trx_id 
  AND rctl.LINE_TYPE = 'LINE' 
  AND rct.cust_trx_type_seq_id = types.cust_trx_type_seq_id 
  AND rctl.inventory_item_id = Item_val.inventory_item_id (+) 
  AND rctl.org_id = Item_val.org_id (+) 
  AND rct.complete_flag = 'Y' 
  AND ship_to.party_site_use_id(+) = rct.ship_to_party_site_use_id 
  AND rct.bill_to_site_use_id = bill_to.site_use_id 
  AND hou.organization_id = rct.org_id 
  AND NVL(rct.attribute11, 'N') <> 'S' 
  AND hou.name = 'IN_CR_DG40_BU' --AND rct.trx_class  ='CM' 
  AND trunc(rct.creation_date) >=('2021-01-25')