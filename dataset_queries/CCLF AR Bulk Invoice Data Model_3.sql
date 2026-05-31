SELECT    
       to_char(sum(c.extended_amount),fnd_currency.get_format_mask(rct.invoice_currency_code,40))  
       tax_amount,       
       c.tax_rate            tax_rate,
       v.tax_rate_code        tax_code,
       z.tax_full_name        tax_name,
       lkp.meaning      tax_inclusive_flag,
       c.sales_tax_id                tax_location_rate_id,
       c.tax_precedence        tax_precedence,
        to_char(sum(c_line.extended_amount),fnd_currency.get_format_mask(rct.invoice_currency_code,40))  
       euro_taxable_amount,
       z.tax_registration_number tax_regn_no,
       c.customer_trx_id
FROM   ra_customer_trx_lines_all c,
       zx_rates_vl v,
       ra_customer_trx_lines_all c_line,
       ar_lookups lkp,
       ra_customer_trx_all        rct,
       zx_lines_v z
where z.trx_line_id = c_line.customer_trx_line_id
and    z.tax_line_id =  c.tax_line_id
and    c.vat_tax_id =  v.tax_rate_id(+)
and    c_line.customer_trx_line_id (+) = c.link_to_cust_trx_line_id
and    c.line_type = 'TAX'
and    lkp.lookup_type = 'YES/NO'
and    lkp.lookup_code = nvl(c.amount_includes_tax_flag,'N')
AND    rct.customer_trx_id = c.customer_trx_id
AND    rct.complete_flag = 'Y'
group by    
    c.tax_rate,
    c.tax_exemption_id,
    c.sales_tax_id,
    lkp.meaning,
    c.tax_precedence,
    v.tax_rate_code,
    z.tax_full_name,
    rct.invoice_currency_code,
    z.tax_registration_number,
     c.customer_trx_id
order by z.tax_full_name,
               c.tax_precedence,
              c.tax_rate