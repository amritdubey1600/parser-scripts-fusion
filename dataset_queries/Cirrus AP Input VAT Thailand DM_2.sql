SELECT  b.period_year||b.period_month||'_'||'000'||ROWNUM   AS item_num, b.*
FROM
(
SELECT  DISTINCT a.*
				FROM 
				(
				SELECT DISTINCT ap.attribute_date1  						   AS date1
				,TO_CHAR(ap.attribute_date1,'DD/MM/YYYY')  	   				   AS tax_invoice_date
				,ap.attribute1 										   		   AS tax_invoice_num
				,ap.attribute3 									       	       AS supplier_branch_num
				,ap.attribute2 										   		   AS supplier_head_office
				,(CASE WHEN ap.invoice_currency_code = 'THB'
				THEN
				poz.vendor_name
				ELSE
				ap.attribute4
				END) 												   		   AS supplier_name
				,(CASE WHEN ap.invoice_currency_code = 'THB'
				THEN
				(SELECT psp.income_tax_id 
					FROM POZ_SUPPLIERS_PII psp
					WHERE psp.vendor_id=poz.vendor_id) 
				ELSE
				NULL
				END)												   		   AS tax_payer_id				
				,(CASE WHEN ap.invoice_currency_code = 'THB'
				THEN
				SUM(tax.tax_amt)
				ELSE
				SUM(ap.attribute_number1)
				END) 														   AS vat_thb
				,(CASE WHEN ap.invoice_currency_code = 'THB'
				THEN
				SUM(tax.line_amt)
				ELSE
				SUM(ap.attribute_number2)
				END) 														  AS amount_before_vat_thb
				,ap.invoice_num												  AS invoice_num
				,ap.invoice_currency_code   								  AS currency_code
				, SUBSTR((TO_CHAR(ap.attribute_date1,'MON')),1,2)    			AS period_month
				 				    	 
				, TO_CHAR(ap.attribute_date1,'YYYY')								AS period_year
				 					      
				
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
				ap.attribute_date1,
				ap.attribute1,
				ap.attribute3,
				ap.attribute2,
				poz.vendor_name,
				poz.vendor_id,
				ap.invoice_num,
				ap.invoice_currency_code,
				ap.attribute4,
				ap.attribute_number1,
				ap.attribute_number2
				)a
				ORDER BY to_char(date1,'MON') desc,TO_DATE(a.tax_invoice_date,'DD/MM/YYYY')
				)b
				ORDER BY ROWNUM