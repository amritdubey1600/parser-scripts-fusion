--======================================================================================================
--# --------------------------------------------------------------------------------------------------#
--# DESCRIPTION: Cirrus AP Receipt Confirm Hold Extract
--#
--#
--#
--# CREATION DATE: 12-08-16
--# CREATED BY: Kishore
--# REL-022
--# MODIFICATION HISTORY:
--# CR#         Author                Date        Description
--# ------------------------------------------------------------------------------------------------------------------------------#
--# REL 022     Karun                02-11-18	Added lookups for Business Unit to process Receipts Hold
--# -------------------------------------------------------------------------------------------------------------------------------#
 

SELECT inv_num AS key, inv_num, dataextract
  FROM (SELECT 
               ---REPLACE(aia.invoice_num, '/', '.') AS inv_num,
               TRANSLATE(aia.invoice_num, '/’', '._') AS inv_num,
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
			   fnd_lookup_values     flv1 --REL-008
         WHERE 1 = 1 -- aia.creation_date> trunc(sysdate-2)
		 --rel -008 September Release start 
		 AND ap_invoices_utility_pkg.get_approval_status (aia.invoice_id,
                                                          NULL,
                                                          NULL,
                                                          NULL) = 'APPROVED'
		 --rel -008 September Release end
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
           AND aia.invoice_num = NVL(:p_invoice_number, aia.invoice_num)
           AND SYSDATE BETWEEN NVL(flv.start_date_active, SYSDATE) AND
               NVL(flv.end_date_active, SYSDATE)
			   --REL-008 START
		   AND flv1.lookup_type = 'CIRRUSAP_RECEIPT_HOLD'
           AND flv1.language = 'US'
           AND flv1.enabled_flag = 'Y'	   
		   AND SYSDATE BETWEEN NVL(flv1.start_date_active, SYSDATE) AND
               NVL(flv1.end_date_active, SYSDATE)	   
		   AND ha.name <> flv1.meaning 	  --REL-008 END
         ORDER BY aia.invoice_num)
	--REL-008 START	 
UNION
SELECT inv_num AS key, inv_num, dataextract
  FROM (SELECT 
             --REPLACE(aia.invoice_num, '/', '.') AS inv_num,
			 TRANSLATE(aia.invoice_num, '/’', '._') AS inv_num,
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
			   fnd_lookup_values     flv1, --REL-008
			   AP_INVOICE_DISTRIBUTIONS_ALL aid,
			   pjf_projects_all_b ppa
         WHERE 1 = 1 -- aia.creation_date> trunc(sysdate-2)
		 --rel -008 September Release start 
		 AND ap_invoices_utility_pkg.get_approval_status (aia.invoice_id,
                                                          NULL,
                                                          NULL,
                                                          NULL) = 'APPROVED'
		--rel -008 September Release end
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
           AND aia.invoice_num = NVL(:p_invoice_number, aia.invoice_num)
           AND SYSDATE BETWEEN NVL(flv.start_date_active, SYSDATE) AND
               NVL(flv.end_date_active, SYSDATE)
		   AND aia.invoice_id=aid.invoice_id
           AND aid.pjc_project_id=ppa.project_id(+)
		   AND flv1.lookup_type = 'CIRRUSAP_RECEIPT_HOLD'
           AND flv1.language = 'US'
           AND flv1.enabled_flag = 'Y'	   
		   AND SYSDATE BETWEEN NVL(flv1.start_date_active, SYSDATE) AND
               NVL(flv1.end_date_active, SYSDATE)	   
		   AND ha.name =flv1.meaning            	   
         ORDER BY aia.invoice_num)
	--REL-008 END	 
UNION
SELECT 'XYZ' AS key, ' ' inv_num, ' ' dataextract
  FROM sys.dual