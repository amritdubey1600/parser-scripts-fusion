/*--#-----------------------------------------------------------------------------------------------------------------#
--# TPS Monthly Title Transfer deatil data model
--# DESCRIPTION  : This data model query to fetch detail invoice level details for TPS monthly feed
--#                
--# CREATION DATE     :
--# CREATED BY      : 
--#
--# MODIFICATION HISTORY:
--# CR#                 Author            Date                  Description
--# REL-018	        Vijay Kochhar    28-JUN-2018		TPS Monthly Title Transfer deatil Data model
--# ---------------------------------------------------------------------------------------------------------------------
*/


SELECT  ps.segment1  vendor_no, 
        ps.vendor_name ,
        apa.invoice_num,
        apa.voucher_num,
        pha.segment1 PO_number,
        apa.invoice_date,
        apsa.due_date,
        apa.invoice_currency_code,
        (apa.invoice_amount * NVL(ROUND(apa.exchange_rate,3),1)) total,
        coco.meaning AS co_code,
      (SELECT end_date  
         FROM GL_PERIODS
         WHERE SYSDATE BETWEEN start_date AND end_date
         AND period_set_name = 'CCL CALENDAR') period_end_date,

(SELECT gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'|| gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7||'.'||gcc.segment8||'.'||gcc.segment9||'.'|| gcc.segment10||'.'||gcc.segment11 
 FROM GL_CODE_COMBINATIONS gcc WHERE gcc. code_combination_id IN ( SELECT dist_code_combination_id  FROM AP_INVOICE_DISTRIBUTIONS_all  WHERE invoice_id 
= apa.invoice_id
AND ROWNUM <2 )) coa,

(SELECT TO_CHAR(SYSDATE,'YYYYMMDD') FROM dual)  Rundate


FROM     AP_INVOICES_ALL apa 
        ,POZ_SUPPLIERS_V       ps
       
       ,PO_HEADERS_ALL        pha
       ,HR_OPERATING_UNITS    ha
       ----
       , AP_PAYMENT_SCHEDULES_ALL apsa
       , HR_ORGANIZATION_UNITS_F_TL fabu
       ,(SELECT  flv.meaning, xep.legal_entity_id 
               FROM   FND_LOOKUP_VALUES_VL flv,XLE_ENTITY_PROFILES xep
               WHERE flv.lookup_type = 'BUC LE MAPPING'
               AND  xep.name = flv.description
               AND   flv.enabled_flag = 'Y'
               AND   TRUNC (SYSDATE) BETWEEN NVL (flv.start_date_active,
                                                TRUNC (SYSDATE))
                                       AND NVL (flv.end_date_active,
                                                TRUNC (SYSDATE))) coco
WHERE apa.vendor_id = ps.vendor_id
AND pha.po_header_id (+) = apa.po_header_id 
AND apa.org_id = ha.organization_id
AND      apa.invoice_id = apsa.invoice_id
AND      apa.payment_status_flag <> 'Y'
AND      apa.wfapproval_status = 'WFAPPROVED'
AND      AP_INVOICES_UTILITY_PKG.GET_APPROVAL_STATUS( apa.invoice_id, NULL, NULL, NULL ) = 'APPROVED'
AND      apsa.discount_amount_available IS NOT NULL
AND      ( USERENV( 'LANG' ) ) = fabu.LANGUAGE
AND      apa.org_id = fabu.organization_id
AND      apa.creation_date BETWEEN fabu.effective_start_date AND fabu.effective_end_date
AND     fabu.name LIKE '%US%'
AND     apa.legal_entity_id = coco.legal_entity_id
ORDER BY  coco.meaning