SELECT 
SUM (ROUND (NVL (pol.amount, pol.unit_price * pol.quantity), 2)) project_po_amount
  FROM PO_LINES_ALL pol, 
  PJF_PROJECTS_ALL_VL p, 
  PO_DISTRIBUTIONS_ALL pod
 WHERE    pol.po_header_id = pod.po_header_id
       AND pol.po_line_id = pod.po_line_id
	   AND pod.pjc_project_id = p.project_id
	   AND p.segment1 = :P_Project_Num
GROUP BY pod.pjc_project_id