SELECT DISTINCT
	   b.customer_trx_id
      ,b.line_number
	  ,b.customer_trx_line_id
	  ,'ITEM' AS line_type
	  ,(b.extended_amount + NVL((SELECT SUM(rct.extended_amount) 
							 FROM RA_CUSTOMER_TRX_LINES_ALL rct 
							 WHERE rct.line_type ='TAX' 
							 AND customer_trx_id =b.customer_trx_id
							 AND rct.line_number = b.line_number),0))AS amount
	  ,b.quantity_invoiced AS invoiced_quantity
	  ,b.unit_selling_price AS unit_price
	  ,(SELECT intl.unit_of_measure
		  FROM INV_UNITS_OF_MEASURE_B inb,
		       INV_UNITS_OF_MEASURE_TL intl
		 WHERE inb.unit_of_measure_id = intl.unit_of_measure_id
		   AND intl.LANGUAGE='US'
		   AND inb.uom_code = b.uom_code
	  ) AS uom
	  ,b.description
	  ,'N' AS final_match
	  ,TO_CHAR(b.creation_date,'YYYY-MM-DD') AS accounting_date
	  ,'CIRRUSARIC' AS attribute_category
	  ,b.customer_trx_id AS attribute1
	  ,b.customer_trx_line_id AS attribute2
	  ,(REPLACE (gcc.segment1,gcc.segment1,(SELECT DISTINCT SUBSTR(j.lookup_code,9,4)
				FROM FND_LOOKUP_VALUES 
			   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
			   AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) ))||'.'||
       REPLACE(gcc.segment2,gcc.segment2,'5020101003')||'.'||
       gcc.segment3||'.'||
	   			(SELECT DISTINCT attribute6
				FROM FND_LOOKUP_VALUES 
			   WHERE lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD' 
			   AND lookup_code = 'AP-'||SUBSTR(j.lookup_code,9,4)||'-'||SUBSTR(j.lookup_code,4,4) )||'.'||
       gcc.segment5||'.'||
       gcc.segment6||'.'||
       gcc.segment7||'.'||
       gcc.segment8||'.'||
       gcc.segment9||'.'||
       gcc.segment10||'.'||
       gcc.segment11) AS concatenated_segments
 FROM RA_CUSTOMER_TRX_ALL          a,
	  RA_CUSTOMER_TRX_LINES_ALL    b,
	  RA_CUST_TRX_LINE_GL_DIST_ALL rctlgl,
	  GL_CODE_COMBINATIONS         gcc,
      XLA_AE_HEADERS               xah,
      XLA_AE_LINES                 xal,
      XLA_DISTRIBUTION_LINKS       xdl,
	  FND_LOOKUP_VALUES          j
 WHERE 1=1
   AND a.customer_trx_id     = b.customer_trx_id
   AND b.customer_trx_line_id = rctlgl.customer_trx_line_id
   AND xdl.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND rctlgl.account_class = 'REV'
   AND xdl.source_distribution_id_num_1 = rctlgl.cust_trx_line_gl_dist_id
   AND xal.code_combination_id = gcc.code_combination_id
   AND xah.ae_header_id = xal.ae_header_id
   AND xdl.ae_header_id = xal.ae_header_id
   AND xdl.ae_line_num = xal.ae_line_num
   AND j.lookup_type (+)     = 'CIRRUSARAP_IBS_INTER_CO_EXCLUD'
   AND j.enabled_flag        = 'Y'
   AND a.legal_entity_id     = j.attribute1
   AND a.bill_to_customer_id = j.attribute3
   AND a.org_id              = j.attribute2
   AND xdl.accounting_line_type_code = 'C'
   AND b.line_type !='TAX'