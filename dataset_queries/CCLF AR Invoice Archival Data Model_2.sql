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
		   --- aadded by Vijay
		  , TO_CHAR (DECODE (rctl2.line_number, NULL, rctl.line_number, NULL))
                    line_number,
					rctl.line_type line_type,
                 AR_BPA_UTILS_PKG.fn_get_line_description (
                    rctl.customer_trx_line_id)
                    line_description,
                 DECODE (
                    rctl.line_type,
                    'TAX', NULL,
                    TO_CHAR (NVL (rctl.quantity_invoiced, rctl.quantity_credited)))
                    quantity,
                 uom.unit_of_measure unit_of_measure_name,
                 NVL(eitem.item_number,AR_BPA_UTILS_PKG.fn_get_line_description (
                    rctl.customer_trx_line_id)) item_number,
					 TO_CHAR (
                    (SELECT SUM(NVL (zlv.tax_amt, 0))
                       FROM zx_lines_v zlv
                      WHERE zlv.trx_line_id = rctl.customer_trx_line_id),
                    fnd_currency.get_format_mask (rct.invoice_currency_code,
                                                  40))
                    line_tax_amount,
                 TO_CHAR (
                    NVL((SELECT SUM(NVL( zlv.tax_amt, 0))
                       FROM zx_lines_v zlv
                      WHERE zlv.trx_line_id = rctl.customer_trx_line_id),0) + NVL (rctl.extended_amount, 0),
                    fnd_currency.get_format_mask (rct.invoice_currency_code,
                                                  40))
                    line_gross_amount,  
					rctl.uom_code,
					bu_name,
gst_hst.tax_rate_gst_hst_line,
                 gst_hst.tax_amount_gst_hst_line,
                 pst.tax_rate_pst_line,
                 pst.tax_amount_pst_line
from ra_customer_trx_lines_all rctl,
         ra_customer_trx_all rct
		 ---  added by vijay
		 ,  ra_customer_trx_lines_all rctl2,
                inv_units_of_measure_vl uom,
               egp_system_items_b eitem,
                 ar_system_parameters_all sysp,
      (SELECT SUM(TAX_RATE) tax_rate_gst_hst_line,
               SUM(UNROUNDED_TAX_AMT) tax_amount_gst_hst_line,
               TRX_ID,
               TRX_LINE_ID               
          FROM zx_lines_v 
         WHERE (UPPER(TAX_REGIME_NAME) LIKE '%GST%' OR UPPER(TAX_REGIME_NAME) LIKE '%HST%')
         GROUP BY trx_id,trx_line_id) gst_hst,
       (SELECT SUM(TAX_RATE) tax_rate_pst_line,
               SUM(UNROUNDED_TAX_AMT) tax_amount_pst_line,
               TRX_ID,
               TRX_LINE_ID               
          FROM zx_lines_v 
         WHERE (UPPER(TAX_REGIME_NAME) LIKE '%PST%')
         GROUP BY trx_id,trx_line_id) pst 
		, hr_all_organization_units ha
		,fun_all_business_units_v fab
		 -- end here 
 where rct.customer_trx_id=rctl.customer_trx_id
 
 --  added by vijay
 And   decode ( bu_name, 'CA_CAD_BU', rctl.line_type, 'LINE') ='LINE'

-----and rct.trx_number='11002100000042'
AND pst.trx_id(+)                       = rctl.customer_trx_id
                 AND pst.TRX_LINE_ID(+)                  = rctl.customer_trx_line_id
                 AND gst_hst.trx_id(+)                   = rctl.customer_trx_id     
                 AND gst_hst.TRX_LINE_ID(+)              = rctl.customer_trx_line_id  
	AND rctl.uom_code = uom.uom_code(+)
                 AND rctl.inventory_item_id = eitem.inventory_item_id(+)
                 AND rctl.org_id = sysp.org_id
                 AND (   (    rctl.inventory_item_id IS NOT NULL
                          AND sysp.item_validation_org_id =
                                 eitem.organization_id)
                      OR rctl.inventory_item_id IS NULL)	
AND rct.org_id = rctl.org_id
                 AND rct.complete_flag = 'Y'
                 AND rctl.link_to_cust_trx_line_id = rctl2.customer_trx_line_id(+)
                 AND rctl.org_id = rctl2.org_id(+)		
				 AND rct.org_id=ha.organization_id
				 and fab.BU_ID =ha.organization_id
and rctl.line_type = 'LINE'
ORDER BY DECODE (
                    rctl2.line_number,
                    NULL, DECODE (rctl.line_type,
                                  'LINE', rctl.line_number * 10000 + 0,
                                  'TAX', rctl.line_number * 10000 + 8000,
                                  100000000000),
                      DECODE (rctl2.line_type,
                              'LINE', rctl2.line_number * 10000 + 0,
                              'TAX', rctl2.line_number * 10000 + 8000,
                              rctl2.line_number * 10000 + 9000)
                    + DECODE (rctl.line_type,
                              'LINE', 0,
                              'CB', 0,
                              'TAX', 8000,
                              'FREIGHT', 9000)
                    + rctl.line_number)