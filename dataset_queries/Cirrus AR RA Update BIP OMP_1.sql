--#-----------------------------------------------------------------------------------------------------#
--# MODIFICATION HISTORY:
--# CR#                       Author             Date                Description
--#-----------------------------------------------------------------------------------------------------#
--# REL-015 EMG                 Kishore Kumar  13-APR-2018       Commented OR condition to pick open GL & AR Period                --##                                                                                                   when IME required flag is '%C'.
--# REL-017                     Kishore Kumar  30-MAY-2018       Added logic to update GL Date and TRX Date for recurring invoice  --##  
--# REL-019 EMG                 Kishore Kumar  13-AUG-2018       Modified GL Date conditions for Bug-Fix on Non recurring invoices
--#-----------------------------------------------------------------------------------------------------#


DECLARE
  l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    msg_rec         FND_MESSAGE.MSG_REC_TYPE;
  err_count       NUMBER := 0;
  index_count1     NUMBER := 1;
  index_count2     NUMBER := 1;
  -- REL-017 added below code
  index_count3     NUMBER := 1;
  index_count4     NUMBER := 1;
  index_count11     NUMBER := 1;
  -- REL-017 added above code
  msg             CLOB;
  inv_num         NUMBER;

  intf_lines_rec1 RA_INTERFACE_LINES_ALL%ROWTYPE;
  intf_lines_rec2 RA_INTERFACE_LINES_ALL%ROWTYPE; 
  -- REL-017 added below code  
  intf_lines_rec3 RA_INTERFACE_LINES_ALL%ROWTYPE;  
  intf_lines_rec4 RA_INTERFACE_LINES_ALL%ROWTYPE;  
  intf_lines_rec11 RA_INTERFACE_LINES_ALL%ROWTYPE; 
  -- REL-017 added above code  
  intf_lines_tbl1 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;
  intf_lines_tbl2 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;
   -- REL-017 added below code  
  intf_lines_tbl3 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE; 
  intf_lines_tbl4 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE;
  intf_lines_tbl11 AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE; 
   -- REL-017 added above code  

  TYPE refcursor IS REF CURSOR;
  xdo_cursor refcursor;

  CURSOR intf_cursor1 IS
  
  SELECT rila.* 
     FROM RA_INTERFACE_LINES_ALL rila,GL_LEDGERS gl,VRM_OPERATING_UNITS_V bu,gl_period_statuses gps
     WHERE 1=1	 
	--REL-019 EMG  commented out --AND (DECODE(SUBSTR(TO_CHAR(rila.gl_date,'MM-YY') ,1,2),'01','JAN','02','FEB','03','MAR','04','APR','05','MAY','06','JUN', '07','JUL','08','AUG','09','SEP','10','OCT','11','NOV','12','DEC')||'-'||TO_CHAR(rila.GL_DATE,'YY')=gps.period_name
	 --or (rila.gl_date IS NULL ))     -- REL-015  commented out --  AND rila.TRX_DATE IS NULL 
	--REL-019 EMG  added below code 
	AND DECODE(SUBSTR(TO_CHAR(NVL(rila.trx_date,SYSDATE),'MM-YY') ,1,2),'01','JAN','02','FEB','03','MAR','04','APR','05','MAY','06','JUN', '07','JUL','08','AUG','09','SEP','10','OCT','11','NOV','12','DEC')||'-'||TO_CHAR(NVL(rila.trx_date,SYSDATE),'YY')=gps.period_name
    --REL-019 EMG  added above code  	
		--or (rila.trx_date IS NULL)) -- REL-015 EMG commented out -- rila.gl_date IS NULL AND 
	 AND NVL(rila.recurring_bill_flag, 'N') = 'N'
	 AND gl.ledger_id=NVL(rila.set_of_books_id,bu.default_ledger_id)
	 AND bu.org_id=rila.org_id
	 and gps.application_id =222
	 and gps.ledger_id =NVL(rila.set_of_books_id,bu.default_ledger_id)
		 -- REL-017 commented out -- AND BU.ORGANIZATION_NAME like '%DG%' 
	 AND bu.organization_name IN 
	      (
		    SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type='CIRRUS_AUTO_INV_BU_NAMES' AND language='US'      
			AND enabled_flag='Y'
			AND lookup_code <> 'DE_IP_DG18_BU'
			UNION
			 SELECT NVL(:ORG_NAME,'TEST')
			  FROM DUAL
			  WHERE :ORG_NAME = 'DE_IP_DG18_BU'
		  ) -- REL-017 added   
	 AND gps.closing_status(+) in ('C','O')
	 AND NVL(rila.interface_status,'N') <> 'P' -- REL-015 EMG added
	 AND gl.name=NVL(:LEDGER_NAME,gl.name)
	 AND bu.organization_name=NVL(:ORG_NAME,bu.organization_name)
	 AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
	 AND rila.interface_line_attribute1=NVL( :SALES_ORDER_NUM,rila.interface_line_attribute1);
	 
	 -- REL-017 added below code
	 
	CURSOR intf_cursor11 IS
  
	 
 SELECT rila.* 
     FROM RA_INTERFACE_LINES_ALL rila,GL_LEDGERS gl,VRM_OPERATING_UNITS_V bu
     WHERE 1=1	 
	 AND NVL(rila.recurring_bill_flag, 'N') = 'Y'
	 AND gl.ledger_id=NVL(rila.set_of_books_id,bu.default_ledger_id)
	 AND bu.org_id=rila.org_id
	 AND NVL(rila.interface_status,'N') <> 'P'
     AND rila.accounting_rule_id = 1 
	 AND rila.rule_end_date IS NOT NULL 
	 AND gl.name=NVL(:LEDGER_NAME,gl.name)
	 AND bu.organization_name IN 
	      (
		    SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type='CIRRUS_AUTO_INV_BU_NAMES' AND language='US'      
			AND enabled_flag='Y'
			AND lookup_code <> 'DE_IP_DG18_BU'
			UNION
			 SELECT NVL(:ORG_NAME,'TEST')
			  FROM DUAL
			  WHERE :ORG_NAME = 'DE_IP_DG18_BU'
		  ) -- REL-017 added   
	 AND bu.organization_name=NVL(:ORG_NAME,bu.organization_name)
	 AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
	 AND rila.interface_line_attribute1=NVL(:SALES_ORDER_NUM,rila.interface_line_attribute1);
	 
	 --This cursor is to update GL Date and Rule Start Date when GL Date is less than current date for recurring invoice
  CURSOR intf_cursor2 IS
  
	 
 SELECT rila.* 
     FROM RA_INTERFACE_LINES_ALL rila,GL_LEDGERS gl,VRM_OPERATING_UNITS_V bu
     WHERE 1=1	 
	 AND NVL(rila.recurring_bill_flag, 'N') = 'Y'
	 AND gl.ledger_id=NVL(rila.set_of_books_id,bu.default_ledger_id)
	 AND bu.org_id=rila.org_id
	 AND NVL(rila.interface_status,'N') <> 'P'
     AND rila.gl_date < SYSDATE	 
	 AND gl.name=NVL(:LEDGER_NAME,gl.name)
	 AND bu.organization_name IN 
	      (
		    SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type='CIRRUS_AUTO_INV_BU_NAMES' AND language='US'      
			AND enabled_flag='Y'
			AND lookup_code <> 'DE_IP_DG18_BU'
			UNION
			 SELECT NVL(:ORG_NAME,'TEST')
			  FROM DUAL
			  WHERE :ORG_NAME = 'DE_IP_DG18_BU'
		  ) -- REL-017 added   
	 AND bu.organization_name=NVL(:ORG_NAME,bu.organization_name)
	 AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
	 AND rila.interface_line_attribute1=NVL( :SALES_ORDER_NUM,rila.interface_line_attribute1);
	 
