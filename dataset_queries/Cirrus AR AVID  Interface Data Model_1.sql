SELECT DISTINCT gl.name 									ledger_name
      ,bu.ORganization_name 								business_unit
	  ,rila.batch_source_name								source_name
	  ,rila.interface_line_attribute1 						sales_ORder_number
	  ,TO_CHAR(rila.SALES_ORDER_DATE,'mm-dd-yyyy')			sales_order_date
	  , (select DL.DISPLAY_LINE_NUMBER 
	    from DOO_LineS_ALL DL 
		where DL.Line_id = rila.SALES_ORDER_LINE)           sales_Order_Line_number
	  ,rila.INTERFACE_LINE_ATTRIBUTE14 						Installment_number	
, rila.AMOUNT											Installment_amount
      ,TO_CHAR(rila.SHIP_DATE_ACTUAL,'mm-dd-yyyy')			Ship_date
	  ,TO_CHAR(rila.gl_date,'mm-dd-yyyy') 					gl_date
	  ,TO_CHAR(rila.trx_date ,'mm-dd-yyyy')				    trx_date
	  ,TO_CHAR((SELECT SYSDATE FROM dual) ,'mm-dd-yyyy') 	sys_date  
      ,TO_CHAR(rila.creation_date ,'mm-dd-yyyy')			creation_date 
	  ,TO_CHAR (CONTRACT_START_DATE,'mm-dd-yyyy')           Contract_Start_date
	  ,TO_CHAR (CONTRACT_END_DATE,'mm-dd-yyyy')             Contract_End_date
	  ,TO_CHAR(rila.rule_start_date,'mm-dd-yyyy') 			rule_start_date
	  ,TO_CHAR(rila.rule_end_date,'mm-dd-yyyy') 			rule_end_date
	  ,TO_CHAR(BILLING_PERIOD_START_DATE,'mm-dd-yyyy')      Billing_Period_start_date
	  ,TO_CHAR(BILLING_PERIOD_END_DATE,'mm-dd-yyyy')        Billing_Period_end_date  	
	  ,TO_CHAR(rila.last_update_date,'mm-dd-yyyy') 			last_update_date
	  ,rila.last_updated_by	
	  ,rila.line_type
	  ,rila.interface_line_guid 							interface_line_attribute11
	  ,rila.interface_line_attribute3
	  ,rila.recurring_bill_flag
	  ,rila.accounting_rule_id
FROM   RA_INTERFACE_LINES_ALL rila
      ,GL_LEDGERS gl
	  ,VRM_OPERATING_UNITS_V bu
WHERE 1=1	 
	   AND gl.ledger_id=NVL(rila.set_of_books_id,bu.default_ledger_id)
	   AND bu.ORg_id=rila.ORg_id
	   --AND gps.application_id =222
	 --AND gps.ledger_id =NVL(rila.set_of_books_id,bu.default_ledger_id)
	   AND BU.ORGANIZATION_NAME IN (select lookup_code 
	                                from fnd_lookup_values 
							        where lookup_type='AVD_BU_NAMES' and language='US')
	   AND gl.name=NVL(:LEDGER_NAME,gl.name)
	   AND NVL(rila.interface_status,'N') <> 'P' -- REL-015 EMG added
	   AND bu.ORganization_name=NVL(:ORG_NAME,bu.ORganization_name)
	   AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
	   AND rila.interface_line_attribute1= NVL(:SALES_ORDER_NUM,rila.interface_line_attribute1)