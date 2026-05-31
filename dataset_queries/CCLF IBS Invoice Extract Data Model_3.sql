SELECT  'I13' record_key_i13,
	 RPAD(UPPER(SUBSTR(h.address1||' ' ||
	 h.address2||' ' ||
	 h.address3||' ' ||
	 h.address4 ,1,30)),30) ship_to_address,
	 'I14' record_key_i14,
	  RPAD(UPPER(h.city),19) ship_to_city,
	  RPAD(UPPER(h.state),2) ship_to_state,
	  RPAD(UPPER(h.postal_code),9) ship_to_zip,
	  RPAD(UPPER(i.territory_short_name),3) ship_to_country,
	  f.site_use_id
FROM 	hz_parties a,
	hz_cust_accounts b,
        fnd_lookup_values c,
        hz_cust_acct_sites_all d,
        hz_party_sites e,
        hz_cust_site_uses_all f,
        hz_locations h,
        fnd_territories_tl i
WHERE 1=1
AND a.party_id = b.party_id
AND c.lookup_code = b.customer_type
AND c.LANGUAGE = 'US'
AND c.lookup_type = 'CUSTOMER_TYPE'
AND b.cust_account_id = d.cust_account_id
AND d.party_site_id = e.party_site_id
AND d.cust_acct_site_id = f.cust_acct_site_id
AND e.location_id = h.location_id
AND h.country = i.territory_code
AND i.LANGUAGE = 'US'
AND f.site_use_code = 'SHIP_TO'