--This cursor is to update TRX Date when TRX Date is not equal to GL Date for recurring invoice
 CURSOR intf_cursor3 IS  
	 
 SELECT rila.* 
     FROM RA_INTERFACE_LINES_ALL rila,GL_LEDGERS gl,VRM_OPERATING_UNITS_V bu
     WHERE 1=1	 
	 AND NVL(rila.RECURRING_BILL_FLAG, 'N') = 'Y'
	 AND gl.ledger_id=NVL(rila.set_of_books_id,bu.default_ledger_id)
	 AND bu.org_id=rila.org_id
	 AND NVL(rila.interface_status,'N') <> 'P' 
	 AND rila.trx_date <> rila.gl_date
	 AND bu.organization_name IN 
	      (
		    SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type='CIRRUS_AUTO_INV_BU_NAMES' AND language='US'      
			AND enabled_flag='Y'
			AND lookup_code <> 'DE_IP_DG18_BU'
			UNION
			 SELECT NVL(:ORG_NAME,'TEST')
			  FROM DUAL
			  WHERE :ORG_NAME = 'DE_IP_DG18_BU'
		  ) -- REL-017 added   
	 AND gl.name=NVL(:LEDGER_NAME,gl.name)
	 AND bu.organization_name=NVL(:ORG_NAME,bu.organization_name)
	 AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
	 AND rila.interface_line_attribute1=NVL( :SALES_ORDER_NUM,rila.interface_line_attribute1);
	 
 CURSOR intf_cursor4 IS 
 SELECT rila.* 
     FROM RA_INTERFACE_LINES_ALL rila,GL_LEDGERS gl,VRM_OPERATING_UNITS_V bu
     WHERE 1=1   
                AND NVL(rila.RECURRING_BILL_FLAG, 'N') = 'Y'
                AND gl.ledger_id=NVL(rila.set_of_books_id,bu.default_ledger_id)
                AND bu.org_id=rila.org_id
                AND NVL(rila.interface_status,'N') <> 'P' 
                AND rila.rule_start_date <>  rila.rule_end_date
                AND rila.accounting_rule_id = '-106'
	 AND bu.organization_name IN 
	      (
		    SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type='CIRRUS_AUTO_INV_BU_NAMES' AND language='US'      
			AND enabled_flag='Y'
			AND lookup_code <> 'DE_IP_DG18_BU'
			UNION
			 SELECT NVL(:ORG_NAME,'TEST')
			  FROM DUAL
			  WHERE :ORG_NAME = 'DE_IP_DG18_BU'
		  ) -- REL-017 added   
                AND gl.name=NVL(:LEDGER_NAME,gl.name)
                AND bu.organization_name=NVL(:ORG_NAME,bu.organization_name)
                AND rila.batch_source_name=NVL(:TRANSACTION_SOURCE,rila.batch_source_name)
                AND rila.interface_line_attribute1=NVL( :SALES_ORDER_NUM,rila.interface_line_attribute1); 

	-- REL-017 added above code 
	
  BEGIN

  
  intf_lines_tbl1 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();


  OPEN intf_cursor1;
  LOOP
    FETCH intf_cursor1
      INTO intf_lines_rec1;
    EXIT WHEN intf_cursor1%notfound;
	
			
	intf_lines_rec1.gl_date  := SYSDATE;
    intf_lines_rec1.trx_date := SYSDATE;
    intf_lines_tbl1.extend;
	 -- REL-015 EMG added below code
	IF            
	intf_lines_rec1.accounting_rule_id IN ('300000015579941','1','-104','-102','-100')
	THEN intf_lines_rec1.rule_start_date := SYSDATE;
	END IF;         
	-- REL-015 EMG added above code
    intf_lines_tbl1(index_count1) := intf_lines_rec1;
    index_count1 := index_count1 + 1;
		
  END LOOP;
  CLOSE intf_cursor1;  
  
  
  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl1,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status);

		COMMIT;									 
																		 
	 IF l_return_status = fnd_api.g_ret_sts_error OR
     l_return_status = fnd_api.g_ret_sts_unexp_error THEN
  
    FOR i in 1 .. l_msg_count LOOP
    
      fnd_msg_pub.get(fnd_msg_pub.g_first,
                      fnd_api.g_true,
                      l_msg_data,
                      l_msg_count);
    
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      msg_rec := FND_MESSAGE.GET_MESSAGE_RECORD;
    
      msg := msg || msg_rec.user_message || '.   ';
    
      fnd_msg_pub.Delete_Msg(1);
    END LOOP;
  
    fnd_msg_pub.Delete_Msg;
  
  END IF;
