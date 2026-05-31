SELECT
	   pol.line_num line_num,
       pol.item_description item_description,
       ROUND (pol.unit_price,2) line_price,
       pol.quantity line_quantity,
       ROUND (NVL(pol.amount,pol.unit_price *pol.quantity),2) line_amount,
       pol.line_status line_status,
       DECODE (
          pll.receipt_required_flag,
          'Y', DECODE (pll.inspection_required_flag,
                       'N', '3-Way',
                       'Y', '4-Way'),
          'N', '2-Way')
          Match_Approval_Level,
       TO_CHAR(pll.closed_for_receiving_date,'mm/dd/yyyy') closed_for_receiving_date,
       TO_CHAR(pll.closed_for_invoice_date,'mm/dd/yyyy') closed_for_invoice_date,
pod.pjc_project_id,
pol.po_header_id 
	  FROM 
	  PO_LINES_ALL pol,
      PO_LINE_LOCATIONS_ALL pll,
	  PO_DISTRIBUTIONS_ALL pod  
	  WHERE 
	   pol.po_line_id = pll.po_line_id
	   AND pol.po_header_id = pod.po_header_id
       AND pol.po_line_id = pod.po_line_id
       AND pol.po_line_id = pll.po_line_id