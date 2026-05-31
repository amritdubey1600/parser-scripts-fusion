select
base.*,
to_char(rownum) as sequence_number
from
(SELECT   c.customer_trx_id customer_trx_id_line,         
          c.customer_trx_line_id customer_trx_line_id,         
      to_char(decode( c2.line_number, null, c.line_number, null)) line_number,         
      c.line_type line_type,         
          AR_BPA_UTILS_PKG.fn_get_line_description(c.customer_trx_line_id) line_description,
       decode(c.line_type, 'TAX', null, to_char(nvl(c.quantity_invoiced, c.quantity_credited))) quantity,        
       uom.unit_of_measure unit_of_measure_name,
       eitem.item_number item_number,
          --null unit_of_measure_name,
          to_char(c.unit_selling_price,fnd_currency.get_format_mask(trx.invoice_currency_code,40))
          unit_price,
          to_char(c.extended_amount,fnd_currency.get_format_mask(trx.invoice_currency_code,40))         
          extended_amount,
      c.sales_order            line_sales_order,
	  trx.invoice_currency_code,
      c.uom_code,
      --    null uom_code,
       trx.trx_number line_trx_number,                  
          decode(c.line_type, 'TAX', null, AR_INVOICE_SQL_FUNC_PUB.get_taxyn ( c.customer_trx_line_id ))
          tax_exists_for_this_line_flag,
          c.tax_rate    as line_tax_rate,
          --decode(c.line_type, 'TAX', v.tax_code, null) as line_tax_code,
          null line_tax_code,
          null printed_tax_name,
          --decode(c.line_type, 'TAX', v.printed_tax_name, null) as line_printed_tax_name,

 (SELECT party_site.PARTY_SITE_NAME 
          FROM hz_party_sites       party_site, 
                  hz_cust_site_uses_all   acct_uses  , 
                  hz_cust_acct_sites_all acct_site 
          WHERE party_site.party_site_id = acct_site.party_site_id 
          and acct_site.cust_acct_site_id = acct_uses.cust_acct_site_id 
          and acct_uses.site_use_id = c.ship_to_site_use_id ) ship_to_site_name,   --Bug: 18705899	 

          c.interface_line_attribute1,
          c.interface_line_attribute2,
          c.interface_line_attribute3,
          c.interface_line_attribute4,
          c.interface_line_attribute5,
          c.interface_line_attribute6,
          c.interface_line_attribute7,
          c.interface_line_attribute8,
          c.interface_line_attribute9,
          c.interface_line_attribute10,
          c.interface_line_attribute11,
          c.interface_line_attribute12,
          c.interface_line_attribute13,
          c.interface_line_attribute14,    
          c.interface_line_attribute15,
          to_char(c.unit_selling_price) unformatted_unit_price,
          to_char(nvl(c.extended_amount,0)) unformatted_extended_amount,
          c.ATTRIBUTE1,
          c.ATTRIBUTE2,
          c.ATTRIBUTE3,
          c.ATTRIBUTE4,
          c.ATTRIBUTE5,
          c.ATTRIBUTE6,
          c.ATTRIBUTE7,
          c.ATTRIBUTE8,
          c.ATTRIBUTE9,
          c.ATTRIBUTE10,
          c.ATTRIBUTE11,
          c.ATTRIBUTE12,
          c.ATTRIBUTE13,
          c.ATTRIBUTE14,
          c.ATTRIBUTE15,
          c.SET_OF_BOOKS_ID,
          c.REASON_CODE,
          c.QUANTITY_ORDERED,
          c.QUANTITY_CREDITED,
          c.UNIT_STANDARD_PRICE,
          c.SALES_ORDER_LINE,
          c.SALES_ORDER_DATE,
          c.ACCOUNTING_RULE_DURATION,
          c.ATTRIBUTE_CATEGORY,
          c.RULE_START_DATE,
          to_char(c.billing_period_start_date,'YYYY-MM-DD')  billing_period_start_date,
          to_char(c.billing_period_end_date,'YYYY-MM-DD')  billing_period_end_date,
          c.INTERFACE_LINE_CONTEXT,
          c.SALES_ORDER_SOURCE,
          c.REVENUE_AMOUNT,
          c.DEFAULT_USSGL_TRANSACTION_CODE,
          c.DEFAULT_USSGL_TRX_CODE_CONTEXT,
          c.LAST_PERIOD_TO_CREDIT,
          c.ITEM_CONTEXT,
          c.TAX_EXEMPT_FLAG,
          c.TAX_EXEMPT_NUMBER,
          c.TAX_EXEMPT_REASON_CODE,
          c.TAX_VENDOR_RETURN_CODE,
          c.GLOBAL_ATTRIBUTE_CATEGORY,
          c.GROSS_UNIT_SELLING_PRICE,
          c.GROSS_EXTENDED_AMOUNT,
          c.EXTENDED_ACCTD_AMOUNT,
          c.MRC_EXTENDED_ACCTD_AMOUNT,
          c.ORG_ID line_org_id,
          c.GLOBAL_ATTRIBUTE1,
          c.GLOBAL_ATTRIBUTE2,
          c.GLOBAL_ATTRIBUTE3,
          c.GLOBAL_ATTRIBUTE4,
          c.GLOBAL_ATTRIBUTE5,
          c.GLOBAL_ATTRIBUTE6,
          c.GLOBAL_ATTRIBUTE7,
          c.GLOBAL_ATTRIBUTE8,
          c.GLOBAL_ATTRIBUTE9,
          c.GLOBAL_ATTRIBUTE10,
          c.GLOBAL_ATTRIBUTE11,
          c.GLOBAL_ATTRIBUTE12,
          c.GLOBAL_ATTRIBUTE13,
          c.GLOBAL_ATTRIBUTE14,
          c.GLOBAL_ATTRIBUTE15,
          c.GLOBAL_ATTRIBUTE16,
          c.GLOBAL_ATTRIBUTE17,
          c.GLOBAL_ATTRIBUTE18,
          c.GLOBAL_ATTRIBUTE19,
          c.GLOBAL_ATTRIBUTE20
		  ,(select b1.description 
FROM zx_lines_v a1, zx_rates_vl b1
       WHERE a1.tax_rate_id = b1.tax_rate_id
                and a1.trx_id = c.customer_trx_id
and a1.trx_line_id = c.customer_trx_line_id
and rownum <=1
) tax_rate_desc
          ,(SELECT SUM(NVL(a1.extended_amount,0))
              FROM ra_customer_trx_lines_all a1
             WHERE c.customer_trx_line_id = a1.link_to_cust_trx_line_id
                             AND a1.line_type= 'TAX'
                     ) line_tax_amount
from      ra_customer_trx_lines_all   c,             
      ra_customer_trx_lines_all  c2,             
      inv_units_of_measure_vl    uom,
          ra_customer_trx_all        trx,
      egp_system_items_b         eitem,
      ar_system_parameters_all   sysp	  
      --ar_vat_tax_all_vl          v
where     c.customer_trx_id = :customer_trx_id
AND        trx.customer_trx_id = c.customer_trx_id
AND      trx.org_id = c.org_id
AND        trx.complete_flag = 'Y'
and       c.link_to_cust_trx_line_id     = c2.customer_trx_line_id(+)
and       c.org_id                = c2.org_id(+)
and       c.uom_code                            = uom.uom_code(+)
and       c.inventory_item_id = eitem.inventory_item_id (+)
and       c.org_id = sysp.org_id
and       ( (c.inventory_item_id is not null
             and sysp.item_validation_org_id = eitem.organization_id)
          or c.inventory_item_id is null) 
--and      c.vat_tax_id =  v.vat_tax_id(+)
--and       c.org_id     = v.org_id(+)
--and         c.line_type in ('LINE', 'TAX', 'CB')
&WHERE_LINE_TYPE
order by   
                 decode( c2.line_number,
                                null, decode( c.line_type,
                                                        'LINE', c.line_number*10000+0,
                                                        'TAX',  c.line_number*10000+8000,
                                                                    100000000000),
                              decode( c2.line_type,
                                              'LINE', c2.line_number*10000+0,
                                              'TAX',  c2.line_number*10000+8000,
                                                         c2.line_number*10000+9000) +
                                  decode( c.line_type,
                                                 'LINE',          0, 'CB',          0,
                                                  'TAX',          8000,
                                                 'FREIGHT',  9000)  +
                                  c.line_number )) base