select hzp.party_name, hca.account_number, hca.customer_type, hcsu.site_use_code, hcsu.location
from hz_parties hzp, hz_cust_accounts hca, hz_cust_site_uses_all hcsu, hz_cust_acct_sites_all hcas
where hca.cust_account_id = hcas.cust_account_id
and hzp.party_id = hca.party_id
and hcsu.cust_acct_site_id = hcas.cust_acct_site_id
and hcsu.site_use_code = 'BILL_TO'