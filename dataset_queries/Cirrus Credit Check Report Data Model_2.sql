SELECT hcab.account_name Customer,
	 pih.invoice_num,
	 pih.ra_invoice_number,
         hcab.account_number Customer_number,
         okh.contract_number,
         okh.cognomen contract_name,
         ar.invoice_currency_code,
         SUM (okh.estimated_amount) contract_amount,
         SUM (NVL(ar.amount_applied,0) )amount_applied,
         SUM (
            TO_CHAR (
                 NVL (NVL (ar.amount_applied, 0) * 100, 0)
               / (okh.estimated_amount),
               fnd_currency.get_format_mask (ar.invoice_currency_code, 40)))
            Rate,
(SELECT TO_CHAR (MAX(acr.receipt_date),'MM/DD/YYYY')
FROM AR_RECEIVABLE_APPLICATIONS_ALL ara, 
AR_CASH_RECEIPTS_ALL acr, 
RA_CUSTOMER_TRX_ALL rct 
WHERE ara.STATUS='APP' 
AND ara.cash_receipt_id=acr.cash_receipt_id 
AND ara.applied_customer_trx_id=rct.customer_trx_id
AND rct.trx_number = pih.ra_invoice_number) apply_date,
TO_CHAR(ar.trx_date ,'MM/DD/YYYY')  invoice_date,
SUM(pil.inv_curr_line_amt) invoice_amount
    FROM OKC_K_HEADERS_VL okh,
         HZ_CUST_ACCOUNTS hcab,
         PJB_INVOICE_HEADERS pih,
         PJB_INVOICE_LINES pil,
         PJB_INV_LINE_DISTS pid,	
         AR_PAYMENT_SCHEDULES_ALL ar,
         PJF_PROJECTS_ALL_VL p
   WHERE     pih.bill_to_cust_acct_id = hcab.CUST_ACCOUNT_ID
         AND pih.contract_id = okh.ID
         AND ar.customer_trx_id = pih.system_reference
         AND pih.invoice_id = pil.invoice_id
         AND (OKH.MAJOR_VERSION =
                 pjb_billing_utils.GET_CNTRCT_MAJOR_VERSION ('INV_PREVIEW',
                                                             OKH.ID))
AND      pid.contract_id = pih.contract_id
AND      pid.invoice_id = pih.invoice_id
AND      pil.invoice_line_id = 	pid.invoice_line_id
AND      p.project_id = pid.transaction_project_id 
AND 	 p.segment1 =  :p_project_Num
AND      pih.transfer_status_code = 'A'
GROUP BY hcab.account_name,
         hcab.account_number,
         okh.contract_number,
         okh.cognomen,
         ar.invoice_currency_code,
         pih.invoice_num,
         pih.ra_invoice_number,
         ar.trx_date