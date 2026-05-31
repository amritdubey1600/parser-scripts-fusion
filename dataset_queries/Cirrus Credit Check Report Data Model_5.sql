SELECT DISTINCT poh.segment1 po_number,
                pov.vendor_name suppplier_name,
                pov.segment1 supplier_number,
                poh.currency_code currency_code,
                poh.DOCUMENT_STATUS po_status,
				poh.po_header_id po_header_id,
				p.Project_id,
				(SELECT SUM(ROUND (NVL(pol.amount,pol.unit_price *pol.quantity),2)) 
FROM PO_LINES_ALL pol, PO_DISTRIBUTIONS_ALL pod1
WHERE pol.po_header_id = poh.po_header_id 
AND   pol.po_line_id  =  pod1.po_line_id
AND   pol.po_header_id = pod1.po_header_id 
AND  pod1.pjc_project_id = p.project_id) po_amount
  FROM PJF_PROJECTS_ALL_VL p,
       PO_HEADERS_ALL poh,
       PO_DISTRIBUTIONS_ALL pod,
       POZ_SUPPLIERS_V pov
 WHERE     p.Project_id = pod.pjc_project_id
       AND poh.po_header_id = pod.po_header_id
       AND poh.vendor_id = pov.vendor_id
       AND p.segment1 = :P_Project_Num