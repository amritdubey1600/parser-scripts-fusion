--#-----------------------------------------------------------------------------------------------------# 
--# MODIFICATION HISTORY: 
--# CR#                       Author             Date                Description 
--#------------------------------------------------------------------------------------------------------# 
--# REL-081                   Damoder Ch        14-Sep-2023            Japan Invoice Print Report                                                       Initial Version-Invoice print Japan Report --#   
--#------------------------------------------------------------------------------------------------------#
SELECT hou.name "Business Unit" ,
rcta.TRX_NUMBER "Transaction Number"
,TO_CHAR(rcta.TRX_DATE,'MM-DD-YYYY')   "Transaction Date"
,rcta.trx_class "Transaction Class"
,zlv.tax_rate "Tax Rate"
,TO_CHAR(zlv.tax_amt,fnd_currency.get_format_mask (rcta.invoice_currency_code, 40)) "Total Tax Amount" 
,TRUNC(rctl.taxable_amount*zlv.tax_rate*0.01 ) "Expected Tax Amount"
,(TRUNC(rctl.taxable_amount*zlv.tax_rate*0.01) - TO_CHAR(zlv.tax_amt,fnd_currency.get_format_mask (rcta.invoice_currency_code, 40))) "Tax Amount Difference" 
FROM 
  ra_customer_trx_all rcta
 -- ,ra_customer_trx_lines_all  rctl
  ,(SELECT sum(rctla.taxable_amount) taxable_amount,rctla.customer_trx_id,rctla.tax_rate 
    FROM  ra_customer_trx_lines_all rctla
    WHERE 1=1 and rctla.line_type = 'TAX'
              GROUP BY rctla.customer_trx_id,rctla.tax_rate 
			  ) rctl
  ,HR_ORGANIZATION_UNITS hou
  ,(SELECT NVL(SUM(zlv.tax_amt),0) tax_amt,
                               zlv.trx_id,
                               zlv.tax_rate
                              						   
    FROM zx_lines_v zlv
              WHERE zlv.APPLICATION_ID = 222  -- In some Invoices/CM application ID is NULL so hard coding to 222 which is for Receivables Added by MEHUL
              GROUP BY zlv.trx_id,
                                  zlv.tax_rate) zlv
	,(SELECT customer_trx_id,
       SUM(amount_due_remaining) amount_due_remaining
  FROM ar_payment_schedules_all
WHERE 1 = 1
GROUP BY customer_trx_id
) psa							  
  WHERE rcta.customer_trx_id    = rctl.customer_trx_id
  AND hou.organization_id       = rcta.org_id
  AND zlv.trx_id                = rcta.customer_trx_id
  and zlv.tax_rate = rctl.tax_rate
  AND   rcta.complete_flag = 'Y'
  AND  hou.name  = :P_Business_Unit
  AND rcta.trx_number = NVL(:P_trx_number , rcta.trx_number )
  AND TRUNC (rcta.trx_date) BETWEEN NVL(:P_trx_start_date , rcta.trx_date ) AND NVL(:P_trx_end_date , rcta.trx_date )
  AND psa.customer_trx_id = rcta.customer_trx_id
  AND DECODE(psa.amount_due_remaining,'0','CLOSE','OPEN') = NVL(:P_Staus ,DECODE(psa.amount_due_remaining,'0','CLOSE','OPEN'))