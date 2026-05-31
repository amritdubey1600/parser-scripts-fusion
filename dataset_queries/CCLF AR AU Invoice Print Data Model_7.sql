select distinct account_number from hz_cust_accounts 
where exists (select 1 
                from hz_cust_acct_sites_all a1,
				hz_cust_site_uses_all b1,AR_REF_ACCOUNTS_ALL c1
				where a1.cust_Account_id = cust_Account_id
				and a1.cust_acct_site_id = b1.cust_acct_site_id
				and a1.set_id = b1.set_id
				 AND c1.SOURCE_REF_ACCOUNT_ID = b1.site_use_id
                AND c1.source_ref_table = 'HZ_CUST_SITE_USES_ALL'
                AND c1.bu_id = :p_business_unit)