select hr.name bu_name, trx.trx_class, trx.customer_trx_id, trx.trx_number, trx.creation_date, trx.trx_date, trx.request_id 
from ra_customer_trx_all trx, hr_all_organization_units hr  
where trx.request_id is not null 
and trx.complete_flag='F' 
and trx.created_from = 'RAXTRX'
and hr.organization_id = trx.org_id
order by trx.creation_date desc