-- REL-017 added below code
--Begin block is to update GL Date when GL Date is less than current date for recurring invoice		
 BEGIN			

    l_return_status :=NULL;
    l_msg_count     :=NULL;
    l_msg_data      :=NULL;	

  intf_lines_tbl11 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();	
											  
 OPEN intf_cursor11;
  LOOP
    FETCH intf_cursor11
      INTO intf_lines_rec11;
    EXIT WHEN intf_cursor11%notfound;	

	intf_lines_rec11.accounting_rule_id   := '-106';
	intf_lines_rec11.rule_end_date        := intf_lines_rec11.rule_start_date;   
	
    intf_lines_tbl11.extend;
    intf_lines_tbl11(index_count11) := intf_lines_rec11;
    index_count11 := index_count11 + 1;

		
  END LOOP;
  CLOSE intf_cursor11; 
  
	

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl11,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status); 

											 COMMIT;
											 
END; 
									 
BEGIN			

    l_return_status :=NULL;
    l_msg_count     :=NULL;
    l_msg_data      :=NULL;	

  intf_lines_tbl2 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();	
											  
 OPEN intf_cursor2;
  LOOP
    FETCH intf_cursor2
      INTO intf_lines_rec2;
    EXIT WHEN intf_cursor2%notfound;

	intf_lines_rec2.gl_date           := SYSDATE;

  If intf_lines_rec2.accounting_rule_id = '-106' 
  THEN 
             intf_lines_rec2.rule_start_date   := SYSDATE; 
             intf_lines_rec2.rule_end_date     := SYSDATE;
  END IF;
  
  If intf_lines_rec2.accounting_rule_id = '1'
  THEN 
             intf_lines_rec2.rule_start_date   := SYSDATE; 
  END IF;
	
    intf_lines_tbl2.extend;
    intf_lines_tbl2(index_count2) := intf_lines_rec2;
    index_count2 := index_count2 + 1;

		
  END LOOP;
  CLOSE intf_cursor2; 
  
	

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl2,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status); 
											 
											 COMMIT;
											 
