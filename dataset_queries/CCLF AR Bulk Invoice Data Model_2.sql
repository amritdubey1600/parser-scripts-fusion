select rctl.QUANTITY_INVOICED qty_shipped,
          rctl.quantity_ordered,
          to_char(rctl.UNIT_SELLING_PRICE,fnd_currency.get_format_mask(rct.invoice_currency_code,40)) UNIT_SELLING_PRICE,
         to_char (rctl.extended_amount,fnd_currency.get_format_mask(rct.invoice_currency_code,40)) inv_amount ,
          RCTL.DESCRIPTION,
          RCTL.CUSTOMER_TRX_ID,
          RCTL.SALES_ORDER,
          rctl.sales_order_line,
          rctl.sales_order_date date_order_received,
          rctl.attribute6,
          rctl.attribute1 
from ra_customer_trx_lines_all rctl,
         ra_customer_trx_all rct
 where rct.customer_trx_id=rctl.customer_trx_id
And rctl. line_type='LINE'