SELECT inv_num AS "KEY",
       'text' AS "OUTPUT_FORMAT",
       'FTP' AS "DEL_CHANNEL",
       'GED_RECPT_CONFIRM.' || to_char(SYSDATE, 'MMDDYYYYhh24MISS') ||
       '.txt' AS "OUTPUT_NAME",
       'true' AS "SAVE_OUTPUT",
       fnd_profile.value('MFT_ICS_SFTP') AS "PARAMETER1",
       :p_dest_dir AS "PARAMETER4",
       'GED_RECPT_CONFIRM.' || inv_num || '.' ||
       to_char(SYSDATE, 'MMDDYYYYhh24MISS') || '.txt' AS "PARAMETER5",
       'true' AS "PARAMETER6"
  FROM (SELECT 
 --REPLACE(aia.invoice_num, '/', '.') AS inv_num,
TRANSLATE(aia.invoice_num, '/’', '._') AS inv_num,
               aia.invoice_num AS inv_num1,
               '"' || ha.name || '",' || '"' || ps.segment1 || '",' || '"' ||
               ps.vendor_name || '",' || '"' || aia.invoice_num || '",' || '"' ||
               flv.meaning || '"' AS dataextract
          FROM ap_invoices_all       aia,
               ap_invoice_lines_all  aila,
               po_headers_all        pha,
               po_lines_all          pll,
               po_line_locations_all plla,
               hr_operating_units    ha,
               poz_suppliers_v       ps,
               fnd_lookup_values     flv
         WHERE 1 = 1 -- aia.creation_date> trunc(sysdate-2)
           AND aila.invoice_id = aia.invoice_id
           AND aila.po_header_id = pha.po_header_id
           AND aila.po_line_id = plla.po_line_id
           AND plla.line_location_id = aila.po_line_location_id
              --and invoice_num like 'ReceiptConfirmationHold%'
           AND pha.po_header_id = aia.po_header_id
           AND pha.po_header_id = pll.po_header_id
           AND plla.po_line_id = pll.po_line_id
           AND plla.po_header_id = pha.po_header_id
           AND aia.invoice_id NOT IN
               (SELECT ahl.invoice_id
                  FROM ap_holds_all ahl
                 WHERE ahl.hold_lookup_code = flv.meaning)
           AND plla.match_option = 'P'
           AND plla.inspection_required_flag = 'N'
           AND plla.receipt_required_flag = 'N'
              -- Modified by Orthon on Mar.9 for invoice using foreign currency
              --AND aila.amount >= 5000
           AND (aila.amount *
               decode(aia.invoice_currency_code,
                       'USD',
                       1,
                       (SELECT gdr.conversion_rate
                          FROM gl_daily_rates            gdr,
                               gl_daily_conversion_types gdc
                         WHERE gdc.conversion_type = gdr.conversion_type
                           AND gdr.from_currency = aia.invoice_currency_code
                           AND gdr.to_currency = 'USD'
                           AND gdr.conversion_date = trunc(aia.invoice_date)
                           AND gdc.user_conversion_type = 'MOR'))) >= 5000
              -- Modify end
           AND aia.payment_status_flag = 'N'
           AND aia.org_id = ha.organization_id
           AND aia.vendor_id = ps.vendor_id
           AND flv.lookup_type = 'GED RECPT CONFIRMATION LOOKUP'
           AND flv.language = 'US'
           AND flv.enabled_flag = 'Y'
           AND aia.invoice_num = nvl(:p_invoice_number, aia.invoice_num)
           AND SYSDATE BETWEEN nvl(flv.start_date_active, SYSDATE) AND
               nvl(flv.end_date_active, SYSDATE)
		   AND ha.name <>'CN_IP_DG32_BU'
         ORDER BY aia.invoice_num)
