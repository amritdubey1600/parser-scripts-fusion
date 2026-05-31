SELECT  SUM(a.vat_thb),
		SUM(a.amount_before_vat_thb)
				FROM 
				(
				SELECT	DISTINCT		
				(CASE WHEN ap.invoice_currency_code = 'THB'
				THEN
				SUM(tax.tax_amt)
				ELSE
				SUM(ap.attribute_number1)
				END) 													AS vat_thb
				,(CASE WHEN ap.invoice_currency_code = 'THB'
				THEN
				SUM(tax.line_amt)
				ELSE
				SUM(ap.attribute_number2)
				END) 													AS amount_before_vat_thb
				
				FROM AP_INVOICES_ALL ap, 
				AP_INVOICE_LINES_ALL apl,
				POZ_SUPPLIERS_V poz,
				ZX_LINES_V tax,
				HR_ORGANIZATION_UNITS hou
				WHERE 1=1
				AND ap.vendor_id = poz.vendor_id
				AND ap.invoice_id = apl.invoice_id
				AND ap.org_id = apl.org_id
				AND ap.org_id = hou.organization_id
				AND ap.attribute_category = 'Thailand Information'
				AND apl.line_type_lookup_code = 'ITEM'
				AND apl.invoice_id = tax.trx_id(+)
				AND apl.line_number = tax.trx_line_id(+)
				AND tax.application_id(+) = 200
				AND tax.cancel_flag(+) = 'N'
				AND hou.name = NVL(:p_buname,hou.name)
				AND (ap.attribute_date1 BETWEEN NVL(:p_start_date,ap.attribute_date1) AND NVL(:p_end_date,ap.attribute_date1) OR (ap.attribute5 = 'Yes' AND (ap.attribute_date1 BETWEEN add_months((last_day(:p_end_date)+1),-7) AND (:p_end_date))))
				GROUP BY 
				ap.invoice_currency_code,
				ap.attribute_number1,
				ap.attribute_number2
				)a