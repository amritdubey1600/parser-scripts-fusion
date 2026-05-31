SELECT DISTINCT
       aia.invoice_num,
       pos.segment1 supplier_number,
       hp.party_name supplier_name,
       p.segment1 Project_Number,
       poh.segment1 PO_Number,
       CASE
          WHEN pol.quantity IS NULL
          THEN
             --ROUND (NVL (pol.amount,0),2)
             (  SELECT ROUND (SUM (NVL (pol.amount, 0)), 2)
                  FROM PO_LINES_ALL pola
                 WHERE     pola.po_header_id = poh.po_header_id
                       AND pola.po_line_id = pol.po_line_id
              GROUP BY pola.po_header_id)
          ELSE
             --ROUND (NVL (pol.unit_price * pol.quantity, 0), 2)
             (  SELECT ROUND (SUM (NVL (pol.unit_price * pol.quantity, 0)), 2)
                  FROM PO_LINES_ALL pola
                 WHERE     pola.po_header_id = poh.po_header_id
                       AND pola.po_line_id = pol.po_line_id
              GROUP BY pola.po_header_id)
       END
          po_amount,
       aia.invoice_currency_code Currency,
       ROUND (NVL (aia.invoice_amount, 0), 2) invoice_amount,
       ROUND (NVL (aia.amount_paid, 0), 2) amount_paid,
       ROUND (
          (  SELECT SUM (apa.invoice_amount)
               FROM AP_INVOICES_ALL apa
              WHERE apa.invoice_id IN
                       (SELECT DISTINCT aill.invoice_id
                          FROM AP_INVOICE_DISTRIBUTIONS_ALL aill
                         WHERE     aill.pjc_project_id = p.project_id
                               AND aia.vendor_id = apa.vendor_id)
           GROUP BY aia.vendor_id),
          2)
          total_invoice_amount,
       aia.invoice_id,
       ROUND (NVL (aia.amount_paid * 100 / aia.invoice_amount, 0), 2)
          PAYMENT_PERCENTAGE,
       TO_CHAR (apsa.due_date, 'MM//DD/YYYY') due_date,
       ROUND (NVL (aia.total_tax_amount, 0), 2) tax_amount,
       ROUND (NVL (aia.invoice_amount - aia.total_tax_amount, 0), 2)
          net_amount
  FROM AP_INVOICE_LINES_ALL ail,
       AP_INVOICES_ALL aia,
       AP_INVOICE_DISTRIBUTIONS_ALL aid,
       AP_PAYMENT_SCHEDULES_ALL apsa,
       POZ_SUPPLIERS pos,
       HZ_PARTIES hp,
       PJF_PROJECTS_ALL_VL p,
       PO_HEADERS_ALL poh,
       PO_LINES_ALL pol,
       PO_DISTRIBUTIONS_ALL pod
 WHERE     aia.invoice_id = ail.invoice_id
       AND aia.invoice_id = aid.invoice_id
       AND ail.line_number = aid.invoice_line_number
       AND aia.invoice_id = apsa.invoice_id
       AND poh.po_header_id(+) = pol.po_header_id
       AND pol.po_header_id(+) = pod.po_header_id
       AND pol.po_line_id(+) = pod.po_line_id
       AND pod.po_distribution_id(+) = aid.po_distribution_id
       AND aia.vendor_id = pos.vendor_id
       AND pos.party_id = hp.party_id
       AND aid.pjc_project_id = p.project_id
       --AND pod.pjc_project_id = p.Project_id
       AND p.segment1 = :P_Project_num