END;


--Begin block is to update TRX Date when TRX Date is not equal to GL Date for recurring invoice
BEGIN			

    l_return_status :=NULL;
    l_msg_count     :=NULL;
    l_msg_data      :=NULL;		

  intf_lines_tbl3 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();	
											  
 OPEN intf_cursor3;
  LOOP
    FETCH intf_cursor3
      INTO intf_lines_rec3;
    EXIT WHEN intf_cursor3%notfound;
	

	intf_lines_rec3.trx_date          :=  intf_lines_rec3.gl_date; 
	
    intf_lines_tbl3.extend;
    intf_lines_tbl3(index_count3) := intf_lines_rec3;
    index_count3 := index_count3 + 1;

		
  END LOOP;
  CLOSE intf_cursor3; 
  
	

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl3,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status); 
											 
											 COMMIT;
											 
END;
											 									 


BEGIN			

    l_return_status :=NULL;
    l_msg_count     :=NULL;
    l_msg_data      :=NULL;	

  intf_lines_tbl4 := AR_AUTOINV_INTF_PKG.INTF_LINES_TBL_TYPE();	
											  
 OPEN intf_cursor4;
  LOOP
    FETCH intf_cursor4
      INTO intf_lines_rec4;
    EXIT WHEN intf_cursor4%notfound;

	intf_lines_rec4.rule_start_date     := intf_lines_rec4.gl_date;
	intf_lines_rec4.rule_end_date       := intf_lines_rec4.gl_date;  
	
    intf_lines_tbl4.extend;
    intf_lines_tbl4(index_count4) := intf_lines_rec4;
    index_count4 := index_count4 + 1;

		
  END LOOP;
  CLOSE intf_cursor4; 
  
	

  AR_AUTOINV_INTF_PKG.UPDATE_INTERFACE_LINES(intf_lines_tbl4,
                                             l_msg_count,
                                             l_msg_data,
                                             l_return_status); 

											 COMMIT;
											 
END; 								 
	
-- REL-017 added above code		
											 
  IF l_return_status = fnd_api.g_ret_sts_error OR
     l_return_status = fnd_api.g_ret_sts_unexp_error THEN
  
    FOR i in 1 .. l_msg_count LOOP
    
      fnd_msg_pub.get(fnd_msg_pub.g_first,
                      fnd_api.g_true,
                      l_msg_data,
                      l_msg_count);
    
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      msg_rec := FND_MESSAGE.GET_MESSAGE_RECORD;
    
      msg := msg || msg_rec.user_message || '.   ';
    
      fnd_msg_pub.Delete_Msg(1);
    END LOOP;
  
    fnd_msg_pub.Delete_Msg;
  
  END IF;

  OPEN :xdo_cursor FOR
    SELECT msg FROM dual;
  COMMIT;

END;