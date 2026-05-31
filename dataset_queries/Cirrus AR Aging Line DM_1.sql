select pay.amount_due_original, pay.amount_due_remaining, lin.line_number, lin.description, lin.line_type, trx.trx_number, trx.trx_date
, ou.name, pay.due_date, hzp.party_name
from ar_payment_schedules_all pay, ra_customer_trx_all trx, ra_customer_Trx_lines_all lin, hr_all_organization_units ou, hz_parties hzp, hz_cust_accounts hca
where pay.customer_trx_id = trx.customer_trx_id
and trx.customer_Trx_id = lin.customer_trx_id
and lin.org_id = pay.org_id
and ou.organization_id = lin.org_id
and ou.name like '%MR%'
and trx.BILL_TO_CUSTOMER_ID = hca.cust_account_id
and hzp.party_id = hca.party_id