UNION
SELECT inv_num AS "KEY",
       'text' AS "OUTPUT_FORMAT",
       'FTP' AS "DEL_CHANNEL",
       'GED_RECPT_CONFIRM.' || to_char(SYSDATE, 'MMDDYYYYhh24MISS') ||
       '.txt' AS "OUTPUT_NAME",
       'true' AS "SAVE_OUTPUT",
       fnd_profile.value('MFT_ICS_SFTP') AS "PARAMETER1",
       :p_dest_dir AS "PARAMETER4",
       'GED_RECPT_CONFIRM.' || inv_num || '.' ||
       to_char(SYSDATE, 'MMDDYYYYhh24MISS') || '.txt' AS "PARAMETER5",
       'true' AS "PARAMETER6"
  FROM (SELECT 
  --REPLACE(aia.invoice_num, '/', '.') AS inv_num,
  TRANSLATE(aia.invoice_num, '/’', '._') AS inv_num,
               aia.invoice_num AS inv_num1,
               '"' || ha.name || '",' || '"' || ps.segment1 || '",' || '"' ||
               ps.vendor_name || '",' || '"' || aia.invoice_num || '",' || '"' ||
               flv.meaning || '"' AS dataextract
          FROM ap_invoices_all       aia,
               ap_invoice_lines_all  aila,
               po_headers_all        pha,
               po_lines_all          pll,
               po_line_locations_all plla,
               hr_operating_units    ha,
               poz_suppliers_v       ps,
               fnd_lookup_values     flv,
			   AP_INVOICE_DISTRIBUTIONS_ALL aid,
			   pjf_projects_all_b ppa
         WHERE 1 = 1 -- aia.creation_date> trunc(sysdate-2)
           AND aila.invoice_id = aia.invoice_id
           AND aila.po_header_id = pha.po_header_id
           AND aila.po_line_id = plla.po_line_id
           AND plla.line_location_id = aila.po_line_location_id
              --and invoice_num like 'ReceiptConfirmationHold%'
           AND pha.po_header_id = aia.po_header_id
           AND pha.po_header_id = pll.po_header_id
           AND plla.po_line_id = pll.po_line_id
           AND plla.po_header_id = pha.po_header_id
           AND aia.invoice_id NOT IN
               (SELECT ahl.invoice_id
                  FROM ap_holds_all ahl
                 WHERE ahl.hold_lookup_code = flv.meaning)
           AND plla.match_option = 'P'
           AND plla.inspection_required_flag = 'N'
           AND plla.receipt_required_flag = 'N'
              -- Modified by Orthon on Mar.9 for invoice using foreign currency
              --AND aila.amount >= 5000
           AND ((aila.amount *
               decode(aia.invoice_currency_code,
                       'USD',
                       1,
                       (SELECT gdr.conversion_rate
                          FROM gl_daily_rates            gdr,
                               gl_daily_conversion_types gdc
                         WHERE gdc.conversion_type = gdr.conversion_type
                           AND gdr.from_currency = aia.invoice_currency_code
                           AND gdr.to_currency = 'USD'
                           AND gdr.conversion_date = trunc(aia.invoice_date)
                           AND gdc.user_conversion_type = 'MOR'))) > 5000  OR ((aila.amount *
                                                                                 decode(aia.invoice_currency_code,
                                                                                        'USD',
                                                                                         1,
                                                                                (SELECT gdr.conversion_rate
                                                                                   FROM gl_daily_rates            gdr,
                                                                                        gl_daily_conversion_types gdc
                                                                                  WHERE gdc.conversion_type = gdr.conversion_type
                                                                                    AND gdr.from_currency = aia.invoice_currency_code
                                                                                     AND gdr.to_currency = 'USD'
                                                                                     AND gdr.conversion_date = trunc(aia.invoice_date)
                                                                                     AND gdc.user_conversion_type = 'MOR'))) <= 5000   AND ppa.segment1 IS NOT NULL))
              -- Modify end
           AND aia.payment_status_flag = 'N'
           AND aia.org_id = ha.organization_id
           AND aia.vendor_id = ps.vendor_id
           AND flv.lookup_type = 'GED RECPT CONFIRMATION LOOKUP'
           AND flv.language = 'US'
           AND flv.enabled_flag = 'Y'
           AND aia.invoice_num = nvl(:p_invoice_number, aia.invoice_num)
           AND SYSDATE BETWEEN nvl(flv.start_date_active, SYSDATE) AND
               nvl(flv.end_date_active, SYSDATE)
		   AND aia.invoice_id=aid.invoice_id
           AND aid.pjc_project_id=ppa.project_id(+)
-- REL-022 commented out   -- AND ha.name = 'CN_IP_DG32_BU' 
-- REL-022 Added below code
          AND ha.name IN (SELECT flv.lookup_code
                                   FROM FND_LOOKUP_VALUES flv
                                  WHERE flv.lookup_type   = 'CIRRUSAP_RECEIPT_HOLD_BU'
                                    AND flv.language      = 'US'
                                    AND flv.enabled_flag  = 'Y'
                                    AND NVL(flv.start_date_active, SYSDATE) <= SYSDATE
                                    AND NVL(flv.end_date_active, SYSDATE) >= SYSDATE)
-- REL-022 Added above code
         ORDER BY aia.invoice_num)	 
/*SELECT 'ENG' as "KEY"
      ,'text' as "OUTPUT_FORMAT"
      ,'FTP' as "DEL_CHANNEL"
      ,'GED_RECPT_CONFIRM.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.txt' as "OUTPUT_NAME"
      ,'true' as "SAVE_OUTPUT"
      ,FND_PROFILE.VALUE('GED_BI_MFTCS_SERVER')  as "PARAMETER1"
      ,:P_DEST_DIR as "PARAMETER4"
      ,'GED_RECPT_CONFIRM.' || TO_CHAR(SYSDATE, 'MMDDYYYYhh24MISS') || '.txt'  as "PARAMETER5"
      ,'true' as "PARAMETER6"
FROM sys.dual*/