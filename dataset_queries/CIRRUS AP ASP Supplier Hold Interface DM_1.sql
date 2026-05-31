/*--#-----------------------------------------------------------------------------------------------------------------#
--# GED ASP Supplier Hold Integration
--# DESCRIPTION  : This data model query to fetch invoices for High Risk Suppliers
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-021	  Vijay Kochhar    04-SEP-2018  SOLAR Changes logic for 3 way match invoice 
--# REL-027	  Nuri Chetia	   16-APR-2019	Changes done in brusting logic
--# ---------------------------------------------------------------------------------------------------------------------
*/

SELECT inv_num AS key
      ,inv_num
      ,dataextract
FROM  ( (SELECT aia.invoice_num AS inv_num
              ,'"' || ha.name || '",' || '"' || ps.segment1 || '",' || '"' ||
               ps.vendor_name || '",' || '"' || aia.invoice_num || '",' || '"' ||
               flv.meaning || '"' AS dataextract
        FROM   ap_invoices_all       aia
              ,ap_invoice_lines_all  aila
              ,po_headers_all        pha
              ,po_lines_all          pll
              ,po_line_locations_all plla
              ,hr_operating_units    ha
              ,poz_suppliers_v       ps
              ,poz_supplier_sites_v  pss
              ,fnd_lookup_values     flv
        WHERE  1 = 1
        AND    aila.invoice_id = aia.invoice_id
        AND    aila.po_header_id = pha.po_header_id
        AND    aila.po_line_id = plla.po_line_id
        AND    plla.line_location_id = aila.po_line_location_id
        AND    pha.po_header_id = aia.po_header_id
        AND    pha.po_header_id = pll.po_header_id
        AND    plla.po_line_id = pll.po_line_id
        AND    plla.po_header_id = pha.po_header_id
        AND    aia.invoice_id NOT IN
               (SELECT ahl.invoice_id
                 FROM   ap_holds_all ahl
                 WHERE  ahl.hold_lookup_code = flv.meaning)
        AND    plla.match_option = 'P'
        AND    plla.inspection_required_flag = 'N'
        AND    plla.receipt_required_flag = 'N'
        AND    aia.payment_status_flag = 'N'
        AND    aia.org_id = ha.organization_id
        AND    aia.vendor_id = ps.vendor_id
        AND    aia.vendor_site_id = pss.vendor_site_id
        AND    pss.attribute3 IN
               ('ASP - Standard Risk', 'ASP - Hightened Risk')
        AND    flv.lookup_type = 'GED AP SUPPLIER HOLD LOOKUP'
        AND    flv.tag = 'ASP Receipt Confirmation'
        AND    flv.language = 'US'
        AND    flv.enabled_flag = 'Y'
        
         -- REL-021 added  below code
        AND ha.name NOT IN 
		(SELECT lookup_code
	           FROM FND_LOOKUP_VALUES
	          WHERE lookup_type ='CIRRUSAP_SO_ASPSUPPLIERHOLD_BU'
		    AND language='US'
		    AND TRUNC(SYSDATE) BETWEEN  NVL(start_date_active, TRUNC(SYSDATE))  AND  NVL(end_date_active, TRUNC(SYSDATE))
		)
		
	 -- REL-021 added  Above code	
	 
        AND    SYSDATE BETWEEN nvl(flv.start_date_active, SYSDATE) AND
               nvl(flv.end_date_active, SYSDATE)
        AND    ((TRIM(:p_invoice_number) IS NOT NULL AND
              aia.invoice_num = TRIM(:p_invoice_number)) OR
              (TRIM(:p_invoice_number) IS NULL AND
              (((CAST(aia.last_update_date AS TIMESTAMP) >
              nvl(to_date(:p_start_time, 'YYYY-MM-DD hh24:mi:ss'),
                        (SELECT MAX(erh.processstart)
                          FROM   ess_request_history  erh
                                ,ess_request_property erp1
                          WHERE  erh.requestid = erp1.requestid
                          AND    erh.definition =
                                 'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                          AND    erh.executable_status = 'SUCCEEDED'
                          AND    erp1.name = 'submit.argument2'
                          AND    erp1.value IS NULL))) OR
              (NOT EXISTS
               (SELECT 1
                     FROM   ess_request_history
                     WHERE  definition =
                            'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                     AND    executable_status = 'SUCCEEDED'))) AND
              trunc(aia.last_update_date) <=
              nvl(to_date(:p_end_time, 'YYYY-MM-DD'), trunc(SYSDATE)))))
        UNION
        SELECT aia.invoice_num AS inv_num
              ,'"' || ha.name || '",' || '"' || ps.segment1 || '",' || '"' ||
               ps.vendor_name || '",' || '"' || aia.invoice_num || '",' || '"' ||
               flv.meaning || '"' AS dataextract
        FROM   ap_invoices_all       aia
              ,ap_invoice_lines_all  aila
              ,po_headers_all        pha
              ,po_lines_all          pll
              ,po_line_locations_all plla
              ,hr_operating_units    ha
              ,poz_suppliers_v       ps
              ,poz_supplier_sites_v  pss
              ,fnd_lookup_values     flv
        WHERE  1 = 1
        AND    aila.invoice_id = aia.invoice_id
        AND    aila.po_header_id = pha.po_header_id
        AND    aila.po_line_id = plla.po_line_id
        AND    plla.line_location_id = aila.po_line_location_id
        AND    pha.po_header_id = aia.po_header_id
        AND    pha.po_header_id = pll.po_header_id
        AND    plla.po_line_id = pll.po_line_id
        AND    plla.po_header_id = pha.po_header_id
        AND    aia.invoice_id NOT IN
               (SELECT ahl.invoice_id
                 FROM   ap_holds_all ahl
                 WHERE  ahl.hold_lookup_code = flv.meaning)
        AND    plla.match_option = 'P'
        AND    plla.inspection_required_flag = 'N'
        AND    aia.payment_status_flag = 'N'
        AND    aia.org_id = ha.organization_id
        AND    aia.vendor_id = ps.vendor_id
        AND    aia.vendor_site_id = pss.vendor_site_id
        AND    pss.attribute3 = 'ASP - Hightened Risk'
        AND    flv.lookup_type = 'GED AP SUPPLIER HOLD LOOKUP'
        AND    flv.tag = 'ASP Quality'
        AND    flv.language = 'US'
        AND    flv.enabled_flag = 'Y'
        
         -- REL-021 added  below code
                AND ha.name NOT IN 
		(SELECT lookup_code
	           FROM FND_LOOKUP_VALUES
	          WHERE lookup_type ='CIRRUSAP_SO_ASPSUPPLIERHOLD_BU'
		    AND language='US'
		    AND TRUNC(SYSDATE) BETWEEN  NVL(start_date_active, TRUNC(SYSDATE))  AND  NVL(end_date_active, TRUNC(SYSDATE))
		)

         -- REL-021 added  Above code

        AND    SYSDATE BETWEEN nvl(flv.start_date_active, SYSDATE) AND
               nvl(flv.end_date_active, SYSDATE)
        AND    ((TRIM(:p_invoice_number) IS NOT NULL AND
              aia.invoice_num = TRIM(:p_invoice_number)) OR
              (TRIM(:p_invoice_number) IS NULL AND
              (((CAST(aia.last_update_date AS TIMESTAMP) >
              nvl(to_date(:p_start_time, 'YYYY-MM-DD hh24:mi:ss'),
                        (SELECT MAX(erh.processstart)
                          FROM   ess_request_history  erh
                                ,ess_request_property erp1
                          WHERE  erh.requestid = erp1.requestid
                          AND    erh.definition =
                                 'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                          AND    erh.executable_status = 'SUCCEEDED'
                          AND    erp1.name = 'submit.argument2'
                          AND    erp1.value IS NULL))) OR
              (NOT EXISTS
               (SELECT 1
                     FROM   ess_request_history
                     WHERE  definition =
                     'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                     AND    executable_status = 'SUCCEEDED'))) AND
              trunc(aia.last_update_date) <=
              nvl(to_date(:p_end_time, 'YYYY-MM-DD'), trunc(SYSDATE)))))
              
               -- REL-021 added  below code
              UNION
              
             
              
              SELECT aia.invoice_num AS inv_num
              ,'"' || ha.name || '",' || '"' || ps.segment1 || '",' || '"' ||
               ps.vendor_name || '",' || '"' || aia.invoice_num || '",' || '"' ||
               flv.meaning || '"' AS dataextract
        FROM   AP_INVOICES_ALL       aia
              ,AP_INVOICE_LINES_ALL  aila
              ,PO_HEADERS_ALL        pha
              ,PO_LINES_ALL          pll
              ,PO_LINE_LOCATIONS_ALL plla
              ,HR_OPERATING_UNITS    ha
              ,POZ_SUPPLIERS_V       ps
              ,POZ_SUPPLIER_SITES_V  pss
              ,FND_LOOKUP_VALUES     flv
        WHERE  1 = 1
        AND    aila.invoice_id = aia.invoice_id
        AND    aila.po_header_id = pha.po_header_id
        AND    aila.po_line_id = plla.po_line_id
        AND    plla.line_location_id = aila.po_line_location_id
        AND    pha.po_header_id = aia.po_header_id
        AND    pha.po_header_id = pll.po_header_id
        AND    plla.po_line_id = pll.po_line_id
        AND    plla.po_header_id = pha.po_header_id
        AND    aia.invoice_id NOT IN
               (SELECT ahl.invoice_id
                 FROM   AP_HOLDS_ALL ahl
                 WHERE  ahl.hold_lookup_code = flv.meaning)
        AND    plla.match_option = 'R'
        AND    plla.inspection_required_flag = 'N'
        AND    plla.receipt_required_flag = 'Y'
        AND    aia.payment_status_flag = 'N'
        AND    aia.org_id = ha.organization_id
        AND    aia.vendor_id = ps.vendor_id
        AND    aia.vendor_site_id = pss.vendor_site_id
        AND    pss.attribute3 IN
               ('ASP - Standard Risk', 'ASP - Hightened Risk')
        AND    flv.lookup_type = 'GED AP SUPPLIER HOLD LOOKUP'
        AND    flv.tag = 'ASP Receipt Confirmation'
        AND    flv.language = 'US'
        AND    flv.enabled_flag = 'Y'
        AND ha.name IN 
        (SELECT lookup_code
           FROM FND_LOOKUP_VALUES
          WHERE lookup_type ='CIRRUSAP_SO_ASPSUPPLIERHOLD_BU'
            AND language='US'
            AND TRUNC(SYSDATE) BETWEEN  NVL(start_date_active, TRUNC(SYSDATE))  AND  NVL(end_date_active, TRUNC(SYSDATE))
)
        AND    SYSDATE BETWEEN NVL(flv.start_date_active, SYSDATE) AND
               NVL(flv.end_date_active, SYSDATE)
        AND    ((TRIM(:p_invoice_number) IS NOT NULL AND
              aia.invoice_num = TRIM(:p_invoice_number)) OR
              (TRIM(:p_invoice_number) IS NULL AND
              (((CAST(aia.last_update_date AS TIMESTAMP) >
              NVL(TO_DATE(:p_start_time, 'YYYY-MM-DD hh24:mi:ss'),
                        (SELECT MAX(erh.processstart)
                          FROM   ESS_REQUEST_HISTORY  erh
                                ,ESS_REQUEST_PROPERTY erp1
                          WHERE  erh.requestid = erp1.requestid
                          AND    erh.definition =
                                 'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                          AND    erh.executable_status = 'SUCCEEDED'
                          AND    erp1.name = 'submit.argument2'
                          AND    erp1.value IS NULL))) OR
              (NOT EXISTS
               (SELECT 1
                     FROM   ESS_REQUEST_HISTORY
                     WHERE  definition =
                            'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                     AND    executable_status = 'SUCCEEDED'))) AND
              TRUNC(aia.last_update_date) <=
              NVL(TO_DATE(:p_end_time, 'YYYY-MM-DD'), TRUNC(SYSDATE)))))
                    UNION
        SELECT aia.invoice_num AS inv_num
              ,'"' || ha.name || '",' || '"' || ps.segment1 || '",' || '"' ||
               ps.vendor_name || '",' || '"' || aia.invoice_num || '",' || '"' ||
               flv.meaning || '"' AS dataextract
        FROM   AP_INVOICES_ALL       aia
              ,AP_INVOICE_LINES_ALL  aila
              ,PO_HEADERS_ALL        pha
              ,PO_LINES_ALL          pll
              ,PO_LINE_LOCATIONS_ALL plla
              ,HR_OPERATING_UNITS    ha
              ,POZ_SUPPLIERS_V       ps
              ,POZ_SUPPLIER_SITES_V  pss
              ,FND_LOOKUP_VALUES     flv
        WHERE  1 = 1
        AND    aila.invoice_id = aia.invoice_id
        AND    aila.po_header_id = pha.po_header_id
        AND    aila.po_line_id = plla.po_line_id
        AND    plla.line_location_id = aila.po_line_location_id
        AND    pha.po_header_id = aia.po_header_id
        AND    pha.po_header_id = pll.po_header_id
        AND    plla.po_line_id = pll.po_line_id
        AND    plla.po_header_id = pha.po_header_id
        AND    aia.invoice_id NOT IN
               (SELECT ahl.invoice_id
                 FROM   AP_HOLDS_ALL ahl
                 WHERE  ahl.hold_lookup_code = flv.meaning)
        AND    plla.match_option = 'R'
        AND    plla.inspection_required_flag = 'N'
        AND    aia.payment_status_flag = 'N'
        AND    aia.org_id = ha.organization_id
        AND    aia.vendor_id = ps.vendor_id
        AND    aia.vendor_site_id = pss.vendor_site_id
        AND    pss.attribute3 = 'ASP - Hightened Risk'
        AND    flv.lookup_type = 'GED AP SUPPLIER HOLD LOOKUP'
        AND    flv.tag = 'ASP Quality'
        AND    flv.language = 'US'
        AND    flv.enabled_flag = 'Y'
        AND ha.name IN 
        (SELECT lookup_code
           FROM FND_LOOKUP_VALUES
          WHERE lookup_type ='CIRRUSAP_SO_ASPSUPPLIERHOLD_BU'
            AND language='US'
            AND TRUNC(SYSDATE) BETWEEN  NVL(start_date_active, TRUNC(SYSDATE))  AND  NVL(end_date_active, TRUNC(SYSDATE))
)
        AND    SYSDATE BETWEEN NVL(flv.start_date_active, SYSDATE) AND
               NVL(flv.end_date_active, SYSDATE)
        AND    ((TRIM(:p_invoice_number) IS NOT NULL AND
              aia.invoice_num = TRIM(:p_invoice_number)) OR
              (TRIM(:p_invoice_number) IS NULL AND
              (((CAST(aia.last_update_date AS TIMESTAMP) >
              NVL(TO_DATE(:p_start_time, 'YYYY-MM-DD hh24:mi:ss'),
                        (SELECT MAX(erh.processstart)
                          FROM   ESS_REQUEST_HISTORY  erh
                                ,ESS_REQUEST_PROPERTY erp1
                          WHERE  erh.requestid = erp1.requestid
                          AND    erh.definition =
                                 'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                          AND    erh.executable_status = 'SUCCEEDED'
                          AND    erp1.name = 'submit.argument2'
                          AND    erp1.value IS NULL))) OR
              (NOT EXISTS
               (SELECT 1
                     FROM   ESS_REQUEST_HISTORY
                     WHERE  definition =
                     'JobDefinition://oracle/apps/ess/custom/GEDAPSupplierHold/GEDAPSupplierHold'
                     AND    executable_status = 'SUCCEEDED'))) AND
              TRUNC(aia.last_update_date) <=
              NVL(TO_DATE(:p_end_time, 'YYYY-MM-DD'), TRUNC(SYSDATE)))))
              
      -- REL-021 added  Above code         
              
        )
ORDER  BY inv_num)
UNION
SELECT 'XYZ' AS key
      ,' ' inv_num
      ,' ' dataextract
FROM   SYS.DUAL