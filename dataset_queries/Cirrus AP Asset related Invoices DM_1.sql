SELECT DISTINCT hou.name bu_name,        
        aia.invoice_num invoice_number,         
        TO_CHAR(aia.invoice_date,'YYYY/MM/DD')  invoice_date,
        gcc.segment1 company_code,		
        gcc.segment1 ||'.'||gcc.segment2  ||'.'|| gcc.segment3  ||'.'|| gcc.segment4  ||'.'|| gcc.segment5 ||'.'|| gcc.segment6 ||'.'|| gcc.segment7 ||'.'|| gcc.segment8 ||'.'|| gcc.segment9 ||'.'|| gcc.segment10 ||'.'|| gcc.segment11 as asset_clearing_account,
		(SELECT pha.segment1
           FROM PO_HEADERS_ALL pha
		  WHERE pha.po_header_id = aila.po_header_id) as PO_NUMBER,
		(SELECT LISTAGG(a.requisition_number, ', ')WITHIN GROUP (ORDER BY a.requisition_number) FROM                                                                                                       (SELECT DISTINCT r.requisition_number
                                   FROM PO_DISTRIBUTIONS_ALL d,
                                        PO_HEADERS_ALL pha,
                                                                POR_REQ_DISTRIBUTIONS_ALL rd,
                                                                POR_REQUISITION_LINES_ALL rl,
                                                                POR_REQUISITION_HEADERS_ALL r
                                                WHERE pha.po_header_id = d.po_header_id
                                                  AND pha.po_header_id = aila.po_header_id
                                                  AND d.req_distribution_id = rd.distribution_id
                                                  AND rd.requisition_line_id = rl.requisition_line_id
                                                  AND rl.requisition_header_id = r.requisition_header_id) a) requisition_num,
   (SELECT LISTAGG(a.attribute1, ', ')WITHIN GROUP (ORDER BY a.attribute1) FROM 
        (SELECT DISTINCT rd.attribute1
		   FROM PO_DISTRIBUTIONS_ALL d,
		        PO_HEADERS_ALL pha,
                POR_REQ_DISTRIBUTIONS_ALL rd
          WHERE pha.po_header_id = d.po_header_id
		    AND pha.po_header_id = aila.po_header_id
            AND d.req_distribution_id = rd.distribution_id) a )appropriation_request_number       						          
FROM  AP_INVOICES_ALL aia,
      AP_INVOICE_LINES_ALL aila,
      AP_INVOICE_DISTRIBUTIONS_ALL aida,
      GL_CODE_COMBINATIONS gcc,
      HR_OPERATING_UNITS hou,      
	  XLA_AE_HEADERS xeh ,
	  XLA_EVENTS xe ,
      XLA_TRANSACTION_ENTITIES xte
WHERE 1=1
  AND aia.invoice_id  = aila.invoice_id
  AND aia.invoice_id = aida.invoice_id
  AND aila.line_number = aida.invoice_line_number
  AND aida.dist_code_combination_id = gcc.code_combination_id
  AND aia.org_id = hou.organization_id  
  AND ((EXISTS (SELECT 1 
                  FROM FA_CATEGORY_BOOKS fcb,
				       FA_CATEGORIES_B fcc,
					   GL_CODE_COMBINATIONS glcc
                WHERE fcb.category_id= fcc.category_id
                  AND fcb.asset_clearing_account_ccid =glcc.code_combination_id
                  AND glcc.segment2=gcc.segment2))
       OR
       aida.assets_tracking_flag  = 'Y')  
  AND xte.application_id          = 200
  AND xeh.application_id          = 200
  AND xe.application_id           = 200
  AND xe.entity_id                = xte.entity_id
  AND xe.event_id                 = xeh.event_id
  AND xte.entity_id               = xeh.entity_id  
  AND xte.ledger_id               = aia.set_of_books_id
  AND xte.entity_code             = 'AP_INVOICES'
  AND xeh.accounting_entry_status_code = 'F'
  AND AP_INVOICES_PKG.GET_POSTING_STATUS(aia.invoice_id) = 'Y'
  AND NVL(xte.source_id_int_1,-99)= aia.invoice_id
  AND (
       (:p_bu_name IS NOT NULL AND :p_from_date IS NOT NULL AND :p_to_date IS NOT NULL)
	    AND hou.name = :p_bu_name
		AND (aia.invoice_date BETWEEN :p_from_date AND :p_to_date)
	  OR
	   ((:p_bu_name IS NOT NULL AND :p_from_date IS NULL AND :p_to_date IS NULL)
	     AND hou.name = :p_bu_name)
	  OR
	   ((:p_bu_name IS NULL AND :p_from_date IS NOT NULL AND :p_to_date IS NOT NULL)
	     AND (aia.invoice_date BETWEEN :p_from_date AND :p_to_date))
	  OR
	   ((:p_bu_name IS NULL AND :p_from_date IS NULL AND :p_to_date IS NULL)
	     AND TO_CHAR(xeh.creation_date,'YYYY/MM/DD') = TO_CHAR(SYSDATE-1,'YYYY/MM/DD'))
	   )