SELECT 	SUM (NVL(ar.amount_applied,0) ) SUM_PAID_AMOUNT
         FROM OKC_K_HEADERS_VL okh,
         HZ_CUST_ACCOUNTS hcab,
         PJB_INVOICE_HEADERS pih,
         PJB_INVOICE_LINES pil,
         PJB_INV_LINE_DISTS pid,	
         AR_PAYMENT_SCHEDULES_ALL ar,
         PJF_PROJECTS_ALL_VL p
   WHERE     pih.bill_to_cust_acct_id = hcab.cust_account_id
         AND pih.contract_id = okh.ID
         AND ar.customer_trx_id = pih.system_reference
         AND pih.invoice_id = pil.invoice_id
         AND (okh.major_version =
                 PJB_BILLING_UTILS.GET_CNTRCT_MAJOR_VERSION ('INV_PREVIEW',
                                                             okh.id))
AND      pid.contract_id = pih.contract_id
AND      pid.invoice_id = pih.invoice_id
AND      pil.invoice_line_id = 	pid.invoice_line_id
AND      p.project_id = pid.transaction_project_id 
AND 	 p.segment1 =  :p_project_Num
AND      pih.transfer_status_code = 'A'