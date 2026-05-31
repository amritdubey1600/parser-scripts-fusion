SELECT    
       to_char(sum(c.extended_amount),fnd_currency.get_format_mask(rct.invoice_currency_code,40))  
       tax_amount_f,  
rct.invoice_currency_code,
        sum(c.extended_amount)  tax_amount,    
       c.tax_rate            tax_rate,
       v.tax_rate_code        tax_code,
       trim(v.description) tax_rate_desc,
	   sum(c_line1.acctd_amount) fc_taxable_amount,
       sum(c1.acctd_amount) fc_tax_amount,
       z.tax_full_name        tax_name,
       c.sales_tax_id                tax_location_rate_id,
       c.tax_precedence        tax_precedence,
        to_char(sum(c_line.extended_amount),fnd_currency.get_format_mask(rct.invoice_currency_code,40))  
       taxable_amount_f,
       sum(c_line.extended_amount) taxable_amount,
(sum(c_line.extended_amount)+sum(c.extended_amount)) total,
to_char((sum(c_line.extended_amount)+sum(c.extended_amount)),fnd_currency.get_format_mask(rct.invoice_currency_code,40)) total_f,
       z.tax_registration_number tax_regn_no,
       c.customer_trx_id
FROM   ra_customer_trx_lines_all c,
     ra_cust_trx_line_gl_dist_all c1,
	  ra_cust_trx_line_gl_dist_all c_line1,
       zx_rates_vl v,
       ra_customer_trx_lines_all c_line,
       ra_customer_trx_all        rct,
       zx_lines_v z
where z.trx_line_id = c_line.customer_trx_line_id
and c_line.customer_trx_line_id = c_line1.customer_trx_line_id
and c_line1.account_class = 'REV'
and c.customer_trx_line_id = c1.customer_trx_line_id
and c1.account_class = 'TAX'
and    z.tax_line_id =  c.tax_line_id
and    c.vat_tax_id =  v.tax_rate_id(+)
and    c_line.customer_trx_line_id (+) = c.link_to_cust_trx_line_id
and    c.line_type = 'TAX'
AND    rct.customer_trx_id = c.customer_trx_id
AND    rct.complete_flag = 'Y'
AND   c1.ACCOUNT_SET_FLAG = 'N'
AND   c_line1.ACCOUNT_SET_FLAG = 'N'
group by    
    c.tax_rate,
    c.tax_exemption_id,
    c.sales_tax_id,v.description,
    c.tax_precedence,
    v.tax_rate_code,
    z.tax_full_name,
    rct.invoice_currency_code,
    z.tax_registration_number,
     c.customer_trx_id
order by z.tax_full_name,
               c.tax_precedence,
              c.tax_rate