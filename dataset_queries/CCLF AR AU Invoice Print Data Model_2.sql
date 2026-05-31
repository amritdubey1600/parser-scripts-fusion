select case 
             when rct.trx_class = 'CM' then rctl.quantity_credited
                   else rctl.quantity_invoiced 
                end qty_invoiced
      ,  case 
             when rct.trx_class = 'CM' then 
             to_char(rctl.quantity_credited,fnd_currency.get_format_mask(rct.invoice_currency_code,40))
               else 
               to_char(rctl.quantity_invoiced, fnd_currency.get_format_mask(rct.invoice_currency_code,40))
                end qty_invoiced_f
          ,rctl.line_number
          ,rctl.quantity_ordered
,rctl.QUANTITY_CREDITED 
,rctl.UNIT_SELLING_PRICE
 ,to_char(rctl.UNIT_SELLING_PRICE,fnd_currency.get_format_mask(rct.invoice_currency_code,40)) UNIT_SELLING_PRICE_F 
,rctl.ATTRIBUTE_CATEGORY
,rctl.attribute1 attribute1
,RTRIM(LTRIM(rctl.attribute7||'-'||rctl.attribute1||'-'||rctl.attribute2||'-'||rctl.attribute3||'-'||rctl.attribute4||'-'||rctl.attribute5,'-'),'-') other_line_ref
,rct.invoice_currency_code
,rctl.attribute7
,rctl.attribute2
,rctl.attribute3
,rctl.attribute4
,rctl.attribute5
         ,rctl.extended_amount line_ext_amount 
		 ,(select sum(ACCTD_AMOUNT) 
from RA_CUST_TRX_LINE_GL_DIST_ALL a2
where a2.customer_trx_line_id = rctl.customer_trx_line_id
and a2.account_class = 'REV') fc_line_ext_amount
         ,to_char(rctl.extended_amount,fnd_currency.get_format_mask(rct.invoice_currency_code,40)) line_ext_amount_f
          ,RCTL.CUSTOMER_TRX_ID
          ,RCTL.SALES_ORDER
          ,rctl.sales_order_line
          ,rctl.sales_order_date date_order_received
          ,(SELECT UNIT_OF_MEASURE 
             FROM INV_UNITS_OF_MEASURE_TL a1,
                  INV_UNITS_OF_MEASURE_B b1
             WHERE a1.unit_of_measure_id = b1.unit_of_measure_id
               AND b1.uom_code = rctl.uom_code
               and language = 'US') uom
          ,(SELECT tax_full_name FROM zx_lines_v 
             WHERE trx_id = rct.customer_trx_id
             and trx_line_id = rctl.customer_trx_line_id
and rownum = 1) tax_name
,(select b1.description 
FROM zx_lines_v a1, zx_rates_vl b1
                WHERE a1.tax_rate_id = b1.tax_rate_id
                and a1.trx_id = rctl.customer_trx_id
and a1.trx_line_id = rctl.customer_trx_line_id
and rownum <=1
) tax_rate_desc
          ,(SELECT SUM(NVL(a1.extended_amount,0))
              FROM ra_customer_trx_lines_all a1
             WHERE rctl.customer_trx_line_id = a1.link_to_cust_trx_line_id
                             AND a1.line_type= 'TAX'
                     ) line_tax_amount
,(select sum(a2.ACCTD_AMOUNT) 
from RA_CUSTOMER_TRX_LINES_ALL a1,
RA_CUST_TRX_LINE_GL_DIST_ALL a2
where 1=1
and a1.customer_trx_line_id = a2.customer_trx_line_id
and a1.link_to_cust_trx_line_id=rctl.customer_trx_line_id
and a1.line_type = 'TAX'
and a2.account_class = 'TAX') fc_line_tax_amount					 
        ,(select to_char(NVL((SELECT SUM(a1.extended_amount)
              FROM ra_customer_trx_lines_all a1
             WHERE rctl.customer_trx_line_id = a1.link_to_cust_trx_line_id
                             AND a1.line_type= 'TAX'
                     ),0),fnd_currency.get_format_mask(rct.invoice_currency_code,40)) from dual) line_tax_amount_f,
-- Added For MVP 2.5
(SELECT fle.attribute_char8  
FROM 
doo_fulfill_lines_all fl,
doo_fulfill_lines_eff_b fle
WHERE 
fle.fulfill_line_id =  fl.fulfill_line_id
AND to_char(fl.fulfill_line_id)=rctl.interface_line_attribute5
AND fle.context_code='GED Fline Context'
AND ROWNUM <=1) Incoterms,
NVL((SELECT LTRIM(dff.attribute_char4||'-'||attribute_char13,'-')
                 FROM 
doo_headers_all doh,
doo_lines_all dol,
doo_fulfill_lines_all dof,
doo_fulfill_lines_eff_b dff
-- Commented as per REL- 006 WHERE TO_CHAR(doh.order_number)=rct.ct_reference
WHERE to_char(dof.fulfill_line_id)=rctl.interface_line_attribute5 -- Added as per REL- 006
AND doh.org_id = rct.org_id
AND doh.header_id = dol.header_id
AND dof.line_id = dol.line_id
AND dof.header_id = doh.HEADER_ID
AND dof.fulfill_line_id = dff.fulfill_line_id
AND dff.context_code='GED Fline Context'
AND dol.inventory_item_id = rctl.inventory_item_id
AND doh.status_code <>'DOO_REFERENCE'
AND ROWNUM <=1)
		      ,LTRIM(( SELECT a.item_number 
               FROM egp_system_items a
             WHERE a.inventory_item_id = rctl.inventory_item_id
            AND ROWNUM<=1)||'-'||rctl.description)) DESCRIPTION 
-- End of Addition For MVP 2.5 	
from ra_customer_trx_lines_all rctl,
         ra_customer_trx_all rct
 where rct.customer_trx_id=rctl.customer_trx_id
And rctl. line_type='LINE'
order by rctl.line_number asc