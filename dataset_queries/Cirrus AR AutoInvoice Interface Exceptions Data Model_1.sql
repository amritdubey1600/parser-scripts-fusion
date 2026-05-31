select lin.interface_line_id, err.message_text, err.invalid_value, lin.creation_date, lin.INTERFACE_LINE_ATTRIBUTE1, 
lin.batch_source_name, lin.line_type, lin.amount, lin.cust_trx_type_name, hcab.account_number bill_customer, hcas.account_number ship_customer,
lin.trx_date, lin.gl_date, lin.trx_number, lin.request_id, lin.rule_start_date, lin.rule_end_date, lin.sales_order, lin.purchase_order, 
lin.tax_regime_code, lin.tax_rate, lin.recurring_bill_flag, lin.contract_start_date, lin.contract_end_date, hr.name bu_name 
from ra_interface_lines_all lin, ra_interface_errors_all err, hz_cust_accounts hcab, hz_cust_accounts hcas, hr_all_organization_units hr
where lin.interface_line_id = err.interface_line_id
and lin.org_id = err.org_id
and lin.ORIG_SYSTEM_BILL_CUSTOMER_ID = hcab.cust_account_id
and lin.ORIG_SYSTEM_SHIP_CUSTOMER_ID = hcas.cust_account_id (+)
and hr.organization_id = lin.org_id 
order by lin.trx_number, lin.trx_date, hr.name, lin.creation_date desc